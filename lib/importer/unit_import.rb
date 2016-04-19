module Importer
  class UnitImport < ::Importer::Base
    def initialize(import)
      super

      @imported_units = Set.new
      @date_format ='%Y%m%d'
    end

    def before

    end

    def map_unit(unit)
      if sanitize_unit(unit_hash(unit))
        import(Unit::Rank, unit_finder_hash(unit), unit_hash(unit))
        @imported_units << unit.name
        print '.'
      end
    end

    def unit_hash(unit)
      {
        name:                 unit.name,
        key:                  unit.key,
        size:                 unit.size,
        pop_cost:             unit.population.to_f,
        resource_1:           unit.minerals,
        resource_2:           unit.gas,
        resource_3:           nil,
        hitpoints:            unit.hp.to_f,
        shield:               unit.shield.to_f,
        armor_value:          unit.armor,
        g_attack:             unit.g_attack,
        g_attack_dps:         nil,
        a_attack:             unit.a_attack,
        a_attack_dps:         nil,
        attack_cd:            unit.cooldown,
        attack_mod_1:         unit.attack_mod,
        attack_mod_2:         nil,
        ground_attack_range:  unit.range.to_f,
        air_attack_range:     unit.range.to_f,
        sight:                unit.sight.to_f,
        notes:                unit.notes,
        build_time:           unit.build_time,
        max_level:            3,
        # abilities:            nil,
        game:                 find_or_create_game(unit.game.try(:to_sym)),
        species:              find_or_create_species(unit.species.try(:to_sym)),
        armor:                find_or_create_armor(unit.armor_type.try(:to_sym))
      }
    end

    def find_or_create_game(game_key)
      return nil unless game_key.present?

      if Game.where(key: game_key).first.blank?
        Game.create!(key: game_key)
      end
      Game.where(key: game_key).first
    end

    def find_or_create_species(species_key)
      return nil unless species_key.present?

      if Species.where(key: species_key).first.blank?
        Species.create!(key: species_key)
      end
      Species.where(key: species_key).first
    end

    def find_or_create_armor(armor_key)
      return nil unless armor_key.present?

      if Armor.where(key: armor_key).first.blank?
        Armor.create!(key: armor_key)
      end
      Armor.where(key: armor_key).first
    end

    def unit_finder_hash(unit)
      {
        name: unit.name,
      }
    end

    def map_asset(item)
      # add image to the Unit::Base
    end

    def sanitize_unit(record)
      required_s = [:name, :hitpoints]
      sanitize_record(record, required_s, @import, :"Unit::Base")
    end

    def after
      Unit::Base.where(:name.nin => @imported_units.to_a).each { |c| c.delete }
    end
  end
end