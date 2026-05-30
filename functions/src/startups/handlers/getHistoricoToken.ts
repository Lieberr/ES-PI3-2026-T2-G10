// Feito por Leonardo Dionel RA: 25010092

import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {Timestamp} from "firebase-admin/firestore";
import {HistoricoPrecos}
  from "../types/startup";
import {buscarStartupsPorId}
  from "../repositories/startupRepository";
import {db} from "../../shared/firebase";

export const getHistoricoToken = onCall(
    async (request:CallableRequest<{startupId: string}>) => {
        const uid = request.auth?.uid;
        if(!uid) {
            throw new HttpsError(
                "not-found",
                "Usuário não encontrado."
            );
        }

        const {startupId} = request.data;

        if(!startupId) {
            throw new HttpsError(
                "invalid-argument",
                "StartupId é obrigatoria"
            );
        }

        const startup = await buscarStartupsPorId(startupId);
        if(!startup) {
            throw new HttpsError(
                "not-found",
                "Startup não encontrada."
            );
        }
        
        const agora = new Date();

        const inicioDiario = new Date(agora);
        inicioDiario.setDate(agora.getDate() - 1);

        const inicioSemanal = new Date(agora);
        inicioSemanal.setDate(agora.getDate() - 7);

        const inicioMensal = new Date(agora);
        inicioMensal.setDate(agora.getDate() - 30);

        const inicioSeisMeses = new Date(agora);
        inicioSeisMeses.setDate(agora.getDate() - 180);
    
        const inicioYTD = new Date(agora.getFullYear(), 0, 1);

        const historico = db.collection("startups")
        .doc(startupId).collection("historicoPrecos");

        const [snapDiario, snapSemanal, snapMensal, snapSeisMeses, snapYTD] = 
        await Promise.all([
            historico
            .where("data", ">=", Timestamp.fromDate(inicioDiario))
            .orderBy("data", "asc")
            .get(),
            historico
            .where("data", ">=", Timestamp.fromDate(inicioSemanal))
            .orderBy("data", "asc")
            .get(),
            historico
            .where("data", ">=", Timestamp.fromDate(inicioMensal))
            .orderBy("date", "asc")
            .get(),
            historico
            .where("data", ">=", Timestamp.fromDate(inicioSeisMeses))
            .orderBy("data", "asc")
            .get(),
            historico
            .where("data", ">=", Timestamp.fromDate(inicioYTD))
            .orderBy("data", "asc")
            .get(),
        ]);
        const calcularVariacao = (
            snap: FirebaseFirestore.QuerySnapshot
        ): number => {
            const registros = snap.docs.map(
                (doc) => doc.data() as HistoricoPrecos
            );
            if(registros.length === 0) return 0;

            const precoInicial = registros[0].valorToken;
            const precoFinal = registros[registros.length - 1].valorToken;

            return ((precoFinal - precoInicial) / precoInicial) * 100
        };

        const registrosTodos = snapSeisMeses.docs.map((doc) =>{
            const d = doc.data() as HistoricoPrecos;
            return {
                valorToken: d.valorToken,
                data: (d.data as Timestamp).toDate().toISOString(),
            };
        });

        return {
            precoAtual: startup.valorToken,
            variacoes: {
                diario: calcularVariacao(snapDiario),
                semanal: calcularVariacao(snapSemanal),
                mensal: calcularVariacao(snapMensal),
                semestral: calcularVariacao(snapSeisMeses),
                ytd: calcularVariacao(snapYTD),
            },
            historicoGrafico: registrosTodos,
        };
    }
);
