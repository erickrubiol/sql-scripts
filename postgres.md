## PostgreSQL container

For downloading and creating the official PostreSQL container:

```
sudo docker run --name postgres -e POSTGRES_PASSWORD=xxxxxxx -d -p 5432:5432 postgres
```

After the container is created is necesary to restore the sample database, download it from https://www.postgresqltutorial.com/postgresql-sample-database/ and then copying it into the container's filesystem:

``` 
sudo docker cp dvdrental.tar postgres:/home/dvdrental.tar 
```

Its mandatory to create the database before restoring it, this has to be made inside the container:

```
sudo docker exec -it postgres bash
psql -U postgres
CREATE DATABASE dvdrental;
exit
```

Finally the database can be restored with one command:

```
pg_restore -U postgres -d dvdrental /home/dvdrental.tar
```