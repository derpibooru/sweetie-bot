# frozen_string_literal: true

SweetieBot.instance.handler do |msg|
  match_data = msg.text.match /https?:\/\/(?:www\.derpi|trixie)booru\.org(\S*)/
  correct_link = "https://derpibooru.org#{match_data && match_data[1]}"

  if match_data && match_data[0] != correct_link
    correct_link = "<#{correct_link}>" if msg.discord?

    msg.reply correct_link, mention: false
    SweetieBot.log "auto-corrected link (#{match_data[1]}) for #{msg.sender.username}"

    true
  else
    false
  end
end
