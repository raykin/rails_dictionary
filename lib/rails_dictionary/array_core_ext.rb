class Array
  # Deprecated: the Array monkey-patch will be removed in a future major
  # release. The real logic now lives in RailsDictionary.extract_to_hash.
  def extract_to_hash(keys_array)
    RailsDictionary.deprecator.warn(
      "Array#extract_to_hash is deprecated; use RailsDictionary.extract_to_hash instead."
    )
    RailsDictionary.extract_to_hash(self, keys_array)
  end
end
