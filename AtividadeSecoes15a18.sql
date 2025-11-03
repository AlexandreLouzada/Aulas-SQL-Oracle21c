--------------------------------------------------------------------------------
-- Seção 15 – Uso de Sequências
--------------------------------------------------------------------------------

-- 1) Criar a sequência
CREATE SEQUENCE seq_movimento START WITH 100 INCREMENT BY 10 NOCACHE;

-- 2) Criar a tabela de movimentos (com restrições úteis)
--    - tipo restrito a 'D' ou 'C'
--    - (opcional) FK para conta(conta_numero) se desejar garantir integridade
CREATE TABLE movimento_conta (
  movimento_id    NUMBER        CONSTRAINT pk_movimento_conta PRIMARY KEY,
  conta_numero    NUMBER,
  tipo            CHAR(1)       CONSTRAINT ck_mov_tipo CHECK (tipo IN ('D','C')),
  valor           NUMBER(10,2)  CONSTRAINT ck_mov_valor CHECK (valor > 0),
  data_movimento  DATE          DEFAULT SYSDATE
  -- , CONSTRAINT fk_mov_conta FOREIGN KEY (conta_numero) REFERENCES conta(conta_numero)
);

-- 2b) (Recomendado) Gatilho para popular o movimento_id via seq_movimento
CREATE OR REPLACE TRIGGER trg_movimento_conta_bi
BEFORE INSERT ON movimento_conta
FOR EACH ROW
BEGIN
  IF :NEW.movimento_id IS NULL THEN
    :NEW.movimento_id := seq_movimento.NEXTVAL;
  END IF;
END;
/

-- 3) Inserir três movimentações usando NEXTVAL (ou deixando o trigger preencher)
--    Use contas existentes (1..40) do seu dataset
INSERT INTO movimento_conta (movimento_id, conta_numero, tipo, valor, data_movimento)
VALUES (seq_movimento.NEXTVAL, 1, 'C', 1500.00, SYSDATE);

INSERT INTO movimento_conta (movimento_id, conta_numero, tipo, valor, data_movimento)
VALUES (seq_movimento.NEXTVAL, 2, 'D', 500.00, SYSDATE);

INSERT INTO movimento_conta (movimento_id, conta_numero, tipo, valor, data_movimento)
VALUES (seq_movimento.NEXTVAL, 3, 'C', 200.00, SYSDATE);

COMMIT;


--------------------------------------------------------------------------------
-- Seção 16 – Criação e Uso de Views
--------------------------------------------------------------------------------

-- 4) vw_contas_clientes (ajuste de nomes de colunas)
CREATE OR REPLACE VIEW vw_contas_clientes AS
SELECT
  c.cliente_nome,
  ct.conta_numero,
  ct.saldo,
  ct.agencia_agencia_cod AS agencia_cod
FROM cliente c
JOIN conta   ct
  ON c.cliente_cod = ct.cliente_cliente_cod;

-- 5) vw_emprestimos_grandes (coluna correta: QUANTIA)
CREATE OR REPLACE VIEW vw_emprestimos_grandes AS
SELECT
  e.emprestimo_numero,
  c.cliente_nome,
  e.quantia
FROM emprestimo e
JOIN cliente   c
  ON e.cliente_cliente_cod = c.cliente_cod
WHERE e.quantia > 20000;

-- 6) UPDATE na view:
-- Tentativa (comentada):
-- UPDATE vw_emprestimos_grandes SET quantia = 25000
-- WHERE emprestimo_numero = 301;
-- Explicação: Views com JOIN + filtro raramente são atualizáveis em Oracle
-- porque a(s) tabela(s) de base não ficam "key-preserved" sob a projeção.
-- Resultado: ORA-01779 / ORA-42399 (dependendo do caso). Use INSTEAD OF TRIGGER
-- na view ou atualize diretamente a tabela base (EMPRESTIMO).


--------------------------------------------------------------------------------
-- Seção 17 – Privilégios e Roles
--------------------------------------------------------------------------------

-- 7) ROLE com privilégios (ajuste: coluna existente é RUA, não ENDERECO)
CREATE ROLE atendente_agencia;

GRANT SELECT ON cliente TO atendente_agencia;
GRANT SELECT ON conta   TO atendente_agencia;

-- Update apenas na coluna 'rua' da tabela cliente
GRANT UPDATE (rua) ON cliente TO atendente_agencia;

-- 8) Conceder a role ao usuário carla
GRANT atendente_agencia TO carla;

-- 9) Revogar o UPDATE em cliente da role
REVOKE UPDATE ON cliente FROM atendente_agencia;

-- 10) Usuário auditor com permissão de consultar views
-- Observação: não existe "SELECT ANY VIEW" em Oracle. O privilégio
-- mais próximo é SELECT ANY TABLE (cobre tabelas e views).
-- Alternativa: conceder SELECT especificamente nas views desejadas (ex.: vw_*).
CREATE USER auditor IDENTIFIED BY senha_auditor;
GRANT CREATE SESSION TO auditor;

-- Opção A (global, inclui tabelas e views):
GRANT SELECT ANY TABLE TO auditor;

-- Opção B (mais restrita ao seu schema): conceder apenas nas views do seu schema
-- GRANT SELECT ON vw_contas_clientes     TO auditor;
-- GRANT SELECT ON vw_emprestimos_grandes TO auditor;


--------------------------------------------------------------------------------
-- Seção 18 – Expressões Regulares (REGEXP)
--------------------------------------------------------------------------------
-- IMPORTANTE: sua tabela CLIENTE não possui CPF nem EMAIL. Para que os
-- exercícios 12, 13 e 15 funcionem, adicione as colunas abaixo (se ainda não existirem):

-- ALTER TABLE cliente ADD (cpf   VARCHAR2(14));
-- ALTER TABLE cliente ADD (email VARCHAR2(100));

-- 11) Nomes que começam com 'M' e terminam com 'a' (case-insensitive)
SELECT *
FROM cliente
WHERE REGEXP_LIKE(cliente_nome, '^M.*a$', 'i');

-- 12) Mascarar CPF (6 primeiros dígitos)  -> requer coluna CPF
-- Formatos aceitos com ou sem pontuação nos 6 primeiros dígitos
SELECT
  cliente_nome,
  REGEXP_REPLACE(cpf, '^[0-9]{3}\.?[0-9]{3}', '***.***') AS cpf_mascarado
FROM cliente;

-- 13) Extrair domínio do e-mail -> requer coluna EMAIL
-- Captura o que vem após '@'
SELECT
  cliente_nome,
  REGEXP_SUBSTR(email, '@(.+)', 1, 1, NULL, 1) AS dominio
FROM cliente;

-- 14) Clientes com dois ou mais nomes (tem pelo menos um espaço)
SELECT cliente_nome
FROM cliente
WHERE REGEXP_LIKE(cliente_nome, ' ');

-- 15) E-mails que terminam com '.br' -> requer coluna EMAIL
SELECT *
FROM cliente
WHERE REGEXP_LIKE(email, '\.br$', 'i');
