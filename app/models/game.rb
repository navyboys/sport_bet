class Game < ActiveRecord::Base
  has_many :game_teams
  has_many :teams, through: :game_teams
  has_many :bets, through: :game_teams
  has_many :users, through: :bets

  belongs_to :stadium

  before_save :resolve_bets()

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
  def resolve_bets(winning_team, winscore, losescore) #assumes winning_team will be be <Team>, if nil it was a tie else they were the winning team

    return if completed?  # already did this book-keeping, don't redo it
    game_team_a = self.game_teams.first
    game_team_b = self.game_teams.last
    if winning_team
      if game_team_a.team_id == winning_team.id
        set_game_team_scores(game_team_a, game_team_b, winscore,losescore)
      else
        set_game_team_scores(game_team_b, game_team_a, winscore,losescore)
      end
      winning_game_team_id = game_team_a.team_id == winning_team.id ? game_team_a.id : game_team_b.id
      winning_bets = self.bets.where(game_team_id: winning_game_team_id)
      set_won_bets(winning_bets)
      losing_bets = self.bets.where.not(game_team_id: winning_game_team_id)
      set_lost_bets(losing_bets)
    else
      game_team_a.result = 0
      game_team_a.save!
      game_team_b.result = 0
      game_team_b.save!
      set_tied_bets
#cancel status will not be implemented in this version      self.status = 'Canceled' if self.game_teams.first.score.nil?
    end
      self.status = 'Final'
      self.save!
    # figure out if we just refund points.  either no winner, or all bets on one side
  end

  private
  def set_game_team_scores(wonteam, loseteam, winscore,losescore)
      wonteam.result = 1
      wonteam.score = winscore
      wonteam.save!
      loseteam.result = -1
      loseteam.score = losescore
      loseteam.save!
  end
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
  def winner_count
    bets.select { |bet| bet.game_team.result == 1  }.count
  end

  def other_hand_count(bet)
    my_result = bet.game_team.result
    0 unless my_result
    other_hand = (my_result == 1) ? -1 : 1

    bet.game.bets.select { |b| b.game_team.result == other_hand }.count
  end
end
