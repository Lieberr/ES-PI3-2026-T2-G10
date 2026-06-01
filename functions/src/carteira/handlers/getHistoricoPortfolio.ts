// Feito Por Gustavo Lieb Figueira RA: 24023376

import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {buscarTokenUsuario} from "../repositories/carteiraRepository";
import {db} from "../../shared/firebase";

export const getHistoricoPortfolio = onCall(
  async (request: CallableRequest<Record<string, never>>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Usuário não autenticado.");
    }

    const tokens = await buscarTokenUsuario(uid) ?? [];
    if (tokens.length === 0) {
      return {pontos: []};
    }

    // Busca histórico de preços de cada startup que o usuário tem tokens
    const pontos: {label: string; valorTotal: number}[] = [];

    for (const token of tokens) {
      const snap = await db
        .collection("startups")
        .doc(token.startupId)
        .collection("historicoPrecos")
        .orderBy("data", "asc")
        .get();

      snap.docs.forEach((doc) => {
        const data = doc.data();
        const date = data.data.toDate();
        const label = `${date.getDate()}/${date.getMonth() +
           1}/${date.getFullYear()} 
           ${String(date.getHours()).padStart(2, "0")}:
           ${String(date.getMinutes()).padStart(2, "0")}`;
        const valorToken = data.valorToken ?? 0;
        const valorTotal = valorToken * token.quantidade;

        // verifica se já tem um ponto com esse label
        const existente = pontos.find((p) => p.label === label);
        if (existente) {
          existente.valorTotal += valorTotal;
        } else {
          pontos.push({label, valorTotal});
        }
      });
    }

    // ordena por data
    pontos.sort((a, b) => {
      const [dA, mA, yA] = a.label.split("/").map(Number);
      const [dB, mB, yB] = b.label.split("/").map(Number);
      return new Date(yA, mA - 1, dA).getTime() - new Date(yB, mB - 1, dB)
        .getTime();
    });

    return {pontos};
  }
);
