-- OVERVIEW THE STUDY CASE:
/*
Toko Cars merupakan toko mainan miniatur kendaraan. Pemilik baru saja menunjuk
manager baru dan memintanya untuk mengenali proses bisnis dari toko tersebut. Toko
tersebut memiliki database yang menyimpan informasi mengenai proses bisnis tokonya. 
*/



-- CASE 1
/*
Manager ingin mengetahui produk-produk 
yang ada di toko Cars
*/

-- CASE 1.1
-- Cars Retail Database
/*
Manager ingin mengetahui apa saja kategori produk yang dijual di toko tersebut
*/

SELECT DISTINCT productline
FROM products;



-- CASE 1.2
-- Cars Retail Database
/*
Manager ingin mengetahui 5 produk termurah yang dibeli oleh toko
*/

SELECT 
	p.productname,
	p.productline,
	p.buyprice
FROM 
	products p
ORDER BY 
	p.buyprice ASC
LIMIT 5;



-- CASE 1.3
-- Cars Retail Database
/*
Manager ingin melakukan simulasi penjualan, jika harga jual produk ditentukan 10%
lebih kecil dari MSRP, seeprti apa proyeksi total penjualan untuk tiap produl jika semua stock terjual habis?

Note: MSRP adalah Manufacturer Suggested Retail Price atau harga eceran yang disarankan

- HJ = MSRP - (10% * MSRP)
- Proyeksi total penjualan untuk setiap produk jika semua stok (quantityinstock) terjual habis?
- Harga Jual Produk, msrp/harga eceran, total_penjualan, stok, produk
*/ 

-- Cara 1 
SELECT 
	p.productname, 
	p.productline,
	p.quantityinstock,
	p.buyprice,
	p.msrp - (p.msrp * 0.1) AS sale_price,
	p.msrp,
	p.quantityinstock * (p.msrp-(p.msrp * 0.1)) AS total_sale
FROM 
	products p;
	
-- Cara 2 Dengan CTE 
WITH productSale AS(
	SELECT 
		p.productname,
		p.productline,
		p.quantityinstock,
		p.buyprice,
		p.msrp - (p.msrp * 0.1) AS sale_price,
		p.msrp
	FROM
		products p
)
	SELECT 
		productname,
		productline,
		quantityinstock,
		buyprice,
		msrp,
		sale_price,
		quantityinstock * sale_price AS total_sale
	FROM 
		productSale;



-- CASE 1.4
-- Cars Retail Database
/*
Jika manager menetapkan harga jual 10% di bawah msrp.
Tampilkan 10 produk yang akan menghasilkan profit terbanyak bagi perusahaan. Jika semua produk terjual habis

Note: 	
- profit = revenue - biaya produk
- revenue - harga_jual * jumlah_stock
- biaya_produk =  harga_beli * jumlah_stock
*/

-- Cara 1
SELECT 
	productname,
	quantityinstock,
	buyprice,
	msrp - (msrp * 0.1) saleprice,
	((msrp - (msrp * 0.1)) * quantityinstock) - (buyprice * quantityinstock) AS profit
FROM
	products
ORDER BY profit DESC
LIMIT 10;


-- Cara 2 dengan CTE
WITH productCost AS (
	SELECT 
		productname, 
		quantityinstock,
		buyprice,
		msrp - (msrp * 0.1) AS saleprice,
		buyprice * quantityinstock AS productcost
	FROM products
),
revenueSale AS (
	SELECT
		productname,
		quantityinstock,
		buyprice,
		productcost,
		saleprice,
		saleprice * quantityinstock AS revenue
	FROM 
		productCost
)
	SELECT
		productname,
		quantityinstock,
		buyprice,
		saleprice,
		revenue - productcost AS profit
	FROM 
		revenueSale
	ORDER BY profit DESC
	LIMIT 10;





-- CASE 2
/* Kali ini manager toko ingin menegtahui 
lebih jauh tentang customernya
*/



-- CASE 2.1
-- Cars Retail Database
/*
Manager ingin mengetahui siapa saa customer yang masuk kategori 'incorporated company'?
Hint: Nama customer mengandung kata 'Inc'
*/

SELECT
	customername
FROM 	
	customers
WHERE 
	customername LIKE '%Inc%';



-- CASE 2.2
-- Cars Retail Database
/*
Sehubungan dengan perayaan hari jadi kota New York (NYC), Brickhaven, dan San Fransisco serta Negara Japan.
Manager ingin mengadakan program khusus di kota/negara tersebut.
Untuk itu, dia ingin mengetahui customer yang berasal dari kota-kota/negara tersebut.
*/

SELECT 
	customername,
	contactlastname,
	phone,
	city,
	country
FROM 
	customers
WHERE 
	city IN ('NYC', 'Brickhaven', 'San Francisco') 
	OR country IN ('Japan');



-- CASE 2.3
-- Cars Retail Database
/*
Untuk meningkatkan transaksi, manager akan membuat diskon pada customer yang masih
memiliki credit limit dan berasal dari negara Amerika.
Dapatkanlah informasi tersebut.
*/
SELECT 
	c.customername,
	c.contactlastname,
	c.phone,
	c.country,
	c.creditlimit
FROM
	customers c
WHERE 
	creditlimit > 0 
	AND country IN ('USA')
LIMIT 7;



-- CASE 2.4
-- Cars Retail Database
/* 
Sebagai bentuk apresiasi toko ingin memberikan hadiah kepada customer
yang nilai transaksinya masuk ke 10 transaksi paling besar.
*/

SELECT 
	customernumber,
	checknumber,
	paymentdate,
	amount
FROM 
	payments
ORDER BY 
	amount DESC
LIMIT 10;

-- How about total per customernumber?
SELECT DISTINCT
	customernumber,
	SUM(amount) AS total_amount
FROM
	payments
GROUP BY customernumber
ORDER BY total_amount DESC
LIMIT 10;
	


	
	

	

