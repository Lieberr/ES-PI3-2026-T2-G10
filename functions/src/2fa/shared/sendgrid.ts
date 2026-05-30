import sgMail from "@sendgrid/mail";



/**
 * Envia o código 2FA para o email do usuário por SendGrid.
 * @param {string} email Email do destinatário.
 * @param {string} code Código de verificação.
 */
export async function enviarCodigoEmail(
  email: string,
  code: string,
) {
  sgMail.setApiKey("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");

  await sgMail.send({
    to: email,
    from: "gustavoliebfigueira1@gmail.com",
    subject: "Seu código de verificação 2FA",
    text: `Seu código de verificação é ${code}.`,
    html: `<p>Seu código de verificação é <strong>${code}</strong>.</p>`,
  });
}
