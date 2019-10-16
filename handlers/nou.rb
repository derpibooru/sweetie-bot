# frozen_string_literal: true

SweetieBot.instance.handler do |msg|
  lower = msg.text.downcase

  if lower.start_with?('bot')        ||
     lower.include?('sweetie')       ||
     lower.include?('this bot')      ||
     lower.include?('derpi bot')     ||
     lower.include?('derpibooru bot')
    response = 'no u'
    num = rand(10)

    if num > 7
      response += ' :V'
    elsif num == 1
      response = 'correct'
    end

    msg.reply response

    SweetieBot.log "no u from (or should I say to) #{msg.sender.username}"

    true
  else
    false
  end
end
