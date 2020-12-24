This repo contains two files:

* `payment-reports.rb` downloads payment reports from Vendor Central
* `generate_import_file.rb` processes them so they can be imported into Consonance

If you use this code, please manually check the outputs. No guarantees are made and this code is provided as is.

# 1. Download Amazon payment reports
> Super early version! Please raise an issue with your problems. The AU country option in particular is untested!

Until such time as payment reports are available in their API, save time by automating the download of your digital payment reports from your vendor central account.

## Installation (Mac)

* Download the file payment-reports.rb to your computer.

### Create a new folder on your computer to keep the code in
* Open Terminal.app on your computer, by pressing cmd+space bar, typing "Terminal" and pressing "Enter".
* Type `cd` in the Terminal and press enter.
* Type `mkdir payment-reports-code` in the Terminal and press enter.
* Type `cd payment-reports-code` in the Terminal and press enter.
* Open Finder. Navigate to where the payment-reports.rb downloaded to. Copy that file.
* In Finder, go to your new payment-reports-code folder (you could use the search bar in the Finder window) and paste the payment-reports.rb file into that folder.
* Back in the Terminal, type `ls` and press enter. You should see the filename `payment-reports.rb` appear.
* Still in the Terminal, type `ruby payment-reports.rb` and press enter. You should see the message "Error: You have to provide at least an email and password. Type `ruby payment-reports.rb -h` for help."

If you have got this far, it's working! If not, try the following.

### Install the gems
* In the Terminal, type `gem install selenium-webdriver` and press enter. This will run for a while. If you see `Error installing selenium-webdriver` please raise an issue.
* When it's done, in the Terminal, type `gem install capybara` and press enter. This will run for a while.
* When it's done, in the Terminal, type `gem install uri` and press enter. This will run for a while.
* When it's done, in the Terminal, type `gem install byebug` and press enter. This will run for a while.
* When it's done, in the Terminal, type `gem install optparse` and press enter. This will run for a while.
* Still in the Terminal, type `ruby payment-reports.rb` and press enter. You should see the message "Error: You have to provide at least an email and password. Type `ruby payment-reports.rb -h` for help."

If that's still not working, try the following:
* In the Terminal, type `which ruby` and raise an issue on this GitHub repo, pasting in this info.

____

* In the Terminal, type `ruby payment-reports.rb -h` and press enter. Follow the instructions for downloading the correct reports.
TODO: more instructions


# 2. Transform Amazon and LSI sales reports

* Put the files you want to tranform into the /files folder
* Run `ruby generate_import_file.rb` with options e.g. `ruby generate_import_file.rb --channel UKH -d GBP -i 31-10-2020`
