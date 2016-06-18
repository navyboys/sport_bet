class User < ActiveRecord::Base
  has_many :bets
  has_many :followees, class_name: 'Following', foreign_key: :followee
  has_many :game_teams, through: :bets
  has_many :games, through: :game_teams
  has_many :stadia, through: :games
  has_many :teams, through: :game_teams

#   def get_points
#     p @current_user
#     # profit = Bet.where(user_id = @current_user.id).sum("profit_points")
#     # wager = Bet.where(user_id = @current_user.id).select("points")
#     # @current_user.points + profit + wager
#   end
end

