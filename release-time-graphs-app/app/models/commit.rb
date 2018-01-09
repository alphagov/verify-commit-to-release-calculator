class Commit
  attr_accessor :commit_date, :lead_time

  def initialize commit_date, lead_time
    self.commit_date = commit_date
    self.lead_time = lead_time
  end
end