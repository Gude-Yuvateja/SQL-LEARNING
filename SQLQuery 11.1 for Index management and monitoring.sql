
-- Index management and monitoring


-- List all indexes on a specific table

Sp_helpindex 'sales.dbcustomers';




-- 1. Monitor index usage

Select
	tb1.name as TableName,
	idx.name as  IndexName,
	idx.type_desc as IndexType,
	idx.is_primary_key as IsPrimaryKey,
	idx.Is_Unique as IsUnique,
	idx.is_disabled as IsDisabled,
	s.user_seeks as UserSeeks,
	s.user_scans as UserScans,
	s.user_lookups  as UserLookups,
	s.user_updates as UserUpdates,
	Coalesce(s.last_user_scan, s.last_user_lookup) as LastUpdate
from sys.indexes as idx
JOIN sys.tables as tb1
ON idx.object_id = tb1.object_id
LEFT JOIN sys.dm_db_index_usage_stats as s
ON idx.object_id = s.object_id
AND idx.index_id = s.index_id
order by TableName, IndexName;


select *
from sys.tables;


select * from sys.dm_db_index_usage_stats;




-- 2. Monitor missing indexes



select * from sys.dm_db_missing_index_details;



-- 3. Monitor duplicate indexes 


select 
	tb1.name as TableName,
	col.name as ColumnName,
	idx.name as IndexName,
	idx.type_desc as IndexType
from sys.indexes idx
JOIN sys.tables as tb1 ON idx.object_id = tb1.object_id 
JOIN sys.index_columns as ic ON idx.object_id = ic.object_id AND idx.index_id = ic.index_id
JOIN sys.columns as col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
order by TableName, ColumnName

 


-- 4. Update statistics


Select
	SCHEMA_NAME(t.schema_id) as SchemeName,
	t.name as TableName,
	s.name as StatisticsName,
	sp.last_updated as Lastupdate,
	DATEDIFF(Day, sp.last_updated, GETDATE()) as LastUpdateDay,
	sp.rows as 'Rows',
	sp.modification_counter as modificationSinceLastUpdate
from sys.stats as s
JOIN sys.tables as t
ON s.object_id = t.object_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) as sp
order by sp.modification_counter desc; 


update statistics sales.employeeLogs PK__Employee__5E5499A8BBDCBCAC;


update statistics sales.dbcustomers _WA_Sys_00000003_01142BA1;



Exec sp_updatestats;





-- 5. Monitor fragmentations


select *
from sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED')



select 
	t.name TableName,
	idx.name IndexName,
	s.avg_fragmentation_in_percent,
	s.page_count
from sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') as s
INNER JOIN sys.tables as t
ON s.object_id = t.object_id
INNER JOIN sys.indexes as idx
ON idx.object_id = s.object_id
AND idx.index_id = s.index_id
order by s.avg_fragmentation_in_percent desc;



ALter Index idx_DBCustomers_CS_FirstName ON sales.DBcustomers reorganize;


ALter Index idx_DBCustomers_CS_FirstName ON sales.DBcustomers Rebuild;





-- Execution plan



select *
from policy_HP
where  Customer_id = 'CUST00359219'

CREATE NONCLUSTERED INDEX idx_Policy_CustomerID
ON policy_HP(Customer_id)


select *
from policy_HP
order by Customer_id