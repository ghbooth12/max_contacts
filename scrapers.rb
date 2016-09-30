require 'nokogiri'
require 'csv'

class Scrapers
  def add_csv(input)
    CSV.open('maxcontacts.csv', 'a+') do |csv|
      csv << input
    end
  end

  def drop_comma(str)
    if str.include?(',')
      str.delete(',')
    else
      str
    end
  end

  def match_arr(size, array)
    if array.length != size
      n = size - array.length
      n.times {|i| array.push('NOT MATCHED')}
    end
    return array
  end

  def nil_fix(element)
    element.nil? ? "N/A" : element.text.strip
  end

  def xpath_fix(nodeSet)
    nodeSet.empty? ? "N/A" : (nodeSet.map {|n| n}).join(' ').strip
  end

  def empty_arr_fix(arr)
    arr.empty? ? ["N/A"] : arr.map {|el| el.text.strip}
  end

  # All scrapers
  def ddc_scraper(html, url)
    #==TEMPLATE==
    temp = "Dealer.com"

    #==ACCOUNT FIELDS==ARRAYS
    selector = "//meta[@name='author']/@content"
    org = xpath_fix(html.xpath(selector))
    acc_phone = nil_fix(html.at_css('.value'))

    # ACCOUNT ADDRESS:
    street = nil_fix(html.at_css('.adr .street-address'))
    city = nil_fix(html.at_css('.adr .locality'))
    state = nil_fix(html.at_css('.adr .region'))
    zip = nil_fix(html.at_css('.adr .postal-code'))

    #==CONTACT FIELDS==ARRAYS
    full_names = empty_arr_fix(html.css('#staffList .vcard .fn'))
    jobs = empty_arr_fix(html.css('#staffList .vcard .title'))
    emails = empty_arr_fix(html.css('#staffList .vcard .email'))

    size = full_names.length
    if jobs.length != size
      n = size - jobs.length
      n.times {jobs.push("N/A")} if n >= 0
    elsif emails.length != size
      n = size - emails.length
      n.times {emails.push("N/A")} if n >= 0
    end

    fnames = []
    lnames = []
    full_names.each {|name|
      words = name.split(' ')
      fnames.push(words[0])
      lnames.push(words[-1])
    }

    for i in 0...size
      add_csv([temp, org, acc_phone, street, city, state, zip, jobs[i], fnames[i], lnames[i], emails[i]])
    end
  end # End of Main Method: "def ddc_scraper"

  def do_scraper(html, url)
    #==TEMPLATE==
    temp = "DealerOn"

    #==ACCOUNT FIELDS==ARRAYS
    org = html.at_css('.dealerName').text
    acc_phones = html.css('.callNowClass').collect {|phone| phone.text}
    acc_phones_str = acc_phones.join(', ')

    # ACCOUNT FULL ADDRESS: #=NEED TO SPLIT!!!!!!!
    addy = html.at_css('.adr').text
    puts addy

    #==CONTACT FIELDS==ARRAYS
    full_names = html.css('.staff-title').map {|name| name.text.strip}
    jobs = html.css('.staff-desc').map {|job| job.text.strip}
    phones = html.css('.phone1').map {|phone| phone.text.strip}
    emails = html.css('.email').map {|email| email.text.strip}

    size = full_names.length
    if jobs.length &&  phones.length && emails.length == size
      fnames = []
      lnames = []
      full_names.each {|name|
        words = name.split(' ')
        fnames.push(words[0])
        lnames.push(words[-1])
      }

      for i in 0...size
        add_csv([temp, org, acc_phones_str, street, city, state, zip, jobs[i], fnames[i], lnames[i], phones[i], emails[i]])
      end
    else
      puts "Employee contact info column length error"
    end

  end # End of Main Method: "def do_scraper"

  def cobalt_scraper(html, url)   # Problems w/ cobalt_verify below.
    #==TEMPLATE==
    temp = "Cobalt"

    #==ACCOUNT FIELDS==ARRAYS
    org_sel = "//img[@class='cblt-lazy']/@alt"
    org = html.xpath(org_sel)
    if org.empty?
      org = "Not Found"
    end
    acc_phone = html.css('.CONTACTUsInfo').text

    # ACCOUNT FULL ADDRESS: # ONE SINGLE ADDRESS STRING
    selector = "//a[@href='HoursAndDirections']"
    street = html.xpath(selector).text
    city = ''
    state = ''
    zip = ''

    #==CONTACT FIELDS==ARRAYS
    full_names = html.css('.contact-name').map {|name| name.text.strip}
    jobs = html.css('.contact-title').map {|job| job.text.strip}
    emails = html.css('.contact-email').map {|email| email.text.strip}

    size = full_names.length
    if jobs.length && emails.length == size
      fnames = []
      lnames = []
      full_names.each {|name|
        words = name.split(' ')
        fnames.push(words[0])
        lnames.push(words[-1])
      }

      for i in 0...size
        add_csv([temp, org, acc_phone, street, city, state, zip, jobs[i], fnames[i], lnames[i], emails[i]])
      end
    else
      puts "Employee contact info column length error"
    end
  end # End of Main Method: "def cobalt_scraper"

  def df_scraper(html, url)   # Problem w/ email.
    #==TEMPLATE==
    temp = "DealerFire"

    #==ACCOUNT FIELDS==ARRAYS
    org = html.at_css('.foot-thanks h1').text
    acc_phones = html.css('#salesphone').collect {|phone| phone.text}
    acc_phones_str = acc_phones.join(', ')

    # ACCOUNT FULL ADDRESS:
    addy = html.at_css('.hide-address').text.split(' ')
    street = addy[0..-4].join(' ')
    city = drop_comma(addy[-3])
    state = drop_comma(addy[-2])
    zip = addy[-1]

    #==CONTACT FIELDS==ARRAYS
    full_names = html.css('.fn').map {|name| name.text.strip}
    jobs = html.css('.position').map {|job| job.text.strip}
    phones = html.css('.tel').map {|phone| phone.text.strip}
    selector = "//meta[@itemprop='email']/@content"
    nodes = html.xpath(selector)
    emails = nodes.map {|n| n}

    size = full_names.length
    if jobs.length == size
      match_arr(size, phones)
      match_arr(size, emails)

      fnames = []
      lnames = []
      full_names.each {|name|
        words = name.split(' ')
        fnames.push(words[0])
        lnames.push(words[-1])
      }

      for i in 0...size
        add_csv([temp, org, acc_phones_str, street, city, state, zip, jobs[i], fnames[i], lnames[i], phones[i], emails[i]])
      end
    else
      puts "Employee contact info column length error"
    end
  end # End of Main Method: "def df_scraper"

  def di_scraper(html, url)
    #==TEMPLATE==
    temp = "DealerInspire"

    #==ACCOUNT FIELDS==ARRAYS
    org = html.at_css('.organization-name').text
    acc_phones = html.css('.tel').collect {|phone| phone.text}
    acc_phones_str = acc_phones.join(', ')

    # ACCOUNT ADDRESS:
    street = html.at_css('.street-address').text
    city = html.at_css('.locality').text
    state = html.at_css('.region').text
    zip = html.at_css('.postal-code').text

    #==CONTACT FIELDS==ARRAYS
    full_names = []  # BEGIN NAMES ARRAY
    html.css('.staff-item h3').map {|name|
      unless full_names.include?(name.text.strip)
        full_names.push(name.text.strip)
      end
    } # END NAMES

    jobs = []  # BEGIN JOBS ARRAY
    html.css('.staff-item h4').map {|job|
      unless jobs.include?(job.text.strip)
        jobs.push(job.text.strip)
      end
    }  # END JOBS ARRAY

    phones = html.css('.staffphone').map {|phone| phone.text.strip}

    # EMAILS BELOW
    selector = "//a[starts-with(@href, 'mailto:')]/@href"
    nodes = html.xpath(selector)
    emails =  nodes.collect {|n| n.value[7..-1]}
    # END EMAILS

    size = full_names.length
    if jobs.length &&  phones.length && emails.length == size
      fnames = []
      lnames = []
      full_names.each {|name|
        words = name.split(' ')
        fnames.push(words[0])
        lnames.push(words[-1])
      }

      for i in 0...size
        add_csv([temp, org, acc_phones_str, street, city, state, zip, jobs[i], fnames[i], lnames[i], phones[i], emails[i]])
      end
    else
      puts "Employee contact info column length error"
    end
  end # End of Main Method: "def di_scraper"
end
