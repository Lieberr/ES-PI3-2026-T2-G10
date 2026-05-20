// Feito por Leonardo Dionel RA: 25010092

import {Usuario} from "../types/usuario";
import {db} from "../../shared/firebase";

/**
 *  Salva um usuario ao ser criado
 * @param {Usuario} usuario - Dados do usuario ao salvar.
 * @return {Promise<void>}
 */
export async function salvarUsuario(usuario: Usuario): Promise<void> {
  const usuariosCollection = db.collection("usuarios");
  await usuariosCollection.doc(usuario.uid).set(usuario);
}

/**
 *  Busca um usuario pelo CPF
 * @param {string} cpf - CPF do usuário no Firestore
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
 *  Busca um usuario pelo UID
 * @param {string} uid - UID do usuário no Firebase Auth.
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
