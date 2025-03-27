--1.	
SELECT a.nome FROM aluno a JOIN matricula m ON a.aluno_id = m.aluno_id JOIN curso c ON m.curso_id = c.curso_id WHERE c.titulo = 'Banco de Dados';
--2.	
SELECT * FROM curso WHERE carga_horaria > 40;
--3.	
SELECT a.nome FROM aluno a JOIN matricula m ON a.aluno_id = m.aluno_id WHERE m.nota IS NULL;
--4.	
SELECT * FROM matricula WHERE data_matricula > TO_DATE('2024-01-01', 'YYYY-MM-DD');
--5.	
SELECT * FROM curso WHERE carga_horaria BETWEEN 30 AND 60;
--6.	
SELECT * FROM aluno WHERE email LIKE '%@gmail.com';

--7.	
SELECT a.nome, c.titulo, m.data_matricula FROM aluno a JOIN matricula m ON a.aluno_id = m.aluno_id JOIN curso c ON m.curso_id = c.curso_id;
--8.	
SELECT a.nome, c.titulo, m.nota FROM aluno a JOIN matricula m ON a.aluno_id = m.aluno_id JOIN curso c ON m.curso_id = c.curso_id;
--9.	
SELECT c.titulo FROM aluno a JOIN matricula m ON a.aluno_id = m.aluno_id JOIN curso c ON m.curso_id = c.curso_id WHERE a.nome = 'João Silva';
--10.	
SELECT c.titulo, COUNT(*) AS qtd FROM curso c JOIN matricula m ON c.curso_id = m.curso_id GROUP BY c.titulo HAVING COUNT(*) > 1;
--11.	
SELECT a.nome FROM aluno a LEFT JOIN matricula m ON a.aluno_id = m.aluno_id WHERE m.aluno_id IS NULL;
--12.	
SELECT c.titulo FROM curso c LEFT JOIN matricula m ON c.curso_id = m.curso_id WHERE m.curso_id IS NULL;
--13.	
SELECT a.nome, COUNT(m.curso_id) AS cursos_matriculados FROM aluno a LEFT JOIN matricula m ON a.aluno_id = m.aluno_id GROUP BY a.nome;
 
--14.	
SELECT AVG(nota) AS media_geral FROM matricula WHERE nota IS NOT NULL;
--15.
SELECT c.titulo, AVG(m.nota) AS media FROM curso c JOIN matricula m ON c.curso_id = m.curso_id WHERE m.nota IS NOT NULL GROUP BY c.titulo;
--16.	
SELECT MAX(nota) AS maior_nota FROM matricula;
--17.	
SELECT a.nome, m.nota FROM aluno a JOIN matricula m ON a.aluno_id = m.aluno_id WHERE m.nota = (SELECT MIN(nota) FROM matricula WHERE nota IS NOT NULL);
--18.	
SELECT c.titulo, COUNT(m.aluno_id) AS total_matriculas FROM curso c LEFT JOIN matricula m ON c.curso_id = m.curso_id GROUP BY c.titulo;
--19.	
SELECT a.nome, AVG(m.nota) AS media FROM aluno a JOIN matricula m ON a.aluno_id = m.aluno_id WHERE m.nota IS NOT NULL GROUP BY a.nome HAVING AVG(m.nota) >= 8.0;
--20.	
SELECT c.titulo, AVG(m.nota) AS media, MIN(m.nota) AS menor, MAX(m.nota) AS maior FROM curso c JOIN matricula m ON c.curso_id = m.curso_id WHERE m.nota IS NOT NULL GROUP BY c.titulo;
