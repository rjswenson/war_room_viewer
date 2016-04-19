# require 'schlepp'

# Can toss in PG_USER and PG_PASSWORD when running the rake task to change defaults
def db_config
  {
    :host => ENV['SINK_HOST'] || 'localhost',
    :username => ENV['SINK_USER'] || ENV['PG_USER'] || 'postgres',
    :password => ENV['SINK_PASSWORD'] || ENV['PG_PASSWORD'] || 'postgres',
    :adapter => 'postgresql',
    :database => "war_room_viewer_#{Rails.env}"
  }
end

def do_extract(name, table = name, required = true)
  file 'Csv' do |csv|
    if name.is_a?(Array)
      csv.name = name.map {|f| File.join('data', "#{f}.csv")}
    else
      csv.name = File.join('data', "#{name}.csv")
    end
    csv.has_headers = true
    csv.required = required
    csv.encoding = 'utf-8'

    csv.csv_options = {col_sep: "|", quote_char: '"'}

    csv.strip = {:all => true}

    csv.before do
      p "extracting #{name}"
      @extraction.before
    end
    csv.after do
      p "done extracting #{name}"
      @extraction.after
    end

    csv.map do |item|
      @extraction.extract_from_file(item, table)
    end
  end
end


Schlepp::Burden.new :units do
  before do
    @import = Import.create!(source: 'unit import')

    @extraction = Importer::Extraction.new
    @unit_import = Importer::UnitImport.new(@import)
    @unit_import.before
  end

  after do
    @unit_import.after
    @import.completed!
  end

  on_success do |job, burden|
    @import.completed!
  end

  on_error do |error, job, burden|
    @import.errored!(error)
    false #return false so execution stops
  end

  cd File.join('data')

  do_extract(["units_*"], "units")

  file 'Binary' do |bin|
    path = File.join('media', '*')

    bin.before do
      @unit_import.before_media
    end

    bin.after do
      @unit_import.after_media
    end

    bin.glob path do |asset|
      @unit_import.map_media(asset)
    end
  end

  db do |war_room|
    war_room.config = db_config

    war_room.table :units do |units|
      units.mapping = {
        :'0' => :game,
        :'1' => :species,
        :'2' => :key,
        :'3' => :name,
        :'4' => :size,
        :'5' => :speed,
        :'6' => :population,
        :'7' => :minerals,
        :'8' => :gas,
        :'9' => :armor,
        :'10' => :hp,
        :'11' => :shield,
        :'12' => :g_attack,
        :'13' => :g_attack_dps,
        :'14' => :a_attack,
        :'15' => :a_attack_dps,
        :'16' => :cooldown,
        :'17' => :range,
        :'18' => :attack_mod,
        :'19' => :sight,
        :'20' => :notes,
        :'21' => :build_time,
        :'22' => :abilities,
        :'23' => :cargo,
        :'24' => :armor_type
      }

      units.before do
        # Wonky way to add indexes to PG tables.
        @extraction.before
        @extraction.indexes = <<-EOT
          DROP INDEX IF EXISTS game_idx;
          DROP INDEX IF EXISTS species_idx;
          DROP INDEX IF EXISTS unit_stats;
          CREATE INDEX game_idx ON units ("0", "2");
          CREATE INDEX species_idx ON units ("1", "2");
          CREATE INDEX unit_stats ON units ("2", "3", "6", "7");
        EOT
        @extraction.after
      end

      units.after do

      end

      units.each do |unit_data|
        @unit_import.map_unit(unit_data)
      end
    end
  end
end