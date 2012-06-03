source :rubygems

gem 'sinatra', '1.3.2'
gem 'thin', '1.3.1'

gem 'rqrcode', '0.4.2'
gem 'chunky_png', '1.2.5'
gem 'barby', git: 'git://github.com/3kwa/barby.git'
gem 'datamapper', '1.2.0'
gem 'rmagick', '2.13.1', require: 'RMagick'

group :production do
    gem 'pg'
    gem 'dm-postgres-adapter'
end

group :development, :test do
    gem 'sqlite3'
    gem 'dm-sqlite-adapter'
end