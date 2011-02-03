require 'rexml/document'

require File.expand_path(File.dirname(__FILE__) + '/../lib/commit_message')
require File.expand_path(File.dirname(__FILE__) + '/../lib/prompt_line')
require File.expand_path(File.dirname(__FILE__) + '/../lib/cruise_status')

desc "Run before checking in"
task :pc => ['svn:add', 'svn:delete', 'svn:up',:precommit]

desc "Run to check in"
task :commit_without_merge => "svn:st" do
  commit_with_task(nil)
end

desc "Run to check in with merge"
task :commit => "svn:st" do
  commit_with_task(:merge_to_branches)
end


def merge_to_branches
  input=""
  while (input.strip.empty?)
    input = Readline.readline("Do u want to merge your code with other branches?")
  end

  branch_names= "";
  if (input.strip.downcase[0, 1] == "y")
    while (branch_names.strip.empty?)
      branch_names = Readline.readline("Enter the absolute path of all the branches delimited by space.")
    end
  end

 
  branches = branch_names.split(" ");
  branches.each do |branch|
    puts"merging with branch " + branch
    sh "#{"sh ./merge.sh  #{branch}" }"
  end
end


def commit_command(message)
  "svn ci -m #{message.inspect}"
end

def files_to_check_in?
  %x[svn st --ignore-externals].split("\n").reject {|line| line[0, 1] == "X"}.any?
end

def ok_to_check_in?
  return true unless self.class.const_defined?(:CCRB_RSS)
  cruise_status = CruiseStatus.new(CCRB_RSS)
  cruise_status.pass? ? true : are_you_sure?( cruise_status.failures )
end

def are_you_sure?(messages)
  message = messages.join("\n")
  puts "Build FAILURES:\n", message
  input = ""
  while (input.strip.empty?)
    input = Readline.readline("Are you sure you want to check in? (y/n): ")
  end
  return input.strip.downcase[0, 1] == "y"
end

def commit_with_task(task)
  if files_to_check_in?
    commit_message = CommitMessage.new.prompt
    Rake::Task[:pc].invoke
    method(task).call if(task)
    sh "#{commit_command(commit_message)}" if ok_to_check_in?
  else
    puts "Nothing to commit"
  end
end


task :cockmit => [:commit]
