require 'csv'
require_relative 'temp_finder.rb'

class Reader
  attr_accessor :url_list

  def initialize
    @url_list = []
  end

  def add_entry(url)
    @url_list.push(url)
  end

  def import_from_csv(file_name)
    csv_text = File.read(file_name)
    csv = CSV.parse(csv_text, headers: true, skip_blanks: true)

    csv.each do |row|
      @url_list.push(row.to_s.chomp)
    end
  end

  def read_csv
    print "Enter CSV file to import: "
    file_name = gets.chomp

    if file_name.empty?
      puts "No CSV file read"
    end

    begin
      import_from_csv(file_name)
      entry_count = @url_list.count
      puts "#{entry_count} new entries added from #{file_name}"
      puts "========================="
      puts "=== Start mining data ==="
      puts "========================="
      TempFinder.new.search(@url_list)
    # rescue
    #   puts "#{file_name} is not a valid CSV, please enter the name of a valid CSV file"
    #   read_csv
    end
  end

  def get_all_urls
    @url_list.each do |entry|
      puts entry
    end
  end
end
