class CreateGameTeams < ActiveRecord::Migration
  def change
    create_table :game_teams do |t|
      t.integer       :score
      t.integer       :result
      t.references    :team
      t.references    :game
      t.timestamps
    end
  end
end
