--PRODUCT DIMENSION
SELECT 
    P.ProductKey
    ,p.ProductAlternateKey
    ,CASE WHEN C.EnglishProductCategoryName IS NULL THEN 'Without Category' ELSE C.EnglishProductCategoryName END AS Category
    ,CASE WHEN S.EnglishProductSubcategoryName IS NULL THEN 'Without Subcategory' ELSE S.EnglishProductSubcategoryName END AS Subcategory
    ,P.EnglishProductName AS Product
    ,P.ModelName
    ,P.Size
    ,P.Color
    ,P.StandardCost
    ,P.ListPrice
    ,P.DealerPrice
INTO DimCustomProduct
FROM DimProduct P
LEFT JOIN DimProductSubcategory S ON P.ProductSubcategoryKey = S.ProductSubcategoryKey
LEFT JOIN DimProductCategory C ON S.ProductCategoryKey = C.ProductCategoryKey
;

-- FACT SALES TABLE
SELECT 
    -- Date
    YEAR(CONVERT(DATE,F.OrderDate)) Year
    ,MONTH(CONVERT(DATE,F.OrderDate)) Month
    ,CONVERT(DATE,F.OrderDate) AS Date
    -- Geography
    ,T.SalesTerritoryGroup
    ,G.EnglishCountryRegionName
    ,G.StateProvinceName
    ,G.City 
    -- Product
    ,CASE WHEN C.EnglishProductCategoryName IS NULL THEN 'Without Category' ELSE C.EnglishProductCategoryName END AS Category
    ,CASE WHEN S.EnglishProductSubcategoryName IS NULL THEN 'Without Subcategory' ELSE S.EnglishProductSubcategoryName END AS Subcategory
    ,P.EnglishProductName AS Product
    ,P.ModelName
    ,P.Size
    ,P.Color
    ,P.StandardCost
    ,P.ListPrice
    ,P.DealerPrice
    -- Reseller
    ,R.BusinessType
    ,R.ResellerName
    -- Promotion
    ,Prom.EnglishPromotionCategory
    ,Prom.EnglishPromotionType
    ,Prom.EnglishPromotionName
    -- Measures
    ,F.OrderQuantity
    ,F.DiscountAmount
    ,F.TotalProductCost
    ,F.SalesAmount
    ,F.Freight
FROM FactResellerSales F
LEFT JOIN DimProduct P ON F.ProductKey = P.ProductKey 
LEFT JOIN DimProductSubcategory S ON P.ProductSubcategoryKey = S.ProductSubcategoryKey
LEFT JOIN DimProductCategory C ON S.ProductCategoryKey = C.ProductCategoryKey
LEFT JOIN DimPromotion Prom ON F.PromotionKey = Prom.PromotionKey
LEFT JOIN DimSalesTerritory T ON F.SalesTerritoryKey = T.SalesTerritoryKey
LEFT JOIN DimReseller R ON R.ResellerKey = F.ResellerKey
LEFT JOIN DimGeography G ON G.GeographyKey = R.GeographyKey
;