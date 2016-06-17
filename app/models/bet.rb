class Bet < ActiveRecord::Base
  belongs_to :user
  belongs_to :game_team
  has_one :game, through: :game_team
  has_one :stadium, through: :game
  has_one :team, through: :game_team
  
end
