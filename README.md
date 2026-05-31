# ES-PI3-2026-T2-G10

Aplicativo mobile de investimentos desenvolvido em Flutter como parte do projeto Mescla. O app permite acompanhar investimentos, visualizar informações financeiras e explorar recursos voltados à organização e análise de aplicações.

## 🧑 Integrantes

- GUSTAVO LIEB FIGUEIRA
- LEONARDO DIONEL LIMA SILVA
- Luis Felipe Pontes Mita
- MATHEUS HENRIQUE PORTUGAL NARDUCCI
- YURI SOARES DA SILVA

## 🛠 Organização Inicial do Projeto

Para iniciar o desenvolvimento do aplicativo de investimentos do projeto **Mescla**, foram criadas as primeiras *issues* no repositório com o objetivo de organizar o trabalho da equipe, definir responsabilidades e estruturar o planejamento inicial do projeto.

A equipe é composta por **5 integrantes**, e o desenvolvimento foi dividido em três principais áreas:

- **Frontend** - Desenvolvimento da interface do aplicativo e experiência do usuário.
- **Backend** - Desenvolvimento da lógica de aplicação, APIs e regras de negócio.
- **Banco de Dados** - Modelagem, estrutura e gerenciamento de dados do sistema.

## 📊 Distribuição inicial de responsabilidades

| Integrante        | Área de Responsabilidade | Atividades |
|------------------|--------------------------|-------------|
| Gustavo Lieb     | Frontend                  | Desenvolvimento das telas principais e navegação do aplicativo |
| Luis Felipe      | Frontend / Banco de Dados | Componentes de interface, integração com APIs / Modelagem do banco de dados e estrutura das tabelas |
| Yuri Soares      | Backend                   | Desenvolvimento da API e regras de negócio |
| Matheus Henrique | Backend                   | Desenvolvimento de rotas e funções |
| Leonardo Dionel  | Integração / Backend      | Integração entre frontend, backend e banco de dados |

## 🧠 Mapa Mental MesclaInvest

![Mapa mental MesclaInvest Preview](.mescla_invest/img/Mapa_mental_MesclaInvest.png)

## 💻 Issues Iniciais do Projeto

### Issue #1 - Organização do Repositório
- Definir estrutura inicial do projeto Flutter
- Criar README
- Definir padrão de commits
- Organização das pastas do projeto

### Issue #2 - Planejamento das Funcionalidades
- Definir escopo inicial do aplicativo
- Listar funcionalidades principais do app de investimentos
- Criar backlog inicial do projeto

### Issue #3 - Definição de Arquitetura
- Definir a comunicação entre frontend e backend
- Escolher padrão de arquitetura
- Planejar estruturas de APIs

### Issue #4 - Modelagem do Banco de Dados
- Definir linguagem de Banco de Dados
- Definir entidades principais
- Criar modelo conceitual
- Estruturar tabelas e relacionamentos

### Issue #5 - Estrutura Inicial do Frontend
- Criar estrutura de telas no Flutter
- Definir navegação entre elas
- Criar layout inicial do aplicativo

### Issue #6 - Configuração do Backend
- Criar estrutura inicial do backend
- Definir endpoints principais da API
- Configurar ambiente de desenvolvimento

## 📱 Features Implementadas

### Sistema de Autenticação
- Tela para cadastro com nome completo, email, CPF, telefone, senha e confirmação de senha;
- Checagens de CPF e email para contas com dados iguais não serem cadastradas;
- Senha que exige: 8 caracteres, letra maiúscula e números;
- Login pedindo email e senha que, caso algum dado esteja errado, mostra um erro;
- Recuperação de senha via email;
- Login persistido localmente;
- Autenticação 2FA por email.

### Catálogo de Startups
- Lista de todas as startups com detalhes:
    - Nome e foto;
    - Breve descrição;
    - Estado (expansão ou operação);
    - Valor do token;
    - Capital aportado;
    - Tokens disponíveis;
    - Porcentagem de valorização.
- Sistema de filtragem por estado: Todas, Nova, Em expansão ou Em operação;

### Tela de Startup
- Três categorias para se visualizar:
- Visão geral:
    - Gráfico de valorização de token;
        - Filtragem por tempo (dia, semana, mês, semestre e ano).
    - Valor do token;
    - Capital aportado;
    - Negociação de tokens (compra ou venda com a própria startup);
    - Sumário executivo;
    - Melhor detalhamento dos tokens;
    - Lista de mentores.
- Estrutura:
    - Lista de sócios da startup com nome e participação societária.
- Perguntas:
    - Envio de perguntas para a startup;
    - Envio de perguntas privadas caso seja investidor;
    - Perguntas frequentes.

### Balcão de Tokens
- Lista com startups investidas e valor de seus tokens;
- Busca por nome startup;
- Ofertas de compra:
    - Quantidade de tokens requeridos;
    - Preço por token;
    - Valor total oferecido;
    - Nome do comprador.
- Ofertas de venda:
    - Quantidade de tokens oferecidos; 
    - Preço por token;
    - Valor total à dar;
    - Nome do vendedor.
- Método de criação de oferta tanto de venda quanto de compra;
- Visualização de suas ofertas abertas com todos os dados e maneira de cancelá-las;
- Histórico de compra e venda pelo balcão.

### Portfólio
- Valor total do portifólio com porcentagem de valorização;
- Gráfico de evolução com filtragem de tempo (dia, semana, mês, semestre ou ano);
- Lista de startups investidas e suas respectivas porcentagens de valorização e capital investido.

### Perfil
- Método para depositar e sacar, de maneira simulada;
- Histórico de depósitos e saques com data e hora;
- Método para alterar os dados pessoais da conta:
    - Nome completo, email e telefone;
    - CPF e senha são bloqueados por segurança.
- Configuração de 2FA;
- Opção de Logout.

### Banco de Dados
- Feito totalmente pelo Firebase;
- Coleções particulares para cada usuário:
    - Informações da conta;
    - Saldo de tokens e reais;
    - Histórico de compra e venda;
- Coleções particulares para cada startup:
    - Informações das startups;
    - Histórico de valorização dos tokens;
- Históricos de transações entre usuário/startup ou usuário/usuário;