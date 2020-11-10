## How to connect to PostgreSQL
For installing the container:
    docker run --name PostgreSQL10 -e POSTGRES_PASSWORD=password -d -p 5432:5432 postgres

    docker exec -it PostgreSQL10 bash

For connecting to the engine using the terminal:
    su postgres
    psql 
Consider that "root" execution of the PostgreSQL server is not permitted. 

    \du

    CREATE DATABASE test;

# REMEMBER TO INSTALL POSTGRES BEFORE CONNECTION TO DB