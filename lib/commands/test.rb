CommandDispatcher.register name: 'test' do |msg, args|
  msg.reply with: "you ran the test command with the following arguments: #{args.raw}"
end
