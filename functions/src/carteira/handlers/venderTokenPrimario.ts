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


export const venderTokenPrimario = onCall(
  async (request:CallableRequest<{
        startupId: string; quantidade: number
    }>) => {
    const data = request.data;
    if (data.quantidade <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "Quantidade invalida.");
    }
    const {quantidade} = data;
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado.");
    }
    const carteira = await buscarCarteira(uid);
    if (!carteira) {
      throw new HttpsError(
        "not-found",
        "Carteira não encontrada.");
    }
    const tokens = await buscarTokenUsuario(uid);
    if (!tokens) {
      throw new HttpsError(
        "invalid-argument",
        "Não foi encontrado tokens");
    }
    const startup = await buscarStartupsPorId(data.startupId);
    if (!startup) {
      throw new HttpsError(
        "not-found",
        "Startup não encontrada.");
    }
    const valorUnitario = startup.valorToken;
    const valorTotal = valorUnitario * quantidade;
    const tokenAtual = tokens.find((t) => t.startupId === data.startupId);
    const quantidadeAtual = tokenAtual?.quantidade ?? 0;
    if (quantidadeAtual < quantidade) {
      throw new HttpsError("invalid-argument", "Tokens insuficiente");
    }
    const novaQuantidade = quantidadeAtual - quantidade;
    await db.runTransaction(async (transaction) => {
      const carteiraRef = db.collection("carteiras").doc(uid);
      const tokenRef = db.collection("carteiras")
        .doc(uid).collection("tokens").doc(startup.id);
      const startupRef = db.collection("startups").doc(startup.id);
      const transacaoRef = db.collection("mercadoPrimario").doc();

      transaction.update(
        carteiraRef,
        {saldo: carteira.saldo + valorTotal});
      transaction.set(
        tokenRef,
        {quantidade: novaQuantidade}, {merge: true});
      transaction.update(
        startupRef,
        {tokensDisponiveis: startup.tokensDisponiveis + quantidade});
      transaction.set(
        transacaoRef,
        {uid,
          startupId: startup.id,
          quantidade,
          valorUnitario,
          valorTotal,
          tipo: "venda",
          data: Timestamp.now(),
        });
    });
    return {mensagem: "Venda realizada com sucesso."};
  }
);
