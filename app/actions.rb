helpers do
  def current_user
    session[:user_id] = 1
    @current_user ||= User.find_by(id: session[:user_id])
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
  i = 0
  @home_teams = []
  @away_teams = []
  @game_dates = []
  @game_stadia_names = []
  @game_stadia_cities = []

  for i in 1..100
    @home_teams << GameTeam.where(game_id: i).first.team.name
    #vs
    @away_teams << GameTeam.where(game_id: i).second.team.name

    #Date of game
    @game_dates << GameTeam.where(game_id: i).first.game.datetime
    #Find games on same day
    #Game.where(datetime: "2016-04-11 19:10:00".to_datetime) - probably don't need this

    #Stadium where game is played
    @game_stadia_names << GameTeam.where(game_id: i).first.game.stadium.name
    @game_stadia_cities << GameTeam.where(game_id: i).first.game.stadium.city
  end

  erb :'games/index'
end

# Page: Game details
get '/games/:id' do
  @game = Game.find(params[:id].to_i)
  erb :'games/show'

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
