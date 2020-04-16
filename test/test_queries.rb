require_relative 'helper'

class TestInheritAssocQueries < ActiveSupport::TestCase
  class Main < ActiveRecord::Base
    has_many :others, :inherit => :account_id
    has_one :third, :inherit => :account_id
    has_many :fourths, :inherit => [:account_id, :blah_id]
  end

  class Other < ActiveRecord::Base
    belongs_to :main, :inherit => :account_id
  end

  class Third < ActiveRecord::Base
    belongs_to :main, :inherit => :account_id
  end

  class Fourth < ActiveRecord::Base
    belongs_to :main, :inherit => :account_id
  end

  class Fifth < ActiveRecord::Base
    belongs_to :main, :inherit => :account_id
    belongs_to :sixth, :inherit => :account_id
  end

  class Sixth < ActiveRecord::Base
    belongs_to :main, :inherit => :account_id
  end

  describe 'generated sql queries' do
    let(:query) { Main.first }

    let(:queries) {
      capture_queries { query.to_a }
    }

    before do
      main = Main.create!(account_id: 100, blah_id: 200)
      Other.create!(main: main)
      Third.create!(main: main)
      Fourth.create!(main: main)
    end

    describe 'has_many' do
      describe 'loading a single record' do
        let(:query) { Main.first.others }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*others.\..account_id/i, queries.last
        end
      end

      describe 'preloading using .includes' do
        let(:query) { Main.includes(:others).all }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*others.\..account_id/i, queries.last
        end
      end

      describe 'preloading using .preload' do
        let(:query) { Main.all.preload(:others) }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*others.\..account_id/i, queries.last
        end
      end
    end

    describe 'has_one' do
      describe 'loading a single record' do
        let(:query) { Main.first.third }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*thirds.\..account_id/i, queries.last
        end
      end

      describe 'preloading using .includes' do
        let(:query) { Main.includes(:third).all }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*thirds.\..account_id/i, queries.last
        end
      end

      describe 'preloading using .preload' do
        let(:query) { Main.all.preload(:third) }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*thirds.\..account_id/i, queries.last
        end
      end
    end

    describe 'has_many with multiple inherits' do
      describe 'loading a single record' do
        let(:query) { Main.first.fourths }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*fourths.\..account_id/i, queries.last
          assert_match /WHERE.*fourths.\..blah_id/i, queries.last
        end
      end

      describe 'preloading using .includes' do
        let(:query) { Main.includes(:fourths).all }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*fourths.\..account_id/i, queries.last
          assert_match /WHERE.*fourths.\..blah_id/i, queries.last
        end
      end

      describe 'preloading using .preload' do
        let(:query) { Main.all.preload(:fourths) }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*fourths.\..account_id/i, queries.last
          assert_match /WHERE.*fourths.\..blah_id/i, queries.last
        end
      end
    end
  end
end
