import { onCall, HttpsError } from "firebase-functions/v2/https";
import { AtualizarSaldoInput } from "../types/carteira";
import {
  buscarCarteira,
  atualizarSaldo,
  registrarOperacao,
} from "../repositories/carteiraRepository";
import { Timestamp } from "firebase-admin/firestore";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export const sacar = onCall<AtualizarSaldoInput>(
  async (request) => {
    const { valor } = request.data as AtualizarSaldoInput;

    if (typeof valor !== "number" || valor <= 0) {
      throw new HttpsError("invalid-argument", "Valor inválido.");
    }

    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Usuário não autenticado.");
    }

    const carteira = await buscarCarteira(uid);

    if (!carteira) {
      throw new HttpsError("not-found", "Carteira não encontrada.");
    }

    if (valor > carteira.saldo) {
      throw new HttpsError(
        "invalid-argument",
        "Saldo insuficiente para realizar o saque"
      );
    }

    const novoSaldo = carteira.saldo - valor;

    await atualizarSaldo(uid, novoSaldo);

    await registrarOperacao({
      uid,
      tipo: "saque",
      valor,
      realizadoEm: Timestamp.now(),
    });
    await db.collection("carteiras")
  .doc(uid)
  .update({
    saldo: admin.firestore.FieldValue.increment(-valor)
  });

await db.collection("carteiras")
  .doc(uid)
  .collection("movimentacoes")
  .add({
    tipo: "saque",
    valor: valor,
    data: admin.firestore.FieldValue.serverTimestamp(),
    descricao: "Saque via app"
  });

    return { mensagem: "Saque realizado com sucesso." };
  }
);