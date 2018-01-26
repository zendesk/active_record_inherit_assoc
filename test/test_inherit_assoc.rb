require_relative 'helper'

class TestInheritAssoc < ActiveSupport::TestCase
  class Main < ActiveRecord::Base
    has_many :others, :inherit => :account_id
    has_one :third, :inherit => :account_id
    has_many :fourths, :inherit => [:account_id, :blah_id]
    if ActiveRecord::VERSION::MAJOR < 4
      has_many :conditional_others, :inherit => :account_id, :conditions => {:val => "foo"}, :class_name => "Other"
    end
    has_many :fifths, :inherit => :account_id
    has_many :sixths, :through => :fifths, inherit: :account_id
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

  class Fifth < ActiveRecord::Base
    belongs_to :main, inherit: :account_id
    belongs_to :sixth, inherit: :account_id
  end

  class Sixth < ActiveRecord::Base
    belongs_to :main
  end

  describe "Main, with some others, scoped by account_id" do
    before do
      @main = Main.create! :account_id => 1
      Other.create! :main_id => @main.id, :account_id => 1
      Other.create! :main_id => @main.id, :account_id => 2
      Other.create! :main_id => @main.id, :account_id => 1, :val => "foo"
    end

    it "set conditions on simple access" do
      assert_equal 2, @main.others.size
    end

    if ActiveRecord::VERSION::MAJOR < 4
      it "set conditions on find" do
        assert_equal 2, @main.others.find(:all).size
      end

      it "merge conditions on find" do
        assert_equal 1, @main.others.all(:conditions => "val = 'foo'").size
      end

      it "merge conditions" do
        assert_equal 1, @main.conditional_others.size
      end
    else
      it "set conditions on find" do
        assert_equal 2, @main.others.all.size
      end

      it "merge conditions on find" do
        assert_equal 1, @main.others.all.where("val = 'foo'").size
      end

      it "merge conditions" do
        skip
        assert_equal 1, @main.conditional_others.size
      end
    end
  end

  def test_has_one_should_set_conditions_on_fetch
    main = Main.create! :account_id => 1
    Third.create! :main_id => main.id, :account_id => 2
    third_2 = Third.create! :main_id => main.id, :account_id => 1

    assert_equal third_2, main.third
  end

  def test_has_one_should_set_conditions_on_includes
    main = Main.create! :account_id => 1

    Third.create! :main_id => main.id, :account_id => 2
    third_2 = Third.create! :main_id => main.id, :account_id => 1

    mains = Main.where(id: main.id).includes(:third)

    assert_equal third_2, mains.first.third
  end

  def test_has_one_should_set_conditions_on_includes_with_multiple_owners
    main_1 = Main.create! :account_id => 1
    main_2 = Main.create! :account_id => 1

    Third.create! :main_id => main_1.id, :account_id => 2
    third_2 = Third.create! :main_id => main_1.id, :account_id => 1
    Third.create! :main_id => main_2.id, :account_id => 2
    third_4 = Third.create! :main_id => main_2.id, :account_id => 1

    mains = Main.where(id: [main_1.id, main_2.id]).includes(:third)

    assert_equal third_2, mains.first.third
    assert_equal third_4, mains.last.third
  end

  def test_has_many_through_should_set_conditions_on_join_table
    main_1 = Main.create! :account_id => 1
    main_2 = Main.create! :account_id => 1

    sixth_1 = Sixth.create! :main_id => main_1.id, :account_id => 1
    sixth_2 = Sixth.create! :main_id => main_1.id, :account_id => 1
    sixth_3 = Sixth.create! :main_id => main_1.id, :account_id => 1
    sixth_4 = Sixth.create! :main_id => main_1.id, :account_id => 1

    Fifth.create! :main_id => main_1.id, :account_id => 2, :sixth_id => sixth_1.id
    Fifth.create! :main_id => main_1.id, :account_id => 1, :sixth_id => sixth_2.id
    Fifth.create! :main_id => main_2.id, :account_id => 2, :sixth_id => sixth_3.id
    Fifth.create! :main_id => main_2.id, :account_id => 1, :sixth_id => sixth_4.id

    mains = Main.where(id: [main_1.id, main_2.id])
    assert_equal [sixth_2], mains.first.sixths
    assert_equal [sixth_4], mains.last.sixths
  end

  def test_has_many_should_set_conditions_on_includes
    main = Main.create! :account_id => 1, :blah_id => 10

    Fourth.create! :main_id => main.id, :account_id => 2, :blah_id => 10
    fourth_2 = Fourth.create! :main_id => main.id, :account_id => 1, :blah_id => 10

    mains = Main.where(id: main.id).includes(:fourths)

    assert_equal [fourth_2], mains.first.fourths
  end

  def test_has_many_should_set_conditions_on_includes_with_multiple_owners
    main_1 = Main.create! :account_id => 1, :blah_id => 10
    main_2 = Main.create! :account_id => 1, :blah_id => 20

    Fourth.create! :main_id => main_1.id, :account_id => 2, :blah_id => 10
    fourth_2 = Fourth.create! :main_id => main_1.id, :account_id => 1, :blah_id => 10
    Fourth.create! :main_id => main_2.id, :account_id => 2, :blah_id => 20
    fourth_4 = Fourth.create! :main_id => main_2.id, :account_id => 1, :blah_id => 20

    mains = Main.where(id: [main_1.id, main_2.id]).includes(:fourths)

    assert_equal [fourth_2], mains.first.fourths
    assert_equal [fourth_4], mains.last.fourths
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

  def test_association_caching_fail
    main_1 = Main.create!(account_id: 1)
    third_1 = Third.create!(main_id: main_1.id, account_id: 1)

    assert_equal third_1, main_1.third

    main_2 = Main.create!(account_id: 2)
    third_2 = Third.create!(main_id: main_2.id, account_id: 2)

    assert_equal third_2, main_2.third # this will fail, commenting out the previous assertion will make it pass.
  end
end
