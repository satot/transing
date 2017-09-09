class Step < ApplicationRecord
  belongs_to :route

  def start_location
    JSON.parse(content)["start_location"]
  end
end
