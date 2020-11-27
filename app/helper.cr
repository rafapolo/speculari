require "json"
require "http/client"
require "openssl/hmac"
# require "terminal_table"
require "digest/md5"
require "colorize"

require "./config"

module Helper

  def finish!
    puts line
    puts "\t done in #{elapsed_time}".colorize(:blue)
    puts line
  end

  [Signal::QUIT, Signal::ABRT, Signal::INT, Signal::KILL, Signal::TERM].each do |s|
    s.trap do
      puts "=> Bye!".colorize(:red)
      exit
      finish!
    end
  end

  def f(el)
    el.to_s.to_f64
  end

  def z(time)
    return time < 10 ? "0#{time}" : time
  end

  def as_date(ms)
    unix = ms.to_s.scan(/\d{10}/)
    if !unix.empty? # unix time!
      date = Time.unix(unix.[0][0].to_i64)
    else
      date = Time.parse(ms, "%Y-%m-%dT%H:%M:%S.%6N", Time::Location::UTC)
    end    
  end

  def ago(ms)
    date = ms ? as_date(ms) : Time.utc unless ms    
    span = (Time.utc - date)
    days = span.days > 0 ? "#{span.days}d" : ""
    "#{days}#{z span.hours}h#{z span.minutes}m#{z span.seconds}s#{span.milliseconds}"
  end

  def intro
    puts line
    puts "\t   Renda Basica".colorize(:blue)
    puts line
  end

  def line
    "=================================".colorize(:blue)
  end

  # def log(str)
  #   pp str if Config.params[:log]
  # end

  # def get_rate(currency, coin)
  #   HTTP::Client.get("http://#{currency}.rate.sx/#{coin}").body
  # end

  def get_json(url, path)
    # @requests += 1
    md5 = Digest::MD5.hexdigest("#{url}#{path}")
    cache = "cache/#{md5}.json"
    json = ""
    begin
      if Config.params[:cache] && File.exists?(cache)
        json = File.read(cache)
        Logger.log "=> #{url}#{path}".colorize(:yellow)
      else
        json = HTTP::Client.get("#{url}#{path}").body
        File.write(cache, json)
        Logger.log "=> #{url}#{path}".colorize(:green)
      end
    rescue e
      Logger.log "error: #{e.message}".colorize(:red)
    end
    JSON.parse(json)
  end

  def update_last_eur_brl
    json = get_json("https://economia.awesomeapi.com.br", "/eur")[0]
    Config.params[:eur_brl] = json["ask"].to_s.to_f64
    var_eur_brl = percentage(json["low"].to_s.to_f64, json["high"].to_s.to_f64)
    spread = percentage(json["bid"].to_s.to_f64, json["ask"].to_s.to_f64)
    puts "EUR:BRL: #{Config.params[:eur_brl]}".colorize(:light_red)
    puts "#{var_eur_brl}% diff : #{spread}% spread".colorize(:light_red)
  end

  def to_eur(f64)
    f64 / f(Config.params[:eur_brl])
  end

  def test_colors
     colors = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :light_gray, :dark_gray, :light_red, :light_green, :light_yellow, :light_blue, :light_magenta, :light_cyan, :white]
     colors.each do |c1|
      puts "color #{c1}".colorize(c1)
       colors.each do |c2|
         puts "fore #{c1} | back #{c2}".colorize.fore(c1).back(c2)
       end
     end
  end

  def profit_perct(x, por)
    (x.to_f64 * por.to_f64/100).round(2).to_s
  end

  def percentage(x, y)
    x, y = x.to_f64, y.to_f64
    pct = x < y ? ((y - x) / x) * 100.0 : - ((x - y) / y) * 100.0
    pct = 0.0 if pct.infinite? || pct.nan?
    pct.round(4)
  end

  def as_time(time, tmz=false)
    parsed_time = Time.parse(time.to_s, "%F %T.%L", Time::Location::UTC)
    tmz ? parsed_time + 2.hours : parsed_time  # TMZ = 2.hours # athens
  end

  def elapsed_time
    as_time_ago(Time.utc - as_time(Config.params[:start_time]))
  end

  def as_time_ago(span)
    h = span.hours > 0 ? "#{span.hours}h" : ""
    m = span.minutes > 0 ? "#{span.minutes}m" : ""
    "#{h}#{m}#{span.seconds}s#{span.milliseconds}"
  end

  def as_dolar(value)
    "$#{value.round(2)}"
  end

  def color(float : Float64)
    float > 0 ? float.to_s.colorize(:green) : float.to_s.colorize(:red)
  end

  def now
    Time.utc.to_s("%F %T.%L")
  end

  def save_json(json, file)
    File.open("log/#{file.to_s}.json", "w") do |f|
      f.write("#{json.to_pretty_json}\n".to_slice)
    end
  end
end

include Helper

class Logger
  def self.log(msg, file=:renda, error=false)
    File.open("log/#{file.to_s}.log", "a+") do |f|
      stamped = "#{now} #{msg}"
      puts stamped.colorize(error ? :red : :yellow) if Config.params[:log] || error
      f.write("#{stamped}\n".to_slice)
    end
  end
end
