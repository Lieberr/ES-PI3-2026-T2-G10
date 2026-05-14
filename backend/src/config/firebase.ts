<<<<<<< Updated upstream
=======
import * as admin from "firebase-admin";
import * as serviceAccount from "../../../servicesAccountKey.json";

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount as admin.ServiceAccount)
})

export const db = admin.firestore()
export const auth = admin.auth()
export const { FieldValue } = admin.firestore
>>>>>>> Stashed changes
