// Feito por Leonardo Dionel RA: 25010092

import {Timestamp} from "firebase-admin/firestore";

export interface TransacaoPrimaria {
  uid: string;
  startupId: string;
  quantidade: number;
  data: Timestamp;
  tipo: "compra" | "venda";
}

export interface TransacaoSecundaria {
  uidComprador: string;
  uidVendedor: string;
  startupId: string;
  quantidade: number;
  valorUnitario: number;
  data: Timestamp;
  status: "aberta" | "fechada" | "cancelada";
}

export interface TokenUsuario {
  quantidade: number;
}