class Source
  def initialize(file)
    @file = file
  end

  def amazon?
    name == 'Amazon'
  end

  def lsi?
    name == 'LS'
  end

  def nbni?
    name == 'NBNI'
  end

  def name
    if @file.match?(/DigitalEBooksPaymentReport/i)
      'Amazon'
    elsif @file.match?(/sales_comp/i)
      'LS'
    elsif @file.match?(/FullTitleSales/i)
      'NBNI'
    end
  end

  def headers
    if amazon?
      {
        isbn:                /Digital ISBN*/i,
        sales_date:          /Invoice Date*/i,
        list_price:          /Publisher Price*/i,
        list_price_currency: /Price Currency*/i,
        quantity:            /Net Units*/i,
        value:               /Payment Amount*/i,
        currency:            /Payment Amount Currency*/i
      }
    elsif lsi?
      {
        isbn:                /parent_isbn/i,
        list_price:          /list_price/i,
        list_price_currency: /reporting_currency_code/i,
        quantity:            /PTD_net_quantity/i,
        value:               /PTD_net_pub_comp/i,
        currency:            /reporting_currency_code/i
      }
    elsif nbni?
      {
        isbn:       /EAN13/i,
        list_price: /Stg Price/i,
        quantity:   /NetQty-m/i,
        value:      /Net Value-m/i
      }
    end
  end
end
