import {onCall, CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {
  atualizarSaldo,
  buscarCarteira,
  registrarOperacao,
} from "../repositories/carteiraRepository";
import {AtualizarSaldoInput} from "../types/carteira";
import {Timestamp} from "firebase-admin/firestore";


export const depositar = onCall(
  async (request: CallableRequest<AtualizarSaldoInput>) => {
    const data = request.data;
    if (data.valor < 0) {
      throw new HttpsError(
        "invalid-argument",
        "O valor inserido é invalido"
      );
    }
    const {valor} = data;
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Usuário não autenticado.");
    }
    const carteira = await buscarCarteira(uid);
    if (!carteira) {
      throw new HttpsError("not-found", "Carteira não encontrada.");
    }
    const novoSaldo = carteira.saldo + valor;

    await atualizarSaldo(uid, novoSaldo);

    await registrarOperacao({
      uid,
      tipo: "deposito",
      valor,
      realizadoEm: Timestamp.now(),
    });
    return {mensagem: "Deposito realizado com sucesso."};
  }
);
