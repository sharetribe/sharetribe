require 'spec_helper'

describe SQLUtils do
  class MockConnection
    def quote(str)
      "'" + str.gsub("'", "escaped") + "'"
    end
  end

  it "#ar_quote" do
    sql = ->(params) {
      "SELECT * FROM people WHERE name = #{params[:name]}"
    }

    connection = MockConnection.new

    expect(SQLUtils.ar_quote(connection, sql, name: "'; DROP TABLE *")).to eql("SELECT * FROM people WHERE name = 'escaped; DROP TABLE *'")
  end

  it "#quote" do
    sql = ->(params) {
      "SELECT * FROM people WHERE name = #{params[:name]}"
    }

    expect(SQLUtils.quote(sql, name: "mikko") { |v| "'#{v.upcase}'"}).to eql("SELECT * FROM people WHERE name = 'MIKKO'")
  end

  it "#quote elements in array" do
    sql = ->(params) {
      "SELECT * FROM people WHERE id in (#{params[:ids].join(',')})"
    }

    expect(SQLUtils.quote(sql, ids: [1, 2, 6]) { |v| v += 1 }).to eql("SELECT * FROM people WHERE id in (2,3,7)")
  end
end
