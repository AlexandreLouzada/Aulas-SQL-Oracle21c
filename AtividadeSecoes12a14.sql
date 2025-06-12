--🔹 Seção 12 – Conversões Implícitas e Explícitas
--1. Formate os saldos das contas com separador decimal vírgula:

SELECT conta_numero, 'R$ ' || REPLACE(TO_CHAR(saldo, '999G999D99'), '.', ',') AS Saldo_Formatado
FROM conta;

--2. Exiba a data atual formatada como 'dd/mm/yyyy':

SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS data_atual
FROM dual;

--3. Exiba nome do cliente e cidade, separados por hífen:

SELECT cliente_nome || ' - ' || cidade AS nome_cidade
FROM cliente;

--4. Empréstimos acima de R$ 5000 com valor formatado:

SELECT emprestimo_numero, 'R$ ' || TO_CHAR(valor, '999G999D99') AS valor_formatado
FROM emprestimo
WHERE valor > 5000;

--🔹 Seção 13 – Tipos de Dados Avançados
--5. Adicionar coluna data_cadastro e atualizar com SYSTIMESTAMP:

ALTER TABLE cliente ADD (data_cadastro TIMESTAMP);
UPDATE cliente SET data_cadastro = SYSTIMESTAMP;

--6. Exibir o tempo em dias desde o cadastro:

SELECT cliente_nome, TRUNC(SYSDATE - data_cadastro) AS dias_desde_cadastro
FROM cliente;

--7. Adicionar coluna tempo_fidelidade com tipo INTERVAL:

ALTER TABLE cliente ADD (tempo_fidelidade INTERVAL YEAR TO MONTH);

--8. Exibir data de renovação com 3 meses após o cadastro:

SELECT cliente_nome, data_cadastro, data_cadastro + INTERVAL '3' MONTH AS renovacao
FROM cliente;

--🔹 Seção 14 – Constraints (Restrições)
--9. Criar a tabela cartao_credito:


CREATE TABLE cartao_credito (
  cartao_numero NUMBER PRIMARY KEY,
  cliente_cod NUMBER REFERENCES cliente(cliente_cod),
  limite_credito NUMBER NOT NULL,
  status VARCHAR2(15) CHECK (status IN ('ATIVO', 'BLOQUEADO', 'CANCELADO'))
);

--10. Tentativa de inserir valor nulo (gera erro):


-- Este comando falha por violar a constraint NOT NULL:
-- INSERT INTO cartao_credito (cartao_numero, cliente_cod, limite_credito, status)
-- VALUES (1, 101, NULL, 'ATIVO');

--11. Inserção de 3 cartões válidos:


INSERT INTO cartao_credito VALUES (1001, 1, 5000, 'ATIVO');
INSERT INTO cartao_credito VALUES (1002, 2, 2000, 'BLOQUEADO');
INSERT INTO cartao_credito VALUES (1003, 3, 3500, 'CANCELADO');

--12. Criar a tabela transacao:


CREATE TABLE transacao (
  transacao_id NUMBER PRIMARY KEY,
  cartao_numero NUMBER REFERENCES cartao_credito(cartao_numero),
  valor NUMBER CHECK (valor > 0),
  data_transacao TIMESTAMP
);

--13. Tentativa de inserir valor negativo (gera erro):

-- Este comando falha por violar a constraint CHECK:
-- INSERT INTO transacao VALUES (1, 1001, -500, SYSTIMESTAMP);
--14. Clientes com cartão ATIVO e limite > 3000:

SELECT c.cliente_nome, cc.limite_credito
FROM cliente c
JOIN cartao_credito cc ON c.cliente_cod = cc.cliente_cod
WHERE cc.status = 'ATIVO' AND cc.limite_credito > 3000;

--15. Criar a view vw_clientes_com_cartao:


CREATE OR REPLACE VIEW vw_clientes_com_cartao AS
SELECT c.cliente_nome, c.cidade, cc.status
FROM cliente c
JOIN cartao_credito cc ON c.cliente_cod = cc.cliente_cod;