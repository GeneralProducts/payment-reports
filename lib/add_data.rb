require './lib/forex'
require './lib/source'
require 'roo'
require 'roo-xls'
require 'axlsx'
require 'byebug'
require 'optparse'

class AddData
  def initialize(output_sheet, options)
    @output_sheet = output_sheet
    @options = options
  end

  def call
    Dir.glob('files/*.xls') do |file|
      input_sheet = convert_to_xlsx(raw_input_sheet(file))
      forex_rate = Forex.new(input_sheet).rate

      # begin
        input_sheet.each_with_index(
          source(file).headers
        ) do |hash, idx|
          if source(file).nbni?
            next if [0..4].include? idx # they have 4 additional lines
          else
            next if idx.zero? # skip header row
          end

          row = Row.new(
            hash,
            forex_rate,
            @options[:currency],
            source(file),
            @options[:invoice_date]
          )
          break if row.empty?

          next if row.zero?

          @output_sheet.add_row [
            'ISBN',
            row.isbn,
            @options[:channel],
            row.sales_date,
            row.list_price,
            source(file).name,
            row.quantity,
            row.value,
            row.returns_qty,
            row.returns_value,
            country_code(file, row.currency),
            row.currency,
            row.original_sales_value,
            row.original_returns_value,
            file,
            row.log
          ]
        end
      # rescue => e
      #   puts "Error! #{e.message == "Couldn't find header row." ? "One of the headers could not be found in #{file}. Please email the file and this message to support@consonance.app" : e}"
      # end
    end
  end

  private

  def source(file)
    Source.new(file)
  end

  def country_code(file, currency)
    if source(file).amazon?
      file.delete('.xls').delete('.xlsx').split(//).last(2).join
    elsif source(file).lsi?
      currency.split(//).first(2).join
    elsif source(file).nbni?
      'GB'
    end
  end

  def raw_input_sheet(file)
    if source(file).lsi?
      Roo::CSV.new(file, csv_options: { col_sep: "\t" }).sheet(0)
    else
      Roo::Excel.new(file).sheet(0)
    end
  end

  def convert_to_xlsx(file)
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: 'first') do |first_sheet|
        file.each { |line| first_sheet.add_row(line) }
      end
      p.serialize('temp.xlsx')
    end
    Roo::Excelx.new('temp.xlsx').sheet(0)
  end
end
