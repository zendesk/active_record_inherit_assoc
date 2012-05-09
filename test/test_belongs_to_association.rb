require File.dirname(__FILE__) + '/helper.rb'

class TestBelongsToAssociation < ActiveSupport::TestCase
  class Main < ActiveRecord::Base
  end

  class Other < ActiveRecord::Base
    belongs_to :main
    inherits_from :main, :attr => [:account_id, :val]
  end

  def test_value_is_inherited_from_parent
    @main = Main.create!(:account_id => 42)
    @other = Other.create!(:main => @main)

    assert_equal 42, @other.account_id
  end

  def test_multiple_values_are_inherited_from_parent
    @main = Main.create!(:account_id => 42, :val => "The Answer")
    @other = Other.create!(:main => @main)

    assert_equal 42, @other.account_id
    assert_equal "The Answer", @other.val
  end

  def test_does_not_inherit_when_parent_not_present
    @other = Other.create!
    assert_nil @other.account_id
  end

  def test_overwrites_value_on_child
    @main = Main.create!(:account_id => 42)
    @other = Other.create!(:main => @main, :account_id => 1337)

    assert_equal 42, @other.account_id
  end

  def test_allows_setting_the_value_after_instantiation
    @main = Main.create!
    @other = Other.new(:main => @main, :account_id => 1337)

    @main.account_id = 42
    @other.save

    assert_equal 42, @other.account_id
  end
end
