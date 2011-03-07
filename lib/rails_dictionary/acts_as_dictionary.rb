module ActsAsDictionary
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def acts_as_dictionary
      belongs_to :dict_type
      after_save :delete_dicts_cache
      after_destroy :delete_dicts_cache

      # Return an instance of array
      def dict_type_name_eq(method_name)
        joins(:dict_type).where("dict_types.name" => method_name).all
      end
      #Following design is not successed with sqlite3 in test
      # scope :dict_type_name_eq,lambda {|method_name| joins(:dict_type).where("dict_types.name" => method_name)}
      # remove the all seems not pass test,return following errors
      # TypeError: no marshal_dump is defined for class SQLite3::Database
      include InstanceMethods
      # Generate methods like Dictionary.student_city
      # Dictionary.student_city - a list of dictionary object which dict type is student_city
      # Dictionary.student_city(:locale => :zh) - a select format array which can be used
      # in view method select as choice params
      # Is this design good?
      def self.method_missing(method_id,options={},&block)
        method_name=method_id.to_s.downcase
        if DictType.all_types.include? method_id.to_s
          Rails.cache.fetch("Dictionary.#{method_name}") { dict_type_name_eq(method_name) }
          listed_attr=Rails.cache.read("Dictionary.#{method_name}").dup
          # Instance of activerelation can not be dup?
          if options.keys.include? :locale or options.keys.include? "locale"
            locale="name_#{ options[:locale] }"
            listed_attr.map! { |a| [a.send(locale),a.id] }
            listed_attr.sort {|a,b| a.last <=> b.last } # maybe remove this line
          else
            listed_attr
          end
        else
          super
        end
      end

    end
  end

  module InstanceMethods
    def delete_dicts_cache
      method_name=DictType.revert(self.dict_type_id)
      Rails.cache.delete("Dictionary.#{method_name}")
      return true
    end
  end

end
ActiveRecord::Base.class_eval { include ActsAsDictionary }
