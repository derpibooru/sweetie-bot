# frozen_string_literal: true

CommandDispatcher.register name: 'pony' do |msg, args|
  data = Booru.random_image args.raw, msg.channel.nsfw?

  if data
    Image.embed message: msg, data: data, description: args.raw.present? ? nil : 'PONY PONY PONY'
  else
    msg.reply with: 'No results for this query!', mention: false
  end
end

CommandDispatcher.alias 'p', 'pony'
