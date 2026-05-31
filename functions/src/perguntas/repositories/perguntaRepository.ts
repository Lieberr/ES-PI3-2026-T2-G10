// Feito por: Matheus Henrique Portugal Narducci RA: 25008976

import {db} from "../../shared/firebase";
import {Pergunta} from "../types/pergunta";
import {Timestamp} from "firebase-admin/firestore";

/**
 * Salva uma nova pergunta no Firestore.
 * @param {Omit<Pergunta, "id">} dados - Dados da pergunta sem o id
 * @return {Promise<string>} ID gerado do documento
 */
export async function criarPergunta(
  dados: Omit<Pergunta, "id">
): Promise<string> {
  const ref = db
    .collection("startups")
    .doc(dados.startupId)
    .collection("perguntas")
    .doc();

  await ref.set({...dados, id: ref.id});
  return ref.id;
}

/**
 * Busca todas as perguntas PÚBLICAS de uma startup.
 * Visíveis a qualquer usuário autenticado.
 * @param {string} startupId - ID da startup
 * @return {Promise<Pergunta[]>}
 */
export async function buscarPerguntasPublicas(
  startupId: string
): Promise<Pergunta[]> {
  const snap = await db
    .collection("startups")
    .doc(startupId)
    .collection("perguntas")
    .where("publica", "==", true)
    .orderBy("criadoEm", "desc")
    .get();

  if (snap.empty) return [];
  return snap.docs.map((doc) => doc.data() as Pergunta);
}

/**
 * Busca todas as perguntas PRIVADAS de uma startup.
 * Só acessível após verificar que o usuário possui tokens.
 * @param {string} startupId - ID da startup
 * @return {Promise<Pergunta[]>}
 */
export async function buscarPerguntasPrivadas(
  startupId: string
): Promise<Pergunta[]> {
  const snap = await db
    .collection("startups")
    .doc(startupId)
    .collection("perguntas")
    .where("publica", "==", false)
    .orderBy("criadoEm", "desc")
    .get();

  if (snap.empty) return [];
  return snap.docs.map((doc) => doc.data() as Pergunta);
}

/**
 * Verifica se o usuário possui tokens de determinada startup.
 * Usado para liberar acesso às perguntas privadas.
 * @param {string} uid - UID do usuário
 * @param {string} startupId - ID da startup
 * @return {Promise<boolean>}
 */
export async function usuarioEhInvestidor(
  uid: string,
  startupId: string
): Promise<boolean> {
  const tokenDoc = await db
    .collection("carteiras")
    .doc(uid)
    .collection("tokens")
    .doc(startupId)
    .get();

  if (!tokenDoc.exists) return false;
  const quantidade = tokenDoc.data()?.quantidade ?? 0;
  return quantidade > 0;
}

/**
 * Atualiza a resposta de uma pergunta existente.
 * Usado pelo seed ou painel admin.
 * @param {string} startupId
 * @param {string} perguntaId
 * @param {string} resposta
 * @return {Promise<void>}
 */
export async function responderPergunta(
  startupId: string,
  perguntaId: string,
  resposta: string
): Promise<void> {
  await db
    .collection("startups")
    .doc(startupId)
    .collection("perguntas")
    .doc(perguntaId)
    .update({
      resposta,
      respondidoEm: Timestamp.now(),
    });
}
