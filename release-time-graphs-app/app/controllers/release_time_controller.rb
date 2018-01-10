require 'csv'
require 'chartkick'
require 'groupdate'

class ReleaseTimeController < ApplicationController

  CSV_FOLDER = 'output'

  def index
    @repos = Dir["../#{CSV_FOLDER}/*"].map{|filepath| File.basename(filepath, '.*') }
    return render :error if @repos.nil? || @repos.empty?
  end

  def show
    file = "../#{CSV_FOLDER}/#{params['repo']}.csv"
    return render :error unless File.exists?(file)

    commits = load_commits_from_csv file
    @commits_lead_time_graph = commits.map{|commit| [commit.commit_date, commit.lead_time] }
    @average_lead_time_per_week_graph = average_lead_time_per_week commits
  end

  private

  def average_lead_time_per_week commits
    weeks = commits.group_by_week(&:commit_date)
    weeks.map do |week, commits_per_week|
      sum = commits_per_week.map(&:lead_time).inject(0, &:+)
      number_of_commits = commits_per_week.count
      [week, sum/number_of_commits ]
    end
  end

  def load_commits_from_csv file
    commits = []
    CSV.foreach(file, headers: true) do |commit|
      commits << Commit.new(
        sha: commit['Sha'],
        commit_date: DateTime.parse(commit['Commit date']),
        release_date: DateTime.parse(commit['Release date']),
        release_tag: commit['Tag'],
        lead_time: commit['Commit to release (hours)'].to_f.round(2))
    end
    commits
  end
end
