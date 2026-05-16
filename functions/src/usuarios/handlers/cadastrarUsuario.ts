// Feito por Leonardo Dionel RA: 25010092

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { CadastrarUsuarioInput } from "../types/usuario";
import { salvarUsuario, buscarUsuarioPorCpf } from "../repositories/usuarioRepository";
import { validarCPF, validarTelefone, validarCamposObrigatorios } from "../shared/validacoes";

export const cadastrarUsuario = functions.https.onCall(
  async (request: functions.https.CallableRequest<CadastrarUsuarioInput>) => {
    const data = request.data;

    // 1. Verificar campos obrigatórios
    const faltando = validarCamposObrigatorios(data as unknown as Record<string, unknown>);
    if (faltando.length > 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        `Campos obrigatórios ausentes: ${faltando.join(", ")}`
      );
    }

    const { nomeCompleto, email, cpf, telefone, senha } = data;

    // 2. Validar formato do CPF
    if (!validarCPF(cpf)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "CPF inválido."
      );
    }

    // 3. Validar formato do telefone
    if (!validarTelefone(telefone)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Telefone inválido. Informe com DDD (10 ou 11 dígitos)."
      );
    }

    // 4. Verificar se CPF já está cadastrado
    const cpfLimpo = cpf.replace(/\D/g, "");
    const usuarioExistente = await buscarUsuarioPorCpf(cpfLimpo);
    if (usuarioExistente) {
      throw new functions.https.HttpsError(
        "already-exists",
        "CPF já cadastrado na plataforma."
      );
    }

    // 5. Criar usuário no Firebase Auth
    let userRecord: admin.auth.UserRecord;
    try {
      userRecord = await admin.auth().createUser({
        email,
        password: senha,
        displayName: nomeCompleto,
      });
    } catch (error: unknown) {
      const firebaseError = error as { code?: string };
      if (firebaseError.code === "auth/email-already-exists") {
        throw new functions.https.HttpsError(
          "already-exists",
          "Email já cadastrado na plataforma."
        );
      }
      if (firebaseError.code === "auth/invalid-email") {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Formato de email inválido."
        );
      }
      if (firebaseError.code === "auth/weak-password") {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Senha fraca. Use no mínimo 6 caracteres."
        );
      }
      throw new functions.https.HttpsError(
        "internal",
        "Erro ao criar conta. Tente novamente."
      );
    }

    // 6. Salvar dados complementares no Firestore
    await salvarUsuario({
      uid: userRecord.uid,
      nomeCompleto,
      email,
      cpf: cpfLimpo,
      telefone: telefone.replace(/\D/g, ""),
      criadoEm: admin.firestore.Timestamp.now(),
    });

    // 7. Retornar resposta de sucesso ao Flutter
    return {
      uid: userRecord.uid,
      mensagem: "Usuário cadastrado com sucesso.",
    };
  }
);