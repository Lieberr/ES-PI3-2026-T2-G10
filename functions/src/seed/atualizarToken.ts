// Feito por Leonardo Dionel RA: 25010092

import {initializeApp, cert} from "firebase-admin/app";
import {readFileSync} from "fs";

const serviceAccount = JSON.parse(
  readFileSync("./../servicesAccountKey.json", "utf8")
);

initializeApp({credential: cert(serviceAccount)});

import {Timestamp} from "firebase-admin/firestore";
import {db} from "../shared/firebase";

// ← EDITE AQUI antes de rodar
const STARTUP_ID = "ST001";
const NOVO_VALOR = 6.7;

// Para rodar, utilize => npx ts-node src/seed/atualizarToken.ts

async function atualizarToken(): Promise<void> {
  const startupRef = db.collection("startups").doc(STARTUP_ID);
  const historicoRef = startupRef.collection("historicoPrecos").doc();

  await db.runTransaction(async (transaction) => {
    transaction.update(startupRef, {valorToken: NOVO_VALOR});
    transaction.set(historicoRef, {
      valorToken: NOVO_VALOR,
      data: Timestamp.now(),
    });
  });

  console.log(`✓ ${STARTUP_ID} atualizado para R$ ${NOVO_VALOR}`);
  process.exit(0);
}

atualizarToken().catch((err) => {
  console.error("Erro:", err);
  process.exit(1);
});