module RailsDictionary
  module ActsAsDictionary
    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    end

    module ClassMethods

      def new(opts)
        type_opt = opts.with_indifferent_access[inheritance_column]
        RailsDictionary.init_dict_sti_class(type_opt) if type_opt
        super
      end

      # For rails3
      # I thought it would be better to define a method in method_missing, Not just generate cache.
      #   Cause cache can not store ActiveRecord
      # Generate methods like Dictionary.student_city
      #   Dictionary.student_city - a list of dictionary object which dict type is student_city
      #   Dictionary.student_city(:locale => :zh) - a select format array which can be used
      #   in view method select as choice params
      # Programmer DOC && TODO:
      #   rethink about the cache.
      #   cache methods like Dictionary.student_city(:locale => :zh,:sort => :name_fr)
      #   but not cache Dictionary.student_city, return it as relation
      #
      #   Remove nil noise,if listed_attr =[[nil, 201], [nil, 203], [nil, 202], ["Sciences", 200]]
      #   the sort would be failed of ArgumentError: comparison of Array with Array failed
      #   split this method ,make it more short and maintainance
      # def method_missing(method_id,options={})
      #   if DictType.all_types.include? method_id
      #     method_name=method_id.to_s.downcase
      #     # TODO: If cache engine is failed, then the code will failed with null cant dup
      #     Rails.cache.fetch("Dictionary.#{method_name}") { dict_type_name_eq(method_name).to_a }
      #     listed_attr=Rails.cache.read("Dictionary.#{method_name}").dup  # Instance of ActiveRecord::Relation can not be dup?
      #     build_scope_method(method_id)
      #     if options.keys.include? :locale or options.keys.include? "locale"
      #       locale="name_#{ options[:locale] }"
      #       sort_block=sort_dicts(options)
      #       listed_attr.sort!(&sort_block) if sort_block
      #       listed_attr.map! { |a| [a.send(locale),a.id] }.reject! {|ele| ele.first.nil?}
      #     end
      #     listed_attr
      #   else
      #     super
      #   end
      # end

      # # Override this method to get customed sort block
      # def sort_dicts(options)
      #   if options.keys.include? :locale or options.keys.include? "locale"
      #     locale="name_#{ options[:locale] }"
      #     if options[:locale].to_sym == :zh
      #       Proc.new { |a,b| a.send(locale).encode('GBK') <=> b.send(locale).encode('GBK') }
      #     else
      #       Proc.new { |a,b| a.send(locale).downcase <=> b.send(locale).downcase }
      #     end
      #   else
      #     false
      #   end
      # end

      # def respond_to?(name, include_private=false)
      #   DictType.all_types.include?(name) || super
      # end

      private

      def build_scope_method(name)
        scope_method_name = "scoped_#{name}".to_sym
        unless respond_to? scope_method_name
          define_singleton_method scope_method_name do
            # see http://stackoverflow.com/questions/18198963/with-rails-4-model-scoped-is-deprecated-but-model-all-cant-replace-it
            # for usage of where(nil)
            dict_type_name_eq(name).where(nil)
          end
        end
      end

    end # End ClassMethods

    module InstanceMethods
      def delete_dicts_cache
        method_name=DictType.revert(self.dict_type_id)
        Rails.cache.delete("Dictionary.#{method_name}")
        return true
      end

      def type=(name)
        ::RailsDictionary.init_dict_sti_class(name)
        super
      end
    end # End InstanceMethods

  end
end
