// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {TransacaoSecundaria}
  from "../../carteira/types/transacao";
import {db} from "../../shared/firebase";

export const getMinhasOfertas = onCall(
  async (request: CallableRequest<Record<string, never>>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }

    // Firestore não suporta OR entre campos diferentes —
    // fazemos duas queries e unimos os resultados
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

    return {ofertas: todasOfertas};
  }
);