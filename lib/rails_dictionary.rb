# rake tasks not autoload in Rails4
Dir[File.expand_path('../tasks/**/*.rake',__FILE__)].each { |ext| load ext } if defined?(Rake)

module RailsDictionary
  # Models that called +acts_as_dictionary+. Stored by name so the registry
  # survives Zeitwerk reloads in development.
  def self.dictionary_model_names
    @dictionary_model_names ||= []
  end

  def self.register_dictionary_model(klass)
    return if klass.name.nil?
    dictionary_model_names << klass.name unless dictionary_model_names.include?(klass.name)
  end

  # Gem-specific deprecator so warnings can be silenced/raised independently
  # of the host app. Silenced by default: the removal version is not decided
  # yet, so we don't nag apps. Re-enable with
  # `RailsDictionary.deprecator.silenced = false`.
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new("a future major release", "rails_dictionary").tap do |deprecator|
      deprecator.silenced = true
    end
  end

  # Internal implementation of the (deprecated) Array#extract_to_hash, kept
  # here so the gem's own callers don't trip the deprecation warning.
  def self.extract_to_hash(array, keys_array)
    ret_hash = {}
    keys_array.each { |ky| ret_hash[ky.to_sym] = [] }
    array.each do |sf|
      keys_array.each do |ky|
        ret_hash[ky.to_sym] << sf.sub("#{ky}_", "") if sf =~ Regexp.new("^#{ky}_")
      end
    end
    ret_hash.reject { |_k, v| v.blank? }
  end

  # Regenerate the per-type lookup methods on every registered dictionary
  # model. Called whenever a DictType row changes.
  def self.reload_dict_methods
    dictionary_model_names.each do |name|
      klass = name.safe_constantize
      klass&.reload_dict_methods
    end
  end

  # Boot-time entry point (used by the Railtie). Guarded so a missing or
  # unmigrated database during boot, asset builds, or db:create never raises.
  def self.load_dict_methods
    reload_dict_methods if dict_table_ready?
  end

  # True only when the dict_types table can actually be queried. Used to guard
  # method generation so a missing/unmigrated database during boot, asset
  # builds, or db:create never raises.
  def self.dict_table_ready?
    ActiveRecord::Base.connection.table_exists?("dict_types")
  rescue ActiveRecord::NoDatabaseError,
         ActiveRecord::StatementInvalid,
         ActiveRecord::ConnectionNotEstablished
    false
  end
end

require File.join(File.dirname(__FILE__), "rails_dictionary/array_core_ext")

ActiveSupport.on_load :active_record do
  require File.join(File.dirname(__FILE__), "rails_dictionary/active_record_extension")
  require File.join(File.dirname(__FILE__), "rails_dictionary/acts_as_dict_type")
  require File.join(File.dirname(__FILE__), "rails_dictionary/acts_as_dictionary")
  require File.join(File.dirname(__FILE__), "rails_dictionary/acts_as_dict_slave")

  ::ActiveRecord::Base.send :include, RailsDictionary::ActiveRecordExtension
end

require File.join(File.dirname(__FILE__), "rails_dictionary/railtie") if defined?(Rails::Railtie)
