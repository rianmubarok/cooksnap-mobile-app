routerAdd("POST", "/api/qris/create", (c) => {
    // Auth check
    const user = c.get("authRecord")
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

    try {
        const res = $http.send({
            url: "https://klikqris.com/api/qris/create",
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "x-api-key": apiKey,
                "id_merchant": merchantId
            },
            body: JSON.stringify({
                "order_id": orderId,
                "id_merchant": merchantId,
                "amount": amount,
                "keterangan": "CookSnap PRO 1 Bulan"
            })
        })

        if (res.statusCode !== 200) {
            throw new BadRequestError("Failed to create transaction with KlikQRIS")
        }

        const jsonRes = res.json()
        if (!jsonRes.status || !jsonRes.data) {
             throw new BadRequestError("Invalid response from KlikQRIS")
        }

        const qrisData = jsonRes.data

        // Create transaction
        const collection = $app.dao().findCollectionByNameOrId("transactions")
        const record = new Record(collection)

        record.set("order_id", qrisData.order_id)
        record.set("user_id", userId)
        record.set("amount", parseInt(qrisData.amount))
        record.set("total_amount", parseInt(qrisData.total_amount))
        record.set("status", "PENDING")
        record.set("signature", qrisData.signature)

        $app.dao().saveRecord(record)

        return c.json(200, {
            "order_id": qrisData.order_id,
            "total_amount": qrisData.total_amount,
            "qris_image": qrisData.qris_image
        })
    } catch (err) {
        throw new BadRequestError("Error processing payment: " + err)
    }
}, $apis.requireRecordAuth())


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
        const record = $app.dao().findFirstRecordByData("transactions", "order_id", orderId)
        
        // Validation 1: Check Signature
        if (record.get("signature") !== signature) {
            return c.json(400, { "error": "Invalid signature" })
        }

        // Processing
        if (status === "PAID" || status === "SUCCESS") {
            if (record.get("status") !== "PAID") {
                record.set("status", "PAID")
                $app.dao().saveRecord(record)

                // Update User
                const userId = record.get("user_id")
                const userRecord = $app.dao().findRecordById("users", userId)
                
                userRecord.set("is_premium", true)
                
                // Add 30 days
                const now = new Date()
                now.setDate(now.getDate() + 30)
                const formattedDate = now.toISOString().replace('T', ' ').substring(0, 19) + 'Z'
                userRecord.set("premium_until", formattedDate)

                $app.dao().saveRecord(userRecord)
            }
        } else if (status === "EXPIRED") {
             if (record.get("status") !== "PAID") {
                 record.set("status", "EXPIRED")
                 $app.dao().saveRecord(record)
             }
        }

        return c.json(200, { "status": "success" })

    } catch (err) {
        return c.json(404, { "error": "Transaction not found" })
    }
})

// Optional route to check status manually
routerAdd("GET", "/api/qris/status/:orderId", (c) => {
    const user = c.get("authRecord")
    if (!user) {
        throw new ForbiddenError("Not authorized.")
    }
    
    const orderId = c.pathParam("orderId")
    
    try {
        const record = $app.dao().findFirstRecordByData("transactions", "order_id", orderId)
        
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
}, $apis.requireRecordAuth())
