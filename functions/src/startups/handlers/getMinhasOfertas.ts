// Feito por Leonardo Dionel RA: 25010092

// Lista ofertas do mercado secundário criadas ou aceitas pelo usuário autenticado.

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {TransacaoSecundaria}
  from "../../carteira/types/transacao";
import {db} from "../../shared/firebase";
import {buscarUsuarioPorUid}
  from "../../usuarios/repositories/usuarioRepository";

export const getMinhasOfertas = onCall(
  async (request: CallableRequest<Record<string, never>>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }

    // Busca ofertas onde o usuário é comprador ou vendedor.
    const [comoComprador, comoVendedor] = await Promise.all([
      db.collection("mercadoSecundario")
        .where("uidComprador", "==", uid)
        .orderBy("criadaEm", "desc")
        .get(),
      db.collection("mercadoSecundario")
        .where("uidVendedor", "==", uid)
        .orderBy("criadaEm", "desc")
        .get(),
    ]);

    const todasOfertas = [
      ...comoComprador.docs,
      ...comoVendedor.docs,
    ]
      .map((doc) => ({
        id: doc.id,
        ...doc.data() as TransacaoSecundaria,
      }))
      .sort((a, b) => b.criadaEm.toMillis() - a.criadaEm.toMillis());

    const ofertasComNomes = await Promise.all(
      todasOfertas.map(async (oferta) => {
        // Enriquece oferta com nome completo de comprador e vendedor.
        const [comprador, vendedor] = await Promise.all([
          oferta.uidComprador ?
            buscarUsuarioPorUid(oferta.uidComprador) :
            null,
          oferta.uidVendedor ?
            buscarUsuarioPorUid(oferta.uidVendedor) :
            null,
        ]);

        console.log("oferta:", JSON.stringify({
          id: oferta.id,
          uidComprador: oferta.uidComprador,
          uidVendedor: oferta.uidVendedor,
          nomeComprador: comprador?.nomeCompleto,
          nomeVendedor: vendedor?.nomeCompleto,
        }));

        return {
          ...oferta,
          nomeComprador: comprador?.nomeCompleto ?? null,
          nomeVendedor: vendedor?.nomeCompleto ?? null,
        };
      })
    );

    return {ofertas: ofertasComNomes};
  }
);
