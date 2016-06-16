class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string        :status
      t.datetime      :datetime
      t.string        :league
      t.references    :stadium
      t.timestamps
    end
  end
end
