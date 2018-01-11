require 'csv'
require 'chartkick'
require 'groupdate'
require 'date'

class ReleaseTimeController < ApplicationController

  CSV_FOLDER = 'output'

  def index
    @repos = Dir["../#{CSV_FOLDER}/*"].map{|filepath| File.basename(filepath, '.*') }
    return render :error if @repos.nil? || @repos.empty?
  end

  def show
    file = "../#{CSV_FOLDER}/#{params['repo']}.csv"
    return render :error unless File.exists?(file)

    @commits = load_commits_from_csv file
    @commits_lead_time_graph = @commits.map{|commit| [commit.commit_date, commit.lead_time] }
    @average_lead_time_per_week_graph = average_lead_time_per_week @commits
  end

  def average_lead_time_per_week commits
    average_lead_time_per_week=[]
    weekly_sum = 0
    weekly_count=0
    current_week_beginning_date= DateTime.now.weeks_ago(1)
    commits.each() do |commit|
      if(commit.commit_date > current_week_beginning_date )
        weekly_sum += commit.lead_time
        weekly_count = weekly_count + 1
      else
        average_lead_time_per_week << [current_week_beginning_date,  weekly_count == 0?  0.00 : weekly_sum/weekly_count]
        weekly_count = 1
        weekly_sum = commit.lead_time
        current_week_beginning_date= current_week_beginning_date.weeks_ago(1)
      end
    end
    average_lead_time_per_week
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
