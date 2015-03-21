module RailsDictionary
  module ActsAsDictConsumer
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Generate dynamic instance method named_column to consumer model
      # def named_city(locale=nil)
      #   locale = locale.presence || default_dict_locale.presence || :en
      #   locale = "name_#{locale}"
      #   self.send(city_dict).try(:send,locale)
      # end
      # alias_method :city_name, :named_city
      # def named_dict_value(method_name)
      #   belongs_to_name="#{method_name}_dict".to_sym
      #   origin_method_name = method_name
      #   method_name="named_#{method_name}"
      #   define_method(method_name) do | locale=nil |
      #     locale = locale.presence || default_dict_locale.presence || :en
      #     locale = "name_#{locale}"
      #     self.send(belongs_to_name).try(:send,locale)
      #   end
      #   alias_method "#{origin_method_name}_name".to_sym, method_name.to_sym
      # end

      # Build dynamic method column_name= to the consumer model
      #
      # ex:
      #   def city_name=(value, options = {})
      #     send "city=", dictionary_obj
      #   end
      def dict_name_equal
        relation_name = @dict_relation_name
        relation_method = @dict_relation_method
        method_name = "#{relation_name}_name="
        class_opt = @opt
        define_method(method_name) do |value, options={}|
          dicts = RailsDictionary.dclass.where(name: Array(value), type: class_opt[:class_name])
          if dicts
            if relation_method == :belongs_to
              send "#{relation_name}=", dicts.first
            elsif relation_method == :many_to_many
              send "#{relation_name}=", dicts.map(&:id)
            else
              raise "Wrong relation method name: #{relation_method}"
            end
          else
            # do nothing ?
          end
        end
      end

      # dont think instance var is a good sollution
      # cause the consumer class will include other lib too
      def build_dict_relation(opt)
        @opt = opt
        @dict_relation_name = @opt.delete :on
        raise 'params on cant be nil' if @dict_relation_name.nil?
        @dict_relation_method = @opt.delete(:relation_type) || :belongs_to
        # @opt[:foreign_key] ||= "#{@dict_relation_name}_id"
        @opt[:class_name] ||= "#{RailsDictionary.config.dictionary_klass}::#{@dict_relation_name.to_s.singularize.camelize}"
        ::RailsDictionary.init_dict_sti_class(@opt[:class_name])
        if @dict_relation_method.to_sym == :belongs_to
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
