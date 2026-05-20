// Feito por Leonardo Dionel RA: 25010092

import {onCall, CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {Timestamp} from "firebase-admin/firestore";
import {CadastrarUsuarioInput} from "../types/usuario";
import {
  salvarUsuario,
  buscarUsuarioPorCpf,
} from "../repositories/usuarioRepository";
import {
  validarCPF,
  validarTelefone,
  validarCamposObrigatorios,
} from "../shared/validacoes";
import {auth} from "../../shared/firebase";
import {criarCarteira} from "../../carteira/repositories/carteiraRepository";

export const cadastrarUsuario = onCall(
  async (request: CallableRequest<CadastrarUsuarioInput>) => {
    const data = request.data;

    // verifica se todos os campos chegaram
    const faltando = validarCamposObrigatorios(
      data as unknown as Record<string, unknown>
    );
    if (faltando.length > 0) {
      throw new HttpsError(
        "invalid-argument",
        `Campos obrigatórios ausentes: ${faltando.join(", ")}`
      );
    }

    const {nomeCompleto, email, cpf, telefone, senha} = data;

    // valida CPF e telefone
    if (!validarCPF(cpf)) {
      throw new HttpsError("invalid-argument", "CPF inválido.");
    }

    if (!validarTelefone(telefone)) {
      throw new HttpsError(
        "invalid-argument",
        "Telefone inválido. Informe com DDD (10 ou 11 dígitos)."
      );
    }

    // checa se o CPF já está cadastrado
    const cpfLimpo = cpf.replace(/\D/g, "");
    const usuarioExistente = await buscarUsuarioPorCpf(cpfLimpo);
    if (usuarioExistente) {
      throw new HttpsError(
        "already-exists",
        "CPF já cadastrado na plataforma."
      );
    }

    // cria o usuário no Firebase Auth
    let userRecord;
    try {
      userRecord = await auth.createUser({
        email,
        password: senha,
        displayName: nomeCompleto,
      });
    } catch (error: unknown) {
      const err = error as {code?: string};
      if (err.code === "auth/email-already-exists") {
        throw new HttpsError(
          "already-exists",
          "Email já cadastrado na plataforma."
        );
      }
      if (err.code === "auth/invalid-email") {
        throw new HttpsError("invalid-argument", "Formato de email inválido.");
      }
      if (err.code === "auth/weak-password") {
        throw new HttpsError(
          "invalid-argument",
          "Senha fraca. Use no mínimo 6 caracteres."
        );
      }
      throw new HttpsError("internal", "Erro ao criar conta. Tente novamente.");
    }

    // salva os dados extras no Firestore
    // se falhar, deleta o usuário do Auth para não deixar conta pela metade
    try {
      await salvarUsuario({
        uid: userRecord.uid,
        nomeCompleto,
        email,
        cpf: cpfLimpo,
        telefone: telefone.replace(/\D/g, ""),
        criadoEm: Timestamp.now(),
      });

      await criarCarteira(userRecord.uid);
    } catch (error) {
      await auth.deleteUser(userRecord.uid);
      throw new HttpsError(
        "internal",
        "Erro ao salvar dados. Tente novamente."
      );
    }

    return {
      uid: userRecord.uid,
      mensagem: "Usuário cadastrado com sucesso.",
    };
  }
);
