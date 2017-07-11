class PerconaAr::Migration < ActiveRecord::Migration
  def connection
    @percona_connection ||=
      PerconaAr::Connection.new(ActiveRecord::Base.connection)
  end

  def percona_option
    @percona_option ||= {}
  end

  def migrate(*args)
    $query_builder = PerconaAr::QueryBuilder.new percona_option, connection
    super
    $query_builder.execute
  end
end
