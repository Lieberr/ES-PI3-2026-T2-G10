import * as functions from "firebase-functions";

import express, {
  Request,
  Response
} from "express";

import authRoutes from "./routes/authRoutes";

const app = express();

app.use(express.json());

app.get("/", (req: Request, res: Response) => {
  res.send("API MesclaInvest");
});

app.use("/auth", authRoutes);

export const api = functions.https.onRequest(app);