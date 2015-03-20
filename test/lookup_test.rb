require File.expand_path('test_helper', File.dirname(__FILE__))

module TestLookup

  class TestAsDictionary < TestSupporter

    def setup
      RailsDictionary.config.dictionary_klass = :Lookup
      Lookup.acts_as_dictionary
    end

    def test_lookup
      art_tag = Lookup.create(name: 'art', type: 'Lookup::Tag')
      assert Lookup, Lookup::Tag.superclass
    end
  end
end
