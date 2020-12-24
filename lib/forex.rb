class Forex
  def initialize(input_sheet)
    @input_sheet = input_sheet
  end

  def rate
    return unless forex_header_cell[0]

    @input_sheet.cell(forex_header_cell[0].row + 1, forex_header_cell[0].column)
  end

  private

  def forex_header_cell
    forex_header = []
    @input_sheet.each_row_streaming do |columns|
      columns.each do |cel|
        next unless [
          'Foreign Exchange Rate',
          'Wisselkoers (Forex Rate)',
          'Taux de change (Foreign Exchange Rate)',
          'Taxa de câmbio internacional (Foreign Exchange Rate)'
        ].include? cel.value.to_s

        forex_header << cel.coordinate
      end
    end

    forex_header
  end
end
