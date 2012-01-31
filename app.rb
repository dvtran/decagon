# Decagon
# "but you're probably never heard of it"
# Dan Tran (@_dvtran)
# http://dvtran.com
# Initiated 27 January 2012
# # # # # # # # # # # # # # # # # # # # # # # # # # # #


# # # # # # # # # # # # # # # # # # # # # # # # # # # #
# gems needed for the successful operation of this app

require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-sqlite-adapter'
# require 'dm-postgres-adapter'

# # # # # # # # # # # # # # # # # # # # # # # # # # # #
# setting up the database

# DataMapper.setup(:default, 'postgres://localhost/database.db') # establish postgres connection

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/database.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://#{Dir.pwd}/database.db")
end

class Post
	include DataMapper::Resource

	property :id,		Serial
	property :body,		Text, 		:required => true
	# property :cat,		String	# board catagory
	property :birth,	DateTime
end
DataMapper.finalize.auto_upgrade!

# # # # # # # # # # # # # # # # # # # # # # # # # # # #
# routes

get '/' do
	@posts = Post.all :order => :id.desc
	erb :index
end

post '/' do
	p = Post.new
	p.body = params[:body]
	# p.cat = params[:board] #  let's get this done later
	p.birth = Time.now
	p.save
	redirect '/'
end