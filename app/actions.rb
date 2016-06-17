helpers do
  def current_user
    session[:user_id] = 1
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def format_datetime(datetime)
    datetime.strftime("%F %I:%M%p")
  end

  def show_game(game)
    "#{game.teams.first.name} vs #{game.teams.last.name}"
  end

  def show_game_result(game)
    if ['Final', 'InProgess'].include?(game.status)
      "#{game.teams.first.name} vs " +
      "#{game.teams.last.name}"
    end
  end
end

get '/' do
    redirect '/users/login'
end

get '/users/login' do
  erb :'users/login'
end

post '/users/login' do
  user = User.find_by(username: params[:username])
  if user.password_hash == params[:password_hash]
    session[:user_id] = user.id
    redirect '/bets'
  else
    #TODO flash a message
    redirect "/users/login"
  end
end

#logout
get "/users/logout" do
  session.clear
  redirect "/users/login"
end
#user profile

get '/users/' do
  erb :'users/index'
end

# Page: Bet on a game
get '/games' do
  erb :'games/index'
end

# Page: Game details
get '/games/:id' do
  begin
    @game = Game.find(params[:id].to_i)
    erb :'games/show'
  rescue ActiveRecord::RecordNotFound => @e    
    erb :'page_not_found' 
  end
end

# Create a bet for a game
post 'games/:id/bets' do
  redirect :'games' # When saved successfully
end

# Page: My bets
get '/bets' do
  @completed_bets = []
  @upcoming_bets = []

  my_bets = Bet.all.where(user: current_user, archived: false)
  my_bets.each do |bet|
    @completed_bets << bet if bet.game.completed?
    @upcoming_bets << bet
  end

  erb :'bets/index'
end

# Archive a bet
patch '/bets/:id' do
  bet = Bet.find_by(params[:bet_id])
  bet.archived = true
  bet.save
  redirect :'bets'
end

# Page: Leader board
get '/leaderboard' do
  erb :'users/leaderboard'
end

# Page: Custom Board

get '/customboard' do
  erb :'users/customboard'
end

# ---------------------------------------------
# To be removed - temporary API helper to seed tables
require 'net/http'
# require 'pry-byebug'
require 'json'

def get_api_data(required_data, required_date = nil)
  if required_date
    uri = URI("https://api.fantasydata.net/mlb/v2/JSON/#{required_data}/#{required_date}")
    uri.query = URI.encode_www_form({
      })
  else
    uri = URI("https://api.fantasydata.net/mlb/v2/JSON/#{required_data}")
    uri.query = URI.encode_www_form({
      })
  end
  request = Net::HTTP::Get.new(uri.request_uri)
  # Request headers
  request['Ocp-Apim-Subscription-Key'] = '8c4c7e5288df4abf8b8830ca64d548a3'
  # Request body
  request.body = "{body}"

  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
  end
  return response.body
end
#Call API methods
@api_response_games_by_date = JSON.parse(get_api_data("GamesByDate","2016-JUN-15"))
@api_response_teams = JSON.parse(get_api_data("teams"))
@api_response_stadia = JSON.parse(get_api_data("Stadiums"))
