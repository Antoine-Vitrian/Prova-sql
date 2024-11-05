-- Prova SQL

CREATE DATABASE Loja_Prova

USE Loja_Prova

-- Cria��o das tabelas
CREATE TABLE Clientes (
	ID_Cliente INT PRIMARY KEY,
	Nome VARCHAR(100),
	Idade INT,
	Data_Cadastro DATE
	)

CREATE TABLE Produtos (
	ID_Produto INT PRIMARY KEY,
	Nome_Produto VARCHAR(100),
	Pre�o FLOAT,
	)

CREATE TABLE Vendas (
	ID_Venda INT PRIMARY KEY,
	ID_Produto INT,
	ID_Cliente INT,
	Valor FLOAT,
	Quantidade INT,
	Data_Venda DATE
	)


-- Inserindo valores
INSERT INTO Clientes(ID_Cliente, Nome, Idade, Data_Cadastro)
VALUES
	( 1, 'Alvaro Ramos', 25, '2021-05-20'),
	( 2, 'Ricardo Nunes', 52, '2022-02-04'),
	( 3, 'L�o Pel�', 32, '2022-09-15')

SELECT *
FROM Clientes

INSERT INTO Produtos(ID_Produto, Nome_Produto, Pre�o)
VALUES
	( 1, 'FIFA 24', 300.00),
	( 2, 'PES 20', 150.00),
	( 3, 'F1 24', 190.00)

SELECT *
FROM Produtos

INSERT INTO Vendas(ID_Venda,ID_Produto,ID_Cliente, Valor, Quantidade, Data_Venda)
VALUES
	( 1, 2, 2, 150.00, 1, '2024-02-12'),
	( 2, 3, 1, 280.00, 2, '2024-06-06'),
	( 3, 2, 1, 150.00, 1, '2024-07-26')

SELECT *
FROM Vendas

-- Views
 -- � consulta que voc� salva, para facilitar se quiser faz�-la novamente
 -- Esta View permite visualizar o valor total de vendas

CREATE OR ALTER VIEW Valor_Total_Vendas
AS
SELECT 
	SUM(Valor) AS 'Total Vendas'
FROM Vendas

SELECT * FROM Valor_Total_Vendas

-- Subqueries
 -- � uma consulta dentro de uma consulta
 -- esse c�digo permite visualizar os clientes que fizeram alguma compra

SELECT
	ID_Cliente,
	Nome
FROM Clientes
WHERE ID_Cliente IN (
	SELECT 
		ID_Cliente
	FROM Vendas
)

-- CTE'S
-- Tabelas tempor�rias que n�o s�o salvas no Banco de Dados
-- este c�digo permite visualizar as vendas de determinado produto

WITH VendaPES20 
AS (
SELECT *
FROM Vendas
WHERE ID_Produto = 2
)

SELECT *
FROM VendaPES20

-- Window Functions
-- Permitem realizar c�lculos em um conjunto de linhas relacionado � linha atual, sem a necessidade de agregar os dados
-- este c�digo cria um id para cada valor de venda

SELECT
	ID_Venda,
	Valor,
	ROW_NUMBER() OVER(PARTITION BY Valor ORDER BY Valor) AS 'ID_Valor'
FROM Vendas

-- Functions
-- S�o fun��es que funcionam na mesma l�gica que no Javascript
-- A FUN��O N�O EST� FUNCIONANDO, MAS O RESTO EST� FEITO


CREATE FUNCTION dbo.fn_TotalVendasProduto (@produtoId INT)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @totalVendas DECIMAL(18, 2);
   
    SELECT @totalVendas = SUM(Quantidade)
    FROM Vendas
    WHERE ID_Produto = @produtoId;

    RETURN @totalVendas;
END


SELECT TOP(1)
    Nome_Produto,
    dbo.fn_TotalVendasProduto(ID_Produto) AS TotalVendas
FROM
    Vendas


-- Loops
-- S�o eventos que acontecem at� um determinado momento de acordo com uma condi��o
-- Este Loop permite a contagem de quantos registros h� em cada tabela

DECLARE @tabelaAtual INT = 1;
DECLARE @totalTabelas INT = 3;
DECLARE @nomeTabelas VARCHAR(50);
DECLARE @quantidade INT;

WHILE @tabelaAtual <= @totalTabelas
BEGIN
    SET @nomeTabelas = CASE @tabelaAtual
                      WHEN 1 THEN 'Clientes'
                      WHEN 2 THEN 'Produtos'
                      WHEN 3 THEN 'Vendas'
                      END; 

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'SELECT @quantidade = COUNT(*) FROM ' + @nomeTabelas;

    EXEC sp_executesql @sql, N'@quantidade INT OUTPUT', @quantidade OUTPUT;

    PRINT 'A tabela ' + @nomeTabelas + ' possui ' + CAST(@quantidade AS VARCHAR) + ' registros.';

    SET @tabelaAtual = @tabelaAtual + 1;
END


-- Procedures
 -- Eles permitem encapsular l�gica complexa, reutilizar c�digo e melhorar a seguran�a e o desempenho
 -- Esta Procedure permite visualizar o total de clientes dessa loja

IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'P' AND NAME = 'TotalClientes')
	BEGIN
		DROP PROCEDURE TotalClientes
	END
GO

CREATE OR ALTER PROCEDURE TotalClientes
AS
SELECT
	COUNT(ID_Cliente) AS 'N� Clientes'
FROM Clientes
GO

EXEC TotalClientes
	
-- Triggers
-- S�o gatilhos salvos e automatizados que ocorrem a partir de um INSERT|DELETE|UPDATE
-- Este trigger mostra a mensagem de "Cliente adicionado com sucesso!" a cada cliente adicionado

CREATE OR ALTER TRIGGER Adicionar_Cliente
ON Clientes
INSTEAD OF INSERT
AS
BEGIN
	PRINT('Cliente adicionado com sucesso!')
END
GO

INSERT INTO Clientes(ID_Cliente, Nome, Idade, Data_Cadastro)
VALUES
	( 4, 'Donald Trump', 67, '2024-06-20')

