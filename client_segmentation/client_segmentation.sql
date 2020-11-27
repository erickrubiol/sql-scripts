/**
**************** Clasificación de clientes para determinar cómo armar su Top 7 ****************
Caso A: Cliente no compró ningún artículo promocional (tomar top 7 de productos promocionales más vendidos).
Caso B: Cliente compró menos de 7 productos promocionales (tomar restantes de acuerdo a su clasificación con
 los comprados por el cliente).
Caso C: Cliente compró menos de 7 productos promocionales y los productos relacionados por su clasificación no
 alcanzarán los 7 productos (tomar restante del top 7 de artículos más vendidos).
**/

USE test;

-- Lista única de IDs de clientes
WITH clientes (id_cliente) AS
(
    SELECT 
        DISTINCT (ID_cte)
    FROM compras
),

-- Rango de números del 1 al 7
nums AS (
    SELECT 1 AS Num UNION ALL SELECT Num + 1 AS asd
    FROM nums
    WHERE nums.Num <= 6
),

-- Tabla base que contiene los siete registros del top para cada cliente
base AS (
    SELECT *, CONCAT('id_art', TRIM(STR(Num))) AS id_top
    FROM clientes
    CROSS JOIN nums
),


cte_promo AS (
    SELECT DISTINCT(ID_cte)
    FROM compras
    LEFT JOIN Promos ON compras.id_art = Promos.ID
    WHERE [DESC] IS NOT NULL
),


top7_promo AS (
    SELECT * FROM (
        SELECT 
            row_number() over (order by COUNT(id_art) desc) as rank_ventas
            ,id_art
        FROM compras
        GROUP BY id_art
    ) top7
    WHERE rank_ventas <= 7
),


top7_venta AS (
    SELECT * FROM (
        SELECT 
            compras.id_art
            ,row_number() over (order by COUNT(compras.id_art) desc) as rank_promo
        FROM compras
        LEFT JOIN Promos ON compras.id_art = Promos.ID
        WHERE [DESC] IS NOT NULL
        GROUP BY compras.id_art, ID
    ) top_venta
    WHERE rank_promo <= 7
),


top7_categoria AS (
    SELECT * FROM (
        SELECT 
            id_clasif, 
            compras.id_art, 
            STR(id_clasif) + '_' + TRIM(STR( row_number() over (PARTITION BY id_clasif order by COUNT(compras.id_art) desc))) 
                AS id_categoria,
            row_number() over (PARTITION BY id_clasif order by COUNT(compras.id_art) desc) AS rank_promo,
            STR(id_clasif) + '_' + TRIM(STR( compras.id_art )) AS concatenado
        FROM compras
        LEFT JOIN CatArt ON compras.id_art = CatArt.id_art
        LEFT JOIN Promos ON compras.id_art = Promos.ID
        WHERE Promos.ID IS NOT NULL
        GROUP BY compras.id_art, id_clasif
    ) tp WHERE rank_promo <= 7
),

--numero de articulos en promoción que compro el cliente
promos_cliente AS (
    SELECT 
        id_cte,
        COUNT(*) AS max_prom
    FROM compras
    LEFT JOIN Promos ON compras.id_art = Promos.ID
    WHERE [DESC] IS NOT NULL
    GROUP BY id_cte
),

--categoria que más compró el cliente de artículos en promoción
top_categoria_cliente 
AS
(
    SELECT 
        id_cte, 
        id_clasif 
    FROM (
        SELECT 
            id_cte, 
            id_clasif
            ,row_number() over (PARTITION BY id_cTE order by COUNT(id_clasif) desc) as rank_promo
        FROM compras LEFT JOIN CatArt ON compras.id_art = CatArt.id_art
        GROUP BY id_cte, id_clasif
    ) test where rank_promo = 1
),

-- top de artículos que compró el cliente de artículos en promoción
top_por_cliente AS (
    SELECT 
        id_cte, 
        id_art, 
        row_number() over (PARTITION BY id_cte order by COUNT(id_art) desc) as rank_por_cliente
        ,id_cte + '_' + TRIM(STR( id_art )) id_top
    FROM compras 
    LEFT JOIN Promos ON compras.id_art = Promos.ID
    WHERE Promos.ID IS NOT NULL
    GROUP BY id_cte, id_art, id_cte + '_' + TRIM(STR( id_art ))
),


excluir AS (
    SELECT 
        top_por_cliente.id_cte + '_' + TRIM(STR(id_art)) AS exist,
        top_por_cliente.id_art
        ,top_por_cliente.id_cte
        ,top_categoria_cliente.id_clasif
        ,TRIM(STR( top_categoria_cliente.id_clasif )) + '_' + TRIM(STR( top_por_cliente.id_art )) id_cat
        ,top_por_cliente.id_cte + '_' + TRIM(STR( top_categoria_cliente.id_clasif )) + '_' + TRIM(STR( top_por_cliente.id_art )) id_excluir
    FROM top_por_cliente
    LEFT JOIN top_categoria_cliente ON top_por_cliente.id_cte = top_categoria_cliente.id_cte
    GROUP BY id_art, top_por_cliente.id_cte + '_' + TRIM(STR(id_art)), top_por_cliente.id_cte, top_categoria_cliente.id_clasif,
        TRIM(STR( top_categoria_cliente.id_clasif )) + '_' + TRIM(STR( top_por_cliente.id_art ))
),


top_arts_sin_excluidos AS (
    SELECT
        compras.id_art, compras.id_cte, Promos.ID, CatArt.id_clasif
        ,id_cte + '_' + TRIM(STR(CatArt.id_clasif)) AS id_top
    FROM compras
    LEFT JOIN Promos ON compras.id_art = Promos.ID
    LEFT JOIN CatArt ON compras.id_art = CatArt.id_art
    WHERE Promos.ID IS NOT NULL
),


top_relacionados AS (
    SELECT
        base.id_cliente
        ,top7_categoria.id_art
        ,base.id_cliente + '_' + TRIM(STR(top_categoria_cliente.id_clasif)) + '_' + TRIM(STR(top7_categoria.id_art)) AS id_cat
        ,row_number() over (PARTITION BY base.id_cliente order by COUNT(top7_categoria.id_art) desc) AS rank_promo
        ,excluir.id_excluir
    FROM base
    LEFT JOIN top_categoria_cliente ON base.id_cliente = top_categoria_cliente.id_cte
    LEFT JOIN top7_categoria ON TRIM(STR(top_categoria_cliente.id_clasif)) + '_' + TRIM(STR(base.Num)) = TRIM(top7_categoria.id_categoria)
    LEFT JOIN excluir ON base.id_cliente + '_' + TRIM(STR(top_categoria_cliente.id_clasif)) + '_' + TRIM(STR(top7_categoria.id_art)) = excluir.exist
    --AND excluir.id_excluir IS NULL AND top7_categoria.id_art IS NOT NULL
    GROUP BY base.id_cliente , top7_categoria.id_art, base.id_cliente + '_' + TRIM(STR(top_categoria_cliente.id_clasif)) + '_' +
        TRIM(STR(top7_categoria.id_art)), excluir.id_excluir
),


final AS (
    SELECT
        base.id_cliente
        ,base.id_top
        ,base.Num
        ,CASE
            WHEN top_por_cliente.id_art IS NOT NULL THEN top_por_cliente.id_art
            WHEN top_relacionados.id_art IS NOT NULL THEN top_relacionados.id_art -- CASO 2 y 3
            ELSE top7_promo.id_art -- CASO 1
            END id_articulo
    FROM base
    JOIN top7_promo ON base.Num = top7_promo.rank_ventas
    JOIN top7_venta ON base.Num = top7_venta.rank_promo
    LEFT JOIN top_por_cliente ON base.id_cliente = top_por_cliente.id_cte AND base.Num = top_por_cliente.rank_por_cliente
    LEFT JOIN promos_cliente ON base.id_cliente = promos_cliente.id_cte
    LEFT JOIN top_relacionados ON base.id_cliente + '_' + TRIM(STR(base.Num - promos_cliente.max_prom)) = top_relacionados.id_cliente + '_' +
    TRIM(STR(top_relacionados.rank_promo))
    LEFT JOIN cte_promo ON cte_promo.ID_cte= base.id_cliente
)

-- Table with final results
SELECT * FROM (
    SELECT
    BASE.id_cliente
    ,base.id_top
    ,CASE
        WHEN top_por_cliente.id_art IS NOT NULL THEN top_por_cliente.id_art
        WHEN top_relacionados.id_art IS NOT NULL THEN top_relacionados.id_art -- CASO 2 y 3
        ELSE top7_promo.id_art -- CASO 1
        END Pruebas_finales
    FROM base
    JOIN top7_promo ON base.Num = top7_promo.rank_ventas
    JOIN top7_venta ON base.Num = top7_venta.rank_promo
    LEFT JOIN top_por_cliente ON base.id_cliente = top_por_cliente.id_cte AND base.Num = top_por_cliente.rank_por_cliente
    LEFT JOIN promos_cliente ON base.id_cliente = promos_cliente.id_cte
    LEFT JOIN top_relacionados ON base.id_cliente + '_' + TRIM(STR(base.Num - promos_cliente.max_prom)) = top_relacionados.id_cliente 
        + '_' + TRIM(STR(top_relacionados.rank_promo))
    LEFT JOIN cte_promo ON cte_promo.ID_cte= base.id_cliente
) t

-- Pivot final results into its requested shape
PIVOT(
    max(Pruebas_finales)
    FOR id_top IN (
        [id_art1] ,
        [id_art2],
        [id_art3],
        [id_art4],
        [id_art5],
        [id_art6],
        [id_art7])
) AS pivot_table

ORDER BY 1 ASC;