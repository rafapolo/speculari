
module Broker
    class NovaDAX < Exchange
        @coins = ["btc", "dgb", "dcr", "eth", "bsv", "xmr", "bch", "xlm", "xrp", "waves", "etc", "trx", "btt", "eos", "ada", "bnb", "link", "dash", "ltc", "xtz", "iota", "omg", "doge", "nuls", "brz"]

        def book(coin)
            return [] of Order unless @coins.index(coin)
            book = get_json("https://api.novadax.com", "/v1/market/depth?symbol=#{coin.upcase}_BRL&limit=500")["data"]
            orders = Array(Order).new
            asks = book["asks"]
            (0..asks.size-1).each do |i|
            order = asks[i]
            # type, value, quantity, time
            orders << Order.new("ask", to_eur(f(order[0])), to_eur(f(order[1]) * f(order[0])), Time.utc.to_unix_ms.to_s)
            end

            bids = book["bids"]
            (0..bids.size-1).each do |i|
            order = bids[i]
            # type, value, quantity, time
            orders << Order.new("bid", to_eur(f(order[0])), to_eur(f(order[1]) * f(order[0])), Time.utc.to_unix_ms.to_s)
            end
            orders.sort_by!{|o| o.utc}.reverse
        end

        def trades(coin)
            trades_json = get_json("https://api.novadax.com", "/v1/market/trades?symbol=#{coin.upcase}_BRL&limit=500")["data"]
            trades = Array(Order).new
            (0..trades_json.size-1).each do |i|
            trade = trades_json[i]
            type = trade["side"].to_s == "SELL" ? "sold" : "bought"
            trades << Order.new(type, to_eur(f(trade["price"])), to_eur(f(trade["amount"]) * f(trade["price"])), trade["timestamp"].to_s)
            end
            trades.sort_by!{|t| t.utc}.reverse
        end
    end
end