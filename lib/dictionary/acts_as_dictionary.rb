module ActsAsDictionary
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_dictionary
      self.class_eval do
        include InstanceMethods
        belongs_to :dict_type
        after_save :delete_dicts_cache
        after_destroy :delete_dicts_cache

        # TODO: need to add more function
        def self.method_missing(method_id,options={},&block)
          method_name=method_id.to_s.downcase
          if DictType.all_types.include? method_id.to_s
            Rails.cache.fetch("Dictionary.#{method_name}") { Dictionary.joins(:dict_type).where('dict_types.name'=>method_name).all }
            listed_attr=Rails.cache.read("Dictionary.#{method_name}").dup
            if options.keys.include? :locale
              locale="name_#{options[:locale]}"
              listed_attr.map! { |a| [a.send(locale),a.id] }
              listed_attr.sort {|a,b| a.last <=> b.last } # maybe remove this one
            else
              listed_attr
            end
          else
            super
          end
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
