import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";

export const venderTokenSecundario = onCall(
  async (request: CallableRequest<{startupId: string, quantidade: number}>) => {
    const data = request.data;
    if (data.quantidade <= 0) {
      throw new HttpsError("invalid-argument", "Quantidade invalida.");
    }
  }
);
