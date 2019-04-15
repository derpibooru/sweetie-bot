CommandDispatcher.register name: 'test' do |msg|
  msg.reply with: 'you ran the test command!'
end
