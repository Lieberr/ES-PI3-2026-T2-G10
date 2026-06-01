// Feito por Gustavo Lieb RA: 24023376


import {Timestamp} from "firebase-admin/firestore";
import {db} from "../../shared/firebase";
import {TwoFaRecord} from "../types/twofa";


const doisFaCollection = db.collection("twofa");
const usuariosCollection = db.collection("usuarios");

/**
 * Salva o código 2FA e metadados no Firestore.
 * @param {string} uid UID do usuário.
 * @param {string} codeHash Hash do código gerado.
 * @param {Timestamp} expiresAt Data de expiração do código.
 */
export async function salvarCodigo2FA(
  uid: string,
  codeHash: string,
  expiresAt: Timestamp,
): Promise<void> {
  await doisFaCollection.doc(uid).set({
    codeHash,
    expiresAt,
    attempts: 0,
    createdAt: Timestamp.now(),
  });
}

/**
 * Busca o registro de código 2FA para um usuário.
 * @param {string} uid UID do usuário.
 */
export async function buscarCodigo2FA(
  uid: string,
): Promise<TwoFaRecord | null> {
  const doc = await doisFaCollection.doc(uid).get();
  if (!doc.exists) return null;
  return doc.data() as TwoFaRecord;
}

/**
 * Deleta o código 2FA do Firestore após uso ou expiração.
 */
/**
 * Deleta o código 2FA armazenado para o usuário.
 * @param {string} uid UID do usuário.
 */
export async function deletarCodigo2FA(
  uid: string,
): Promise<void> {
  await doisFaCollection.doc(uid).delete();
}

/**
 * Incrementa o contador de tentativas de verificação do código.
 * @param {string} uid UID do usuário.
 * @param {number} attempts Novo valor de tentativas.
 */
export async function incrementarTentativas2FA(
  uid: string,
  attempts: number,
): Promise<void> {
  await doisFaCollection.doc(uid).update({attempts});
}

/**
 * Marca o documento do usuário com 2FA ativado.
 * @param {string} uid UID do usuário.
 */
export async function marcarTwoFaEnabled(
  uid: string,
): Promise<void> {
  await usuariosCollection.doc(uid).set(
    {twofaEnabled: true},
    {merge: true},
  );
}
