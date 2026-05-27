// Feito por Leonardo Dionel RA: 25010092

import {setGlobalOptions} from "firebase-functions/v2";

setGlobalOptions({
  maxInstances: 10,
  region: "southamerica-east1",
});

export * from "./usuarios";
export * from "./carteira";
export * from "./startups";
export * from "./perguntas";
