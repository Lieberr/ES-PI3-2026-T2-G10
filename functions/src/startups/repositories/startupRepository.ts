import {Startup} from "../types/startup";
import {db} from "../../shared/firebase";

/**
 *  Busca todas as startups
 * @return {Promise<Startup[]>} Retorna as startups
 */
export async function buscarStartups(): Promise<Startup[]> {
  const startupsCollections = db.collection("startups");
  const snap = await startupsCollections.get();

  const startups: Startup[] = snap.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as Startup[];

  return startups;
}

/**
 *  Busca startup por ID
 * @param {string} id - ID da startup no firestore
 * @return {Promise<Startup[] | null>} Startup encontrada ou null
 */
export async function buscarStartupsPorId(id: string): Promise<Startup | null> {
  const startupsCollection = db.collection("startups");
  const doc = await startupsCollection.doc(id).get();
  if (!doc.exists) return null;
  return doc.data() as Startup;
}

/**
 *  Busca startups pelo estagio
 * @param {string} estagio - Estagio das startups no firebase
 * @return {Promise<Startup[] | null>} startup encontrada ou null.
 */
export async function buscarStartupPorEstagio(
  estagio: string
): Promise<Startup[] | null> {
  const startupsCollection = db.collection("startups");
  const snap = await startupsCollection
    .where("estagio", "==", estagio)
    .get();

  if (snap.empty) return null;
  const startups: Startup[] = snap.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as Startup[];

  return startups;
}
