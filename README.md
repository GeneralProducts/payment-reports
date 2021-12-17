This repo contains two Ruby tools:

* `download_payment_reports.rb` downloads payment reports from Vendor Central
* `generate_import_file.rb` processes them, and LSI files, so they can be imported into Consonance

If you use this code, please manually check the outputs. No guarantees are made and this code is provided as is.

Update, Xmas 2021. Amazon have changed their page so this scraper no longer works. The file combiner should, though. 

# 1. Download Amazon payment reports
> Super early version! Please raise an issue with your problems. The AU country option in particular is untested!

Until such time as payment reports are available in their API, save time by automating the download of your digital payment reports from your vendor central account.

## What does it do?

This code uses the Chrome browser to perform the actions you take on the Vendor Central website, just as you do when you log in and click the download links.

It doesn't download every file on the page, as you'll already have downloaded many of them. Instead, it inspects each file name, which has the date included. The code clicks on the files with a date in the filename that is greater than the date you give it. If you enter a date of 31/03/2017, the code will download all the files with the date 01/04/2017 and later.

## How does it interact with Amazon's systems?

It doesn't. The code inspects the HTML that is the Vendor Central website, so it knows what to click on. The code only ever looks as far as your own human eyeballs can.

## Summary instructions

* Download download_payment_reports.rb
* `cd` to that folder
* Run `ruby download_payment_reports.rb -h`to check the gems are installed
* If you need to install any dependencies, run `gem install <gemname>` for the gems required in download_payment_reports.rb

## Installation (Mac)

* Download the file download_payment_reports.rb to your computer.

### Create a new folder on your computer to keep the code in
* Open Terminal.app on your computer, by pressing cmd+space bar, typing "Terminal" and pressing "Enter".
* Type `cd` in the Terminal and press enter.
* Type `mkdir payment-reports-code` in the Terminal and press enter.
* Type `cd payment-reports-code` in the Terminal and press enter.
* Open Finder. Navigate to where the download_payment_reports.rb downloaded to. Copy that file.
* In Finder, go to your new payment-reports-code folder (you could use the search bar in the Finder window) and paste the payment-reports.rb file into that folder.
* Back in the Terminal, type `ls` and press enter. You should see the filename `download_payment_reports.rb` appear.
* Still in the Terminal, type `ruby download_payment_reports.rb` and press enter. You should see the message "Error: You have to provide at least an email and password. Type `ruby download_payment_reports.rb -h` for help."

If you have got this far, it's working! If not, try the following.

### Install the gems
* In the Terminal, type `gem install selenium-webdriver` and press enter. This will run for a while. If you see `Error installing selenium-webdriver` please raise an issue.
* When it's done, in the Terminal, type `gem install capybara` and press enter. This will run for a while.
* When it's done, in the Terminal, type `gem install uri` and press enter. This will run for a while.
* When it's done, in the Terminal, type `gem install byebug` and press enter. This will run for a while.
* When it's done, in the Terminal, type `gem install optparse` and press enter. This will run for a while.
* Still in the Terminal, type `ruby download_payment_reports.rb` and press enter. You should see the message "Error: You have to provide at least an email and password. Type `ruby download_payment_reports.rb -h` for help."

If that's still not working, try the following:
* In the Terminal, type `which ruby` and raise an issue on this GitHub repo, pasting in this info.

____

* In the Terminal, type `ruby download_payment_reports.rb -h` and press enter. Follow the instructions for downloading the correct reports.

TODO: more instructions


# 2. Transform Amazon and LSI sales reports

* Put the files you want to tranform into the /files folder
* Run `ruby generate_import_file.rb` with options e.g. `ruby generate_import_file.rb --channel UKH -d GBP -i 31-10-2020`
