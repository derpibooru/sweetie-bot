# frozen_string_literal: true

CommandDispatcher.register name: 'image' do |msg, args|
  msg.reply 'no such image!' unless Image.send_image(msg, args.raw)
end

CommandDispatcher.alias 'i', 'image'
CommandDispatcher.alias 'img', 'image'
