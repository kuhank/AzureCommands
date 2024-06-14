-- Database Creation
--use master or any database
CREATE DATABASE [DBname]

--Check for pricing tier and Elastic pool
---connect to the new database
SELECT d.name
	,slo.*
FROM sys.databases d
JOIN sys.database_service_objectives slo ON d.database_id = slo.database_id;

--Checking elastic pool size
---connect to master DB
SELECT TOP 1 elastic_pool_storage_limit_mb AS ElasticPoolMaxSizeInMB
	,*
FROM sys.elastic_pool_resource_stats
WHERE elastic_pool_name LIKE 'ElasticPoolname'
ORDER BY end_time DESC;

--Change the pricing tier or Elastic pool
---connect to any DB
ALTER DATABASE [DBname] MODIFY (SERVICE_OBJECTIVE = ELASTIC_POOL(name = ElasticPoolname));

-- create login
---connect to that new database
CREATE LOGIN NewUser
	WITH PASSWORD = 'Password'

CREATE USER NewUser
FROM LOGIN NewUser;

-- Granting Access to the user
GRANT EXECUTE
	TO NewUser

GRANT ALL
	TO NewUser

GRANT SELECT
	,INSERT
	,UPDATE
	,DELETE
	TO NewUser

GRANT CONNECT
	TO NewUser

GRANT ALTER
	TO NewUser

GRANT REFERENCES
	TO NewUser
