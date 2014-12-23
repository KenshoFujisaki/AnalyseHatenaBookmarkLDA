#!/bin/sh
#mysql -A -N -uhatena -phatena -Dhatena_bookmark -e "select id from url;" | \
#	xargs -P1 -I{} bash -c \
#	  'mysql -uhatena -phatena -Dhatena_bookmark -e "select * from url_morpheme where url_id = {};" | 
#     awk '"'"'NR>1{print $3 ":" $4}'"'"' | 
#		 ruby -ne '"'"'BEGIN{agg=""}; agg=agg+$_.sub(/\n/," ");END{puts agg}'"'"


mysql -A -N -uhatena -phatena -Dhatena_bookmark -e "
  SELECT 
    concat(
      count(*), 
      ' ', 
      group_concat(
        concat(url_morpheme.morpheme_id, ':', url_morpheme.morpheme_count) 
        separator ' '
      )
    ) 
  FROM url_morpheme 
    LEFT JOIN url ON url_morpheme.url_id = url.id 
  WHERE 
    NOT EXISTS (SELECT 1 FROM stoplist WHERE stoplist.morpheme_id = url_morpheme.morpheme_id) 
  GROUP BY url.id 
  ORDER BY url.id DESC;"
