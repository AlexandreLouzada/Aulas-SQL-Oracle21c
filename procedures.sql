-- procedures.sql
-- Procedures didáticas para a agência bancária
-- Dependências: tabelas CONTA, MOVIMENTO_CONTA; sequência SEQ_MOVIMENTO

SET SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE

--------------------------------------------------------------------------------
-- [Setup opcional] garante a existência de SEQ_MOVIMENTO e MOVIMENTO_CONTA
--------------------------------------------------------------------------------
DECLARE e_missing EXCEPTION; PRAGMA EXCEPTION_INIT(e_missing, -2289);
BEGIN
  EXECUTE IMMEDIATE 'SELECT seq_movimento.NEXTVAL FROM dual';
EXCEPTION WHEN e_missing THEN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_movimento START WITH 100 INCREMENT BY 10 NOCACHE';
END;
/

DECLARE v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = 'MOVIMENTO_CONTA';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE movimento_conta (
        movimento_id    NUMBER PRIMARY KEY,
        conta_numero    NUMBER,
        tipo            CHAR(1) CHECK (tipo IN ('C','D')),  -- C=crédito, D=débito
        valor           NUMBER(10,2) CHECK (valor > 0),
        data_movimento  DATE DEFAULT SYSDATE,
        observacao      VARCHAR2(200)
      )
    ]';
  END IF;
END;
/

--------------------------------------------------------------------------------
-- p_depositar: ação com efeito colateral (sem retorno)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE p_depositar (
  p_conta IN NUMBER,
  p_valor IN NUMBER,
  p_obs   IN VARCHAR2 DEFAULT 'Depósito'
) AS
BEGIN
  IF p_valor IS NULL OR p_valor <= 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Valor inválido para depósito');
  END IF;

  UPDATE conta
     SET saldo = saldo + p_valor
   WHERE conta_numero = p_conta;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Conta inexistente');
  END IF;

  INSERT INTO movimento_conta (movimento_id, conta_numero, tipo, valor, observacao)
  VALUES (seq_movimento.NEXTVAL, p_conta, 'C', p_valor, p_obs);
END;
/
SHOW ERRORS PROCEDURE p_depositar

--------------------------------------------------------------------------------
-- p_sacar: valida saldo, atualiza, registra movimento
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE p_sacar (
  p_conta IN NUMBER,
  p_valor IN NUMBER,
  p_obs   IN VARCHAR2 DEFAULT 'Saque'
) AS
  v_saldo NUMBER;
BEGIN
  IF p_valor IS NULL OR p_valor <= 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Valor inválido para saque');
  END IF;

  SELECT saldo
    INTO v_saldo
    FROM conta
   WHERE conta_numero = p_conta
   FOR UPDATE;

  IF p_valor > v_saldo THEN
    RAISE_APPLICATION_ERROR(-20004, 'Saldo insuficiente');
  END IF;

  UPDATE conta
     SET saldo = saldo - p_valor
   WHERE conta_numero = p_conta;

  INSERT INTO movimento_conta (movimento_id, conta_numero, tipo, valor, observacao)
  VALUES (seq_movimento.NEXTVAL, p_conta, 'D', p_valor, p_obs);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20005, 'Conta inexistente');
END;
/
SHOW ERRORS PROCEDURE p_sacar

--------------------------------------------------------------------------------
-- p_transferir: compõe p_sacar + p_depositar (mesma transação)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE p_transferir (
  p_origem  IN NUMBER,
  p_destino IN NUMBER,
  p_valor   IN NUMBER,
  p_obs     IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
  IF p_origem = p_destino THEN
    RAISE_APPLICATION_ERROR(-20006, 'Origem e destino não podem ser iguais');
  END IF;
  p_sacar     (p_origem,  p_valor, 'Transferência para '||p_destino||CASE WHEN p_obs IS NOT NULL THEN ' - '||p_obs END);
  p_depositar (p_destino, p_valor, 'Transferência de ' ||p_origem ||CASE WHEN p_obs IS NOT NULL THEN ' - '||p_obs END);
END;
/
SHOW ERRORS PROCEDURE p_transferir

--------------------------------------------------------------------------------
-- Exemplos rápidos
--------------------------------------------------------------------------------
-- BEGIN
--   p_depositar(1, 300, 'Depósito caixa');
--   p_sacar    (2, 100, 'Saque ATM');
--   p_transferir(1, 2, 50, 'Ajuste');
-- END;
-- /
-- SELECT * FROM movimento_conta ORDER BY movimento_id;
