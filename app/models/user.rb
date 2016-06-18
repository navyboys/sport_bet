class User < ActiveRecord::Base
  has_many :bets
  has_many :followees, class_name: 'Following', foreign_key: :follower_id
  has_many :game_teams, through: :bets
  has_many :games, through: :game_teams
  has_many :stadia, through: :games
  has_many :teams, through: :game_teams

  def bet?(game)
    game.users.include?(self)
  end

end

