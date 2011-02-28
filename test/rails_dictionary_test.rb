# -*- coding: utf-8 -*-
# min test
require "test/unit"
require "active_support"
require "active_record"
require "ruby-debug"
Object.const_set "RAILS_CACHE", ActiveSupport::Cache.lookup_store
require "active_support/cache"
require "rails"
# $: << "/home/raykin/studio/dictionary/lib" # tmply added for local testing
require "#{File.dirname(__FILE__)}/../lib/rails_dictionary.rb"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

$stdout = StringIO.new

def setup_db
  ActiveRecord::Base.logger
  ActiveRecord::Schema.define(:version => 1) do
    create_table :dict_types do |t|
      t.string :name
      t.string :comment
      t.timestamps
    end
    create_table :dictionaries do |t|
      t.string :name_en
      t.string :name_zh
      t.string :name_fr
      t.integer :dict_type_id
      t.timestamps
    end
    create_table :students do |t|
      t.string :email
      t.integer :city
      t.integer :school
      t.timestamps
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class DictType < ActiveRecord::Base
  acts_as_dict_type
end

class Dictionary < ActiveRecord::Base
  acts_as_dictionary
end

class Student < ActiveRecord::Base
end


class CoreExtTest < Test::Unit::TestCase
  def test_array
    expected_hash={:student => %w[school city],:admin => %w[role]}
    assert_equal expected_hash, %w[student_school student_city admin_role].extract_to_hash(%w[student admin])
    assert_equal expected_hash, %w[root student_school student_city admin_role].extract_to_hash(%w[student admin])
  end
end

class DictTypeTest < Test::Unit::TestCase
  def setup
    setup_db
    #Object.const_set('Student',Class.new(ActiveRecord::Base))
    @dt_stu_city=DictType.create! :name => "student_city"
    @dt_stu_school=DictType.create! :name => "student_school"
    @dy_shanghai=Dictionary.create! name_en: "shanghai",name_zh: "上海",name_fr: "shanghai",dict_type_id: @dt_stu_city.id
    @dy_beijing=Dictionary.create! name_en: "beijing",name_zh: "北京",name_fr: "Pékin",dict_type_id: @dt_stu_city.id
    @stu_beijing=Student.create! email: "beijing@dict.com",city: @dy_beijing.id
    @stu_shanghai=Student.create! email: "shanghai@dict.com",city: @dy_shanghai.id
    Student.acts_as_dict_slave
    # the acts_as_dict_slave need real data to generate dynamic method
  end

  def teardown
    teardown_db
  end

  def test_tab_and_column
    expected_hash={:student => %w[city school]}
    assert_equal expected_hash,DictType.tab_and_column
  end

  def test_all_types
    assert_equal %w[student_city student_school],DictType.all_types
  end

  # test revert method in acts_as_dict_type
  def test_dt_revert
    assert_equal "student_school",DictType.revert(@dt_stu_school.id)
  end

  def test_dictionary_method_missing
    assert_equal [["shanghai",1],["beijing",2]],Dictionary.student_city(:locale => :en)
  end

  def test_dictionary_method_missing_with_locale
    assert_equal [["上海", 1], ["北京", 2]],Dictionary.student_city(:locale => :zh)
  end

  # test dynamic instance methods in slave model
  def test_named_city
    assert_equal %w[city school],Student.columns_in_dict_type
    assert_equal %w[city school],Student.dict_columns
    assert_equal "shanghai",@stu_shanghai.named_city(:en)
    assert_equal "Pékin",@stu_beijing.named_city(:fr)
  end

  def test_delete_dicts_cache
    @dy_wuhan=Dictionary.create! name_en: "wuhan",name_zh: "武汉",name_fr: "wuhan",dict_type_id: @dt_stu_city.id
    assert_equal [["shanghai", 1], ["beijing", 2], ["wuhan", 3]],Dictionary.student_city(:locale => :en)
    @dy_wuhan.destroy
    assert_equal [["shanghai", 1], ["beijing", 2]],Dictionary.student_city(:locale => :en)
    assert_equal [@dy_shanghai,@dy_beijing],Dictionary.student_city
  end

  def test_delete_all_caches
    assert_equal %w[student_city student_school],DictType.all_types
    @dt_stu_school.destroy
    assert_equal %w[student_city],DictType.all_types
  end

end
