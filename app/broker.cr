require "./brokers/*"

module Broker

  def self.all
    [Broker::MercadoBitcoin.new, Broker::Binance.new]
  end

  def self.update!
    puts "Updating..."
    b = Broker::Binance.new
    m = Broker::MercadoBitcoin.new

    (b.coins & m.coins).each do |coin|
      spawn { b.trades(coin) }
      spawn { m.trades(coin) }
    end    
  end

  def self.by_name(name)    
    self.all.each{|b| return b if b.to_s == name}
  end  
end