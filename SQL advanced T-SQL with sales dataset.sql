SELECT *
FROM sales..superstore
ORDER BY CustomerID

--Running total per customer
SELECT CustomerID, OrderID, OrderDate, Sales, 
SUM(Sales) OVER (PARTITION BY CustomerID ORDER BY OrderID ROWS UNBOUNDED PRECEDING) AS RunningTotal
FROM sales..superstore

--Total Sales per customer
SELECT CustomerID, OrderID, OrderDate, Sales, 
SUM(Sales) OVER (PARTITION BY CustomerID ORDER BY OrderID RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Total
FROM sales..superstore

--Running total & Running total average for every 3 rows per customer
SELECT CustomerID, OrderID, OrderDate, Sales,
SUM(Sales) OVER (PARTITION BY CustomerID ORDER BY OrderID ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS RunningTotal,
AVG(Sales) OVER (PARTITION BY CustomerID ORDER BY OrderID ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS RunningTotalAVG
FROM sales..superstore

--First and last sale per customer
SELECT CustomerID, OrderID, OrderDate, Sales,
FIRST_VALUE(Sales) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS FirstSale,
LAST_VALUE(Sales) OVER (PARTITION BY CustomerID ORDER BY OrderDate
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS LastSale
FROM sales..superstore
ORDER BY CustomerID, OrderDate

--First 5 orders per customer and their running total 
WITH superstoreCTE AS
(
SELECT CustomerID, OrderID, OrderDate, Sales,
ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS RN,
SUM(Sales) OVER (PARTITION BY CustomerID ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS RunningTotal
FROM sales..superstore
--ORDER BY CustomerID, RN
)
SELECT CustomerID, OrderID, OrderDate, Sales, RunningTotal
FROM superstoreCTE
WHERE RN <= 5 

--Subquery to find first 3 orders
SELECT CustomerID, OrderID, OrderDate, Sales
FROM sales..superstore SS
WHERE OrderID IN
	(SELECT TOP(3) OrderID
	 FROM sales..superstore SS2
	 WHERE SS.CustomerID = SS2.CustomerID
	 ORDER BY CustomerID)

--Cross apply to find first 3 orders
SELECT SS.CustomerID, SS2.OrderID, SS2.OrderDate
FROM sales..superstore SS

CROSS APPLY

	(SELECT TOP(3) CustomerID, OrderID, OrderDate
	FROM sales..superstore SS2
	WHERE SS2.CustomerID = SS.CustomerID
	ORDER BY OrderID) SS2

--Row number to find first 3 orders
SELECT CustomerID, OrderID, OrderDate
FROM
	(SELECT CustomerID, OrderID, OrderDate,
	ROW_NUMBER() OVER (PARTITION BY CustomerID
	ORDER BY OrderID) RN 
	FROM sales..superstore) AS X
WHERE RN <= 3
