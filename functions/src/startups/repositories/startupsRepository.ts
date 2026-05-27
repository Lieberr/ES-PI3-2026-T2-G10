// Feito por Gustavo Lieb Ra: 24023376

// startups/repositories/startupRepository.ts

import { db } from "../../shared/firebase";
import { Startup } from "../types/startup";

export async function listarStartups(): Promise<Startup[]> {
  const snap = await db.collection("startups").get();

  return snap.docs.map((doc) => {
    const data = doc.data();

    return {
      id: doc.id,
      nome: data.nome,
      descricao: data.descricao,
      estagio: data.estagio,
      status: data.status,
      capitalAportado: data.capitalAportado,
      tokensDisponiveis: data.tokensDisponiveis,
      tokensEmitidos: data.tokensEmitidos,
      valorToken: data.valorToken,
      setor: data.setor,
      videoDemo: data.videoDemo,
    };
  });
}