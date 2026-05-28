import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {
  buscarCarteira,
  buscarTokenUsuario,
} from "../../carteira/repositories/carteiraRepository";
import {buscarOfertaPorId} from "../repositories/balcaoRepository";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "../../shared/firebase";

export const cancelarOfertaBalcao = onCall(
  async (request:CallableRequest<{ofertaId: string}>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }
    const {ofertaId} = request.data;
    const oferta = await buscarOfertaPorId(ofertaId);
    if (!oferta) {
      throw new HttpsError(
        "not-found",
        "Oferta não encontrada."
      );
    }
    if (oferta.status !== "aberta") {
      throw new HttpsError(
        "failed-precondition",
        "Oferta não esta aberta."
      );
    }
    const token = await buscarTokenUsuario(uid) ?? [];
    const carteira = await buscarCarteira(uid);
    if (!carteira) {
      throw new HttpsError(
        "not-found",
        "Carteira não encontrada."
      );
    }
    const uidDono = oferta.uidComprador ?? oferta.uidVendedor;
    if (uid !== uidDono) {
      throw new HttpsError(
        "permission-denied",
        "Você não tem permissao para cancelar essa oferta."
      );
    }

    if (oferta.tipo === "compra") {
      const novoSaldo = carteira.saldo + oferta.valorTotal;
      const novoSaldoReservado = carteira.saldoReservado - oferta.valorTotal;

      await db.runTransaction(async (transaction) => {
        const carteiraRef = db.collection("carteiras").doc(uid);
        const ofertaRef = db.collection("mercadoSecundario").doc(ofertaId);

        transaction.update(carteiraRef, {
          saldo: novoSaldo,
          saldoReservado: novoSaldoReservado,
        });

        transaction.update(ofertaRef, {
          status: "cancelada",
          resolvidaEm: Timestamp.now(),
        });
      });
      return {mensagem: "Oferta cancelada com sucesso."};
    }

    if (oferta.tipo === "venda") {
      const tokenAtual = token.find((t) => t.startupId === oferta.startupId);
      const quantidadeAtual = tokenAtual?.quantidade?? 0;
      const tokenReservado = tokenAtual?.quantidadeReservada?? 0;
      const novoToken = quantidadeAtual + oferta.quantidade;
      const novoTokenReservado = tokenReservado - oferta.quantidade;

      await db.runTransaction(async (transaction) => {
        const tokenRef = db.collection("carteiras").doc(uid)
          .collection("tokens").doc(oferta.startupId);
        const ofertaRef = db.collection("mercadoSecundario").doc(ofertaId);

        transaction.update(tokenRef, {
          quantidade: novoToken,
          quantidadeReservada: novoTokenReservado,
        });

        transaction.update(ofertaRef, {
          status: "cancelada",
          resolvidaEm: Timestamp.now(),
        });
      });
      return {mensagem: "Oferta cancelada com sucesso."};
    }
    return {mensagem: "Falha ao cancelar oferta."};
  }
);

