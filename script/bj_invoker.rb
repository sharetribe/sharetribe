@routing = Workling::Routing::ClassAndMethodRouting.new
unnormalized = REXML::Text::unnormalize(STDIN.read)
message, command, args = *unnormalized.match(/(^[^ ]*) (.*)/)
options = Hash.from_xml(args)["hash"]

if workling = @routing[command]
  options = options.symbolize_keys
  method_name = @routing.method_name(command)

  workling.dispatch_to_worker_method(method_name, options)
end
