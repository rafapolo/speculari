require "./brokers/*"

module Broker

  def self.all
    [Broker::MercadoBitcoin.new, Broker::Kraken.new]
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
    return case name
    when "novadax"
      Broker::NovaDAX.new
    when "mercadobitcoin"
      Broker::MercadoBitcoin.new
    when "braziliex"
      Broker::Braziliex.new
    when "kraken"
      Broker::Kraken.new
    end    
  end  
end