module RailsDictionary
  module ActsAsDictionary
    def self.included(base)
      base.extend(ClassMethods)
      base.send :include,InstanceMethods
    end

    module ClassMethods

      # Return an instance of array
      # Programmer DOC:
      #   Following design is failed with sqlite3 in test
      #   scope :dict_type_name_eq,lambda {|method_name| joins(:dict_type).where("dict_types.name" => method_name)}
      #   remove the all seems not pass test,return following errors
      #   TypeError: no marshal_dump is defined for class SQLite3::Database
      def dict_type_name_eq(method_name)
        joins(:dict_type).where("dict_types.name" => method_name).all
      end

      # Generate methods like Dictionary.student_city
      #   Dictionary.student_city - a list of dictionary object which dict type is student_city
      #   Dictionary.student_city(:locale => :zh) - a select format array which can be used
      #   in view method select as choice params
      # Programmer DOC && TODO:
      #   rethink about the cache.
      #   cache methods like Dictionary.student_city(:locale => :zh,:sort => :name_fr)
      #   but not cache Dictionary.student_city,return it as relation
      #
      #   Remove nil noise,if listed_attr =[[nil, 201], [nil, 203], [nil, 202], ["Sciences", 200]]
      #   the sort would be failed of ArgumentError: comparison of Array with Array failed
      #   split this method ,make it more short and maintainance
      def method_missing(method_id,options={})
        method_name=method_id.to_s.downcase
        if DictType.all_types.include? method_id
          Rails.cache.fetch("Dictionary.#{method_name}") { dict_type_name_eq(method_name) }
          listed_attr=Rails.cache.read("Dictionary.#{method_name}").dup
          # Instance of activerelation can not be dup?
          if options.keys.include? :locale or options.keys.include? "locale"
            locale="name_#{ options[:locale] }"
            listed_attr.map! { |a| [a.send(locale),a.id] }.reject! {|ele| ele.first.nil?}
            listed_attr.sort { |a,b| a.first.downcase <=> b.first.downcase }
            # maybe remove the above line,or change some sorting and caching design
          else
            listed_attr
          end
        else
          super
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
end
