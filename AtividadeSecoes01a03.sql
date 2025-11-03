-- Q1) Exibir todos os dados da tabela de clientes
SELECT *
FROM cliente
ORDER BY cliente_cod;

-- Q2) Exibir nome e cidade dos clientes
SELECT c.cliente_nome, c.cidade
FROM cliente c
ORDER BY c.cliente_nome;

-- Q3) Exibir número da conta e saldo de todas as contas
SELECT ct.conta_numero, ct.saldo
FROM conta ct
ORDER BY ct.conta_numero;

-- Q4) Clientes da cidade de Macaé
SELECT c.cliente_nome
FROM cliente c
WHERE c.cidade = 'Macaé'
ORDER BY c.cliente_nome;

-- Q5) Clientes com código entre 5 e 15 (inclusive)
SELECT c.cliente_cod, c.cliente_nome
FROM cliente c
WHERE c.cliente_cod BETWEEN 5 AND 15
ORDER BY c.cliente_cod;

-- Q6) Clientes de Niterói, Volta Redonda ou Itaboraí
SELECT c.cliente_nome, c.cidade
FROM cliente c
WHERE c.cidade IN ('Niterói', 'Volta Redonda', 'Itaboraí')
ORDER BY c.cidade, c.cliente_nome;

-- Q7) Clientes cujo nome começa com "F"
SELECT c.cliente_nome
FROM cliente c
WHERE c.cliente_nome LIKE 'F%'
ORDER BY c.cliente_nome;

-- Q8) Frase com nome e cidade do cliente
SELECT c.cliente_nome || ' mora em ' || c.cidade AS frase
FROM cliente c
ORDER BY c.cliente_nome;

-- Q9) Contas com saldo > R$ 9.000, em ordem decrescente de saldo
SELECT ct.conta_numero, ct.saldo
FROM conta ct
WHERE ct.saldo > 9000
ORDER BY ct.saldo DESC, ct.conta_numero;

-- (Opcional de exibição monetária)
-- SELECT ct.conta_numero,
--        'R$ ' || TO_CHAR(ct.saldo, 'FM999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.') AS saldo_fmt
-- FROM conta ct
-- WHERE ct.saldo > 9000
-- ORDER BY ct.saldo DESC, ct.conta_numero;

-- Q10) Clientes com "Silva" no nome ou da cidade "Nova Iguaçu"
SELECT c.cliente_nome, c.cidade
FROM cliente c
WHERE c.cliente_nome LIKE '%Silva%'
   OR c.cidade = 'Nova Iguaçu'
ORDER BY c.cliente_nome;

-- Q11) Saldo das contas arredondado para o inteiro mais próximo
SELECT ct.conta_numero, ROUND(ct.saldo, 0) AS saldo_arredondado
FROM conta ct
ORDER BY ct.conta_numero;

-- Q12) Nome dos clientes em letras maiúsculas
SELECT UPPER(c.cliente_nome) AS nome_maiusculo
FROM cliente c
ORDER BY nome_maiusculo;

-- Q13) Clientes que não são de Teresópolis nem de Campos dos Goytacazes
SELECT c.cliente_nome, c.cidade
FROM cliente c
WHERE c.cidade NOT IN ('Teresópolis', 'Campos dos Goytacazes')
ORDER BY c.cidade, c.cliente_nome;
