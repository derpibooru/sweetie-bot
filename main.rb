require './lib/bot.rb'

config_file = 'settings.yml'

if ARGV[0] == '--help' || ARGV[0] == '-h'
  puts <<~HELPTEXT
    Available options:
      -h, --help      Displays this help message
      -c <filename>   Load specified configuration YAML
  HELPTEXT

  return
end

puts "Starting bot(s) from configuration file (#{config_file})"

bot_obj = Bot.new

bot_obj.load_config config_file
bot_obj.run
