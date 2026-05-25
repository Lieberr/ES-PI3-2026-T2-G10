// Feito por Leonardo Dionel RA: 25010092

import {
  CallableRequest, HttpsError, onCall,
} from "firebase-functions/v2/https";
import {
  buscarCarteira, buscarTokenUsuario,
} from "../repositories/carteiraRepository";
import {
  buscarStartupsPorId,
} from "../../startups/repositories/startupRepository";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "../../shared/firebase";

export const comprarTokenPrimario = onCall(
  async (request:CallableRequest<{startupId: string; quantidade: number}>) => {
    const data = request.data;
    if (data.quantidade <= 0) {
      throw new HttpsError("invalid-argument", "Quantidade invalida");
    }
    const {quantidade} = data;
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Usuário não autenticado.");
    }
    const carteira = await buscarCarteira(uid);
    if (!carteira) {
      throw new HttpsError("not-found", "Carteira não encontrada");
    }
    const tokens = await buscarTokenUsuario(uid) ?? [];
    const startup = await buscarStartupsPorId(data.startupId);
    if (!startup) {
      throw new HttpsError("not-found", "Startup não encontrada.");
    }

    const valorUnitario = startup.valorToken;
    const valorTotal = quantidade * valorUnitario;
    if (valorTotal > carteira.saldo) {
      throw new HttpsError("invalid-argument", "Saldo insuficiente");
    }

    if (quantidade > startup.tokensDisponiveis) {
      throw new HttpsError(
        "invalid-argument",
        "Tokens insuficientes na startup.");
    }
    const tokenAtual = tokens?.find((t) => t.startupId === data.startupId);
    const quantidadeAtual = tokenAtual?.quantidade ?? 0;
    const novaQuantidade = quantidadeAtual + quantidade;
    await db.runTransaction(async (transaction) => {
      const carteiraRef = db.collection("carteiras").doc(uid);
      const tokenRef = db.collection("carteiras")
        .doc(uid).collection("tokens").doc(startup.id);
      const startupRef = db.collection("startups").doc(startup.id);
      const transacaoRef = db.collection("mercadoPrimario").doc();

      transaction.update(carteiraRef, {saldo: carteira.saldo - valorTotal});
      transaction.set(tokenRef, {quantidade: novaQuantidade}, {merge: true});
      transaction.update(startupRef,
        {tokensDisponiveis: startup.tokensDisponiveis - quantidade});
      transaction.set(transacaoRef, {
        uid,
        startupId: startup.id,
        quantidade,
        valorUnitario,
        valorTotal,
        tipo: "compra",
        data: Timestamp.now(),
      });
    });

    return {mensagem: "Compra realizada com sucesso."};
  });
