// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {
  buscarCarteira,
  buscarTokenUsuario,
} from "../../carteira/repositories/carteiraRepository";
import {buscarOfertaPorId} from "../repositories/balcaoRepository";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "../../shared/firebase";
import { buscarStartupsPorId } from "../repositories/startupRepository";
import { TransacaoSecundaria } from "../../carteira/types/transacao";

export const getOfertasAbertas = onCall(
    async(request:CallableRequest<{startupId: string}>) => {
        const uid = request.auth?.uid;
        if(!uid) {
            throw new HttpsError(
                "not-found", 
                "Usuário não encontrado.",
            );
        }

        const { startupId } = request.data;
        if(!startupId) {
            throw new HttpsError(
                "not-found", 
                "StartupId é obrigatorio",
            );
        }
        const startup = buscarStartupsPorId(startupId);
        if(!startup) {
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

        const ofertas = snap.docs
        .map((doc) => ({
            id: doc.id,
            ...doc.data() as unknown as TransacaoSecundaria})) 
        .filter((oferta) => oferta.uidComprador !== uid && oferta.uidVendedor !== uid);

        return {ofertas};
    }
)