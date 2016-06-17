class Game < ActiveRecord::Base
  has_many :game_teams
  has_many :teams, through: :game_teams
  has_many :bets, through: :game_teams
  has_many :users, through: :bets

  belongs_to :stadium

  # TODO: before_save :resolve_bet
  # TODO: before_save :set_result_to_game_team

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
    game_teams.where(result: [1, 0]).map { |gt| gt.team }.first
  end

  def loser
    game_teams.where(result: [-1, 0]).map { |gt| gt.team }.first
  end

  private

  def pool
    bets.sum(points)
  end

  def winner_count
    bets.select { |bet| bet.game_team.result == 1  }.count
  end

  def other_hand_count
    my_result = current_user.game_team.result
    0 unless my_result
    other_hand = (my_result == 1) ? -1 : 1

    bets.select { |bet| bet.game_team.result == other_hand }.count
  end

  def resolve_bet
    return unless completed?

    bets.each do |bet|
      bet_result = bet.game_team.result

      # bet points back to user
      if status == 'Canceled' ||                     # Game Canceled
        (status == 'Final' && bet_result == 0) ||    # Tie
        (status == 'Final' && other_hand_count == 0) # No one on the other hand
        current_user.points += bet.points
      end

      # all poins in game pool divided by winner count back
      # TODO: points shoold be divided by raitos
      if status == 'Final' && bet_result == 1      # Won
        current_user.points += pool / winner_count
      end
    end
  end

  def resolve_bet(winning_team)
    if completed?
      return  # already did this book-keeping, don't redo it
    end
    # figure out if we just refund points.  either no winner, or all bets on one side
  end

  # TODO: When & where call this method?
  def cancel_game
    # 1) set status = canelled
    # 2) refund all bets
    # 3) ??? set game_team.result to some value ???
  end
end
