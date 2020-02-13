# frozen_string_literal: true

RANDOM_PHRASES = [
  "it's you, of course.",
  'you <3',
  "there is a high probability it's you.",
  "it's Celestia! Um... I mean you! hehehehe ><",
  'might be you.',
  'definitely you :3',
  'obviously you.',
  'the person I am pinging :3'
].freeze

# Mah bot I choose who gets this :3
ALLOWED_IDS = %w[128567958086615040 263103777521926145 77736797399941120].freeze

SweetieBot.instance.handler do |msg|
  next unless ALLOWED_IDS.include? msg.sender.id.to_s

  lower = msg.text.downcase

  if lower.start_with?("sweetie who is luna's kitty")
    msg.reply '<@461926422462595092> ^~^', mention: false
    next
  end

  if lower.start_with?('sweetie who is your') ||
     lower.start_with?('sweetie who is the best') ||
     lower.start_with?('sweetie who is best') ||
     lower.start_with?('sweetie who is the cutest')
    msg.reply RANDOM_PHRASES.sample

    true
  else
    false
  end
end
