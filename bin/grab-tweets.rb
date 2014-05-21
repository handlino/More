#!/usr/bin/ruby

require 'rubygems'
require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "SFspmYq7y3FAWp0XtgMEA"
  config.consumer_secret     = "lDObTaNcwczFCtZjiLJ5lzf9HdEV8c8UDw5q8RUzc"
  config.access_token        = "333093-NSnfyOBeNLouC7SEvu4G9Sj3SBDyyxW7IaxMz42DIpZ"
  config.access_token_secret = "dhGDW6qHOt7xNYxMfoucCHaOqtg5RCwQEITgWKPbhKRuC"
end

qs = ["咖啡", "不賴"]

qs.each do |q|
  client.search(q, :lang => "zh").each do |tweet|
    if !tweet.text.match(/https?:\/\/[\S]+/) && !tweet.text.match(/@/) && !tweet.text.match(/#/)
      puts tweet.text
    end
  end
end
