module CryptosHelper
  def format_price(price)
    number_with_delimiter(number_with_precision(price, precision: 2))
  end

  def format_change(change)
    number_with_precision(change, precision: 2)
  end

  def format_quantity(quantity)
    precision = (quantity % 1 == 0) ? 0 : 2
    number_with_delimiter(number_with_precision(quantity, precision: precision))
  end

  def estimated_value(asset)
    asset[:quantity] * asset[:overall_price]
  end
end