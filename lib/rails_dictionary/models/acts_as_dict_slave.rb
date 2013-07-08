module RailsDictionary
  module ActsAsDictSlave
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # return columns that exist in DictType#tab_and_column
      def columns_in_dict_type
        if ActiveRecord::VERSION::STRING < '3.1'
          DictType.tab_and_column[self.name.underscore.to_sym]
        elsif DictType.table_exists?
          DictType.tab_and_column[self.name.underscore.to_sym]
        else
          []
        end
      end

      # columns which map to dictionary
      def dict_columns(ops={})
        conf = { except: nil, add: nil}
        conf.update(ops)
        cidt = columns_in_dict_type || []
        cidt.delete(conf[:except])
        case conf[:add]
        when String
          cidt.push(conf[:add])
        when Array
          cidt.push(*conf[:add])
        else nil
        end
        cidt.uniq! || cidt
      end

      # add a belongs_to(Dictionary) association and a named_{column} method
      def add_dynamic_column_method
        dict_mapping_columns.each { |e| belongs_to "#{e}_dict".to_sym, class_name: "Dictionary", foreign_key: e.to_sym }
        dict_mapping_columns.each { |ele| named_dict_value ele.to_sym }
        dict_mapping_columns.each { |ele| dict_name_equal ele.to_sym }
      end

      # Generate dynamic instance method named_column to consumer model
      # def named_city(locale=nil)
      #   locale = locale.presence || default_dict_locale.presence || :en
      #   locale = "name_#{locale}"
      #   self.send(city_dict).try(:send,locale)
      # end
      # alias_method :city_name, :named_city
      def named_dict_value(method_name)
        belongs_to_name="#{method_name}_dict".to_sym
        origin_method_name = method_name
        method_name="named_#{method_name}"
        define_method(method_name) do | locale=nil |
          locale = locale.presence || default_dict_locale.presence || :en
          locale = "name_#{locale}"
          self.send(belongs_to_name).try(:send,locale)
        end
        alias_method "#{origin_method_name}_name".to_sym, method_name.to_sym
      end

      # Build dynamic method column_name= to the consumer model
      #
      # def city_name=(value, options = {})
      #
      #
      # end
      def dict_name_equal(colname)
        method_name = "#{colname}_name="
        belongs_to_name="#{colname}_dict".to_sym
        define_method(method_name) do |value, options={}|
          options.merge!(name_en: value)
          dict_type_id = DictType.revert("#{self.class.table_name.singularize}_#{colname}")
          exist_dictionary = Dictionary.where(options).where(dict_type_id: dict_type_id)
          if exist_dictionary.present?
            exist_id = exist_dictionary.first.id
          else
            exist_id = send("create_#{belongs_to_name}!", options).id
          end
          send "#{colname}=", exist_id
        end
      end

    end # END ClassMethods

  end
end
