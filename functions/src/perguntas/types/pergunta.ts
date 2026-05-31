// Feito por: Matheus Henrique Portugal Narducci RA: 2500896

import {Timestamp} from "firebase-admin/firestore";
 
export type Visibilidade = "publica" | "privada";
 
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
 
export interface CriarPerguntaInput {
  startupId: string;
  texto: string;
  visibilidade: Visibilidade;
}
 