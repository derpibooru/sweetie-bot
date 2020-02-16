# frozen_string_literal: true

RICKROLL_LINKS = [
  'https://www.youtube.com/watch?v=cvh0nX08nRw',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  'https://www.youtube.com/watch?v=j5a0jTc9S10',
  'https://www.youtube.com/watch?v=dPmZqsQNzGA',
  'https://www.youtube.com/watch?v=xfr64zoBTAQ'
].freeze

CommandDispatcher.register name: 'rickroll' do |msg, _|
  msg.reply "<#{RICKROLL_LINKS.sample}>", mention: false
end

CommandDispatcher.alias 'dailyvideo', 'rickroll'
CommandDispatcher.alias 'bestvideo', 'rickroll'
CommandDispatcher.alias 'gen5', 'rickroll'
CommandDispatcher.alias 'nudes', 'rickroll'
CommandDispatcher.alias 'send nudes', 'rickroll'
