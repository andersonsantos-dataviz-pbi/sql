/*Verificando se já existe uma tabela calendário para deleção*/
USE Teste; /*Informe a base de dados de trabalho*/  
GO  
IF OBJECT_ID (N'dbo.D_Calendario', N'U') IS NOT NULL  
DROP TABLE dbo.D_Calendario;
GO

/*Definindo o dia de inicio da semana. 1 para iniciar na segunda, 7 para iniciar no domingo.*/
SET DATEFIRST 1;

/*Criando o escopo de data inicial e data final da tabela calendário*/
DECLARE @data DATE = GETDATE() /* Definindo data atual como DATE ao invés de DATETIME*/
DECLARE @rangeStart DATE = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) -1, 0) /*Definindo o primeiro dia do ano. Para anos anteriores DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) -1, 0), para ano atual DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) */
DECLARE @rangeEnd DATE = @data /*Definindo data atual*/  

/*Criando a data inicial do contexto, para continuidade sequencial*/
DECLARE @dataContexto DATE
SET @dataContexto = @rangeStart

/*Criando tabela calendário*/
CREATE TABLE D_Calendario
(
	Data DATE,
	GrupoDia VARCHAR(6),
	Ano INT,
	GrupoAno VARCHAR(6),
	Mes INT,
	DiaAno INT,
	DiaMes INT,
	SemanaAno INT,
	SemanaAnoNominal VARCHAR(5),
	SemanaMes INT,
	DiaSemanaNome NCHAR(9),
	MesNome NCHAR(19),
	MesNomeAbreviado NCHAR(14),
	MesAno VARCHAR(10),
	GrupoMesAno VARCHAR(6),
	SeqMesAno INT,
	Trimestre VARCHAR(5)
)

WHILE @dataContexto <= @rangeEnd
BEGIN
		INSERT INTO D_Calendario
		(
			Data,
			GrupoDia,
			Ano,
			GrupoAno,
			Mes,
			DiaAno,
			DiaMes,
			SemanaAno,
			SemanaAnoNominal,
			SemanaMes,
			DiaSemanaNome,
			MesNome,
			MesNomeAbreviado,
			MesAno,
			GrupoMesAno,
			SeqMesAno,
			Trimestre

		)
		VALUES ( 
			@dataContexto,
			CASE 
				WHEN @dataContexto = @data THEN 'Atual' 
				ELSE 'Outros' 
			END,
			YEAR(@dataContexto),
			CASE 
				WHEN YEAR(@dataContexto) = YEAR(@data) THEN 'Atual' 
				ELSE 'Outros' 
			END,
			MONTH(@dataContexto),
			DATEPART(dy, @dataContexto),
			DAY(@dataContexto),
			CONCAT(YEAR(@dataContexto), DATEPART(wk, @dataContexto)),
			CONCAT(RIGHT(YEAR(@dataContexto),2),'W', DATEPART(wk, @dataContexto)),
			DATEPART(WEEK, @dataContexto) - DATEPART(WEEK, CONVERT(CHAR(6), @dataContexto, 112) + '01') + 1,
			REPLICATE(NCHAR(8203) , 7 - DATEPART(WEEKDAY,@dataContexto) ) + LEFT(DATENAME(WEEKDAY, @dataContexto),3),
			REPLICATE(NCHAR(8203) ,12 - MONTH(@dataContexto) ) + DATENAME(MONTH, @dataContexto),
			REPLICATE(NCHAR(8203) ,12 - MONTH(@dataContexto) ) + LEFT(DATENAME(MONTH, @dataContexto),3),
			LEFT(DATENAME(MONTH, @dataContexto),3) + '/' +  DATENAME(YEAR, @dataContexto),
			CASE 
				WHEN LEFT(DATENAME(MONTH, @dataContexto),3) + '/' +  DATENAME(YEAR, @dataContexto) /*Mês/Ano do contexto*/ 
				= LEFT(DATENAME(MONTH, @data),3) + '/' +  DATENAME(YEAR, @data) /*Mês/Ano Atual*/ THEN 'Atual' 
				ELSE 'Outros' 
			END,
			12 * YEAR(@dataContexto) + MONTH(@dataContexto) - 1,
			CASE
				WHEN MONTH(@dataContexto) IN (1, 2, 3) THEN '1 Tri'
				WHEN MONTH(@dataContexto) IN (4, 5, 6) THEN '2 Tri'
				WHEN MONTH(@dataContexto) IN (7, 8, 9) THEN '3 Tri'
				WHEN MONTH(@dataContexto) IN (10, 11, 12) THEN '4 Tri'
			END
		)
		SET @dataContexto = DATEADD(DAY, 1, @dataContexto)
END

SELECT * FROM D_Calendario