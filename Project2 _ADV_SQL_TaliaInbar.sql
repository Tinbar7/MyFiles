--Project2

--Q1 

WITH T  
AS
(
    SELECT 
        YEAR(O.OrderDate) AS "Year",
         SUM(il.ExtendedPrice - iL.TaxAmount) AS "IncomePerYear", --ExtendedAmount-TaxRate
		COUNT(DISTINCT MONTH(O.OrderDate)) AS NumberOfDistinctMonths,
        SUM(il.ExtendedPrice - iL.TaxAmount) / COUNT(DISTINCT MONTH(O.OrderDate)) * 12 AS "YearlyLinearincome"	--picked quantity
    FROM 

        [Sales].[Orders] O  JOIN [Sales].[Invoices] I
    ON I.OrderID = O.OrderID
	JOIN [Sales].[InvoiceLines] IL
	on I.InvoiceID =IL.invoiceID
    GROUP BY  YEAR(O.OrderDate)
 
)
SELECT Year,IncomePerYear,NumberOfDistinctMonths, FORMAT(YearlyLinearincome,'0.00') AS "YearlyLinearIncome",
     FORMAT( ((YearlyLinearincome-LAG(YearlyLinearincome)OVER(order by YEAR ))/ LAG(YearlyLinearincome)  OVER(order by YEAR ))*100,'0.##') AS "GrowthRate"
FROM T
ORDER BY  YEAR

	

--Q2 

WITH T
AS
(

SELECT Year(O.OrderDate) AS "TheYear"
, CASE
      WHEN MONTH(o.orderdate) BETWEEN 1 AND 3 THEN 1
	  WHEN MONTH(o.orderdate) BETWEEN 4 AND 6 THEN 2
	  WHEN MONTH(o.orderdate) BETWEEN 7 AND 9 THEN 3
	  WHEN MONTH(o.orderdate) BETWEEN 10 AND 12 THEN 4
	  
	  END AS "TheQuarter"
,c.customername AS "CustomerName"
,  SUM(il.ExtendedPrice - iL.TaxAmount) AS "IncomePerYear"
From [Sales].[Orders] o join [Sales].[Customers] c
ON o.customerid = c.customerid
join [Sales].[Invoices] i
ON O.OrderID= i.OrderID
JOIN [Sales].[InvoiceLines] il
ON i.invoiceid= il.InvoiceID
Group by Year(O.OrderDate)
, CASE
      WHEN MONTH(o.orderdate) BETWEEN 1 AND 3 THEN 1
	  WHEN MONTH(o.orderdate) BETWEEN 4 AND 6 THEN 2
	  WHEN MONTH(o.orderdate) BETWEEN 7 AND 9 THEN 3
	  WHEN MONTH(o.orderdate) BETWEEN 10 AND 12 THEN 4
	  
	  END 
, c.customername

), 

Z AS
(
SELECT *, DENSE_RANK()Over(PARTITION BY TheYear, TheQuarter ORDER BY IncomePerYear DESC) AS "DNR"
FROM T

)

SELECT*
FROM Z
WHERE DNR<=5

Order By TheYear, TheQuarter, IncomePerYear DESC

go


--Q3 

SELECT TOP 10 il.stockitemid AS "StockItemID"
,il.Description AS "StockItemName"
,SUM (il.ExtendedPrice - il.TaxAmount)  AS "TotalProfit"
 FROM [Sales].[InvoiceLines] il
 Group By il.stockitemid ,il.Description
 Order By  "TotalProfit" DESC 
 go

 --Q4 

SELECT 
ROW_NUMBER() OVER ( ORDER BY (si.unitprice) DESC) AS "Rn",
si.StockItemID,
si.StockItemName AS "StockItemName"
,si.UnitPrice AS "UnitPrice",
si.RecommendedRetailPrice AS "RecommendedRetailPrice",
SUM(si.RecommendedRetailPrice - si.UnitPrice) AS "NominalProductProfit"  
,DENSE_Rank() OVER ( ORDER BY SUM(si.RecommendedRetailPrice - si.UnitPrice) DESC) AS DNR 
 FROM  Warehouse.stockitems si 
	
GROUP BY 
si.StockItemID
,si.StockItemName
,si.UnitPrice
, si.RecommendedRetailPrice 

		
ORDER BY si.UnitPrice DESC,si.RecommendedRetailPrice , SUM(si.RecommendedRetailPrice - si.UnitPrice) DESC
	


--Q5

SELECT CAST(ps.supplierid AS VARCHAR) + ' - ' + ps.SupplierName AS "SupplierDetails"
    ,STUFF (
	( SELECT ' /, ' + CAST(si.stockitemid AS VARCHAR) + ' ' + si.stockitemname
       FROM  Warehouse.StockItems si
        WHERE si.SupplierID = ps.SupplierID
		 AND si.stockitemname IS NOT NULL 
        FOR XML PATH('')), 1, 3, ''
	) AS "ProductDetails"
FROM [Purchasing].[Suppliers] ps
WHERE EXISTS (
    SELECT 1
    FROM Warehouse.StockItems si
    WHERE si.SupplierID = ps.SupplierID
    AND si.stockitemname IS NOT NULL
)
ORDER BY ps.supplierid;

--Q6 

SELECT TOP 5  i.CustomerID,c.cityName AS "CityName", co.countryName, co.Continent,co.Region, FORMAT(SUM(il.ExtendedPrice),'###,##.##') AS TotalExtendedPrice
FROM sales.invoices i JOIN sales.InvoiceLines il 
ON i.invoiceid=il.InvoiceID
JOIN sales.Customers cu
ON i.CustomerID =cu.customerid
JOIN Application.Cities c
ON cu.DeliveryCityID =c.CityID
JOIN [Application].StateProvinces sp
ON  C.StateProvinceID= SP.StateProvinceID
JOIN Application.Countries co
ON sp.CountryID = co.CountryID
GROUP BY  i.CustomerID,c.cityName, co.countryName, co.Region,  co.Continent
Order BY SUM(il.ExtendedPrice) DESC 

go



--Q7
SELECT  --Data to present in the final Table
"OrderYear"
,"OrderMonth"
,FORMAT("MonthlyTotal",'#,##') AS "MonthlyTotal"
,FORMAT("CumulativeTotal",'#,##') AS "CumulativeTotal"
FROM (
    SELECT                 
      Year(o.orderdate) AS "OrderYear"
      ,CAST(Month(o.orderdate) AS NVARCHAR) AS "OrderMonth"
      ,SUM(ol.PickedQuantity * ol.UnitPrice) AS "MonthlyTotal"
      ,SUM(SUM(ol.PickedQuantity * ol.UnitPrice)) OVER (PARTITION BY Year(o.orderdate) ORDER BY Month(o.orderdate) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "CumulativeTotal"
      ,Month(o.orderdate) AS "SortMonth" --Adding anothe column to sort the months properly due to adding another text as a month
    FROM 
        [Sales].[Orders] o JOIN [Sales].[OrderLines] ol
    ON o.OrderID = ol.OrderID
    GROUP BY Year(o.orderdate), Month(o.orderdate)

    UNION ALL --Creating the Grand total row

    SELECT 
        "OrderYear"
        ,'Grand Total' AS "OrderMonth",
        MAX("CumulativeTotal") AS "MonthlyTotal", -- Max cumulative total as monthly total
        MAX("CumulativeTotal") AS "CumulativeTotal", -- Max cumulative total as cumulative total
        13 AS "SortMonth" -- Sort to appear last
    
	FROM (         --Base table
	   SELECT 
       Year(o.orderdate) AS "OrderYear",
       SUM(ol.PickedQuantity * ol.UnitPrice) AS "MonthlyTotal",
       SUM(SUM(ol.PickedQuantity * ol.UnitPrice)) OVER (PARTITION BY Year(o.orderdate)ORDER BY Month(o.orderdate) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "CumulativeTotal"
       FROM [Sales].[Orders] o JOIN [Sales].[OrderLines] ol
       ON o.OrderID = ol.OrderID
       GROUP BY Year(o.orderdate), Month(o.orderdate)
	) AS CumulativeData -- Name of the basic table
    GROUP BY "OrderYear"
) AS  UnionResult   -- Name of the Unified Table
ORDER BY         --sorting the presented table
    "OrderYear", "SortMonth";


go


--Q8
SELECT  OrderMonth,[2013],[2014],[2015],[2016]
FROM (
   SELECT 
   Year(o.orderdate) AS "OrderYear"
   ,MONTH(o.OrderDate) AS "OrderMonth"
   ,o.orderid
   FROM sales.Orders o
) AS SourceTable
PIVOT (
   COUNT(orderid)
   FOR "OrderYear" IN ([2013],[2014],[2015],[2016])
) AS PivotTable
ORDER BY OrderMonth

go


--Q9

WITH 
GlobalMaxDate  -- Latest-Global MAX order date across-all-customers
AS 
(
   
    SELECT MAX(o.OrderDate) AS "GlobalMaxOrderDate"
    FROM Sales.Orders o
),

CustomerMaxDates  -- Latest MAX order date for-each-customer
AS 
(
    SELECT 
	  o.CustomerID
	  ,MAX(o.OrderDate) AS "CustomerLatestOrderDate"
    FROM Sales.Orders o
    GROUP BY o.CustomerID
),
BasicTable  --Basic calculations
AS 
(
    SELECT 
        c.CustomerID AS "CustomerID",
        c.CustomerName AS "CustomerName",
        o.OrderDate AS "OrderDate",
        LAG(o.OrderDate) OVER (PARTITION BY c.CustomerID ORDER BY o.OrderDate) AS "PreviousOrderDate",
        DATEDIFF(DAY, LAG(o.OrderDate) OVER (PARTITION BY c.CustomerID ORDER BY o.OrderDate), o.OrderDate) AS "DaysSincePreviousOrder"
    FROM Sales.Customers c JOIN Sales.Orders o
    ON c.CustomerID = o.CustomerID
)

SELECT --columns to present in the query
    BasicTable.CustomerID
    ,BasicTable.CustomerName
    ,BasicTable.OrderDate
    ,BasicTable.PreviousOrderDate
    ,DATEDIFF(DAY, CustomerMaxDates.CustomerLatestOrderDate, GlobalMaxDate.GlobalMaxOrderDate) AS "DaysSinceLastOrder"
	,AVG(BasicTable.DaysSincePreviousOrder) OVER (PARTITION BY BasicTable.CustomerID) AS "AVGDaysBetweenOrders",
    CASE 
        WHEN DATEDIFF(DAY, CustomerMaxDates.CustomerLatestOrderDate,GlobalMaxDate.GlobalMaxOrderDate) > 2 * AVG(BasicTable.DaysSincePreviousOrder) OVER (PARTITION BY BasicTable.CustomerID)
        THEN 'Potential Churn'
        ELSE 'Active'
    END AS "CustomerStatus"
FROM BasicTable JOIN CustomerMaxDates 
ON BasicTable.CustomerID = CustomerMaxDates.CustomerID
CROSS JOIN GlobalMaxDate -- (Global max date applies to all rows)
ORDER BY 
    BasicTable.CustomerID,
    BasicTable.OrderDate DESC;



GO

--Q10


WITH NormalizedTable AS (
    -- Normalize customer names
    SELECT 
        cc.CustomerCategoryName,
        cc.CustomerCategoryID,
        c.CustomerID,
        c.CustomerName,
        CASE 
            WHEN c.CustomerName LIKE 'Wingtip%' THEN 'Wingtip'
            WHEN c.CustomerName LIKE 'Tailspin%' THEN 'Tailspin'
            ELSE c.CustomerName
        END AS NormalizedCustomerName
    FROM 
        Sales.CustomerCategories cc
    JOIN 
        Sales.Customers c
    ON 
        cc.CustomerCategoryID = c.CustomerCategoryID
),
Counts AS (
    -- Count distinct normalized customernames per categoryname
    SELECT 
        nt.CustomerCategoryName,
        COUNT(DISTINCT NormalizedCustomerName) AS "CustomerCount"
		
    FROM 
        NormalizedTable nt
    GROUP BY 
        nt.CustomerCategoryName
)
--Presented table
SELECT
    CustomerCategoryName,
    CustomerCount AS CustomerCOUNT,
    SUM(CustomerCount) OVER() AS "TotalCustCount",
	CONCAT(ROUND( CAST(CustomerCount AS FLOAT) / SUM(CustomerCount) OVER() * 100, 2),'%') AS "DistributionFactor"

FROM 
    Counts
ORDER BY 
    CustomerCategoryName;


/*
go
SELECT*
FROM [Sales].[OrderLines]

SELECT*
FROM WideWorldImporters.SALES.Orders


SELECT*
FROM [Sales].[InvoiceLines]

SELECT*
FROM Warehouse.StockItems

SELECT* FROM sales.OrderLines
SELECT* FROM sales.Orders
GO
go

SELECT*
FROM sales.Orders o

go
*/