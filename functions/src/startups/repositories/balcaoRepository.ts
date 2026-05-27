import { Timestamp } from "firebase-admin/firestore";
import { TransacaoSecundaria } from "../../carteira/types/transacao"
import {db} from "../../shared/firebase";


/**
 * Cria uma oferta
 * @param {TransacaoSecundaria} oferta - Oferta criada
 * @return {Promise<id>}
 */
export async function criarOferta(
    oferta: TransacaoSecundaria
): Promise<string> {
  const ref = db.collection("mercadoSecundario").doc();
  await ref.set(oferta);
  return ref.id;
}


/**
 * Busca todas as ofertas abertas
 * @param {string} startupId - ID da startup na qual vamos buscar as ofertas
 * @return {Promise<TransacaoSecundaria>} Retorna as ofertas
 */
export async function buscarOfertasAbertas(startupId: string)
: Promise<TransacaoSecundaria[]> {
    const mercadoSecundarioCollection = db.collection("mercadoSecundario");
    const snap = await mercadoSecundarioCollection
    .where("status", "==", "aberta")
    .where("startupId", "==", startupId)
    .get();
    const ofertas: TransacaoSecundaria[] = snap.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
    })) as unknown as TransacaoSecundaria[];
    
    return ofertas;
}

/**
 * Busca uma oferta pelo ID do usuario
 * @param {string} uid - ID do usuario
 * @return {Promise<TransacaoSecundaria[]>} Retorna a oferta
 */
export async function buscarOfertaPorUid(
    uid: string
): Promise<TransacaoSecundaria[]> {
    const mercadoSecundarioCollection = db.collection("mercadoSecundario");
    const snapVendedor = await mercadoSecundarioCollection
    .where("uidVendedor", "==", uid).get();
    const snapComprador = await mercadoSecundarioCollection
    .where("uidComprador", "==", uid).get();

    const ofertas = [
        ...snapVendedor.docs,
        ...snapComprador.docs,
    ].map((doc) => ({
        id: doc.id, 
        ...doc.data()
    })) as unknown as TransacaoSecundaria[];

    return ofertas;
}


/**
 * Busca uma oferta pelo ID da oferta
 * @param {string} id - ID da oferta
 * @return {
 * Promise<TransacaoSecundaria | null>
 * } Retorna a oferta ou nulo se não encontrar.
 */
export async function buscarOfertaPorId(
    id: string
): Promise<TransacaoSecundaria | null> {
  const mercadoSecundarioCollection = db.collection("mercadoSecundario");
  const doc = await mercadoSecundarioCollection.doc(id).get();
  if (!doc.exists) return null;
  return doc.data() as TransacaoSecundaria;
}


/**
 * Cancela uma oferta
 * @param {string} id - ID da oferta
 * @return {Promise<void>}
 */
export async function cancelarOferta(
    id: string
): Promise<void> {
    await db.collection("mercadoSecundario")
    .doc(id)
    .update({status: "cancelada"});
}


/**
 * Fecha uma oferta ao ser concluida
 * @param {string} id - ID da oferta
 * @return {Promise<void>}
 */
export async function fecharOferta(
    id:string,
    uidAceitante: string,
    tipo: "compra" | "venda",
): Promise<void> {
    
    const atualizacao = tipo === "compra"
    ? {status: "fechada", uidVendedor: uidAceitante, resolvidaEm: Timestamp.now()}
    : {status: "fechada", uidComprador: uidAceitante, resolvidaEm: Timestamp.now()};

    await db.collection("mercadoSecundario").doc(id).update(atualizacao);
}