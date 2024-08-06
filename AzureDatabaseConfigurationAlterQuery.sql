-- 1) Error : The database 'MYDATABASE' has reached its size quota. Partition or delete data, drop indexes, or consult the documentation for possible resolutions.

--Query:

/*** Checking the Database present config ****/

SELECT DATABASEPROPERTYEX('MYDATABASE', 'MaxSizeInBytes') AS DatabaseDataMaxSizeInBytes

SELECT Edition = DATABASEPROPERTYEX('MYDATABASE', 'EDITION'),
ServiceObjective = DATABASEPROPERTYEX('MYDATABASE', 'ServiceObjective'),
MaxSizeInBytes =  DATABASEPROPERTYEX('MYDATABASE', 'MaxSizeInBytes');


ALTER DATABASE [MYDATABASE] MODIFY (MAXSIZE=150GB)


-- space used by the database
-- use master
USE master

SELECT TOP 1 storage_in_megabytes AS DatabaseDataSpaceUsedInMB
FROM sys.resource_stats
WHERE database_name = 'MYDATABASE'
ORDER BY end_time DESC;

-- connect to the database and execute
SELECT type_desc
	,SUM(size) / 128 AS DatabaseDataSpaceAllocatedInMB
	,SUM(size - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)) / 128 AS DatabaseDataSpaceAllocatedUnusedInMB
FROM sys.database_files
GROUP BY type_desc

-- connect to master
-- elastic pool max and unused space
SELECT TOP 1 elastic_pool_storage_limit_mb AS ElasticPoolMaxSizeInMB
	,avg_storage_percent / 100.0 * elastic_pool_storage_limit_mb AS ElasticPoolDataSpaceUsedInMB
FROM sys.elastic_pool_resource_stats
WHERE elastic_pool_name = 'pool1'
ORDER BY end_time DESC;

SELECT TOP 1 elastic_pool_storage_limit_mb AS ElasticPoolMaxSizeInMB
	,avg_storage_percent / 100.0 * elastic_pool_storage_limit_mb AS ElasticPoolDataSpaceUsedInMB
FROM sys.elastic_pool_resource_stats
WHERE elastic_pool_name = 'pool2'
ORDER BY end_time DESC;

-- connect to respective database 
-- details of space for each data partition and logs
SELECT file_id
	,name
	,CAST(FILEPROPERTY(name, 'SpaceUsed') AS BIGINT) * 8 / 1024. AS space_used_mb
	,CAST(size AS BIGINT) * 8 / 1024. AS space_allocated_mb
	,CAST(max_size AS BIGINT) * 8 / 1024. AS max_file_size_mb
FROM sys.database_files
WHERE type_desc IN (
		'ROWS'
		,'LOG'
		);
