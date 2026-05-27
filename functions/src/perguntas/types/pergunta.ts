// Feito por: Matheus Henrique Portugal Narducci RA: 2500896

import {Timestamp} from "firebase-admin/firestore";

export interface Pergunta {
    id: string,
    startupId: string,
    autorUid: string,
    autorNome: string,
    texto: string,
    resposta: string | null,
    respondidoEm: Timestamp | null,
    criadoEm: Timestamp
    publica: boolean,
}

export interface CriarPerguntaInput {
    startupId: string,
    texto: string,
}