namespace :btc do
  desc "Query BTC data from SQLite"
  task query: :environment do
    puts "=" * 60
    puts "Querying BTC Data from SQLite"
    puts "=" * 60
    
    # Check if table exists
    unless HistoricalPriceData.table_exists?
      puts "❌ Table 'historical_price_data' does not exist"
      puts "   Run: rails db:migrate"
      exit
    end
    
    # Get BTC records
    btc_records = HistoricalPriceData.for_symbol('BTC').ordered_by_date
    
    if btc_records.empty?
      puts "❌ No BTC data found in database"
      puts "   Run: rails binance:fetch_historical"
      puts ""
      puts "Available symbols: #{HistoricalPriceData.distinct.pluck(:symbol).join(', ')}"
    else
      puts "\n📊 Found #{btc_records.count} BTC records\n"
      puts "-" * 60
      puts "Date      | Open      | High      | Low       | Close"
      puts "-" * 60
      
      btc_records.each do |record|
        printf "%-9s | %-9.4f | %-9.4f | %-9.4f | %-9.4f\n",
          record.date,
          record.open,
          record.high,
          record.low,
          record.close
      end
      
      puts "-" * 60
      puts "\n📈 Statistics:"
      puts "   First date: #{btc_records.first.date}"
      puts "   Last date: #{btc_records.last.date}"
      puts "   Highest price: $#{btc_records.maximum(:high)}"
      puts "   Lowest price: $#{btc_records.minimum(:low)}"
      puts "   Latest close: $#{btc_records.last.close}"
    end
    
    puts "\n" + "=" * 60
  end
  
  desc "Query BTC data with custom format"
  task :query_json, [:limit] => :environment do |t, args|
    limit = args[:limit]&.to_i || 10
    
    records = HistoricalPriceData.for_symbol('BTC')
                                 .ordered_by_date
                                 .limit(limit)
    
    data = records.map do |r|
      {
        date: r.date,
        open: r.open.to_f,
        high: r.high.to_f,
        low: r.low.to_f,
        close: r.close.to_f
      }
    end
    
    puts JSON.pretty_generate(data)
  end
end

