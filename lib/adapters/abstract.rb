class AbstractAdaptable
  attr_accessor :adapter_name
  attr_accessor :raw

  def is?(what)
    @adapter_name == what
  end
end

class AbstractConnection < AbstractAdaptable
  def connect(*opts)
  end

  def disconnect
  end

  def on_message(message_data)
  end
end

class AbstractMessage < AbstractAdaptable
  attr_accessor :text
  attr_accessor :sender
  attr_accessor :channel

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
  attr_accessor :nickname
  attr_accessor :username

  def mention
  end
end

class AbstractChannel < AbstractAdaptable
  attr_accessor :id
  attr_accessor :name
  attr_accessor :channel_type

  def initialize(chan_type)
    @channel_type = chan_type
  end

  def send(*opts)
  end

  def nsfw?
    true
  end
end
