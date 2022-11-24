require "./exchange"

module Broker

    class MercadoBitcoin < Exchange
        fantokens = %w{acm asr atm bar gal cai juv psg og}
        @coins = %w{0x zxr aave bal comp crv dai knc mkr ren axs bat link chz mana enj grt wbx btc ltc usdc xrp bch eth paxg link chz wbx snx }

        def book(coin)
            return [] of Order unless @coins.index(coin)
            book = get_json("https://www.mercadobitcoin.net", "/api/#{coin}/orderbook/")
            orders = Array(Order).new
            asks = book["asks"]
            (0..asks.size-1).each do |i|
            order = asks[i]
            # type, value, quantity, time
            orders << Order.new("ask", to_usd(f(order[0])), to_usd(f(order[1]) * f(order[0])), Time.utc.to_unix_ms.to_s)
            orders.sort_by!{|o| o.price}.reverse
            end

            bids = book["bids"]
            (0..bids.size-1).each do |i|
            order = bids[i]
            # type, value, quantity, time
            orders << Order.new("bid", to_usd(f(order[0])), to_usd(f(order[1]) * f(order[0])), Time.utc.to_unix_ms.to_s)
            end
            orders.sort_by!{|o| o.price}.reverse
        end

        def trades(coin)
            trades_json = get_json("https://www.mercadobitcoin.net", "/api/#{coin}/trades/")
            trades = Array(Order).new
            (0..trades_json.size-1).each do |i|
            trade = trades_json[i]
            type = trade["type"].to_s == "sell" ? "sold" : "bought"
            trades << Order.new(type, to_usd(f(trade["price"])), to_usd(f(trade["amount"]) * f(trade["price"])), trade["date"].to_s)
            end
            trades.sort_by{|t| t.utc}.reverse
        end
    end
end