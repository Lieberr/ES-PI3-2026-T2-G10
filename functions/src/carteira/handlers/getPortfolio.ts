// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {buscarTokenUsuario}
  from "../repositories/carteiraRepository";
import {buscarStartupsPorId}
  from "../../startups/repositories/startupRepository";

export const getPortfolio = onCall(
  async (request: CallableRequest<Record<string, never>>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }

    const tokens = await buscarTokenUsuario(uid) ?? [];

    if (tokens.length === 0) {
      return {
        resumo: {
          totalInvestido: 0,
          totalAtual: 0,
          variacaoGeral: 0,
        },
        itens: [],
      };
    }

    // Busca todas as startups em paralelo
    const startups = await Promise.all(
      tokens.map((token) => buscarStartupsPorId(token.startupId))
    );

    // Monta cada item do portfólio cruzando token com startup
    const itens = tokens.map((token, index) => {
      const startup = startups[index];
      if (!startup) return null;

      const precoMedio = token.quantidade > 0
        ? token.valorInvestido / token.quantidade
        : 0;

      const valorAtual = startup.valorToken * token.quantidade;

      const variacao = token.valorInvestido > 0
        ? ((valorAtual - token.valorInvestido) /
            token.valorInvestido) * 100
        : 0;

      return {
        startupId: token.startupId,
        nomeStartup: startup.nome,
        quantidade: token.quantidade,
        quantidadeReservada: token.quantidadeReservada ?? 0,
        valorInvestido: token.valorInvestido,
        precoMedio,
        precoAtual: startup.valorToken,
        valorAtual,
        variacao,
      };
    }).filter((item) => item !== null);

    // Resumo geral somando todos os itens
    const totalInvestido = itens.reduce(
      (acc, item) => acc + item!.valorInvestido, 0
    );
    const totalAtual = itens.reduce(
      (acc, item) => acc + item!.valorAtual, 0
    );
    const variacaoGeral = totalInvestido > 0
      ? ((totalAtual - totalInvestido) / totalInvestido) * 100
      : 0;

    return {
      resumo: {
        totalInvestido,
        totalAtual,
        variacaoGeral,
      },
      itens,
    };
  }
);