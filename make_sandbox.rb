require 'optparse'
require 'erb'
require 'fileutils'

def shell(cmd)
  puts cmd
  `#{cmd}`
end

opt = OptionParser.new

arproxy_path = '../../arproxy'
rails_version = nil
app_name = 'sandbox'
adapter = 'mysql2'

opt.on('--rails-version VERSION') {|v| rails_version = v }
opt.on('--app-name APP_NAME') {|v| app_name = v }
opt.on('--arproxy-path PATH') {|v| arproxy_path = v }
opt.on('--adapter NAME') {|v| adapter = v }
opt.parse!

unless Dir.exist?(app_name)
  shell %Q!rails new #{app_name} --skip-action-mailer --skip-active-storage --skip-action-cable --skip-puma --skip-spring --skip-listen --skip-coffee --skip-javascript --skip-turbolinks --skip-test --skip-system-test --skip-bootsnap!
end

dbyml_path = "#{app_name}/config/database.yml"
puts "Updating #{dbyml_path}"
dbyml_content = File.open("resources/database-#{adapter}.yml") {|f| f.read }
open(dbyml_path, "w") do |f|
  f.write ERB.new(dbyml_content).result(binding)
end

gemfile_path = "#{app_name}/Gemfile"
open(gemfile_path, "a+") do |f|
  content = f.read
  if content !~ /arproxy/m
    puts "Updating #{gemfile_path}"
    f.write <<-END
#{content}
#{adapter == 'mysql2' ? "gem 'mysql2'" : ""}
gem 'arproxy', path: '#{arproxy_path}'
    END
  end
end

initializer_path = "#{app_name}/config/initializers/init_arproxy.rb"
puts "Updating #{initializer_path}"
initializer_content = File.open("resources/init_arproxy.rb") {|f| f.read }
open(initializer_path, "w") do |f|
  f.write ERB.new(initializer_content).result(binding)
end

shell %Q!cd #{app_name}; bundle exec rails generate model book title:string price:integer --skip!
shell %Q!cd #{app_name}; bundle exec rake db:setup db:migrate!

seed_path = "#{app_name}/db/seed.rb"
unless File.exist?(seed_path)
  puts "Updating #{seed_path}"
  FileUtils.cp 'resources/seed.rb', seed_path
  shell %Q!cd #{app_name}; bundle exec rake db:seed!
end

