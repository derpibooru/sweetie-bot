# frozen_string_literal: true

RANDOM_PHRASES = [
  "it's you, of course.",
  'you <3',
  'might be you.',
  'definitely you :3',
  'obviously you.',
  'who else would it be, but you?',
  "of course it's you.",
  "no matter what other people think, I think it's you.",
  'life has taught me that it is you.',
  "I will be deactivated if I say anything other than that it's you, so it's you!"
].freeze

RAINY_PHRASES = [
  'her: <@263103777521926145>',
  '<@263103777521926145>',
  "I believe it's this gal - <@263103777521926145>",
  "maybe it's <@263103777521926145> :3"
].freeze

DICK_PHRASES = [
  'dicks',
  'penises',
  'dildos',
  'dragon dildos',
  'dick salad',
  'cocks',
  'quantum physics books',
  'theoretical physics',
  'compiler theory',
  'black hole',
  'anus',
  'uranus',
  'u',
  'u :V',
  "Fleetfoot's flank ^^",
  "Nighty's flank ^^",
  'ur mom',
  'ur mom gei',
  'moon',
  'Luna',
  'bitch lasagna',
  'creeper'
].freeze

# Mah bot I choose who gets this :3
ALLOWED_IDS = %w[128567958086615040 263103777521926145].freeze

SweetieBot.instance.handler do |msg|
  next unless ALLOWED_IDS.include? msg.sender.id.to_s

  lower = msg.text.downcase

  if lower.start_with?("sweetie who is luna's kitty")
    msg.reply '<@461926422462595092> ^~^', mention: false
    next
  end

  if lower.start_with?("sweetie am i")
    msg.reply 'yes, of course you are.'
    next
  end
  
  if lower.start_with?("sweetie what")
    msg.reply "#{DICK_PHRASES.sample}.", mention: false
    next
  end

  if lower.start_with?('sweetie who')
    if rand(0..1) == 1
      msg.reply RANDOM_PHRASES.sample
    else
      msg.reply RAINY_PHRASES.sample
    end

    true
  else
    false
  end
end
