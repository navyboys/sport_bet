class GameTeam < ActiveRecord::Base
  belongs_to :game
  belongs_to :team
  has_many :bets
  has_many :users, through: :bets
  has_one :stadium, through: :game

  def pool
    # bets.reduce(0) { |sum, bet| sum += bet.points }
    bets.sum(points)
  end
end
