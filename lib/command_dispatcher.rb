class CommandDispatcher
  attr_accessor :commands

  def self.register(*opts)
    opts = opts[0]

    opts[:name] ||= opts[0]

    raise 'No name specified' unless opts[:name]

    @commands ||= Hash.new

    @commands[opts[:name]] = {
      data: opts,
      callback: Proc.new do |msg|
        yield msg
      end
    }
  end

  def self.handle(msg)
    match = msg.text.match /.([\w_]+)\s*([.]*)/
    command = match[1].downcase
    remainder = match[2]
    real_command = @commands[command]

    # Run the command if exists, ignore otherwise
    if real_command
      real_command[:callback].call(msg)
    end
  end
end

Dir['./lib/commands/*.rb'].each do |file|
  require file
end
