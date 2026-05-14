import { Request, Response } from "express";
import { db, auth } from "../firebase/firebase";
import { Timestamp } from "firebase-admin/firestore";

export async function register(req: Request, res: Response) {
  try {
    const { nomeCompleto, email, cpf, telefone, senha } = req.body;

    if (!nomeCompleto || !email || !cpf || !telefone || !senha) {
      return res.status(400).json({ error: "Preencha todos os campos obrigatórios" });
    }

    const userAuth = await auth.createUser({
      email,
      password: senha,
      displayName: nomeCompleto,
      phoneNumber: telefone.startsWith('+') ? telefone : undefined // O Auth exige formato E.164 para telefone se for salvar lá
    });

    const novoUsuario = {
      nomeCompleto,
      email,
      CPF: cpf, // Exatamente como no seu exemplo
      telefone,
      uid: userAuth.uid,
      mfaHabilitado: false, // Padrão inicial
      criadoEm: Timestamp.now(),
      atualizadoEm: Timestamp.now(),
      saldo: 10000 // Mantendo o saldo inicial que você tinha definido
    };

    await db.collection("usuarios").doc(userAuth.uid).set(novoUsuario);

    return res.status(201).json({
      message: "Usuário cadastrado com sucesso",
      uid: userAuth.uid
    });

  } catch (error: any) {
    console.error("Erro no registro:", error);

    // Tratamento de erros específicos do Firebase
    if (error.code === 'auth/email-already-exists') {
      return res.status(400).json({ error: "Este e-mail já está cadastrado." });
    }
    if (error.code === 'auth/invalid-password') {
      return res.status(400).json({ error: "A senha deve ter pelo menos 6 caracteres." });
    }

    return res.status(500).json({ error: "Erro interno ao processar cadastro." });
  }
}
