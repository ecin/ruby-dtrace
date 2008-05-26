#
# Ruby-Dtrace
# (c) 2008 Chris Andrews <chris@nodnol.org>
#

require 'dtrace'
require 'dtrace/dof'
require 'test/unit'
require 'pp'

class TestDofStrtabs < Test::Unit::TestCase
  include Dtrace::Dof::Constants
  
  def test_strtab_stridxs
    strings = ['foo', 'bar', 'baz']
    sec = Dtrace::Dof::Section::Strtab.new(strings, 1)
    
    assert sec
    assert_equal 1, sec.stridx('foo')
    assert_equal 5, sec.stridx('bar')
    assert_equal 9, sec.stridx('baz')
  end

  def test_strtab_stridxs_uniq
    strings = ['foo', 'bar', 'foo']
    sec = Dtrace::Dof::Section::Strtab.new(strings, 1)
    
    assert sec
    assert_equal 1, sec.stridx('foo')
    assert_equal 5, sec.stridx('bar')
  end

  def test_strtab_dof
    f = Dtrace::Dof::File.new

    strings = ['test', 'main', 'test']
    strtab = Dtrace::Dof::Section::Strtab.new(strings, 0)
    f.sections << strtab

    pp strtab

    s = Dtrace::Dof::Section.new(DOF_SECT_PROBES, 1)
    s.data = [
              {
                :name     => strtab.stridx('test'),
                :func     => strtab.stridx('main'),
                :noffs    => 1,
                :enoffidx => 0,
                :argidx   => 0,
                :nenoffs  => 0,
                :offidx   => 0,
                :addr     => 0,
                :nargc    => 0,
                :xargc    => 0
              },
             ]
    f.sections << s

    s = Dtrace::Dof::Section.new(DOF_SECT_PRARGS, 2)
    s.data = [ 0 ]
    f.sections << s

    s = Dtrace::Dof::Section.new(DOF_SECT_PROFFS, 3)
    s.data = [ 36 ]
    f.sections << s
    
    s = Dtrace::Dof::Section.new(DOF_SECT_PROVIDER, 4)
    s.data = {
      :strtab => 0,
      :probes => 1,
      :prargs => 2,
      :proffs => 3,
      :name   => strtab.stridx('test'),
      :provattr => { :name => 5, :data => 5, :class => 5 },
      :modattr  => { :name => 1, :data => 1, :class => 5 },
      :funcattr => { :name => 1, :data => 1, :class => 5 },
      :nameattr => { :name => 5, :data => 5, :class => 5 },
      :argsattr => { :name => 5, :data => 5, :class => 5 }
    }
    f.sections << s

    pp f

    dof = f.generate
    assert dof

    Dtrace.loaddof(dof)    
  end

end