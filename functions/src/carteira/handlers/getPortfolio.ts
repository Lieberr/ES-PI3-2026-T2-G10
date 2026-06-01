// Feito por Leonardo Dionel RA: 25010092

// Calcula resumo do portfólio: valor investido, valor atual e variação por startup.

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

      const totalTokens =
        token.quantidade + (token.quantidadeReservada ?? 0);
      const precoMedio = totalTokens > 0
        ? token.valorInvestido / totalTokens
        : 0;

      const valorAtual = startup.valorToken * totalTokens;


      // Compara o valor atual com o que custaria comprar esses tokens pelo preço médio
      const valorInvestidoAtual = precoMedio * token.quantidade;
      const variacao = precoMedio > 0
        ? ((startup.valorToken - precoMedio) / precoMedio) * 100
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
      (acc, item) => acc + (item?.valorInvestido ?? 0), 0
    );
    const totalAtual = itens.reduce(
      (acc, item) => acc + (item?.valorAtual ?? 0), 0
    );
    const variacaoGeral = totalInvestido > 0 ?
      ((totalAtual - totalInvestido) / totalInvestido) * 100 :
      0;

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
