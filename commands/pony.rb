# frozen_string_literal: true

CommandDispatcher.register name: 'pony', help_text: 'displays a random image matching the search query' do |msg, args|
  img = Booru.random_image args.raw, msg.channel.check_nsfw?

  if img
    Image.embed img, message: msg, description: args.present? ? nil : 'PONY PONY PONY'
  else
    msg.reply with: '_No results for this query!_', mention: false
  end
end

CommandDispatcher.alias 'p', 'pony'
