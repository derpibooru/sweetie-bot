# frozen_string_literal: true

require 'net/http'
require 'json'

CommandDispatcher.register name: 'printerfact', help_text: 'displays a random fact about printers' do |msg, _|
  res = Net::HTTP.get_response(URI('https://catfact.ninja/fact'))

  next unless res

  fact = JSON.parse(res.body)['fact']

  next unless fact

  fact = fact.gsub(/(cat|feline)/i, 'printer')
             .gsub(/kitten/i, 'baby printer')
             .gsub(/(lion|leopard|lynx|cheetah)/i, 'big printer')
             .gsub(/\.(\s*)(printer|baby|big)/) do |match|
                ".#{$1}#{$2.capitalize}"
              end  

  fact = fact.capitalize

  msg.reply with: fact, mention: false
end

CommandDispatcher.alias 'pf', 'printerfact'
