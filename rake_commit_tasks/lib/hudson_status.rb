require 'rexml/document'
require "open-uri"

class HudsonStatus

  def initialize(feed_url)
    @failures = []
    project_feed = open(feed_url).read
    @doc = REXML::Document.new(project_feed)
  rescue Exception => e
    @failures = [e.message]
    @doc = REXML::Document.new("")
  end

  def pass?
    failures.empty?
  end

  def failures
    titles = REXML::XPath.match( @doc, "//feed/entry/title" )
    if !titles.empty? 
      latest = titles[0].text
      @failures +=  [latest] if /stable/.match(latest).nil?
    end
    @failures
  end
end
