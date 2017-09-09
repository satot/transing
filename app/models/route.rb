class Route < ApplicationRecord
  has_many :steps
  accepts_nested_attributes_for :steps, allow_destroy: true
  scope :time_desc, ->{order(created_at: :desc)}

  self.inheritance_column = nil
  enum type: {
    recent: 1,
    saved: 2
  }
end
