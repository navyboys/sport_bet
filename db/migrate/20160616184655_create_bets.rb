class CreateBets < ActiveRecord::Migration
  def change
    create_table :bets do |t|
      t.integer       :points
      t.integer       :result
      t.references    :user
      t.references    :game
      t.timestamps
    end
  end
end
