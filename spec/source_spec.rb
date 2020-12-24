require './lib/source'

describe Source do
  let(:source) { Source.new(file_name) }

  let(:file_name) { 'any.xls' }

  it 'gives the name' do
    expect(source.name).to eq(nil)
  end

  it 'responds properly' do
    expect(source.amazon?).to eq(false)
    expect(source.nbni?).to eq(false)
    expect(source.lsi?).to eq(false)
  end

    it 'returns the right headers' do
      expect(source.headers).to eq(nil)
    end

  context "source is Amazon" do
    let(:file_name) { 'DigitalEBooksPaymentReport.xls' }

    it 'gives the name' do
      expect(source.name).to eq("Amazon")
    end

    it 'responds properly' do
      expect(source.amazon?).to eq(true)
      expect(source.nbni?).to eq(false)
      expect(source.lsi?).to eq(false)
    end

    it 'returns the right headers' do
      expect(source.headers).to eq({
        isbn:                /Digital ISBN*/i,
        sales_date:          /Invoice Date*/i,
        list_price:          /Publisher Price*/i,
        list_price_currency: /Price Currency*/i,
        quantity:            /Net Units*/i,
        value:               /Payment Amount*/i,
        currency:            /Payment Amount Currency*/i
        })
    end
  end

  context "source is lsi" do
    let(:file_name) { 'sales_comp.xls' }

    it 'gives the name' do
      expect(source.name).to eq("LS")
    end

    it 'responds properly' do
      expect(source.amazon?).to eq(false)
      expect(source.nbni?).to eq(false)
      expect(source.lsi?).to eq(true)
    end

    it 'returns the right headers' do
      expect(source.headers).to eq({
        isbn:                /parent_isbn/i,
        list_price:          /list_price/i,
        list_price_currency: /reporting_currency_code/i,
        quantity:            /PTD_net_quantity/i,
        value:               /PTD_net_pub_comp/i,
        currency:            /reporting_currency_code/i
      })
    end
  end

  context "source is NBNi" do
    let(:file_name) { 'FullTitleSales.xls' }

    it 'gives the name' do
      expect(source.name).to eq("NBNI")
    end

    it 'responds properly' do
      expect(source.amazon?).to eq(false)
      expect(source.nbni?).to eq(true)
      expect(source.lsi?).to eq(false)
    end

    it 'returns the right headers' do
      expect(source.headers).to eq({
        isbn:       /EAN13/i,
        list_price: /Stg Price/i,
        quantity:   /NetQty-m/i,
        value:      /Net Value-m/i
      })
    end
  end
end
