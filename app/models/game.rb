class Game < ActiveRecord::Base
  has_many :game_teams
  has_many :teams, through: :game_teams
  has_many :bets, through: :game_teams
  has_many :users, through: :bets

  belongs_to :stadium

  before_save :resolve_bets

  def completed?
    ['Final', 'Canceled'].include?(status)
  end

  def in_progress?
    ['Scheduled', 'InProgress'].include?(status)
  end

  def winner
    return unless game_teams.count > 1
    game_team_a = game_teams.first
    game_team_b = game_teams.last
    game_team_a.score ||= 0
    game_team_b.score ||= 0
    game_team_a.score > game_team_b.score ? game_team_a : game_team_b
  end

  def loser
    game_teams.where.not(id: winner.id).first
  end

  def pool
    bets.reduce(0) {|m, bet| m + bet.points}
  end

  def tied?
    game_teams.first.score == game_teams.last.score
  end

  def resolve_bets
    return unless winner && loser
    if winner.score == loser.score
      set_game_team_result(winner, loser, 'tied')
      set_tied_bets
    else
      set_game_team_result(winner, loser, 'not_tied')
      winning_bets = self.bets.where(game_team: winner)
      set_won_bets(winning_bets)
      losing_bets = self.bets.where(game_team: loser)
      set_lost_bets(losing_bets)
    end
  end

  def set_game_team_result(wonteam, loseteam, tied_or_not)
    if tied_or_not == 'tied'
      wonteam.result = 0
      loseteam.result = 0
    elsif tied_or_not == 'not_tied'
      wonteam.result = 1
      loseteam.result = -1
    end
    wonteam.save!
    loseteam.save!
  end

  def set_won_bets(bets)
    winning_bet_pool = bets.reduce(0) {|m, bet| m + bet.points}
    bets.each do |bet|          #sets bet's profit_points
      decimal_percentage = bet.points.to_f / winning_bet_pool.to_f #check math and decimal if time allows
      winnings = (pool * decimal_percentage).floor
      bet.profit_points = winnings
      bet.user.points += winnings
      bet.save!
      bet.user.save!
    end
  end

  def set_lost_bets(bets)
    bets.each do |bet|
      bet.profit_points = 0
      bet.save!
    end
  end

  def set_tied_bets
    self.bets.each do |bet|     #everyone gets their points back and 'profit points' are set to bet point amount
      bet.profit_points = bet.points
      bet.user.points += bet.points
      bet.save!
      bet.user.save!
    end
  end
end
