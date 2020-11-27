require "./exchange"

module Broker

    class MercadoBitcoin < Exchange
        @coins = ["btc", "ltc", "usdc", "xrp", "bch", "eth"]

        def book(coin)
            book = get_json("https://www.mercadobitcoin.net", "/api/#{coin}/orderbook/")
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
            trades_json = get_json("https://www.mercadobitcoin.net", "/api/#{coin}/trades/")
            trades = Array(Order).new
            (0..trades_json.size-1).each do |i|
            trade = trades_json[i]
            type = trade["type"].to_s == "sell" ? "sold" : "bought"
            trades << Order.new(type, to_eur(f(trade["price"])), to_eur(f(trade["amount"]) * f(trade["price"])), trade["date"].to_s)
            end
            trades.sort_by{|t| t.utc}.reverse
        end
    end
end