class AddArchivedToBets < ActiveRecord::Migration
  def change
    add_column :bets, :archived, :boolean
  end
end
