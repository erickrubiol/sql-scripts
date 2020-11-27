# Top de ventas por producto y cliente

Dada las 3 tablas siguientes en una base de datos:

1. Catalogo de productos (CatArt.csv)
2. Catalogo de productos promocionales (Promos.csv)
3. Compras realizadas (compras.csv)

Crear para cada cliente que existe en los datos un top 7 personal de los artículos que más compró del catálogo de productos promocionales, aplicando las siguientes restricciones:

- Si el cliente no compró ningún articulo promocional deberá tomar el top 7 de productos promocionales 
más vendidos para todos los clientes.

- Si el cliente compró menos de 7 productos promocionales, los productos restantes deberán
tomarse de los articulos de productos promocionales que esten relacionados de acuerdo
a su clasificación con los comprados por el cliente.

- Si el ciente compró menos de 7 productos promocionales y los productos relacionados por su clasificación no alcanzarán los 7 productos se debera tomar lo restante del top 7 de articulos mas vendidos para complementarlos.

- El Layout final deberá contener las columnas de cliente y producto en orden de más comprado (id_art1) al menos comprado (id_art7)
de la siguiente forma:

|Columna|
|-------|
|id_cliente|
|id_art1|
|id_art2|
|id_art3|
|id_art4|
|id_art5|
|id_art6|
|id_art7|