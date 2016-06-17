class Bet < ActiveRecord::Base
  has_one :game, through: :game_team
  has_one :stadium, through: :game
  has_one :team, through: :game_team

  belongs_to :user
  belongs_to :game_team

  def show_bet_result
    case game_team.result
    when 1
      'Won'
    when -1
      'Lost'
    when 0
      'Tie'
    else
      'No Idea'
    end
  end

  def show_datetime
    game.datetime.strftime("%F %I:%M%p")
  end

  def show_game_result
    "#{game.winner.team.name} (#{game.winner.score}) vs " +
    "#{game.loser.team.name} (#{game.loser.score})"
  end
end
