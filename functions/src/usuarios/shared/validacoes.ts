// Feito por Leonardo Dionel RA: 25010092

/**
 * Valida CPF usando o algoritmo dos dois dígitos verificadores.
 * Aceita CPF com ou sem formatação.
 * @param {string} cpf - CPF a ser validado.
 * @return {boolean} true se válido, false caso contrário.
 */
export function validarCPF(cpf: string): boolean {
  const limpo = cpf.replace(/\D/g, "");

  if (limpo.length !== 11) return false;

  if (/^(\d)\1+$/.test(limpo)) return false;

  let soma = 0;
  for (let i = 0; i < 9; i++) soma += parseInt(limpo[i]) * (10 - i);
  let resto = (soma * 10) % 11;
  if (resto === 10 || resto === 11) resto = 0;
  if (resto !== parseInt(limpo[9])) return false;

  soma = 0;
  for (let i = 0; i < 10; i++) soma += parseInt(limpo[i]) * (11 - i);
  resto = (soma * 10) % 11;
  if (resto === 10 || resto === 11) resto = 0;

  return resto === parseInt(limpo[10]);
}

/**
 * Valida telefone celular brasileiro com DDD.
 * Aceita com ou sem formatação. Celular: 11 dígitos. Fixo: 10.
 * @param {string} telefone - Telefone a ser validado.
 * @return {boolean} true se válido, false caso contrário.
 */
export function validarTelefone(telefone: string): boolean {
  const limpo = telefone.replace(/\D/g, "");
  return limpo.length === 10 || limpo.length === 11;
}

/**
 * Valida se todos os campos obrigatórios do cadastro estão presentes.
 * @param {Record<string, unknown>} dados - Objeto com os dados recebidos.
 * @return {string[]} Lista de campos ausentes (vazia se todos presentes).
 */
export function validarCamposObrigatorios(
  dados: Record<string, unknown>
): string[] {
  const obrigatorios = [
    "nomeCompleto",
    "email",
    "cpf",
    "telefone",
    "senha",
  ];
  return obrigatorios.filter((campo) => !dados[campo]);
}
