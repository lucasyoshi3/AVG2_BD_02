CREATE DATABASE ex05
GO
USE ex05
GO
CREATE TABLE fornecedor (
codigo			INT				NOT NULL,
nome			VARCHAR(50)		NOT NULL,
atividade		VARCHAR(80)		NOT NULL,
telefone		CHAR(8)			NOT NULL
PRIMARY KEY(codigo)
)
GO
CREATE TABLE cliente (
codigo			INT				NOT NULL,
nome			VARCHAR(50)		NOT NULL,
logradouro		VARCHAR(80)		NOT NULL,
numero			INT				NOT NULL,
telefone		CHAR(8)			NOT NULL,
data_nasc		DATE			NOT NULL
PRIMARY KEY(codigo)
)
GO
CREATE TABLE produto (
codigo			INT				NOT NULL,
nome			VARCHAR(50)		NOT NULL,
valor_unitario	DECIMAL(7,2)	NOT NULL,
qtd_estoque		INT				NOT NULL,
descricao		VARCHAR(80)		NOT NULL,
cod_forn		INT				NOT NULL
PRIMARY KEY(codigo)
FOREIGN KEY(cod_forn) REFERENCES fornecedor(codigo)
)
GO
CREATE TABLE pedido (
codigo			INT			NOT NULL,
cod_cli			INT			NOT NULL,
cod_prod		INT			NOT NULL,
quantidade		INT			NOT NULL,
previsao_ent	DATE		NOT NULL
PRIMARY KEY(codigo, cod_cli, cod_prod, previsao_ent)
FOREIGN KEY(cod_cli) REFERENCES cliente(codigo),
FOREIGN KEY(cod_prod) REFERENCES produto(codigo)
)
GO
INSERT INTO fornecedor VALUES (1001,'Estrela','Brinquedo','41525898')
INSERT INTO fornecedor VALUES (1002,'Lacta','Chocolate','42698596')
INSERT INTO fornecedor VALUES (1003,'Asus','Informática','52014596')
INSERT INTO fornecedor VALUES (1004,'Tramontina','Utensílios Domésticos','50563985')
INSERT INTO fornecedor VALUES (1005,'Grow','Brinquedos','47896325')
INSERT INTO fornecedor VALUES (1006,'Mattel','Bonecos','59865898')
INSERT INTO cliente VALUES (33601,'Maria Clara','R. 1° de Abril',870,'96325874','15/08/2000')
INSERT INTO cliente VALUES (33602,'Alberto Souza','R. XV de Novembro',987,'95873625','02/02/1985')
INSERT INTO cliente VALUES (33603,'Sonia Silva','R. Voluntários da Pátria',1151,'75418596','23/08/1957')
INSERT INTO cliente VALUES (33604,'José Sobrinho','Av. Paulista',250,'85236547','09/12/1986')
INSERT INTO cliente VALUES (33605,'Carlos Camargo','Av. Tiquatira',9652,'75896325','25/03/1971')
INSERT INTO produto VALUES (1,'Banco Imobiliário',65.00,15,'Versão Super Luxo',1001)
INSERT INTO produto VALUES (2,'Puzzle 5000 peças',50.00,5,'Mapas Mundo',1005)
INSERT INTO produto VALUES (3,'Faqueiro',350.00,0,'120 peças',1004)
INSERT INTO produto VALUES (4,'Jogo para churrasco',75.00,3,'7 peças',1004)
INSERT INTO produto VALUES (5,'Tablet',750.00,29,'Tablet',1003)
INSERT INTO produto VALUES (6,'Detetive',49.00,0,'Nova Versão do Jogo',1001)
INSERT INTO produto VALUES (7,'Chocolate com Paçoquinha',6.00,0,'Barra',1002)
INSERT INTO produto VALUES (8,'Galak',5.00,65,'Barra',1002)
INSERT INTO pedido VALUES (99001,33601,1,1,'07/03/2023')
INSERT INTO pedido VALUES (99001,33601,2,1,'07/03/2023')
INSERT INTO pedido VALUES (99001,33601,8,3,'07/03/2023')
INSERT INTO pedido VALUES (99002,33602,2,1,'09/03/2023')
INSERT INTO pedido VALUES (99002,33602,4,3,'09/03/2023')
INSERT INTO pedido VALUES (99003,33605,5,1,'15/03/2023')
GO

-- 1. Consultar a quantidade, valor total e valor total com desconto (25%) dos itens comprados par Maria Clara.
SELECT p.quantidade AS Quantidade, SUM(pro.valor_unitario) AS Valor_Total, SUM(pro.valor_unitario)*0.75 AS Valor_Total_Com_Desconto 
FROM pedido AS p
JOIN produto AS pro ON p.cod_prod = pro.codigo
JOIN cliente AS c ON p.cod_cli = c.codigo
WHERE c.nome = 'Maria Clara'
GROUP BY p.quantidade;

--2. Consultar quais brinquedos não tem itens em estoque.
SELECT p.nome, p.qtd_estoque
FROM produto AS p
LEFT JOIN fornecedor AS f ON p.cod_forn = f.codigo
WHERE f.atividade LIKE 'Brinquedo%' AND p.qtd_estoque=0

--3. Consultar quais nome e descrições de produtos que não estão em pedidos
SELECT p.nome AS Nome, p.descricao AS descricao
FROM produto AS p
LEFT JOIN pedido AS pedido ON p.codigo = pedido.cod_prod
WHERE pedido.cod_prod IS NULL;

--4. Alterar a quantidade em estoque do faqueiro para 10 peças.
UPDATE produto
SET descricao = '10 peças'
WHERE codigo = 3;

--5. Consultar Quantos clientes tem mais de 40 anos.
SELECT count(*)
FROM cliente AS c
WHERE DATEDIFF(YEAR, c.data_nasc, GETDATE())>= 40;

--6. Consultar Nome e telefone (Formatado XXXX-XXXX) dos fornecedores de Brinquedos e Chocolate.
SELECT f.nome AS Nome, SUBSTRING(f.telefone,1,4) +'-' + SUBSTRING(f.telefone, 5, 8 ) AS Telefone 
FROM fornecedor AS f
WHERE f.atividade LIKE 'Brinquedo%' OR f.atividade LIKE 'Chocolate'

--7. Consultar nome e desconto de 25% no preço dos produtos que custam menos de R$50,00
SELECT p.nome AS Nome, CONVERT(DECIMAL(7,2), p.valor_unitario*0.75) AS Desconto
FROM produto AS p
WHERE p.valor_unitario < 50;

--8. Consultar nome e aumento de 10% no preço dos produtos que custam mais de R$100,00
SELECT p.nome AS Nome, CONVERT(DECIMAL(7,2), p.valor_unitario*1.10) AS Aumento
FROM produto AS p
WHERE p.valor_unitario > 100;

--9. Consultar desconto de 15% no valor total de cada produto da venda 99001.
SELECT p.nome AS Nome, CONVERT(DECIMAL(7,2), p.valor_unitario*0.85) AS Desconto
FROM produto AS p
LEFT JOIN pedido AS pe ON p.codigo = pe.cod_prod
WHERE pe.codigo = 99001;

--10. Consultar Código do pedido, nome do cliente e idade atual do cliente
SELECT DISTINCT p.codigo AS Codigo_Produto, c.nome AS Nome_Cliente, DATEDIFF(YEAR, c.data_nasc, GETDATE()) AS Idade_Cliente
FROM pedido AS p
LEFT JOIN cliente AS c ON p.cod_cli=c.codigo

--11. Consultar o nome do fornecedor do produto mais caro
SELECT TOP 1 f.nome AS Nome
FROM fornecedor AS f
LEFT JOIN produto AS p ON f.codigo = p.cod_forn
ORDER BY p.valor_unitario DESC

SELECT f.nome AS Nome, p.valor_unitario
FROM fornecedor AS f
LEFT JOIN produto AS p ON f.codigo = p.cod_forn
ORDER BY p.valor_unitario DESC

--12. Consultar a média dos valores cujos produtos ainda estão em estoque
SELECT p.nome AS nome, AVG(p.valor_unitario) AS Media
FROM produto AS p
WHERE p.qtd_estoque >0 
GROUP BY p.nome

--13. Consultar o nome do cliente, endereço composto por logradouro e número, o valor unitário do produto, 
--o valor total (Quantidade * valor unitario) da compra do cliente de nome Maria Clara

SELECT c.nome AS Nome_Cliente, CONCAT(c.logradouro, '; ', c.numero) AS Endereço, pro.valor_unitario AS Valor, 
	SUM(pro.valor_unitario) AS Valor_Total
FROM cliente AS c
LEFT JOIN pedido AS pe ON c.codigo = pe.cod_cli
LEFT JOIN produto AS pro ON pro.codigo = pe.cod_prod
WHERE c.nome = 'Maria Clara'
GROUP BY c.nome, c.logradouro, c.numero, pro.valor_unitario

--14. Considerando que o pedido de Maria Clara foi entregue 15/03/2003, consultar quantos dias houve de atraso
SELECT DATEDIFF(DAY, p.previsao_ent, '15/03/2023') AS Dias_de_Atraso
FROM pedido AS p
LEFT JOIN cliente AS c ON p.cod_cli = c.codigo
WHERE c.nome = 'Maria Clara'

--15. Caonsultar qual a nova data de entrega para o pedido de Alberto% sabendo que se pediu 9 dias a mais.
SELECT DATEADD(DAY,9,p.previsao_ent) AS Nova_Data
FROM pedido AS p
LEFT JOIN cliente AS c ON p.cod_cli = c.codigo
WHERE c.nome LIKE 'Alberto%'
