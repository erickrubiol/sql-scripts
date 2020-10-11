# sql-scripts
Contains a SQL Server laboratory for query testing, it is based on the official SQL Server 2017 container that can be downloaded from DockerHub:
https://hub.docker.com/_/microsoft-mssql-server

Container installation:

```
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=xxxxxxxxxx" \
    -e 'MSSQL_PID=Developer' -p 1433:1433 --name sqlserver17 \
    -h sqlserver17 -d mcr.microsoft.com/mssql/server:2017-latest-ubuntu
```

Copying files from host to container: `docker cp foo.txt mycontainer:/foo.txt`

Copying files from container to host: `docker cp mycontainer:/foo.txt foo.txt`

For exploring the container filesystem, this command can be used: `docker exec -t -i sqlserver17 /bin/bash`


The data used comes from the AdventureWorksDW2017 sample from Microsoft:
https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/adventure-works

