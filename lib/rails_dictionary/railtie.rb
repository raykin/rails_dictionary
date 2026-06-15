module RailsDictionary
  class Railtie < Rails::Railtie
    # Generate the dynamic lookup methods after the app (and its autoloaded
    # models) are ready. The actual call is guarded in
    # RailsDictionary.load_dict_methods so a missing/unmigrated database
    # during boot, asset builds, or db:create never raises.
    config.to_prepare do
      RailsDictionary.load_dict_methods
    end
  end
end
