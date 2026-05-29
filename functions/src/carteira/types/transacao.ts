// Feito por Leonardo Dionel RA: 25010092

import {Timestamp} from "firebase-admin/firestore";

export interface TransacaoPrimaria {
  uid: string;
  startupId: string;
  quantidade: number;
  valorUnitario: number;
  valorTotal: number,
  tipo: "compra" | "venda";
  data: Timestamp;
}

export interface TransacaoSecundaria {
  uidComprador?: string;
  uidVendedor?: string;
  startupId: string;
  quantidade: number;
  valorUnitario: number;
  valorTotal: number;
  tipo: "compra" | "venda";
  status: "aberta" | "fechada" | "cancelada";
  criadaEm: Timestamp;
  resolvidaEm: Timestamp | null;
}

export interface TokenUsuario {
  startupId: string;
  quantidade: number;
  quantidadeReservada: number;
  valorInvestido: number;
}
