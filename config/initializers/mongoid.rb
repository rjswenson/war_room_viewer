path = Rails.root.join("config", "mongoid.yml")

if File.exists?(path) and Rails.env.development?
  conf = YAML.load(ERB.new(File.read(path)).result)[Rails.env]
  if conf && conf["sessions"]
    conf['sessions']['default'].store('database', "unit_viewer")

    # Connect if we got conf for our Rails.env, other wise use defaults
    Mongoid::Config.load_configuration(conf)
  end
end
