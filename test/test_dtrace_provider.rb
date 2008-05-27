#
# Ruby-Dtrace
# (c) 2008 Chris Andrews <chris@nodnol.org>
#

require 'dtrace'
require 'dtrace/provider'
require 'test/unit'

class TestDtraceProviders < Test::Unit::TestCase
  
  def test_probe_no_args
    Dtrace::Provider.create :test do |p|
      p.probe :test
    end

    t = Dtrace.new
    matches = 0
    t.each_probe do |p|
      if p.to_s == "test#{$$}:testmodule:main:test"
        matches += 1
      end
    end
    assert_equal 1, matches
  end

  def test_probe_with_char_arg
    Dtrace::Provider.create :test do |p|
      p.probe :test, :string
    end

    t = Dtrace.new
    matches = 0
    t.each_probe do |p|
      if p.to_s == "test#{$$}:testmodule:main:test"
        matches += 1
      end
    end
    assert_equal 1, matches
  end

  def test_probe_with_int_arg
    Dtrace::Provider.create :test do |p|
      p.probe :test, :int
    end

    t = Dtrace.new
    matches = 0
    t.each_probe do |p|
      if p.to_s == "test#{$$}:testmodule:main:test"
        matches += 1
      end
    end
    assert_equal 1, matches
  end

  def test_probe_with_two_args
    Dtrace::Provider.create :test do |p|
      p.probe :test, :int, :int
    end

    t = Dtrace.new
    matches = 0
    t.each_probe do |p|
      if p.to_s == "test#{$$}:testmodule:main:test"
        matches += 1
      end
    end
    assert_equal 1, matches
  end

  def test_multiple_probes_with_two_args
    Dtrace::Provider.create :test do |p|
      p.probe :test1, :int, :int
      p.probe :test2, :int, :int
    end

    t = Dtrace.new
    matches = 0
    t.each_probe do |p|
      if p.to_s =~ /^test#{$$}:testmodule:main:test/
        matches += 1
      end
    end
    assert_equal 2, matches
  end

  def test_multiple_probes
    Dtrace::Provider.create :test do |p|
      p.probe :test1, :int
      p.probe :test2, :int
      p.probe :test3, :int
      p.probe :test4, :int
      p.probe :test5, :int
    end

    t = Dtrace.new
    matches = 0
    t.each_probe do |p|
      if p.to_s =~ /^test#{$$}:testmodule:main:test/
        matches += 1
      end
    end
    assert_equal 5, matches
  end

end
