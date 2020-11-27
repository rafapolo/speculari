abstract class Exchange
    property coins = Array(String).new
  
    abstract def book(coin)
    abstract def trades(coin)
  
    def to_s
        self.class.name.gsub("Broker::", "").downcase
    end
  end