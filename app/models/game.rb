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

  def winner
    game_team_a = game_teams.first
    game_team_b = game_teams.last
    game_team_a.score > game_team_b.score ? game_team_a : game_team_b
  end

  def loser
    game_teams.where(result: [-1, 0]).map { |gt| gt.team }.first
  end

  def pool
    bets.reduce(0) {|m, bet| m + bet.points}
  end

  def tied?
    game_teams.first.score == game_teams.last.score
  end

  def resolve_bets
    return if completed?  # already did this book-keeping, don't redo it

    game_team_a = self.game_teams.first
    game_team_b = self.game_teams.last

    winning_team = nil
    losing_team = nil

    if game_team_a.score > game_team_b.score
      winning_team = game_team_a
      losing_team =  game_team_b
    elsif game_team_a.score < game_team_b.score
      winning_team = game_team_b
      winning_team = game_team_a
    else
      winning_team = nil
    end

    if winning_team
      winning_bets = self.bets.where(game_team_id: winning_team.id)
      set_won_bets(winning_bets)
      losing_bets = self.bets.where.not(game_team_id: winning_team.id)
      set_lost_bets(losing_bets)
    else
      set_tied_bets
    end
  end

  private
  def set_won_bets(bets)
    winning_bet_pool = bets.reduce(0) {|m, bet| m + bet.points}
    bets.each do |bet|          #sets bet's profit_points
      decimal_percentage = bet.points.to_f / winning_bet_pool.to_f #check math and decimal if time allows
      winnings = (pool * decimal_percentage).floor
      bet.profit_points = winnings
      bet.save!
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
      bet.save!
    end
  end
end
