// Feito por Leonardo Dionel RA: 25010092

// Ponto de entrada das Cloud Functions: configura opções globais e reexporta todos os módulos.

import {setGlobalOptions} from "firebase-functions/v2";

// Limita instâncias e define região de deploy (São Paulo).
setGlobalOptions({
  maxInstances: 10,
  region: "southamerica-east1",
});

// Cada export expõe funções callable ao app Flutter.
export * from "./usuarios";
export * from "./carteira";
export * from "./startups";
export * from "./2fa";
export * from "./perguntas";
