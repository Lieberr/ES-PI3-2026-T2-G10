import {onCall, CallableRequest, HttpsError} from "firebase-functions/https";
import {Timestamp} from "firebase-admin/firestore";
import {enviarCodigoEmail} from "../shared/sendgrid";
import {
  salvarCodigo2FA,
  buscarCodigo2FA,
} from "../repositories/twofaRepository";
import * as crypto from "crypto";

export const send2FACode = onCall(
  async (request: CallableRequest<Record<string, unknown>>) => {
    const uid = request.auth?.uid;
    const email =
      (request.data.email as string | undefined) ??
      request.auth?.token?.email;

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado.",
      );
    }

    if (!email || typeof email !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "Email do usário não encontrado.",
      );
    }

    const existing = await buscarCodigo2FA(uid);
    if (existing) {
      const now = Timestamp.now().toMillis();
      const expiresAt = existing.expiresAt.toMillis();
      if (now < expiresAt - 60_000) {
        throw new HttpsError(
          "resource-exhausted",
          "Ainda não pode reenviar o código. Aguarde um minuto."
        );
      }
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const hash = crypto.createHash("sha256").update(code).digest("hex");
    const expiresAt = Timestamp.fromMillis(Date.now() + 5 * 60 * 1000);

    await salvarCodigo2FA(uid, hash, expiresAt);

    await enviarCodigoEmail(email, code);

    return {ok: true};
  });

