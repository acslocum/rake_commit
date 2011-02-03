load File.expand_path(File.dirname(__FILE__) + '/./rake_commit_tasks/tasks/commit.rake')
load File.expand_path(File.dirname(__FILE__) + '/./rake_commit_tasks/tasks/svn.rake')

CCRB_RSS = "http://services-cruise:8080/cruisecontrol/rss"

task :default => :precommit

task :precommit do
  sh "ant"
end

task :all do
  sh "ant all_with_integration"
end

load File.expand_path(File.dirname(__FILE__) + '/./seacucumber/tasks/seacucumber.rake')