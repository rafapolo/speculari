require "./exchange"

module Broker
  class Braziliex < Exchange
    @coins =
    ["brl","btc","bch","ltc","eth","dash","zec","dcr","xrp","usdt","tusd","zrx","dai","paxg","sngls","brzx","gmr","omg","gnt","epc","abc","mxt","smart","nbr","bsv","crw","lcc","onix","etc","iop","btg","eos","prsp","cfty","trx"]

    def fees
      result = Hash(String, Float64).new
      fees_json = get_json("https://braziliex.com", "/api/v1/public/currencies")
      coins.each do |c|
        result[c] = to_eur fees_json[c]["txWithdrawalFee"].to_s.to_f64
      end
      result
    end

    def book(coin)
      return [] of Order unless @coins.index(coin)
      book = get_json("https://braziliex.com", "/api/v1/public/orderbook/#{coin}_brl")
      orders = Array(Order).new
      asks = book["asks"]
      (0..asks.size-1).each do |i|
        order = asks[i]
        # type, value, quantity, time
        eur_price = to_eur(f(order["price"]))
        orders << Order.new("ask", eur_price, f(order["amount"]) * eur_price, Time.utc.to_unix_ms.to_s)
      end

      bids = book["bids"]
      (0..bids.size-1).each do |i|
        order = bids[i]
        # type, value, quantity, time
        eur_price = to_eur(f(order["price"]))
        orders << Order.new("bid", eur_price, f(order["amount"]) * eur_price, Time.utc.to_unix_ms.to_s)
      end
      orders.sort_by!{|o| o.utc}.reverse
    end

    def trades(coin)
      trades_json = get_json("https://braziliex.com", "/api/v1/public/tradehistory/#{coin}_brl")
      trades = Array(Order).new
      (0..trades_json.size-1).each do |i|
        trade = trades_json[i]
        type = trade["type"].to_s == "sell" ? "sold" : "bought"
        trades << Order.new(type, to_eur(f(trade["price"])), to_eur(f(trade["amount"]) * f(trade["price"])), trade["timestamp"].to_s)
      end
      trades.sort_by{|t| t.utc}.reverse
    end
  end

end