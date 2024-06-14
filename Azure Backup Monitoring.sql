SELECT *
FROM sys.dm_database_backups
ORDER BY backup_finish_date DESC

/** Backup_Type – Type of Backup. 
D stands for Full Database Backup, 
L – Stands for Log Backup and 
I – Stands for differential backup

***/
/***In_Retention – Whether backup is within retention period or not. 
1 stands for within retention period and 
0 stands for out of retention

****/
/*** monitor Azure SQL Database History backups ***/
SELECT db.name
	,backup_start_date
	,backup_finish_date
	,CASE backup_type
		WHEN 'D'
			THEN 'Full'
		WHEN 'I'
			THEN 'Differential'
		WHEN 'L'
			THEN 'Transaction Log'
		END AS BackupType
	,CASE in_retention
		WHEN 1
			THEN 'In Retention'
		WHEN 0
			THEN 'Out of Retention'
		END AS is_Backup_Available
FROM sys.dm_database_backups AS ddb
INNER MERGE JOIN sys.databases AS db ON ddb.physical_database_name = db.physical_database_name
ORDER BY backup_start_date DESC;

SELECT DISTINCT db.name
	,CASE backup_type
		WHEN 'D'
			THEN 'Full'
		WHEN 'I'
			THEN 'Differential'
		WHEN 'L'
			THEN 'Transaction Log'
		END AS BackupType
	,CASE in_retention
		WHEN 1
			THEN 'In Retention'
		WHEN 0
			THEN 'Out of Retention'
		END AS is_Backup_Available
	,max(backup_start_date) max_start_Date
	,max(backup_finish_date) max_backup_finish_date
FROM sys.dm_database_backups AS ddb
INNER MERGE JOIN sys.databases AS db ON ddb.physical_database_name = db.physical_database_name
GROUP BY db.name
	,CASE backup_type
		WHEN 'D'
			THEN 'Full'
		WHEN 'I'
			THEN 'Differential'
		WHEN 'L'
			THEN 'Transaction Log'
		END
	,CASE in_retention
		WHEN 1
			THEN 'In Retention'
		WHEN 0
			THEN 'Out of Retention'
		END
ORDER BY 3
