# frozen_string_literal: true

CommandDispatcher.register name: 'rickroll' do |msg, _|
  msg.reply 'hey, check this out <https://www.youtube.com/watch?v=dQw4w9WgXcQ>'
end

CommandDispatcher.alias 'dailyvideo', 'rickroll'
CommandDispatcher.alias 'bestvideo', 'rickroll'
CommandDispatcher.alias 'gen5', 'rickroll'
CommandDispatcher.alias 'nudes', 'rickroll'
