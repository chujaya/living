/*
Date: 05. 14. 2020
Description: 
This script creates create database statements that allows to attach databases with mdf/ldf files. 
The script consists of code that gathers information of database name and physical mdf/ldf location. 
The target server has to match the file system (drive letter and drive name) with the current server.
*/

DECLARE @database_id INT
DECLARE @physical_name varchar(260)
DECLARE @_string varchar(560)
DECLARE @getid CURSOR
CREATE TABLE #temp (
	string varchar(560)
)


SET @getid = CURSOR FOR
SELECT database_id, physical_name FROM sys.master_files where database_id > 4


OPEN @getid
FETCH NEXT
FROM @getid INTO @database_id, @physical_name
WHILE @@FETCH_STATUS = 0
BEGIN
	-- statement
	SET @_string = 'CREATE DATABASE [' + DB_NAME(@database_id) + '] ON (FILENAME = ''' + @physical_name + '''), '

	FETCH NEXT
	FROM @getid INTO @database_id, @physical_name

	SET @_string += '(FILENAME = ''' + @physical_name + ''') FOR ATTACH;'

	INSERT INTO #temp VALUES (@_string)
	INSERT INTO #temp VALUES ('GO')

	FETCH NEXT
	FROM @getid INTO @database_id, @physical_name
END


CLOSE @getid
DEALLOCATE @getid


SELECT * FROM #temp
DROP TABLE #temp