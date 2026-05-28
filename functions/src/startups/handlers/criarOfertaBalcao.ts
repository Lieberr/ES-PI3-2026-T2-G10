// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {
  buscarCarteira,
  buscarTokenUsuario,
} from "../../carteira/repositories/carteiraRepository";
import {buscarStartupsPorId}
  from "../repositories/startupRepository";
import {TransacaoSecundaria}
  from "../../carteira/types/transacao";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "../../shared/firebase";

export const criarOfertaBalcao = onCall(
  async (request:CallableRequest<{
        startupId: string;
        quantidade: number;
        tipo: "compra" | "venda"}>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }
    const data = request.data;
    const {startupId, quantidade, tipo} = data;
    if (quantidade <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "Quantidade invalida"
      );
    }
    const startup = await buscarStartupsPorId(startupId);
    if (!startup) {
      throw new HttpsError(
        "not-found",
        "Startup não encontrada."
      );
    }
    const carteira = await buscarCarteira(uid);
    if (!carteira) {
      throw new HttpsError(
        "not-found",
        "Carteira não encontrada."
      );
    }
    const tokens = await buscarTokenUsuario(uid) ?? [];
    const valorUnitario = startup.valorToken;
    const valorTotal = valorUnitario * quantidade;
    if (tipo === "compra") {
      if (valorTotal > carteira.saldo) {
        throw new HttpsError(
          "invalid-argument",
          "Saldo insuficiente."
        );
      }
      const oferta: TransacaoSecundaria = {
        uidComprador: uid,
        uidVendedor: undefined,
        startupId,
        quantidade,
        valorUnitario,
        valorTotal,
        tipo: "compra",
        status: "aberta",
        criadaEm: Timestamp.now(),
        resolvidaEm: null,
      };
      await db.runTransaction(async (transaction) => {
        const carteiraRef = db.collection("carteiras").doc(uid);
        const ofertaRef = db.collection("mercadoSecundario").doc();
        transaction.set(ofertaRef, oferta);
        transaction.update(carteiraRef, {
          saldo: carteira.saldo - valorTotal,
          saldoReservado: carteira.saldoReservado + valorTotal,
        });
      });
      return {mensagem: "Oferta de compra realizada com sucesso."};
    }
    if (tipo === "venda") {
      const tokenAtual = tokens.find((t) =>
        t.startupId === data.startupId
      );
      const quantidadeAtual = tokenAtual?.quantidade ?? 0;

      if (quantidadeAtual < quantidade) {
        throw new HttpsError(
          "invalid-argument",
          "Tokens insuficiente"
        );
      }
      const novaQuantidade = quantidadeAtual - quantidade;
      const oferta: TransacaoSecundaria = {
        uidComprador: undefined,
        uidVendedor: uid,
        startupId,
        quantidade,
        valorUnitario,
        valorTotal,
        tipo: "venda",
        status: "aberta",
        criadaEm: Timestamp.now(),
        resolvidaEm: null,
      };
      await db.runTransaction(async (transaction) => {
        const tokenRef = db.collection("carteiras")
          .doc(uid).collection("tokens").doc(startupId);
        const ofertaRef = db.collection("mercadoSecundario").doc();
        transaction.set(ofertaRef, oferta);
        transaction.update(tokenRef, {
          quantidade: novaQuantidade,
          quantidadeReservada:
                    (tokenAtual?.quantidadeReservada ?? 0) + quantidade,
        });
      });
      return {mensagem: "Oferta de venda realizada com sucesso."};
    }
    return {mensagem: "Erro ao criar oferta."};
  }
);
