abstract class Exchange
    property coins = Array(String).new
  
    abstract def book(coin)
    abstract def trades(coin)

    def bids(coin)
        book(coin).select{|o| o.type == "bid"}.sort_by!{|o| o.value}.reverse#[0..10]
    end

    def asks(coin)
        book(coin).select{|o| o.type == "ask"}.sort_by!{|o| o.value}#[0..10]
    end
  
    def to_s
        self.class.name.gsub("Broker::", "").downcase
    end
  end