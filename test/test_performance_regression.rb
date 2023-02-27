# frozen_string_literal: true

require_relative 'helper'
require 'benchmark'

class Account < ActiveRecord::Base
end

class Foo < ActiveRecord::Base # ticket_form
  has_many :bars, -> { includes :bazs }, dependent: :destroy, inverse_of: :foo, inherit: :account_id
  belongs_to :account
end

class Bar < ActiveRecord::Base # ticket_field_condition
  has_many :custom_bar_bazs, inherit: :account_id, inverse_of: :bar, class_name: "CustomBarBazs"
  has_many :bazs, through: :custom_bar_bazs, inherit: :account_id
  belongs_to :account
  belongs_to :foo, inherit: :account_id
end

class Baz < ActiveRecord::Base # custom_status
  has_many :custom_bar_bazs, dependent: :destroy, inherit: :account_id, inverse_of: :baz, class_name: "CustomBarBazs"
  has_many :bars, through: :custom_bar_bazs, inherit: :account_id
  belongs_to :account
end

class CustomBarBazs < ActiveRecord::Base #ticket_field_condition_custom_status
  belongs_to :account
  belongs_to :bar
  belongs_to :baz
end

class TestPerformanceRegression < ActiveSupport::TestCase

  describe "Performance regression" do
    before do
      1000.times do
        account = Account.create!
        foo = Foo.create!(account_id: account.id)
        bar = foo.bars.create
        baz = bar.bazs.create
        custom_bar_baz = CustomBarBazs.create!(bar_id: bar.id, baz_id: baz.id)
      end
    end

    after do
      Account.destroy_all
      Foo.destroy_all
      Bar.destroy_all
      Baz.destroy_all
      CustomBarBazs.destroy_all
    end

    it "can load the bars on foo" do
      t = Benchmark.realtime do
        @queries = capture_queries {
          p Foo.all.includes({
                             bars: {
                               bazs: {}
                             }})
            .flat_map(&:bars)
            .flat_map(&:bazs)
            .size
        }
      end

      puts "Time #{t}"

      # pp @queries

      assert @queries
    end
  end
end
