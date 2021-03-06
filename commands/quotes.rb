# frozen_string_literal: true

CommandDispatcher.register name: 'quotes', help_text: 'displays the amount of quotes related to a user or a channel' do |msg, args|
  subject = args.parsed[0]
  field = Quote.subject_type subject

  if !field && !subject.nil?
    msg.reply 'invalid subject, try a user or a channel.'
    next
  end

  begin
    if field
      _, _, count = Quote.search field: field, value: subject, id: 1
      msg.reply "**#{msg.escape_name(subject)}** has **#{count}** quote#{count != 1 ? 's' : ''} on record.", mention: false
    else
      msg.reply "There are total of **#{Quote.all.count}** quotes on record.", mention: false
    end
  rescue StandardError => ex
    msg.reply ex.message
  end
end

CommandDispatcher.alias 'qs', 'quotes'
CommandDispatcher.alias 'quote_count', 'quotes'
CommandDispatcher.alias 'count_quotes', 'quotes'
