// Feito por Leonardo Dionel RA: 25010092

// Funções de validação de dados de cadastro de usuário.

/**
 * Verifica se o CPF tem 11 dígitos numéricos.
 * Aceita CPF com ou sem formatação (ex: 123.456.789-09).
 * @param {string} cpf - CPF a ser validado.
 * @return {boolean} true se válido, false caso contrário.
 */
export function validarCPF(cpf: string): boolean {
  const limpo = cpf.replace(/\D/g, "");
  return limpo.length === 11;
}

/**
 * Verifica se o telefone tem 10 ou 11 dígitos (com DDD).
 * Aceita com ou sem formatação (ex: (19) 99999-9999).
 * @param {string} telefone - Telefone a ser validado.
 * @return {boolean} true se válido, false caso contrário.
 */
export function validarTelefone(telefone: string): boolean {
  const limpo = telefone.replace(/\D/g, "");
  return limpo.length === 10 || limpo.length === 11;
}

/**
 * Verifica se todos os campos obrigatórios do cadastro estão presentes.
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
