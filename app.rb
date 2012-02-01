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
# helpers

helpers do  
    include Rack::Utils  
    alias_method :escape, :escape_html  
end

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

	property :id,		Serial	# post number, auto incremented
	property :body,		Text, 		:required => true	# body of post
#	property :cat,		String	# board catagory
	property :parent,	Boolean # is the post a parent or not
	property :thread,	Integer # what thread does the post belong to? (parent post id = thread number)
	property :birth,	DateTime # when was the post created?
end

DataMapper.finalize.auto_upgrade!

# # # # # # # # # # # # # # # # # # # # # # # # # # # #
# routes

get '/' do
	@posts = Post.all(:parent => true, :order => :id.desc) # only list parent posts
	erb :index
end

post '/' do
	p = Post.new
	p.body = params[:body]
	# p.cat = params[:board] #  let's get this done later
	p.parent = true
	p.birth = Time.now
	p.save
	p.thread = p.id
	p.save
	redirect '/'
end

get '/thread/:id' do
	if Post.count(:thread => params[:id]) > 0
		@dem_posts = Post.all(:thread => params[:id])
		@dat_id = params[:id]
		erb :post
	else
		redirect 'not_found'
	end
end

post '/reply/:id' do
	if Post.count(:thread => params[:id]) > 0
		p = Post.new
		p.body = params[:body]
		p.parent = false
		p.thread = params[:id]
		p.birth = Time.now
		p.save
		redirect '/thread/' + params[:id]
	else
		redirect 'not_found'
	end
end

not_found do
  "these are not the pages you're looking for."
end