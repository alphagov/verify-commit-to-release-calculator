require 'csv'
require 'chartkick'
require 'groupdate'

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

    @weeks = commits.group_by_week(&:commit_date)

    @average_lead_time_per_week = []
    @weeks.each() do |week, commits|
      sum = 0
      number_of_commits = 0
      commits.each() do |commit|
        sum += commit.lead_time
        number_of_commits = number_of_commits + 1
      end
      @average_lead_time_per_week << [week, sum/number_of_commits ]
    end
  end

end
