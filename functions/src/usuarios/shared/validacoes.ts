/**
 * @author Leonardo Dionel
 * @ra 25010092
 *
 * Funções de validação de dados do usuário.
 * Não acessa o Firestore — só valida o formato dos campos.
 */

/**
 * Valida CPF usando o algoritmo oficial dos dois dígitos verificadores.
 * Aceita CPF com ou sem formatação (ex: "123.456.789-09" ou "12345678909").
 */
export function validarCPF(cpf: string): boolean {
  const limpo = cpf.replace(/\D/g, "");

  if (limpo.length !== 11) return false;

  // Rejeita sequências repetidas (ex: 111.111.111-11)
  if (/^(\d)\1+$/.test(limpo)) return false;

  // Primeiro dígito verificador
  let soma = 0;
  for (let i = 0; i < 9; i++) soma += parseInt(limpo[i]) * (10 - i);
  let resto = (soma * 10) % 11;
  if (resto === 10 || resto === 11) resto = 0;
  if (resto !== parseInt(limpo[9])) return false;

  // Segundo dígito verificador
  soma = 0;
  for (let i = 0; i < 10; i++) soma += parseInt(limpo[i]) * (11 - i);
  resto = (soma * 10) % 11;
  if (resto === 10 || resto === 11) resto = 0;

  return resto === parseInt(limpo[10]);
}

/**
 * Valida telefone celular brasileiro.
 * Aceita com ou sem formatação.
 * Celular: 11 dígitos (com DDD). Fixo: 10 dígitos.
 */
export function validarTelefone(telefone: string): boolean {
  const limpo = telefone.replace(/\D/g, "");
  return limpo.length === 10 || limpo.length === 11;
}

/**
 * Valida se todos os campos obrigatórios do cadastro estão presentes.
 * Retorna lista de campos faltando (vazia se OK).
 */
export function validarCamposObrigatorios(dados: Record<string, unknown>): string[] {
  const obrigatorios = ["nomeCompleto", "email", "cpf", "telefone", "senha"];
  return obrigatorios.filter((campo) => !dados[campo]);
}
