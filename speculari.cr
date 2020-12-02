# author: rafael polo

require "kemal"
require "kilt"
require "kilt/slang"
require "option_parser"
require "./app/*"

get "/" do |env| 
  render "public/views/index.slang"
end

get "/arbs" do |env| 
  # arbs = Strategy.get_arbitrages
  render "public/views/arbs.slang"
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

finish!
