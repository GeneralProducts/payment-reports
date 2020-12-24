require 'selenium-webdriver'
require 'capybara'
require 'uri'
require 'byebug'
require 'optparse'

options = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = 'Usage: ruby payment-reports.rb --email [email] --password [amazon vendor central password] --country [country, one of GB, US, or AU] --from-date [from month, formatted dd-mm-yyyy]'
  opt.separator  ''
  opt.separator  'e.g. ruby payment-reports.rb --email emma@fauxbooks.com --password 2345678 --country GB --from-month 01-07-2020'
  opt.separator  ''
  opt.separator  'Options'

  opt.on('-e=s', '--email=s', 'The email address you use to sign in to Vendor Central') do |email|
    options[:email] = email
  end

  opt.on('-p=s', '--password=s', 'The password you use to sign in to Vendor Central. If it has special characters in, you have to put a backslash before them e.g. 234!345 becomes 234\!345') do |password|
    options[:password] = password
  end

  opt.on('-c=s', '--country=s', 'The Amazon regional site you want to log in to. Must be one of GB, US or AU') do |country|
    options[:country] = country
  end

  opt.on('-d=s', '--from-date=s', 'The month and year you want the reports from, as dd-mm-yyyy e.g. 01-07-2020 for July 2020') do |date|
    options[:from_date] = date
  end

  opt.on('-h', '--help', 'Help') do
    puts opt_parser
    exit
  end

  opt.separator ''
end

begin
  opt_parser.parse!

  unless options[:email] && options[:password]
    puts "Error: You have to provide at least an email and password. Type 'ruby payment-reports.rb -h' for help."
    exit
  end
rescue OptionParser::InvalidOption => e
  puts "No such option! Type 'ruby payment-reports.rb -h' for help. Full error: #{e}"
  exit
end

# Configurations
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.javascript_driver = :chrome
Capybara.configure do |config|
  config.default_max_wait_time = 10 # seconds
  config.default_driver = :selenium
end

def list_of_dates(date, country = 'GB')
  from_date = Date.parse(date)
  if country == 'US'
    (from_date..Date.today).map { |d| "#{d.month}/1/#{d.year}" }.uniq # e.g. 7/1/2020
  elsif country == 'AU'
    (from_date..Date.today).map { |d| "#{d.month}/#{d.end_of_month.day}/#{d.year}" }.uniq # e.g. 7/31/2020
  else
    (from_date..Date.today).map { |d| "1/#{d.month}/#{d.year}" }.uniq # e.g. 1/7/2020
  end
end

def website(country)
  if country == 'US'
    'https://vendorcentral.amazon.com'
  elsif country == 'AU'
    'https://vendorcentral.amazon.com.au'
  else
    'https://vendorcentral.amazon.co.uk'
  end
end

# Visit and authenticate
browser = Capybara.current_session
browser.visit website(options[:country])

browser.fill_in 'ap_email', with: options[:email]
browser.fill_in 'Password', with: options[:password]
browser.click_on 'signInSubmit'

puts "Action needed: Amazon will ask you for your One Time Password (OTP), which they will send to your mobile phone. Go to the Chrome browser window that shows Amazon's site, enter the OTP when prompted, and press enter. Type 'done' here on the Terminal and press enter when you are done."
done = gets
puts "Thanks! Now accessing reports... "

browser.choose options[:country] || 'GB'
browser.find('span', id: 'vendor-group-switch-confirm-button').click

sleep 2 # to let the page catch up. The find on the next line should really wait, but in practice it doesn't.

# Navigate to the reports page
browser.find('p#vss_navbar_tab_reports_text').hover
browser.click_on 'Digital Media Reports'

# Get the number of table rows on the page
total_rows = browser.all('td.rep-dash-entry > a:nth-of-type(1)').count

# Iterate through the rows
total_rows.times do |row|
  result = browser.all('td.rep-dash-entry > a:nth-of-type(1)')[row][:onclick]
  # returns the onclick handler in the original HTML e.g. "javascript:window.open('/dmr/download?reportId=vVJF%2Bqac%2FB%555StllyaMJASkOfGvqt%2Frbzrm40WFexGE%3D&reportDescription=SNBEU - Digital eBooks Payment Reports from 1/7/2017 to 1/8/2017&marketplaceId=A1F83G8C2ARO7P&isS3Report=false', 'downloadPopup', 'status=0,resizable=1,scrollbars=0,width=500,height=200');"

  url = result.split("'")[1] # gets the url out of that big mess
  report_name = URI(url).query.split('&')[1].split('=')[1] # gets the reportDescription query

  # Skip the row if it's for a date earlier than requested
  if options[:from_date]
    unless list_of_dates(options[:from_date], options[:country]).any? { |date| report_name[date] }
      puts "Skipped downloading #{options[:country]} report #{report_name} #{row} out of #{total_rows} because its date is before #{Date.parse(options[:from_date])}"
      next
    end
  end

  new_window = browser.open_new_window
  browser.within_window new_window do
    browser.visit("#{website(options[:country])}#{url}")
    browser.click_on 'Download as Excel File'
    new_window.close
  end
  puts "Downloaded Amazon #{options[:country]} report #{row} out of #{total_rows} - #{report_name}"
end
