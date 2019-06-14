-- instance file for the master
box.cfg{
  listen = 3302,
  replication = {3301},  -- master URI
--                 3302}, -- replica URI
  read_only = true
}
box.once("schema", function()
   box.schema.user.grant('guest', 'replication') -- grant replication role
   box.schema.space.create("test")
   box.space.test:create_index("primary")
   print('box.once executed on master')
end)

require('console').start()