class Route < ApplicationRecord
  has_many :steps
  accepts_nested_attributes_for :steps, allow_destroy: true
  scope :time_desc, ->{order(created_at: :desc)}
  MINUTE = 60

  self.inheritance_column = nil
  enum type: {
    recent: 1,
    saved: 2
  }

  def duration
    steps.map{|s| s.body["duration"]["value"]}.inject(&:+).to_f / MINUTE
  end

  def eta
    Time.now() + duration.minutes
  end
end
