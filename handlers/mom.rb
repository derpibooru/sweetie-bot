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

AGREEMENTS = [
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

DISAGREEMENTS = [
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
  lower = msg.text.downcase
  response = nil
  mention = true

  if lower.start_with?("#{SweetieBot.config.discord.bot_name} are you")
    response = DISAGREEMENTS.sample
    mention = true
  end

  if !response && ALLOWED_IDS.include?(msg.sender.id.to_s)
    if lower.start_with?("#{SweetieBot.config.discord.bot_name} who is luna's kitty")
      response = '<@461926422462595092> ^~^'
      mention = false
    end

    if !response && lower.start_with?("#{SweetieBot.config.discord.bot_name} am i")
      response = AGREEMENTS.sample
      mention = true
    end

    if !response && lower.start_with?("#{SweetieBot.config.discord.bot_name} what")
      response = DICK_PHRASES.sample
      mention = false
    end

    if !response && lower.start_with?("#{SweetieBot.config.discord.bot_name} who")
      response = if rand(0..1) == 1
        RANDOM_PHRASES.sample
      else
        RAINY_PHRASES.sample
      end
    end
  end

  if response
    msg.reply response, mention: mention
    true
  else
    false
  end
end
