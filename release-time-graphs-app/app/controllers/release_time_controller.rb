require 'csv'
require 'chartkick'

class ReleaseTimeController < ApplicationController

  def index
    commits = []
    CSV.foreach('../time_from_commit_to_release_logs.csv', headers: true) do |commit|
      commit_date = DateTime.parse(commit['Commit date'])
      release_date = DateTime.parse(commit['Release tag date'])

      lead_time = ((release_date.to_time - commit_date.to_time)/3600).round(2)

      commit_object = Commit.new(commit_date, lead_time)
      commits << commit_object
    end
    @commits = commits.map{|commit| [commit.commit_date.to_time.to_i, commit.lead_time] }
  end

end
