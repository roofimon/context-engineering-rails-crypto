# ApexCharts Market Trend Implementation Summary

## Overview
This document summarizes the implementation of ApexCharts for displaying market trend charts in the Rails application.

## 1. Installation

### Ruby Gem
- Added `apexcharts` gem to `Gemfile`
- Ran `bundle install`

### JavaScript Library
- Loaded ApexCharts JavaScript from CDN in the `<head>` using `content_for :head`
- URL: `https://cdn.jsdelivr.net/npm/apexcharts@3.47.0/dist/apexcharts.min.js`

## 2. Created Market Trend Page

### Route
- Added route: `get "market_trend", to: "cryptos#market_trend"`

### Controller Action
- Added `market_trend` method in `CryptosController`
- Generates 30 days of fake price history data for each asset
- Creates date labels for the last 30 days

### View
- Created `app/views/cryptos/market_trend.html.erb`
- Displays chart containers for each cryptocurrency asset
- Shows asset information (name, symbol, price, change percentage)

### Navigation
- Added "Market Trend" menu item to bottom navigation bar
- Positioned between "Activities" and "Wallet" menu items

## 3. Fixed Turbo Frame Script Execution

### Problem
Scripts outside the `turbo_frame_tag` don't execute when navigating via Turbo Frames.

### Solution
- Moved the JavaScript code **inside** the `turbo_frame_tag` block
- Script now executes automatically when the Turbo Frame loads

### Key Insight
```erb
<%= turbo_frame_tag "market_data" do %>
  <!-- Content -->
  
  <script>
    // Script MUST be inside turbo_frame_tag to run when frame loads
  </script>
<% end %>
```

## 4. Fixed ERB Escaping Issues

### Problem
Error: "Unexpected token '&'" - ERB was escaping characters inside the `<script>` tag, causing JavaScript syntax errors.

### Root Cause
When ERB processes code inside `<script>` tags, it escapes HTML entities like `&` to `&amp;`, breaking JavaScript.

### Solution
- Moved all ERB data interpolation to the top of the script as a JavaScript array
- Used `j()` helper for strings to properly escape JavaScript
- Used `raw` helper for JSON data to prevent HTML entity escaping
- Replaced ERB loops with JavaScript `forEach` loops

### Example Fix
**Before (Broken):**
```erb
<script>
  <% @assets.each do |asset| %>
    const data = '<%= asset[:symbol] %>'; // Could escape & to &amp;
  <% end %>
</script>
```

**After (Working):**
```erb
<script>
  const assetsData = [
    <% @assets.each do |asset| %>
    {
      symbol: '<%= j(asset[:symbol]) %>',  // j() escapes for JS
      dates: <%= raw asset[:dates].to_json %>,  // raw prevents HTML escaping
      prices: <%= raw asset[:price_history].to_json %>
    },
    <% end %>
  ];
  
  // Pure JavaScript loop (no ERB)
  assetsData.forEach(function(asset) {
    // Use asset.symbol, asset.dates, asset.prices
  });
</script>
```

## 5. Final Implementation Structure

```erb
<% content_for :head do %>
  <script src="https://cdn.jsdelivr.net/npm/apexcharts@3.47.0/dist/apexcharts.min.js"></script>
<% end %>

<%= turbo_frame_tag "market_data" do %>
  <!-- Chart containers for each asset -->
  <div id="chart-<%= asset[:symbol] %>" class="w-full" style="height: 300px;"></div>
  
  <script>
    // 1. Prepare data at top (using j() and raw helpers)
    const assetsData = [
      <% @assets.each do |asset| %>
      {
        symbol: '<%= j(asset[:symbol]) %>',
        name: '<%= j(asset[:name]) %>',
        dates: <%= raw asset[:dates].to_json %>,
        prices: <%= raw asset[:price_history].to_json %>
      },
      <% end %>
    ];
    
    // 2. Helper functions (pure JavaScript)
    function updateStatus(symbol, message) { ... }
    
    // 3. Wait for ApexCharts to load
    function waitForApexChartsAndCreate() {
      if (window.ApexCharts && typeof window.ApexCharts === 'function') {
        createAllCharts();
      } else {
        setTimeout(waitForApexChartsAndCreate, 100);
      }
    }
    
    // 4. Create charts function (pure JavaScript)
    function createAllCharts() {
      assetsData.forEach(function(asset) {
        const chartElement = document.getElementById('chart-' + asset.symbol);
        const chart = new window.ApexCharts(chartElement, {
          series: [{ name: asset.symbol, data: asset.prices }],
          chart: { type: 'line', height: 300 },
          xaxis: { categories: asset.dates }
        });
        chart.render();
      });
    }
    
    // 5. Initialize
    waitForApexChartsAndCreate();
    
    // 6. Handle Turbo Frame events
    document.addEventListener('turbo:frame-load', function(event) {
      if (event.target.id === 'market_data') {
        setTimeout(waitForApexChartsAndCreate, 300);
      }
    });
  </script>
<% end %>
```

## Key Takeaways

1. **Scripts in Turbo Frames**: Scripts must be **inside** the `turbo_frame_tag` to execute when navigating via Turbo Frames
2. **ERB in JavaScript**: Use `j()` helper for strings and `raw` helper for JSON when embedding ERB data in JavaScript
3. **Avoid ERB in Scripts**: Prepare data at the top, then use pure JavaScript for loops and logic
4. **External Libraries**: Load in `<head>` via `content_for :head` for better performance
5. **Debugging**: Use alerts and console logs to debug step-by-step when scripts don't execute

## Chart Configuration

The charts display:
- **Type**: Line chart (can be changed to 'area', 'bar', etc.)
- **Height**: 300px
- **Data**: 30 days of price history
- **X-axis**: Date labels (MM/DD format)
- **Y-axis**: Price values formatted as currency

## Files Modified

- `Gemfile` - Added apexcharts gem
- `config/routes.rb` - Added market_trend route
- `app/controllers/cryptos_controller.rb` - Added market_trend action
- `app/views/cryptos/_bottom_navigation.html.erb` - Added Market Trend menu item
- `app/views/cryptos/market_trend.html.erb` - Created new view with charts
- `app/views/layouts/application.html.erb` - ApexCharts loaded via content_for

## Result

The Market Trend page now successfully displays interactive ApexCharts showing 30-day price trends for all cryptocurrency assets with smooth rendering and proper Turbo Frame integration.

