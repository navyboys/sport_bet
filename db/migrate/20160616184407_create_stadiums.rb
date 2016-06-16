class CreateStadiums < ActiveRecord::Migration
  def change
    create_table :stadiums do |t|
      t.string        :name
      t.string        :city
      t.timestamps
    end
  end
end
