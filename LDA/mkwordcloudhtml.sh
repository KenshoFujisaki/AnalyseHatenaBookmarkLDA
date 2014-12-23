#!/bin/bash

#コマンドライン引数理解
if [ $# -ne 2 ]; then
	echo "usage: $0 csv_file_path output_file_path"
	exit 1
fi
csv_file=$1
output_file=$2

echo '<!DOCTYPE html>
<meta charset="utf-8">
<body>
<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
<script src="../d3.layout.cloud.js"></script>
<script>
  var fill = d3.scale.category20();

  var load_csv_file = "'"$csv_file"'";

  //csv読み込み
  d3.csv(load_csv_file, function(error, data){
    var value_max = 0.0;
    var csv = data.map(function(d) {
      if(value_max < d["value"]) {
        value_max = d["value"] * 1
      }
      return {
        text: d["name"],
        size: d["value"] * 1};
    });

    //各種定数宣言
    var width = 600;
    var height = 600;
    var gap_length = 0;

    //フォントサイズが対数になるように設定
    var sizeScale = d3.scale.linear().domain([0, value_max]).range([10, 100])

    //ワードクラウド作成処理
    d3.layout.cloud().size([width, height])
        .words(csv)
        .padding(gap_length)
        .rotate(function() { return Math.round(1 - Math.random()) * 90; })
        .font("Impact")
        .fontSize(function(d) { return sizeScale(d.size); })
        .on("end", draw)
        .start();

    function draw(words) {
      d3.select("body").append("svg")
          .attr("width", width)
          .attr("height", height)
        .append("g")
          .attr("transform", "translate(150,150)")
        .selectAll("text")
          .data(words)
        .enter().append("text")
          .style("font-size", function(d) { return d.size + "px"; })
          .style("font-family", "Impact")
          .style("fill", function(d, i) { return fill(i); })
          .attr("text-anchor", "middle")
          .attr("transform", function(d) {
            return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
          })
          .text(function(d) { return d.text; });
    }
  });
</script>
</body>' > $output_file
