class PerconaAr::QueryBuilder
  def initialize(opt = {}, conn = ActiveRecord::Base.connection)
    @tables = Hash.new {|h, k| h[k] = [] }
    @opt = opt
    @conn = conn
  end

  def execute
    @tables.each do |table, snippets|
      PerconaAr::PtOnlineSchemaChangeExecutor.new(table, snippets.join(", "), @opt, @conn).call
    end
  end

  def add(sql)
    if sql =~ /^ALTER TABLE `([^`]*)` (.*)/i
      @tables[$1.to_s] << get_sql_for($2)
    elsif sql =~ /^CREATE ([^ ]*) *INDEX `([^`]*)` *ON `([^`]*)` \((.*)\)/i
      @tables[$3.to_s] << get_sql_for_create_index($2, $4, $1)
    elsif sql =~ /^DROP INDEX `([^`]*)` ON `([^`]*)`/i
      @tables[$2.to_s] << get_sql_for_drop_index($1)
    end
    self
  end

  private

  def get_sql_for(cmd)
    return cmd unless cmd =~ /DROP/i && !(cmd =~ /COLUMN/i)
    return cmd if cmd=~ /PRIMARY KEY|INDEX/i
    cmd.gsub(/DROP/i, "DROP COLUMN")
  end

  def get_sql_for_create_index(idx_name, col_name, option)
    "ADD #{option} INDEX #{idx_name}(#{col_name})"
  end

  def get_sql_for_drop_index(idx_name)
    "DROP INDEX `#{idx_name}`"
  end
end
