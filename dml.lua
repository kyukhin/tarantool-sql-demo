-- Single DML client

nb = require('net.box')
cn = nb.connect('3301')

local prod_count = cn:call('box.space.PRODUCT:count')
local cust_count = cn:call('box.space.CUSTOMER:count')

function do_place_order(items_count)
    local params = {}
    params[1] = box.NULL
    params[2] = math.random(1, cust_count)
    local res = cn:execute([[INSERT INTO purchase VALUES ($1, $2)]], params)
    local p_id = res["autoincrement_ids"][1]
    for j = 1, items_count do
	local params = {}
	params[1] = tonumber64(p_id)
	local range_len = prod_count / items_count
	params[2] = math.floor(math.random((j-1) * range_len + 1,
			       j * range_len - 1))
	params[3] = math.random(10)
	params[4] = math.random(1000) / 3.14
	cn:execute([[INSERT INTO purchase_item VALUES ($1, $2, $3, $4)]], params)
    end
end

function do_close_order()
    local p_id_min = cn:execute([[SELECT min(id) FROM purchase]])["rows"][1][1]
    local p_id_max = cn:execute([[SELECT max(id) FROM purchase]])["rows"][1][1]
    local p_id = cn:execute([[SELECT max(id) from purchase WHERE id <= $1]],
    	  {math.random(p_id_min, p_id_max)})["rows"][1][1]
    cn:execute([[DELETE FROM purchase WHERE id = $1]], {p_id})
end

while true do
    if math.random(1, 2) == 1 then
      do_place_order(math.random(1, 10))
    else
      do_close_order()
    end
end

require('console').start()
