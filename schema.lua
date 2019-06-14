box.cfg{}

-- DDL
box.execute("CREATE TABLE product (id INTEGER PRIMARY KEY, name TEXT)")

box.execute("CREATE TABLE customer (id INTEGER PRIMARY KEY, name TEXT, email TEXT, passwd TEXT)")

box.execute([[CREATE TABLE purchase (id INTEGER PRIMARY KEY AUTOINCREMENT, customer_id INTEGER,
                                     FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE RESTRICT ON UPDATE RESTRICT)]])

box.execute([[CREATE TABLE purchase_item (purchase_id INTEGER,
                                          product_id  INTEGER,
                                          items_num   INTEGER,
                                          total_price FLOAT,
                                          PRIMARY KEY(purchase_id, product_id),
                                          FOREIGN KEY (purchase_id) REFERENCES purchase(id) ON DELETE CASCADE ON UPDATE CASCADE,
                                          FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE RESTRICT ON UPDATE RESTRICT)]])

function string_rand(len)
    if len < 1 then return nil end
    local s = ""
    for i = 1, len do
        s = s .. string.char(math.random(65, 122))
    end
    return s
end

local prod_count = 100000
local cust_count = 100000
function initial_fill(p_count, items_per_p)
    for i = 1, prod_count do
	local params = {}
	params[1] = i
	params[2] = string_rand(30)
	box.execute([[INSERT INTO product VALUES ($1, $2)]], params)
    end
    for i = 1, cust_count do
	local params = {}
	params[1] = i
	params[2] = string_rand(20)
	params[3] = string_rand(10) .. '@mail.ru'
	params[4] = string_rand(8)
	box.execute([[INSERT INTO customer VALUES ($1, $2, $3, $4)]], params)
    end
    for i = 1, p_count do
        local params = {}
	params[1] = i
	params[2] = math.random(1, cust_count)
	box.begin()
	box.execute([[INSERT INTO purchase VALUES ($1, $2)]], params)
	for j = 1, items_per_p do
	    local params = {}
   	    params[1] = i
            local range_len = prod_count / items_per_p
	    params[2] = math.random((j-1) * range_len + 1,
	    	                     j * range_len - 1)
	    params[3] = math.random(10)
	    params[4] = math.random(1000) / 3.14
	    box.execute([[INSERT INTO purchase_item VALUES ($1, $2, $3, $4)]], params)
	end
	box.commit()
    end
end

initial_fill(200000, 10)
