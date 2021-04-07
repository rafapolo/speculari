# author: rafael polo

require "kemal"
require "kilt"
require "kilt/slang"
require "option_parser"
require "./app/*"

get "/" do |env| 
  # arbs = Strategy.get_arbitrages
  # render "public/views/index.slang"
  render "public/views/arbs.slang"
end

get "/coin/:coin" do |env| 
  coin = env.params.url["coin"]
  render "public/views/coin.slang"
end

get "/:broker/:coin/orders.json" do |env| 
  env.response.content_type = "application/json"
  coin = env.params.url["coin"]
  broker = Broker.by_name(env.params.url["broker"])
  broker.book(coin).to_json if broker
end

get "/:broker/:coin/trades.json" do |env| 
  env.response.content_type = "application/json"
  coin = env.params.url["coin"]
  broker = Broker.by_name(env.params.url["broker"])
  broker.trades(coin).to_json if broker
end

config = Config.params
OptionParser.parse do |args|
  args.banner = "Usage: rico [arguments]"
  args.on("-l", "--log", "Show broker HTTP/JSON request/answer logs"){ config[:log] = true }
  args.on("-c", "--cache", "Use last cached requests"){ config[:cache] = true }
  args.on("-e EURO", "--euro=EURO", "Define EURO:BRL manually"){ |e| config[:eur_brl] = e.to_f64 }
  # args.on("-s", "--simulate", "Fake buy"){ config[:simulate] = true }
  # args.on("-a", "--assets", "Show wallets"){ Wallet.assets(:format) }
  # args.on("-t", "--total", "Sum wallets values and taxes in dolar"){ Wallet.total(:format) }
  # args.on("-o", "--orders", "Show previous orders"){ Order.all(:format) }
  args.on("-w", "--web", "Enable web mode localhost:5000"){ config[:web] = true }
  # args.on("-m MARKET", "--market=NAME", "Set market to buy"){ |m| config[:market] = m }
  # args.on("-v VALUE", "--value=VALUE", "Set value to buy in dolars"){ |v| config[:value] = v }
  # args.on("-b", "--buy", "Buy {market} and {value} from BTC") {
  #   Wallet.buy_in_dolar(config[:market].to_s.downcase, config[:value].to_s.to_f64)
  # }
  args.on("-h", "--help", "Show this help") { puts args; exit }
end

update_last_eur_brl
spawn { Broker.update! } unless config[:cache]
Kemal.run if config[:web]

# b = Broker::Braziliex.new
# k = Broker::Kraken.new

# (b.coins & k.coins).each do |coin|
#   puts coin
#   bids = b.bids(coin)
#   asks = b.asks(coin)

#   # puts b.to_s
#   bid1 = bids.first
#   ask1 = asks.first
#   # puts "last bid: #{bid1.to_s}"
#   # puts "last ask: #{ask1.to_s}"

#   bids = k.bids(coin)
#   asks = k.asks(coin)
#   # puts k.to_s
#   bid2 = bids.first
#   ask2 = asks.first
#   # puts "last bid: #{bid2.to_s}"
#   # puts "last ask: #{ask2.to_s}"

#   p = percentage(ask2.value, bid1.value)  
#   puts "<- #{p}% | #{ask2.value} : #{bid1.value}"
#   p = percentage(ask1.value, bid2.value)
#   puts "-> #{p}% | #{ask1.value} : #{bid2.value}"

#   puts
# end

finish!
