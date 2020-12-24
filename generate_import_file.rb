require 'roo'
require 'roo-xls'
require 'axlsx'
require 'byebug'
require 'optparse'
require './lib/row'
require './lib/source'
require './lib/add_data'
require './lib/options'

def output_rows
  [
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
end

def call
  options = Options.new.call
  consonance_file = Axlsx::Package.new
  workbook = consonance_file.workbook
  output_sheet = workbook.add_worksheet(name: 'Basic Worksheet')
  output_sheet.add_row output_rows
  AddData.new(output_sheet, options).call
  consonance_file.serialize 'output.xlsx'
end

call
