# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'bundler'
Bundler.setup

require 'active_record'

namespace :db do
  db_config = YAML.safe_load(File.open('config/database.yml'))

  desc 'Create the database'
  task :create do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.create_database(db_config['database']) if db_config['adapter'] != 'sqlite3'
    puts 'Database created.'
  end

  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.migration_context.migrate
    Rake::Task['db:schema'].invoke
    puts 'Database migrated.'
  end

  desc 'Drop the database'
  task :drop do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.drop_database(db_config['database'])
    puts 'Database deleted.'
  end

  desc 'Reset the database'
  task reset: [:drop, :create, :migrate]

  desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
  task :schema do
    ActiveRecord::Base.establish_connection(db_config)
    require 'active_record/schema_dumper'
    filename = 'db/schema.rb'
    File.open(filename, 'w:utf-8') do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end
end

namespace :g do
  desc 'Generate migration'
  task :migration do
    name = ARGV[1] || raise('Specify name: rake g:migration your_migration')
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split('_').map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<~MIGRATION
        class #{migration_class} < ActiveRecord::Migration
          def self.up
          end
          def self.down
          end
        end
      MIGRATION
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end
