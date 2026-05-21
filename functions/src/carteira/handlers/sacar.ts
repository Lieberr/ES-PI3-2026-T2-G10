import {onCall, CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {AtualizarSaldoInput} from "../types/carteira";
import {
  atualizarSaldo, buscarCarteira, registrarOperacao,
} from "../repositories/carteiraRepository";
import {Timestamp} from "firebase-admin/firestore";

export const sacar = onCall(
  async (request: CallableRequest<AtualizarSaldoInput>) => {
    const data = request.data;
    if (data.valor < 0) {
      throw new HttpsError(
        "invalid-argument",
        "O valor inserido é invalido."
      );
    }
    const {valor} = data;
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Usuário não autenticado.");
    }
    const carteira = await buscarCarteira(uid);
    if (!carteira) {
      throw new HttpsError("not-found", "Carteira não encontrada");
    }

    if (valor > carteira.saldo) {
      throw new HttpsError(
        "invalid-argument",
        "Saldo insuficiente para realizar o saque");
    }

    const novoSaldo = carteira.saldo - valor;
    await atualizarSaldo(uid, novoSaldo);

    await registrarOperacao({
      uid,
      tipo: "saque",
      valor,
      realizadoEm: Timestamp.now(),
    });
    return {mensagem: "Saque realizado com sucesso."};
  }
);
