require './lib/row'
require './lib/source'

describe Row do
  let(:row) { Row.new(hash, forex, default_currency, source, invoice_date) }

  let(:hash) do
    {
      isbn:                '123',
      sales_date:          '01/04/2020',
      list_price:          '123',
      quantity:            '100',
      currency:            'GBP',
      list_price_currency: 'GBP'
    }
  end

  let(:default_currency) { 'GBP' } # mandatory
  let(:forex) { nil }
  let(:source) { Source.new('DigitalEBooksPaymentReport.xls') }
  let(:invoice_date) { nil }

  it 'gives the isbn' do
    expect(row.isbn).to eq('123')
  end

  it 'gives the sales date' do
    expect(row.sales_date).to eq('2020-04-01')
  end

  context 'when the currency is USD' do
    let(:hash) do
      {
        sales_date: '04/30/2020',
        currency:   'USD'
      }
    end

    it 'gives the sales date' do
      expect(row.sales_date).to eq('2020-04-30')
    end

    it 'gives the list_price' do
      expect(row.list_price).to eq(nil)
    end
  end

  it 'gives the list_price' do
    expect(row.list_price).to eq('123')
  end

  it 'gives the quantity' do
    expect(row.quantity).to eq(100)
  end

  it 'gives the returns_qty' do
    expect(row.returns_qty).to eq('')
  end

  describe '#positive' do
    context 'with a positive value, a default currency, no forex' do
      let(:hash) do
        {
          value:      '200',
          currency:   'GBP'
        }
      end

      it 'gives the value' do
        expect(row.value).to eq(200.0)
      end

      it 'gives the returns_value' do
        expect(row.returns_value).to eq(nil)
      end

      it 'gives no original_sales_value' do
        expect(row.currency).to eq('GBP')
        expect(row.original_sales_value).to eq(nil)
        expect(row.original_returns_value).to eq(nil)
      end
    end

    context 'with a value, a currency, a forex' do
      let(:hash) do
        {
          value:      '200',
          currency:   'USD'
        }
      end

      let(:forex) { 0.3 }

      it 'gives the value' do
        expect(row.value).to eq(60.0)
      end

      it 'gives the returns_value' do
        expect(row.returns_value).to eq(nil)
      end

      it 'gives an original_sales_value' do
        expect(row.currency).to eq('USD')
        expect(row.original_sales_value).to eq(200.0)
        expect(row.original_returns_value).to eq(nil)
      end
    end

    context 'with a value, a currency, no forex' do
      let(:hash) do
        {
          value:      '200',
          currency:   'USD'
        }
      end

      it 'gives no value' do
        expect(row.value).to eq(nil)
      end

      it 'gives the returns_value' do
        expect(row.returns_value).to eq(nil)
      end

      it 'gives an original_sales_value' do
        expect(row.currency).to eq('USD')
        expect(row.original_sales_value).to eq(200.0)
        expect(row.original_returns_value).to eq(nil)
      end
    end
  end

  describe '#negative' do
    context 'with a negative value, a default currency, no forex' do
      let(:hash) do
        {
          value:      '-200',
          currency:   'GBP',
          quantity:   '-100'
        }
      end

      it 'gives the value' do
        expect(row.value).to eq(nil)
      end

      it 'gives the returns_value' do
        expect(row.returns_value).to eq(200.0)
      end

      it 'gives the returns_qty' do
        expect(row.returns_qty).to eq(100)
      end

      it 'gives no original_sales_value' do
        expect(row.currency).to eq('GBP')
        expect(row.original_sales_value).to eq(nil)
        expect(row.original_returns_value).to eq(nil)
      end
    end

    context 'with a value, a currency, a forex' do
      let(:hash) do
        {
          value:      '-200',
          currency:   'USD'
        }
      end

      let(:forex) { 0.3 }

      it 'gives the value' do
        expect(row.value).to eq(nil)
      end

      it 'gives the returns_value' do
        expect(row.returns_value).to eq(60.0)
      end

      it 'gives an original_sales_value' do
        expect(row.currency).to eq('USD')
        expect(row.original_sales_value).to eq(nil)
        expect(row.original_returns_value).to eq(200.0)
      end
    end

    context 'with a value, a currency, no forex' do
      let(:hash) do
        {
          value:      '-200',
          currency:   'USD'
        }
      end

      it 'gives no value' do
        expect(row.value).to eq(nil)
      end

      it 'gives the returns_value' do
        expect(row.returns_value).to eq(nil)
      end

      it 'gives an original_sales_value' do
        expect(row.currency).to eq('USD')
        expect(row.original_sales_value).to eq(nil)
        expect(row.original_returns_value).to eq(200.0)
      end
    end
  end
end
