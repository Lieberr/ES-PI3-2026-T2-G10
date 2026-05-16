// Feito por Leonardo Dionel RA: 25010092

import {Usuario} from "../types/usuario";
import {db} from "../../shared/firebase";

const usuariosCollection = db.collection("usuarios");

  //Salva os dados do usuário no Firestore.
export async function salvarUsuario(usuario: Usuario): Promise<void> {
  await usuariosCollection.doc(usuario.uid).set(usuario);
}

  //Busca usuário pelo CPF (somente dígitos).
export async function buscarUsuarioPorCpf(
  cpf: string
): Promise<Usuario | null> {
  const snap = await usuariosCollection
    .where("cpf", "==", cpf)
    .limit(1)
    .get();

  if (snap.empty) return null;
  return snap.docs[0].data() as Usuario;
}

  //Busca usuário pelo uid do Firebase Auth.
export async function buscarUsuarioPorUid(
  uid: string
): Promise<Usuario | null> {
  const doc = await usuariosCollection.doc(uid).get();
  if (!doc.exists) return null;
  return doc.data() as Usuario;
}