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
require 'dm-postgres-adapter'
# require 'carrierwave' # for file uploading
# require 'rmagick'
# require 'rdiscount'

# # # # # # # # # # # # # # # # # # # # # # # # # # # #
# helpers

helpers do  
    include Rack::Utils  
    alias_method :escape, :escape_html  
end

# # # # # # # # # # # # # # # # # # # # # # # # # # # #
# some helpful vars

@@boards = ["art", "design", "fashion", "humour", "math", "music", "photography", "technology", "writing", "variety"]


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
	property :body,		Text, :required => true	# body of post
	property :board,	String	# board catagory
	property :parent,	Boolean # is the post a parent or not
	property :thread,	Integer # what thread does the post belong to? (parent post id = thread number)
	property :created_at, DateTime # when was this post created?
	property :created_on, Date
end

DataMapper.finalize.auto_upgrade!

# # # # # # # # # # # # # # # # # # # # # # # # # # # #
# routes

# homepage
get '/' do
	@posts = Post.all(:parent => true, :order => :id.desc) # only list parent posts
	erb :index
end

# sort the posts by board
get '/:board' do
	if @@boards.include? params[:board] # this is to check if the board exsists.
		@board_name = params[:board]
		@board_posts = Post.all(:parent => true, :order => :id.desc, :board => params[:board])
		erb :board
	else
		not_found
	end
end

# handle new board posts
post '/:board' do
	if @@boards.include? params[:board]
		p = Post.new
		p.body = params[:body]
		p.board = params[:board]
		p.parent = true
		p.created_at = Time.now
		p.save
		p.thread = p.id
		p.save
		redirect '/' + params[:board]
	else
		not_found
	end
end

# individual threads
get '/:board/thread/:id' do
	if Post.count(:thread => params[:id]) > 0
		@board_name = params[:board]
		@dem_posts = Post.all(:thread => params[:id])
		@dat_id = params[:id]
		erb :thread
	else
		not_found
	end
end

post '/:board/reply/:id' do
	if Post.count(:thread => params[:id]) > 0
		p = Post.new
		p.body = params[:body]
		p.board = params[:board]
		p.parent = false
		p.thread = params[:id]
		p.created_at = Time.now
		p.save
		redirect params[:board] + '/thread/' + params[:id]
	else
		not_found
	end
end

not_found do
  "this is not the page you are looking for."
end