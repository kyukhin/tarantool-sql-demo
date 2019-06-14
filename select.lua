-- Single OLAP client

nb = require('net.box')
cn = nb.connect('3301')

cn:execute([[SELECT MAX(total_price)
               FROM purchase_item
	       WHERE purchase_id IN
	          (SELECT id
		   FROM purchase
		   WHERE customer_id NOT IN
		       (SELECT id FROM customer WHERE id IN
		           (SELECT id FROM purchase WHERE id IN
			       (SELECT purchase_id FROM purchase_item WHERE
			           count(id) > 3 GROUP BY purchase_id))))
		GROUP BY purchase_id]])

os.exit()