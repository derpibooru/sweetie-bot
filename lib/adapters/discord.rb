require_relative 'abstract.rb'
require 'discordrb'

class DiscordChannel < AbstractChannel
  def initialize(channel)
    @raw = channel
    @id = channel.id
    @name = channel.name

    super case channel.type
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

  def send(*opts)
    @raw.send_message opts[0]
  end

  def nsfw?
    @raw.nsfw? || @raw.type == :private
  end
end

class DiscordUser < AbstractUser
  def initialize(user)
    @adapter_name = :discord

    @raw = user
    @nickname = user.nick
    @username = user.username
  end

  def mention
    @raw.mention
  end
end

class DiscordMessage < AbstractMessage
  def initialize(event)
    @adapter_name = :discord
  
    @raw = event
    @text = event.content
    @sender = DiscordUser.new(event.author)
    @channel = DiscordChannel.new(event.channel)
  end

  def reply(*args)
    opts = args[0].is_a?(String) ? args[1] : args[0]
    msg = args[0].is_a?(String) ? args[0] : opts[:with]

    if opts[:mention] != false
      @raw.respond "#{@sender.mention}, #{msg}"
    else
      @raw.respond msg
    end
  end

  def delete
    @raw.message.delete
  end

  def edit(new_message)
    @raw.message.edit(new_message)
  end

  def from_bot?
    @raw.from_bot? || @raw.message.webhook?
  end
end

class DiscordConnection < AbstractConnection
  def initialize(opts)
    @adapter_name = :discord
    @raw = Discordrb::Bot.new token: opts['token']
  end

  def connect(*opts)
    @raw.run(true)
  end

  def disconnect
    @raw.stop
  end

  def message
    raise 'Discord not connected!' unless @raw

    @raw.message do |event|
      yield DiscordMessage.new(event)
    end
  end
end
