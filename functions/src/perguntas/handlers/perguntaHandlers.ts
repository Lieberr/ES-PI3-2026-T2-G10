// Feito por: Matheus Henrique Portugal Narducci RA: 25008976

import {onCall, CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {Timestamp} from "firebase-admin/firestore";
import {CriarPerguntaInput} from "../types/pergunta";
import {
  criarPergunta,
  buscarPerguntasPublicas,
  buscarPerguntasPrivadas,
  usuarioEhInvestidor,
} from "../repositories/perguntaRepository";
import {db} from "../../shared/firebase";


// Helpers


/**
 // Busca o nome do usuário no Firestore.
 * @param {string} uid
 * @return {Promise<string>}
 */
async function buscarNomeUsuario(uid: string): Promise<string> {
  const doc = await db.collection("usuarios").doc(uid).get();
  return doc.exists ? (doc.data()?.nome ?? "Usuário") : "Usuário";
}

/**
 // Valida os campos comuns de envio de pergunta.
 * @param {string} startupId
 * @param {string} texto
 */
function validarInput(startupId: string, texto: string): void {
  if (!startupId?.trim()) {
    throw new HttpsError("invalid-argument", "O campo startupId é obrigatório.");
  }
  if (!texto?.trim()) {
    throw new HttpsError("invalid-argument", "A pergunta não pode ser vazia.");
  }
  if (texto.trim().length > 500) {
    throw new HttpsError(
      "invalid-argument",
      "A pergunta não pode ter mais de 500 caracteres."
    );
  }
}


// Perguntas Públicas


/**
 * Qualquer usuário autenticado pode enviar uma pergunta pública.
 */
export const enviarPergunta = onCall(
  async (request: CallableRequest<CriarPerguntaInput>) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Usuário não autenticado.");

    const {startupId, texto} = request.data;
    validarInput(startupId, texto);

    const nomeAutor = await buscarNomeUsuario(uid);

    await criarPergunta({
      startupId: startupId.trim(),
      autorUid: uid,
      autorNome: nomeAutor,
      texto: texto.trim(),
      resposta: null,
      respondidoEm: null,
      criadoEm: Timestamp.now(),
      publica: true,
    });

    return {mensagem: "Pergunta pública enviada com sucesso."};
  }
);

/**
 * Retorna as perguntas públicas da startup.
 * Visível a qualquer usuário autenticado.
 */
export const getPerguntasDaStartup = onCall(
  async (request: CallableRequest<{startupId: string}>) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Usuário não autenticado.");

    const {startupId} = request.data;
    if (!startupId?.trim()) {
      throw new HttpsError("invalid-argument", "O campo startupId é obrigatório.");
    }

    const perguntas = await buscarPerguntasPublicas(startupId.trim());
    return {perguntas};
  }
);


// Perguntas Privadas (somente investidores)


 //Somente usuários que possuem tokens da startup podem
 //enviar uma pergunta privada.

export const enviarPerguntaPrivada = onCall(
  async (request: CallableRequest<CriarPerguntaInput>) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Usuário não autenticado.");

    const {startupId, texto} = request.data;
    validarInput(startupId, texto);

    const ehInvestidor = await usuarioEhInvestidor(uid, startupId.trim());
    if (!ehInvestidor) {
      throw new HttpsError(
        "permission-denied",
        "Apenas investidores desta startup podem enviar perguntas privadas."
      );
    }

    const nomeAutor = await buscarNomeUsuario(uid);

    await criarPergunta({
      startupId: startupId.trim(),
      autorUid: uid,
      autorNome: nomeAutor,
      texto: texto.trim(),
      resposta: null,
      respondidoEm: null,
      criadoEm: Timestamp.now(),
      publica: false,  // ← marca como privada
    });

    return {mensagem: "Pergunta privada enviada com sucesso."};
  }
);

/**
 * Retorna as perguntas privadas da startup.
 * Somente investidores (usuários com tokens) têm acesso.
 */
export const getPerguntasPrivadasDaStartup = onCall(
  async (request: CallableRequest<{startupId: string}>) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Usuário não autenticado.");

    const {startupId} = request.data;
    if (!startupId?.trim()) {
      throw new HttpsError("invalid-argument", "O campo startupId é obrigatório.");
    }

    const ehInvestidor = await usuarioEhInvestidor(uid, startupId.trim());
    if (!ehInvestidor) {
      throw new HttpsError(
        "permission-denied",
        "Apenas investidores desta startup têm acesso às perguntas privadas."
      );
    }

    const perguntas = await buscarPerguntasPrivadas(startupId.trim());
    return {perguntas};
  }
);