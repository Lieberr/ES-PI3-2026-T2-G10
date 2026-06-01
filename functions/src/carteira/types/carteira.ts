// Feito por Leonardo Dionel RA: 25010092

import {Timestamp} from "firebase-admin/firestore";

// Documento principal da carteira em carteiras/{uid}.
export interface Carteira {
  uid: string;
  saldo: number;
  // Valor bloqueado em ofertas de compra no mercado secundário.
  saldoReservado: number;
  criadoEm: Timestamp;
}

// Registro de depósito ou saque na subcoleção operacoes.
export interface Operacao {
  uid: string;
  tipo: "deposito" | "saque";
  valor: number;
  realizadoEm: Timestamp;
}

// Payload recebido nas funções depositar e sacar.
export interface AtualizarSaldoInput {
  valor: number;
}
