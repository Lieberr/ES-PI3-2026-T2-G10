// Feito por Leonardo Dionel RA: 25010092

import {Carteira, Operacao} from "../types/carteira";
import {db} from "../../shared/firebase";
import {Timestamp} from "firebase-admin/firestore";

/**
 * Cria uma carteira zerada para o usuário recém cadastrado.
 * @param {string} uid - UID do usuário no Firebase Auth.
 * @return {Promise<void>}
 */
export async function criarCarteira(uid: string): Promise<void> {
  const carteira: Carteira = {
    uid,
    saldo: 0,
    criadoEm: Timestamp.now(),
  };
  const carteirasCollection = db.collection("carteiras");
  await carteirasCollection.doc(uid).set(carteira);
}

/**
 * Registra a operação no banco de dados
 * @param {Operacao} operacao - UID do usuário no Firebase Auth.
 * @return {Promise<void>}
 */
export async function registrarOperacao(operacao: Operacao): Promise<void> {
  await db.collection("carteiras").doc(operacao.uid)
    .collection("operacoes").doc()
    .set(operacao);
}

/**
 * Atualiza o saldo do usuario
 * @param {string} uid - UID do usuário no Firebase Auth.
 * @param {number} novoSaldo - Novo saldo do usuario
 * @return {Promise<void>}
 */
export async function atualizarSaldo(
  uid: string, novoSaldo: number
): Promise<void> {
  await db.collection("carteiras").doc(uid).update({saldo: novoSaldo});
}


/**
 * busca a carteira do usuario
 * @param {string} uid - UID do usuário no Firebase Auth.
 * @return {Promise<Carteira | null>}
 */
export async function buscarCarteira(uid: string): Promise<Carteira | null> {
  const carteirasCollection = db.collection("carteiras");
  const doc = await carteirasCollection.doc(uid).get();
  if (!doc.exists) return null;
  return doc.data() as Carteira;
}
