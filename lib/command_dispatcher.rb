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
      data:     opts,
      callback: proc do |msg, args|
        if args
          yield msg, args
        else
          msg.reply with: 'unclosed string'
        end
      end
    }
  end

  def self.alias(what, into)
    @commands[what] ||= @commands[into]
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

Dir['./lib/commands/*.rb'].each do |file|
  require file
end
