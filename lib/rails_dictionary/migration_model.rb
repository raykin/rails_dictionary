# no doc. no test.
module RailsDictionary
  class MigrationModel < ActiveRecord::Base
    self.abstract_class = true
    def self.target_dict_subclass
      name.sub('Origin', '')
    end

    def self.inherited(subclass)
      subclass.table_name = subclass.target_dict_subclass.tableize
      super
    end

    def self.migrate_to_dictionary(attr_from: :name)
      @dict_mapping = {}
      find_each do |origin_record|
        dict = RailsDictionary.dclass.find_or_initialize_by(name: origin_record.send(attr_from), type: target_dict_subclass)
        yield(origin_record, dict) if block_given?
        dict.save!
        @dict_mapping[origin_record.id] = dict.id
      end
      @dict_mapping
    end

    def self.migrate_relation_data(relation_class)
      foreign_key = target_dict_subclass.foreign_key.to_sym
      relation_class.find_each do |record|
        record.update_column foreign_key, @dict_mapping[record.send foreign_key]
      end
    end
  end
end
