# frozen_string_literal: true

require_relative 'helper'
require 'minitest/benchmark'

class Account < ActiveRecord::Base
end

class Foo < ActiveRecord::Base
  has_many :bars, -> { includes :bazs }, dependent: :destroy, inverse_of: :foo, inherit: :account_id
  belongs_to :account
end

class Bar < ActiveRecord::Base
  has_many :custom_bar_bazs, inherit: :account_id, inverse_of: :bar, class_name: "CustomBarBazs"
  has_many :bazs, through: :custom_bar_bazs, inherit: :account_id
  belongs_to :account
  belongs_to :foo, inherit: :account_id
end

class Baz < ActiveRecord::Base
  has_many :custom_bar_bazs, dependent: :destroy, inherit: :account_id, inverse_of: :baz, class_name: "CustomBarBazs"
  has_many :bars, through: :custom_bar_bazs, inherit: :account_id
  belongs_to :account
end

class CustomBarBazs < ActiveRecord::Base
  belongs_to :account
  belongs_to :bar
  belongs_to :baz
end

class TestPerformanceRegression < Minitest::Benchmark
  def self.bench_range
    bench_linear(1, 5, 1)
  end

  def setup
    skip unless ENV["CI"]
    super

    self.class.bench_range.each do |n|
      (n * 1000).times do
        account = Account.create!
        foo = Foo.create!(account_id: account.id, group_id: n)
        bar = foo.bars.create
        baz = bar.bazs.create
        CustomBarBazs.create!(bar_id: bar.id, baz_id: baz.id)
      end
    end
  end

  def bench_performance
    assert_performance_linear 0.98 do |n|
      Foo.where(group_id: n).includes(:bars).map(&:bars).size
    end
  end

  def teardown
    Account.destroy_all
    Foo.destroy_all
    Bar.destroy_all
    Baz.destroy_all
    CustomBarBazs.destroy_all

    super
  end
end
