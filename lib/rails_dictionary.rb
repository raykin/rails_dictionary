require File.join(File.dirname(__FILE__), "rails_dictionary/models/active_record_extension")
require File.join(File.dirname(__FILE__), "rails_dictionary/models/acts_as_dictionary")
require File.join(File.dirname(__FILE__), "rails_dictionary/models/acts_as_dict_consumer")

# rake tasks not autoload in Rails4
Dir[File.expand_path('../tasks/**/*.rake',__FILE__)].each { |ext| load ext } if defined?(Rake)

module RailsDictionary

  def self.config
    Config.instance
  end

  class Config < Struct.new(:dictionary_klass, :defined_sti_klass)
    include Singleton
  end

  config.dictionary_klass = :Dictionary
  config.defined_sti_klass = []

  def self.dclass
    @dclass ||= config.dictionary_klass.to_s.constantize
  end

  def self.init_dict_sti_class(klass)
    unless config.defined_sti_klass.include?(klass) || Module.const_defined?(klass)
      subklass = klass.sub "#{config.dictionary_klass}::", ''
      dclass.const_set subklass, Class.new(dclass)
      config.defined_sti_klass.push(klass)
    end
  end
end
