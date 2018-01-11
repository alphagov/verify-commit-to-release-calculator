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

    @commits = load_commits_from_csv(file)
    @commits_to_plot = @commits.select{|commit| commit.commit_to_release_lead_time < 1000 }
    @commits_to_release_lead_time_graph = @commits_to_plot.map{|commit| [commit.commit_date, commit.commit_to_release_lead_time] }
    @commits_to_build_lead_time_graph = @commits_to_plot.map{|commit| [commit.commit_date, commit.commit_to_build_lead_time] }
    @average_build_lead_time_per_week_graph = average_lead_time_per_week(@commits_to_plot, :commit_to_build_lead_time)
    @average_release_lead_time_per_week_graph = average_lead_time_per_week(@commits_to_plot, :commit_to_release_lead_time)
  end

  def average_lead_time_per_week(commits, tag_type)
    average_lead_time_per_week=[]
    weekly_sum = 0
    weekly_count=0
    current_week_beginning_date= DateTime.now.weeks_ago(1)
    commits.each() do |commit|
      lead_time = commit.send(tag_type)

      if(commit.commit_date > current_week_beginning_date)
        weekly_sum += lead_time
        weekly_count = weekly_count + 1
      else
        average_lead_time_per_week << [current_week_beginning_date,  weekly_count == 0?  0.00 : weekly_sum/weekly_count]
        weekly_count = 1
        weekly_sum = lead_time
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
        build_date: DateTime.parse(commit['Build date']),
        release_date: DateTime.parse(commit['Release date']),
        release_tag: commit['Tag'],
        commit_to_release_lead_time: commit['Commit to release (hours)'].to_f.round(2),
        commit_to_build_lead_time: commit['Commit to build(hours)'].to_f.round(2))
    end
    commits
  end
end
