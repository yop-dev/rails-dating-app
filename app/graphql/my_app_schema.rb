# app/graphql/my_app_schema.rb
class MyAppSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # Optional: enable GraphQL execution errors formatting
  rescue_from(ActiveRecord::RecordNotFound) do |err, _obj, _args, _ctx, _field|
    raise GraphQL::ExecutionError.new("Record not found: #{err.message}")
  end
end
