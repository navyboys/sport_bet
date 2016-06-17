class RenameFollowerAndFollowee < ActiveRecord::Migration
  def change
    rename_column :followings, :follower, :follower_id
    rename_column :followings, :followee, :followee_id
  end
end
