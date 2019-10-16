CommandDispatcher.register name: 'help' do |msg, args|
  msg.reply with: "do you seriously think there is help?"
end

CommandDispatcher.alias 'h', 'help'
