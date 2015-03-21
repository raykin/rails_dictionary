module RailsDictionary
  module ActiveRecordExtension
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def acts_as_dictionary

        # after_save :delete_dicts_cache
        # after_destroy :delete_dicts_cache
        # scope :dict_type_name_eq, lambda { |name| joins(:dict_type).where("dict_types.name" => name) }

        include ActsAsDictionary
        validates_uniqueness_of :name, scope: [inheritance_column]
      end

      # Ex: acts_as_dict_consumer on: :city
      #
      # on:         - add dict mapping columns, can be string or array of string
      # relation_type: - belongs_to/many_to_many, default is belongs_to. has_many Not supported yet
      # class_name: - Dictionary class name
      # locale:     - add and initialize class attribute default_dict_locale
      def acts_as_dict_consumer(opts={})
        include ActsAsDictConsumer
        # class_attribute :default_dict_locale, :instance_writer => false
        # cattr_accessor :dict_mapping_columns, :instance_writes => false

        case opts[:on]
        when Array
          opts[:on].each do |on_value|
            build_dict_relation(opts.merge(on: on_value))
          end
        when String, Symbol
          build_dict_relation(opts)
        else
          raise TypeError, 'Wrong value of params on'
        end
        # self.default_dict_locale = opts[:locale] if opts[:locale]
        # self.dict_mapping_columns = dict_columns(opts)
        # unless dict_mapping_columns.nil?
        #   add_dynamic_column_method
        # end
      end

    end
  end
end

::ActiveRecord::Base.send :include, RailsDictionary::ActiveRecordExtension
