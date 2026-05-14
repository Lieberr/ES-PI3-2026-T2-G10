import { Request, Response } from "express";
import { db } from "../firebase/firebase";

export async function register(req: Request, res: Response) {

  try {

    const {
      nome,
      email,
      cpf,
      telefone,
      senha
    } = req.body;

    // validação básica
    if (!nome || !email || !cpf || !telefone || !senha) {
      return res.status(400).json({
        error: "Preencha todos os campos"
      });
    }

    // verificar email existente
    const emailSnapshot = await db
      .collection("usuarios")
      .where("email", "==", email)
      .get();

    if (!emailSnapshot.empty) {
      return res.status(400).json({
        error: "E-mail já cadastrado"
      });
    }

    // verificar cpf existente
    const cpfSnapshot = await db
      .collection("usuarios")
      .where("cpf", "==", cpf)
      .get();

    if (!cpfSnapshot.empty) {
      return res.status(400).json({
        error: "CPF já cadastrado"
      });
    }

    // criar usuário
    const user = await db.collection("usuarios").add({
      nome,
      email,
      cpf,
      telefone,
      senha,
      saldo: 10000,
      createdAt: new Date()
    });

    return res.status(201).json({
      message: "Usuário criado",
      id: user.id
    });

  } catch (error) {

    return res.status(500).json({
      error: "Erro interno"
    });

  }
}