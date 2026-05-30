// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {
  buscarCarteira,
  buscarTokenUsuario,
} from "../../carteira/repositories/carteiraRepository";
import {buscarOfertaPorId}
  from "../repositories/balcaoRepository";
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
        "Você não pode aceitar a própria oferta."
      );
    }

    // OFERTA DE COMPRA — quem criou quer comprar, uid é o vendedor
    if (oferta.tipo === "compra") {
      if (!oferta.uidComprador) {
        throw new HttpsError(
          "not-found",
          "Comprador não encontrado."
        );
      }
      const uidComprador = oferta.uidComprador;

      const [carteira, tokens, carteiraComprador, tokensComprador] =
        await Promise.all([
          buscarCarteira(uid),
          buscarTokenUsuario(uid),
          buscarCarteira(uidComprador),
          buscarTokenUsuario(uidComprador),
        ]);

      if (!carteira) {
        throw new HttpsError(
          "not-found",
          "Carteira não encontrada."
        );
      }
      if (!carteiraComprador) {
        throw new HttpsError(
          "not-found",
          "Carteira do comprador não encontrada."
        );
      }

      const tokenVendedor = tokens?.find(
        (t) => t.startupId === oferta.startupId
      );
      const quantidadeVendedor = tokenVendedor?.quantidade ?? 0;

      if (quantidadeVendedor < oferta.quantidade) {
        throw new HttpsError(
          "invalid-argument",
          "Tokens insuficientes."
        );
      }

      const valorInvestidoVendedor = tokenVendedor?.valorInvestido ?? 0;
      const precoMedioVendedor = valorInvestidoVendedor / quantidadeVendedor;
      const valorInvestidoVendido = precoMedioVendedor * oferta.quantidade;

      const tokenComprador = tokensComprador?.find(
        (t) => t.startupId === oferta.startupId
      );

      await db.runTransaction(async (transaction) => {
        const carteiraRef = db.collection("carteiras").doc(uid);
        const carteiraRefComprador = db.collection("carteiras")
          .doc(uidComprador);
        const tokenRef = db.collection("carteiras")
          .doc(uid).collection("tokens").doc(oferta.startupId);
        const tokenRefComprador = db.collection("carteiras")
          .doc(uidComprador).collection("tokens")
          .doc(oferta.startupId);
        const ofertaRef = db.collection("mercadoSecundario").doc(ofertaId);


        transaction.update(carteiraRef, {
          saldo: carteira.saldo + oferta.valorTotal,
        });
        transaction.set(tokenRef, {
          quantidade: quantidadeVendedor - oferta.quantidade,
          valorInvestido: valorInvestidoVendedor - valorInvestidoVendido,
        }, {merge: true});

        transaction.update(carteiraRefComprador, {
          saldoReservado:
            carteiraComprador.saldoReservado - oferta.valorTotal,
        });

        transaction.set(tokenRefComprador, {
          startupId: oferta.startupId,
          quantidade:
            (tokenComprador?.quantidade ?? 0) + oferta.quantidade,
          valorInvestido:
            (tokenComprador?.valorInvestido ?? 0) + oferta.valorTotal,
        }, {merge: true});

        transaction.update(ofertaRef, {
          uidVendedor: uid,
          status: "fechada",
          resolvidaEm: Timestamp.now(),
        });
      });
    }


    // OFERTA DE VENDA — quem criou quer vender, uid é o comprador
    if (oferta.tipo === "venda") {
      if (!oferta.uidVendedor) {
        throw new HttpsError("internal", "Vendedor não identificado.");
      }
      const uidVendedor = oferta.uidVendedor;

      const [carteira, tokens, carteiraVendedor, tokensVendedor] =
        await Promise.all([
          buscarCarteira(uid),
          buscarTokenUsuario(uid),
          buscarCarteira(uidVendedor),
          buscarTokenUsuario(uidVendedor),
        ]);

      if (!carteira) {
        throw new HttpsError("not-found", "Carteira não encontrada.");
      }
      if (!carteiraVendedor) {
        throw new HttpsError(
          "not-found",
          "Carteira do vendedor não encontrada."
        );
      }

      if (carteira.saldo < oferta.valorTotal) {
        throw new HttpsError("invalid-argument", "Saldo insuficiente.");
      }

      const tokenComprador = tokens?.find(
        (t) => t.startupId === oferta.startupId
      );

      const tokenVendedor = tokensVendedor?.find(
        (t) => t.startupId === oferta.startupId
      );
      const totalTokensVendedor =
        (tokenVendedor?.quantidade ?? 0) +
        (tokenVendedor?.quantidadeReservada ?? 0);
      const valorInvestidoVendedor = tokenVendedor?.valorInvestido ?? 0;
      const precoMedioVendedor = totalTokensVendedor > 0 ?
        valorInvestidoVendedor / totalTokensVendedor :
        0;
      const valorInvestidoVendido = precoMedioVendedor * oferta.quantidade;

      await db.runTransaction(async (transaction) => {
        const carteiraRef = db.collection("carteiras").doc(uid);
        const carteiraRefVendedor = db.collection("carteiras")
          .doc(uidVendedor);
        const tokenRef = db.collection("carteiras")
          .doc(uid).collection("tokens").doc(oferta.startupId);
        const tokenRefVendedor = db.collection("carteiras")
          .doc(uidVendedor).collection("tokens")
          .doc(oferta.startupId);
        const ofertaRef = db.collection("mercadoSecundario").doc(ofertaId);

        transaction.update(carteiraRef, {
          saldo: carteira.saldo - oferta.valorTotal,
        });

        transaction.set(tokenRef, {
          startupId: oferta.startupId,
          quantidade:
            (tokenComprador?.quantidade ?? 0) + oferta.quantidade,
          valorInvestido:
            (tokenComprador?.valorInvestido ?? 0) + oferta.valorTotal,
        }, {merge: true});

        transaction.update(carteiraRefVendedor, {
          saldo: carteiraVendedor.saldo + oferta.valorTotal,
        });

        transaction.set(tokenRefVendedor, {
          quantidadeReservada:
            (tokenVendedor?.quantidadeReservada ?? 0) - oferta.quantidade,
          valorInvestido: valorInvestidoVendedor - valorInvestidoVendido,
        }, {merge: true});

        transaction.update(ofertaRef, {
          uidComprador: uid,
          status: "fechada",
          resolvidaEm: Timestamp.now(),
        });
      });
    }

    return {mensagem: "Oferta concluída com sucesso."};
  }
);
