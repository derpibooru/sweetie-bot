# frozen_string_literal: true

CommandDispatcher.register name: 'tagfight', help_text: 'compare two search queries' do |msg, args|
  match = args.raw.downcase.strip.match /^(.+)\s+(::|vs\.|versus\.|vs|versus|against|against\.|\/\/|\/|\|\|\||\.\.|\.\.\.|\n|\r\n|\n\n|\r\n\r\n)\s+(.+)$/

  next unless match

  query1 = match[1].strip
  query2 = match[3].strip

  next if query1 == '' || query2 == ''

  search_result1 = Booru.search query: query1, filter: SweetieBot.config.booru.everything_filter
  sleep 0.125
  search_result2 = Booru.search query: query2, filter: SweetieBot.config.booru.everything_filter

  total1 = search_result1.total
  total2 = search_result2.total

  winner = if total1 > total2
    "`#{query1}` with **#{total1}** images (against **#{total2}** of `#{query2}`)"
  elsif total1 == total2
    "tie! Both have **#{total1}** images on record"
  else
    "`#{query2}` with **#{total2}** images (against **#{total1}** of `#{query1}`)"
  end

  msg.reply with: "**Tag Fight**\n`#{query1}` vs. `#{query2}`\n\n**Winner:**\n#{winner}", mention: false
end

CommandDispatcher.alias 'tf', 'tagfight'
