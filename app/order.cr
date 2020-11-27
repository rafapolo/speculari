include Helper

class Order
  include JSON::Serializable
  getter type, value, price, utc

  def initialize(@type : String, @value : Float64, @price : Float64, @utc : String)
    @utc = as_date(@utc).to_s.gsub(" UTC", "")
  end
end
