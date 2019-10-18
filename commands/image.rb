# frozen_string_literal: true

CommandDispatcher.register name: 'image', help_text: 'displays information about a specific image' do |msg, args|
  msg.reply '_no such image!_' unless Image.send_image(msg, args.raw)
end

CommandDispatcher.alias 'i', 'image'
CommandDispatcher.alias 'img', 'image'
