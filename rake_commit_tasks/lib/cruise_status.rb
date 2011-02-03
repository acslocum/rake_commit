require 'rexml/document'
require "open-uri"

class CruiseStatus

  def initialize(feed_url)
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
    @failures ||= REXML::XPath.match( @doc, "//item/title" ).select { |element|
      element.text.downcase =~ /failed/
    }.map do |element|
      element.text.downcase.gsub( /(.*) (build (.+) failed|failed)$/i, '\1' )
    end
  end
end
