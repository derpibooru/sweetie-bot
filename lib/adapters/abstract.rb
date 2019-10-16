class AbstractAdaptable
  attr_accessor :adapter_name, :raw

  def is?(what)
    @adapter_name == what
  end

  def discord?
    @adapter_name == :discord
  end

  def irc?
    @adapter_name == :irc
  end
end

class AbstractConnection < AbstractAdaptable
  attr_accessor :connection_id

  def connect(*opts)
  end

  def disconnect
  end

  def on_message(message_data)
  end
end

class AbstractMessage < AbstractAdaptable
  attr_accessor :text, :sender, :channel

  def reply(*opts)
  end

  def delete
  end

  def edit(new_message)
  end

  def from_bot?
  end
end

class AbstractUser < AbstractAdaptable
  attr_accessor :nickname, :username

  def mention
  end
end

class AbstractChannel < AbstractAdaptable
  attr_accessor :id, :name, :channel_type

  def initialize(chan_type)
    @channel_type = chan_type
  end

  def send(*opts)
  end

  def nsfw?
    true
  end
end
