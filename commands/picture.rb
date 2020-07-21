# frozen_string_literal: true

ADORABLE_PHRASES = [
  'ADORABLENESS!',
  'CUTENESS INCOMING!',
  'DAWWWW!',
  'CUTE FURS!'
].freeze

CommandDispatcher.register name: 'picture', help_text: 'displays a random image matching the search query' do |msg, args|
  img = Booru.random_image args.raw, msg.channel.check_nsfw?

  if img
    Image.embed img, message: msg, description: args.present? ? nil : ADORABLE_PHRASES.sample, condense: true
  else
    msg.reply with: '_No results for this query!_', mention: false
  end
end

CommandDispatcher.alias 'p', 'picture'
CommandDispatcher.alias 'f', 'picture'
