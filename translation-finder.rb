#!/usr/bin/env ruby
require 'microsoft_translator'

from_regex = Regexp.compile(ARGV[0], Regexp::IGNORECASE)
to_regex = Regexp.compile(ARGV[2], Regexp::IGNORECASE)

from_lang = ARGV[1]
to_lang = ARGV[3]

words_file = File.open(ARGV[4], 'r:iso-8859-1') # Ugh

translator = MicrosoftTranslator::Client.new(ENV['MICROSOFT_CLIENT_ID'], ENV['MICROSOFT_TRANSLATOR_SECRET'])
total_words = 0
found_words = []

words_file.each_slice(100).with_index do |words|
  valid_words = words.select{ |word| word =~ from_regex }.map(&:strip)

  next if valid_words.empty?
  total_words += valid_words.size

  translator_response = translator.translate(valid_words, from_lang, to_lang, 'text/plain')

  translator_response.scan(/"(.*?)"/).flatten.each_with_index do |word, i|
    found_words << [word, valid_words[i]] if word =~ to_regex
  end
end

puts '*' * 40

found_words.each do |translated, base|
  puts "#{base} - #{translated}"
end

puts "Tested #{total_words} words"