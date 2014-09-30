module SQLUtils
  module_function

  # Give lambda (that constructs the SQL), params hash and a quote strategy block
  # and get back quoted SQL
  #
  # Usage:
  #
  # sql -> (params) { "SELECT * FROM people WHERE name = #{params[:name]}" }
  #
  # quote(sql, name: "Mikko") { |p| "'" + p.upcase + "'" } #=> "SELECT * FROM people WHERE name = 'MIKKO'"
  #
  def quote(sql_lambda, params, &block)
    sql_lambda.call(HashUtils.map_values(params) { |p|
        if(p.is_a? Array)
          p.map { |v| block.call(v) }
        else
          block.call(p)
        end
      })
  end

  # Give ActiveRecord connection, lambda (that constructs the SQL) and params hash and get back quoted SQL.
  #
  # Usage:
  #
  # connection = ActiveRecord::Base.connection
  # sql -> (params) { "SELECT * FROM people WHERE name = #{params[:name]}" }
  #
  # ar_quote(connection, sql, name: "Mikko") #=> "SELECT * FROM people WHERE name = 'Mikko'"
  #
  def ar_quote(connection, sql_lambda, params)
    quote(sql_lambda, params) { |p| connection.quote(p) }
  end

end
