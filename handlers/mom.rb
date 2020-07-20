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

$AGREEMENTS = [
  'yes, of course you are.',
  'yes.',
  'of course ^^',
  'yep.',
  'I think so.',
  'how else would it be~',
  'yusss.',
  'obviously.',
  'well, duh!',
  'exactly.',
  'yeah.'
].freeze

$DISAGREEMENTS = [
  'no u',
  'nope.',
  'naaah.',
  'obviously not.',
  "I don't think so.",
  'ask Luna.',
  'no comment.',
  'how about you?',
  'never.',
  'ugh... no.',
  'I disagree'
].freeze

# Mah bot I choose who gets this :3
ALLOWED_IDS = %w[128567958086615040 263103777521926145].freeze

SweetieBot.instance.handler do |msg|
  if lower.start_with?("#{SweetieBot.config.discord.bot_name} are you")
    msg.reply $DISAGREEMENTS.sample
    next
  end

  next unless ALLOWED_IDS.include? msg.sender.id.to_s

  lower = msg.text.downcase

  if lower.start_with?("#{SweetieBot.config.discord.bot_name} who is luna's kitty")
    msg.reply '<@461926422462595092> ^~^', mention: false
    next
  end

  if lower.start_with?("#{SweetieBot.config.discord.bot_name} am i")
    msg.reply $AGREEMENTS.sample
    next
  end
  
  if lower.start_with?("#{SweetieBot.config.discord.bot_name} what")
    msg.reply DICK_PHRASES.sample, mention: false
    next
  end

  if lower.start_with?("#{SweetieBot.config.discord.bot_name} who")
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
