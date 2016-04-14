# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
load 'schlepp/tasks/schlepp.rake'

WarRoomViewer::Application.load_tasks

namespace :db do
  desc 'Open a MongoDB console with connection parameters for the current Rails.env'
  task :console => :environment do
    conn = Mongoid.master.connection
    opts = ''
    opts << ' --username ' << conn.username if conn.username rescue nil
    opts << ' --password ' << conn.password if conn.password rescue nil
    opts << ' --host ' << conn.host
    opts << ' --port ' << conn.port.to_s
    system "mongo #{opts} #{Mongoid.master.name}"
  end

  desc 'Inverse of db:seed'
  task :unseed => :environment do
    User.where(seed: true).delete_all
    Customer.where(seed: true).delete_all
    Group.where(seed: true).delete_all
  end

  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
  task :migrate  do
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    #Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end
end

task :destructive do
  puts 'This task destroys records! Do you wish to continue? [y/N]'
  input = STDIN.gets.chomp
  raise SecurityError unless input.downcase == 'y'
end