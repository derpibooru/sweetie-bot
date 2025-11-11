# frozen_string_literal: true

require 'discordrb'

class Discordrb::Channel
  def channel_type
    case type
    when 0
      :text
    when 1
      :private
    when 2
      :voice
    when 3
      :group
    else
      :text
    end
  end

  def mention
    "<##{id}>"
  end

  def send(*opts)
    send_message opts[0]
  end

  def check_nsfw?
    nsfw? || [:private, :group].include?(channel_type)
  end
end

class Discordrb::Events::MessageEvent
  def sender
    author
  end

  def text
    content
  end

  def reply(*args)
    opts = (args[0].is_a?(String) ? args[1] : args[0]) || {}
    msg = args[0].is_a?(String) ? args[0] : opts[:with]

    if opts[:mention] != false
      respond "#{sender.mention}, #{msg}"
    else
      respond msg
    end
  end

  def delete
    message.delete
  end

  def edit(new_message)
    message.edit(new_message)
  end

  def from_bot?
    from_bot? || message.webhook?
  end

  def escape_name(username)
    user_id = username.gsub(/^<@!?/, '').gsub(/>$/, '').to_i

    if user_id && (member = server.member(user_id))
      return member.display_name
    end

    'Unknown Member'
  end
end

# A container for a Discord connection.
# @author Luna aka Meow the Cat
# @attr [Discordrb::Bot] raw The raw bot object.
# @attr [String] connection_id The ID of the connection as defined in the YAML file.
class DiscordConnection
  attr_accessor :raw, :connection_id

  def initialize(opts)
    @raw = Discordrb::Bot.new(
      token:       ENV['DISCORD_BOT_TOKEN'] || opts.token,
      type:        (opts.client_type || :bot),
      parse_self:  !opts.ignore_self,
      ignore_bots: opts.ignore_bots
    )

    @raw.ready do
      @raw.game = "#{opts.bot_title} v#{SweetieBot.version}" if opts.display_version
    end
  end

  def connect(*_opts)
    @raw.run true
  end

  def disconnect
    @raw.stop
  end

  def message
    raise 'Discord not connected!' unless @raw

    @raw.message do |event|
      yield event
    end
  end

  def mention
    raise 'Discord not connected!' unless @raw

    @raw.mention do |event|
      yield event
    end
  end
end
