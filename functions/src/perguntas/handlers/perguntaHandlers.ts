// Feito por: Matheus Henrique Portugal Narducci RA: 25008976

import {onCall, CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {Timestamp} from "firebase-admin/firestore";
import {CriarPerguntaInput} from "../types/pergunta";
import {
  criarPerguntaRepo,
  buscarPerguntasPublicas,
  buscarPerguntasPrivadas,
  usuarioEhInvestidor,
} from "../repositories/perguntaRepository";
import {db} from "../../shared/firebase";

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────

/**
 * Busca o nome do usuário no Firestore.
 * @param {string} uid
 * @return {Promise<string>}
 */
async function buscarNomeUsuario(uid: string): Promise<string> {
  const doc = await db.collection("usuarios").doc(uid).get();
  return doc.exists ? (doc.data()?.nome ?? "Usuário") : "Usuário";
}

/**
 * Valida os campos comuns de envio de pergunta.
 * @param {string} startupId
 * @param {string} texto
 */
function validarInput(startupId: string, texto: string): void {
  if (!startupId?.trim()) {
    throw new HttpsError(
      "invalid-argument",
      "O campo startupId é obrigatório."
    );
  }
  if (!texto?.trim()) {
    throw new HttpsError(
      "invalid-argument",
      "A pergunta não pode ser vazia."
    );
  }
  if (texto.trim().length > 500) {
    throw new HttpsError(
      "invalid-argument",
      "A pergunta não pode ter mais de 500 caracteres."
    );
  }
}

// ─────────────────────────────────────────────
// criarPergunta
// Chamado pelo Flutter ao enviar qualquer pergunta.
// Se visibilidade == "privada", verifica se é investidor.
// ─────────────────────────────────────────────

export const criarPergunta = onCall(
  async (request: CallableRequest<CriarPerguntaInput>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }

    const {startupId, texto, visibilidade} = request.data;
    validarInput(startupId, texto);

    if (visibilidade !== "publica" && visibilidade !== "privada") {
      throw new HttpsError(
        "invalid-argument",
        "O campo visibilidade deve ser 'publica' ou 'privada'."
      );
    }

    // Se for privada, verifica se o usuário possui tokens da startup
    if (visibilidade === "privada") {
      const ehInvestidor = await usuarioEhInvestidor(uid, startupId.trim());
      if (!ehInvestidor) {
        throw new HttpsError(
          "permission-denied",
          "Apenas investidores desta startup podem enviar perguntas privadas."
        );
      }
    }

    const nomeAutor = await buscarNomeUsuario(uid);

    await criarPerguntaRepo({
      startupId: startupId.trim(),
      autorUid: uid,
      autorNome: nomeAutor,
      texto: texto.trim(),
      resposta: null,
      respondidoEm: null,
      criadoEm: Timestamp.now(),
      visibilidade,
    });

    return {mensagem: "Pergunta enviada com sucesso."};
  }
);

// ─────────────────────────────────────────────
// listarPerguntas
// Chamado pelo Flutter ao abrir a aba de perguntas.
// Retorna públicas para todos; privadas só para investidores.
// ─────────────────────────────────────────────

export const listarPerguntas = onCall(
  async (request: CallableRequest<{startupId: string}>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Usuário não autenticado."
      );
    }

    const {startupId} = request.data;
    if (!startupId?.trim()) {
      throw new HttpsError(
        "invalid-argument",
        "O campo startupId é obrigatório."
      );
    }

    // Sempre carrega as públicas
    const publicas = await buscarPerguntasPublicas(startupId.trim());

    // Privadas só se for investidor
    const ehInvestidor = await usuarioEhInvestidor(uid, startupId.trim());
    const privadas = ehInvestidor ?
      await buscarPerguntasPrivadas(startupId.trim()) :
      [];

    return {
      perguntas: [...publicas, ...privadas],
      ehInvestidor,
    };
  }
);
