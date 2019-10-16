class NoU
  def self.handle(msg)
    lower = msg.text.downcase

    return unless lower.start_with?('bot')        ||
                  lower.include?('sweetie')       ||
                  lower.include?('this bot')      ||
                  lower.include?('derpi bot')     ||
                  lower.include?('derpibooru bot')

    response = 'no u'
    num = rand(10)

    if num > 7
      response += ' :V'
    elsif num == 1
      response = 'correct'
    end

    msg.reply with: response

    true
  end
end
