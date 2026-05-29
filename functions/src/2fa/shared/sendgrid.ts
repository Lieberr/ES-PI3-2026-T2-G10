import sendgrid from "@sendgrid/mail";


const SENDGRID_KEY =
  "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";
if (!SENDGRID_KEY) {
  throw new Error("SENDGRID_KEY nao definido no arquivo.");
}

sendgrid.setApiKey(SENDGRID_KEY);

/**
 * Envia o código 2FA para o email do usuário por SendGrid.
 * @param {string} email Email do destinatário.
 * @param {string} code Código de verificação.
 */
export async function enviarCodigoEmail(
  email: string,
  code: string,
) {
  await sendgrid.send({
    to: email,
    from: "no-reply@seu-dominio.com",
    subject: "Seu código de verificação 2FA",
    text: `Seu código de verificação é ${code}.`,
    html: `<p>Seu código de verificação é <strong>${code}</strong>.</p>`,
  });
}
