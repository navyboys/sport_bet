class Game < ActiveRecord::Base
  has_many :game_teams
  belongs_to :stadium
  has_many :teams, through: :game_teams
  has_many :bets, through: :game_teams
  has_many :users, through: :bets
end
