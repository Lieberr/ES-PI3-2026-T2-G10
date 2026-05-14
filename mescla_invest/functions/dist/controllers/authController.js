"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.register = register;
async function register(req, res) {
    try {
        const { nome, email, cpf, telefone, senha } = req.body;
        if (!nome || !email || !cpf || !telefone || !senha) {
            return res.status(400).json({
                error: 'Preencha todos os campos'
            });
        }
        return res.status(201).json({
            message: 'Usuário criado com sucesso'
        });
    }
    catch (error) {
        return res.status(500).json({
            error: 'Erro interno'
        });
    }
}
