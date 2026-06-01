// Feito por: Matheus Henrique Portugal Narducci RA: 25008976

import {db} from "../../shared/firebase";
import {Pergunta} from "../types/pergunta";
import {Timestamp} from "firebase-admin/firestore";

/**
 * Salva uma nova pergunta no Firestore.
 * @param {Omit<Pergunta, "id">} dados
 * @return {Promise<string>}
 */
export async function criarPerguntaRepo(
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
 * Busca perguntas públicas de uma startup.
 * @param {string} startupId
 * @return {Promise<Pergunta[]>}
 */
export async function buscarPerguntasPublicas(
  startupId: string
): Promise<Pergunta[]> {
  const snap = await db
    .collection("startups")
    .doc(startupId)
    .collection("perguntas")
    .where("visibilidade", "==", "publica")
    .orderBy("criadoEm", "desc")
    .get();

  if (snap.empty) return [];
  return snap.docs.map((doc) => doc.data() as Pergunta);
}

/**
 * Busca perguntas privadas de uma startup.
 * @param {string} startupId
 * @return {Promise<Pergunta[]>}
 */
export async function buscarPerguntasPrivadas(
  startupId: string
): Promise<Pergunta[]> {
  const snap = await db
    .collection("startups")
    .doc(startupId)
    .collection("perguntas")
    .where("visibilidade", "==", "privada")
    .orderBy("criadoEm", "desc")
    .get();

  if (snap.empty) return [];
  return snap.docs.map((doc) => doc.data() as Pergunta);
}

/**
 * Verifica se o usuário possui tokens da startup.
 * @param {string} uid
 * @param {string} startupId
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
  return (tokenDoc.data()?.quantidade ?? 0) > 0;
}

/**
 * Atualiza a resposta de uma pergunta existente.
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
