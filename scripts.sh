echo -e 'server/shard\tid\tselect_type\ttable\ttype\tpossible_keys\tkey\tkey_len_ref\trows\tfiltered\textra'; for server in $(awk  '/flogger/{
       if ($3 ~ /PREFIX_SERVER.+-TABLE/) {print $3}
       else if($NF ~ /[0-9]-TABLE$/) {print $NF}
     }' < /etc/hosts | sort -u); 
   do shard=${server#prod-}; 
      shard=${SCHEMA%-TABLE}; 
      echo -ne "$server/$shard\t";
      ssh "${server}" "mysql -u root -NBe 'explain QUERY' $shard";
   done
