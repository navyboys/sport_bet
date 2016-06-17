class ChangeStadiumName < ActiveRecord::Migration
  def change
    rename_table('stadiums', 'stadia')
  end
end
