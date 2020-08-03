# frozen_string_literal: true

SweetieBot.instance.handler do |msg|
  next unless SweetieBot.config.discord.autocorrect_links

  corrected = false
  correct_link = nil

  SweetieBot.config.discord.autocorrect_replacements.each do |rep|
    next if corrected

    match_data = msg.text.match /https?:\/\/#{rep[0]}(\S*)/
    correct_link = "https://#{rep[1]}#{match_data && match_data[1]}"

    corrected = true if match_data && match_data[0] != correct_link
  end

  if corrected
    msg.reply "<#{correct_link}>", mention: false
    SweetieBot.log "auto-corrected link for #{msg.sender.username}"

    true
  else
    false
  end
end
