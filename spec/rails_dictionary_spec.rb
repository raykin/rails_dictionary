# -*- coding: utf-8 -*-
require 'debugger'
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe RailsDictionary::ActiveRecordExtension do
  %w[acts_as_dict_type acts_as_dictionary acts_as_dict_slave].each do |method_name|
    it "contains #{method_name}" do
      ActiveRecord::Base.methods.include?(method_name.to_sym).should be_true
    end
  end
end

describe RailsDictionary do
  let!(:dt_stu_city) { DictType.create! :name => "student_city" }
  let!(:dt_stu_school) { DictType.create! :name => "student_school" }
  let!(:dy_shanghai) { Dictionary.create! name_en: "shanghai",name_zh: "上海",name_fr: "shanghai",dict_type_id: dt_stu_city.id }
  let!(:dy_beijing) { Dictionary.create! name_en: "beijing",name_zh: "北京",name_fr: "Pékin",dict_type_id: dt_stu_city.id }
  let!(:stu_beijing) { Student.create! email: "beijing@dict.com",city: dy_beijing.id }
  let!(:stu_shanghai) { Student.create! email: "shanghai@dict.com",city: dy_shanghai.id }

  describe DictType do
    it "parse model and method" do
      expected_hash={:student => %w[city school]}
      DictType.tab_and_column.should == expected_hash
    end

    it "all types" do
      DictType.all_types.should == [:student_city, :student_school]
    end

    it "reverts id to name or name to id" do
      DictType.revert(dt_stu_school.id).should == "student_school"
      DictType.revert(100).should be_nil
    end

    it "after one record removed" do
      dt_stu_school.destroy
      DictType.all_types.should == [:student_city]
      DictType.tab_and_column.should == Hash[:student,["city"]]
    end
  end

  describe Dictionary do
    it "should respond to student_city" do
      Dictionary.should respond_to(:student_city)
    end

    it "generate student_city method" do
      Dictionary.student_city.should == [dy_shanghai,dy_beijing]
    end

    it "generate student_city method with locale" do
      Dictionary.student_city(:locale => :zh).should == [["北京", 2],["上海",1]]
    end

    it "build scope method scoped_student_city" do
      Dictionary.scoped_student_city.class.name.should == "ActiveRecord::Relation"
      Dictionary.scoped_student_city.where(:id => 1).should == [dy_shanghai]
    end

    it "after record added or removed" do
      @dy_wuhan=Dictionary.create! name_en: "wuhan",name_zh: "武汉",name_fr: "wuhan",dict_type_id: dt_stu_city.id
      Dictionary.student_city(:locale => :en).should == [["beijing", 2],["shanghai",1],["wuhan", 3]]
      @dy_wuhan.destroy
      Dictionary.student_city(:locale => :en).should == [["beijing", 2],["shanghai",1]]
    end

  end

  describe Student do
    before :each do
      Student.acts_as_dict_slave
    end
    it "method of columns_in_dict_type and dict_columns" do
      Student.columns_in_dict_type.should == %w[city school]
      Student.dict_columns == %w[city school]
    end

    it "named_city with different locale" do
      stu_shanghai.named_city(:en).should == "shanghai"
      stu_shanghai.named_city("").should == "shanghai"
      stu_beijing.named_city(:fr).should == "Pékin"
    end

    it "override default locale" do
      Student.acts_as_dict_slave :locale => :fr
      stu_beijing.named_city.should == "Pékin"
    end
  end
end

describe Array do
  let(:an_array) { %w[root student_school student_city admin_role] }
  let(:expected_hash) { {:student => %w[school city],:admin => %w[role]} }
  let(:blank_hash) { Hash.new }
  it "extract to hash" do
    an_array.extract_to_hash(%w[student admin]).should == expected_hash
    an_array.extract_to_hash(%w[students]).should == blank_hash
  end
end
