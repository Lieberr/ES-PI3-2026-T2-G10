import {onCall, CallableRequest, HttpsError} from "firebase-functions/https";
import * as crypto from "crypto";
import {
  buscarCodigo2FA,
  incrementarTentativas2FA,
  deletarCodigo2FA,
  marcarTwoFaEnabled,
} from "../repositories/twofaRepository";

export const verify2FACode = onCall(
  async (request: CallableRequest<Record<string, unknown>>) => {
    const uid = request.auth?.uid;
    const code = String(request.data.code ?? "").trim();

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado"
      );
    }

    if (code.length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "Código inválido"
      );
    }

    const record = await buscarCodigo2FA(uid);
    if (!record) {
      throw new HttpsError(
        "not-found",
        "Nenhum código 2FA encontrado."
      );
    }

    const now = record.expiresAt.toMillis();
    if (Date.now() > now) {
      await deletarCodigo2FA(uid);
      throw new HttpsError(
        "deadline-exceeded",
        "Código expirado."
      );
    }

    if ((record.attempts ?? 0) >= 5) {
      await deletarCodigo2FA(uid);
      throw new HttpsError(
        "permission-denied",
        "Número máximo de tentativas excedido."
      );
    }

    const hash = crypto.createHash("sha256").update(code).digest("hex");
    if (hash !== record.codeHash) {
      await incrementarTentativas2FA(uid, (record.attempts ?? 0) + 1);
      throw new HttpsError(
        "invalid-argument",
        "Código incorreto."
      );
    }

    await marcarTwoFaEnabled(uid);
    await deletarCodigo2FA(uid);

    return {ok: true};
  });
