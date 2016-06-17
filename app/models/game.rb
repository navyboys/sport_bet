class Game < ActiveRecord::Base
  has_many :game_teams
  has_many :teams, through: :game_teams
  has_many :bets, through: :game_teams
  has_many :users, through: :bets

  belongs_to :stadium

  # TODO: set_result_to_game_team ? 
  # TODO: before_save :resolve_bet

  def completed?
    ['Final'].include?(status) #change later 
  end

  def winner
    game_teams.where(result: [1, 0]).map { |gt| gt.team }.first
  end

  def loser
    game_teams.where(result: [-1, 0]).map { |gt| gt.team }.first
  end

  def pool
    bets.reduce(0) {|m, bet| m + bet.points}
  end

  def resolve_bet(winning_team) #assumes winning_team will be be <Team> or is it <GameTeam>?, if nil it was a tie else they were the winning team
    return if completed?  # already did this book-keeping, don't redo it
    if winning_team

      game_team_a = self.game_teams.first
      game_team_b = self.game_teams.last
      winning_game_team_id = game_team_a.team_id == winning_team.id ? game_team_a.id : game_team_b.id  

      winning_bets = self.bets.where(game_team_id: winning_game_team_id) 
      set_won_bets(winning_bets)
      losing_bets = self.bets.where.not(game_team_id: winning_game_team_id)
      set_lost_bets(losing_bets)
      self.status = 'Final' 
    else 
      set_tied_bets
      self.status = 'Canceled' if self.game_teams.first.score.nil? 
    end
      self.save!
    # figure out if we just refund points.  either no winner, or all bets on one side
  end

  private
  
  def set_won_bets(bets)
    winning_bet_pool = bets.reduce(0) {|m, bet| m + bet.points}   
    bets.each do |bet|          #sets bet's profit_points
      decimal_percentage = bet.points.to_f / winning_bet_pool.to_f #check math and decimal if time allows
      winnings = (pool * decimal_percentage).floor
      bet.profit_points = winnings
      bet.save!
      bet.user.points += winnings  #sets user's points winnings from bet
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
      bet.save!
      bet.user.points = bet.points
      bet.user.save!
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

# def resolve_bet
#   return unless completed?

#   bets.each do |bet|
#     bet_result = bet.game_team.result

#     # bet points back to user
#     if status == 'Canceled' ||                     # Game Canceled
#       (status == 'Final' && bet_result == 0) ||    # Tie
#       (status == 'Final' && other_hand_count == 0) # No one on the other hand
#       bet.user.points += bet.points
#     end

#     # all poins in game pool divided by winner count back
#     # TODO: points should be divided by ratios
#     if status == 'Final' && bet_result == 1      # Won
#       current_user.points += pool / winner_count
#     end
#   end
# end

  # TODO: When & where call this method?
  def cancel_game
    # 1) set status = canelled
    # 2) refund all bets
    # 3) ??? set game_team.result to some value ???
  end
end
