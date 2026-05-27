// Feito por: Matheus Henrique Portugal Narducci RA: 25008976

import {onCall, CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {Timestamp} from "firebase-admin/firestore";
import {CriarPerguntaInput} from "../types/pergunta";
import {
    criarPergunta,
    buscarPerguntasdaStartup,
} from "../repositories/perguntaRepository";
import {db} from "../..shared/firebase";

// Vai receber uma pergunta do usuário autenticado e salva no Firestore.
// A resposta da pergunta vai começar como null e vai ser respondida via seed/admin.

export const enviarPergunta = onCall (
    async (request: CallableRequest<CriarPerguntaInput>) => {
        const uid = request.auth?.uid;
        if (!uid) {
            throw new HttpsError("unauthenticated", "Usuário não autenticado.");
    }

    const {startupId, texto} = request.data;

    if (!startupId || !startupId.trim()) {
        throw new HttpsError (
            "Invalid=argument",
            "O campo startupId é obrigatório e não pode ser vazio."
        );
    }
    if (!texto || !texto.trim()) {
        throw new HttpsError (
            "Invalid-argument",
            "A pergunta não pode ser vazia."
        );
    }

    if (texto.trim().length > 150) {
        throw new HttpsError (
            "Ivalid-argument", 
            "A pergunta não pode ter mais de 150 caracteres."
        );
    }

    // Vai buscar o nome do usuário no firestore para exibir na pergunta.
    
    const usuarioDoc = await db.collection("usuarios").doc(uid).get();
    const nomeAutor : string = usuarioDoc.exists 
       ? (usuarioDoc.data()?.nome ?? "Usuário") 
       : "Usuário";

    
    await criarPergunta({
        startupId: startupId.trim(),
        autorUid: uid,
        autorNome: nomeAutor,
        texto: texto.trim(),
        resposta: null,
        respondidoEm: null,
        criadoEm: Timestamp.now(),
        publica: true,
    });

    return {mensagem: "Pergunta enviada com sucesso."};
  }
);

// Retorna todas as perguntas publicas de uma startup,
// incluindo as que nao foram respondidas.

export const getPerguntasDaStartup = onCall (
    async (request: CallableRequest<{startupId: string}>) => {
        const uid = request.auth?.uid;
        if (!uid) {
            throw new HttpsError (
                "unauthenticated", 
                "Usuário não autenticado."
            );
        }

        const {startupId} =request.data;
        if (!startupId || !startupId.trim()) {
            throw new HttpsError (
                "invalid-argument",
                "O campo startupId é obrigatório."
            );
        }

        const perguntas = await buscarPerguntasDaStartup(startupId.trim());
        return {perguntas};

    }
);