require File.expand_path('test_helper', File.dirname(__FILE__))

module TestLookup

  class TestAsDictionary < TestSupporter

    def initialize(opt)
      RailsDictionary.init_dict_class_for_test(:Lookup)
      super
    end

    def test_lookup
      art_tag = Lookup.create(name: 'art', type: 'Lookup::Tag')
      assert Lookup, Lookup::Tag.superclass
    end
  end
end
