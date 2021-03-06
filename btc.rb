# coding: UTF-8
require "net/http"
require "net/https"
require 'colorize'
require 'ruby-debug'
class Btc
  def initialize
    @last_price = 0.0
    @lowest_price = 10000000.0
    @highest_price = 0.0
    @url = URI.parse('https://btcchina.com')
    @net = Net::HTTP.new(@url.host, @url.port)
    @net.use_ssl = true if @url.scheme == 'https'
  end
  def run
    while true
      @net.start do |http|
        next if get_price_from_respond == nil
        print_line get_price_line
        @last_price = @price
      end
      sleep(rand(6))
    end
  end

  private
  def get_price_from_respond 
    respond = @net.request(Net::HTTP::Get.new(@url.request_uri))
    begin
      price_string_index = respond.body.to_s.index('Last BTC Price: </td><td align="center">') + 42
    rescue NoMethodError
      return nil
    end

    return nil if price_string_index == nil
    price_string = respond.body.to_s[price_string_index,12]
    price_string = price_string.delete ","
    numstr = price_string[/\d+.\d+/]
    @price = numstr.to_f
    @highest_price = @price  if @price > @highest_price
    @lowest_price  = @price  if @price < @lowest_price
    return true
  end
  def get_price_line
    if @price - @last_price != 0
      line = ""
      line += sprintf("Time:%2d/%d %02d:%02d Price: %.2f ",Time.now.month,Time.now.day,Time.now.hour,Time.now.min,@price, @price - @last_price )
      if @price - @last_price > 0 
        line += '+' 
      end
      line += sprintf("%.2f", @price - @last_price)
      return line
    else
      return nil
    end
  end
  def print_line price_line
    return if price_line == nil or @price == @last_price
    if @price == @highest_price
      puts price_line.red
    elsif @price == @lowest_price
      puts price_line.white
    elsif @price > @last_price
      puts price_line.green
    else
      puts price_line.yellow
    end
  end

end

Btc.new.run
