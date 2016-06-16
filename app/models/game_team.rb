class GameTeam < ActiveRecord::Base
  belongs_to :game
  belongs_to :team
  has_many :bets
end
