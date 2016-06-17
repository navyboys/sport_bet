class Game < ActiveRecord::Base
  has_many :game_teams
  has_many :teams, through: :game_teams
  has_many :bets, through: :game_teams
  belongs_to :stadium

  # after_save :resolve_bet
  # TODO: after_save :set_result_to_game_team

  def completed?
    ['Final', 'Canceled'].include?(status)
  end

  def find_winner
    first_team = game_teams.first
    second_team = game_teams.last
    return if first_team.result == 0

    case first_team.result
    when 1
      [first_team, second_team]
    when -1
      [second_team, first_team]
    else
      ["Tie"]
    end
  end

  def winner
    find_winner.first
  end

  def loser
    find_winner.last
  end

  private

  def pool
    bets.reduce(0) { |sum, bet| sum += bet.points }
  end

  def winner_count
    bets.select { |bet| bet.game_team.result == 1  }.count
  end

  def other_hand_count
    my_result = current_user.game_team.result
    0 unless my_result
    other_hand = (my_status == 1) ? -1 : 1

    bets.select { |bet| bet.game_team.result == other_hand }.count
  end

  # def resolve_bet
  #   bet = bets.find_by(user: current_user)
  #   return unless completed? || bet
  #
  #   bet_result = bet.game_team.result
  #
  #   # bet points back to user
  #   if status == 'Canceled' ||                     # Game Canceled
  #     (status == 'Final' && bet_result == 0) ||    # Tie
  #     (status == 'Final' && other_hand_count == 0) # No one on the other hand
  #     current_user.points += bet.points
  #   end
  #
  #   # all poins in game pool divided by winner count back
  #   if status == 'Final' && bet_result == 1      # Won
  #     current_user.points += pool / winner_count
  #   end
  # end
end
