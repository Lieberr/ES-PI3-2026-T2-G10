// Feito por Leonardo Dionel RA: 25010092

// Camada de persistência da carteira, tokens e transações do mercado primário.

import {Carteira, Operacao} from "../types/carteira";
import {db} from "../../shared/firebase";
import {Timestamp} from "firebase-admin/firestore";
import {TransacaoPrimaria, TokenUsuario} from "../types/transacao";

/**
 * Cria uma carteira zerada para o usuário recém cadastrado.
 * @param {string} uid - UID do usuário no Firebase Auth.
 * @return {Promise<void>}
 */
export async function criarCarteira(uid: string): Promise<void> {
  const carteira: Carteira = {
    uid,
    saldo: 0,
    saldoReservado: 0,
    criadoEm: Timestamp.now(),
  };
  const carteirasCollection = db.collection("carteiras");
  await carteirasCollection.doc(uid).set(carteira);
}

/**
 * Registra a operação no banco de dados
 * @param {Operacao} operacao - Dados da operação
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


/**
 * busca os tokens do usuario
 * @param {string} uid - UID do usuário no Firebase Auth.
 * @return {Promise<TokenUsuario[] | null>}
 */
export async function buscarTokenUsuario(
  uid: string
): Promise<TokenUsuario[] | null> {
  const tokensCollection = db
    .collection("carteiras")
    .doc(uid)
    .collection("tokens");
  const snap = await tokensCollection.get();

  if (snap.empty) return null;

  const tokens: TokenUsuario[] = snap.docs.map((doc) => ({
    startupId: doc.id,
    ...doc.data(),
  })) as TokenUsuario[];

  return tokens;
}


/**
 * Atualiza os tokens do usuario
 * @param {string} uid - UID do usuário no Firebase Auth.
 * @param {string} startupId - ID da startup
 * @param {number} novaQuantidade - Nova quantidade de tokens do usuario
 * @return {Promise<void>}
 */
export async function atualizarTokenUsuario(
  uid: string, startupId: string, novaQuantidade: number
): Promise<void> {
  await db.collection("carteiras").doc(uid)
    .collection("tokens").doc(startupId).set(
      {quantidade: novaQuantidade,
        quantidadeReservada: 0,
      },
      {merge: true}
    );
}


/**
 * Registra a transacao
 * @param {TransacaoPrimaria} transacao - Dados da transação primaria
 * @return {Promise<void>}
 */
export async function registrarTransacaoPrimaria(
  transacao: TransacaoPrimaria
): Promise<void> {
  await db.collection("mercadoPrimario").doc().set(transacao);
}
