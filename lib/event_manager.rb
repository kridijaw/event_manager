# frozen_string_literal: false

require 'pry-byebug'
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

# https://www.theodinproject.com/lessons/ruby-event-manager
puts 'EventManager initialized.'

filename = 'event_attendees.csv'
File.read(filename) if File.exist? filename

# puts contents

lines = File.readlines(filename)
lines.each_with_index do |line, index|
  next if index.zero?

  columns = line.split(',')
  # p columns[2]
end

def clean_zipcode_old(zipcode)
  if zipcode.nil?
    '00000'
  elsif zipcode.length < 5
    zipcode.rjust(5, '0')
  elsif zipcode.length > 5
    zipcode[0..4]
  else
    zipcode
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

# ------------------------------------------------------------------------- #

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    )
    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislators_string = legislator_names.join(', ')
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

contents = CSV.open(
  filename,
  headers: true,
  header_converters: :symbol
)

# contents.each do |row|
#   name = row[:first_name]

#   zipcode = clean_zipcode(row[:zipcode])

#   legislators = legislators_by_zipcode(zipcode)

#   puts "#{name} #{zipcode} #{legislators}"
# end

# ------------------------------------------------------------------------- #

template_letter = File.read('form_letter.html')

# contents.each do |row|
#   name = row[:first_name]

#   zipcode = clean_zipcode(row[:zipcode])

#   legislators = legislators_by_zipcode(zipcode)

#   personal_letter = template_letter.gsub('FIRST_NAME', name)
#   personal_letter.gsub!('LEGISLATORS', legislators)

#   puts personal_letter
# end

# ------------------------------------------------------------------------- #

meaning_of_life = 42

question = 'The Answer to the Ultimate Question of Life, the Universe, and Everything is <%= meaning_of_life %>'
template = ERB.new question

results = template.result(binding)
# puts results

# ------------------------------------------------------------------------- #
