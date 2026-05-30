// Feito por Leonardo Dionel RA: 25010092

import {initializeApp, cert} from "firebase-admin/app";
import {readFileSync} from "fs";

const serviceAccount = JSON.parse(
  readFileSync("./../servicesAccountKey.json", "utf8")
);

initializeApp({credential: cert(serviceAccount)});

import {Timestamp} from "firebase-admin/firestore";
import {db} from "../shared/firebase";

/**
 * Gera histórico de preços simulado para todas as startups.
 * 60 registros por startup com intervalo de 3 dias (~180 dias).
 * Variação de ±2% a cada registro, ancorado no preço atual.
 * @return {Promise<void>}
 */
async function seedHistoricoPrecos(): Promise<void> {
  console.log("Buscando startups...");

  const snap = await db.collection("startups").get();
  if (snap.empty) {
    console.log(
      "Nenhuma startup encontrada. Rode o seed de startups primeiro.");
    process.exit(1);
  }

  for (const doc of snap.docs) {
    const startup = doc.data();
    const startupId = doc.id;

    // Verifica se já existe histórico para não duplicar
    const existente = await db
      .collection("startups")
      .doc(startupId)
      .collection("historicoPrecos")
      .limit(1)
      .get();

    if (!existente.empty) {
      console.log(`${startup.nome} já possui histórico. Pulando...`);
      continue;
    }

    console.log(`Gerando histórico para ${startup.nome}...`);

    const agora = new Date();
    const batch = db.batch();
    let preco = startup.valorToken;

    // Gera de trás para frente — ancora no preço atual
    for (let i = 60; i >= 0; i--) {
      const data = new Date(agora);
      data.setDate(agora.getDate() - i * 3);

      if (i === 0) {
        // Último ponto é sempre o preço atual exato da startup
        const docRef = db
          .collection("startups")
          .doc(startupId)
          .collection("historicoPrecos")
          .doc();
        batch.set(docRef, {
          valorToken: startup.valorToken,
          data: Timestamp.fromDate(data),
        });
      } else {
        // Variação aleatória de ±2% a cada 3 dias
        const variacao = (Math.random() * 4) - 2;
        preco = preco * (1 - variacao / 100);

        // Garante que o preço não vai para zero ou negativo
        if (preco <= 0) preco = 0.01;

        const docRef = db
          .collection("startups")
          .doc(startupId)
          .collection("historicoPrecos")
          .doc();
        batch.set(docRef, {
          valorToken: parseFloat(preco.toFixed(2)),
          data: Timestamp.fromDate(data),
        });
      }
    }

    await batch.commit();
    console.log(`✓ ${startup.nome} — 61 registros salvos.`);
  }

  console.log("Seed de histórico concluído!");
  process.exit(0);
}

seedHistoricoPrecos().catch((err) => {
  console.error("Erro no seed:", err);
  process.exit(1);
});
