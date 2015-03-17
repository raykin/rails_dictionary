# -*- coding: utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

module TestRailsDictionary

  class TestActiveRecordExtension < TestSupporter
    [:acts_as_dictionary, :acts_as_dict_consumer].each do |method_name|
      define_method "test_#{method_name}_exists_ar" do
        assert_includes ActiveRecord::Base.methods, method_name
      end
    end
  end

  class PreTestDatabase < TestSupporter

    def test_no_dictionary_data_exist_before
      assert_equal 0, Dictionary.count, 'dicionaries table should be blank'
    end
  end

  class TestInitSubDictClass < TestSupporter
    def setup
      super
      Dictionary.acts_as_dictionary
      if Dictionary.const_defined? 'City'
        Dictionary.send :remove_const, 'City'
        RailsDictionary.config.defined_type_class.delete('Dictionary::City')
      end
    end

    def test_dictionary_city_class_when_create_dictionary
      @shanghai = Dictionary.create!(name: "shanghai", type: 'Dictionary::City')
      assert Dictionary, Dictionary::City.superclass
    end

    def test_dictionary_city_class_when_assign_type
      beijing = Dictionary.new(name: 'beijing')
      beijing.type = 'Dictionary::City'
      beijing.save!
      assert Dictionary, Dictionary::City.superclass
    end

    def test_dictionary_city_class_when_assign_type_in_new
      beijing = Dictionary.new(name: 'beijing', type: 'Dictionary::City')
      beijing.save!
      assert Dictionary, Dictionary::City.superclass
    end

  end
end


class TestWithDB < TestSupporter
  def setup
    Dictionary.acts_as_dictionary
    @beijing = Dictionary.new(name: 'beijing', type: 'Dictionary::City')
    @beijing.save!

    @shanghai = Dictionary.create!(name: 'shanghai', type: 'Dictionary::City')

    @stu_beijing = Student.create! email: "beijing@dict.com", city_id: @shanghai.id
    @stu_shanghai = Student.create! email: "shanghai@dict.com", city_id: @shanghai.id
  end
end

class TestStudent < TestWithDB
  def setup
    Student.acts_as_dict_consumer on: [:city]
    super
  end

  def test_city_name_equal_to_exist_dictionary_name
    # assert_equal 1, Dictionary.where(name: "beijing").count
    # @stu_shanghai.update_attributes city_name: "beijing"
    # assert_equal 'beijing', @stu_shanghai.reload.city_name
    # assert_equal 1, Dictionary.where(name_en: "beijing").count
  end

end

# describe RailsDictionary do
#   let!(:dt_stu_city) { DictType.create! :name => "student_city" }
#   let!(:dt_stu_school) { DictType.create! :name => "student_school" }
#   let!(:dy_shanghai) { Dictionary.create! name_en: "shanghai",name_zh: "上海",name_fr: "shanghai", type: 'City' }
#   let!(:dy_beijing) { Dictionary.create! name_en: "beijing",name_zh: "北京",name_fr: "Pékin", type: 'City' }
#   let!(:stu_beijing) { Student.create! email: "beijing@dict.com",city_id: dy_beijing.id }
#   let!(:stu_shanghai) { Student.create! email: "shanghai@dict.com",city_id: dy_shanghai.id }

#     it "after one record removed" do
#       DictType.all_types
#       DictType.whole_types.should == [:student_city, :student_school]
#       dt_stu_school.destroy
#       DictType.all_types.should == [:student_city]
#       DictType.tab_and_column.should == Hash[:student,["city"]]
#     end
#   end

#   describe Dictionary do
#     it "should respond to student_city" do
#       Dictionary.should respond_to(:student_city)
#     end

#     it "generate student_city method" do
#       Dictionary.student_city.should == [dy_shanghai,dy_beijing]
#     end

#     it "generate student_city method with locale" do
#       Dictionary.student_city(:locale => :zh).should == [["北京", 2],["上海",1]]
#     end

#     it "build scope method scoped_student_city" do
#       Dictionary.scoped_student_city.class.name.should == "ActiveRecord::Relation"
#       Dictionary.scoped_student_city.where(:id => 1).should == [dy_shanghai]
#     end

#     it "after record added or removed" do
#       @dy_wuhan=Dictionary.create! name_en: "wuhan",name_zh: "武汉",name_fr: "wuhan",dict_type_id: dt_stu_city.id
#       Dictionary.student_city(:locale => :en).should == [["beijing", 2],["shanghai",1],["wuhan", 3]]
#       @dy_wuhan.destroy
#       Dictionary.student_city(:locale => :en).should == [["beijing", 2],["shanghai",1]]
#     end

#   end

#   describe Student do
#     before :each do
#       Student.acts_as_dict_slave
#     end

#     it "named_city with different locale" do
#       stu_shanghai.named_city(:en).should == "shanghai"
#       stu_shanghai.city_name(:en).should == "shanghai"
#       stu_shanghai.city_name.should == "shanghai"
#       stu_shanghai.named_city("").should == "shanghai"
#       stu_beijing.named_city(:fr).should == "Pékin"
#     end

#     it "update city by set city_name to a value" do
#       stu_shanghai.update_attributes city_name: "wuhan"
#       stu_shanghai.reload.city_name.should == "wuhan"
#       Dictionary.student_city.map(&:name_en).include?("wuhan").should be_true
#     end

#     it "update city by set city_name to an exist dictionary name" do
#       Dictionary.where(name_en: "beijing").count.should eq(1)
#       stu_shanghai.update_attributes city_name: "beijing"
#       stu_shanghai.reload.city_name.should eq('beijing')
#       Dictionary.where(name_en: "beijing").count.should eq(1)
#     end

#     it "create a student with shanghai city" do
#       s = Student.create(city_name: "shanghai")
#       s.reload
#       s.city_name.should == "shanghai"
#     end

#     it "override default locale" do
#       Student.acts_as_dict_slave :locale => :fr
#       stu_beijing.named_city.should == "Pékin"
#     end
#   end
# end
