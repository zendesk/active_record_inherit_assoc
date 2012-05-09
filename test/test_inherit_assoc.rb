require File.dirname(__FILE__) + '/helper.rb'

class TestInheritAssoc < ActiveSupport::TestCase
  class Main < ActiveRecord::Base
    has_many :others, :inherit => :account_id
    has_one :third, :inherit => :account_id
    has_many :fourths, :inherit => [:account_id, :blah_id]
  end

  class Other < ActiveRecord::Base
    belongs_to :main
  end

  class Third < ActiveRecord::Base
    belongs_to :main
  end

  class Fourth < ActiveRecord::Base
    belongs_to :main
  end

  context "Main, with some others" do
    setup do
      @main = Main.create! :account_id => 1
      Other.create! :main_id => @main.id, :account_id => 1
      Other.create! :main_id => @main.id, :account_id => 2
      Other.create! :main_id => @main.id, :account_id => 1, :val => "foo"
    end

    should "set conditions on simple access" do
      assert_equal 2, @main.others.size
    end

    should "set conditions on find" do
      assert_equal 2, @main.others.find(:all).size
    end

    should "merge conditions on find" do
      assert_equal 1, @main.others.all(:conditions => "val = 'foo'").size
    end
  end

  def test_has_one_should_set_conditions_on_fetch
    main = Main.create! :account_id => 1
    third_1 = Third.create! :main_id => main.id, :account_id => 2
    third_2 = Third.create! :main_id => main.id, :account_id => 1
    assert_equal third_2, main.third
  end

  def test_has_many_should_set_conditions_for_multiple_inherits
    main = Main.create! :account_id => 1, :blah_id => 10
    # these two should match
    Fourth.create! :main_id => main.id, :account_id => 1, :blah_id => 10
    Fourth.create! :main_id => main.id, :account_id => 1, :blah_id => 10

    # nope.
    Fourth.create! :main_id => main.id, :account_id => 1, :blah_id => 5
    Fourth.create! :main_id => main.id, :account_id => 1, :blah_id => 12
    Fourth.create! :main_id => 99999, :account_id => 1, :blah_id => 12

    assert_equal(2, main.fourths.size)
  end

  def test_has_many_should_setup_attributes_when_building
    main = Main.create! :account_id => 1, :blah_id => 10

    other = main.others.build
    assert_equal main.id, other.main_id
    assert_equal main.account_id, other.account_id
  end

  def test_has_many_should_setup_attributes_when_creating
    main = Main.create! :account_id => 1, :blah_id => 10

    other = main.others.create!
    assert_equal main.id, other.main_id
    assert_equal main.account_id, other.account_id

    other = main.others.create
    assert_equal main.id, other.main_id
    assert_equal main.account_id, other.account_id
  end

  def test_has_one_should_setup_attributes_when_building
    main = Main.create! :account_id => 1, :blah_id => 10

    other = main.build_third
    assert_equal main.account_id, other.account_id

    other = main.create_third
    assert_equal main.account_id, other.account_id
  end

end
