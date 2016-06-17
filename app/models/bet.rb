class Bet < ActiveRecord::Base
  has_one :game, through: :game_team
  has_one :stadium, through: :game
  has_one :team, through: :game_team

  belongs_to :user
  belongs_to :game_team
end
