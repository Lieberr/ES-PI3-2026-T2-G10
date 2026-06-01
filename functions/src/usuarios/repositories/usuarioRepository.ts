// Feito por Leonardo Dionel RA: 25010092

// Camada de persistência de usuários na coleção usuarios.

import {Usuario} from "../types/usuario";
import {db} from "../../shared/firebase";

/**
 * Salva os dados do usuário no Firestore.
 * @param {Usuario} usuario - Dados do usuário a salvar.
 * @return {Promise<void>}
 */
export async function salvarUsuario(usuario: Usuario): Promise<void> {
  const usuariosCollection = db.collection("usuarios");
  await usuariosCollection.doc(usuario.uid).set(usuario);
}

/**
 * Busca usuário pelo CPF para evitar duplicatas.
 * @param {string} cpf - CPF somente com dígitos.
 * @return {Promise<Usuario | null>} Usuário encontrado ou null.
 */
export async function buscarUsuarioPorCpf(
  cpf: string
): Promise<Usuario | null> {
  const usuariosCollection = db.collection("usuarios");
  const snap = await usuariosCollection
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
  const usuariosCollection = db.collection("usuarios");
  const doc = await usuariosCollection.doc(uid).get();
  if (!doc.exists) return null;
  return doc.data() as Usuario;
}
