import sgMail from "@sendgrid/mail";
import { defineSecret } from "firebase-functions/params";

export const sendgridKey = defineSecret("SENDGRID_API_KEY");

/**
 * Envia o código 2FA para o email do usuário por SendGrid.
 * @param {string} email Email do destinatário.
 * @param {string} code Código de verificação.
 */
export async function enviarCodigoEmail(
  email: string,
  code: string,
) {
  sgMail.setApiKey(sendgridKey.value());

  await sgMail.send({
    to: email,
    from: "gustavoliebfigueira1@gmail.com",
    subject: "Seu código de verificação 2FA",
    text: `Seu código de verificação é ${code}.`,
    html: `<p>Seu código de verificação é <strong>${code}</strong>.</p>`,
  });
}
