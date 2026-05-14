import { Request, Response } from 'express'
import { auth, db, FieldValue } from '../config/firebase'
import { UserSchema } from '../schemas/userSchema'
import { Timestamp } from 'firebase-admin/firestore';

// Registro do usuario
export async function register(req: Request , res: Response) {
    try {

        // Valida os dados recebidos
        const result = UserSchema.safeParse(req.body);
        
        if (!result.success) {

            return res.status(400).json({
            error:'Erro na validação'
        })
    }

    const { nome, email, cpf, telefone, senha } = result.data
    
    // Criar usuário no Firebase Auth (email + senha)
    const userRecord = await auth.createUser({
        email,
        password: senha,
        displayName: nome,
    })

    const uid = userRecord.uid
    
    const batch = db.batch();
    // Salvando informações de perfil e carteira no banco de dados

    batch.set(db.collection('usuarios').doc(uid), {
        nome,
        email,
        cpf,
        telefone,
        mfaHabilitado: false,
        criadoEm: FieldValue.serverTimestamp(),
        atualizadoEm: FieldValue.serverTimestamp(),
    })

    batch.set(db.collection('carteiras').doc(uid), {
        saldoReais: 0,
        tokens: {},
        atualizadoEm: FieldValue.serverTimestamp(),
    })

    await batch.commit()
    
    return res.status(201).json({
        message:'Usuario criado com sucesso:', uid
    })

  } catch (error: any) {
    if (error.code === 'auth/email-already-exists') {
        return res.status(409).json({ error: 'E-mail já cadastrado' })
    }
    console.error('Erro no register:', error)
    return res.status(500).json({ error: 'Erro ao criar conta' })
  }
}

