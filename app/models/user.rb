class User < ActiveRecord::Base
  has_many :bets
  has_many :followees, class_name: 'Following', foreign_key: :follower_id
  has_many :game_teams, through: :bets
  has_many :games, through: :game_teams
  has_many :stadia, through: :games
  has_many :teams, through: :game_teams

  def bet_count
    bets.count
  end

  def bets_in_progress
    game_teams.joins(:game).where("games.status IN ('Scheduled', 'InProgress')")
  end

  def bet_count_in_progress
    bets_in_progress.count
  end

  def bet_points_in_progress
    bets_in_progress.sum(:points)
  end

  def bets_completed
    game_teams.joins(:game).where("games.status IN ('Final', 'Canceled')")
  end

  def bet_count_completed
    bets_completed.count
  end
end
