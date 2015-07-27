-- Download the slow_log table into a file
-- http://www.pythian.com/blog/exporting-the-mysql-slow_log-table-into-slow-query-log-format/

hostname=$1
username=$2

mysql -u $username -p -h $hostname -D mysql -s -r -e "SELECT \
CONCAT( '# Time: ', DATE_FORMAT(start_time, '%y%m%d %H%i%s'), '\n', \
'# User@Host: ', user_host, '\n', '# Query_time: ', TIME_TO_SEC(query_time),  \
'  Lock_time: ', TIME_TO_SEC(lock_time), '  Rows_sent: ', rows_sent, '  Rows_examined: ', \
rows_examined, '\n', sql_text, ';' ) FROM mysql.slow_log" > /tmp/mysql.slow_log.log
