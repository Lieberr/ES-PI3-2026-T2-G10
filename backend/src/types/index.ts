<<<<<<< Updated upstream
=======
import { Timestamp } from "firebase-admin/firestore"

export interface Usuario {
    email: string,
    nome: string,
    CPF: string,
    telefone: string,
    criadoEm: Timestamp,
    atualizadoEm: Timestamp
    mfaHabilitado: boolean
}

export interface Carteira {
    saldoReais: number
    tokens: {
        [startupId:string]: {
            quantidade: number,
            precoMedioAquisicao: number
        }
    }
    atualizadoEm: Timestamp
}

export interface Startup {
    nome: string
    descricao: string
    setor: string
    estagio: 'nova' | 'em_operacao' | 'em_expansao'
    logoUrl: string
    videoUrl: string
    sumarioExecutivo: string
    planoDeNegociosUrl: string
    totalTokenEmitidos: number
    precoAtualToken: number
    capitalAportado: number
    socios: Socio[]
    mentor: Mentor[]
    conselho: Conselheiro[]
    criadoEm: Timestamp
    atualizadoEm: Timestamp
}

export interface HistoricoPreco {
    data: string
    precoAbertura: number
    precoFechamento: number
    precoMaximo: number
    precoMinimo: number
    volume: number
    numeroTransacoes: number
    variacao: number
    atualizadoEm: Timestamp
}

export interface Oferta{
    tipo: 'compra' | 'venda'
    startupId: string
    usuarioId: string
    quantidade: number
    precoUnitario: number
    status: 'aberta' | 'executada' | 'cancelada'
    criadoEm: Timestamp
    atualizadoEm: Timestamp
}

export interface transacao{
    compradorId: string
    vendedorId: string
    startupId: string
    quantidade: number
    precoUnitario: number
    valorTotal: number
    ofertaCompraId: string
    ofertaVendaId: string
    executadaEm: Timestamp
}

export interface Socio {
  nome: string,
  percentual: number,
  bio: string,
  fotoUrl: string
}

export interface Mentor {
  nome: string,
  papel: string
}

export interface Conselheiro {
    nome: string,
    papel: string
}

declare global {
    namespace Express {
        interface Request {
            uid?: string
        }
    }
}
>>>>>>> Stashed changes
