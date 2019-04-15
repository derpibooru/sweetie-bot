# frozen_string_literal: true

require 'optparse'
require 'yaml'

require 'adapters'
require 'command_dispatcher'

class SweetieBot
  attr_accessor :config

  def load_config(config_file)
    @config = YAML.load_file config_file
  end

  def run
    @config['bots'].each do |bot_data|
      conn = DiscordConnection.new(bot_data)
      conn.message do |msg|
        if @config['prefixes'].include? msg.text[0]
          CommandDispatcher.handle msg
        end
      end
      conn.connect
    end
  end

  def self.main
    bot = SweetieBot.new

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: sweetie-bot [options]"

      opts.on("-c NAME", "--config-file=NAME", "Configuration file") do |c|
        bot.load_config(c)
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    opt_parser.parse!

    if bot.config.nil?
      puts "No configuration file specified! Exiting."
      exit
    else
      puts "Starting..."
      bot.run
    end
  end
end
