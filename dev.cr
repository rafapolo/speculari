# abritrage!
require "./app/*"
# todo: could became a DSL!

# buy 100 BRL in XRP, if hasn't
mbtc = Broker::MercadoBitcoin.new
@invested = @xrp_last_sell_price * 100

unless mbtc.wallet.address["xrp"]["value"] >= @invested
    mbtc.wallet.order(100, "BRL", "XRP", @invested)
end
   
# send xrp to Kraken
krk = Broker::Kraken.new
mbtc.withdraw("xrp", @invested, krk.wallet.address["xrp"])

# wait xrp
while krk.wallet.address["xrp"]["value"] < @received
    wait
end

@received = @invested - @taxas
# check same transferCode ?

# xrp->eur
krk.wallet.order(@received, "xrp", "eur") # wait?
# eur->bch
krk.wallet.order(@xrp_to_euros, "eur", "bch")

# send bch to MercadoBitcoin
krk.withdraw("bch", @bch_last_sell*, mbtc.wallet.address["bch"])

# wait BCH
while krk.wallet.address["xrp"]["value"] < @xrp_last_sell_price * 100 - @taxas
    wait
end

# sell per BRL
mbtc.wallet.order(100, "BCH", "BRL", @xrp_last_sell_price+1% + @taxas)
