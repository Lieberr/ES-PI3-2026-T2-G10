// Feito por Leonardo Dionel RA: 25010092
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {Timestamp} from "firebase-admin/firestore";

if (!admin.apps.length) {
  admin.initializeApp();
}

export const depositar = onCall(async (request) => {
  const {valor} = request.data;

  if (typeof valor !== "number" || valor <= 0) {
    throw new HttpsError("invalid-argument", "Valor inválido.");
  }

  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado.");
  }

  const carteiraRef = admin.firestore().collection("carteiras").doc(uid);

  // 1. Atualiza saldo corretamente (atômico)
  await carteiraRef.update({
    saldo: admin.firestore.FieldValue.increment(valor),
  });

  // 2. Registra histórico (IMPORTANTE pro Flutter)
  await carteiraRef.collection("movimentacoes").add({
    tipo: "deposito",
    valor: valor,
    realizadoEm: Timestamp.now(),
    descricao: "Depósito via app",
  });

  return {mensagem: "Depósito realizado com sucesso."};
});
