class Stadium < ActiveRecord::Base
  has_many :games
  has_many :game_teams, through: :games
  has_many :teams, through: :game_teams
  has_many :bets, through: :game_teams
  has_many :users, through: :bets
end
