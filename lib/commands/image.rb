class ChatImage
  def self.handle(msg)
    match_data = msg.text.match />>([0-9]+)/

    if match_data
      data = Booru.image(match_data[1])

      if data then
        Image.embed message: msg, data: data
      end
    end
  end
end
