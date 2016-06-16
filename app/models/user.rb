class User < ActiveRecord::Base
  has_many :bets
  has_many :followees, class_name: 'Following', foreign_key: :followee
end
