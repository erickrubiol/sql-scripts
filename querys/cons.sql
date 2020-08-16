--PRODUCT DIMENSION
SELECT 
    P.ProductKey
    ,CASE WHEN C.EnglishProductCategoryName IS NULL THEN 'Without Category' ELSE C.EnglishProductCategoryName END AS Category
    ,CASE WHEN S.EnglishProductSubcategoryName IS NULL THEN 'Without Subcategory' ELSE S.EnglishProductSubcategoryName END AS Subcategory
    ,P.EnglishProductName AS Product
    ,P.Size
    ,P.Color
INTO DimCustomProduct
FROM DimProduct P
LEFT JOIN DimProductSubcategory S ON P.ProductSubcategoryKey = S.ProductSubcategoryKey
LEFT JOIN DimProductCategory C ON S.ProductCategoryKey = C.ProductCategoryKey
;


-- 

SELECT 
    CONVERT(DATE,F.OrderDate) AS OrderDate
    ,T.SalesTerritoryCountry AS Country
    ,P.Category
    ,P.Subcategory
    ,P.Product
    ,P.Size
    ,P.Color
    ,F.SalesAmount
    ,F.OrderQuantity
    ,F.TotalProductCost
FROM FactInternetSales F
LEFT JOIN DimCustomProduct P ON F.ProductKey = P.ProductKey 
LEFT JOIN DimSalesTerritory T ON F.SalesTerritoryKey = T.SalesTerritoryKey