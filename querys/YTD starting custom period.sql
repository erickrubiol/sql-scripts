-- Retrieve the cumulative sales starting from a specific period (jul-2012) and its previous year version 

USE AdventureWorksDW2017;
WITH Sales AS (
    SELECT  
        (D.CalendarYear) CalendarYear
        ,D.MonthNumberOfYear
        ,SUM(F.SalesAmount) Sales
        ,IIF( (D.CalendarYear * 100 + D.MonthNumberOfYear) > 201206, 1, 0) flag
        ,SUM(
            IIF( (D.CalendarYear * 100 + D.MonthNumberOfYear) > 201206, SUM(F.SalesAmount), 0) 
            ) OVER ( ORDER BY D.CalendarYear ,D.MonthNumberOfYear) CumulativeSales
    FROM FactInternetSales F
    JOIN DimDate D 
        ON F.OrderDateKey = D.DateKey
    GROUP BY D.CalendarYear, D.MonthNumberOfYear
),

SalesLY AS (
    SELECT  
        (D.CalendarYear + 1) CalendarYear
        ,D.MonthNumberOfYear
        ,SUM(F.SalesAmount) Sales
        ,IIF( (D.CalendarYear * 100 + D.MonthNumberOfYear) > 201106, 1, 0) flag
        ,SUM(
            IIF( (D.CalendarYear * 100 + D.MonthNumberOfYear) > 201106, SUM(F.SalesAmount), 0) 
            ) OVER ( ORDER BY D.CalendarYear ,D.MonthNumberOfYear) CumulativeSales
    FROM FactInternetSales F
    JOIN DimDate D 
        ON F.OrderDateKey = D.DateKey
    GROUP BY D.CalendarYear, D.MonthNumberOfYear
)


SELECT 
    A.CalendarYear
    ,A.MonthNumberOfYear
    ,A.Sales
    ,A.CumulativeSales
    ,B.Sales Sales_LY
    ,B.CumulativeSales CumulativeSales_LY
FROM Sales A
JOIN SalesLY B
ON A.CalendarYear = B.CalendarYear AND A.MonthNumberOfYear = B.MonthNumberOfYear