-- OVERVIEW STUDY CASE
/*
Toko cars merupakan toko mainan miniatur kendaraan. Toko tersebut memiliki
database yang menyimpan informasi mengenai proses bisnis tokonya. Pemilik
toko, ingin menganalisis database yang dipunyai tersebut. Mari kita bantu!
*/


-- CASE 1.1
/*
- Problem:
	- Memasuki tahun ke 3 toko beroperasi sejak tahun 2003, pemiliki toko 
		ingin melihat trend penjualan dan transaksi tahunannya.

- Solution:
	1. Menghitung total penjualan berdasarkan tahunnya
	2. Menghitung total transaksi berdasarkan tahunnya
	3. Membutuhkan data dari table PAYMENTS dengan kolom:
		- paymentdate
		- amount
*/
SELECT
	EXTRACT(YEAR FROM paymentdate) AS year,
	SUM(amount) AS jumlah_pembayaran,
	COUNT(paymentdate) AS total_transaksi
FROM payments
GROUP BY year
ORDER BY jumlah_pembayaran DESC





-- CASE 1.2
/*
- Problem:
	- Dari transaksi yang telah dilakukan di toko tersebut, pemiliki toko tertarik
		untuk mengetahui berapa banyak total payments customer yang berada di atas
		rata-rata atau di bawah rata-rata total payments?

- Solution:
	1. Hitung total payment customer
	2. Hitung rata-rata keseluruhan payments 
	3. Label total pembayaran menjadi above/below jika di atas atau di bawah rata2 keseluruhan
	5. Hitung berapa banyak above dan below
	4. Membutuhkan data dari table PAYMENTS dengan kolom:
		- paymendate
		- amount
*/


-- Solution with CTE
-- Avg Berdasarkan Total Payment Keseluruhan
WITH total_payment AS (
	SELECT
		customernumber,
		SUM(amount) AS jumlah_pembayaran
	FROM payments
	GROUP BY customernumber
),
kategori_pembayaran AS (
	SELECT
		CASE
			WHEN (jumlah_pembayaran > (SELECT AVG(jumlah_pembayaran) FROM total_payment)) THEN 'above_avg'
			WHEN (jumlah_pembayaran = (SELECT AVG(jumlah_pembayaran) FROM total_payment)) THEN 'same'
		ELSE 'below_avg'
		END AS payment_category
	FROM total_payment
)
SELECT
	payment_category,
	COUNT(payment_category) AS number_of_payment
FROM kategori_pembayaran 
GROUP BY 1





-- Solution with Query
-- Avg Berdasarkan Total Payment Keseluruhan

-- 1. Menghitung Total Payment setiap Customer
SELECT
	customernumber,
	SUM(amount) AS jumlah_pembayaran
FROM payments
GROUP BY customernumber
ORDER BY customernumber

-- 2. Menghitung Rata-rata Keseluruhan Payment
SELECT AVG(jumlah_pembayaran) AS avg_payment
FROM (	SELECT
			customernumber,
			SUM(amount) AS jumlah_pembayaran
		FROM payments
		GROUP BY customernumber
		ORDER BY customernumber
	) AS total_payment_per_customer

-- 3. Mencari Total Payment Customer di atas Rata-rata Payment
SELECT 	
	CASE
		WHEN jumlah_pembayaran > avg_payment THEN 'above_avg'
		WHEN jumlah_pembayaran = avg_payment THEN 'same'
	ELSE 'below_avg'
	END AS payment_category
FROM (
	SELECT AVG(jumlah_pembayaran) AS avg_payment
	FROM (	SELECT
				customernumber,
				SUM(amount) AS jumlah_pembayaran
			FROM payments
			GROUP BY customernumber
			ORDER BY customernumber
		) AS total_payment_per_customer
) AS totalpayment_above_below_avg

-- 4. Menghitung Banyaknya Total Pembayaran di atas/di bawah Rata-rata Keseluruhan
SELECT 
	payment_category,
	COUNT(payment_category) AS number_of_payment
FROM (	SELECT 	
			CASE
				WHEN jumlah_pembayaran >(SELECT AVG(amount) FROM payments) THEN 'above_avg'
				WHEN jumlah_pembayaran = (SELECT AVG(amount) FROM payments) THEN 'above_avg'
			ELSE 'below_avg'
			END AS payment_category
		FROM (
				SELECT
					customernumber,
					SUM(amount) AS jumlah_pembayaran
				FROM payments
				GROUP BY customernumber
				ORDER BY customernumber
			) AS total_pembayaran
		) AS total_payment_below_above_avg
GROUP BY 1








-- CASE 1.3
/*
- Problem:
	Pemilik toko berencana membuat customer loyalty program dengan memberikan
	fasilitas khusus kepada customer yang masuk kategori Loyal Customer. Sebelum
	menjalankannya, ia meminta Anda untuk mengkategorikan customer
	berdasarkan frekuensi order sebagai berikut:
	a. Jika 1x order, maka dikategorikan sebagai One-time Customer
	b. Jika 2x order, maka dikategorikan sebagai Repeated customer
	c. Jika 3x order, maka dikategorikan sebagai Frequen Customer
	d. Jika minimum 4x order, maka dikategorikan sebagai Loyal Customer

- Solution:
	1. Cari count order tiap customer (customer & order)
	2. BUat kategori loyalitas customer
*/

WITH total_order AS (
	SELECT
		customernumber,
		customername,
		COUNT(ordernumber) AS jumlah_order
	FROM orders
	JOIN customers
		USING(customernumber)
	GROUP BY 1,2
	ORDER BY customernumber
),
type_of_customer AS (
SELECT
	customernumber,
	customername,
	jumlah_order,
	CASE 
		WHEN jumlah_order = 1 THEN 'One-Time Customer'
		WHEN jumlah_order = 2 THEN 'Repeated Customer'
		WHEN jumlah_order = 3 THEN 'Frequent Customer'
		ELSE 'Loyal Customer'
	END AS customer_category
FROM total_order
ORDER BY customername 
)
SELECT
	customernumber,
	customername,
	customer_category
FROM type_of_customer
WHERE customer_category = 'Loyal Customer'





-- CASE 1.4
/*
- Problem:
	Pemilik toko tertarik untuk mengetahui tren pembelian produk di tiap negara.Ia
	meminta untuk mencari tahu category product yahng paling banyak di order di tiap
	negara.

- Note:
	Buatlah query tersebut ke dalam views

- Solution:
	1. Menghubungkan data kolom dari tabel yang berbeda dengan foreign key sebagai berikut:
		customers 		(country)
		products 		(productname & productline)
		orderdetails 	(quantityordered)
		
		customers - orders (FK: customernumber)
		orders - orderdetails (FK: ordernumber)
		orderdetail - products (FK: productcode)

	2. Hitung total quantityordered per country & productline
	3. Buat rank total order berdasarkan country & productline
	4. Seleksi atau pilih rank 1 (order paling banyak) berdasarkan country & productline
		misal:
			USA 	Vintage Cars	100
			USA		Classic Cars	80
			USA 	Modern Cars 	110
		maka,
		USA; Modern Cars; 110 yang akan dipilih/ditampilkan karena memiliki rank 1 diantara ketiganya

- Solution:
	1. Cari quantityordered/sold category product di tiap negara
	2. Pilih kategori produk nomer satu tiap negara (first value)
	3. Tampilkan country dan favorite_category
*/

-- 1. Create The View
CREATE VIEW tren_produk 
AS 

WITH order_per_country_productline AS (
	SELECT 
		country,
		productline,
		SUM(quantityordered) AS jumlah_pemesanan
	FROM customers
	JOIN orders
		USING(customernumber)
	JOIN orderdetails
		USING(ordernumber)
	JOIN products
		USING(productcode)
	GROUP BY 1, 2
),
ranked_country_jml_pemesanan AS (
	SELECT 
		country,
		productline,
		jumlah_pemesanan,
		RANK () OVER (PARTITION BY country ORDER BY jumlah_pemesanan DESC) AS rank_per_country
	FROM order_per_country_productline
)
SELECT 
	country,
	productline
FROM ranked_country_jml_pemesanan
WHERE rank_per_country = 1
ORDER BY country


-- 2. Call The View
SELECT *
FROM tren_produk











-- CASE 2.1
/*
- Problem:
	Pemilik toko ingin mengetahui berapa rata-rata waktu yang dibutuhkan 
	oleh customer untuk melakukan repeat order?

- Solution:
	1. Cari data tentang orderdate berdasarkan customernumber, untuk mengetahui urutan pemesanan
	2. Buat kolom nextorder berdasarkan urutan orderdate menggunakan LEAD(), yang mana
		fungsinya untuk mengetahui urutan pemesanan dari satu tanggal ke tanggal lain 
	3. Dari langkah 2, kita bisa mengetahui berapa hari (day) selisih antara nextorder dengan orderdate
	4. Kemudian, kelompokkan berdasarkan customer number dan cari rata-rata dari hari/durasi 
		yang merupakan hasild ari pengurangan nextorder - orderdate
*/
-- Versi 1
-- (Lihat CTE 3 Bagian: WHERE duration IS NOT NULL)
WITH next_order AS (
	SELECT
		customernumber,
		customername,
		orderdate,
		LEAD(orderdate, 1) OVER(PARTITION BY customernumber ORDER BY orderdate ASC) AS nextorder
	FROM orders
	JOIN customers
		USING(customernumber)
),
duration_of_order AS (
	SELECT
		customernumber,
		customername,
		nextorder - orderdate AS duration
	FROM next_order
)
	SELECT
		customername,
		AVG(duration)::int AS avg_day_to_next_order
	FROM duration_of_order
	WHERE duration IS NOT NULL
	GROUP BY 1
	ORDER BY avg_day_to_next_order 
	


-- Versi 2
-- (Lihat CTE 3 Bagian: WHERE nextorder IS NOT NULL)
WITH nextdate AS (
SELECT
	customername,
	orderdate,
	LEAD(orderdate, 1) OVER(PARTITION BY customername ORDER BY orderdate) AS nextorder
FROM customers
JOIN orders
	USING(customernumber)
),
order_duration AS (
SELECT
	customername,
	nextorder - orderdate AS duration
FROM nextdate
WHERE nextorder IS NOT NULL
)
SELECT
	customername,
	AVG(duration)::int AS avg_duration
FROM order_duration
GROUP BY 1
ORDER BY 2





-- CASE 2.2
/*
- Problem:
	Pemilik toko ingin melihat tanggal dan jumlah transaksi yang dilakukan
	customer saat melakukan payment pertama kali
	
- Solution:
	1. Menampilkan kolom: customername, paymentdate, amount
	2. Kelompokan berdasarakn customername
	3. Cari paymentdate & amount yang pertama kali dilakukan
	
*/


WITH rank_of_paymentdate AS (
	SELECT	
		customername,
		amount,
		RANK() OVER(PARTITION BY customername ORDER BY paymentdate) AS rank_paymentdate,
		paymentdate AS firstpayment
	FROM customers
	JOIN payments
		USING(customernumber)
)
	SELECT
		customername,
		firstpayment,
		amount
	FROM rank_of_paymentdate
	WHERE rank_paymentdate = 1
	ORDER BY firstpayment





-- CASE 2.3
/*
- Problem:
	Kali ini pemiliki toko ingin melihat customer yang melakukan order pertama
	dan terakhir di tiap negara

- Solution:
	1. Tampilkan data dari kolom: customername, country, orderdate
	2. Kelompokan berdasarkan country
	3. Ranking berdasarkan orderdate
	4. Seleksi ranking 1 & ke n-1 (terakhir)
*/
WITH first_last_customer AS (
	SELECT
		country,
		customername,
		orderdate,
		FIRST_VALUE(customername) OVER(PARTITION BY country ORDER BY orderdate) AS firstcustomer,
		LAST_VALUE (customername) OVER(PARTITION BY country ORDER BY orderdate 
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lastcustomer
	FROM customers
	JOIN orders
		USING(customernumber)
)
	SELECT
		country,
		firstcustomer,
		lastcustomer
	FROM rank_cust_per_country
	GROUP BY 1,2,3





-- CASE 2.4
/*
- Problem:
	Pemilik toko tertarik untuk mengetahui produk termahal ke-N yang
	diorder tiap customer. Buatlah query tersebut ke dalam procedure!
- Solution:
	1. Menampilkan customernumber, productname (termahal ke-N), priceeach
	2. Membuat rank produk termahal 
	3. Cari produk termahal ke-2 (misalnya) dengan (NTH_VALUE)
	4. Tampilkan
*/

-- Versi 1: Menggunakan Function RANK()
WITH rank_product_of_price AS (
	SELECT 	
	customernumber,
	customername,
	productname,
	priceeach,
	RANK() OVER(PARTITION BY customername ORDER BY priceeach DESC RANGE BETWEEN 
		UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS rank_product 
	FROM customers
	JOIN orders 
		USING(customernumber)
	JOIN orderdetails
		USING(ordernumber)
	JOIN products
		USING(productcode)
)
	SELECT	
		customername,
		productname
	FROM rank_product_of_price
	WHERE rank_product = 2



-- Versi 2: Menggunakan Function NTH_VALUE()
WITH customer_product_ordered AS (
	SELECT
		customername,
		productname,
		priceeach
	FROM customers
	JOIN orders
		USING(customernumber)
	JOIN orderdetails	
		USING(ordernumber)
	JOIN products
		USING(productcode)
),
second_most_expensive AS (	
	SELECT *,
		NTH_VALUE(productname, 2) OVER(PARTITION BY customername ORDER BY priceeach DESC
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS second_most_expensive_products
	FROM customer_product_ordered
)
	SELECT
		customername,
		second_most_expensive_products
	FROM second_most_expensive 
	GROUP BY 1,2
	ORDER BY 1




SELECT *
FROM orders

SELECT *
FROM orderdetails

SELECT *
FROM customers

SELECT *
FROM products


SELECT *
FROM payments