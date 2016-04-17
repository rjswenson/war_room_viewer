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
      csv.name = name.map {|f| File.join('unit_csvs', "#{f}.csv")}
    else
      csv.name = File.join('unit_csvs', "#{name}.csv")
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


Schlepp::Burden.new :starcraft do
  before do
    @import = Import.create!(source: 'starcraft import')

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

  [
    'protoss',
    'terran',
    'zerg'
  ].each do |name|
    do_extract(["#{name}*"], "#{name}_starcraft")
  end

  file 'Binary' do |bin|
    path = File.join('unit_imgs', 'starcraft1', '*.png')

    bin.before do
      p 'Starting assets'
    end

    bin.after do
      p 'Done with assets'
    end

    bin.glob path do |asset|
      @unit_import.map_asset(asset)
    end
  end

  db do |war_room|
    war_room.config = db_config

    ['protoss', 'terran', 'zerg'].each do |race|
      war_room.table :"#{race}_starcraft" do |units|
        units.mapping = {
          :'0' => :name,
          :'1' => :size,
          :'2' => :speed,
          :'3' => :population,
          :'4' => :minerals,
          :'5' => :gas,
          :'6' => :armor,
          :'7' => :hp,
          :'8' => :shield,
          :'9' => :g_attack,
          :'10' => :g_attack_dps,
          :'11' => :a_attack,
          :'12' => :a_attack_dps,
          :'13' => :cooldown,
          :'14' => :range,
          :'15' => :attack_mod,
          :'16' => :sight,
          :'17' => :notes,
          :'18' => :build_time,
          :'19' => :abilities,
          :'20' => :cargo,
          :'21' => :bonus
        }

        units.before do
          p "Starting SC1 #{race}"

          @origin_game = :starcraft
          # Wonky way to add indexes to PG tables.
          @extraction.before
          @extraction.indexes = <<-EOT
            DROP INDEX IF EXISTS race_idx;
            CREATE INDEX race_idx ON #{race}_starcraft ("0", "2", "6");
          EOT
          @extraction.after
        end

        units.after do
          p "Finished SC1 #{race}."
        end

        units.each do |sc_unit|
          @unit_import.map_unit(sc_unit)
        end
      end
    end
  end
end