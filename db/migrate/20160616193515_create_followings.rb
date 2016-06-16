class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.integer       :follower
      t.integer       :followee
      t.timestamps
    end
  end
end
