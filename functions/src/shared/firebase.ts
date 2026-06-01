// Feito por Leonardo Dionel RA: 25010092

// Inicialização compartilhada do Firebase Admin SDK usada por todos os módulos.

import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";

// Evita reinicializar o app quando o módulo é importado mais de uma vez.
if (getApps().length === 0) {
  initializeApp();
}

// Instâncias singleton de Firestore e Auth para leitura/escrita no backend.
export const db = getFirestore();
export const auth = getAuth();
