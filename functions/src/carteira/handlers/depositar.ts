// Feito por Leonardo Dionel RA: 25010092

import {onCall, CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {AtualizarSaldoInput} from "../types/carteira";
import {
  atualizarSaldo, buscarCarteira, registrarOperacao,
} from "../repositories/carteiraRepository";
import {Timestamp} from "firebase-admin/firestore";

export const depositar = onCall(
  async (request:CallableRequest<AtualizarSaldoInput>) => {
    const data = request.data;
    if (data.valor < 0) {
      throw new HttpsError(
        "invalid-argument",
        "o valor inserido é invalido."
      );
    }

    const {valor} = data;
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }

    const carteira = await buscarCarteira(uid);
    if (!carteira) {
      throw new HttpsError(
        "not-found",
        "Carteira não encontrada."
      );
    }

    const novoSaldo = carteira.saldo + valor;
    await atualizarSaldo(uid, novoSaldo);

    await registrarOperacao({
      uid,
      valor,
      tipo: "deposito",
      realizadoEm: Timestamp.now(),
    });
    return {mensagem: "Depósito realizado com sucesso."};
  }
);
