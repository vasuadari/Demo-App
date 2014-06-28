class Student < ActiveRecord::Base
  attr_accessible :name, :roll_no, :year
  validates :name, presence: true
end
