// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {db} from "../../shared/firebase";
import {buscarStartupsPorId} from "../repositories/startupRepository";
import {TransacaoSecundaria} from "../../carteira/types/transacao";
import {buscarUsuarioPorUid}
  from "../../usuarios/repositories/usuarioRepository";

export const getOfertasAbertas = onCall(
  async (request:CallableRequest<{startupId: string}>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado.",
      );
    }

    const {startupId} = request.data;
    if (!startupId) {
      throw new HttpsError(
        "not-found",
        "StartupId é obrigatorio",
      );
    }
    const startup = await buscarStartupsPorId(startupId);
    if (!startup) {
      throw new HttpsError(
        "not-found",
        "Startup não encontrada.",
      );
    }

    const snap = await db.collection("mercadoSecundario")
      .where("startupId", "==", startupId)
      .where("status", "==", "aberta")
      .orderBy("criadaEm", "desc")
      .get();

    const ofertasFiltradas = snap.docs
      .map((doc) => ({id: doc.id, ...doc.data() as TransacaoSecundaria}))
      .filter((o) => o.uidComprador !== uid && o.uidVendedor !== uid);

    const ofertaComNome = await Promise.all(
      ofertasFiltradas.map(async (oferta) => {
        const uidCriador = oferta.uidComprador ?? oferta.uidVendedor;
        const usuario = uidCriador ?
          await buscarUsuarioPorUid(uidCriador) :
          null;
        return {
          ...oferta,
          nomeCriador: usuario?.nomeCompleto ?? "Usuário desconhecido",
        };
      })
    );

    return {ofertas: ofertaComNome};
  }
);
