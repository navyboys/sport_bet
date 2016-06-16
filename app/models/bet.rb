class Bet < ActiveRecord::Base
  belongs_to :user
  belongs_to :game_team
end
