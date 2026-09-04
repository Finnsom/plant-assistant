require "yaml"

class PlantCareCatalog
  DATA_PATH = Rails.root.join("config/plant_care.yml")

  class << self
    def profiles
      @profiles ||= YAML.safe_load_file(DATA_PATH).values.freeze
    end

    def options
      profiles.map { |profile| [label(profile), profile.fetch("latin_name")] }
    end

    def find(species)
      return if species.blank?

      profiles.find do |profile|
        names_for(profile).any? { |name| name.casecmp?(species.strip) }
      end
    end

    def label(profile)
      "#{profile.fetch('latin_name')} - #{profile.fetch('common_name')}"
    end

    private

    def names_for(profile)
      [profile.fetch("latin_name"), profile.fetch("common_name"), *profile.fetch("aliases", [])]
    end
  end
end
