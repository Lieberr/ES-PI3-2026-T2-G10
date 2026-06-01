// Feito por: Matheus Henrique Portugal Narducci RA: 2500896

import {Timestamp} from "firebase-admin/firestore";

// Visibilidade da pergunta: pública (todos) ou privada (somente investidores).
export type Visibilidade = "publica" | "privada";

// Documento em startups/{startupId}/perguntas/{id}.
export interface Pergunta {
  id: string;
  startupId: string;
  autorUid: string;
  autorNome: string;
  texto: string;
  resposta: string | null;
  respondidoEm: Timestamp | null;
  criadoEm: Timestamp;
  visibilidade: Visibilidade;
}

// Payload enviado pelo app ao criar uma pergunta.
export interface CriarPerguntaInput {
  startupId: string;
  texto: string;
  visibilidade: Visibilidade;
}

