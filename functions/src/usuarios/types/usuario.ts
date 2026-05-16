/**
 * @author Leonardo Dionel
 * @ra 25010092
 *
 * Tipagem do módulo de usuários.
 */

import { Timestamp } from "firebase-admin/firestore";

/** Dados armazenados no Firestore após o cadastro. */
export interface Usuario {
  uid: string;
  nomeCompleto: string;
  email: string;
  cpf: string;       // armazenado somente com dígitos (sem formatação)
  telefone: string;  // armazenado somente com dígitos
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
