# frozen_string_literal: true

require 'arguments'

# Handles the commands that are entered in chat, as well as registering of the new commands.
# @author Luna aka Meow the Cat
# @attr [Hash] commands All available commands and aliases.
class CommandDispatcher
  attr_accessor :commands

  # Registers a new command.
  # @param opts [Hash] command options.
  # @option opts [String] :name the name of the command.
  # @option opts [String] :help_text the text to display in the `help` command.
  #   If left blank, will not show up in the help command.
  # @yield [msg, args] The command callback.
  # @yieldparam [Discordrb::Events::MessageEvent] msg The message that triggered the command.
  # @yieldparam [Arguments] args The arguments by the user.
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

  # Generates the array of commands for use by the help command.
  # @note Only includes actual commands, won't include aliases.
  # @return [Array<Hash>] the array of commands.
  def self.help
    @commands.flat_map do |_, data|
      if data[:help_text] && data[:alias].nil?
        data
      else
        []
      end
    end
  end

  # Creates an alias for a given command.
  # @param what [String] the alias name.
  # @param into [String] the command to run when the alias is triggered.
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

  # Parses the arguments string.
  # @param str [String] the arguments string.
  # @return [Arguments] parsed arguments.
  def self.parse_arguments(str)
    Arguments.new.parse(str)
  end

  # Handles the message as a command. Expects the message to be a command.
  # Separates the command from the arguments and parses the arguments before
  # calling the command callback.
  # @param msg [Discordrb::Events::MessageEvent] the message event.
  def self.handle(msg)
    match = msg.text.match /.([\w_]+)\s*(.*)/

    return unless match

    command = match[1].downcase
    remainder = match[2]
    real_command = @commands[command]

    # Run the command if exists, ignore otherwise
    if real_command
      SweetieBot.log "#{command} #{!remainder.empty? ? ('(' + remainder + ') ') : ''}from #{msg.sender.username}"
      real_command[:callback].call(msg, parse_arguments(remainder))
    end
  end
end

Dir['./commands/*.rb'].each do |file|
  require file
end
