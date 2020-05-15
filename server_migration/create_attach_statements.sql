/*
Date: 05. 14. 2020
Description: 
This script creates create database statements that allows to attach databases with mdf/ldf files. 
The script consists of code that gathers information of database name and physical data/log file location. 
The target server has to match the file system (drive letter and drive name) with the current server.
*/

DECLARE @database_id INT
DECLARE @physical_name varchar(260)
DECLARE @_string varchar(560)
DECLARE @getid CURSOR
DECLARE @getid2 CURSOR
CREATE TABLE #temp (
	string varchar(560)
)


SET @getid2 = CURSOR FOR
SELECT DISTINCT database_id FROM sys.master_files where database_id > 4

OPEN @getid2 
FETCH NEXT
FROM @getid2 INTO @database_id
WHILE @@FETCH_STATUS = 0
BEGIN

SET @getid = CURSOR FOR
SELECT physical_name FROM sys.master_files where database_id = @database_id

SET @_string = 'CREATE DATABASE [' + DB_NAME(@database_id) + '] ON (FILENAME = N'''

OPEN @getid
FETCH NEXT
FROM @getid INTO @physical_name
WHILE @@FETCH_STATUS = 0
BEGIN
	-- statement
	SET @_string += @physical_name

	FETCH NEXT
	FROM @getid INTO @physical_name
	IF @@FETCH_STATUS < 0 BREAK

	SET @_string += '''), (FILENAME = N'''

END
CLOSE @getid
DEALLOCATE @getid

SET @_string += ''') FOR ATTACH;'
INSERT INTO #temp VALUES (@_string)
INSERT INTO #temp VALUES ('GO')

FETCH NEXT
FROM @getid2 INTO @database_id

END
CLOSE @getid2
DEALLOCATE @getid2


SELECT * FROM #temp
DROP TABLE #temp
