// Feito por Leonardo Dionel RA: 25010092

import {Timestamp} from "firebase-admin/firestore";

// Transação direta com a startup (mercado primário), coleção mercadoPrimario.
export interface TransacaoPrimaria {
  uid: string;
  startupId: string;
  quantidade: number;
  valorUnitario: number;
  valorTotal: number,
  tipo: "compra" | "venda";
  data: Timestamp;
}

// Oferta entre usuários (mercado secundário / balcão), coleção mercadoSecundario.
export interface TransacaoSecundaria {
  uidComprador: string | null;
  uidVendedor: string | null;
  startupId: string;
  quantidade: number;
  valorUnitario: number;
  valorTotal: number;
  tipo: "compra" | "venda";
  status: "aberta" | "fechada" | "cancelada";
  criadaEm: Timestamp;
  resolvidaEm: Timestamp | null;
}

// Posição do usuário em tokens de uma startup (subcoleção carteiras/{uid}/tokens).
export interface TokenUsuario {
  startupId: string;
  quantidade: number;
  // Tokens reservados em ofertas de venda abertas no balcão.
  quantidadeReservada: number;
  valorInvestido: number;
}
