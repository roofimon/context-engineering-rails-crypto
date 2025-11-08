namespace :binance do
  desc "Fetch historical price data from Binance and save to SQLite"
  task fetch_historical: :environment do
    require 'net/http'
    require 'json'
    require 'date'

    # Map asset symbols to Binance trading pairs
    symbol_map = {
      'BTC' => 'BTCUSDT',
      'ETH' => 'ETHUSDT',
      'SOL' => 'SOLUSDT',
      'USDT' => 'USDCUSDT', # USDT/USDT doesn't exist, using USDC/USDT as proxy
      'BNB' => 'BNBUSDT'
    }

    # Days of historical data to fetch
    days = 30
    interval = '1d' # Daily candles

    historical_data = {}

    symbol_map.each do |symbol, binance_symbol|
      puts "Fetching data for #{symbol} (#{binance_symbol})..."
      
      begin
        # Clear existing data for this symbol
        HistoricalPriceData.clear_symbol(symbol)
        
        # Binance API endpoint for klines (candlestick data)
        url = URI("https://api.binance.com/api/v3/klines?symbol=#{binance_symbol}&interval=#{interval}&limit=#{days}")
        
        response = Net::HTTP.get_response(url)
        
        if response.code == '200'
          klines = JSON.parse(response.body)
          saved_count = 0
          
          klines.each do |kline|
            # kline format: [timestamp, open, high, low, close, volume, ...]
            timestamp_ms = kline[0].to_i
            date = Time.at(timestamp_ms / 1000).to_date
            date_str = date.strftime("%m/%d")
            
            open_price = kline[1].to_f.round(4)
            high_price = kline[2].to_f.round(4)
            low_price = kline[3].to_f.round(4)
            close_price = kline[4].to_f.round(4)
            
            # Save to SQLite
            HistoricalPriceData.upsert_data(
              symbol,
              date_str,
              open_price,
              high_price,
              low_price,
              close_price
            )
            
            saved_count += 1
          end
          
          puts "✅ Successfully saved #{saved_count} days of data for #{symbol} to SQLite"
        else
          puts "❌ Error fetching #{symbol}: HTTP #{response.code}"
        end
      rescue => e
        puts "❌ Error fetching #{symbol}: #{e.message}"
        puts e.backtrace.first(3).join("\n")
      end
    end

    # Summary
    total_records = HistoricalPriceData.count
    puts "\n✅ Historical data saved to SQLite database"
    puts "📊 Total records in database: #{total_records}"
    puts "📈 Symbols: #{HistoricalPriceData.distinct.pluck(:symbol).join(', ')}"
  end
end

