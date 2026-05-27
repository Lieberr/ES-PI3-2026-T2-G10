// Feito por Gustavo Lieb Ra: 2023376

export interface Startup {
    id: string;
    nome: string;
    descricao: string;
    estagio: string;

    capitalAportado: number;
    tokensDisponiveis: number;
    tokensEmitidos: number;
    valorToken: number;

    setor: string;
    videoDemo?: string;
}