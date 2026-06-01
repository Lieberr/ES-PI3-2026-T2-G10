// Feito por Gustavo Lieb RA: 24023376


import {Timestamp} from "firebase-admin/firestore";

export interface TwoFaRecord {
    codeHash: string;
    expiresAt: Timestamp;
    attempts: number;
    createdAt: Timestamp;
}
