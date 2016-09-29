require_relative 'reader.rb'

reader = Reader.new

system "clear"
puts "Welcome to Max Contacts!\n"

reader.read_csv
