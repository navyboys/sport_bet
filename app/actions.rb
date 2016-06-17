# Homepage
get '/' do
  redirect :'games'
end

# Page: Bet on a game
get '/games' do
  erb :'games/index'
end

# Page: Game details
get '/games/:id' do
  erb :'games/show'
end

# Create a bet for a game
post 'games/:id/bets' do
  redirect :'games' # When saved successfully
end

# Page: My bets
get '/bets' do
  erb :'bets/index'
end

# Page: Leader board
get '/leaderboard' do
  erb :'users/leaderboard'
end

# Page: Custome Board
get '/customeboard' do
  erb :'users/customeboard'
end

# ---------------------------------------------
# To be removed - temporary API helper to seed tables
require 'net/http'
# require 'pry-byebug'
require 'json'

def get_api_data(required_data = nil)
  # uri = URI("https://api.fantasydata.net/mlb/v2/JSON/#{required_data}")
  uri = URI("https://api.fantasydata.net/mlb/v2/JSON/GamesByDate/#{required_data}")
  uri.query = URI.encode_www_form({
    })
  # binding.pry
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

JSON.parse(get_api_data("GamesByDate"))
# pp JSON.parse(get_api_data("CurrentSeason"))
@api_response = JSON.parse(get_api_data("2016-JUN-15"))
# JSON.parse(get_api_data("teams"))
# binding.pry
# puts "Stop"
# CurrentSeason
# 2015-SEP-01
