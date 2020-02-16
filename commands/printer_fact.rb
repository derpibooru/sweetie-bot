# frozen_string_literal: true

require 'net/http'
require 'json'

PRINTER_FACTS = JSON.parse(File.read('config/printer_facts.json')).freeze

CommandDispatcher.register name: 'printerfact', help_text: 'displays a random fact about printers' do |msg, _|
  msg.reply with: PRINTER_FACTS.sample, mention: false
end

CommandDispatcher.alias 'pf', 'printerfact'
