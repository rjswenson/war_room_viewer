module Import
  class Extraction
    attr_accessor :indexes

    def before
      config = {
        :host => ENV['SINK_HOST'] || 'localhost',
        :user => ENV['SINK_USER'] || ENV['PG_USER'] || 'postgres',
        :password => ENV['SINK_PASSWORD'] || ENV['PG_PASSWORD'] || 'postgres',
        :dbname => "war_room_viewer_#{Rails.env}"
      }
      establish_connection(config)

      @tables = []
      @batch_query = ''
      @count = 0
      @indexes = ''
    end

    def after
      if @batch_query.present?
        query_sink(@batch_query)
      end

      query_sink(@indexes) if @indexes.present?

      close_connection
    end

    def establish_connection(config)
      connect_sink(config)
    end

    def close_connection
      @sink_connection.close
    end

    def query_sink(query)
      @sink_connection.send_query(query)
      results = []
      while result = @sink_connection.get_result
        results << result
      end

      results.each do |result|
        raise "Postgres Error: #{result.result_error_message}\n" if result.result_status != 1
      end

      results
    end

    def connect_sink(config)
      @sink_connection = ::PGconn.new(config)
    end

    def insert_query_part(row)
      keys = []
      values = []
      row.each_with_index do |v, k|
        if v.class == String
          value = v.gsub(/'/, "''").slice(0, 1024)
          #p(v, value) if v != value
        else
          value = v ? v : "~NULL~"
        end

        keys << "\"#{k}\""
        values << value
      end

      keys = keys.join(',')
      values = "'" + values.join("', '") + "'"
      values.gsub!("'~NULL~'", "NULL")

      " (#{keys}) VALUES (#{values}) "
    end

    def insert_rows(table_name, rows, row_count)
      ensure_connection do
        base_query = "INSERT INTO #{table_name} "


        batch_query = ''

        rows.each(:cache_rows => false) do |row|
          query = base_query + insert_query_part(row) + ';'
          batch_query << query

          if i % 900 == 0 || i + 1 == row_count
            query_sink(batch_query)
            batch_query = ''

            print "#{i}\n"
          end
          i = i.next
        end
      end
    end

    def extract_from_file(row, table_name)
      unless @tables.include? table_name
        @tables << table_name

        truncate_and_create(table_name, row)
      end

      base_query = "INSERT INTO #{table_name} "

      query = base_query + insert_query_part(row) + ';'
      @batch_query << query

      @count = @count.next

      if @count % 900 == 0
        query_sink(@batch_query)
        @batch_query = ''

        print "#{@count}\n"
      end
    end

    def truncate_and_create(table_name, row)
      truncate_sink([table_name])
      create_table(table_name, row)
    end

    def create_table(table_name, row)
      rows = []

      row.each_with_index do |col, index|
        name = "\"#{index}\""
        type = 'varchar(1024)'
        null = ''

        rows << [name, type, null].join(' ')
      end

      rows = rows.join(', ')

      query = "CREATE TABLE #{table_name} (id SERIAL UNIQUE, #{rows} );"

      query_sink(query)
      print "Created table #{table_name}"
    end

    def truncate_sink(source_tables)
      source_tables.each do |table_name|
        print "Dropping table #{table_name}"
        begin
          query_sink("DROP TABLE #{table_name}")
        rescue => error
        end
      end
    end
  end
end