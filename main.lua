
local blt = require('BearLibTerminal')
local fennel = require('fennel.fennel')
-- table.insert(package.loaders or package.searchers, fennel.searcher)
table.insert(package.loaders, fennel.make_searcher({correlate=true}))

local program = require('program')
program.run()
