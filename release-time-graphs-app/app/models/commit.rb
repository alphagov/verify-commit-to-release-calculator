class Commit
  attr_accessor :commit_date, :build_date, :commit_to_release_lead_time, :commit_to_build_lead_time, :sha, :release_date, :release_tag

  def initialize props
    @commit_date = props[:commit_date]
    @build_date = props[:build_date]
    @release_date = props[:release_date]
    @commit_to_build_lead_time = props[:commit_to_build_lead_time]
    @commit_to_release_lead_time = props[:commit_to_release_lead_time]
    @sha = props[:sha]
    @release_tag = props[:release_tag]
  end
end