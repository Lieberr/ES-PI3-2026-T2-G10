// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {buscarTokenUsuario}
  from "../../carteira/repositories/carteiraRepository";
import {buscarStartupPorEstagio, buscarStartups, buscarStartupsPorId}
  from "../repositories/startupRepository";

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
      canTradeTokens: isInvestor,
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
