// Feito por Gustavo Lieb Ra: 24023376

import { onCall } from "firebase-functions/https";
import { listarStartups } from "../repositories/startupsRepository";

export const listarStartupsHandler = onCall(async () => {
    const startups = await listarStartups();

    return {startups};
    
})