-- USING AGREGATION, GROUPING, WINDOW FUNCTION

-- OVERVIEW STUDY CASE
/*
Toko Cars merupakan toko mainan miniatur kendaraan. Toko tersebut memiliki
database yang menyimpan informasi mengenai proses bisnis tokonya.
Pemiliki toko, ingin menganalisis database yang dipunyai tersebut.
*/


-- Problem Solving of cases using Aggregation
/*
Toko ingin melihat kelengkapan stock di gudangnya. Hal ini untuk menentukan 
apakah jumlah stock barang masih mencukupi. Coba analisis
ketersediaan stock dengan menari jumlah totalnya.
*/
SELECT * -- productcode 
FROM products;

SELECT * -- productcode
FROM orderdetails;

-- Analisis Total Ketersediaan Stok Barang
SELECT
	SUM(quantityinstock) AS total_stock
FROM
	products;
	

-- Analisis Ketersediaan Stock setiap Barang/Produk
-- JOIN with USING
-- FOREIGN KEY (FK)
SELECT 
	p.productname,
	p.productline,
	p.productvendor,
	p.quantityinstock,
	od.quantityordered
FROM 
	products p
JOIN
	orderdetails od
	USING (productcode)
ORDER BY p.quantityinstock;


-- Analisis Ketersediaan Barang Dikelompokkan berdasarkan PRODUCTLINE(KATEGORI)
-- Without CTE
-- JOIN with USING
-- FOREIGN KEY (FK)
-- ORDER BY
-- GROUP BY
SELECT
	p.productline,
	p.quantityinstock,
	od.quantityordered,
	p.quantityinstock - od.quantityordered AS remaining_stock 
FROM
	products p
JOIN
	orderdetails od
	USING (productcode)
GROUP BY 
	p.productline,
	p.quantityinstock,
	od.quantityordered,
	remaining_stock 
ORDER BY remaining_stock;

SELECT 
	productline,
	SUM(quantityinstock) AS jml_stok
FROM products
GROUP BY productline;


-- Analisis Ketersediaan Barang Dikelompokkan berdasarkan PRODUCTLINE(KATEGORI)
-- Menggunakan CTE
-- JOIN with USING
-- FOREIGN KEY (FK)
-- ORDER BY
-- GROUP BY
WITH availableStock AS(
	SELECT 
		p.productline,
		SUM(p.quantityinstock) AS total_stock,
		SUM(od.quantityordered) AS total_ordered
	FROM
		products p
	JOIN
		orderdetails od
		USING(productcode)
	GROUP BY
		p.productline
)
	SELECT
		productline,
		total_stock,
		total_ordered,
		total_stock - total_ordered AS remaining_stock
	FROM
		availableStock
	GROUP BY 
		productline, 
		total_stock,
		total_ordered,
		remaining_stock;





-- AGGREGATION, GROUPING, AND HAVING CASE 
/*
Kemudian operasioanl gudang toko ingin melihat variasi dari jenis barang pada
gudang. Variasi barang yang memiliki jumlah sedikit akan ditambahkan variasinya.
Jika variasi barang kurang dari 5, maka akan ditambahkan variasinya.

Summary:
- Menampilkan jumlah variasi produk (productname) berdasarkan productline
- Berapa productname (variasi produk) untuk setiap kategorinya/productline?
*/


-- Cara 1
-- Hanya Menggunakan 1 Table (Product)
WITH productVariation AS (
	SELECT
		productline,
		COUNT(productname) AS total_variasi
	FROM
		products
	GROUP BY
		productline
)
	SELECT
		productline,
		total_variasi,
		CASE
			WHEN total_variasi < 5 THEN SUM(total_variasi) +5
			ELSE SUM(total_variasi)
		END AS adjustedVariation
	FROM
		productVariation
	GROUP BY
		productline,
		total_variasi;


-- Cara 2	
-- Menampilkan Jumlah Variasi Produk (Berdasarkan Jumlah PRODUCTNAME) Berdasarkan PRODUCTLINE
-- Menggunakan 2 Table yang di JOIN-kan (Product & Productline)
SELECT *
FROM productlines;

SELECT *
FROM products;

SELECT
	pl.productline,
	COUNT(productname) AS variasi_produk
FROM
	products p
JOIN 
	productlines pl
	USING(productline)
GROUP BY
	pl.productline;


-- Cara 3
-- Menampilkan Jumlah Variasi Produk (Berdasarkan Jumlah PRODUCTNAME) Berdasarkan PRODUCTLINE
-- Kemudian menambahkan 5 variasi untuk JML_VARIASI < 5
-- Menggunakan 2 Table yang di JOIN-kan (Product & Productline)
WITH productVariations AS(
	SELECT
		pl.productline,
		COUNT(p.productname) AS jml_variasi
FROM
	products p
JOIN 	
	productlines pl
	USING(productline)
GROUP BY
	pl.productline
)
	SELECT
		productline,
		jml_variasi,
		CASE
			WHEN jml_variasi < 5 THEN SUM(jml_variasi) +5
			ELSE SUM(jml_variasi)
		END AS adjusted_variation
	FROM
		productVariations
	GROUP BY
		productline,
		jml_variasi;




-- AGRGEGATION AND GROUPING LIMIT
/*
Pada tahap akhir kegiatan restock, toko ingin membandingkan stock barang dengan 
rata-ratanya agar nanti stock barang yang kurang dari rata-rata dapat di restock.
*/


-- Rata-rata Kurang Representatif
-- Apa yang harus dilakukan?
-- Next Case
/*
Rata-rata kurang representatif karena hanya merepetisi nilai yang ada
pada kolom 'quantityinstock'. Ini merupakan batasan dari agregasi dan grouping.
*/
SELECT
	productname,
	quantityinstock,
	AVG(quantityinstock) AS avg_stock





-- WINDOW FUNCTIONS

-- Penggunaan Window Function sebagai Solusi (This is 'Next Case')
-- Before use Window Function
-- Restock Problem Continuation
/*
Batasan agregasi dan grouping menyebabkan data yang ditam[ilakn tidak representatif.
Hal ini dapat diatasi dengan menggunakan window functions.
*/

SELECT
	productname,
	quantityinstock,
	AVG(quantityinstock) AS avg_stock
FROM
	products
GROUP BY
	productname,
	quantityinstock;

-- Solution: After use Window Function
-- Menampilkan rata-rata stock barang per baris
-- Window function dapat menampilkan rata-rata stock berdampingan dengan stock barang
-- Barang barang yang kurang dari rata-rata akan direstock
SELECT 
	productname,
	quantityinstock,
	AVG(quantityinstock) OVER(ORDER BY quantityinstock ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS avg_stock
FROM
	products;



-- RANGKING CASE
-- DENSE_RANK
/*
Toko ingin melihat apakah harga suatu barang mempengaruhi kuantitas pembelian,
apakah jika barang semakin mahal, maka semakin sedikit yang beli?
Sebaliknya, apakah jika barang semakin murah, maka akan semakin banyak yang beli?

Maka, carilah lakukan analisis terhadap perbandingan harga dan kuantitas pembelian barang!
*/

-- Disimpulkan: 
/*
Harga pembelian kurang berpengaruh terhadap kuantitas pembelian.
Kemungkinan kuantitas pembelian dipengaruhi faktor lain.
*/
SELECT
	productcode,
	priceeach,
	quantityordered,
	DENSE_RANK() OVER(ORDER BY quantityordered DESC) AS quantityRank,
	DENSE_RANK() OVER(ORDER BY priceeach DESC) AS priceRank
FROM
	orderdetails;





-- ANALYTIC CASE
/*
Kemudian, toko ingin melihat karakteristik customer dengan memandingkan
tanggal pembelian dengan pembelian selanjutnya beserta harga belinya. Hal
tersebut untuk menjawab berapa lama yang dibutuhkan customer untuk melakukan 
pembelian selanjutnya dan apakah pembelian selanjutnya jumlah yang dibeli naik
atau turun?

Maka, coba cari perbandingan masing-masing tanggal pembelian dengan pembelian 
selanjutnya beserta harga belinya!
*/

-- Karakteristik customer yang ada cukup variatif.
-- Menandakan segmentasi customer yang bermacam-macam.
SELECT 
	customernumber,
	paymentdate,
	LEAD(paymentdate, 1) OVER(PARTITION BY customernumber ORDER BY paymentdate ASC) AS nextpayment,
	amount,
	LEAD(amount, 1) OVER(PARTITION BY customernumber) AS nextamount
FROM
	payments;


-- ROWS CASE
/*
Terakhir, toko ingin melihat harga termahal ke-N pada setiap jenis miniatur,
kemudian membandingkanya dengan seluruh jenis produk yang ada pada setiap
jenis miniatur.

Maka, coba cari perbandingan harga termahal ke-N pada setiap jenis produk pada setiap jenis miniatur.
*/

-- Hasil bermacam-macam tergantung NTH_VALUE yang diinputkan
-- Rows digunakan sebagai frame
SELECT 
	productname,
	productline,
	buyprice,
	NTH_VALUE(buyprice, 1) OVER(
	PARTITION BY productline ORDER BY buyprice DESC 
	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) AS most_expensive
FROM
	products;

	
