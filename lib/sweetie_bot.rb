# frozen_string_literal: true

require 'optparse'
require 'yaml'

require 'active_support'
require 'adapters'
require 'command_dispatcher'
require 'api'
require 'image'

::Booru = Derpibooru.new

class SweetieBot
  attr_accessor :config, :connections, :should_stop

  def initialize
    @should_stop = false
    @connections = []
  end

  def load_config(config_file)
    @config = YAML.load_file config_file
    Booru.import_config @config['booru']
  end

  def run
    @config['bots'].each do |bot_data|
      conn = DiscordConnection.new(bot_data)
      conn.connection_id = bot_data['id']
      conn.message do |msg|
        if @config['prefixes'].include? msg.text[0]
          CommandDispatcher.handle msg
        else
          NoU.handle(msg) unless ChatImage.handle(msg)
        end
      end
      @connections.push conn
      conn.connect
    end

    SweetieBot.log 'Ready!'

    # keep the main thread alive
    loop do
      if @should_stop
        stop!
        exit
      end
      sleep 0.1
    end
  end

  def stop!
    @connections.each do |connection|
      puts "  -> stopping '#{connection.connection_id}'"
      connection.disconnect
    end

    SweetieBot.log 'Stopped.'
  end

  def self.main
    bot = SweetieBot.new

    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: sweetie-bot [options]'

      opts.on('-c NAME', '--config-file=NAME', 'Configuration file') do |c|
        bot.load_config(c)
      end

      opts.on('-h', '--help', 'Prints this help') do
        puts opts
        exit
      end
    end

    opt_parser.parse!

    if bot.config.nil?
      bot.load_config 'settings.yml'

      exit if bot.config.nil?
    end

    Signal.trap 'INT' do
      puts ''
      SweetieBot.log 'Disconnecting and stopping...'
      bot.should_stop = true
    end

    SweetieBot.log 'Starting...'
    bot.run
  end

  def self.log(msg)
    puts "#{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')} - #{msg}"
  end
end
