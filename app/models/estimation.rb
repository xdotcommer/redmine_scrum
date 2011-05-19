class Estimation < ActiveRecord::Base
  unloadable
  
  has_many  :issues
  
  def spiked?
    value == 0
  end
end
