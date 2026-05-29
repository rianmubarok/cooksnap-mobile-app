function sendViaBrevo(e) {
    const apiKey = $os.getenv("BREVO_API_KEY");
    if (!apiKey) {
        $app.logger().warn("BREVO_API_KEY is not set. Falling back to default SMTP.");
        return; // Lanjutkan menggunakan SMTP standar jika API key tidak ada
    }

    const senderEmail = $os.getenv("BREVO_SENDER_EMAIL") || "noreply@cooksnap.app";
    const userEmail = e.record.get("email");
    const subject = e.mail.subject || "CookSnap Notification";
    const htmlContent = e.mail.html || `<p>Please check your account.</p>`;

    try {
        const res = $http.send({
            url: "https://api.brevo.com/v3/smtp/email",
            method: "POST",
            headers: {
                "api-key": apiKey,
                "Content-Type": "application/json",
                "Accept": "application/json"
            },
            body: JSON.stringify({
                sender: {
                    name: "CookSnap",
                    email: senderEmail
                },
                to: [
                    {
                        email: userEmail
                    }
                ],
                subject: subject,
                htmlContent: htmlContent
            }),
            timeout: 10 // 10 seconds timeout
        });

        if (res.statusCode >= 400) {
            $app.logger().error("Failed to send email via Brevo API", "status", res.statusCode, "response", res.raw);
        } else {
            $app.logger().info("Email sent successfully via Brevo API to " + userEmail);
        }

        // Tidak perlu membatalkan e.cancel() agar tidak memicu error.
        // Cukup biarkan PocketBase melanjutkan tugasnya (pastikan SMTP di Dashboard dimatikan).
    } catch (err) {
        $app.logger().error("Error executing Brevo HTTP request: " + err);
        // Jangan batalkan jika gagal HTTP, biarkan SMTP mencoba (meskipun mungkin timeout)
    }
}

// Intersep email Verifikasi Akun
onMailerBeforeRecordVerificationSend((e) => {
    return sendViaBrevo(e);
});

// Intersep email Lupa Password (Password Reset)
onMailerBeforeRecordPasswordResetSend((e) => {
    return sendViaBrevo(e);
});

// Intersep email Perubahan Alamat Email
onMailerBeforeRecordChangeEmailSend((e) => {
    return sendViaBrevo(e);
});
