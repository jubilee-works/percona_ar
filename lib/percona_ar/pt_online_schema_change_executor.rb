require 'rake'
require 'rake/file_utils'

class PerconaAr::PtOnlineSchemaChangeExecutor
  include FileUtils

  attr_accessor :sql, :table, :conn

  def initialize(table, sql, opt = {}, conn = ActiveRecord::Base.connection)
    @table = table
    @sql = sql
    @opt = opt
    @conn = conn
  end

  def call
    sh %Q(#{boilerplate}#{suffix(table, sql)}#{option})
  end

  private

  def suffix(table, cmd)
    %Q('#{cmd.gsub("'","\"")}' --recursion-method none --no-check-alter --execute D=#{config[:database]},t=#{table})
  end

  def boilerplate
    "pt-online-schema-change -u '#{config[:username]}' -h '#{config[:host]}' -p '#{config[:password]}' --alter "
  end

  def option
    if option.present?
      str = ''
      str << " --critical-load #{opt[:critical_load]}" if opt[:critical_load]
      str << " --max-load #{opt[:max_load]}" if opt[:max_load]
      str << " --chunk-size #{opt[:chunk_size]}" if opt[:chunk_size]
      str << " --chunk-time #{opt[:chunk_time]}" if opt[:chunk_time]
      str
    else
      ''
    end
  end

  def config
    conn.instance_variable_get(:@config)
  end
end
