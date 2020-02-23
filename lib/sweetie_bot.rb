# frozen_string_literal: true

require 'optparse'
require 'yaml'
require 'hashie'

require 'active_support'
require 'discord/adapter'
require 'discord/embed'
require 'command_dispatcher'
require 'derpibooru'
require 'image'
require 'database'

# API object for easy access and configuration.
::Booru = Derpibooru.new

# The main class responsible for the bot.
# @author Luna aka Meow the Cat
# @note Can hold multiple bot instances.
# @note It's not advised or supported to instantiate this class more than once.
# @attr [Hash] config The loaded configuration of the current bot instance.
# @attr [Array<DiscordConnection>] connections The established bot connections.
# @attr [Boolean] should_stop Whether the bot should be gracefully killed or not.
# @attr [SweetieBot] instance The currently running instance of the bot wrapper.
class SweetieBot
  attr_accessor :config, :connections, :should_stop, :instance

  # The current running instance of SweetieBot class.
  @@instance = nil

  def initialize
    @should_stop = false
    @connections = []
    @handlers = []
    @rate_limits = {}
  end

  # Current version of the bot
  # @return [String] version string in X.X.X-suffix format.
  def self.version
    '0.8.2'
  end

  # Current version's codename.
  # @return [String] codename of the current major (x.X.x) release.
  def self.codename
    'No U'
  end

  # Getter for the current running instance of SweetieBot.
  # @return [SweetieBot] current instance.
  def self.instance
    @@instance
  end

  # Getter for the current instance's configuration (settings.yml).
  # @return [Hash] configuration values as defined in the YAML file.
  def self.config
    @@instance.config
  end

  # Adds a custom message handler, which isn't necessarily a command.
  # @yield [msg] callback to be called when a message is sent.
  # @yieldparam [Discordrb::Events::MessageEvent] msg message event.
  def handler
    @handlers.push(proc do |msg|
      yield msg
    end)
  end

  # Execute a command with a rate limiter.
  # @param id [String] The unique ID of the rate limiter.
  # @param seconds [Number] The number of seconds that are required to be held between two executions of the code.
  # @yield nil
  def rate_limit(id, seconds = 1)
    now_time = Time.now
    last_exec = @rate_limits[id] || (now_time - seconds.seconds - 1.second)

    if now_time > last_exec + seconds.seconds
      yield_result = yield
      @rate_limits[id] = now_time
    end

    yield_result
  end

  # Loads a configuration from a YAML file.
  # @param config_file [String] path to the YAML file on the filesystem.
  def load_config(config_file)
    @config = YAML.load_file config_file
    @config = Hashie::Mash.new(@config) if @config

    Booru.import_config @config.booru
  end

  # Runs the bot using the current configuration.
  # @note Config MUST be loaded beforehand!
  def run
    # Include all handlers now.
    Dir['./handlers/*.rb'].sort.each do |file|
      require file
    end

    @config.bots.each do |bot_id, bot_data|
      conn = DiscordConnection.new(bot_data)

      conn.connection_id = bot_id

      conn.message do |msg|
        next unless @config.discord.allowed_channel_types.include?(msg.channel.channel_type)

        if (prefix = check_prefix(msg.text))
          CommandDispatcher.handle prefix, msg
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

  # Gracefully stops and disconnects all the bot instances.
  # @note Must be connected before disconnecting.
  def stop!
    @connections.each do |connection|
      puts "  -> stopping '#{connection.connection_id}'"
      connection.disconnect
    end

    SweetieBot.log 'Stopped.'
  end

  # Loads configuration and starts the bot.
  # Reads commandline params to determine config paths.
  #   # Options:
  #   # -c --config-file NAME
  #   # -h --help
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
      log "No config file specified, using 'config/settings.yml'"

      @@instance.load_config 'config/settings.yml'

      exit 1 if @@instance.config.nil?
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

  # Creates a stdout log entry with current time and date.
  # @param msg [String] message to output.
  def self.log(msg)
    puts "#{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')} - #{msg}"
  end

  private

  def check_prefix(text)
    winning_prefix = nil

    lower_text = text.downcase

    @config.prefixes.each do |prefix|
      if lower_text.start_with? prefix.downcase
        winning_prefix = prefix if !winning_prefix || prefix.length > winning_prefix.length
      end
    end

    winning_prefix
  end
end
