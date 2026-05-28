// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {
  buscarCarteira,
  buscarTokenUsuario,
} from "../../carteira/repositories/carteiraRepository";
import {buscarOfertaPorId} from "../repositories/balcaoRepository";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "../../shared/firebase";

export const aceitarOferta = onCall(
  async (request: CallableRequest<{ofertaId: string}>) => {
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
        "Oferta não está mais aberta."
      );
    }
    if (oferta.uidComprador === uid || oferta.uidVendedor === uid) {
      throw new HttpsError(
        "permission-denied",
        "Você não pode aceitar a propria oferta."
      );
    }

    const tokens = await buscarTokenUsuario(uid) ?? [];
    const carteira = await buscarCarteira(uid);
    if (!carteira) {
      throw new HttpsError(
        "not-found", 
        "Carteira não encontrada."
      );
    }

    if (oferta.tipo === "compra") {
      oferta.uidVendedor = uid;
      if (!oferta.uidComprador) {
        throw new HttpsError(
          "internal", 
          "Comprador não identificado."
        );
      }

      const tokenAtual = tokens.find((t) => t.startupId === oferta.startupId);
      const quantidadeAtual = tokenAtual?.quantidade ?? 0;

      if (quantidadeAtual < oferta.quantidade) {
        throw new HttpsError(
          "invalid-argument", 
          "Tokens insuficientes."
        );
      }

      const novaQuantidade = quantidadeAtual - oferta.quantidade;
      const novoSaldo = carteira.saldo + oferta.valorTotal;

      const carteiraComprador = await buscarCarteira(
        oferta.uidComprador);

      const tokensComprador = await buscarTokenUsuario(
        oferta.uidComprador) ?? [];
      const tokenAtualComprador = tokensComprador.find(
        (t) => t.startupId === oferta.startupId
      );

      await db.runTransaction(async (transaction) => {
        if (!oferta.uidComprador) {
          throw new HttpsError(
            "internal",
            "Comprador não identificado."
          );
        }
        const carteiraRef = db.collection("carteiras").doc(uid);
        const carteiraRefComprador = db.collection("carteiras")
          .doc(oferta.uidComprador);

        if (!carteiraComprador) {
          throw new HttpsError(
            "not-found",
            "Carteira do comprador não encontrada.",
          );
        }
        const tokenRef = db.collection("carteiras")
          .doc(uid).collection("tokens").doc(oferta.startupId);
        const tokenRefComprador = db.collection("carteiras")
          .doc(oferta.uidComprador).collection("tokens").doc(oferta.startupId);
        const ofertaRef = db.collection("mercadoSecundario").doc(ofertaId);

        transaction.update(carteiraRef, {saldo: novoSaldo});

        transaction.update(carteiraRefComprador, {
          saldoReservado: carteiraComprador.saldoReservado - oferta.valorTotal,
        });

        transaction.set(tokenRef, {quantidade: novaQuantidade}, {merge: true});

        transaction.set(tokenRefComprador, {
          quantidade:
          (tokenAtualComprador?.quantidade ?? 0) + oferta.quantidade,
        }, {merge: true});

        transaction.update(ofertaRef, {
          uidVendedor: uid,
          status: "fechada",
          resolvidaEm: Timestamp.now(),
        });
      });
    }

    if (oferta.tipo === "venda") {
      oferta.uidComprador = uid;
      if (!oferta.uidVendedor) {
        throw new HttpsError(
          "unauthenticated",
          "Usuário não autenticado."
        );
      }
      const tokenAtual = tokens.find((t) => t.startupId === oferta.startupId);
      const quantidadeAtual = tokenAtual?.quantidade ?? 0;

      if (carteira.saldo < oferta.valorTotal) {
        throw new HttpsError(
          "invalid-argument", 
          "Saldo insuficiente."
        );
      }

      const novaQuantidade = quantidadeAtual + oferta.quantidade;
      const novoSaldo = carteira.saldo - oferta.valorTotal;

      const carteiraVendedor = await buscarCarteira(oferta.uidVendedor);
      if (!carteiraVendedor) {
        throw new HttpsError(
          "not-found",
          "Carteira do vendedor não encontrada."
        );
      }
      const tokensVendedor = await buscarTokenUsuario(
        oferta.uidVendedor) ?? [];
      const tokenAtualVendedor = tokensVendedor.find(
        (t) => t.startupId === oferta.startupId
      );

      await db.runTransaction(async (transaction) => {
        if (oferta.tipo === "venda") {
          oferta.uidComprador = uid;
          if (!oferta.uidVendedor) {
            throw new HttpsError(
              "unauthenticated",
              "Usuário não autenticado."
            );
          }
          const carteiraRef = db.collection("carteiras").doc(uid);
          const carteiraRefVendedor = db.collection("carteiras")
            .doc(oferta.uidVendedor);
          const tokenRef = db.collection("carteiras")
            .doc(uid).collection("tokens").doc(oferta.startupId);
          const tokenRefVendedor = db.collection("carteiras")
            .doc(oferta.uidVendedor).collection("tokens").doc(oferta.startupId);
          const ofertaRef = db.collection("mercadoSecundario").doc(ofertaId);

          transaction.update(carteiraRef, {
            saldo: novoSaldo,
          });

          transaction.update(carteiraRefVendedor, {
            saldo: carteiraVendedor.saldo + oferta.valorTotal,
          });

          transaction.set(tokenRef, {
            quantidade: novaQuantidade,
          }, {merge: true});

          transaction.set(tokenRefVendedor, {
            quantidadeReservada:
            (tokenAtualVendedor?.quantidadeReservada ?? 0) - oferta.quantidade,
          }, {merge: true});

          transaction.update(ofertaRef, {
            uidComprador: uid,
            status: "fechada",
            resolvidaEm: Timestamp.now(),
          });
        }
      });
    }

    return {mensagem: "Oferta concluida com sucesso."};
  }
);
