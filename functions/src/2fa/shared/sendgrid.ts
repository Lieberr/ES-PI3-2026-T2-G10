import {defineSecret} from "firebase-functions/params";
import sgMail from "@sendgrid/mail";


const SENDGRID_KEY = defineSecret("SENDGRID_KEY");

/**
 * Envia o código 2FA para o email do usuário por SendGrid.
 * @param {string} email Email do destinatário.
 * @param {string} code Código de verificação.
 */
export async function enviarCodigoEmail(
  email: string,
  code: string,
) {
  sgMail.setApiKey(SENDGRID_KEY.value());

  await sgMail.send({
    to: email,
    from: "no-reply@seu-dominio.com",
    subject: "Seu código de verificação 2FA",
    text: `Seu código de verificação é ${code}.`,
    html: `<p>Seu código de verificação é <strong>${code}</strong>.</p>`,
  });
}
