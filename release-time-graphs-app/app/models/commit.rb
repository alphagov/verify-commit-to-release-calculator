class Commit
  attr_accessor :commit_date, :lead_time, :sha, :release_date, :release_tag

  def initialize props
    @commit_date = props[:commit_date]
    @release_date = props[:release_date]
    @lead_time = props[:lead_time]
    @sha = props[:sha]
    @release_tag = props[:release_tag]
  end
end