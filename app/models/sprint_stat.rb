class SprintStat < ActiveRecord::Base
  unloadable
  
  def self.log(journal)
    stuff = "#{journal.inspect}\n#{journal.detail.inspect}"
    raise stuff
  end
end
