require 'optparse'

class Options
  def initialize
  end

  def call
    options = {}

    opt_parser = OptionParser.new do |opt|
      opt.banner = 'Usage: ruby generate_import_file.rb'
      opt.separator  ''
      opt.separator  'e.g. ruby generate_import_file.rb'
      opt.separator  ''
      opt.separator  'options'

      opt.on('-c=s', '--channel=s', 'The channel code from Consonance') do |channel|
        options[:channel] = channel
      end

      opt.on('-d=s', '--default-currency=s', 'Your default currency in Consonance -- not the currency in this file') do |currency|
        options[:currency] = currency
      end

      opt.on('-i=s', '--invoice_date=s', 'The invoice date, formatted YYYY-MM-DD, required for LSI files because they do not contain a date') do |invoice_date|
        options[:invoice_date] = invoice_date
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
        puts "Error: You have to provide a default currency. Type 'ruby generate_import_file.rb -h' for help."
        exit
      end

    rescue OptionParser::InvalidOption => e
      puts "No such option! Type 'ruby generate_import_file.rb -h' for help. Full error: #{e}"
      exit
    end

    options
  end
end
