class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy  # ✅ Delete comments when a post is deleted

  validates :title, presence: true
  validates :text, presence: true
end
