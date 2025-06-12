--Lista de Exercícios – Seções 15 a 18
--Tema: Sequências, Views, Privilégios, e Expressões Regulares
--Contexto: Sistema de Agência Bancária

--🔹 Seção 15 – Uso de Sequências
--Crie uma sequência chamada seq_movimento iniciando em 100 e com incremento de 10.
--Utilize essa sequência futuramente para alimentar a chave primária de uma tabela de movimentações de conta.

--Crie uma tabela movimento_conta com os seguintes campos:
--movimento_id (gerado pela sequência seq_movimento)
--conta_numero
--tipo ('D' para débito, 'C' para crédito)
--valor
--data_movimento

--Insira três movimentações na tabela movimento_conta utilizando NEXTVAL da sequência criada.

--🔹 Seção 16 – Criação e Uso de Views
--Crie uma VIEW chamada vw_contas_clientes que contenha:

--nome do cliente
--número da conta
--saldo
--código da agência

--Crie uma VIEW chamada vw_emprestimos_grandes contendo número do empréstimo, nome do cliente e valor, apenas para empréstimos com valor superior a R$ 20.000.

--Tente realizar um UPDATE na vw_emprestimos_grandes alterando o valor de um empréstimo. O que acontece? Explique.

--🔹 Seção 17 – Privilégios e Roles
--Crie uma ROLE chamada atendente_agencia com os seguintes privilégios:

--SELECT nas tabelas cliente e conta

--UPDATE na coluna endereco da tabela cliente

--Conceda a role atendente_agencia ao usuário carla.

--Revogue da role atendente_agencia o privilégio de UPDATE na tabela cliente.

--Crie um usuário auditor e conceda a ele apenas permissão para consultar todas as views existentes no banco.

--🔹 Seção 18 – Expressões Regulares (REGEXP)
--Liste os clientes cujo nome começa com a letra "M" e termina com "a".
--(Dica: use REGEXP_LIKE com padrão ^M.*a$)

--Exiba o CPF dos clientes com os 6 primeiros dígitos mascarados com asteriscos.
--(Dica: use REGEXP_REPLACE)

--Extraia o domínio do e-mail dos clientes (ex: gmail.com, outlook.com).
--(Dica: use REGEXP_SUBSTR)

--Liste os nomes dos clientes que possuem dois ou mais nomes (ou seja, contém espaço entre os nomes).

--Selecione os clientes cujo e-mail termina com '.br'.


-- Seção 15 – Sequências

-- 1
CREATE SEQUENCE seq_movimento START WITH 100 INCREMENT BY 10;

-- 2
CREATE TABLE movimento_conta (
    movimento_id NUMBER PRIMARY KEY,
    conta_numero NUMBER,
    tipo CHAR(1),
    valor NUMBER(10,2),
    data_movimento DATE
);

-- 3
INSERT INTO movimento_conta VALUES (seq_movimento.NEXTVAL, 101, 'C', 1500.00, SYSDATE);
INSERT INTO movimento_conta VALUES (seq_movimento.NEXTVAL, 102, 'D', 500.00, SYSDATE);
INSERT INTO movimento_conta VALUES (seq_movimento.NEXTVAL, 103, 'C', 200.00, SYSDATE);

-- Seção 16 – Views

-- 4
CREATE OR REPLACE VIEW vw_contas_clientes AS
SELECT c.cliente_nome, ct.conta_numero, ct.saldo, ct.agencia_cod
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cod;

-- 5
CREATE OR REPLACE VIEW vw_emprestimos_grandes AS
SELECT e.emprestimo_numero, c.cliente_nome, e.valor
FROM emprestimo e
JOIN cliente c ON e.cliente_cod = c.cliente_cod
WHERE e.valor > 20000;

-- 6
-- UPDATE vw_emprestimos_grandes SET valor = 25000 WHERE emprestimo_numero = 301;
-- ERRO: A view contém JOIN e WHERE que impedem atualização direta.

-- Seção 17 – Privilégios e Roles

-- 7
CREATE ROLE atendente_agencia;
GRANT SELECT ON cliente TO atendente_agencia;
GRANT SELECT ON conta TO atendente_agencia;
GRANT UPDATE (endereco) ON cliente TO atendente_agencia;

-- 8
GRANT atendente_agencia TO carla;

-- 9
REVOKE UPDATE ON cliente FROM atendente_agencia;

-- 10
CREATE USER auditor IDENTIFIED BY senha_auditor;
GRANT CREATE SESSION TO auditor;
GRANT SELECT ANY table TO auditor;

-- Seção 18 – Expressões Regulares

-- 11
SELECT * FROM cliente
WHERE REGEXP_LIKE(cliente_nome, '^M.*a$', 'i');

-- 12
SELECT cliente_nome,
       REGEXP_REPLACE(cpf, '^[0-9]{3}\.?[0-9]{3}', '***.***') AS cpf_mascarado
FROM cliente;

-- 13
SELECT cliente_nome,
       REGEXP_SUBSTR(email, '@(.+)', 1, 1, NULL, 1) AS dominio
FROM cliente;

-- 14
SELECT cliente_nome FROM cliente
WHERE REGEXP_LIKE(cliente_nome, ' ');

-- 15
SELECT * FROM cliente
WHERE REGEXP_LIKE(email, '\.br$', 'i');
