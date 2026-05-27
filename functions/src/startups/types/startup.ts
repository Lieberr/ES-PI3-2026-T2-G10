<<<<<<< HEAD
// Feito por Gustavo Lieb Ra: 2023376
=======
// Feito por Leonardo Dionel RA: 25010092

import {Timestamp} from "firebase-admin/firestore";


export interface Socio{
    nome: string;
    percentual: number;
}

export interface HistoricoPrecos {
    valorToken: number;
    data: Timestamp;
}
>>>>>>> main

export interface Startup {
    id: string;
    nome: string;
    descricao: string;
<<<<<<< HEAD
    estagio: string;

    capitalAportado: number;
    tokensDisponiveis: number;
    tokensEmitidos: number;
    valorToken: number;

    setor: string;
    videoDemo?: string;
}
=======
    estagio: "Nova" | "Em operação" | "Em expansão";
    setor: string;
    capitalAportado: number;
    tokensEmitidos: number;
    tokensDisponiveis: number;
    valorToken: number;
    videoDemo: string;
    status: "Ativa" | "Inativa";
    socios: Socio[];
    mentores: string[];
}
>>>>>>> main
