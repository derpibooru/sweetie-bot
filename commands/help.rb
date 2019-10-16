# frozen_string_literal: true

CommandDispatcher.register name: 'help' do |msg, _|
  msg.reply 'do you seriously think there is help?'
end

CommandDispatcher.alias 'h', 'help'
