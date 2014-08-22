require 'twitter'
require 'pry'

class TweetTicker
  def client
    @client ||= Twitter::Streaming::Client.new do |config|
      config.consumer_key        = "FIVs79rklkQyDtxs33g80g"
      config.consumer_secret     = "zdGNeDZbcQINNYOcEOqAMioOatwfG0iBKOWOhUIs8"
      config.access_token        = "610444106-8RCeCgzdxHOsqZDaghixHXOcZTEgYjuxfIsveN91"
      config.access_token_secret = "puiJn8BYZiI0KPtgdK5UUmO392rLfd7LTOVMHqYmIbZPp"
    end
  end

  def fetch_tweets(english_only, minutes_ago)
    top_tweets = []
    options = {:filter_level => 'medium'}
    options[:language] = 'en' if english_only
    start_time = Time.now - (minutes_ago * 60)

    client.sample(options) do |new_tweet|
      if new_tweet.is_a?(Twitter::Tweet)
        #Display some random tweets until we find more popular ones
        if top_tweets.length < 10
          top_tweets << new_tweet
        else
          #sort top tweets
          top_tweets = sort_tweets(top_tweets)
          #find original tweet if this is a retweet
          if new_tweet.retweet?
            new_tweet = new_tweet.retweeted_status
          end

          if new_tweet.created_at > start_time
            top_tweets = insert_popular_tweet(top_tweets, new_tweet)
          end
        end
      end

      display_tweets(top_tweets)
    end
  end

  def insert_popular_tweet(top_tweets, new_tweet)
    first_lesser_tweet = top_tweets.find do |existing_tweet|
      existing_tweet.retweet_count < new_tweet.retweet_count
    end
    #insert popular tweet, trim the bottom-most tweet
    if first_lesser_tweet
      top_tweets.insert(top_tweets.index(first_lesser_tweet), new_tweet)
      top_tweets = top_tweets[0...10]
    end
    top_tweets
  end

  def sort_tweets(tweets)
    tweets.sort_by{|tweet| [tweet.retweet_count, -1 * tweets.index(tweet)]}.reverse
  end

  def display_tweets(tweets)
    if tweets.length == 10
      system("clear")
      tweets.each_with_index do |tweet, index|
        puts "#{index + 1}. #{tweet.text} - #{tweet.retweet_count} ReTweets"
      end
      sleep 1
    end
  end
end

puts "Welcome to The Tweet Ticker"
puts "Display English Language Tweets Only? (Y/N)"
input = gets.chomp[0]
english_only = true if (input.downcase == "y")
puts "Minutes ago (as a numeral) to start tracking from?"
minutes_ago = gets.chomp[0].to_i
TweetTicker.new.fetch_tweets(english_only, minutes_ago)
