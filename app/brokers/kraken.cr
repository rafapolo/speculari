require "./exchange"

module Broker
    class Kraken < Exchange
        @coins =
        ["eth","btc","xrp","ltc","usdt","bch","rep","zec","ada","qtum","xtz","atom","gno","eos","mln","bat","waves","icx","link","sc","omg","paxg","nano","lsk","algo","trx","oxt","kava","comp","storj","knc","repv2","xmr","xlm","dash","dai","usdc", "xdg"]

        COIN_CODE = {
        "eth": "XETHZEUR",
        "btc": "XXBTZEUR",
        "xrp": "XXRPZEUR",
        "ltc": "XLTCZEUR",
        "usdt": "USDTEUR",
        "bch": "BCHEUR",
        "rep": "XREPZEUR",
        "zec": "XZECZEUR",
        "ada": "ADAEUR",
        "qtum": "QTUMEUR",
        "xtz": "XTZEUR",
        "atom": "ATOMEUR",
        "gno": "GNOEUR",
        "eos": "EOSEUR",
        "mln": "XMLNZEUR",
        "bat": "BATEUR",
        "waves": "WAVESEUR",
        "icx": "ICXEUR",
        "link": "LINKEUR",
        "sc": "SCEUR",
        "omg": "OMGEUR",
        "paxg": "PAXGEUR",
        "nano": "NANOEUR",
        "lsk": "LSKEUR",
        "algo": "ALGOEUR",
        "trx": "TRXEUR",
        "oxt": "OXTEUR",
        "kava": "KAVAEUR",
        "comp": "COMPEUR",
        "storj": "STORJEUR",
        "knc": "KNCEUR",
        "repv2": "REPV2EUR",
        "xmr": "XXMRZEUR",
        "xdg": "XDGEUR",
        "xlm": "XXLMZEUR",
        "dash": "DASHEUR",
        "dai": "DAIEUR",
        "usdc": "USDCEUR"
        }

        def book(coin)
        url_coin = coin=="btc" ? "xbt" : coin

        book = get_json("https://api.kraken.com", "/0/public/Depth?pair=#{url_coin}eur")["result"][COIN_CODE[coin]]

        orders = Array(Order).new
        asks = book["asks"]
        (0..asks.size-1).each do |i|
            order = asks[i]
            # type, value, quantity, time
            orders << Order.new("ask", f(order[0]), (f(order[1]) * f(order[0])), order[2].to_s)
        end

        bids = book["bids"]
        (0..bids.size-1).each do |i|
            order = bids[i]
            # type, value, quantity, time
            orders << Order.new("bid", f(order[0]), (f(order[1]) * f(order[0])), order[2].to_s)
        end

        orders.sort_by!{|o| o.utc}.reverse
        end

        def trades(coin)
        url_coin = coin=="btc" ? "xbt" : coin

        trades_json = get_json("https://api.kraken.com", "/0/public/Trades?pair=#{url_coin}eur")["result"][COIN_CODE[coin]]

        trades = Array(Order).new
        (0..trades_json.size-1).each do |i|
            trade = trades_json[i]
            type = trade[3].to_s == "s" ? "sold" : "bought"
            trades << Order.new(type, f(trade[0]), (f(trade[1]) * f(trade[0])), trade[2].to_s)
        end
        trades.sort_by{|o| o.utc}.reverse
        end
    end
end