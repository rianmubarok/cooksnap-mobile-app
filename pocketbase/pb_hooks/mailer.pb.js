function sendViaBrevo(e) {
    const apiKey = $os.getenv("BREVO_API_KEY");
    if (!apiKey) {
        throw new Error("BREVO_API_KEY_MISSING");
    }

    const senderEmail = $os.getenv("BREVO_SENDER_EMAIL") || "noreply@cooksnap.app";
    const userEmail = e.record.get("email");
    const subject = e.mail.subject || "CookSnap Notification";
    const htmlContent = e.mail.html || `<p>Please check your account.</p>`;

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
        timeout: 10
    });

    if (res.statusCode >= 400) {
        throw new Error("BREVO_FAILED: " + res.raw);
    } else {
        // Jika sukses, kita lempar error khusus untuk MENCEGAH sendmail berjalan
        // dan agar kita bisa melihat buktinya di log.
        throw new Error("BREVO_SUCCESS_EMAIL_SENT_TO_" + userEmail);
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
