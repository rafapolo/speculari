html
  head
    title= "Speculari | €/R$#{Config.params[:eur_brl]}"
    meta charset="UTF-8"
    script src="/js/plotly-latest.min.js"
    script src="/js/umbrellajs.js"

  css:
    * {margin: 0px; padding: 0px}
    body { font-family: "Ubuntu"; font-size: 13px; padding: 10px; text-align: center; background-image: linear-gradient(to bottom right, gray, lightgray);}
    .arb { width: 65%; padding: 5px; display: inline-block } 
    .graph { border: 1px solid black; }
    .stats{ text-align: right; padding: 5px; position: relative; top: -25px;}
    .red{color: red}
    .green{color: green}  
    .lado{display: inline-block; padding: 3px;}
    .center{text-align: center}
    .book{vertical-align: top; font-weight: 500; font-size: 13px; padding-top: 30px; background-color: white; display: inline-block; border: 1px solid black; padding: 20px; margin: 5px;}


  javascript:
    u(document).on("DOMContentLoaded", function(){

      u(".graph").each(function(i){
        createGraph(u(i).attr("coin"), u(i).attr("b1"), u(i).attr("b2"))
      })

      function createGraph(coin, b1, b2){
        var id = "graph-"+b1+"-"+b2+"-"+coin;
        var layout = {
          title: coin.toUpperCase(), // + " | " + b1 + " ⟷ " + b2,
          legend: {
            x: 0.1,
            y: 1.15,
            orientation: "h",
            font: {
              family: 'Ubuntu',
              size: 11,
              color: '#000'
            }
          }
        };
        Plotly.newPlot(id, [], layout, {responsive: true});
        addTrace(id, b1, coin, "bought");
        addTrace(id, b1, coin, "sold");
        addTrace(id, b2, coin, "bought");
        addTrace(id, b2, coin, "sold");

        myPlot = document.getElementById(id);
        myPlot.on('plotly_hover', function (eventdata){
          points = eventdata.points.map(function(i){return i.y}).sort();
          var x = points[0]
          var y = points[points.length-1]
          var perc = x < y ? ((y - x) / x) * 100.0 : - ((x - y) / y) * 100.0;
         u("#stats-"+b1+"-"+b2+"-"+coin).text(x + " -> "+ y + " =  " + perc.toFixed(3) + "%");
        });
      };

      function addTrace(id, broker, coin, type){      
        var horasAntes = new Date(new Date() - 1000*60*60*3);
        fetch("/"+broker+"/"+coin+"/trades.json").then(function(response) {
          return response.json().then(function(json) {          
            var trades = json.filter(function(e, i) { return e.type==type && new Date(e.utc) >= horasAntes });
            var prices = trades.map(function(e, i){ return e.value.toFixed(3) });
            var times = trades.map(function(e, i){ return e.utc });
            var values = trades.map(function(e, i){ return e.price.toFixed(2) });
            var avg = prices.reduce((a, b) => (parseFloat(a) + parseFloat(b))) / prices.length;
            var symb = type == "bought" ? " < " : " > ";

            var trace = {
              x: times,
              y: prices,
              name: broker + symb + trades.length,
              text: values,
              line: {shape: 'spline'},
              hovertemplate: '%{y:€.2f}',
              type: 'scatter',
              hovertemplate: 'R$%{y:€.2f}<br>Total: %{text}',
              mode: 'lines+markers',
              marker: { size: 4 }
            };
            Plotly.addTraces(id, trace);
          });
        });
      }
    
    });

  body
      - perms = Broker.all.combinations(2)
      - perms.each do |duo|
        #quotes
          .arb
              .graph b1=duo[0].to_s b2=duo[1].to_s coin=coin id="graph-#{duo[0].to_s}-#{duo[1].to_s}-#{coin}"
              p.stats b1=duo[0].to_s b2=duo[1].to_s coin=coin id="stats-#{duo[0].to_s}-#{duo[1].to_s}-#{coin}" %
          .book
              .lado
                  p= duo[0].to_s
                  br
                  .green.center
                      - duo[0].bids(coin)[0..20].reverse.each do |o|
                          p= o
                  .red.center
                      - duo[0].asks(coin)[0..20].each do |o|
                          p= o
              .lado
                  p= duo[1].to_s
                  br
                  .red.center
                      - duo[1].asks(coin).reverse[0..20].each do |o|
                          p= o
                  .green.center
                      - duo[1].bids(coin)[0..20].each do |o|
                          p= o