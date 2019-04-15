require './lib/adapters/discord.rb'
require './lib/command_dispatcher.rb'
require 'yaml'

class Bot
  attr_accessor :config

  def load_config(config_file)
    @config = YAML.load_file config_file
  end

  def run
    @config['bots'].each do |bot_data|
      bot = DiscordConnection.new(bot_data)
      bot.message do |msg|
        if @config['prefixes'].include? msg.text[0]
          CommandDispatcher.handle msg
        end
      end
      bot.connect
    end
  end
end
