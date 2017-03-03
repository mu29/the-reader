require 'epub/parser'
require 'readline'
require './tts'

Readline.completion_append_character = '/'
Readline.completion_proc = Proc.new do |str|
  Dir[str + '*'].grep( /^#{Regexp.escape(str)}/ )
end

puts '[ Enter the epub file path ]'
path = Readline.readline('> ').strip
path = path[-1] == '/' ? path[0...path.size - 1] : path
book = EPUB::Parser.parse(path)

contents = book.each_content
            .map { |page| page.content_document&.nokogiri&.text&.strip }
            .reject(&:nil?)

puts "\n[ Select chapter to receive audio file ]"
puts contents.map { |c| c.split("\n").drop(1).join(' ') }
             .map.with_index { |c, i| "#{i}: #{c[0..50].strip}\n" }
             .reject { |c| c.size < 25 }
chapter = Readline.readline('> ').strip.to_i
contents[chapter].to_file "en"
