// Feito por Leonardo Dionel RA: 25010092

import {Carteira} from "../types/carteira";
import {db} from "../../shared/firebase";
import {Timestamp} from "firebase-admin/firestore";

const carteirasCollection = db.collection("carteiras");

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
  await carteirasCollection.doc(uid).set(carteira);
}