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

  describe 'generated sql queries' do
    let(:query) { Main.first }

    let(:queries) {
      capture_queries { query.to_a }
    }

    before do
      Main.delete_all
      Other.delete_all
      Third.delete_all
      Fourth.delete_all

      main = Main.create!(account_id: 100, blah_id: 200)
      Other.create!(main: main, account_id: 100)
      Third.create!(main: main, account_id: 100)
      Fourth.create!(main: main, account_id: 100, blah_id: 200)
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

        describe 'loading many records with different values for the inherited association' do
          before do
            main = Main.create!(account_id: 777, blah_id: 999)
            Other.create!(main: main, account_id: 777)
          end

          it 'correctly maps based on inherited association' do
            results = query.to_a

            subsequent_queries = capture_queries do
              results.each do |main|
                others = main.others.to_a

                assert_equal 1, others.size
                assert_equal main.account_id, others.first.account_id
              end
            end

            assert_equal 0, subsequent_queries.size
          end
        end
      end

      describe 'preloading using .preload' do
        let(:query) { Main.all.preload(:others) }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*others.\..account_id/i, queries.last
        end

        describe 'loading many records with different values for the inherited association' do
          before do
            main = Main.create!(account_id: 777, blah_id: 999)
            Other.create!(main: main, account_id: 777)
          end

          it 'correctly maps based on inherited association' do
            results = query.to_a

            subsequent_queries = capture_queries do
              results.each do |main|
                others = main.others.to_a

                assert_equal 1, others.size
                assert_equal main.account_id, others.first.account_id
              end
            end

            assert_equal 0, subsequent_queries.size
          end
        end
      end
    end

    describe 'has_one' do
      describe 'loading a single record' do
        let(:query) { Main.first.third }

        let(:queries) {
          capture_queries { query }
        }

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

        describe 'loading many records with different values for the inherited association' do
          before do
            main = Main.create!(account_id: 777, blah_id: 999)
            Third.create!(main: main, account_id: 777)
          end

          it 'correctly maps based on inherited association' do
            results = query.to_a

            subsequent_queries = capture_queries do
              results.each do |main|
                assert_equal main.account_id, main.third.account_id
              end
            end

            assert_equal 0, subsequent_queries.size
          end
        end
      end

      describe 'preloading using .preload' do
        let(:query) { Main.preload(:third).all }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*thirds.\..account_id/i, queries.last
        end

        describe 'loading many records with different values for the inherited association' do
          before do
            main = Main.create!(account_id: 777, blah_id: 999)
            Third.create!(main: main, account_id: 777)
          end

          it 'correctly maps based on inherited association' do
            results = query.to_a

            subsequent_queries = capture_queries do
              results.each do |main|
                assert_equal main.account_id, main.third.account_id
              end
            end

            assert_equal 0, subsequent_queries.size
          end
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

        describe 'loading many records with different values for the inherited association' do
          before do
            main = Main.create!(account_id: 777, blah_id: 999)
            Fourth.create!(main: main, account_id: 777, blah_id: 999)
          end

          it 'correctly maps based on inherited association' do
            results = query.to_a

            subsequent_queries = capture_queries do
              results.each do |main|
                fourths = main.fourths.to_a

                assert_equal 1, fourths.size
                assert_equal main.account_id, fourths.first.account_id
              end
            end

            assert_equal 0, subsequent_queries.size
          end
        end
      end

      describe 'preloading using .preload' do
        let(:query) { Main.all.preload(:fourths) }

        it 'correctly inherits' do
          assert_equal 2, queries.size
          assert_match /WHERE.*fourths.\..account_id/i, queries.last
          assert_match /WHERE.*fourths.\..blah_id/i, queries.last
        end

        describe 'loading many records with different values for the inherited association' do
          before do
            main = Main.create!(account_id: 777, blah_id: 999)
            Fourth.create!(main: main, account_id: 777, blah_id: 999)
          end

          it 'correctly maps based on inherited association' do
            results = query.to_a

            subsequent_queries = capture_queries do
              results.each do |main|
                fourths = main.fourths.to_a

                assert_equal 1, fourths.size
                assert_equal main.account_id, fourths.first.account_id
              end
            end

            assert_equal 0, subsequent_queries.size
          end
        end
      end
    end
  end
end
