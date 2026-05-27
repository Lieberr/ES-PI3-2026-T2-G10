// Feito por: Matheus Henrique Portugal Narducci RA: 25008976

import {db} from "../../shared/firebase";
import {Pergunta} from "../types/pergunta";
import {Timestamp} from "firebase-admin/firestore";

// Salva a nova pergunta no Firestore
// A resposta começa nula e vai ser preenchida pelo seed/admin.
//@param {Omit<Pergunta, "id">} dados - Dados da pergunta sem o id
//* @return {Promise<string>} ID gerado do documento

export async function criarPergunta(
    dados: Omit<Pergunta, "id">
); Promise<string> {
    const ref = db
    .collection("startups")
    .doc(dados.startupId)
    .collection("perguntas")
    .doc();

    await ref.set({
        ...dados,
        id: ref.id,
    });
    return ref.id;
}


// Busca todas as perguntas públicas de uma startup,
// ordenadas da mais recente para a mais antiga.
// @param {string} startupId - ID da startup
// @return {Promise<Pergunta[]>}

export async function buscarPerguntasDaStartup(
    startupId: string
):   Promise<Pergunta[]> {
    const snap = await db
        .collection("startups")
        .doc(startupId)
        .collection("perguntas")
        .where("publica", "==", true)
        .orderBy("CriadoEm", "desc")
        .get();
    if (snap.empty) return [];

    return snap.docs.map((doc) => doc.data() as Pergunta);
}

 
// Adiciona ou atualiza a resposta de uma pergunta existente.
// Usado pelo seed ou painel admin para responder perguntas.
// @param {string} startupId - ID da startup dona da pergunta
// @param {string} perguntaId - ID da pergunta a ser respondida
// @param {string} resposta - Texto da resposta
// @return {Promise<void>}

export async function responderPergunta(
    startupId: string,
    perguntaId: string,
    resposta: string
):   Promise<void> {
    await db
        .collection("startups")
        .doc(startupId)
        .collection("perguntas")
        .doc(perguntaId)
        .updeate ({
            resposta,
            respondidoEm: Timestamp.now(),
        });
}
  
