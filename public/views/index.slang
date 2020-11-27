head
  title= "Speculari | 1€:R$#{Config.params[:eur_brl]}"
  meta charset="UTF-8"
  script src="js/plotly-latest.min.js"
  script src="js/umbrellajs.js"

css:
  * {margin: 0px; padding: 0px}
  body {font-family: "Ubuntu"; font-size: 12px; padding: 10px; background-image: linear-gradient(to bottom right, gray, lightgray);}
  h3 { text-align: center; font-size: 13px; padding: 3px}
  .red {color: red}
  .green { color: green}
  .faixa {display: flex}
  .quote{ text-align: center; padding: 5px; }
  .quote:hover { background-color: white; cursor: pointer}
  .seta {font-size: 19px; line-height: 35px;}
  .caixa { border: 1px solid black; display: inline-block; padding: 5px; margin: 5px; background-color: #f1f0f0;}
  #quotes{ text-align: center; padding-bottom: 20px }
  #graph { width:100%; margin: 0px auto }
  .main-svg{ background-color: rgb(255 255 255 / 0%) important! }
  #stats{text-align: right; padding-bottom: 5px}
  
javascript:
  u(document).on("DOMContentLoaded", function(){

    u(".quote").on("click", function(){
      // make Graph
      var coin = u(this).children('p:first-child').text().toLowerCase();
      var b1 = u(this).parent().attr("broker1").toLowerCase();
      var b2 = u(this).parent().attr("broker2").toLowerCase();

      Plotly.newPlot('graph', [], {}, {responsive: true});
      addTrace(b1, coin, "bought");
      addTrace(b1, coin, "sold");
      addTrace(b2, coin, "bought");
      addTrace(b2, coin, "sold");

      myPlot = document.getElementById('graph');
      myPlot.on('plotly_hover', function (eventdata){
        points = eventdata.points.map(function(i){return i.y}).sort();
        var x = points[0]
        var y = points[points.length-1]
        var perc = x < y ? ((y - x) / x) * 100.0 : - ((x - y) / y) * 100.0;
       u("#stats").text(x.toFixed(3) + " -> "+ y.toFixed(3) + " =  " + perc.toFixed(3) + "%")
      });
    });

    function addTrace(broker, coin, type){
      var antes24h = new Date(new Date() - 1000*60*60*24);
      fetch("/"+broker+"/"+coin+"/trades.json").then(function(response) {
        return response.json().then(function(json) {          
          var trades = json.filter(function(e, i) { return e.type==type && new Date(e.utc) > antes24h });
          var prices = trades.map(function(e, i){ return e.value });
          var times = trades.map(function(e, i){ return e.utc });

          var trace = {
            x: times,
            y: prices,
            name: broker + " / " + coin.toUpperCase() + " / " + type + " / " + trades.length ,
            line: {shape: 'spline'},
            hovertemplate: '%{y:$.2f}',
            type: 'scatter'
          };
          Plotly.addTraces("graph", trace);
        });
      });
    }
  
  });

body
  #quotes
    - perms = [Broker::Braziliex.new, Broker::MercadoBitcoin.new, Broker::Kraken.new, Broker::NovaDAX.new].combinations(2)
    - perms.each do |duo|
      div.caixa
        h3= "#{duo[0]} ⟷ #{duo[1]}"      
        .faixa broker1="#{duo[0]}" broker2="#{duo[1]}" 
          p.seta= "↠"
          - Strategy.offers(duo[0], duo[1]).each do |op|
            - color = op.perc < 0 ? "red" : "green"
            span.quote class=color
              p= op.coin
              p= "#{op.perc}%"
        .faixa broker1="#{duo[0]}" broker2="#{duo[1]}" 
          p.seta= "↞"
          - Strategy.offers(duo[1], duo[0]).each do |op|
            - color = op.perc < 0 ? "red" : "green"
            span.quote class=color
              p= op.coin
              p= "#{op.perc}%"
  #stats
  #graph