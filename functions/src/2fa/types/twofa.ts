import {Timestamp} from "firebase-admin/firestore";

export interface TwoFaRecord {
    codeHash: string;
    expiresAt: Timestamp;
    attempts: number;
    createdAt: Timestamp;
}
