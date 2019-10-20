# frozen_string_literal: true

require 'optparse'
require 'yaml'
require 'hashie'

require 'active_support'
require 'discord_adapter'
require 'command_dispatcher'
require 'derpibooru'
require 'image'
require 'database/database'

::Booru = Derpibooru.new

class SweetieBot
  attr_accessor :config, :connections, :should_stop, :instance

  @@instance = nil

  def initialize
    @should_stop = false
    @connections = []
    @handlers = []
  end

  def self.version
    '0.4.4'
  end

  def self.codename
    'Parrot'
  end

  def self.instance
    @@instance
  end

  def self.config
    @@instance.config
  end

  def handler
    @handlers.push proc do |msg|
      yield msg
    end
  end

  def load_config(config_file)
    @config = YAML.load_file config_file
    @config = Hashie::Mash.new(@config) if @config

    Booru.import_config @config.booru
  end

  def run
    # Include all handlers now.
    Dir['./handlers/*.rb'].each do |file|
      require file
    end

    @config.bots.each do |bot_id, bot_data|
      conn = DiscordConnection.new(bot_data)

      conn.connection_id = bot_id

      conn.message do |msg|
        next unless @config.discord.allowed_channel_types.include?(msg.channel.channel_type)

        if @config.prefixes.include? msg.text[0]
          CommandDispatcher.handle msg
        else
          @handlers.each do |handler|
            break if handler.call(msg) == true
          end
        end
      end

      conn.mention do |msg|
        next unless @config.discord.allowed_channel_types.include?(msg.channel.channel_type)
        next if msg.content.match? /^(\.|\!)(a|d|add_|del_|delete_|remove_|count_)?q(uote|s|uotes|uote_count)?\b/
        next unless msg.content.present?
        next if bot_data.client_type == :user

        msg.send_message "#{msg.message.author.mention}, please type `.help` if you would like to learn more about my functions!"
      end

      @connections.push conn
      conn.connect
    end

    SweetieBot.log "Made #{@connections.length} connection#{@connections.length > 1 ? 's' : ''}."
    SweetieBot.log 'Ready!'

    # keep the main thread alive
    loop do
      if @should_stop
        stop!
        exit
      end

      sleep 1
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
    log "Derpibooru Sweetie Bot v#{version} (#{codename})"

    @@instance = SweetieBot.new

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

    if @@instance.config.nil?
      log "No config file specified, using 'settings.yml'"

      @@instance.load_config 'settings.yml'

      exit if @@instance.config.nil?
    end

    Signal.trap 'INT' do
      exit if @@instance.should_stop

      puts ''
      log 'Disconnecting and stopping (press ^C again to force)...'

      @@instance.should_stop = true
    end

    log 'Starting...'
    @@instance.run
  end

  def self.log(msg)
    puts "#{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')} - #{msg}"
  end
end
