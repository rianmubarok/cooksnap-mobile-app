routerAdd("POST", "/api/qris/create", (c) => {
    // Auth check
    const user = c.auth
    if (!user) {
        throw new ForbiddenError("Not authorized.")
    }

    const userId = user.id
    const orderId = "CS-PRO-" + Date.now() + "-" + $security.randomString(5)
    
    // Amount
    const amount = 15000 // Rp 15.000 for CookSnap PRO 1 month

    const apiKey = $os.getenv("KLIKQRIS_API_KEY")
    const merchantId = $os.getenv("KLIKQRIS_MERCHANT_ID")

    if (!apiKey || !merchantId) {
        throw new BadRequestError("Server configuration missing: KLIKQRIS_API_KEY or KLIKQRIS_MERCHANT_ID")
    }

    // Call KlikQRIS API
    let res
    try {
        res = $http.send({
            url: "https://klikqris.com/api/qris/create",
            method: "POST",
            headers: {
                "content-type": "application/json",
                "x-api-key": apiKey,
                "id_merchant": merchantId
            },
            body: JSON.stringify({
                "order_id": orderId,
                "id_merchant": merchantId,
                "amount": amount,
                "keterangan": "CookSnap PRO 1 Bulan",
                "callback_url": "https://cooksnap-mobile-app-production.up.railway.app/api/qris/webhook"
            }),
            timeout: 30
        })
    } catch (httpErr) {
        throw new BadRequestError("KlikQRIS connection error: " + httpErr)
    }

    // Log full response for debugging
    const rawBody = res.raw
    const statusCode = res.statusCode

    if (statusCode < 200 || statusCode >= 300) {
        throw new BadRequestError("KlikQRIS HTTP " + statusCode + ": " + rawBody)
    }

    // Parse response
    let jsonRes
    try {
        jsonRes = JSON.parse(rawBody)
    } catch (parseErr) {
        throw new BadRequestError("KlikQRIS parse error. Raw: " + rawBody)
    }

    if (!jsonRes.data) {
        throw new BadRequestError("KlikQRIS no data. Response: " + rawBody)
    }

    const qrisData = jsonRes.data

    // Create transaction record
    try {
        const collection = $app.findCollectionByNameOrId("transactions")
        const record = new Record(collection)

        record.set("order_id", qrisData.order_id || orderId)
        record.set("user_id", userId)
        record.set("amount", parseInt(amount))
        record.set("total_amount", parseInt(qrisData.total_amount || amount))
        record.set("status", "PENDING")
        record.set("signature", qrisData.signature || "")

        $app.save(record)
    } catch (dbErr) {
        throw new BadRequestError("DB save error: " + dbErr)
    }

    return c.json(200, {
        "order_id": qrisData.order_id || orderId,
        "total_amount": qrisData.total_amount || amount,
        "qris_image": qrisData.qris_image || ""
    })
}, $apis.requireAuth())


routerAdd("POST", "/api/qris/webhook", (c) => {
    // Webhook from KlikQRIS
    // Webhook sends application/json POST body.
    let body = new DynamicModel({
        "order_id": "",
        "status": "",
        "amount": 0,
        "total_amount": 0,
        "payment_date": "",
        "signature": ""
    })

    c.bind(body)

    const orderId = body.order_id
    const status = body.status
    const signature = body.signature

    if (!orderId || !status || !signature) {
         return c.json(400, { "error": "Missing parameters" })
    }

    try {
        const record = $app.findFirstRecordByData("transactions", "order_id", orderId)
        
        // Validation 1: Check Signature
        if (record.get("signature") !== signature) {
            return c.json(400, { "error": "Invalid signature" })
        }

        // Processing
        if (status === "PAID" || status === "SUCCESS") {
            if (record.get("status") !== "PAID") {
                record.set("status", "PAID")
                $app.save(record)

                // Update User
                const userId = record.get("user_id")
                const userRecord = $app.findRecordById("users", userId)
                
                userRecord.set("is_premium", true)
                
                // Add 30 days
                const now = new Date()
                now.setDate(now.getDate() + 30)
                const formattedDate = now.toISOString().replace('T', ' ').substring(0, 19) + 'Z'
                userRecord.set("premium_until", formattedDate)

                $app.save(userRecord)
            }
        } else if (status === "EXPIRED") {
             if (record.get("status") !== "PAID") {
                 record.set("status", "EXPIRED")
                 $app.save(record)
             }
        }

        return c.json(200, { "status": "success" })

    } catch (err) {
        return c.json(404, { "error": "Transaction not found" })
    }
})

// Optional route to check status manually
routerAdd("GET", "/api/qris/status/:orderId", (c) => {
    const user = c.auth
    if (!user) {
        throw new ForbiddenError("Not authorized.")
    }
    
    const orderId = c.pathParam("orderId")
    
    try {
        const record = $app.findFirstRecordByData("transactions", "order_id", orderId)
        
        if (record.get("user_id") !== user.id) {
             throw new ForbiddenError("Not authorized.")
        }
        
        return c.json(200, {
            "order_id": record.get("order_id"),
            "status": record.get("status")
        })
    } catch (e) {
        throw new NotFoundError("Transaction not found")
    }
}, $apis.requireAuth())
