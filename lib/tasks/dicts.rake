# -*- coding: utf-8 -*-
namespace :dicts do
  desc "Generate dictionary and dict_type model"
  task :generate do
    system "rails g model dictionary name_en:string name_zh:string name_fr:string dict_type_id:integer"
    system "rails g model dict_type name:string"
  end
  desc "Generate student model"
  task :sample_slave do
    system "rails g model student email:string city:integer school:integer"
  end
  desc "Generate sample data for rails_dictionary gem"
  task :sample_data => [:environment] do
    @dt_stu_city=DictType.create! :name => "student_city"
    @dt_stu_school=DictType.create! :name => "student_school"
    @dy_shanghai=Dictionary.create! name_en: "shanghai",name_zh: "上海",name_fr: "shanghai",dict_type_id: @dt_stu_city.id
    @dy_beijing=Dictionary.create! name_en: "beijing",name_zh: "北京",name_fr: "Pékin",dict_type_id: @dt_stu_city.id
    @stu_beijing=Student.create! email: "beijing@dict.com",city: @dy_beijing.id
    @stu_shanghai=Student.create! email: "shanghai@dict.com",city: @dy_shanghai.id
  end
end
