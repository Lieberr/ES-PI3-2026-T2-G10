import { Timestamp } from "firebase-admin/firestore"

interface Usuario {
    uid:string;
    email:string;
    nomeCompleto:string;
    CPF:string;
    telefone:string;
    criadoEm:Timestamp;
    atualizadoEm:Timestamp;
}

interface Socio {
  nome: string
  percentual: number
  bio: string
  fotoUrl: string
}

interface Mentor {
  nome: string
  papel: string
}