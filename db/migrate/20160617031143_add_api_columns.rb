class AddApiColumns < ActiveRecord::Migration
  def change
    add_column :stadia, :api_stadium_id, :integer
    add_column :games, :api_game_id, :integer
    add_column :games, :api_stadium_id, :integer
    add_column :teams, :api_team_id, :integer
    add_column :game_teams, :api_game_id, :integer
    add_column :game_teams, :api_team_id, :integer
    add_column :bets, :profit_points, :integer
  end
end
