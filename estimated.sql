
-- 
-- This query is executed in the catalog, the information here will entirely depend
-- on your statitics (specially depending on the innodb_sample_page_stats)
-- ANALYZE TABLE <your table>
-- | STA_IX_NM                             | Card   | Cols                                  
-- | rows_per_key    | index_total_pages | ix_leaf_pgs | %overEstTotal |

SELECT STA.STA_IX_NM, CARDINALITY AS "Card", CONCAT(COLUMNS, " Idbflds(",fields ,")") AS "Cols" , rows_per_key    ,index_total_pages ,index_leaf_pages as "ix_leaf_pgs",  round(STA.CARDINALITY*100/ITS.rows) as "%overEstTotal" 
FROM 
 ( 
   SELECT INDEX_NAME as STA_IX_NM,SEQ_IN_INDEX, CARDINALITY, GROUP_CONCAT(COLUMN_NAME SEPARATOR ', ') AS COLUMNS 
     FROM STATISTICS 
     WHERE TABLE_NAME = '<your table>' 
     GROUP BY INDEX_NAME 
     ORDER by SEQ_IN_INDEX DESC, CARDINALITY DESC
 ) STA
 INNER JOIN INNODB_INDEX_STATS  IIS ON (IIS.index_name = STA.STA_IX_NM )
 INNER JOIN INNODB_TABLE_STATS  ITS ON (IIS.table_name = ITS.table_name )
 WHERE IIS.table_name = '<your table>'
 ;
 
 
--
-- WARNING: This query will executed a count over the table
--

SET @ordcount = (SELECT count(*) as count from <your table>);

--
-- WARNING: This query could take some considerable time
--
-- | part    | <column to analyze distribution>          | Percentage from Total |

SELECT q.* , round(q.part*100/@ordcount) as "Percentage from Total" 
  FROM ( select count(*) as part, <column to analyze distribution> 
         from <your table> group by <column to analyze distribution> ) q 
   ORDER BY 3 DESC;


--
-- Other minimalistic queries, Maybe a procedure will be the best
--

select * from INNODB_TABLE_STATS WHERE table_name = '<your table>'; -- Table stats
select * from INNODB_INDEX_STATS where table_name = '<your table>'; -- Stats by entries
SELECT INDEX_NAME,COLUMN_NAME,CARDINALITY FROM STATISTICS where TABLE_NAME = '<your table>';
SELECT q.* , round(q.part*100/p.count) as "Percentage from Total" FROM ( select count(*) as part, order_status from orders group by order_status ) q , (select count(*) as count from orders) p order by 3 DESC;
SELECT INDEX_NAME,SEQ_IN_INDEX, CARDINALITY, GROUP_CONCAT(COLUMN_NAME SEPARATOR ', ') AS COLUMNS       FROM STATISTICS       WHERE TABLE_NAME = 'orders'       GROUP BY INDEX_NAME       ORDER by SEQ_IN_INDEX DESC, CARDINALITY DESC;
select * from INNODB_INDEX_STATS where table_name = '<your table>'; 
select * from INNODB_TABLE_STATS WHERE table_name = '<your table>';
select table_name , rows  , clust_size , other_size ,modified , 
from INNODB_TABLE_STATS WHERE table_name = '<your table>';


SELECT  TABLE_SCHEMA, SUM(DATA_LENGTH)/(1024*1024*1024) 'Data Size', 
        SUM(INDEX_LENGTH)/(1024*1024*1024) 'Index Size' ,
        count(*) as 'Tables'
FROM information_schema.TABLES 
where ENGINE='InnoDB' AND TABLE_SCHEMA NOT IN('mysql','information_schema')
group by TABLE_SCHEMA;

-- 
-- Gather Handler information
--

FLUSH STATUS;
-- query goes here
SHOW SESSION STATUS LIKE 'Handler%';
