module AssetsHelper
  def format_price(price)
    number_with_delimiter(number_with_precision(price, precision: 2))
  end

  def format_change(change)
    number_with_precision(change, precision: 2)
  end
end

