/**
 * @author Leonardo Dionel
 * @ra 25010092
 *
 * Camada de acesso ao Firestore para o módulo de usuários.
 * Só executa queries — sem regras de negócio aqui.
 */

import * as admin from "firebase-admin";
import { Usuario } from "../types/usuario";

const db = () => admin.firestore();
const COLECAO = "usuarios";

/**
 * Salva os dados do usuário no Firestore.
 * O documento é identificado pelo uid do Firebase Auth.
 */
export async function salvarUsuario(usuario: Usuario): Promise<void> {
  await db().collection(COLECAO).doc(usuario.uid).set(usuario);
}

/**
 * Busca usuário pelo CPF (somente dígitos).
 * Usado para evitar cadastros duplicados de CPF.
 * Retorna null se não encontrar.
 */
export async function buscarUsuarioPorCpf(cpf: string): Promise<Usuario | null> {
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
 * Retorna null se não encontrar.
 */
export async function buscarUsuarioPorUid(uid: string): Promise<Usuario | null> {
  const doc = await db().collection(COLECAO).doc(uid).get();
  if (!doc.exists) return null;
  return doc.data() as Usuario;
}
