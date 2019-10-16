CommandDispatcher.register name: 'help' do |msg, args|
  msg.reply 'do you seriously think there is help?'
end

CommandDispatcher.alias 'h', 'help'
