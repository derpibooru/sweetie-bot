# frozen_string_literal: true

SweetieBot.instance.handler do |msg|
  lower = msg.text.downcase

  if lower.match?(/^(the|this)?\s*bot\b/i)
    SweetieBot.instance.rate_limit 'nou', 5 do
      emoji = case rand(1..10)
      when 1, 2, 3
        # YES
        ['🇾', '🇪', '🇸']
      when 4, 5, 6
        # NOU
        ['🇳', '🇴', '🇺']
      when 10
        # DICK
        ['🇩', '🇮', '🇨', '🇰']
      else
        # NO
        ['🇳', '🇴']
      end

      next unless emoji

      emoji.each do |char|
        msg.message.react char
        sleep 0.25
      end

      SweetieBot.log "no u from (or should I say to) #{msg.sender.username}"

      true
    end
  else
    false
  end
end
