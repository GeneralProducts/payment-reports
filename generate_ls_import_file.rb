require 'roo'
require 'roo-xls'
require 'axlsx'
require 'byebug'
require 'optparse'
require './row'

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = 'Usage: ruby generate_ls_import_file.rb'
  opt.separator  ''
  opt.separator  'e.g. ruby generate_ls_import_file.rb'
  opt.separator  ''
  opt.separator  'Options'

  opt.on('-c=s', '--channel=s', 'The channel code from Consonance') do |channel|
    options[:channel] = channel
  end

  opt.on('-i=s', '--invoice_date=s', 'The invoice date') do |invoice_date|
    options[:invoice_date] = invoice_date
  end

  opt.on('-d=s', '--default-currency=s', 'Your default currency in Consonance') do |currency|
    options[:currency] = currency
  end

  opt.on('-h', '--help', 'Help') do
    puts opt_parser
    exit
  end

  opt.separator ''
end

begin
  opt_parser.parse!

  unless options[:currency]
    puts "Error: You have to provide a default currency. Type 'ruby generate_ls_import_file.rb -h' for help."
    exit
  end

rescue OptionParser::InvalidOption => e
  puts "No such option! Type 'ruby generate_ls_import_file.rb -h' for help. Full error: #{e}"
  exit
end

consonance_import_file = Axlsx::Package.new
workbook = consonance_import_file.workbook
sheet = workbook.add_worksheet(name: 'Basic Worksheet')
sheet.add_row [
  'Product ID type',
  'Product ID',
  'Channel ID',
  'Sales date',
  'List price',
  'Source',
  'Sales quantity',
  'Sales value',
  'Return quantity',
  'Return value',
  'Country code',
  'Original currency',
  'Original sales value',
  'Original return value',
  'File',
  'Notes'
]


# For each file...
Dir.glob('files/*.xls') do |file|
  puts "working on: #{file}..."

  # Get the .xls file
  # raw_input_sheet = Roo::CSV.new(file).sheet(0)
  raw_input_sheet = Roo::CSV.new(file, csv_options: { col_sep: "\t" }).sheet(0)

    # Convert the .xls to an .xlsx, to make it more queryable.
  # We have to require axlsx anyway, to write the output file:
  # may as well get some more use out of it.
  Axlsx::Package.new do |p|
    p.workbook.add_worksheet(name: 'first') do |first_sheet|
      raw_input_sheet.each { |line| first_sheet.add_row(line) }
    end
    p.serialize('temp.xlsx')
  end
  input_sheet = Roo::Excelx.new('temp.xlsx').sheet(0)

  begin
    input_sheet.each_with_index(
      isbn:                /parent_isbn/i,
      list_price:          /list_price/i,
      list_price_currency: /reporting_currency_code/i,
      quantity:            /PTD_net_quantity/i,
      value:               /PTD_net_pub_comp/i,
      currency:            /reporting_currency_code/i
    ) do |hash, idx|
      next if idx.zero? # skip header row
      # byebug
      row = Row.new(hash, nil, options[:currency])

      # break if row.empty?
      next if row.zero?

      sheet.add_row [
        'ISBN',
        row.isbn,
        options[:channel],
        options[:invoice_date],
        row.list_price,
        'LSI',
        row.quantity,
        row.value,
        row.returns_qty,
        row.returns_value,
        row.currency.split(//).first(2).join,
        row.currency,
        row.original_sales_value,
        row.original_returns_value,
        file,
        row.log
      ]
    end
  rescue => e
    puts "Error! #{e.message == "Couldn't find header row." ? "One of the headers could not be found in spreadsheet #{file}. Please email the file and this message to support@consonance.app" : e}"
  end
end

consonance_import_file.serialize 'output.xlsx'
