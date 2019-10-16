# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: 'bot.db'

Dir['./models/**/*.rb'].each do |f|
  require f
end

require 'database/schema'
