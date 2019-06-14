-- instance file for the master

box.cfg {
  listen = 3301,
  read_only = false
}

box.once("schema", function()
   box.schema.user.grant('guest', 'write, read, execute', 'universe')
   print('box.once executed on master')
end)

require('console').start()