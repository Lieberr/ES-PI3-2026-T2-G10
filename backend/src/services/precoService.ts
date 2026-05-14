import { Timestamp, Transaction } from 'firebase-admin/firestore'
import { db, FieldValue } from '../config/firebase'
import * as admin from 'firebase-admin'

export async function registrarPrecoNaTransacao(
    startup_id:string,
    preco:number,
    quantidade:number,
    t: admin.firestore.Transaction
) {
    

}