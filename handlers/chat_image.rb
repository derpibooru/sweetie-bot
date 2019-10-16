# frozen_string_literal: true

SweetieBot.instance.handler do |msg|
  match_data = msg.text.match />>([0-9]+)/

  if match_data
    Image.send_image(msg, match_data[1])
    SweetieBot.log "image (#{match_data[1]}) from #{msg.sender.username}"

    true
  else
    false
  end
end
