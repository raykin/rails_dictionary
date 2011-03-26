module ActsAsDictType
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_dict_type(ops={})
      self.class_eval do
        has_many :dictionaries
        include InstanceMethods
        validates_uniqueness_of :name
        after_save :delete_all_caches
        after_destroy :delete_all_caches

        def self.all_types
          Rails.cache.fetch("DictType.all_types") { all.map(&:name) }.dup
        end

        def self.cached_all
          Rails.cache.fetch("DictType.cached_all") { all }.dup
        end

        # short method to transfer id to name or name to id
        def self.revert(arg)
          if arg.is_a?(String)
            DictType.where(name: arg).first.try(:id)
          elsif arg.is_a?(Fixnum)
            DictType.where(id: arg).first.try(:name)
          end
        end

        # TODO: get a more accurate method name
        # Parse the name value to get which column and model are listed in DictType
        def self.tab_and_column
          tab_and_column={}
          # There are two chooses,one is subclasses the other is descendants,
          # I don't know which is better,but descendants contains subclass of subclass,it contains more.
          # Class like +Ckeditor::Asset+ transfer to "ckeditor/asset",but we can not naming method like that,
          # So it still not support, the solution may be simple,just make another convention to escape "/"
          all_model_class=ActiveRecord::Base.descendants.map(&:name).map(&:underscore)
          tab_and_column=all_types.extract_to_hash(all_model_class)
        end
      end
    end

    module InstanceMethods
      def delete_all_caches
        Rails.cache.delete("DictType.all_types")
        Rails.cache.delete("DictType.cached_all")
        return true
      end
    end

  end
end
ActiveRecord::Base.class_eval { include ActsAsDictType  }
