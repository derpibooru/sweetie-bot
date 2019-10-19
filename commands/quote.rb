# frozen_string_literal: true

CommandDispatcher.register name: 'quote', help_text: 'displays a quote from a user or channel' do |msg, args|
  subject = args.parsed[0]
  field = Quote.subject_type(subject) || (subject.nil? ? :id : false)
  quote_id = args.parsed[1] ? args.parsed[1].to_i : false

  if !field
    msg.reply <<~HELPTEXT
      cannot quote this, try a user or a channel!
      If you meant to add or remove a quote, try the following commands:
      **.add_quote** _<user or channel> <quote text...>_
      **.del_quote** _<user or channel> <index>_
      **.quotes** _<user or channel>_
    HELPTEXT
    next
  end

  begin
    quote, qid, count = nil

    if field != :id
      quote, qid, count = Quote.search field: field, value: subject, id: quote_id
    else
      quote_count = Quote.all.count
      quote_id = if subject.nil?
        rand(1..quote_count)
      else
        subject.to_i
      end

      raise 'ID out of range.' if quote_id <= 0 || quote_id > quote_count

      quote = Quote.all.offset(quote_id - 1).order(created_at: :asc).first
      qid = quote_id
      count = quote_count
    end

    msg.reply "(#{qid} / #{count}) #{quote.user}: #{quote.body}", mention: false
  rescue StandardError => ex
    msg.reply ex.message
  end
end

CommandDispatcher.alias 'q', 'quote'
