require 'mechanize'
require 'nokogiri'
require 'open-uri'
require_relative 'scrapers.rb'
require_relative 'reader.rb'

class TempFinder
  def temp_method(item, docu, url, id)
    sc = Scrapers.new

    case item
    when "DDC"
      sc.ddc_scraper(docu, url, id)
      puts "Found DDC on Dealer.com template."
    when "dealeron"
      sc.do_scraper(docu, url, id)
      puts "Found dealeron on DealerOn.com template."
    when "cobalt"
      sc.cobalt_scraper(docu, url, id)
      puts "Found cobalt on Cobalt.com template."
    when "DealerFire"
      sc.df_scraper(docu, url, id)
      puts "Found DealerFire on DealerFire.com template."
    when "di_homepage"
      sc.di_scraper(docu, url, id)
      puts "Found di_homepage on DealerInspire.com template."
    else
      puts "Template Version Unidentified."
    end
  end

  def search(url_list)
    temp_list = [ 'DDC', 'dealeron', 'cobalt', 'DealerFire', 'di_homepage' ]
    urls = url_list.map {|hash| hash[:url]}

    urls.each do |url|
      doc = Nokogiri::HTML(open(url))
      result = false

      for i in 0...(temp_list.length)
        verify = doc.at_css('head').text.include?(temp_list[i])

        if verify
          result = true
          id = url_list[urls.index(url)][:id]
          temp_method(temp_list[i], doc, url, id)
        end
      end

      unless result
        puts "NOT FOUND"
      end

      puts "delaying..."
      delay_time = rand(11)
      sleep(delay_time)
    end
  end
end
