-- triggers.sql
-- Triggers clássicas + versão COMPOUND TRIGGER para consolidar regras em CONTA

SET SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE

--------------------------------------------------------------------------------
-- [Setup opcional] adiciona DATA_ABERTURA se faltar (usada nos defaults)
--------------------------------------------------------------------------------
DECLARE v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt
  FROM user_tab_cols
  WHERE table_name = 'CONTA' AND column_name = 'DATA_ABERTURA';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE conta ADD (data_abertura DATE DEFAULT SYSDATE)';
  END IF;
END;
/

--------------------------------------------------------------------------------
-- (A) TRIGGERS SIMPLES (podem ser úteis didaticamente)
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_conta_bi_defaults
BEFORE INSERT ON conta
FOR EACH ROW
BEGIN
  IF :NEW.data_abertura IS NULL THEN
    :NEW.data_abertura := SYSDATE;
  END IF;
END;
/
SHOW ERRORS TRIGGER trg_conta_bi_defaults

CREATE OR REPLACE TRIGGER trg_conta_chk_negativo
AFTER INSERT OR UPDATE OF saldo ON conta
FOR EACH ROW
BEGIN
  IF :NEW.saldo < 0 THEN
    RAISE_APPLICATION_ERROR(-20007, 'Saldo não pode ficar negativo');
  END IF;
END;
/
SHOW ERRORS TRIGGER trg_conta_chk_negativo

--------------------------------------------------------------------------------
-- (B) COMPOUND TRIGGER: consolida múltiplos eventos em CONTA
-- - Before Each Row: aplica defaults/validações imediatas
-- - After Each Row: acumula contas afetadas
-- - After Statement: ação agregada (ex.: auditoria por lote)
-- Obs.: substitui a necessidade de várias triggers separadas.
--------------------------------------------------------------------------------

-- Remove versões antigas, se existirem
DECLARE
  PROCEDURE drop_trg(p_name VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER '||p_name;
  EXCEPTION WHEN OTHERS THEN
    IF SQLCODE NOT IN (-4080, -4043) THEN RAISE; END IF; -- ignora "does not exist"
  END;
BEGIN
  drop_trg('TRG_CONTA_COMPOUND');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER trg_conta_compound
FOR INSERT OR UPDATE OR DELETE ON conta
COMPOUND TRIGGER

  -- Coleção para acumular contas afetadas no statement
  TYPE t_conta_tab IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  g_contas_afetadas t_conta_tab;
  g_idx             PLS_INTEGER := 0;

  -- Before Statement
  BEFORE STATEMENT IS
  BEGIN
    g_contas_afetadas.DELETE;
    g_idx := 0;
  END BEFORE STATEMENT;

  -- Before Each Row
  BEFORE EACH ROW IS
  BEGIN
    -- Default de data_abertura em inserts
    IF INSERTING THEN
      IF :NEW.data_abertura IS NULL THEN
        :NEW.data_abertura := SYSDATE;
      END IF;
      -- saldo não pode iniciar negativo
      IF :NEW.saldo < 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Saldo não pode ficar negativo (insert)');
      END IF;
    ELSIF UPDATING('SALDO') THEN
      -- impedir saldo negativo em updates
      IF :NEW.saldo < 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Saldo não pode ficar negativo (update)');
      END IF;
    END IF;
  END BEFORE EACH ROW;

  -- After Each Row
  AFTER EACH ROW IS
  BEGIN
    -- Guarda o número da conta afetada para auditoria agregada
    g_idx := g_idx + 1;
    IF INSERTING OR UPDATING THEN
      g_contas_afetadas(g_idx) := :NEW.conta_numero;
    ELSIF DELETING THEN
      g_contas_afetadas(g_idx) := :OLD.conta_numero;
    END IF;
  END AFTER EACH ROW;

  -- After Statement
  AFTER STATEMENT IS
  BEGIN
    -- Exemplo: log agregado (aqui só mostra contagem; adapte para gravar numa tabela de auditoria se quiser)
    DBMS_OUTPUT.PUT_LINE('Contas afetadas no statement: '||g_contas_afetadas.COUNT);
    -- Ex.: INSERT em uma tabela de auditoria resumida:
    -- FOR i IN 1 .. g_contas_afetadas.COUNT LOOP
    --   INSERT INTO conta_audit (quando, conta_numero, usuario) VALUES (SYSTIMESTAMP, g_contas_afetadas(i), USER);
    -- END LOOP;
    -- COMMIT;  -- cuidado: só se a tabela de auditoria for AUTONOMOUS_TRANSACTION
  END AFTER STATEMENT;

END trg_conta_compound;
/
SHOW ERRORS TRIGGER trg_conta_compound

--------------------------------------------------------------------------------
-- (C) Trigger em MOVIMENTO_CONTA: normaliza observação
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_movimento_ai
AFTER INSERT ON movimento_conta
FOR EACH ROW
BEGIN
  IF :NEW.observacao IS NULL THEN
    :NEW.observacao := CASE :NEW.tipo WHEN 'C' THEN 'Crédito' ELSE 'Débito' END;
  END IF;
END;
/
SHOW ERRORS TRIGGER trg_movimento_ai

--------------------------------------------------------------------------------
-- (D) Auditoria de EMPRESTIMO (after I/U/D)
--------------------------------------------------------------------------------
DECLARE v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = 'EMPRESTIMO_AUDIT';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE emprestimo_audit (
        audit_id       NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        operacao       VARCHAR2(10),
        emprestimo_num NUMBER,
        cliente_cod    NUMBER,
        agencia_cod    NUMBER,
        quantia        NUMBER(10,2),
        audit_user     VARCHAR2(128),
        audit_date     TIMESTAMP DEFAULT SYSTIMESTAMP
      )
    ]';
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_emprestimo_audit
AFTER INSERT OR UPDATE OR DELETE ON emprestimo
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    INSERT INTO emprestimo_audit (operacao, emprestimo_num, cliente_cod, agencia_cod, quantia, audit_user)
    VALUES ('INSERT', :NEW.emprestimo_numero, :NEW.cliente_cliente_cod, :NEW.agencia_agencia_cod, :NEW.quantia, USER);
  ELSIF UPDATING THEN
    INSERT INTO emprestimo_audit (operacao, emprestimo_num, cliente_cod, agencia_cod, quantia, audit_user)
    VALUES ('UPDATE', :NEW.emprestimo_numero, :NEW.cliente_cliente_cod, :NEW.agencia_agencia_cod, :NEW.quantia, USER);
  ELSIF DELETING THEN
    INSERT INTO emprestimo_audit (operacao, emprestimo_num, cliente_cod, agencia_cod, quantia, audit_user)
    VALUES ('DELETE', :OLD.emprestimo_numero, :OLD.cliente_cliente_cod, :OLD.agencia_agencia_cod, :OLD.quantia, USER);
  END IF;
END;
/
SHOW ERRORS TRIGGER trg_emprestimo_audit

--------------------------------------------------------------------------------
-- Exemplos rápidos
--------------------------------------------------------------------------------
-- UPDATE conta SET saldo = saldo + 1 WHERE conta_numero IN (1,2,3);
-- INSERT INTO emprestimo (emprestimo_numero, quantia, cliente_cliente_cod, agencia_agencia_cod)
-- VALUES (99901, 1000, 1, 1);
-- UPDATE emprestimo SET quantia = quantia + 200 WHERE emprestimo_numero = 99901;
-- DELETE FROM emprestimo WHERE emprestimo_numero = 99901;
-- SELECT * FROM emprestimo_audit ORDER BY audit_id;
