module Import
  class UnitImport < ::Import::Base
    def initialize(import)
      super

      @imported_units = Set.new
      @date_format ='%Y%m%d'
    end

    def before

    end

    def map_unit(unit)
      if sanitize_unit(unit_hash(unit))
        import(Unit::Base, unit_finder_hash(unit), unit_hash(unit))
        @imported_units << unit.name
      end
    end

    def unit_hash(unit)
      {
        name:                 unit.name,
        size:                 unit.size,
        pop_cost:             unit.population.to_f,
        resource_1:           unit.minerals,
        resource_2:           unit.gas,
        resource_3:           nil,
        hitpoints:            unit.hp.to_f,
        shield:               unit.shield.to_f,
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
        level:                0,
        abilities:            nil,
        armor:                nil
      }
    end

    def catalog_finder_hash(unit)
      {
        name: unit.name
      }
    end

    def map_asset(item)
      # add image to the Unit::Base
    end

    def sanitize_catalog(record)
      required_s = [:name, :hitpoints]
      sanitize_record(record, required_s, @import, :"Unit::Base")
    end

    def after
      Unit::Base.where(:name.nin => @imported_units.to_a).each { |c| c.delete }
    end
  end
end