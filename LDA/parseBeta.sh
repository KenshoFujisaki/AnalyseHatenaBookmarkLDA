#!/bin/bash

#引数理解
if [ $# -ne 3 ]; then
	echo "usage: ./parseBeta model.beta number_of_topics number_of_rankings"
	exit 1
fi
input_file=$1
file_prefix=${input_file%.beta}
number_of_topics=$2
number_of_rankings=$3

mkdir -p ./wordcloud/visualize_csv/$file_prefix
echo "./wordcloud/visualize_csv/$file_prefix folder is created."

cat $input_file | ruby -ne '
	#初期化
	BEGIN{ar = []; row = 0; output_length = '"$number_of_rankings"'};

	#行列を変数に格納
	rowElms=$_.split(" "); 
	ar[row] = []; 
	for col in 0..rowElms.length-1; 
		ar[row][col] = rowElms[col].to_f; 
	end; 
	row+=1; 
	print "." if ARGF.lineno % 1000==0
	
	END{
		puts "loading file is finished."

		#各トピックについての単語の生起確率（arの転置行列を，各行の中で列の値でソート）
		#  トピック１ [{最大生起単語の確率,morpheme_id}，{第２生起単語の確率,morpheme_id}，{第３生起単語の確率,morpheme_id}．．．]
		#  トピック２ [{最大生起単語の確率,morpheme_id}，{第２生起単語の確率,morpheme_id}，{第３生起単語の確率,morpheme_id}．．．]
		sorted_ar = []
		topic_id = 0
		for col in 0..ar[0].length-1;
			print ".";
			sorted_cols = [];
			for row in 0..ar.length-1;
				sorted_cols[row] = [ar[row][col], row+1];
			end;
			sorted_cols.sort!{|a,b| (-1) * (a[0]<=>b[0])}
			sorted_ar[topic_id] = sorted_cols.slice!(0..output_length-1);
			topic_id += 1;
		end
		ar = nil;
		puts "sorting array is finished.";

		#各トピックについて単語の生起確率を上位N個出力
		for topic_id in 0..sorted_ar.length-1;
			alpha = `cat '"$file_prefix"'.alpha`;
			alpha_topic_score = alpha.split(" ")[topic_id].to_f;
			puts "topic" + (topic_id+1).to_s + ":" + alpha_topic_score.to_s;

			file = "./wordcloud/visualize_csv/'"$file_prefix"'/topic" + topic_id.to_s + ".csv"
			open(file, "w") {|f|
				f.write("name,value\n");
				morpheme_score_max = sorted_ar[topic_id][0][0];
				for word_id in 0..output_length-1;
					morpheme_score = sorted_ar[topic_id][word_id][0];
					morpheme_id = sorted_ar[topic_id][word_id][1];
					morpheme_name = `mysql -N -uhatena -phatena -Dhatena_bookmark -e "select name from morpheme where id = #{morpheme_id}"`;
					print morpheme_name.sub(/\n/,"") + " ";
					f.write(morpheme_name.sub(/\n/,"") + "," + "#{morpheme_score}" + "\n");
				end;
				sorted_ar[topic_id] = nil;
				print "\n\n"
			}
		end;
	}
'

#結果を画像に出力
for ((i=0; i<$number_of_topics; i++)); do
	echo "topic${i}:"
	./mkwordcloudhtml.sh "./${file_prefix}/topic${i}.csv" "./wordcloud/visualize_csv/index.html"
	wkhtmltoimage --crop-w 2000 --height 2000 --zoom 4.4 "file://`pwd`/wordcloud/visualize_csv/index.html" "./wordcloud/visualize_csv/${file_prefix}/topic${i}.png"
done
rm ./wordcloud/visualize_csv/index.html
echo "image output is finished!"
