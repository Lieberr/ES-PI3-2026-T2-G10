// Feito por Gustavo lieb Ra: 24023376

import { CallableContext, HttpsError, onCall } from "firebase-functions/v1/https";
import { db } from "../../shared/firebase";
import { CallableRequest } from "firebase-functions/https";

export const getHistoricoSaldo = onCall(
    async (request: CallableRequest<Record<string, never>>) => {
    
        const uid = request.auth?.uid;
        if(!uid) {
            throw new HttpsError(
                "unauthenticated",
                "Usuário não autenticado."
            )
        }

        const snap = await db
                .collection("carteiras")
                .doc(uid)
                .collection("operacoes")
                .orderBy("realizadosEm", "asc")
                .get();
        
        if (snap.empty) {
            return {pontos: []};
        }

        let saldoAcumulado = 0
        const pontos: {label: string; saldo: number}[] = [];

        snap.docs.forEach((doc) => {
            const op = doc.data();
            if(op.tipo === "deposito") {
                saldoAcumulado += op.valor;
            } else if(op.tipo === "saque") {
                saldoAcumulado -= op.valor;
            }

            const data = op.realizadosEm.toDate();
            const label = `${data.getDate()}/${data.getMonth() + 1}`;

            pontos.push({label, saldo: saldoAcumulado});
        });

        return {pontos};

    }

);