CREATE DATABASE PizzeriaLuigi


CREATE TABLE Pizza(
IDPizza [INT] IDENTITY(1,1) PRIMARY KEY,
Nome [NVARCHAR](30),
Descrizione [NVARCHAR](100),
Prezzo [DECIMAL],
 )

CREATE TABLE Ingrediente(
IDIngrediente [INT] IDENTITY(1,1) PRIMARY KEY,
Nome [NVARCHAR](30),
Prezzo [DECIMAL],
Scorte [INTEGER]
)

CREATE TABLE PizzaIngrediente(
IDIngrediente int,
IDPizza int,
FOREIGN KEY (IDIngrediente) REFERENCES Ingrediente(IDIngrediente),
FOREIGN KEY (IDPizza) REFERENCES Pizza(IDPizza)
)


ALTER TABLE Pizza
ADD CONSTRAINT Prezzo CHECK (Prezzo>0)

ALTER TABLE Ingrediente
ADD CONSTRAINT PrezzoI CHECK (Prezzo>0)

ALTER TABLE Ingrediente
ADD CONSTRAINT Scorte CHECK (Scorte>=0)

INSERT INTO Pizza VALUES('Margherita', 'Pomodoro, mozzarella', 5)
INSERT INTO Pizza VALUES('Bufala', 'Pomodoro, mozzarella di bufala', 7)
INSERT INTO Pizza VALUES('Diavola', 'Pomodoro, mozzarella, spianata piccante', 6)
INSERT INTO Pizza VALUES('Quattro Stagioni', 'Pomodoro, mozzarella, funghi, carciofi, cotto, olive', 6.50)
INSERT INTO Pizza VALUES('Porcini', 'Pomodoro, mozzarella, funghi porcini', 7)
INSERT INTO Pizza VALUES('Dioniso', 'Pomodoro, mozzarella, stracchino, speck, rucola, grana', 8)
INSERT INTO Pizza VALUES('Ortolana', 'Pomodoro, mozzarella, verdure di stagione', 8)
INSERT INTO Pizza VALUES('Patate e Salsiccia', 'Mozzarella, patate, salsiccia', 6)
INSERT INTO Pizza VALUES('Pomodorini', 'Mozzarella, pomodorini, ricotta', 6)
INSERT INTO Pizza VALUES('Quattro Formaggi', 'Mozzarella, provola, gorgonzola, grana', 7.50)
INSERT INTO Pizza VALUES('Caprese', 'Mozzarella, pomodoro fresco, basilico', 7.50)
INSERT INTO Pizza VALUES('Zeus', 'Mozzarella, bresaola, rucola', 7.50)


SELECT *
FROM Pizza


INSERT INTO Ingrediente VALUES('Pomodoro', 0.50, 70)
INSERT INTO Ingrediente VALUES('Mozzarella', 1.20, 40)
INSERT INTO Ingrediente VALUES('Mozzarella di bufala', 2.00, 10)
INSERT INTO Ingrediente VALUES('Spianata piccante', 1.70, 7)
INSERT INTO Ingrediente VALUES('Funghi porcini', 2.00, 9)
INSERT INTO Ingrediente VALUES('Funghi', 1.20, 13)
INSERT INTO Ingrediente VALUES('Stracchino', 1.30, 12)
INSERT INTO Ingrediente VALUES('Speck', 1.10, 20)
INSERT INTO Ingrediente VALUES('Rucola', 0.80, 30)
INSERT INTO Ingrediente VALUES('Grana', 2.30, 10)
INSERT INTO Ingrediente VALUES('Verdure di stagione', 3.00, 5)
INSERT INTO Ingrediente VALUES('Patate', 0.90, 20)
INSERT INTO Ingrediente VALUES('Salsiccia', 3.30, 6)
INSERT INTO Ingrediente VALUES('Pomodorini',  0.90, 20)
INSERT INTO Ingrediente VALUES('Ricotta', 2.70, 10)
INSERT INTO Ingrediente VALUES('Provola', 1.60, 5)
INSERT INTO Ingrediente VALUES('Gorgonzola', 2.20, 10)
INSERT INTO Ingrediente VALUES('Pomoodoro fresco', 1.70, 6)
INSERT INTO Ingrediente VALUES('Basilico', 0.50, 30)
INSERT INTO Ingrediente VALUES('Bresaola', 5.00, 10)
 
--1. Estrarre tutte le pizze con prezzo superiore a 6 euro.
SELECT *
FROM Pizza p
WHERE p.Prezzo > 6;

--2. Estrarre la pizza/le pizze più costosa/e.

SELECT Nome, Prezzo
FROM Pizza p
WHERE p.Prezzo=(
SELECT MAX(Prezzo) FROM Pizza); 

--3. Estrarre le pizze «bianche»

SELECT p.Nome, p.Descrizione
FROM Pizza p 
WHERE p.Descrizione NOT LIKE 'Pomodoro%'

--4. Estrarre le pizze che contengono funghi (di qualsiasi tipo).

SELECT p.Nome, p.Descrizione
FROM Pizza p 
WHERE p.Descrizione LIKE '%Funghi%'

--PROCEDURE: 1. Inserimento di una nuova pizza (parametri: nome, prezzo)

GO
create procedure InserisciPizza
@NuovaPizza varchar(30),
@NuovaDescrizione varchar(100),
@NuovoPrezzo decimal

AS
declare @IDPIZZA int
select @IDPIZZA=IdPizza from Pizza p where Nome=@NuovaPizza
insert into Pizza values (@NuovaPizza,@NuovaDescrizione,@NuovoPrezzo);
Go

execute InserisciPizza 'Principessa','Pomodoro, mozzarella, funghi, prosciutto cotto', 5.00

SELECT *
FROM Pizza
-- Aggiunta ingrediente
GO
create procedure InserisciIngrediente
@nuovoIngrediente varchar(30),
@NuovoPrezzo decimal,
@NuovaScorta int

AS
declare @IDINGREDIENTE int
select @IDINGREDIENTE=IdIngrediente from Ingrediente p where Nome=@nuovoIngrediente 
insert into Ingrediente values (@nuovoIngrediente, @NuovoPrezzo, @NuovaScorta);
Go
execute InserisciIngrediente 'Prosciutto cotto',1.20, 18

SELECT *
FROM Ingrediente


--2.Assegnazione di un ingrediente a una pizza (parametri: nome pizza, nome, ingrediente)

GO
 create procedure InserisciIngredientePizza 
 @nuovoIngrediente nvarchar(30),
 @Nome nvarchar(30)
 AS
begin
	begin try
	BEGIN TRANSACTION
 	insert into PizzaIngrediente values((select Nome from Pizza where Nome=@Nome),
	(select Nome from Ingrediente where Nome=@nuovoIngrediente));
	COMMIT TRAN;
	end try

	BEGIN CATCH	
		ROLLBACK TRAN;
	select ERROR_LINE() As ErrorLine, ERROR_MESSAGE() As [Messaggio d'errore] 
	END CATCH
end

execute InserisciIngredientePizza 'Basilico', 'Margherita'


 --3. Aggiornamento prezzo
 GO
 create procedure AggiornaPrezzo 
 @Nome nvarchar(30),
 @nuovoPrezzo decimal
 AS
begin
	begin try
	BEGIN TRANSACTION
 	insert into Pizza values((select p.Nome, p.Prezzo from Pizza p where p.Nome=@Nome and p.Prezzo=@nuovoPrezzo));
	COMMIT TRAN;
	end try

	BEGIN CATCH	
		ROLLBACK TRAN;
	select ERROR_LINE() As ErrorLine, ERROR_MESSAGE() As [Messaggio d'errore] 
	END CATCH
end

--4. Eliminazione di un ingrediente da una pizza (parametri: nome pizza, nome, ingrediente)
GO
CREATE PROCEDURE EliminaPizza
@IdPizza int,
@PizzaDaEliminare varchar(30),
@DescrizioneDaEliminare varchar(100)

AS
BEGIN
	IF @PizzaDaEliminare = 'Elimina'
	BEGIN
		DELETE FROM Pizza
		WHERE IDPizza = @IdPizza
	END
END

--5.Incremento del 10% del prezzo delle pizze contenenti un ingrediente (parametro: nome ingrediente) // Mi da Errore sul numero colonne
GO
CREATE PROCEDURE AumentoIngrediente
@NomeIngrediente nvarchar(30)
AS
begin
	begin try
BEGIN TRANSACTION
 	insert into PizzaIngrediente values((SELECT p.Nome, p.Prezzo
FROM PizzaIngrediente ping join Pizza p on p.IDPizza = ping.IDPizza 
join Ingrediente i on i.IDIngrediente = ping.IDIngrediente 
where i.Nome = @NomeIngrediente and p.Prezzo=p.Prezzo*1.15));
	COMMIT TRAN;
	end try

	BEGIN CATCH	
		ROLLBACK TRAN;
	select ERROR_LINE() As ErrorLine, ERROR_MESSAGE() As [Messaggio d'errore] 
	END CATCH
end



--Esercitazione FUNZIONI
--1.Tabella listino pizze (nome, prezzo) (parametri: nessuno)
GO
CREATE FUNCTION TabellaListino()
returns table 
AS
RETURN
SELECT p.Nome, p.Prezzo
FROM Pizza p

  
--2 Tabella listino pizze (nome, prezzo) contenenti un ingrediente (parametri: nome ingrediente)
GO 
CREATE FUNCTION TabellaListinoIngrediente(@NomeIngrediente varchar(30))
returns table 
AS
RETURN
SELECT p.Nome, p.Prezzo
FROM PizzaIngrediente ping join Pizza p on p.IDPizza = ping.IDPizza 
join Ingrediente i on i.IDIngrediente = ping.IDIngrediente 
where i.Nome = @NomeIngrediente

  
--3 Tabella listino pizze (nome, prezzo) che non contengono un certo ingrediente (parametri: nome ingrediente)
GO 
CREATE FUNCTION TabellaListinoSenzaIngrediente(@NomeIngrediente varchar(30))
returns table 
AS
RETURN
SELECT p.Nome, p.Prezzo
FROM PizzaIngrediente ping join Pizza p on p.IDPizza = ping.IDPizza 
join Ingrediente i on i.IDIngrediente = ping.IDIngrediente 
where i.Nome NOT LIKE @NomeIngrediente 

--4 Calcolo numero pizze contenenti un ingrediente (parametri: nome ingrediente)
GO
create function NumeroPizzeIngrediente(@NomeIngrediente varchar(30))
returns int
as
Begin
declare @numeroPizzeIngredienti int

select @numeroPizzeIngredienti=count(*)
FROM PizzaIngrediente ping join Pizza p on p.IDPizza = ping.IDPizza 
join Ingrediente i on i.IDIngrediente = ping.IDIngrediente 
where i.Nome=@NomeIngrediente 

return @numeroPizzeIngredienti
end

--5 Calcolo numero pizze che non contengono un ingrediente (parametri: codice ingrediente)
GO
create function NumeroPizzeSenzaIngrediente(@IdIngrediente int)
returns int
as
Begin
declare @numeroPizzeSenzaIngredienti int

select @numeroPizzeSenzaIngredienti=count(*)
FROM PizzaIngrediente ping join Pizza p on p.IDPizza = ping.IDPizza 
join Ingrediente i on i.IDIngrediente = ping.IDIngrediente 
where i.IDIngrediente = @IdIngrediente and @IdIngrediente = null 

return @numeroPizzeSenzaIngredienti
end


--6 Calcolo numero ingredienti contenuti in una pizza (parametri: nome pizza)
GO
create function NumeroIngredientiPizza(@NomePizza varchar(50))
returns int
as
Begin
declare @numeroIngredientiPizza int

select @numeroIngredientiPizza=count(*)
FROM PizzaIngrediente ping join Pizza p on p.IDPizza = ping.IDPizza 
join Ingrediente i on i.IDIngrediente = ping.IDIngrediente 
where i.IDIngrediente = @numeroIngredientiPizza  and @NomePizza = p.Nome

return @numeroIngredientiPizza
end

 --Realizzare una view che rappresenta il menù con tutte le pizze.
GO
    create view MenuPizza (Nome, Descrizione, Prezzo)
AS(
select p.Nome, p.Descrizione, p.Prezzo
FROM PizzaIngrediente ping join Pizza p on p.IDPizza = ping.IDPizza 
join Ingrediente i on i.IDIngrediente = ping.IDIngrediente )

   