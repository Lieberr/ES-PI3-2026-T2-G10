// Feito por Leonardo Dionel RA: 25010092

// Compra tokens diretamente da startup no mercado primário.

// Imports

import {
  CallableRequest, HttpsError, onCall,
} from "firebase-functions/v2/https";
import {
  buscarCarteira, buscarTokenUsuario,
} from "../repositories/carteiraRepository";
import {
  buscarStartupsPorId,
} from "../../startups/repositories/startupRepository";
import {Timestamp} from "firebase-admin/firestore";
import {db} from "../../shared/firebase";

// Compra de Tokens - Mercado Primário

export const comprarTokenPrimario = onCall(
  async (request: CallableRequest<{
    startupId: string;
    quantidade: number
  }>) => {

    // Validação dos dados recebidos

    const data = request.data;

    if (data.quantidade <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "Quantidade invalida"
      );
    }

    const {quantidade} = data;

    // Validação de autenticação

    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }

    // Busca dos dados necessários

    const carteira = await buscarCarteira(uid);

    if (!carteira) {
      throw new HttpsError(
        "not-found",
        "Carteira não encontrada"
      );
    }

    const tokens = await buscarTokenUsuario(uid) ?? [];
    const startup = await buscarStartupsPorId(data.startupId);

    if (!startup) {
      throw new HttpsError(
        "not-found",
        "Startup não encontrada."
      );
    }

    // Cálculo dos valores da compra

    const valorUnitario = startup.valorToken;
    const valorTotal = quantidade * valorUnitario;

    // Validação de saldo da carteira

    if (valorTotal > carteira.saldo) {
      throw new HttpsError(
        "invalid-argument",
        "Saldo insuficiente"
      );
    }

    // Validação de disponibilidade de tokens

    if (quantidade > startup.tokensDisponiveis) {
      throw new HttpsError(
        "invalid-argument",
        "Tokens insuficientes na startup."
      );
    }

    // Atualização da posição do investidor

    const tokenAtual = tokens?.find(
      (t) => t.startupId === data.startupId
    );

    const quantidadeAtual = tokenAtual?.quantidade ?? 0;
    const novaQuantidade = quantidadeAtual + quantidade;

    const valorInvestido = tokenAtual?.valorInvestido ?? 0;
    const novoValorInvestido = valorInvestido + valorTotal;

    // Transação atômica
    // Atualiza carteira, tokens, startup e histórico

    await db.runTransaction(async (transaction) => {
      const carteiraRef = db.collection("carteiras").doc(uid);

      const tokenRef = db.collection("carteiras")
        .doc(uid)
        .collection("tokens")
        .doc(startup.id);

      const startupRef = db.collection("startups").doc(startup.id);

      const transacaoRef = db.collection("mercadoPrimario").doc();

      // Atualiza saldo da carteira
      transaction.update(carteiraRef, {
        saldo: carteira.saldo - valorTotal,
      });

      // Atualiza posição de tokens do usuário
      transaction.set(tokenRef, {
        startupId: startup.id,
        quantidade: novaQuantidade,
        valorInvestido: novoValorInvestido,
      }, {merge: true});

      // Atualiza quantidade disponível da startup
      transaction.update(startupRef, {
        tokensDisponiveis: startup.tokensDisponiveis - quantidade,
      });

      // Registra movimentação do mercado primário
      transaction.set(transacaoRef, {
        uid,
        startupId: startup.id,
        quantidade,
        valorUnitario,
        valorTotal,
        tipo: "compra",
        data: Timestamp.now(),
      });
    });

    // Retorno de sucesso

    return {
      mensagem: "Compra realizada com sucesso.",
    };
  }
);