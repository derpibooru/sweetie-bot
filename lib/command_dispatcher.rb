# frozen_string_literal: true

require 'arguments'

class CommandDispatcher
  attr_accessor :commands

  def self.register(*opts)
    opts = opts[0]

    opts[:name] ||= opts[0]

    raise 'No command name specified' unless opts[:name]

    @commands ||= {}

    @commands[opts[:name]] = {
      data:      opts,
      callback:  proc do |msg, args|
        if args
          yield msg, args
        else
          msg.reply with: 'unclosed string'
        end
      end,
      name:      opts[:name],
      help_text: opts[:help_text],
      aliases:   []
    }
  end

  def self.help
    @commands.flat_map do |_, data|
      if data[:help_text] && data[:alias].nil?
        data
      else
        []
      end
    end
  end

  def self.alias(what, into)
    target_cmd = @commands[into]

    if target_cmd
      @commands[what] ||= {
        name:      target_cmd[:name],
        help_text: target_cmd[:help_text],
        data:      target_cmd[:data],
        callback:  target_cmd[:callback],
        alias:     true
      }

      @commands[into][:aliases].push what
    end
  end

  def self.parse_arguments(str)
    Arguments.new.parse(str)
  end

  def self.handle(msg)
    match = msg.text.match /.([\w_]+)\s*(.*)/
    command = match[1].downcase
    remainder = match[2]
    real_command = @commands[command]

    # Run the command if exists, ignore otherwise
    if real_command
      SweetieBot.log "#{command} (#{remainder}) from #{msg.sender.username}"
      real_command[:callback].call(msg, parse_arguments(remainder))
    end
  end
end

Dir['./commands/*.rb'].each do |file|
  require file
end
