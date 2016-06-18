require 'net/http'
require 'json'

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

#Populate teams
@api_response_games = JSON.parse(get_api_data("games")) # save to season.json

#Populate game_teams and games
file = File.read('season.json')
season = JSON.parse(file)
short = season[400..499]

def update_game(local, api)
  local.update(status: api["Status"],
               datetime: api["DateTime"],
               api_stadium_id: api["StadiumID"])
end

short.each do |api_game|
  api_game_id = api_game["GameID"]
  local_game = Game.find_by(api_game_id: api_game_id)
  # local_team_a = GameTeam.find_by(api_game_id: api_game_id).first
  # local_team_b = GameTeam.find_by(api_game_id: api_game_id).last


  if api_game[:status] == 'Final' && api_game[:status] != local_game.status
    update_game(local_game, game)
    update_game_team(local_game, game)
    resolve_bets()
  end

  GameTeam.create(score: game["AwayTeamRuns"], result: 0, api_game_id: game["GameID"], api_team_id: game["AwayTeamID"])



end


# Must run query twice: once for AwayTeam and once for HomeTeam
short.each { |game| GameTeam.create(score: game["HomeTeamRuns"], result: 0, api_game_id: game["GameID"], api_team_id: game["HomeTeamID"]) }

short.each { |game| GameTeam.create(score: game["AwayTeamRuns"], result: 0, api_game_id: game["GameID"], api_team_id: game["AwayTeamID"]) }

#sample Game population
short.each { |game| Game.create(status: game["Status"], datetime: game["DateTime"], api_game_id: game["GameID"], api_stadium_id: game["StadiumID"]) }

#
#Update team_id in game_teams table
GameTeam.all.each do |gt|
    gt.update(team_id: Team.find_by(api_team_id: gt.api_team_id).id)
end

#Update stadium_id in games table
Game.all.each do |game|
    game.update(stadium_id: Stadium.find_by(api_stadium_id: game.api_stadium_id).id)
end

#Update game_id in GameTeam
GameTeam.all.each do |gt|
    gt.update(game_id: Game.find_by(api_game_id: gt.api_game_id).id)
end
