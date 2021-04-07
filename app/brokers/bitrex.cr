require "./exchange"

module Broker
    class Bitrex < Exchange
        @coins = ["aave", "ada", "bal", "band", "bch", "bsv", "btc", "cro", "dot", "eth", "knc", "renbtc", "ren", "trx", "uma", "usd", "usdt", "xlm", "xrp", "yfl"]

        def book(coin)
            return [] of Order unless @coins.index(coin)
            book = get_json("https://api.bittrex.com", "/v3/markets/#{coin}-EUR/orderbook")
            orders = Array(Order).new
            asks = book["ask"]
            (0..asks.size-1).each do |i|
                order = asks[i]
                # type, value, quantity, time
                orders << Order.new("ask", (f(order["rate"])), (f(order["quantity"]) * f(order["rate"])), Time.utc.to_unix_ms.to_s)
            end

            bids = book["bid"]
            (0..bids.size-1).each do |i|
                order = bids[i]
                # type, value, quantity, time
                orders << Order.new("bid", (f(order["rate"])), (f(order["quantity"]) * f(order["rate"])), Time.utc.to_unix_ms.to_s)
            end
            orders.sort_by!{|o| o.utc}.reverse
        end

        def trades(coin)
            return [] of Order unless @coins.index(coin)
            book = get_json("https://api.bittrex.com", "/v3/markets/#{coin}-EUR/trades")
            trades = Array(Order).new
            (0..book.size-1).each do |i|
                trade = book[i]
                # type, value, quantity, time
                type = trade["takerSide"] == "SELL" ? "sold" : "bought"
                trades << Order.new(type, (f(trade["rate"])), (f(trade["rate"]) * f(trade["quantity"])), trade["executedAt"].to_s)
            end
            trades.sort_by{|t| t.utc}.reverse
        end
    end
end