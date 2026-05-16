// Feito por Leonardo Dionel RA: 25010092

import * as admin from "firebase-admin";
import {Usuario} from "../types/usuario";

const db = () => admin.firestore();
const COLECAO = "usuarios";

/**
 * Salva os dados do usuário no Firestore.
 * O documento é identificado pelo uid do Firebase Auth.
 * @param {Usuario} usuario - Dados completos do usuário a salvar.
 * @return {Promise<void>}
 */
export async function salvarUsuario(usuario: Usuario): Promise<void> {
  await db().collection(COLECAO).doc(usuario.uid).set(usuario);
}

/**
 * Busca usuário pelo CPF (somente dígitos).
 * Usado para evitar cadastros duplicados de CPF.
 * @param {string} cpf - CPF somente com dígitos.
 * @return {Promise<Usuario | null>} Usuário encontrado ou null.
 */
export async function buscarUsuarioPorCpf(
  cpf: string
): Promise<Usuario | null> {
  const snap = await db()
    .collection(COLECAO)
    .where("cpf", "==", cpf)
    .limit(1)
    .get();

  if (snap.empty) return null;
  return snap.docs[0].data() as Usuario;
}

/**
 * Busca usuário pelo uid do Firebase Auth.
 * @param {string} uid - UID do Firebase Auth.
 * @return {Promise<Usuario | null>} Usuário encontrado ou null.
 */
export async function buscarUsuarioPorUid(
  uid: string
): Promise<Usuario | null> {
  const doc = await db().collection(COLECAO).doc(uid).get();
  if (!doc.exists) return null;
  return doc.data() as Usuario;
}
