include Helper

class Order
  include JSON::Serializable
  getter type, value, price, utc

  def initialize(@type : String, @value : Float64, @price : Float64, @utc : String)
    @utc = as_date(@utc).to_s.gsub(" UTC", "")
  end

  def to_s
    "#{self.value.round(3)} - #{self.price.round(3)}"
  end
end
