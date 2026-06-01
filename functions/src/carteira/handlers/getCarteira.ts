// Feito por Leonardo Dionel RA: 25010092

// Retorna saldo e tokens do usuário autenticado.

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {buscarCarteira, buscarTokenUsuario}
  from "../repositories/carteiraRepository";

export const getCarteira = onCall(
  async (request:CallableRequest<Record<string, never>>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }

    // Busca carteira e tokens em paralelo para reduzir latência.
    const [carteira, tokens] = await Promise.all([
      buscarCarteira(uid),
      buscarTokenUsuario(uid),
    ]);

    if (!carteira) {
      throw new HttpsError(
        "not-found",
        "Carteira não encontrada."
      );
    }

    return {
      saldo: carteira.saldo,
      saldoReservado: carteira.saldo,
      tokens: tokens ?? [],
    };
  }
);
