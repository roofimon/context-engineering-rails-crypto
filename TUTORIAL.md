# Building a Cryptocurrency Asset Tracker with Rails 8 and Tailwind CSS

This tutorial documents the complete implementation of a cryptocurrency asset tracking application built with Rails 8, Tailwind CSS, and Turbo Frames. The application features real-time price tracking, buy order management, transaction history, and a modern, responsive UI.

## Table of Contents

1. [Setting Up Tailwind CSS](#1-setting-up-tailwind-css)
2. [Creating the Asset Tracking Interface](#2-creating-the-asset-tracking-interface)
3. [Implementing Turbo Frame Navigation](#3-implementing-turbo-frame-navigation)
4. [Building the Buy Form with Validation](#4-building-the-buy-form-with-validation)
5. [Adding Transaction History](#5-adding-transaction-history)
6. [Creating a Confirmation Page](#6-creating-a-confirmation-page)
7. [Code Formatting and Best Practices](#7-code-formatting-and-best-practices)

---

## 1. Setting Up Tailwind CSS

### 1.1 Initialize npm and Install Tailwind CSS

First, we initialized npm in our Rails project and installed Tailwind CSS:

```bash
npm init -y
npm install -D tailwindcss@^4.1.16
```

### 1.2 Create package.json Scripts

We added build scripts to `package.json`:

```json
{
  "scripts": {
    "build:css": "tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/stylesheets/application.css --minify",
    "watch:css": "tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/stylesheets/application.css --watch"
  }
}
```

### 1.3 Configure Tailwind CSS

Created `tailwind.config.js` to scan Rails files:

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

### 1.4 Create Tailwind Input File

Created `app/assets/stylesheets/application.tailwind.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### 1.5 Update bin/dev for Concurrent Processes

Modified `bin/dev` to run both Rails server and Tailwind watcher:

```ruby
#!/usr/bin/env ruby
require "fileutils"

FileUtils.cd(File.dirname(__FILE__) + "/..") do
  rails_pid = spawn("./bin/rails", "server", *ARGV)
  tailwind_pid = spawn("npm", "run", "watch:css")
  
  begin
    Process.wait(rails_pid)
  rescue Interrupt
    puts "\nShutting down..."
  ensure
    Process.kill("TERM", rails_pid) rescue nil
    Process.kill("TERM", tailwind_pid) rescue nil
    Process.wait(tailwind_pid) rescue nil
  end
end
```

---

## 2. Creating the Asset Tracking Interface

### 2.1 Controller Setup

We created `CryptosController` (originally `AssetsController`) to manage cryptocurrency data:

**Key Features:**
- Dynamic asset quantity calculation based on purchase orders
- Session-based order storage
- Helper methods for asset lookup

**Controller Structure:**

```ruby
class CryptosController < ApplicationController
  def index
    @assets = index_assets
  end

  def buy
    symbol = params[:symbol]
    @asset = find_asset_by_symbol(symbol)
    redirect_to root_path, alert: "Asset not found" unless @asset
  end

  private

  def index_assets
    base_assets = [
      {
        name: "Bitcoin",
        symbol: "BTC",
        icon: "₿",
        initial_quantity: 2.5,
        exchanges: {
          "Binance" => { price: 94245.32, change: nil },
          "Coinbase" => { price: 94312.03, change: nil }
        },
        overall_price: 94245.50,
        change: 1.25
      },
      # ... more assets
    ]

    # Calculate current quantity based on orders
    orders = session[:orders] || []

    base_assets.map do |asset|
      purchased_units = orders
                        .select { |order| order["symbol"] == asset[:symbol] }
                        .sum { |order| order["units"].to_f }
      
      current_quantity = asset[:initial_quantity] + purchased_units
      asset.merge(quantity: current_quantity)
    end
  end
end
```

### 2.2 View Implementation

Created a responsive view with desktop table and mobile card layouts:

**Desktop Table Features:**
- Asset name and symbol
- Holdings column (dynamic quantity)
- Exchange prices (Binance, Coinbase)
- Overall price
- Estimated value (holdings × price)
- Change percentage

**Mobile Card Features:**
- Compact card layout
- Same information optimized for small screens
- Bottom navigation bar

### 2.3 Helper Methods

Created `CryptosHelper` for consistent formatting:

```ruby
module CryptosHelper
  def format_price(price)
    number_with_delimiter(number_with_precision(price, precision: 2))
  end

  def format_quantity(quantity)
    precision = (quantity % 1 == 0) ? 0 : 2
    number_with_delimiter(number_with_precision(quantity, precision: precision))
  end

  def estimated_value(asset)
    asset[:quantity] * asset[:overall_price]
  end
end
```

---

## 3. Implementing Turbo Frame Navigation

### 3.1 Understanding Turbo Frames

Turbo Frames allow us to update specific parts of a page without full page reloads, creating a SPA-like experience.

### 3.2 Setting Up Routes

```ruby
Rails.application.routes.draw do
  root "cryptos#index"
  
  # Buy crypto routes
  get "cryptos/:symbol/buy", to: "cryptos#buy", as: :buy_crypto
  post "cryptos/:symbol/confirm", to: "cryptos#confirm", as: :confirm_order
  post "cryptos/:symbol/buy", to: "cryptos#create_order", as: :create_order
  
  # Activities/Transaction history
  get "activities", to: "cryptos#activities", as: :activities
end
```

### 3.3 Wrapping Content in Turbo Frames

In `index.html.erb`, we wrapped the market data in a Turbo Frame:

```erb
<%= turbo_frame_tag "market_data" do %>
  <!-- Desktop Table View -->
  <!-- Mobile Card View -->
<% end %>
```

### 3.4 Linking with Turbo Frames

When clicking asset symbols, we target the Turbo Frame:

```erb
<%= link_to asset[:symbol], 
    buy_crypto_path(asset[:symbol]), 
    class: "text-sm text-gray-500 hover:text-blue-600",
    data: { turbo_frame: "market_data" } %>
```

**Key Points:**
- All navigation links use `data: { turbo_frame: "market_data" }`
- Only the content inside the frame updates, not the entire page
- Header, navigation, and other elements remain static

---

## 4. Building the Buy Form with Validation

### 4.1 Form Structure

The buy form includes:
- Market Price (read-only)
- Number of Units (input with validation)
- Estimated Cost (auto-calculated)

### 4.2 Client-Side Validation with Stimulus

Created `app/javascript/controllers/buy_form_controller.js`:

**Key Features:**
1. **Real-time Calculation:**
   ```javascript
   calculate() {
     const units = parseFloat(this.unitsTarget.value) || 0
     const price = parseFloat(this.marketPriceTarget.value) || 0
     const estimatedCost = units * price
     
     if (units >= 1 && price > 0 && estimatedCost > 0) {
       this.estimatedCostTarget.value = estimatedCost.toFixed(2)
     }
   }
   ```

2. **Input Restriction (Max 2 Decimal Places):**
   ```javascript
   preventExtraDecimals(event) {
     const value = input.value
     const decimalIndex = value.indexOf('.')
     
     if (decimalIndex !== -1) {
       if (selectionStart > decimalIndex) {
         const decimalPart = value.substring(decimalIndex + 1, selectionEnd)
         if (decimalPart.length >= 2 && /^\d$/.test(key)) {
           event.preventDefault()
         }
       }
     }
   }
   ```

3. **Paste Handling:**
   ```javascript
   handlePaste(event) {
     const pastedData = event.clipboardData.getData('text')
     if (pastedData.includes('.')) {
       const parts = pastedData.split('.')
       if (parts[1] && parts[1].length > 2) {
         // Trim to 2 decimal places
         const restrictedValue = `${parts[0]}.${parts[1].substring(0, 2)}`
         // Update input value
       }
     }
   }
   ```

4. **Form Validation:**
   - Minimum value: 1.00
   - Maximum decimal places: 2
   - Real-time error display

### 4.3 Server-Side Validation

In the controller, we validate before processing:

```ruby
def confirm
  units = params[:units].to_f
  
  # Validate minimum
  if units < 1
    redirect_to buy_crypto_path(symbol), alert: "Number of units must be at least 1.00"
    return
  end
  
  # Validate decimal places
  units_str = params[:units].to_s
  if units_str.include?(".")
    decimal_places = units_str.split(".")[1]&.length || 0
    if decimal_places > 2
      redirect_to buy_crypto_path(symbol), alert: "Number of units can have maximum 2 decimal places"
      return
    end
  end
  
  @units = units
  @market_price = params[:market_price].to_f
  @total_cost = @units * @market_price
end
```

### 4.4 Form HTML

```erb
<%= form_with url: confirm_order_path(symbol: @asset[:symbol]), 
              method: :post, 
              data: { turbo_frame: "market_data" } do |f| %>
  
  <!-- Market Price (read-only) -->
  <%= f.number_field :market_price, 
      value: @asset[:overall_price],
      readonly: true,
      class: "bg-gray-50" %>
  
  <!-- Units with validation -->
  <%= f.number_field :units, 
      min: 1,
      step: 0.01, 
      required: true,
      data: { 
        "buy-form-target": "units", 
        action: "input->buy-form#calculate input->buy-form#validate keydown->buy-form#preventExtraDecimals paste->buy-form#handlePaste" 
      } %>
  
  <!-- Estimated Cost (auto-calculated) -->
  <input type="text" 
         readonly
         data-buy-form-target="estimatedCost"
         placeholder="Calculated automatically" />
  
  <%= f.submit "Buy", class: "px-8 py-3 bg-blue-600" %>
  <%= link_to "Cancel", root_path, 
      class: "px-4 py-3 bg-red-600",
      data: { turbo_frame: "market_data" } %>
<% end %>
```

---

## 5. Adding Transaction History

### 5.1 Activities Controller Action

```ruby
def activities
  @orders = session[:orders] || []
  @orders = @orders.sort_by { |order| order["timestamp"] }.reverse
end
```

### 5.2 Activities View

Created `activities.html.erb` with:
- Desktop table view
- Mobile card view
- Sortable by timestamp (most recent first)

### 5.3 Bottom Navigation

Added "Activities" link to bottom navigation:

```erb
<%= link_to activities_path, 
    class: "flex flex-col items-center",
    data: { turbo_frame: "market_data" } do %>
  <svg><!-- Clock icon --></svg>
  <span>Activities</span>
<% end %>
```

---

## 6. Creating a Confirmation Page

### 6.1 Confirmation Flow

The buy process now has three steps:
1. **Buy Form** → Enter units
2. **Confirmation Page** → Review order summary
3. **Order Created** → Stored in session

### 6.2 Confirmation Action

```ruby
def confirm
  # Validation (same as before)
  @units = units
  @market_price = params[:market_price].to_f
  @total_cost = @units * @market_price
end
```

### 6.3 Confirmation View

Displays order summary with:
- Asset name and symbol
- Number of units
- Market price per unit
- Total cost

```erb
<%= turbo_frame_tag "market_data" do %>
  <div class="order-summary">
    <h2>Confirm Buy Order</h2>
    
    <div>
      <p>Asset</p>
      <p><%= @asset[:name] %> (<%= @asset[:symbol] %>)</p>
    </div>
    
    <div>
      <p>Units</p>
      <p><%= format_quantity(@units) %></p>
    </div>
    
    <div>
      <p>Market Price</p>
      <p>$<%= format_price(@market_price) %></p>
    </div>
    
    <div>
      <p>Total Cost</p>
      <p class="text-xl font-bold">$<%= format_price(@total_cost) %></p>
    </div>
    
    <%= form_with url: create_order_path(symbol: @asset[:symbol]), 
                  method: :post,
                  data: { turbo_frame: "_top" } do |f| %>
      <%= f.hidden_field :units, value: @units %>
      <%= f.hidden_field :market_price, value: @market_price %>
      <%= link_to "Cancel", buy_crypto_path(@asset[:symbol]),
          data: { turbo_frame: "market_data" } %>
      <%= f.submit "Confirm Buy" %>
    <% end %>
  </div>
<% end %>
```

### 6.4 Creating Orders

```ruby
def create_order
  # Validation (same as before)
  
  order = {
    "symbol" => symbol.upcase,
    "units" => units,
    "price" => market_price,
    "timestamp" => Time.current.to_s
  }
  
  session[:orders] ||= []
  session[:orders] << order
  
  redirect_to root_path, notice: "Buy order placed for #{asset[:name]}"
end
```

---

## 7. Code Formatting and Best Practices

### 7.1 Using Rubocop

We used Rubocop to ensure consistent code style:

```bash
rubocop -a  # Auto-fix offenses
```

**Benefits:**
- Consistent indentation
- Proper spacing
- Standard Ruby conventions

### 7.2 Partial Organization

We separated views into partials for better organization:

- `_mobile_card.html.erb` - Mobile card view
- `_bottom_navigation.html.erb` - Bottom navigation bar

### 7.3 Key Best Practices Applied

1. **Separation of Concerns:**
   - Controller handles business logic
   - Views handle presentation
   - Helpers handle formatting
   - Stimulus controllers handle client-side behavior

2. **DRY Principle:**
   - Reusable helper methods
   - Shared partials
   - Private controller methods

3. **Security:**
   - Server-side validation (even with client-side validation)
   - Proper parameter handling
   - Session management

4. **User Experience:**
   - Real-time feedback
   - Input restrictions
   - Clear error messages
   - Confirmation before actions

5. **Performance:**
   - Turbo Frames for partial page updates
   - Efficient session storage
   - Optimized calculations

---

## Summary

This tutorial covered:

✅ **Tailwind CSS Integration** - Setting up and configuring Tailwind in Rails 8  
✅ **Responsive UI** - Desktop table and mobile card layouts  
✅ **Turbo Frames** - SPA-like navigation without full page reloads  
✅ **Form Validation** - Both client-side (Stimulus) and server-side (Rails)  
✅ **Transaction Management** - Session-based order storage and history  
✅ **Confirmation Flow** - Order review before final submission  
✅ **Code Quality** - Consistent formatting and best practices  

The application demonstrates modern Rails development practices, combining the power of Turbo, Stimulus, and Tailwind CSS to create a fast, responsive, and user-friendly interface.

---

## Running the Application

```bash
# Install dependencies
npm install

# Start development server (Rails + Tailwind watcher)
./bin/dev

# Or run separately:
rails server
npm run watch:css
```

The application will be available at `http://localhost:3000`.

