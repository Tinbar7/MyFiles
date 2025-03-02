--Project - US_Economy_DB

-- Shows a connection between the S&P500 stocks/companies and their sectors/ sub sectors, their stock prices throughout the years, and also shows in which sectors the most wealthy people in the world are in. 



IF EXISTS (SELECT * FROM sys.databases WHERE name = 'US_Economy_DB')
    DROP DATABASE US_Economy_DB

go



Create Database  US_Economy_DB  

USE US_Economy_DB  


go

--Table 1- [dbo].[SP500Sectors] --> A creation of Sectorid per Sector 

CREATE TABLE SP500Sectors
(
    Sector_id INT PRIMARY KEY,  -- Sector ID as the primary key
    Sector_Name NVARCHAR(200) NOT NULL  -- Name of the sector
)

go


INSERT INTO SP500Sectors (Sector_Name, Sector_id)
VALUES
('Health Care',	1),
('Information Technology',	2),
('Consumer Discretionary',	3),
('Financials',	4),
('Consumer Staples',	5),
('Industrials',	6),
('Utilities',	7),
('Materials',	8),
('Real Estate',	9),
('Energy',	10),
('Communication Services',	11)
;
go



--Table 2- [dbo].[SP500Companies] --> S&P500 companies and their sectors/ sub sectors
CREATE TABLE SP500Companies
(
Symbol VARCHAR(10) PRIMARY KEY, -- Unique identifier for each company
Security_Name VARCHAR(150) NOT NULL UNIQUE,
SECTOR NVARCHAR(200) Not Null 
       CONSTRAINT sector_chk CHECK (Sector IN ('Health Care','Information Technology','Consumer Discretionary','Financials','Consumer Staples','Industrials','Utilities','Materials','Real Estate','Energy','Communication Services')), 
Sub_Sector NVARCHAR(250) NOT NULL,
Headquarters_Location VARCHAR(200) Not Null,
Date_Added DATE Not Null,
CIK INT UNIQUE, -- Central Index Key 
Founded_Year INT 
          CONSTRAINT Founded_year_chk CHECK (Founded_Year >= 1700), -- Founded year must be realistic
Sector_id INT NOT NULL 
 CONSTRAINT FK_Sector FOREIGN KEY (Sector_id) REFERENCES SP500Sectors(Sector_id)
)

GO

INSERT INTO SP500Companies
(Symbol, Security_Name, Sector, Sub_Sector, Headquarters_Location, Date_Added, CIK, Founded_Year, Sector_id)
VALUES
('A', 'Agilent Technologies', 'Health Care', 'Life Sciences Tools & Services', 'Santa Clara, California', '2000-06-05', 1090872, 1999, 1),
('AAPL', 'Apple Inc.', 'Information Technology', 'Technology Hardware, Storage & Peripherals', 'Cupertino, California', '1982-11-30', 320193, 1977, 2),
('ABBV', 'AbbVie', 'Health Care', 'Biotechnology', 'North Chicago, Illinois', '2012-12-31', 1551152, 2013, 1),
('ABNB', 'Airbnb', 'Consumer Discretionary', 'Hotels, Resorts & Cruise Lines', 'San Francisco, California', '2023-09-18', 1559720, 2008, 3),
('AMZN', 'Amazon', 'Consumer Discretionary', 'Broadline Retail', 'Seattle, Washington', '2005-11-18', 1018724, 1994, 3),
('META', 'Meta Platforms', 'Communication Services', 'Interactive Media & Services', 'Menlo Park, California', '2013-12-23', 1326801, 2004, 11),
('MSFT', 'Microsoft', 'Information Technology', 'Systems Software', 'Redmond, Washington', '1994-06-01', 789019, 1975, 2),
('TSLA', 'Tesla Inc.', 'Consumer Discretionary', 'Automobiles', 'Austin, Texas', '2010-06-29', 1318605, 2003, 3),
('NFLX', 'Netflix', 'Communication Services', 'Movies & Entertainment', 'Los Gatos, California', '2002-05-23', 1065280, 1997, 11),
('GOOGL', 'Alphabet Inc.', 'Communication Services', 'Interactive Media & Services', 'Mountain View, California', '2004-08-19', 1652044, 1998, 11),
('NVDA', 'NVIDIA Corporation', 'Information Technology', 'Semiconductors', 'Santa Clara, California', '1999-01-22', 1045810, 1993, 2),
('BRK.A', 'Berkshire Hathaway', 'Financials', 'Multi-Sector Holdings', 'Omaha, Nebraska', '1986-04-16', 1067983, 1839, 4),
('V', 'Visa Inc.', 'Information Technology', 'Data Processing & Outsourced Services', 'San Francisco, California', '2008-03-19', 1403161, 2007, 2),
('JPM', 'JPMorgan Chase & Co.', 'Financials', 'Diversified Banks', 'New York City, New York', '1968-09-01', 19617, 1799, 4),
('XOM', 'Exxon Mobil Corporation', 'Energy', 'Integrated Oil & Gas', 'Irving, Texas', '1972-12-13', 34088, 1870, 10),
('PG', 'Procter & Gamble', 'Consumer Staples', 'Household Products', 'Cincinnati, Ohio', '1837-10-31', 80424, 1837, 5),
('KO', 'Coca-Cola', 'Consumer Staples', 'Soft Drinks', 'Atlanta, Georgia', '1892-01-29', 21344, 1892, 5),
('PEP', 'PepsiCo', 'Consumer Staples', 'Soft Drinks', 'Purchase, New York', '1965-08-17', 77476, 1898, 5),
('DIS', 'Walt Disney Co.', 'Communication Services', 'Movies & Entertainment', 'Burbank, California', '1923-10-16', 1001039, 1923, 11),
('HD', 'Home Depot', 'Consumer Discretionary', 'Home Improvement Retail', 'Atlanta, Georgia', '1978-06-29', 354950, 1978, 3),
('CVX', 'Chevron Corporation', 'Energy', 'Integrated Oil & Gas', 'San Ramon, California', '1879-09-10', 93410, 1879, 10),
('BA', 'Boeing', 'Industrials', 'Aerospace & Defense', 'Chicago, Illinois', '1916-07-15', 12927, 1916, 6),
('CAT', 'Caterpillar', 'Industrials', 'Construction Machinery & Heavy Trucks', 'Deerfield, Illinois', '1925-04-15', 18230, 1925, 6)


go

--Table 3- [dbo].[SP500CompaniesPrices] -->  S&P500 companies stock prices throughout by date

CREATE TABLE SP500CompaniesPrices
(
Symbol VARCHAR(10) NOT NULL  
        CONSTRAINT Symbol_fk foreign key (Symbol) REFERENCES SP500Companies(Symbol), -- Foreign Key to SP500Companies
Date DATE Not Null
      CONSTRAINT Datestyle_chk CHECK (Date>='1900-01-01'),

Security_Price Decimal(12,2) NOT NULL,
 Primary Key (Symbol, Date)       
)



---


go


--

INSERT INTO SP500CompaniesPrices (Symbol, Date, Security_Price)
VALUES
('AAPL', '2024-05-01', 181.18),
('AAPL', '2024-04-01', 181.91),
('AAPL', '2024-03-01', 184.25),
('AAPL', '2024-02-01', 185.64),
('AAPL', '2023-12-29', 192.53),
('TSLA', '2024-05-01', 237.49),
('TSLA', '2024-04-01', 237.93),
('TSLA', '2024-03-01', 238.45),
('TSLA', '2024-02-01', 248.42),
('TSLA', '2023-12-29', 248.48),
('MSFT', '2024-05-01', 367.75),
('MSFT', '2024-04-01', 367.94),
('MSFT', '2024-03-01', 370.6),
('MSFT', '2024-02-01', 370.87),
('MSFT', '2023-12-29', 376.04),
('MSFT', '2023-12-28', 375.28),
('GOOGL', '2024-05-01', 135.73),
('GOOGL', '2024-04-01', 136.39),
('GOOGL', '2024-03-01', 138.92),
('GOOGL', '2024-02-01', 138.17),
('GOOGL', '2023-12-29', 139.69),
('GOOGL', '2023-12-28', 140.23),
('AMZN', '2024-05-01', 145.24),
('AMZN', '2024-04-01', 144.57),
('AMZN', '2024-03-01', 148.47),
('AMZN', '2024-02-01', 149.93),
('AMZN', '2023-12-29', 151.94),
('AMZN', '2023-12-28', 153.38)

go



--
--Table 4- [dbo].[PersonWorthBySector] --> shows in which Industry-sectors the most wealthy people in the world are in.

CREATE TABLE PersonWorthBySector
(
Person_id INT Primary Key,
First_Name NVARCHAR(50) NOT NULL,
Last_Name NVARCHAR(50) NOT NULL,
Total_Net_Worth MONEY NOT NULL,
CONSTRAINT NetWorth_chk CHECK (Total_Net_Worth >= 0),
Country NVARCHAR (50) NOT NULL,
Industry NVARCHAR (100) NOT NULL,
         CONSTRAINT Industry_ck CHECK (Industry IN ('Health Care',
'Technology',
'Retail',
'Finance',
'Food & Beverage',
'Industrial',
'Services',
'Real Estate',
'Energy',
'Media & Telecom',
'Diversified',
'Commodities',
'Consumer',
'Entertainment'))
,Sector_id INT,
      CONSTRAINT Sector_id_fk FOREIGN KEY (Sector_id) REFERENCES SP500Sectors(Sector_id)
	)
	GO


	INSERT INTO PersonWorthBySector 
	(Person_id ,First_Name ,Last_Name ,
Total_Net_Worth ,Country ,Industry ,Sector_id)
	Values
	(1, 'Elon', 'Musk', 447000000000, 'United States', 'Technology', 2),
(2, 'Jeff', 'Bezos', 249000000000, 'United States', 'Technology', 2),
(3, 'Mark', 'Zuckerberg', 224000000000, 'United States', 'Technology', 2),
(4, 'Larry', 'Ellison', 198000000000, 'United States', 'Technology', 2),
(5, 'Bernard', 'Arnault', 181000000000, 'France', 'Consumer', 7),
(6, 'Larry', 'Page', 174000000000, 'United States', 'Technology', 2),
(7, 'Bill', 'Gates', 165000000000, 'United States', 'Technology', 2),
(8, 'Sergey', 'Brin', 163000000000, 'United States', 'Technology', 2),
(9, 'Steve', 'Ballmer', 155000000000, 'United States', 'Technology', 2),
(10, 'Warren', 'Buffett', 144000000000, 'United States', 'Diversified', 3),
(11, 'Jensen', 'Huang', 122000000000, 'United States', 'Technology', 2),
(12, 'Jim', 'Walton', 117000000000, 'United States', 'Retail', 3),
(13, 'Michael', 'Dell', 115000000000, 'United States', 'Technology', 2),
(14, 'Rob', 'Walton', 115000000000, 'United States', 'Retail', 3),
(15, 'Alice', 'Walton', 114000000000, 'United States', 'Retail', 3),
(16, 'Amancio', 'Ortega', 106000000000, 'Spain', 'Retail', 3),
(17, 'Mukesh', 'Ambani', 97100000000, 'India', 'Energy', 10),
(18, 'Carlos', 'Slim', 85600000000, 'Mexico', 'Diversified', 3),
(19, 'Gautam', 'Adani', 79300000000, 'India', 'Industrial', 6),
(20, 'Julia', 'Flesher Koch & family', 75900000000, 'United States', 'Industrial', 6),
(21, 'Francoise', 'Bettencourt Meyer', 75600000000, 'France', 'Consumer', 7),
(22, 'Charles', 'Koch', 68200000000, 'United States', 'Industrial', 6),
(23, 'Changpeng', 'Zhao', 63000000000, 'Canada', 'Finance', 4),
(24, 'Zhong', 'Shanshan', 58800000000, 'China', 'Diversified', 3),
(25, 'Stephen', 'Schwarzman', 58100000000, 'United States', 'Finance', 4),
(26, 'Thomas', 'Peterffy', 54000000000, 'United States', 'Finance', 4),
(27, 'Tadashi', 'Yanai', 52800000000, 'Japan', 'Retail', 3)

--
go


select* 
from [dbo].[SP500Companies]

select*
from [dbo].[SP500Sectors]

select *
from [dbo].[SP500CompaniesPrices]

select*
from [dbo].[PersonWorthBySector]