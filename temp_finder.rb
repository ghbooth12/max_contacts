require 'mechanize'
require 'nokogiri'
require 'open-uri'
require_relative 'scrapers.rb'
require_relative 'reader.rb'

class TempFinder
  def temp_method(item, docu)
    sc = Scrapers.new

    case item
    when "DDC"
      sc.ddc_scraper(docu)
      puts "Found DDC on Dealer.com template."
    when "dealeron"
      sc.do_scraper(docu)
      puts "Found dealeron on DealerOn.com template."
    when "cobalt"
      sc.cobalt_scraper(docu)
      puts "Found cobalt on Cobalt.com template."
    when "DealerFire"
      sc.df_scraper(docu)
      puts "Found DealerFire on DealerFire.com template."
    when "di_homepage"
      sc.di_scraper(docu)
      puts "Found di_homepage on DealerInspire.com template."
    else
      puts "Template Version Unidentified."
    end
  end

  def search(urls)
    temp_list = [ 'DDC', 'dealeron', 'cobalt', 'DealerFire', 'di_homepage' ]

    urls.each do |url|
      doc = Nokogiri::HTML(open(url))
      result = false

      for i in 0...(temp_list.length)
        verify = doc.at_css('head').text.include?(temp_list[i])

        if verify
          result = true
          temp_method(temp_list[i], doc)
        end
      end

      unless result
        puts "NOT FOUND"
      end

      delay_time = rand(11)
      sleep(delay_time)
      puts "delaying..."
    end
  end
end
