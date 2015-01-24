#!/bin/sh

# データの取得
mysql -A -N -uhatena -phatena -Dhatena_bookmark -e "
  # group_concatの上限値を引き上げ
  # ref: http://blog.katty.in/3915
  SET group_concat_max_len = 10000000;

  # データの取得
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
  ORDER BY url.id DESC;" 2> /dev/null
