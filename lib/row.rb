require 'date'
require 'byebug'

class Row
  def initialize(hash, forex_rate, default_currency, source, invoice_date)
    @hash = hash
    @forex_rate = forex_rate
    @default_currency = default_currency
    @source = source
    @invoice_date = invoice_date
  end

  def empty?
    ['', nil].include? @hash.values.first
  end

  def zero?
    [quantity.to_f, returns_qty.to_f, original_sales_value.to_f, original_returns_value.to_f].sum.zero?
  end

  def isbn
    @hash[:isbn]
  end

  def sales_date
    return @invoice_date if @source.lsi?

    if currency == 'USD'
      Date.strptime(@hash[:sales_date], '%m/%d/%Y').strftime('%Y-%m-%d')
    else
      Date.parse(@hash[:sales_date]).strftime('%Y-%m-%d')
    end
  end

  def list_price
    # only if in the correct currency, as list price royalties are based on this
    @hash[:list_price] if list_price_currency == @default_currency
  end

  def quantity
    @hash[:quantity].to_i > 0 ? @hash[:quantity] : 0
  end

  def returns_qty
    @hash[:quantity].to_i < 0 ? @hash[:quantity].to_i * -1 : ''
  end

  def value
    return if !in_default_currency? && !forex_provided?

    @hash[:value].to_f > 0 ? @hash[:value].to_f * (@forex_rate || 1) : nil
  end

  def returns_value
    return if !in_default_currency? && !forex_provided?

    @hash[:value].to_f < 0 ? @hash[:value].to_f * -1 * (@forex_rate || 1) : nil
  end

  def currency
    @hash[:currency]
  end

  def original_sales_value
    return if in_default_currency?

    @hash[:value].to_f > 0 ? @hash[:value].to_f : nil
  end

  def original_returns_value
    return if in_default_currency?

    @hash[:value].to_f < 0 ? (@hash[:value].to_f * -1) : nil
  end

  def log
    if !in_default_currency? && !forex_provided?
      "Not in #{@default_currency}, but no forex found, so have to leave it to Consonance to do the conversion"
    elsif !in_default_currency?
      "Not in #{@default_currency}, and a forex is provided, so the Sales value column has the calculated #{@default_currency} amount (#{@forex_rate} x #{currency}#{original_sales_value}#{original_returns_value})"
    elsif in_default_currency?
      "In #{@default_currency}"
    end
  end

  private

  def forex_provided?
    !!@forex_rate
  end

  def in_default_currency?
    @default_currency == currency
  end

  def list_price_currency
    @hash[:list_price_currency]
  end
end
