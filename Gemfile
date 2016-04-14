source 'https://rubygems.org'
gem 'rails', '~>4.1.1'
gem 'sass-rails', '4.0.4' # https://github.com/rails/sass-rails/issues/191
gem 'coffee-rails', '~>4.1.0'
gem 'uglifier', '>=1.3'

gem 'rake', '~> 10.4.2'

# Database
gem 'mongoid', '>= 4.0.0.rc2'
gem 'mongoid_paranoia', github: 'simi/mongoid_paranoia'
gem 'pg', '~> 0.17.1'

gem 'devise', '~> 3.3.0' # https://github.com/codahale/bcrypt-ruby/issues/89
gem 'cancancan', '~> 1.12.0'

# Admin Portal
gem 'activeadmin', github: 'activeadmin/active_admin', :ref => 'ad4caab46f1813bedf5acdb7739a17da546a5609'
gem 'activeadmin-mongoid', github: 'fred/activeadmin-mongoid', branch: 'activeadmin-1.0' # https://github.com/elia/activeadmin-mongoid/issues/79
gem 'axlsx', '~> 1.3.6', :require => false

# Import tools
gem 'paperclip-ffmpeg', '~> 1.2.0'
gem 'fastimage', require: false
gem 'quick_magick', '~> 0.8.0'
gem 'mongoid-paperclip', '~> 0.0.10', :require => "mongoid_paperclip"
gem 'aws-sdk', '~> 1.66.0'
gem 'schlepp', :git => 'git://github.com/lyleunderwood/schlepp.git', :tag => '0.1.2'

group :development, :test do
  gem 'github_api', '~> 0.12.4', :require => false
  gem 'ruby-prof', '~> 0.15.9', :require => false
  gem 'pry-rails', '~> 0.3.4'
  gem 'pry-byebug', '~> 3.0.1'
end

group :development do
  gem 'web-console', '~> 2.0'
end