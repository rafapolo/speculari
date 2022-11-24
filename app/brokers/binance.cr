require "./exchange"

module Broker
  class Binance < Exchange
    @coins =  ["1inch", "aave", "acm", "ada", "aion", "akro", "algo", "alice", "alpha", "ankr", "ant", "ar", "ardr", "arpa", "asr", "ata", "atm", "atom", "aud", "audio", "auto", "ava", "avax", "axs", "badger", "bake", "bal", "band", "bar", "bat", "bch", "beam", "bel", "blz", "bnb", "bnt", "btc", "btcst", "btg", "bts", "btt", "burger", "busd", "bzrx", "cake", "celo", "celr", "cfx", "chr", "chz", "ckb", "cocos", "comp", "cos", "coti", "crv", "ctk", "ctsi", "ctxc", "cvc", "dash", "data", "dcr", "dego", "dent", "dgb", "dia", "dnt", "dock", "dodo", "doge", "dot", "drep", "dusk", "egld", "enj", "eos", "eps", "ern", "etc", "eth", "eur", "fet", "fil", "fio", "firo", "fis", "flm", "forth", "ftm", "ftt", "fun", "gbp", "grt", "gtc", "gto", "gxs", "hard", "hbar", "hive", "hnt", "hot", "icp", "icx", "inj", "iost", "iota", "iotx", "iris", "jst", "juv", "kava", "keep", "key", "klay", "kmd", "knc", "ksm", "lina", "link", "lit", "lpt", "lrc", "lsk", "ltc", "lto", "luna", "mana", "mask", "matic", "mbl", "mdt", "mdx", "mft", "mir", "mith", "mkr", "mtl", "nano", "nbs", "near", "neo", "nkn", "nmr", "nu", "nuls", "ocean", "og", "ogn", "om", "omg", "one", "ong", "ont", "orn", "oxt", "pax", "paxg", "perl", "perp", "pha", "pnt", "pols", "pond", "psg", "pundix", "qtum", "ramp", "reef", "ren", "rep", "rif", "rlc", "rose", "rsr", "rune", "rvn", "sand", "sc", "sfp", "shib", "skl", "slp", "snx", "sol", "srm", "stmx", "storj", "stpt", "strax", "stx", "sun", "super", "susd", "sushi", "sxp", "tct", "tfuel", "theta", "tko", "tlm", "tomo", "torn", "trb", "troy", "tru", "trx", "tusd", "twt", "uma", "unfi", "uni", "usdc", "utk", "vet", "vite", "vtho", "wan", "waves", "win", "wing", "wnxm", "wrx", "wtc", "xem", "xlm", "xmr", "xrp", "xtz", "xvg", "xvs", "yfi", "yfii", "zec", "zen", "zil", "zrx"]

    def book(coin)
      return [] of Order unless @coins.index(coin)
      book = get_json("https://api.binance.com", "/api/v3/depth?symbol=#{coin.upcase}USDT")
      orders = Array(Order).new
      asks = book["asks"]
      (0..asks.size-1).each do |i|
        order = asks[i]
        # type, value, quantity, time
        eur_price = f(order[0])
        orders << Order.new("ask", eur_price, f(order[1]) * eur_price, Time.utc.to_unix_ms.to_s)
      end

      bids = book["bids"]
      (0..bids.size-1).each do |i|
        order = bids[i]
        # type, value, quantity, time
        eur_price = f(order[0])
        orders << Order.new("bid", eur_price, f(order[1]) * eur_price, Time.utc.to_unix_ms.to_s)
      end
      orders.sort_by!{|o| o.utc}.reverse
    end

    def trades(coin)
      trades_json = get_json("https://api.binance.com", "/api/v3/trades?limit=1000&symbol=#{coin.upcase}USDT")
      trades = Array(Order).new
      (0..trades_json.size-1).each do |i|
        trade = trades_json[i]
        tipo = trade["isBuyerMaker"] == true ? "sold" : "bought"
        trades << Order.new(tipo, (f(trade["price"])), (f(trade["qty"]) * f(trade["price"])), trade["time"].to_s)
      end
      trades.sort_by{|t| t.utc}.reverse
    end
  end

end