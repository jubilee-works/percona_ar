require 'spec_helper'

RSpec.describe PerconaAr::PtOnlineSchemaChangeExecutor do
  describe "#call" do

    let(:lib) { described_class.new("users", sql) }
    let(:sql) { "`foo` `bar` varchar(36)" }

    after { lib.call }
    subject { lib }

    it "build correct command" do
      is_expected.to receive(:sh).
        with(
          /pt.online.schema.change.*[-]u.*[-]h.*[-]p.*alter.*foo.*execute.D.#{$db_name.gsub("_", ".")}.t.users/
        )
    end

    context "has some option" do
      let(:lib) { described_clas.new("users", sql, { critical_load: "Thread_running=100" }) }

      it "build command with option" do
        is_expected.to receive(:sh).
          with(
            /pt.online.schema.change.*[-]u.*[-]h.*[-]p.*alter.*foo.*execute.D.#{$db_name.gsub("_", ".")}.t.users.--critical-load.Thread_running=100/
          )
      end
    end
  end
end
