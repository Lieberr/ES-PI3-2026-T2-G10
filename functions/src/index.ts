// Feito por Leonardo Dionel RA: 25010092

import * as admin from "firebase-admin";
import {setGlobalOptions} from "firebase-functions/v2";

admin.initializeApp();

// Configurações globais aplicadas a todas as functions
setGlobalOptions({
  maxInstances: 10,
  region: "southamerica-east1",
});

// Exporta os módulos
export * from "./usuarios";
