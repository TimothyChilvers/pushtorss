require 'rss'
require 'json'
require 'sinatra'

module Pusher
  class App < Sinatra::Base
        
    post '/item' do

      old_feed_file_path = "stored_feed.json"
      
      if @current_contents.nil?
        @current_contents = [params[:link]]
      else
        @current_contents << params[:link]
      end
      
      File.open(old_feed_file_path, 'w') { |file| file.write(@current_contents.to_json) }
      
    end
    
    get '/feed' do

      populate_feed()
      
      rss = RSS::Maker.make("RSS20") do |maker|
        maker.channel.author = "Pants"
        maker.channel.updated = Time.now.to_s
        maker.channel.about = "http://www.ruby-lang.org/en/feeds/news.rss"
        maker.channel.title = "Pants Feed"

        @current_contents.each do |stored_url|
          maker.items.new_item do |item|
            item.link = stored_url
            item.updated = Time.now.to_s
          end
        end
      end

      return rss
    end

    def populate_feed()

      if File.exist?(old_feed_file_path) && @current_contents.nil?
        feed_file = File.read(old_feed_file_path)
        @current_contents = JSON.parse(feed_file)
      else 
        @current_contents = []  
      end
      
    end
    
  end
end
