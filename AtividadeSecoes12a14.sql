--------------------------------------------------------------------------------
-- 🔹 Seção 12 – Conversões Implícitas e Explícitas
--------------------------------------------------------------------------------

-- 1) Formate os saldos das contas com separador decimal vírgula
SELECT
  conta_numero,
  'R$ ' || TO_CHAR(saldo, 'FM999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.') AS saldo_formatado
FROM conta;

-- 2) Exiba a data atual formatada como 'dd/mm/yyyy'
SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS data_atual
FROM dual;

-- 3) Exiba nome do cliente e cidade, separados por hífen
SELECT cliente_nome || ' - ' || cidade AS nome_cidade
FROM cliente;

-- 4) Empréstimos acima de R$ 5000 com valor formatado
-- (coluna correta é QUANTIA)
SELECT
  emprestimo_numero,
  'R$ ' || TO_CHAR(quantia, 'FM999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.') AS valor_formatado
FROM emprestimo
WHERE quantia > 5000;


--------------------------------------------------------------------------------
-- 🔹 Seção 13 – Tipos de Dados Avançados
--------------------------------------------------------------------------------

-- 5) Adicionar coluna data_cadastro e atualizar com SYSTIMESTAMP
ALTER TABLE cliente ADD (data_cadastro TIMESTAMP);
UPDATE cliente SET data_cadastro = SYSTIMESTAMP;
COMMIT;

-- 6) Exibir o tempo em dias desde o cadastro
-- (TIMESTAMP -> DATE para subtração em dias)
SELECT
  cliente_nome,
  TRUNC(SYSDATE - CAST(data_cadastro AS DATE)) AS dias_desde_cadastro
FROM cliente;

-- 7) Adicionar coluna tempo_fidelidade com tipo INTERVAL
ALTER TABLE cliente ADD (tempo_fidelidade INTERVAL YEAR TO MONTH);

-- 8) Exibir data de renovação com 3 meses após o cadastro
SELECT
  cliente_nome,
  data_cadastro,
  data_cadastro + INTERVAL '3' MONTH AS renovacao
FROM cliente;


--------------------------------------------------------------------------------
-- 🔹 Seção 14 – Constraints (Restrições)
--------------------------------------------------------------------------------

-- 9) Criar a tabela cartao_credito (com constraints nomeadas)
-- (Se precisar recriar, descomente o bloco de DROP)
-- BEGIN
--   EXECUTE IMMEDIATE 'DROP TABLE cartao_credito CASCADE CONSTRAINTS';
-- EXCEPTION WHEN OTHERS THEN
--   IF SQLCODE != -942 THEN RAISE; END IF;
-- END;
-- /

CREATE TABLE cartao_credito (
  cartao_numero   NUMBER
    CONSTRAINT pk_cartao_credito PRIMARY KEY,
  cliente_cod     NUMBER
    CONSTRAINT fk_cartao_cliente REFERENCES cliente(cliente_cod),
  limite_credito  NUMBER
    CONSTRAINT nn_cartao_limite NOT NULL,
  status          VARCHAR2(15)
    CONSTRAINT ck_cartao_status CHECK (status IN ('ATIVO', 'BLOQUEADO', 'CANCELADO'))
);

-- 10) Tentativa de inserir valor nulo (gera erro)
-- Este comando falha por violar a constraint NOT NULL:
-- INSERT INTO cartao_credito (cartao_numero, cliente_cod, limite_credito, status)
-- VALUES (1, 101, NULL, 'ATIVO');

-- 11) Inserção de 3 cartões válidos (sempre liste as colunas)
INSERT INTO cartao_credito (cartao_numero, cliente_cod, limite_credito, status)
VALUES (1001, 1, 5000, 'ATIVO');

INSERT INTO cartao_credito (cartao_numero, cliente_cod, limite_credito, status)
VALUES (1002, 2, 2000, 'BLOQUEADO');

INSERT INTO cartao_credito (cartao_numero, cliente_cod, limite_credito, status)
VALUES (1003, 3, 3500, 'CANCELADO');


-- 12) Criar a tabela transacao (com constraints nomeadas)
-- (Se precisar recriar, descomente o bloco de DROP)
-- BEGIN
--   EXECUTE IMMEDIATE 'DROP TABLE transacao CASCADE CONSTRAINTS';
-- EXCEPTION WHEN OTHERS THEN
--   IF SQLCODE != -942 THEN RAISE; END IF;
-- END;
-- /

CREATE TABLE transacao (
  transacao_id     NUMBER
    CONSTRAINT pk_transacao PRIMARY KEY,
  cartao_numero    NUMBER
    CONSTRAINT fk_transacao_cartao REFERENCES cartao_credito(cartao_numero),
  valor            NUMBER
    CONSTRAINT ck_transacao_valor CHECK (valor > 0),
  data_transacao   TIMESTAMP
);

-- 13) Tentativa de inserir valor negativo (gera erro)
-- Este comando falha por violar a constraint CHECK:
-- INSERT INTO transacao (transacao_id, cartao_numero, valor, data_transacao)
-- VALUES (1, 1001, -500, SYSTIMESTAMP);

-- 14) Clientes com cartão ATIVO e limite > 3000
SELECT c.cliente_nome, cc.limite_credito
FROM cliente c
JOIN cartao_credito cc ON c.cliente_cod = cc.cliente_cod
WHERE cc.status = 'ATIVO'
  AND cc.limite_credito > 3000;

-- 15) Criar a view vw_clientes_com_cartao
-- (Se precisar recriar, descomente o DROP abaixo)
-- DROP VIEW vw_clientes_com_cartao;

CREATE OR REPLACE VIEW vw_clientes_com_cartao AS
SELECT c.cliente_nome, c.cidade, cc.status
FROM cliente c
JOIN cartao_credito cc ON c.cliente_cod = cc.cliente_cod;
