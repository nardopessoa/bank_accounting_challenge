# Bank Accounting - Challenge

Para o funcionamento deste sistema, assume-se que neste ponto estejam instalados na máquina:

- Erlang 21 ou superior
- Elixir 1.8 ou superior
- um banco de dados PostgreSQL 10 ou superior esteja acessível

Para iniciar o servidor Phoenix:

- Instale as dependencias com `mix deps.get`
- Crie a estrutura do seu banco de dados com `mix ecto.setup`
  - Os dados para acesso ao banco de dados encontram-se em `config/dev.exs` para ambiente de **development**. Altere os valores conforme a necessidade:

```elixir
config :bank_accounting, BankAccounting.Repo,
  username: "postgres",
  password: "123456",
  database: "bank_accounting_dev",
  hostname: "localhost"
```

- Inicie o servidor HTTP (Phoenix) com `mix phx.server`. A porta em ambiente **development** é a **4000**.

## Camada de Segurança (JWT)

Há uma camada de segurança que exige um token (JWT) para identificação do usuário logado.

Para cadastrar um novo usuário basta fazer uma requisição `POST` para a rota `http://localhost:4000/api/v1/sign_up` com as seguintes informações no corpo:

```json
{
  "user": {
    "username": "admin",
    "password": "admin",
    "password_confirmation": "admin"
  }
}
```

Caso o usuário já esteja cadastrado, basta executar uma requisição `POST` para a rota `http://localhost:4000/api/v1/sign_in` com as credenciais no corpo: `{ "username": "admin", "password": "admin" }`

A resposta das requisições acima retornará em seu corpo o token de acesso para as demais rotas do sistema: `{ "access_token": "$$JWT$$" }`

Basta utilizar o `access_token` retornado no cabeçalho `authorization` das novas requisições com o prefixo `bearer` para que o acesso seja garantido.

## Rotas do Sistema Bancário

O sistema possui funcionalidades que envolvem operações de inserção e consulta de contas bancárias (`accounts`) e de transferencia de dinheiro entre contas (`balance_movements`).

### Contas Bancárias (accounts)

#### Inserir Conta

Cria uma nova conta no sistema com o saldo (`balance`) informado no corpo

- **Verbo HTTP:** POST
- **Rota:** `http://localhost:4000/api/v1/accounts`
- **Cabeçalho** `Authorization: Bearer $$JWT$$`
- **Corpo:** `{ "account": { "balance": 1000.00 } }`

#### Listar Contas

Lista todas as contas cadastradas na base de dados do sistema

- **Verbo HTTP:** GET
- **Rota:** `http://localhost:4000/api/v1/accounts`
- **Cabeçalho** `Authorization: Bearer $$JWT$$`

#### Consultar Saldo

Consulta o saldo de uma conta a partir de seu identificador (`:account_id`). O identificador de uma conta é retornado após sua criação e na listagem de todas as contas descrita acima.

- **Verbo HTTP:** GET
- **Rota:** `http://localhost:4000/api/v1/accounts/:account_id`
- **Cabeçalho** `Authorization: Bearer $$JWT$$`

### Transferência de Dinheiro (balance_movements)

Realiza a transferência de saldo de uma conta para outra. Para isto, são necessários o identificador da conta origem (`source_account_id`), o identificador da conta destino (`destination_account_id`) e a quantidade de dinheiro a ser transferido (`amount`).

- **Verbo HTTP:** POST
- **Rota:** `http://localhost:4000/api/v1/balance_movements`
- **Cabeçalho** `Authorization: Bearer $$JWT$$`
- **Corpo:** `{ "balance_movement": { "source_account_id": 1, "destination_account_id": 2, "amount": 10.00 } }`

## Contribuindo

Para ajudar com novas funcionalidades ou correções de bugs:

1. **Fork** o repositório no GitHub
2. **Clone** o projeto para seu computador `$ git clone https://github.com/nardopessoa/bank_accounting_challenge.git`
3. Crie uma nova **Branch** `$ git checkout -b <nome-da-nova-branch>`
4. **Code** faça as mudanças necessárias
5. **Commit** mudanças em sua branch
6. **Push** seu trabalho para o fork
7. Crie um **Pull request** para que possa ser avaliado

Maiores detalhes dos passos acima disponíveis em [Primeiras Contribuições](https://github.com/firstcontributions/first-contributions)

Todas opiniões, sugestões e críticas são bem vindas!
