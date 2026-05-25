// Feito por Leonardo Dionel RA: 25010092

import {Timestamp} from "firebase-admin/firestore";

export interface Carteira {
  uid: string;
  saldo: number;
  criadoEm: Timestamp;
}

export interface Operacao {
  uid: string;
  tipo: "deposito" | "saque";
  valor: number;
  realizadoEm: Timestamp;
}

export interface AtualizarSaldoInput {
  valor: number;
}