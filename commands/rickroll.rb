# frozen_string_literal: true

CommandDispatcher.register name: 'rickroll' do |msg, _|
  msg.reply '<https://www.youtube.com/watch?v=dQw4w9WgXcQ>', mention: false
end

CommandDispatcher.alias 'dailyvideo', 'rickroll'
CommandDispatcher.alias 'bestvideo', 'rickroll'
CommandDispatcher.alias 'gen5', 'rickroll'
CommandDispatcher.alias 'nudes', 'rickroll'
