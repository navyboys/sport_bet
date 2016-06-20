require 'net/http'
require 'json'

#AddInitialUsers
user_names = ["Richard", "Natalia", "Ben", "Max", "Matt", "Eamonn", "Vanessa", "Deepak", "Alexandra", "Juliana", "Terrence"]
bet_points = [1500, 1500, 1500, 1750, 200, 300, 1, 500, 600, 0, 2000]

email = "@sports_bet.com"
i = 0
user_names.each do |name|
  User.create!(username: name, password_hash: 'password', email: name + email, points: bet_points[i])
  i += 1
end
#Following.create!(follower:1, followee: 2)

# #Get API data
# def get_api_data(required_data, required_date = nil)
#   if required_date
#     uri = URI("https://api.fantasydata.net/mlb/v2/JSON/#{required_data}/#{required_date}")
#     uri.query = URI.encode_www_form({
#       })
#   else
#     uri = URI("https://api.fantasydata.net/mlb/v2/JSON/#{required_data}")
#     uri.query = URI.encode_www_form({
#       })
#   end
#   request = Net::HTTP::Get.new(uri.request_uri)
#   # Request headers
#   request['Ocp-Apim-Subscription-Key'] = 'Your API key here'
#   # Request body
#   request.body = "{body}"
#
#   response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
#       http.request(request)
#   end
#   return response.body
# end
#
# #Call API methods
# #Populate stadia
# @api_response_stadia = JSON.parse(get_api_data("Stadiums"))
# @api_response_stadia.each do |stadium|
#   Stadium.create(api_stadium_id: stadium["StadiumID"], name: stadium["Name"], city: stadium["City"])
# end
# #
# # #Populate teams
# @api_response_teams = JSON.parse(get_api_data("teams"))
# @api_response_teams.each do |team|
#   Team.create(api_team_id: team["TeamID"], name: team["Name"])
# end
# #
# # #Populate game_teams and games
# # #Populate games - will need this to get up to date game results
# @api_response_games_by_date = JSON.parse(get_api_data("GamesByDate","2016-JUN-18"))
# #
# @api_response_games_by_date.each { |game| Game.create(status: game["Status"], datetime: game["DateTime"], api_game_id: game["GameID"], api_stadium_id: game["StadiumID"]) }
# #
# @api_response_games_by_date.each { |game| GameTeam.create(score: game["AwayTeamRuns"], result: nil, api_game_id: game["GameID"], api_team_id: game["AwayTeamID"]) }
# #
# @api_response_games_by_date.each { |game| GameTeam.create(score: game["HomeTeamRuns"], result: nil, api_game_id: game["GameID"], api_team_id: game["HomeTeamID"]) }
# #
# # #Update team_id in game_teams table
# GameTeam.all.each { |gt| gt.update(team_id: Team.find_by(api_team_id:gt.api_team_id).id) }
# #
# #Update stadium_id in games table
# Game.all.each { |game| game.update(stadium_id: Stadium.find_by(api_stadium_id: game.api_stadium_id).id) }
# #
# # #Update game_id in GameTeam
# GameTeam.all.each { |gt| gt.update(game_id: Game.find_by(api_game_id: gt.api_game_id).id) }
# #

# file = File.read('season.json')
#sample GameTeam population short is an array of hashes
#populated as follows:
# file = File.read('season.json')
# season = JSON.parse(file)
# short = season[0..99]
# Must run query twice: once for AwayTeam and once for HomeTeam
# short.each { |game| GameTeam.create(score: game["HomeTeamRuns"], result: 0, api_game_id: game["GameID"], api_team_id: game["HomeTeamID"]) }
#
# short.each { |game| GameTeam.create(score: game["AwayTeamRuns"], result: 0, api_game_id: game["GameID"], api_team_id: game["AwayTeamID"]) }

#sample Game population
# short.each { |game| Game.create(status: game["Status"], datetime: game["DateTime"], api_game_id: game["GameID"], api_stadium_id: game["StadiumID"]) }

# Game Status Update command:
# Find the game_id of the game you want to force to "Final" (check the URL on the games page), then issue this in tux: (say the game has id = 10)
# Game.find(10).update(status: "Final")
