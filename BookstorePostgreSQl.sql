--creating and connecting to booksore database
CREATE DATABASE BookstoreDB;
\c BookstoreDB

--creating books table in bookstore database
CREATE TABLE Books(
	BookID SERIAL PRIMARY KEY,
	Title TEXT NOT NULL,
	Author VARCHAR(40) NOT NULL,
	Genre VARCHAR(30) NOT NULL,
	Price REAL NOT NULL CHECK(Price > 0),
	QuantityInStock INTEGER NOT NULL CHECK(QuantityInStock >= 0) 
);

INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock)
VALUES ('Anna Karenina', 'Leo Tolstoy', 'novel', 15.2, 10),
	   ('Jane Eyre', 'Charlotte Bronte', 'novel', 12.6, 15),
	   ('The little prince', 'Antoine de Saint-Exupery', 'fiction', 9.15, 5),
	   ('The Great Gatsby', 'F. Scott Fitzgerald', 'tragedy', 10.65, 10),
	   ('War and Peace', 'Leo Tolstoy', 'historical novel', 12.6, 20),
	   ('The Complete Sherlock Holmes', 'Arthur Conan Doyle', 'detective', 16.5, 28),
	   ('Pride and Prejudice', 'Jane Austen', 'romance', 18.25, 6),
	   ('Frankenstein', 'Mary Shelley', 'fiction', 15.6, 10),
	   ('The Lord of the Rings', 'John Ronald Reuel Tolkien', 'adventure', 20.5, 3),
	   ('Crime and Punishment', 'Fyodor Dostoevsky', 'philosophical fiction', 10.5, 30);

--creating customers table in bookstore database
CREATE TABLE Customers(
	CustomerID SERIAL PRIMARY KEY,
	Name VARCHAR(20) NOT NULL,
	Email VARCHAR(60) UNIQUE,
	Phone VARCHAR(20) NOT NULL 
);

INSERT INTO Customers(Name, Email, Phone)
VALUES('Cindy Eberz', 'ceberz@gmail.com', '37518526354'),
	  ('James Dowel', 'jdowel@gmail.com', '1458963451'),
	  ('Julia Davids', 'jdavids@gmail.com', '37458963214'),
	  ('Sara Ross', 'sross@gmail.com', '1054523614'),
	  ('Jack Peters', 'jpeters@gmail.com', '374152156');

--creating sales table that will hold foreign keys referencing primary keys of books and customers tables
CREATE TABLE Sales (
	SaleID SERIAL PRIMARY KEY,
	BookID INTEGER,
	CustomerID INTEGER,
	DateOfSale DATE,
	QuantitySold INTEGER NOT NULL CHECK(QuantitySold >= 0),
    TotalPrice REAL NOT NULL CHECK(TotalPrice >= 0),
    CONSTRAINT fk_book FOREIGN KEY (BookID) REFERENCES Books(BookID) ON DELETE SET NULL,
    CONSTRAINT fk_customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE SET NULL
);

INSERT INTO SALES(BookID, CustomerID, DateOfSale, QuantitySold, TotalPrice)
VALUES (4, 2, '2023-12-15', 1, 10.65),
	   (6, 3, '2023-02-25', 3, 49.5),
	   (8, 2, '2023-05-03', 2, 31.2),
	   (1, 1, '2023-11-12', 1, 15.2),
	   (5, 4, '2023-06-02', 2, 25.2),
	   (2, 5, '2023-10-15', 3, 37.8);

--retrieving a list of all books sold, including the book title, customer name, and date of sale
SELECT Sales.DateOfSale AS DateOfSale, Books.Title AS BookTitle, Customers.Name as CustomerName 
FROM Sales
JOIN Books ON Sales.BookID = Books.BookID
JOIN Customers ON Sales.CustomerID = Customers.CustomerID;

--finding the total revenue generated from each genre of books
SELECT Books.Genre, SUM(Sales.TotalPrice) as Revenue
FROM Sales                           
JOIN Books ON Sales.BookID = Books.BookID
GROUP BY Books.Genre;

--creating a trigger to update quantity of books in store
CREATE OR REPLACE FUNCTION update_books_quantity_in_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Books                                    
    SET QuantityInStock = QuantityInStock - NEW.QuantitySold
    WHERE BookID = NEW.BookID;                         
    RETURN NEW;
END;           
$$ LANGUAGE plpgsql;
                    
CREATE TRIGGER update_books_quantity
AFTER INSERT ON Sales
FOR EACH ROW
EXECUTE FUNCTION update_books_quantity_in_stock();
