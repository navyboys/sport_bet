helpers do
  def current_user
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
      "#{game.game_teams.first.score} : #{game.game_teams.last.score}"
    end
  end

  def show_bet_result(bet)
    bet.profit_points ||= 0
    result = (bet.profit_points - bet.points).to_s

    case bet.game_team.result
    when 1
      'Won ' + result + ' points'
    when -1
      'Lost ' + result + ' points'
    when 0
      "Tie: #{bet.points} returned back to your account."
    end
  end

  def get_points
    profit = Bet.where(user_id = current_user.id).sum("profit_points")
    # wager = Bet.where(user_id = current_user.id).sum("points")
    # current_user.points.to_i + profit - wager
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
    redirect '/users/login'
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

# Page: Show list of all games available for betting
get '/games' do
  # binding.pry
  i = 0
  @game_to_bet_on = []
  @games_array = []
  for i in 1..100
    @game_to_bet_on << { home_team: GameTeam.where(game_id: i).first.team.name, away_team: GameTeam.where(game_id: i).second.team.name, game_date: GameTeam.where(game_id: i).first.game.datetime, game_stadium_name: GameTeam.where(game_id: i).first.game.stadium.name, game_stadium_city: GameTeam.where(game_id: i).first.game.stadium.city
    }
    @games_array << Game.where(id: i).first
  end

  erb :'games/index'
end

# Page: Game details
get '/games/:id' do
  # binding.pry
  begin
    @game = Game.find(params[:id].to_i)
    @winning_team_name = @game.winner.team.name.upcase unless @game.tied?
    @city_name = @game.stadium.city.upcase
    erb :'games/show'
  rescue ActiveRecord::RecordNotFound => @e
    erb :'page_not_found'
  end
end
# Create a bet for a game
post '/games/:id/bets' do
  if params[:bet_points].to_i > current_user.points
    flash[:error] = "Sorry, you don't have enough points."
    redirect back
  end

  new_bet = Bet.new(points: params[:bet_points],
                    user: current_user,
                    game_team_id: params[:game_team_id])
  if new_bet.save
    current_user.points -= params[:bet_points].to_i
    current_user.save
    flash[:notice] = 'You bet successfully.'
  else
    flash[:error] = 'Error happens when you bet.'
  end
  redirect back
end

# Page: My bets
get '/bets' do
  @completed_bets = []
  @upcoming_bets = []

  my_bets = Bet.all.where(user: current_user, archived: [false, nil])
  my_bets.each do |bet|
    if bet && bet.game && bet.game.completed?
      @completed_bets << bet
    else
      @upcoming_bets << bet
    end
  end

  erb :'bets/index'
end

# Archive a bet
patch '/bets/:id' do
  bet = Bet.find(params[:id])
  bet.archived = true
  bet.save
  redirect :'bets'
end

# Delete a bet
delete '/bets/:id' do
  bet = Bet.find(params[:id])
  bet.user.points += bet.points
  if bet.destroy
    bet.user.save
    redirect :'bets'
  else
    flash[:error] = 'Your bet cannot be deleted.'
  end
end

# Page: Leader board
get '/leaderboard' do
  erb :'users/leaderboard'
end

# Page: Custom Board

get '/customboard' do
  erb :'users/customboard'
end
