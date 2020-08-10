require 'sinatra'
require 'sinatra/reloader'
require 'dm-core'
require 'dm-migrations'

enable 'sessions'
DataMapper::Logger.new($stdout,:debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/gambling.db")

#create a model class
class Gamble
    include DataMapper::Resource
    property :id, Serial
    property :user_name, String
    property :user_password, String
    property :win, Integer
    property :lost, Integer
end
# DataMapper.auto_migrate!
DataMapper.finalize

get '/login' do
    if session[:user]
        erb :home
    else
        erb :login
    end
end
post '/login' do
    id = Gamble.first(:user_name =>params[:id])
    #@password = Bet.get(params[:id])
    if id!=nil && id.user_password== params[:password]
        session[:win]= 0
        session[:lost]= 0
        session[:password]= params[:password]
        session[:user]= params[:id]
        session[:total_win]= id.win
        session[:total_lost]= id.lost
        session[:id]=id.id
        erb :home
    else
        
        erb :login
    end
    #erb :home
end
    

configure do
    enable :sessions
end



get '/' do
    erb :login
end


post '/bet' do
    stake = params[:stake].to_i
    number = params[:number].to_i
    roll = rand(6) + 1
    if number == roll
      session[:win] += (stake*10)
      erb :home
      
      
    else
        session[:lost] += stake
        erb :home
    end
  end
  

def save_session(won_lost, money)
    profit = (session[won_lost] || 0).to_i
    profit += money
    session[:won_lost] = profit
end

get '/logout' do
    session[:user] = nil
    session[:password] = nil
    session[:message] = "Logged out"
    id = Gamble.get(session[:id])
    session[:total_win]+= session[:win]
    session[:total_lost]+= session[:lost]
    #id.lost+= session[:total_lost]
    id.update(:win=>session[:total_win],:lost=>session[:total_lost])
    erb :login
end



