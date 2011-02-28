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
            DictType.where(name: arg).try(:first).id
          elsif arg.is_a?(Fixnum)
            DictType.where(id: arg).try(:first).name
          end
        end

        # TODO: get a more accurate method name
        # parse the name to get which column and model are listed in DictType
        def self.tab_and_column
          @tab_and_column={}
          @all_types=all_types
          # TODO: any better way to retrive the class name in app/model ?
          # Here maybe a problem when class like Ckeditor::Asset(.name.underscore => "ckeditor/asset"
          all_tabs=ActiveRecord::Base.connection.tables.sort.reject! do |t|
            ['schema_migrations', 'sessions'].include?(t)
          end
          all_class=all_tabs.map(&:singularize)
          all_tabs=all_class
          @tab_and_column=@all_types.extract_to_hash(all_tabs)
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
