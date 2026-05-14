// src/schemas/userSchema.ts
import { z } from 'zod'

export const UserSchema = z.object({
  nome:         z.string().min(3, 'Nome deve ter ao menos 3 caracteres'),
  email:        z.email('E-mail inválido'),
  cpf:          z.string().length(11, 'CPF deve ter 11 dígitos').regex(/^\d+$/, 'CPF deve conter apenas números'),
  telefone:     z.string().min(10, 'Telefone inválido'),
  senha:        z.string().min(6, 'Senha deve ter ao menos 6 caracteres'),
})

export type Usuario = z.infer<typeof UserSchema>