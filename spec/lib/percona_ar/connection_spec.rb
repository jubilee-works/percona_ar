require 'spec_helper'

RSpec.describe PerconaAr::Connection do
  let!(:lib) { described_class.new(ActiveRecord::Base.connection) }
  let(:builder) { $query_builder }

  before do
    allow(builder).to receive(:add)
    allow_any_instance_of(ActiveRecord::ConnectionAdapters::Mysql2Adapter).
      to receive(:execute)
  end

  it "raises an error for unsupported methods" do
    expect { lib.create_table(:foo) }.to raise_error(
      "This is not implemented with the percona tool, please use a standard migration"
    )
  end

  describe "#execute" do
    it "uses percona tool when sql is an alter statement" do
      sql = "ALTER TABLE `users` drop column `foo`"
      expect(builder).to receive(:add).with(sql)
      lib.execute(sql)
    end

    it "uses percona tool when sql is an create index statement" do
      sql = "CREATE INDEX `user_index` ON `users` (`id`)"
      expect(builder).to receive(:add).with(sql)
      lib.execute(sql)
    end

    it "uses percona tool when sql in an drop index statement" do
      sql = "DROP INDEX `user_index` ON `users`"
      expect(builder).to receive(:add).with(sql)
      lib.execute(sql)
    end

    it "uses percona tool when sql in an drop primary key statement" do
      sql = "ALTER TABLE `users` DROP PRIMARY KEY"
      expect(builder).to receive(:add).with(sql)
      lib.execute(sql)
    end

    it "uses percona tool when sql in an add primary key statement" do
      sql = "ALTER TABLE `users` ADD PRIMARY KEY(`foo`)"
      expect(builder).to receive(:add).with(sql)
      lib.execute(sql)
    end

    it "uses ActiveRecord when sql is not an alter statement" do
      sql = "SHOW FIELDS FOR users"
      expect(builder).not_to receive(:add)
      lib.execute(sql)
    end
  end
end
