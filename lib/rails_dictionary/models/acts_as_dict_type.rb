module RailsDictionary
  module ActsAsDictType
    def self.included(base)
      base.extend(ClassMethods)
      base.send :include,InstanceMethods
    end

    module ClassMethods

      def all_types
        Rails.cache.fetch("DictType.all_types") { all.map(&:name).map(&:to_sym) }.dup
      end

      def cached_all
        Rails.cache.fetch("DictType.cached_all") { all }.dup
      end

      # short method to transfer id to name or name to id
      def revert(arg)
        if arg.is_a?(String)
          DictType.where(name: arg).first.try(:id)
        elsif arg.is_a?(Fixnum)
          DictType.where(id: arg).first.try(:name)
        end
      end

      # TODO: get a more accurate method name
      #
      # Parse the name value to get which column and model are listed in DictType
      #
      # Programmer DOC:
      #   There are two chooses to get subclass,one is subclasses the other is descendants,
      #   I don't know which is better,but descendants contains subclass of subclass,it contains more.
      #   Class like +Ckeditor::Asset+ transfer to "ckeditor/asset",but we can not naming method like that,
      #   So it still not support, the solution may be simple,just make another convention to escape "/"
      # TODO:
      #   To cache this method output need more skills on how to caculate ActiveRecord::Base.descendants
      #   Temply remove the cache
      #   And add test for this situation
      def tab_and_column
        #Rails.cache.fetch("DictType.tab_and_column") do
          all_model_class=ActiveRecord::Base.descendants.map(&:name).map(&:underscore)
          all_types.map(&:to_s).extract_to_hash(all_model_class)
        #end
      end
    end

    module InstanceMethods
      def delete_all_caches
        Rails.cache.delete("DictType.all_types")
        Rails.cache.delete("DictType.cached_all")
        #Rails.cache.delete("DictType.tab_and_column")
        return true
      end
    end

  end
end
