require "./brokers/*"

module Broker

  def self.all
    [Broker::MercadoBitcoin.new, Broker::Kraken.new, Broker::Bitrex.new, Broker::Braziliex.new, Broker::NovaDAX.new]
  end

  def self.update!
    update_last_eur_brl unless Config.params[:eur_brl]
    puts "Updating..."
    Broker.all.each do |b|
      b.coins.each do |coin|
        spawn { b.trades(coin) }
      end    
    end
  end

  def self.by_name(name)    
    self.all.each{|b| return b if b.to_s == name}
  end  
end