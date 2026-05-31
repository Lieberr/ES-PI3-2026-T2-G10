// Feito por Gustavo lieb Ra: 24023376

import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import {db} from "../../shared/firebase";

export const getHistoricoSaldo = onCall(
    async (request: CallableRequest<Record<string, never>>) => {
    
        const uid = request.auth?.uid;
        if(!uid) {
            throw new HttpsError(
                "unauthenticated",
                "Usuário não autenticado."
            )
        }

        const snapMovimentacoes = await db
                .collection("carteiras")
                .doc(uid)
                .collection("movimentacoes")
                .orderBy("realizadoEm", "asc")
                .get();
        
                
        const snapOperacoes = await db
                .collection("carteiras")
                .doc(uid)
                .collection("operacoes")
                .orderBy("realizadoEm", 'asc')
                .get();
        
        const todasOps = [
            ...snapMovimentacoes.docs.map((doc) => doc.data()),
            ...snapOperacoes.docs.map((doc) => doc.data()),
            ].sort((a, b) => a.realizadoEm.toMillis() - b.realizadoEm.toMillis());
        
        if (todasOps.length === 0) {
            return {pontos: []};
        }

        let saldoAcumulado = 0
        const pontos: {label: string; saldo: number}[] = [];

        todasOps.forEach((op) => {
            
            if(op.tipo === "deposito") {
                saldoAcumulado += op.valor;
            } else if(op.tipo === "saque") {
                saldoAcumulado -= op.valor;
            }

            const data = op.realizadoEm.toDate();
            const label = `${data.getDate()}/${data.getMonth() + 1}`;

            pontos.push({label, saldo: saldoAcumulado});
        });

        return {pontos};

    }

);