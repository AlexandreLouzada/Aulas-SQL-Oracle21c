-- Questão 1: Exibir todos os dados da tabela de clientes
SELECT * FROM cliente;

-- Questão 2: Exibir nome e cidade dos clientes
SELECT cliente_nome, cidade FROM cliente;

-- Questão 3: Exibir número da conta e saldo de todas as contas
SELECT conta_numero, saldo FROM conta;

-- Questão 4: Clientes da cidade de Macaé
SELECT cliente_nome FROM cliente
WHERE cidade = 'Macaé';

-- Questão 5: Clientes com código entre 5 e 15
SELECT cliente_cod, cliente_nome
FROM cliente
WHERE cliente_cod BETWEEN 5 AND 15;

-- Questão 6: Clientes de Niterói, Volta Redonda ou Itaboraí
SELECT cliente_nome, cidade
FROM cliente
WHERE cidade IN ('Niterói', 'Volta Redonda', 'Itaboraí');

-- Questão 7: Clientes cujo nome começa com "F"
SELECT cliente_nome
FROM cliente
WHERE cliente_nome LIKE 'F%';

-- Questão 8: Frase com nome e cidade do cliente
SELECT cliente_nome || ' mora em ' || cidade AS Frase
FROM cliente;

-- Questão 9: Contas com saldo superior a R$ 9.000, ordenadas decrescentemente
SELECT conta_numero, saldo
FROM conta
WHERE saldo > 9000
ORDER BY saldo DESC;

-- Questão 10: Clientes com "Silva" no nome ou da cidade Nova Iguaçu
SELECT cliente_nome, cidade
FROM cliente
WHERE cliente_nome LIKE '%Silva%' OR cidade = 'Nova Iguaçu';

-- Questão 11: Saldo das contas com arredondamento para o inteiro mais próximo
SELECT conta_numero, ROUND(saldo, 0) AS saldo_arredondado
FROM conta;

-- Questão 12: Nome dos clientes em letras maiúsculas
SELECT UPPER(cliente_nome) AS nome_maiusculo
FROM cliente;

-- Questão 13: Clientes que não são de Teresópolis nem de Campos dos Goytacazes
SELECT cliente_nome, cidade
FROM cliente
WHERE cidade NOT IN ('Teresópolis', 'Campos dos Goytacazes');
