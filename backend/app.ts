<<<<<<< Updated upstream
=======
import 'dotenv/config'
import express from 'express'
import cors from 'cors'

// import { authRoutes } from './src/routes/authRoutes'
import { ok } from 'node:assert'
import { Timestamp } from 'firebase-admin/firestore'
import { error } from 'node:console'

const app = express()

app.use(cors())
app.use(express.json())

app.get('/health', (_req, res) => {
    res.json({status: ok, Timestamp: new Date().toISOString() })
}) 

// app.use('/auth', authRoutes)

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) =>{
    console.error('erro não tratado:', err.message);
    res.status(500).json({ error: 'Erro interno do servidor'})
})

const PORT = process.env.PORT || 3000
app.listen(PORT, () => 
    console.log(`Servidor rodando na porta ${PORT}`)
)
>>>>>>> Stashed changes
