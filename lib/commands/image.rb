class ChatImage
  def self.handle(msg)
    match_data = msg.text.match />>([0-9]+)/

    if match_data
      ChatImage.send_image msg, match_data[1]
    end
  end

  def self.send_image(msg, id)
    data = Booru.image(id)

    if data then
      Image.embed message: msg, data: data
      return true
    end
  end
end

CommandDispatcher.register name: 'image' do |msg, args|
  if !ChatImage.send_image(msg, args.raw)
    msg.reply with: 'no such image!'
  end
end

CommandDispatcher.alias 'i', 'image'
CommandDispatcher.alias 'img', 'image'
