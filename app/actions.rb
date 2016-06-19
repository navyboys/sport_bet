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
    if Bet.where(user_id: current_user.id).count == 0
       return current_user.points
    end
    profit = Bet.where(user_id: current_user.id).sum("profit_points")
    wager = Bet.where(user_id: current_user.id).sum("points")
    current_user.points.to_i + profit - wager
  end

  def bet_count
    current_user.bets.count
  end

  def bet_won
    Bet.joins(:game_team).where("user_id = ? AND game_teams.result = ?", current_user.id, 1).count
  end

  def bet_loss
    Bet.joins(:game_team).where("user_id = ? AND game_teams.result = ?", current_user.id, -1).count
  end

  def bet_tie
    Bet.joins(:game_team).where("user_id = ? AND game_teams.result = ?", current_user.id, 0).count
  end

  def bet_in_progress
    Bet.joins(:game_team).where("user_id = ? AND game_teams.result = ?", current_user.id, nil).count
  end

  def bet_completed
    bet_count - bet_in_progress
  end

  def points_in_progress
    Bet.joins(:game_team).where("user_id = ? AND game_teams.result = ?", current_user.id, nil).sum("points")
  end

  def points_invested_won
    Bet.joins(:game_team).where("user_id = ? AND game_teams.result = ?", current_user.id, 1).sum("points")
  end

  def points_gain_won
    Bet.joins(:game_team).where("user_id = ? AND game_teams.result = ?", current_user.id, 1).sum("points")
  end

  def points_profit_won
    points_invested_won - points_gain_won
  end

  def points_loss
    Bet.joins(:game_team).where("user_id = ? AND game_teams.result = ?", current_user.id, -1).sum("points")
  end

  def points_tie
    Bet.joins(:game_team).where("user_id = ? AND game_teams.result = ?", current_user.id, 0).sum("points")
  end

  def points_total_placed
    points_invested_won + points_loss + points_tie
  end

  def points_total_gained
    points_gain_won + points_tie
  end

  def point_total_profit
      points_profit_won - points_loss
  end

  def can_bet?(game)
    game.in_progress? && !game.users.include?(current_user)
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

# Charge with credit card
post '/charge' do
  Stripe.api_key = 'sk_test_yENZrfNUuVXFshfe9yOkatfu'
  StripeWrapper::Charge.create(
    card:        params[:stripeToken],
    amount:      2000,
    description: "BBettr user: #{current_user.email}"
  )
  current_user.points += 2000
  current_user.save!
  flash[:notice] = "You charged 2000 points into your account."
  redirect back
end

# Page: Show list of all games available for betting
get '/games' do
  i = 0
  @game_to_bet_on = []
  @games_array = []
  for i in Game.first.id..Game.last.id
    current_gt = GameTeam.where(game_id: i)
    @game_to_bet_on << { home_team: current_gt.first.team.name, home_team_score: current_gt.first.score, away_team: current_gt.second.team.name, away_team_score: current_gt.second.score, game_date: current_gt.first.game.datetime, game_stadium_name: current_gt.first.game.stadium.name, game_stadium_city: current_gt.first.game.stadium.city
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
  bet_points = params[:bet_points].to_i

  if bet_points > current_user.points
    flash[:error] = "Sorry, you don't have enough points."
    redirect back
  end

  new_bet = Bet.new(points: bet_points,
                    user: current_user,
                    game_team_id: params[:game_team_id].to_i)

  current_user.points -= bet_points

  if new_bet.save && current_user.save
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
  current_user.points += bet.points

  if bet.destroy && current_user.save
    flash[:notice] = 'Your canceled a bet successfully.'
  else
    flash[:error] = 'Your bet cannot be deleted.'
  end

  redirect :'bets'
end

# Page: Leader board
get '/leaderboard' do
  @top_users = User.all.sort_by { |user| user.points }.reverse.take(10)
  erb :'users/leaderboard'
end

# Page: Custom Board
get '/customboard' do
  erb :'users/customboard'
end

get '/admin' do
  erb :'admin/index'

end

get '/admin/game_update' do
  erb :'admin/game_update'
  redirect '/admin'
end
# Page: update db with new seed data
get '/admin/seed' do
  #Get API data
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
  #Get stadium data
  @api_response_stadia = JSON.parse(get_api_data("Stadiums"))
  #Populate stadia table
  @api_response_stadia.each do |stadium|
    Stadium.create(api_stadium_id: stadium["StadiumID"], name: stadium["Name"], city: stadium["City"])
  end
  #Get team data
  @api_response_teams = JSON.parse(get_api_data("teams"))
  #Populate teams table
  @api_response_teams.each do |team|
    Team.create(api_team_id: team["TeamID"], name: team["Name"])
  end
  #Get game data
  @api_response_games_by_date_day_one = JSON.parse(get_api_data("GamesByDate","2016-JUN-19"))
  @api_response_games_by_date_day_two = JSON.parse(get_api_data("GamesByDate","2016-JUN-20"))
  file_var = File.open("sunday_games.json","w")
  file_var.write(@api_response_games_by_date_day_one)
  #Populate games table
  @api_response_games_by_date_day_one.each { |game| Game.create(status: game["Status"], datetime: game["DateTime"], api_game_id: game["GameID"], api_stadium_id: game["StadiumID"]) }
  @api_response_games_by_date_day_two.each { |game| Game.create(status: game["Status"], datetime: game["DateTime"], api_game_id: game["GameID"], api_stadium_id: game["StadiumID"]) }
  #Populate game_teams table
  #Day one
  @api_response_games_by_date_day_one.each { |game| GameTeam.create(score: game["AwayTeamRuns"], result: nil, api_game_id: game["GameID"], api_team_id: game["AwayTeamID"]) }
  #
  @api_response_games_by_date_day_one.each { |game| GameTeam.create(score: game["HomeTeamRuns"], result: nil, api_game_id: game["GameID"], api_team_id: game["HomeTeamID"]) }
  #Day two
  @api_response_games_by_date_day_two.each { |game| GameTeam.create(score: game["AwayTeamRuns"], result: nil, api_game_id: game["GameID"], api_team_id: game["AwayTeamID"]) }
  #
  @api_response_games_by_date_day_two.each { |game| GameTeam.create(score: game["HomeTeamRuns"], result: nil, api_game_id: game["GameID"], api_team_id: game["HomeTeamID"]) }

  #Update all local id fields
  # #Update team_id in game_teams table
  GameTeam.all.each { |gt| gt.update(team_id: Team.find_by(api_team_id:gt.api_team_id).id) }
  #
  #Update stadium_id in games table
  Game.all.each { |game| game.update(stadium_id: Stadium.find_by(api_stadium_id: game.api_stadium_id).id) }
  #
  # #Update game_id in GameTeam
  GameTeam.all.each { |gt| gt.update(game_id: Game.find_by(api_game_id: gt.api_game_id).id) }

  erb :'/admin/seed_db'

end
