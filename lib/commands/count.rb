CommandDispatcher.register name: 'count' do |msg, args|
  data = Booru.search args.raw, msg.channel.nsfw?

  msg.reply with: "#{data.total} images match query '#{args.raw}'.", mention: false
end

CommandDispatcher.alias 'c', 'count'
