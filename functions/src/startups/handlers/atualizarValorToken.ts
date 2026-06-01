// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "../../shared/firebase";

export const atualizarValorToken = onCall(
  async (request: CallableRequest<{
    startupId: string;
    novoValor: number;
  }>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }

    const {startupId, novoValor} = request.data;

    if (!startupId || novoValor <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "startupId e novoValor são obrigatórios."
      );
    }

    const startupRef = db.collection("startups").doc(startupId);
    const historicoRef = startupRef.collection("historicoPrecos").doc();

    await db.runTransaction(async (transaction) => {
      // Atualiza o valorToken da startup
      transaction.update(startupRef, {valorToken: novoValor});

      // Registra o novo ponto no histórico
      transaction.set(historicoRef, {
        valorToken: novoValor,
        data: Timestamp.now(),
      });
    });

    return {mensagem: "Valor do token atualizado com sucesso."};
  }
);