-- Add subtotals to a query

USE AdventureWorksDW2017;
SELECT
    CASE
        WHEN T.SalesTerritoryGroup IS NULL
        THEN 'Total Worldwide'
        ELSE T.SalesTerritoryGroup
        END 'Group'
    ,CASE
        WHEN T.SalesTerritoryGroup IS NULL THEN 'Total Worldwide'
        ELSE IIF(C.EnglishProductCategoryName IS NULL, 
            'Total ' + T.SalesTerritoryGroup, 
            IIF(S.EnglishProductSubcategoryName IS NULL, 
                'Total ' + C.EnglishProductCategoryName, 
                C.EnglishProductCategoryName )) 
        END Category
    ,CASE
        WHEN T.SalesTerritoryGroup IS NULL THEN 'Total Worldwide'
        ELSE IIF(C.EnglishProductCategoryName IS NULL, 
            'Total ' + T.SalesTerritoryGroup, 
            IIF(S.EnglishProductSubcategoryName IS NULL, 
                'Total ' + C.EnglishProductCategoryName, 
                S.EnglishProductSubcategoryName )) 
        END Subcategory
    ,SUM(F.SalesAmount) Sales

FROM FactInternetSales F
LEFT JOIN DimSalesTerritory T ON F.SalesTerritoryKey = t.SalesTerritoryKey
LEFT JOIN DimProduct p ON F.ProductKey = P.ProductKey
LEFT JOIN DimProductSubcategory S ON P.ProductSubcategoryKey = S.ProductSubcategoryKey
LEFT JOIN DimProductCategory C ON S.ProductCategoryKey = C.ProductCategoryKey

GROUP BY
    T.SalesTerritoryGroup
    ,C.EnglishProductCategoryName
    ,S.EnglishProductSubcategoryName  
WITH ROLLUP;