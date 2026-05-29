onMailerRecordVerificationSend((e) => {
    const apiKey = $os.getenv("BREVO_API_KEY");
    if (!apiKey) {
        $app.logger().warn("BREVO_API_KEY is not set. Falling back to default SMTP.");
        return e.next();
    }

    const senderEmail = $os.getenv("BREVO_SENDER_EMAIL") || "noreply@cooksnap.app";
    const userEmail = e.record.get("email");
    const subject = e.message.subject || "CookSnap Notification";
    const htmlContent = e.message.html || `<p>Please check your account.</p>`;

    const res = $http.send({
        url: "https://api.brevo.com/v3/smtp/email",
        method: "POST",
        headers: {
            "api-key": apiKey,
            "Content-Type": "application/json",
            "Accept": "application/json"
        },
        body: JSON.stringify({
            sender: { name: "CookSnap", email: senderEmail },
            to: [{ email: userEmail }],
            subject: subject,
            htmlContent: htmlContent
        }),
        timeout: 10
    });

    if (res.statusCode >= 400) {
        throw new Error("BREVO_FAILED: " + res.raw);
    } else {
        $app.logger().info("Email sent successfully via Brevo API to " + userEmail);
        return; // Prevent sendmail
    }
});

onMailerRecordPasswordResetSend((e) => {
    const apiKey = $os.getenv("BREVO_API_KEY");
    if (!apiKey) return e.next();
    
    const senderEmail = $os.getenv("BREVO_SENDER_EMAIL") || "noreply@cooksnap.app";
    const userEmail = e.record.get("email");
    const res = $http.send({
        url: "https://api.brevo.com/v3/smtp/email",
        method: "POST",
        headers: {
            "api-key": apiKey,
            "Content-Type": "application/json",
            "Accept": "application/json"
        },
        body: JSON.stringify({
            sender: { name: "CookSnap", email: senderEmail },
            to: [{ email: userEmail }],
            subject: e.message.subject || "Password Reset",
            htmlContent: e.message.html || ""
        }),
        timeout: 10
    });
    if (res.statusCode >= 400) throw new Error("BREVO_FAILED: " + res.raw);
    return;
});
