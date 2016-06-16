class ChaneGameToGameteamInBets < ActiveRecord::Migration
  def change
    rename_column :bets, :game_id, :game_team_id
  end
end
