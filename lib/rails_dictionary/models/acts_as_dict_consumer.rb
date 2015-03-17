module RailsDictionary
  module ActsAsDictConsumer
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # return columns that exist in DictType#tab_and_column
      # def columns_in_dict_type
      #   if ActiveRecord::VERSION::STRING < '3.1'
      #     DictType.tab_and_column[self.name.underscore.to_sym]
      #   elsif DictType.table_exists?
      #     DictType.tab_and_column[self.name.underscore.to_sym]
      #   else
      #     []
      #   end
      # end

      # columns which map to dictionary
      # def dict_columns(ops={})
      #   conf = { except: nil, add: nil}
      #   conf.update(ops)
      #   cidt = columns_in_dict_type || []
      #   cidt.delete(conf[:except])
      #   case conf[:add]
      #   when String
      #     cidt.push(conf[:add])
      #   when Array
      #     cidt.push(*conf[:add])
      #   else nil
      #   end
      #   cidt.uniq! || cidt
      # end

      # add a belongs_to(Dictionary) association and a named_{column} method
      # def add_dynamic_column_method
      #   dict_mapping_columns.each { |e| belongs_to "#{e}_dict".to_sym, class_name: "Dictionary", foreign_key: e.to_sym }
      #   dict_mapping_columns.each { |ele| named_dict_value ele.to_sym }
      #   dict_mapping_columns.each { |ele| dict_name_equal ele.to_sym }
      # end

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
      # end
      def dict_name_equal
        colname = @dict_relation_name
        method_name = "#{colname}_name="
        # define_method(method_name) do |value, options={}|
        #   # @opt[:class_name].constantize.find_by(name: )
        #   options.merge!(name_en: value)
        #   dict_type_id = DictType.revert("#{self.class.table_name.singularize}_#{colname}")
        #   options.merge!(dict_type_id: dict_type_id)
        #   exist_dictionary = Dictionary.where(options)
        #   if exist_dictionary.present?
        #     exist_id = exist_dictionary.first.id
        #   else
        #     exist_id = send("create_#{belongs_to_name}!", options).id
        #   end
        #   send "#{colname}=", exist_id
        # end
      end

      # dont think instance var is a good sollution
      # cause the consumer class will include other lib too
      def build_dict_relation(opt)
        @opt = opt
        @dict_relation_name = @opt.delete :on
        raise 'params on cant be nil' if @dict_relation_name.nil?
        @dict_relation_method = @opt.delete(:relation_type) || :has_one
        @opt[:foreign_key] ||= "#{@dict_relation_name}_id"
        @opt[:class_name] ||= "#{RailsDictionary.config.dictionary_klass}::#{@dict_relation_name.to_s.camelize}"
        ::RailsDictionary.init_dict_sti_class(@opt[:class_name])
        if @dict_relation_method.to_sym == :has_one
          send @dict_relation_method, @dict_relation_name, @opt
        elsif @dict_relation_method.to_sym == :many_to_many
          # no code required?
          # build_many_to_many_dict_relation
        end
        dict_name_equal
        # how support has_many in one column. actually has_many will the same as has_and_belongs_to_many
      end

    end # END ClassMethods

  end
end
