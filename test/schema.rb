ActiveRecord::Schema.define(:version => 1) do
  drop_table(:mains) rescue nil
  create_table "mains" do |t|
    t.integer :account_id
    t.integer :blah_id
    t.string   "val"
  end

  drop_table(:others) rescue nil
  create_table "others" do |t|
    t.integer :main_id
    t.integer :account_id
    t.string  :val
  end

  drop_table(:thirds) rescue nil
  create_table "thirds" do |t|
    t.integer :main_id
    t.integer :account_id
  end

  drop_table(:fourths) rescue nil
  create_table "fourths" do |t|
    t.integer :main_id
    t.integer :account_id
    t.integer :blah_id
  end

  drop_table(:fifths) rescue nil
  create_table "fifths" do |t|
    t.integer :main_id
    t.integer :account_id
    t.integer :sixth_id
  end

  drop_table(:sixths) rescue nil
  create_table "sixths" do |t|
    t.integer :main_id
    t.integer :account_id
    t.integer :seventh_id
  end

  drop_table(:sevenths) rescue nil
  create_table "sevenths" do |t|
    t.integer :main_id
    t.integer :account_id
  end
end
