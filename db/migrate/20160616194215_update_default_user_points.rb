class UpdateDefaultUserPoints < ActiveRecord::Migration
  def change
    change_column_default(:users, :points, 1000)
  end
end
