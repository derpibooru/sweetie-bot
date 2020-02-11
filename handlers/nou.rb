# frozen_string_literal: true

SweetieBot.instance.handler do |msg|
  lower = msg.text.downcase

  if lower.match?(/^(the|this)?\s*bot\b/i)
    response = 'no u'
    num = rand(10)

    if num >= 7
      next
    elsif num <= 2
      response = 'correct'
    end

    msg.reply response

    SweetieBot.log "no u from (or should I say to) #{msg.sender.username}"

    true
  else
    false
  end
end
