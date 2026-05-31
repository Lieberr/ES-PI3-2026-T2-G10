// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {buscarTokenUsuario}
  from "../../carteira/repositories/carteiraRepository";
import {buscarStartupPorEstagio, buscarStartups, buscarStartupsPorId}
  from "../repositories/startupRepository";
import {db} from "../../shared/firebase";
import { Timestamp } from "firebase-admin/firestore";

async function calcularVariacaoMensal(
  startupId: string,
  valorAtual: number,
): Promise<number> {
  const umMesAtras = new Date();
  umMesAtras.setDate(umMesAtras.getDate() - 30);

  const snap = await db
    .collection("startups")
    .doc(startupId)
    .collection("historicoPrecos")
    .where("data", ">=", Timestamp.fromDate(umMesAtras))
    .orderBy("data", "asc")
    .limit(1)
    .get();

  if(snap.empty) return 0;

  const precoInicio = snap.docs[0].data().valorToken as number;
  if(precoInicio === 0) return 0;

  return ((valorAtual - precoInicio) / precoInicio  ) * 100;
}

export const getStartups = onCall(
  async (request: CallableRequest<void>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado.");
    }

    const startups = await buscarStartups();
    return {startups};
  }
);

export const getStartupById = onCall(
  async (request: CallableRequest<{id: string}>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado.");
    }
    const data = request.data;
    const {id} = data;
    if (!id) {
      throw new HttpsError(
        "invalid-argument",
        "ID da startup é obrigatório."
      );
    }
    const [startup, tokens] = await Promise.all([
      buscarStartupsPorId(id),
      buscarTokenUsuario(uid),
    ]);

    if (!startup) {
      throw new HttpsError("not-found", "Startup não encontrada.");
    }
    const tokenDaStartup = tokens?.find((t) => t.startupId === id);
    const isInvestor = (tokenDaStartup?.quantidade ?? 0) > 0;
    return {
      startup,
      isInvestor,
      canTradeTokens: true,
      canAccessBalcao: isInvestor,
      canSendPrivateQuestion: isInvestor,
    };
  }
);

export const getStartupPorEstagio = onCall(
  async (request: CallableRequest<{estagio: string}>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado.");
    }
    const data = request.data;
    const {estagio} = data;
    const startups = await buscarStartupPorEstagio(estagio);
    return {startups};
  }
);
