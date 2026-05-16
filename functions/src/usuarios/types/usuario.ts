// Feito por Leonardo Dionel RA: 25010092

import {Timestamp} from "firebase-admin/firestore";

/** Dados armazenados no Firestore após o cadastro. */
export interface Usuario {
  uid: string;
  nomeCompleto: string;
  email: string;
  cpf: string;
  telefone: string;
  criadoEm: Timestamp;
}

/** Dados recebidos do Flutter na chamada onCall de cadastro. */
export interface CadastrarUsuarioInput {
  nomeCompleto: string;
  email: string;
  cpf: string;
  telefone: string;
  senha: string;
}
