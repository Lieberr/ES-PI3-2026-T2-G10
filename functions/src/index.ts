// Feito por Leonardo Dionel RA: 25010092

import {setGlobalOptions} from "firebase-functions/v2";
import "./shared/firebase"; // garante inicialização antes dos módulos

setGlobalOptions({
  maxInstances: 10,
  region: "southamerica-east1",
});

export * from "./usuarios";
export * from "./carteira";