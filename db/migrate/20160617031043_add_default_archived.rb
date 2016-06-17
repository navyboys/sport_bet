class AddDefaultArchived < ActiveRecord::Migration
  def change
    change_column_default :bets, :archived, false
  end
end
