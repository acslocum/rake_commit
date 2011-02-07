require File.dirname(__FILE__) + "/test_helper"

FAIL_RESPONSE = <<-EOS
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>aps all builds</title>
  <link type="text/html" href="http://10.0.1.6:8080/hudson/job/aps/" rel="alternate"/>
  <updated>2011-02-03T21:04:58Z</updated>
  <author>
    <name>Hudson Server</name>
  </author>
  <id>urn:uuid:903deee0-7bfa-11db-9fe1-0800200c9a66</id>
  <entry>
    <title>aps #27 (broken since build #19)</title>
    <link type="text/html" href="http://10.0.1.6:8080/hudson/job/aps/27/" rel="alternate"/>
    <id>tag:hudson.dev.java.net,2011:aps:2011-02-03_08-19-14</id>
    <published>2011-02-03T14:19:14Z</published>
    <updated>2011-02-03T14:19:14Z</updated>
  </entry>
</feed>
EOS

FAIL_LONG_RESPONSE = <<-EOS
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>aps all builds</title>
  <link type="text/html" href="http://10.0.1.6:8080/hudson/job/aps/" rel="alternate"/>
  <updated>2011-02-03T21:04:58Z</updated>
  <author>
    <name>Hudson Server</name>
  </author>
  <id>urn:uuid:903deee0-7bfa-11db-9fe1-0800200c9a66</id>
  <entry>
    <title>aps #87 (broken since this build)</title>
    <link type="text/html" href="http://10.0.1.6:8080/hudson/job/aps/87/" rel="alternate"/>
    <id>tag:hudson.dev.java.net,2011:aps:2011-02-07_09-54-03</id>
    <published>2011-02-07T15:54:03Z</published><updated>2011-02-07T15:54:03Z</updated>
  </entry>
  <entry>
    <title>aps #86 (stable)</title><link type="text/html" href="http://10.0.1.6:8080/hudson/job/aps/86/" rel="alternate"/>
    <id>tag:hudson.dev.java.net,2011:aps:2011-02-07_09-48-05</id>
    <published>2011-02-07T15:48:05Z</published><updated>2011-02-07T15:48:05Z</updated>
  </entry>
</feed>

EOS

PASS_RESPONSE = <<-EOS
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>aps all builds</title>
  <link type="text/html" href="http://10.0.1.6:8080/hudson/job/aps/" rel="alternate"/>
  <updated>2011-02-03T21:04:58Z</updated>
  <author>
    <name>Hudson Server</name>
  </author>
  <id>urn:uuid:903deee0-7bfa-11db-9fe1-0800200c9a66</id>
  <entry>
    <title>aps #56 (stable)</title>
    <link type="text/html" href="http://10.0.1.6:8080/hudson/job/aps/56/" rel="alternate"/>
    <id>tag:hudson.dev.java.net,2011:aps:2011-02-03_15-04-58</id>
    <published>2011-02-03T21:04:58Z</published>
    <updated>2011-02-03T21:04:58Z</updated>
  </entry>
</feed>
EOS

class TestHudsonStatusFail < Test::Unit::TestCase
  
  def setup
    HudsonStatus.any_instance.expects(:open).with('hudson.rss').returns(stub(:read => FAIL_RESPONSE))
    @hudson_checker = HudsonStatus.new 'hudson.rss'
  end
  
  test "failed projects are parsed correctly" do
    assert_equal ["aps #27 (broken since build #19)"], @hudson_checker.failures
  end
    
  test "pass is false when cruise is failed" do
    assert_equal false, @hudson_checker.pass?
  end
end

class TestHudsonStatusFailNewBuild < Test::Unit::TestCase
  
  def setup
    HudsonStatus.any_instance.expects(:open).with('hudson.rss').returns(stub(:read => FAIL_LONG_RESPONSE))
    @hudson_checker = HudsonStatus.new 'hudson.rss'
  end
  
  test "failed projects are parsed correctly" do
    assert_equal ["aps #87 (broken since this build)"], @hudson_checker.failures
  end
    
  test "pass is false when cruise is failed" do
    assert_equal false, @hudson_checker.pass?
  end
end

class TestHudsonStatusPass < Test::Unit::TestCase
  
  def setup
    HudsonStatus.any_instance.expects(:open).with('hudson.rss').returns(stub(:read => PASS_RESPONSE))
    @hudson_checker = HudsonStatus.new 'hudson.rss'
  end
  
  test "passing projects are parsed correctly" do
    assert_equal [], @hudson_checker.failures
  end
  
  test "test pass is true when hudson is passing" do
    assert_equal true, @hudson_checker.pass?
  end
end

class TestHudsonStatusCannotConnect < Test::Unit::TestCase

  test "pass is false when cannot connect to hudson" do
    HudsonStatus.any_instance.expects(:open).with('bad_url').raises(Exception, 'Cannot connect')
    assert_equal false, HudsonStatus.new('bad_url').pass?
  end
end
