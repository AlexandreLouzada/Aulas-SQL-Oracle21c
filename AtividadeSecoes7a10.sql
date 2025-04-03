-- Questão 1: Nome do cliente e número da conta (sintaxe Oracle de equijunção)
SELECT cliente.cliente_nome, conta.conta_numero
FROM cliente, conta
WHERE cliente.cliente_cod = conta.cliente_cliente_cod;

-- Questão 2: Produto cartesiano entre cliente e agência
SELECT cliente.cliente_nome, agencia.agencia_nome
FROM cliente, agencia;

-- Questão 3: Nome dos clientes e cidade da agência (com alias)
SELECT c.cliente_nome, a.agencia_cidade
FROM cliente c, conta ct, agencia a
WHERE c.cliente_cod = ct.cliente_cliente_cod
AND ct.agencia_agencia_cod = a.agencia_cod;

-- Questão 4: Saldo total de todas as contas
SELECT SUM(saldo) AS total_saldos FROM conta;

-- Questão 5: Maior saldo e média dos saldos
SELECT MAX(saldo) AS maior_saldo, AVG(saldo) AS media_saldo FROM conta;

-- Questão 6: Quantidade total de contas
SELECT COUNT(*) AS total_contas FROM conta;

-- Questão 7: Número de cidades distintas com clientes
SELECT COUNT(DISTINCT cidade) AS cidades_distintas FROM cliente;

-- Questão 8: Substituir saldo nulo por 0
SELECT conta_numero, NVL(saldo, 0) AS saldo_corrigido FROM conta;

-- Questão 9: Média de saldo por cidade dos clientes
SELECT cidade, ROUND(AVG(ct.saldo), 2) AS media_saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
GROUP BY cidade;

-- Questão 10: Cidades com mais de 3 contas
SELECT cidade, COUNT(*) AS qtd_contas
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
GROUP BY cidade
HAVING COUNT(*) > 3;

-- Questão 11: Total de saldos por cidade da agência + total geral (ROLLUP)
SELECT a.agencia_cidade, SUM(ct.saldo) AS total_saldos
FROM conta ct
JOIN agencia a ON ct.agencia_agencia_cod = a.agencia_cod
GROUP BY ROLLUP (a.agencia_cidade);

-- Questão 12: Cidades de clientes e agências (sem duplicação) – UNION
SELECT cidade FROM cliente WHERE cidade IN ('Niterói', 'Resende')
UNION
SELECT agencia_cidade FROM agencia WHERE agencia_cidade IN ('Niterói', 'Resende');

-- Questão 13: Clientes com saldo acima da média geral (subconsulta de linha única)
SELECT c.cliente_nome
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo > (
  SELECT AVG(saldo) FROM conta
);

-- Questão 14: Clientes com saldo entre os 10 maiores (subconsulta multilinha com IN)
SELECT c.cliente_nome
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo IN (
  SELECT DISTINCT saldo
  FROM conta
  ORDER BY saldo DESC FETCH FIRST 10 ROWS ONLY
);

-- Questão 15: Clientes com saldo menor que todos da cidade 'Niterói' (subconsulta com ALL)
SELECT c.cliente_nome, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo < ALL (
  SELECT ct2.saldo
  FROM conta ct2
  JOIN cliente c2 ON ct2.cliente_cliente_cod = c2.cliente_cod
  WHERE c2.cidade = 'Niterói'
);

-- Questão 16: Clientes com saldo acima da média da própria agência (subconsulta correlacionada)
SELECT c.cliente_nome, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
WHERE ct.saldo > (
  SELECT AVG(ct2.saldo)
  FROM conta ct2
  WHERE ct2.agencia_agencia_cod = ct.agencia_agencia_cod
);

-- Questão 17: Clientes com pelo menos uma conta (subconsulta com EXISTS)
SELECT cliente_nome
FROM cliente c
WHERE EXISTS (
  SELECT 1 FROM conta ct
  WHERE ct.cliente_cliente_cod = c.cliente_cod
);

-- Questão 18: Clientes sem conta registrada (subconsulta com NOT EXISTS)
SELECT cliente_nome
FROM cliente c
WHERE NOT EXISTS (
  SELECT 1 FROM conta ct
  WHERE ct.cliente_cliente_cod = c.cliente_cod
);

-- Questão 19: Subconsulta nomeada com WITH – clientes com saldo acima da média da cidade
WITH media_saldo_por_cidade AS (
  SELECT c.cidade, AVG(ct.saldo) AS media_saldo
  FROM cliente c
  JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
  GROUP BY c.cidade
)
SELECT c.cliente_nome, c.cidade, ct.saldo
FROM cliente c
JOIN conta ct ON c.cliente_cod = ct.cliente_cliente_cod
JOIN media_saldo_por_cidade m ON c.cidade = m.cidade
WHERE ct.saldo > m.media_saldo;
