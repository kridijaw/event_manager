# frozen_string_literal: false

require 'pry-byebug'
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

# https://www.theodinproject.com/lessons/ruby-event-manager
puts 'EventManager initialized.'

filename = 'event_attendees.csv'
File.read(filename) if File.exist? filename

contents = CSV.open(
  filename,
  headers: true,
  header_converters: :symbol
)

# puts contents

# lines = File.readlines(filename)
# lines.each_with_index do |line, index|
#   next if index.zero?

#   columns = line.split(',')
#   p columns[2]
# end

# def clean_zipcode_old(zipcode)
#   if zipcode.nil?
#     '00000'
#   elsif zipcode.length < 5
#     zipcode.rjust(5, '0')
#   elsif zipcode.length > 5
#     zipcode[0..4]
#   else
#     zipcode
#   end
# end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

# ------------------------------------------------------------------------- #

def legislators_by_zipcode_old(zip)
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

# meaning_of_life = 42

# question = 'The Answer to the Ultimate Question of Life, the Universe, and Everything is <%= meaning_of_life %>'
# template = ERB.new question

# results = template.result(binding)
# puts results

# ------------------------------------------------------------------------- #

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

# contents.each do |row|
#   id = row[0]
#   name = row[:first_name]

#   zipcode = clean_zipcode(row[:zipcode])

#   legislators = legislators_by_zipcode(zipcode)

#   form_letter = erb_template.result(binding)

#   # puts form_letter

#   save_thank_you_letter(id, form_letter)
# end

# ------------------------------------------------------------------------- #
# Assignment: Clean phone numbers

def bad_number(phone)
  if phone.length == 11 && phone[0] != '1' ||
     phone.length > 11 ||
     phone.length < 10
    phone = 'bad number'
  end
  phone
end

def clean_phone(phone)
  return if phone.nil?

  phone = phone.gsub(/[-.()\s]/, '')

  if phone.length == 10
    phone
  elsif phone.length == 11 && phone[0] == '1'
    phone[1..10]
  end

  bad_number(phone)
end

# contents.each do |row|
#   name = row[:first_name]
#   phone = clean_phone(row[:homephone])

#   puts "#{name} #{phone}"
# end

# ------------------------------------------------------------------------- #
# Assignment: Time targeting && Assignment: Day of the week targeting
# Using the registration date and time we want to find out what the peak registration hours are.  #strptime, #strftime, #hour


all_hours = []
all_wdays = []

contents.each do |row|
  regdate = row[:regdate]
  
  all_hours.push(Time.strptime(regdate, '%m/%d/%y %H:%M')
  .strftime('%H'))

  all_wdays.push((Time.strptime(regdate, '%m/%d/%y %H:%M'))
  .strftime('%A'))
end

all_hours_sum = all_hours.each_with_object(Hash.new(0)) do |hour, result|
  result[hour] += 1
end

all_wdays_sum = all_wdays.each_with_object(Hash.new(0)) do |wday, result|
  result[wday] += 1
end

best_hour = (all_hours_sum.max_by { |key, value| value })[0]
best_wday = (all_wdays_sum.max_by { |key, value| value })[0]

puts "The best time to register is #{best_hour}:00"
puts "The best day to register is #{best_wday}"
