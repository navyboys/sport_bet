class Team < ActiveRecord::Base
  has_many :game_teams
  has_many :bets, through: :game_teams
  has_many :games, through: :game_teams
  has_many :stadia, through: :games
  has_many :users, through: :bets
end
