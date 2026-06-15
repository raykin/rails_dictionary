require "active_support/concern"

module RailsDictionary
  module ActsAsDictionary
    extend ActiveSupport::Concern

    included do
      RailsDictionary.register_dictionary_model(self)
    end

    class_methods do

      # Define one singleton method per dict type, replacing the old
      # method_missing dispatch. Called at boot (Railtie) and whenever a
      # DictType row is written, so runtime-added categories stay available.
      #
      #   Dictionary.student_city               # => [<Dictionary>, ...]
      #   Dictionary.student_city(locale: :zh)  # => [["北京", 2], ...] for select
      def reload_dict_methods
        ::DictType.all_types.each { |name| define_dict_method(name) }
      end

      # List all distinct categories. Useful for admin UIs.
      def categories
        ::DictType.all_types
      end

      # Add an entry to a category. Returns the created record.
      #   Dictionary.add(:city, "New York")
      def add(category, name, attrs = {})
        dict_type_id = ::DictType.revert(category.to_s)
        create!(attrs.merge(name_en: name, dict_type_id: dict_type_id))
      end

      # Remove every entry in a category matching the given name.
      #   Dictionary.remove(:city, "New York")
      def remove(category, name)
        dict_type_id = ::DictType.revert(category.to_s)
        where(name_en: name, dict_type_id: dict_type_id).destroy_all
      end

      # Form-ready output for options_for_select: [[label, id], ...].
      #   Dictionary.options_for(:city, locale: :en)
      def options_for(category, locale: :en)
        public_send(category.to_s.downcase)
          .map { |d| [d.send("name_#{locale}"), d.id] }
          .reject { |pair| pair.first.nil? }
      end

      # Override this method to get customed sort block
      def sort_dicts(options)
        if options.keys.include? :locale or options.keys.include? "locale"
          locale="name_#{ options[:locale] }"
          if options[:locale].to_sym == :zh
            Proc.new { |a,b| a.send(locale).encode('GBK') <=> b.send(locale).encode('GBK') }
          else
            Proc.new { |a,b| a.send(locale).downcase <=> b.send(locale).downcase }
          end
        else
          false
        end
      end

      def dict_cache_key(name)
        "Dictionary.#{connection_db_config.database}.#{name}"
      end

      private

      def define_dict_method(method_id)
        method_name = method_id.to_s.downcase
        build_scope_method(method_id)
        define_singleton_method(method_name) do |options = {}|
          key = dict_cache_key(method_name)
          Rails.cache.delete(key) if options[:query]
          Rails.cache.fetch(key) { dict_type_name_eq(method_name).to_a }
          listed_attr = Rails.cache.read(key).dup
          if options.keys.include? :locale or options.keys.include? "locale"
            RailsDictionary.deprecator.warn(
              "Passing :locale to Dictionary.#{method_name} is deprecated; " \
              "use Dictionary.options_for(:#{method_name}, locale: ...) instead."
            )
            locale = "name_#{ options[:locale] }"
            sort_block = sort_dicts(options)
            listed_attr.sort!(&sort_block) if sort_block
            listed_attr.map! { |a| [a.send(locale), a.id] }.reject! { |ele| ele.first.nil? }
          end
          listed_attr
        end
      end

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

    end # End class_method

    def delete_dicts_cache
      method_name = ::DictType.revert(self.dict_type_id)
      Rails.cache.delete(self.class.dict_cache_key(method_name))
      return true
    end
  end
end
