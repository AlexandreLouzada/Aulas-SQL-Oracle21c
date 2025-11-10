-- functions.sql
-- Funções didáticas: podem ser usadas em SELECT/expressões

SET SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE

--------------------------------------------------------------------------------
-- f_saldo_conta: retorna saldo atual da conta
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_saldo_conta (p_conta IN NUMBER)
RETURN NUMBER
IS
  v_saldo NUMBER;
BEGIN
  SELECT saldo INTO v_saldo
    FROM conta
   WHERE conta_numero = p_conta;
  RETURN v_saldo;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL; -- ou RAISE_APPLICATION_ERROR(-20010,'Conta inexistente');
END;
/
SHOW ERRORS FUNCTION f_saldo_conta

--------------------------------------------------------------------------------
-- f_risco_cliente: classifica risco simples a partir de saldos e empréstimos
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_risco_cliente (p_cliente IN NUMBER)
RETURN VARCHAR2
IS
  v_saldo_total   NUMBER := 0;
  v_emprest_total NUMBER := 0;
  v_ratio         NUMBER := 0;
BEGIN
  SELECT NVL(SUM(saldo),0)
    INTO v_saldo_total
    FROM conta
   WHERE cliente_cliente_cod = p_cliente;

  SELECT NVL(SUM(quantia),0)
    INTO v_emprest_total
    FROM emprestimo
   WHERE cliente_cliente_cod = p_cliente;

  v_ratio := CASE WHEN v_saldo_total <= 0 THEN 9999 ELSE v_emprest_total / v_saldo_total END;

  IF v_ratio < 0.5 THEN
    RETURN 'BAIXO';
  ELSIF v_ratio < 1.5 THEN
    RETURN 'MÉDIO';
  ELSE
    RETURN 'ALTO';
  END IF;
END;
/
SHOW ERRORS FUNCTION f_risco_cliente

--------------------------------------------------------------------------------
-- Exemplos rápidos
--------------------------------------------------------------------------------
-- SELECT 1 AS conta, f_saldo_conta(1) AS saldo FROM dual
-- UNION ALL
-- SELECT 2, f_saldo_conta(2) FROM dual
-- ORDER BY 1;
--
-- SELECT c.cliente_cod, c.cliente_nome, f_risco_cliente(c.cliente_cod) AS risco
-- FROM cliente c
-- ORDER BY c.cliente_cod;
