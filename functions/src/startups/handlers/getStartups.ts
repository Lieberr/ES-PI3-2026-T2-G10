// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
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
    const startup = await buscarStartupsPorId(id);
    if (!startup) {
      throw new HttpsError("not-found", "Startup não encontrada.");
    }
    return {startup};
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
