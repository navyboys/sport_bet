class Game < ActiveRecord::Base
  has_many :game_teams
  belongs_to :stadium
end
