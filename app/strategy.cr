class Op
  include JSON::Serializable
  property coin, perc

  def initialize(@coin : String, @perc : Float64)
  end

end

class Strategy

    def self.offers(b1, b2)
        result = [] of Op
    
        t_s = 0.0
        coins = (b1.coins & b2.coins) - ["btc"]
        coins.each do |coin|
    
          b1_book = b1.book(coin)
          b2_book = b2.book(coin)
          begin
            price_buy = b1_book.sort_by{|o| o.value}.select{|o| o.type=="ask"}.first.value
            price_sell = b2_book.sort_by{|o| o.value}.select{|o| o.type=="bid"}.last.value
          rescue
            # when any is empty 
            price_buy = 0
            price_sell = 0
          end
    
          perc = percentage(price_buy, price_sell).round(3)
          # if perc >= -1
            result << Op.new(coin.to_s.upcase, perc) if price_buy > 0
    
          #   table = TerminalTable.new
          #   table.headings = ["b1 buy < b2 sell", "total", "%", "profit"]     
          #   sum = 0
          #   perc_t = 0
          #   count = 0
          #   # vendem em b1 por menos que compram em b2
          #   b1_book.sort_by!{|o| o.value}.select{|o|o.type=="ask" && o.value <= price_sell}.each do |o|
          #     perc = percentage(o.value, price_sell).to_f64 # taxas 0.16+0.16+0.5+0.5+send
          #     if perc >= PERC
          #       count+=1
          #       table << [o.value.round(4), "€ #{o.price.round(2)}", perc.round(2), "€ #{profit_perct(o.price, perc)}"]
          #       sum += o.price
          #       perc_t += perc
          #     end
          #   end
          #   avg_perc = perc_t/count
          #   profit = profit_perct(sum, avg_perc) 
          #   t_s += profit.to_f64
    
          #   #t(ypetions?
          #   if count>0
          #     begin
          #       # fees = get_json("https://braziliex.com", "/api/v1/public/currencies")[coin]
          #       # result << "MinWithdrawal  #{fees["MinWithdrawal"]}".colorize(:light_red)
          #       # result << "txWithdrawalFee  #{fees["txWithdrawalFee"]} = €#{to_eur(fees["txWithdrawalFee"].to_s.to_f64)}".colorize(:light_red)
          #       # result << "minDeposit  #{fees["minDeposit"]} = €#{to_eur(fees["txWithdrawalFee"].to_s.to_f64)}".colorize(:light_red)
          #       # result << "minAmountTradeUSDT  #{fees["minAmountTradeUSDT"]}".colorize(:light_red)
          #     end
          #     result << table.render.colorize(:blue)
    
          #     # past buys
          #     trades = TerminalTable.new
          #     trades.headings = ["b1 bought", "total", "%", "ago"]
          #     t = b1.trades(coin).select{|o| o.type=="bought"}[0..5].each do |t|
          #       trades << [t.value.round(4), "€#{t.price.round(2)}", percentage(t.value, price_sell).to_f64, "#{ago(t.utc)}"]
          #     end
          #     result << trades.render.colorize(:yellow)
    
          #     # next buys
          #     table = TerminalTable.new
          #     table.headings = ["b2 buy > b1 ask", "total", "%", "profit"] 
          #     # orders b2 buying > b1 selling
          #     b2_book.sort_by!{|o| o.value}.select{|o|o.type=="bid" && o.value >= price_buy}.reverse[0..5].each do |o|
          #       perc = percentage(price_buy, o.value).to_f64 # taxas 0.16+0.16+0.5+0.5+send
          #       table << [o.value.round(4), "€ #{o.price.round(2)}", perc.round(2), "€ #{profit_perct(o.price, perc)}"]
          #     end
          #     result << table.render.colorize(:green)
    
          #     # past sells
          #     trades = TerminalTable.new
          #     trades.headings = ["b2 sold", "total", "%", "ago"]
          #     t = b2.trades(coin).select{|o| o.type=="sold"}[0..5].each do |t|
          #       trades << [t.value.round(4), "€#{t.price.round(2)}", percentage(price_buy, t.value).to_f64, "#{ago(t.utc)}"]
          #     end 
          #     result << trades.render.colorize(:red)
    

          #     result << "=> invest €#{sum.round(2)} to get +#{avg_perc.round(2)}% = #{profit}".colorize(:green)
          #     result << line
          #   end
    
          #   if t_s > 0
          #     result << "=> total €#{t_s.round(2)}".colorize(:yellow)
          #     result << line
          #   end
          # end
        end
        result.sort_by!{|v| v.perc}.reverse
      end
end