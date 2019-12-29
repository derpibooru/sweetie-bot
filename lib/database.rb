# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection YAML.safe_load(File.open('config/database.yml'))

Dir['./models/**/*.rb'].sort.each do |f|
  require f
end
