// Feito por Leonardo Dionel RA: 25010092
import {initializeApp, cert} from "firebase-admin/app";
import {readFileSync} from "fs";

const serviceAccount = JSON.parse(
  readFileSync("./../servicesAccountKey.json", "utf8")
);

initializeApp({credential: cert(serviceAccount)});


import {Startup} from "../startups/types/startup";
import {db} from "../shared/firebase";

const startups: Startup[] = [
  {
    id: "ST001",
    nome: "AgroPulse",
    descricao: "Startup de agricultura inteligente que usa sensores IoT " +
      "e análise preditiva para otimizar irrigação, fertilização e " +
      "produtividade em pequenas e médias propriedades rurais.",
    estagio: "Em operação",
    setor: "Agrotech",
    capitalAportado: 850000,
    tokensEmitidos: 850000,
    tokensDisponiveis: 850000,
    valorToken: 6.50,
    videoDemo: "https://agropulse/demo",
    status: "Ativa",
    socios: [
      {nome: "Marina Costa", percentual: 40},
      {nome: "Hugo Souza", percentual: 35},
      {nome: "Gustavo Lima", percentual: 25},
    ],
    mentores: ["Ana Ribeiro", "Carlos Miguel"],
  },
  {
    id: "ST002",
    nome: "MedLink AI",
    descricao: "Plataforma de saúde digital que conecta pacientes, " +
      "clínicas e especialistas com triagem automatizada, agendamento " +
      "inteligente e prontuário assistido por inteligência artificial.",
    estagio: "Em operação",
    setor: "Healthtech",
    capitalAportado: 1200000,
    tokensEmitidos: 1200000,
    tokensDisponiveis: 1200000,
    valorToken: 10.00,
    videoDemo: "https://medlinkai/demo",
    status: "Ativa",
    socios: [
      {nome: "Juliana Freitas", percentual: 55},
      {nome: "Bruno Castro", percentual: 45},
    ],
    mentores: ["Dr. Renato Silva", "Patrícia Nunes"],
  },
  {
    id: "ST003",
    nome: "EcoChain",
    descricao: "Solução para rastreabilidade sustentável em cadeias " +
      "produtivas, registrando origem de insumos, emissões e " +
      "certificações em infraestrutura baseada em blockchain.",
    estagio: "Em expansão",
    setor: "Greentech",
    capitalAportado: 2500000,
    tokensEmitidos: 2500000,
    tokensDisponiveis: 2500000,
    valorToken: 8.00,
    videoDemo: "https://ecochain/demo",
    status: "Ativa",
    socios: [
      {nome: "Lucas Ferreira", percentual: 40},
      {nome: "Beatriz Souza", percentual: 30},
      {nome: "Rafael Ribeiro", percentual: 30},
    ],
    mentores: ["Fernanda Albuquerque", "Marcelo Silva"],
  },
  {
    id: "ST004",
    nome: "SkillBridge",
    descricao: "Plataforma educacional com trilhas de aprendizagem, " +
      "desafios práticos e mentorias para desenvolver competências " +
      "técnicas e comportamentais voltadas ao mercado de trabalho.",
    estagio: "Em operação",
    setor: "Edtech",
    capitalAportado: 980000,
    tokensEmitidos: 980000,
    tokensDisponiveis: 980000,
    valorToken: 7.00,
    videoDemo: "https://skillbridge/demo",
    status: "Ativa",
    socios: [
      {nome: "Camila Duarte", percentual: 60},
      {nome: "Gustavo Henrique", percentual: 40},
    ],
    mentores: ["Helena Costa", "Prof. André Vieira"],
  },
  {
    id: "ST005",
    nome: "FinGuard",
    descricao: "Plataforma de gestão financeira e prevenção a fraudes " +
      "para micro e pequenas empresas, com alertas em tempo real, " +
      "scoring de risco e conciliação bancária automatizada.",
    estagio: "Em expansão",
    setor: "Fintech",
    capitalAportado: 3100000,
    tokensEmitidos: 3100000,
    tokensDisponiveis: 3100000,
    valorToken: 5.80,
    videoDemo: "https://youtu.be/finguard_demo",
    status: "Ativa",
    socios: [
      {nome: "Thiago Alves", percentual: 45},
      {nome: "Renata Moraes", percentual: 30},
      {nome: "Diego Santos", percentual: 25},
    ],
    mentores: ["Sérgio Oliveira", "Livia Campos"],
  },
];


/**
 * Cria a seed das startups
 * @return {Promise<void>}
 */
async function seedStartups(): Promise<void> {
  console.log("Iniciando seed de startups...");
  for (const startup of startups) {
    await db.collection("startups").doc(startup.id).set(startup);
    console.log(`${startup.nome} salva.`);
  }
  console.log("Seed concluído! Todas as startups foram salvas.");
  process.exit(0);
}
seedStartups().catch((err) => {
  console.error("Erro no seed:", err);
  process.exit(1);
});

