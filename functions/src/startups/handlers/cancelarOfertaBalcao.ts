import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {
  buscarCarteira,
  buscarTokenUsuario,
} from "../../carteira/repositories/carteiraRepository";
import {buscarOfertaPorId} from "../repositories/balcaoRepository";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "../../shared/firebase";

export const cancelarOferta = onCall(
    async (request:CallableRequest<{ofertaId: string}>) => {
        const uid = request.auth?.uid
        if(!uid) {
            throw new HttpsError(
                "unauthenticated", 
                "Usuário não autenticado."
            );
        }
        const {ofertaId} = request.data;
        const oferta = await buscarOfertaPorId(ofertaId);
        if(!oferta) {
            throw new HttpsError(
                "not-found", 
                "Oferta não encontrada."
            );
        }
        if(oferta.status !== "aberta"){
            throw new HttpsError(
                "failed-precondition", 
                "Oferta não esta aberta."
            );
        }
        const token = await buscarTokenUsuario(uid) ?? [];
        const carteira = await buscarCarteira(uid);
        if(!carteira) {
            throw new HttpsError(
                "not-found",
                "Carteira não encontrada."
            );
        }
        if(oferta.tipo === "compra") {
            
        }
    }
)

