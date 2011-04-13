module RailsDictionary
  module ActiveRecordExtension
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      #TODO: move macro define in each module file
      def acts_as_dict_type
        self.class_eval do
          has_many :dictionaries
          validates_uniqueness_of :name
          after_save :delete_all_caches
          after_destroy :delete_all_caches
        end
        include RailsDictionary::ActsAsDictType
      end

      def acts_as_dictionary
        self.class_eval do
          belongs_to :dict_type
          after_save :delete_dicts_cache
          after_destroy :delete_dicts_cache
        end
        include RailsDictionary::ActsAsDictionary
      end

      # :except - remove dict mapping column
      # :add - add dict mapping column
      # :locale - add and initialize class attribute default_dict_locale
      def acts_as_dict_slave(ops={})
        include RailsDictionary::ActsAsDictSlave
        class_attribute :default_dict_locale,:instance_writer => false
        cattr_accessor :dict_mapping_columns,:instance_writes => false
        self.default_dict_locale = ops[:locale] if ops[:locale]
        self.dict_mapping_columns = dict_columns(ops)
        unless dict_mapping_columns.nil?
          add_dynamic_column_method
        end
      end

    end
  end
end
