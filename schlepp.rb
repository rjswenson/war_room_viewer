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

def do_extract(name, opts = { col_sep: ',', quote_char: '`' })
  file 'Csv' do |csv|
    csv.name = File.join('unit_csvs', "#{name}.csv")
    csv.has_headers = true
    csv.required = true
    csv.encoding = 'utf-8'
    csv.csv_options = opts
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
      @extraction.extract_from_file(item, "#{name}")
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
    'protoss_sc1',
    'terran_sc1',
    'zerg_sc1'
  ].each do |file|
    do_extract(file)
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

    ['zerg', 'protoss', 'terran'].each do |race|
      war_room.table :"#{race}_sc1" do |units|
        units.mapping = {
          :'0' => :name,
          :'1' => :size,
          :'2' => :population,
          :'3' => :minerals,
          :'4' => :gas,
          :'5' => :armor,
          :'6' => :hp,
          :'7' => :shield,
          :'8' => :g_attack,
          :'9' => :a_attack,
          :'10' => :cooldown,
          :'11' => :range,
          :'12' => :attack_mod,
          :'13' => :sight,
          :'14' => :notes,
          :'15' => :build_time,
          :'16' => :abilities
        }

        units.before do
          p "Starting SC1 #{race}"
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