/*
=======================================================================
PROJE ADI: E-Ticaret Veri Analizi ve Müşteri Davranışı Modelleme
AÇIKLAMA: Bu proje, 20.000 satırlık e-ticaret veri seti (FLO) üzerinde 
          gerçekleştirilmiş kapsamlı veri analizi çalışmalarını içermektedir. 
          Geliþmiş SQL sorguları (Subqueries, Aggregations vb.) kullanılarak; 
          - Müşteri Yaþam Boyu Değeri (CLTV) hesaplama altyapısı,
          - Sipariş frekansı ve kanal bazlı ciro analizleri,
          - İş Zekası (BI) ve karar destek sistemleri için temel KPI 
            metrikleri oluşturulmuştur.
=======================================================================
*/


SELECT DB_NAME() AS CurrentDatabase; fasvgafgwrfwhrhrhr nuray lara en iyi yazılımcı awsdjsjssj 
 
SELECT name
FROM sys.databases;

USE FLO;
GO
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES

SELECT *FROM flo_data_20K

--SORU-1:Kaç Farklı müşterinin alışveriş yaptığını gösterecek sorguyu yazınız.
SELECT COUNT(DISTINCT(master_id))
FROM flo_data_20K;
--Soru-2:Toplam -ve cüroyu bulunuz?
SELECT
  SUM(order_num_total_ever_offline+order_num_total_ever_online) AS TOPLAM_SIPARIS_SAYÝSÝ,
  ROUND(SUM(customer_value_total_ever_online+customer_value_total_ever_offline),2) AS TOPLAM_CIRO
FROM flo_data_20K;
--Soru-3 Alışveriş payına düşen ortalam ciroyu bulunuz.
SELECT 
 ROUND(SUM(customer_value_total_ever_online+customer_value_total_ever_offline)/SUM(order_num_total_ever_offline+order_num_total_ever_online),2)
FROM flo_data_20K;
--Soru-4: En son alýþveriþ yapýlan kanal (last_order_channel) üzerinden yapýlan alýþveriþlerin toplam ciro ve alýþveriþ sayýlarýný getirecek sorguyu yazýnýz.  

SELECT 
  last_order_channel,
  SUM(order_num_total_ever_offline+order_num_total_ever_online),
  SUM(customer_value_total_ever_online+customer_value_total_ever_offline)
FROM flo_data_20K
GROUP BY last_order_channel

--SORU-6:STORE TYPE  KIRLIMINDA ELDE EDÝLEN TOPLAM CİROYU GETİREN SORGUYU YAZINIZ. 
SELECT 
  store_type MAGAZA_TURU,
  ROUND(SUM(customer_value_total_ever_online+customer_value_total_ever_offline),2)
FROM flo_data_20K
GROUP BY store_type;
--SORU-7:Yýl kýrýlýmýnda alýþveriþ sayýlarýný getirecek sorguyu yazýnýz (Yýl olarak müþterinin ilk alýþveriþ tarihi (first_order_date) yýlýnI BAZ ALINIZ)
SELECT 
 YEAR(first_order_date) YIL,
 SUM(order_num_total_ever_offline+order_num_total_ever_online)
FROM flo_data_20K
GROUP BY YEAR(first_order_date)
--ORDER BY  2 desc
--SORU-8: En son alýþveriþ yapýlan kanal kýrýlýmýnda alýþveriþ baþýna ortalama ciroyu hesaplayacak sorguyu yazýnýz. 
SELECT last_order_channel,
  ROUND(SUM(customer_value_total_ever_online+customer_value_total_ever_offline)/SUM(order_num_total_ever_offline+order_num_total_ever_online),2)
FROM flo_data_20K
GROUP BY last_order_channel;
--SORU-9:. Son 12 ayda en çok ilgi gören kategoriyi getiren sorguyu yazýnýz
SELECT 
 interested_in_categories_12,
 COUNT(*) FREKANS_BILGIFISI
FROM flo_data_20K
GroUP BY interested_in_categories_12
ORDER BY 2 DESC;
--SORU- 10. En çok tercih edilen store_type bilgisini getiren sorguyu yazýnýz. 
SELECT TOP 1
 store_type,
 COUNT(*) FREKANS_BILGIFISI
FROM flo_data_20K
GROUP BY store_type
ORDER BY 2 DESC;




-- SORU-11: En son alýþveriþ yapýlan kanal (last_order_channel) kýrýlýmýnda 
-- en çok sipariþ alýnan kategoriyi getiren sorguyu yazýnýz.
SELECT DISTINCT last_order_channel,
    (
        SELECT TOP 1 interested_in_categories_12
        FROM flo_data_20K
        WHERE last_order_channel = f.last_order_channel
        GROUP BY interested_in_categories_12
        ORDER BY SUM(order_num_total_ever_offline + order_num_total_ever_online) DESC
    ) AS EN_COK_SIPARIS_ALINAN_KATEGORI
FROM flo_data_20K f;


-- SORU-12: En çok alýþveriþ yapan (ciro bazýnda) kiþinin ID'sini getiren sorguyu yazýnýz.
SELECT TOP 1 master_id
FROM flo_data_20K
GROUP BY master_id
ORDER BY SUM(customer_value_total_ever_offline + customer_value_total_ever_online) DESC;


-- SORU-13 & 14: En çok alýþveriþ yapan (ciro bazýnda) ilk 100 kiþinin alýþveriþ baþýna 
-- ortalama cirosunu ve alýþveriþ yapma gün ortalamasýný (alýþveriþ sýklýðýný) getiren sorgu.
SELECT 
    D.master_id,
    D.TOPLAM_CIRO,
    D.TOPLAM_SIPARIS_SAYISI,
    ROUND((D.TOPLAM_CIRO / D.TOPLAM_SIPARIS_SAYISI), 2) AS SIPARIS_BASINA_ORTALAMA,
    DATEDIFF(DAY, first_order_date, last_order_date) AS ILK_SON_ALVRS_GUN_FRK,
    ROUND((CAST(DATEDIFF(DAY, first_order_date, last_order_date) AS FLOAT) / D.TOPLAM_SIPARIS_SAYISI), 1) AS ALISVERIS_GUN_ORT
FROM 
    (
    SELECT TOP 100 
        master_id,
        first_order_date,
        last_order_date,
        SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAM_CIRO,
        SUM(order_num_total_ever_offline + order_num_total_ever_online) AS TOPLAM_SIPARIS_SAYISI
    FROM flo_data_20K
    GROUP BY master_id, first_order_date, last_order_date
    ORDER BY TOPLAM_CIRO DESC
    ) D;


-- SORU-15: En son alýþveriþ yapýlan kanal (last_order_channel) kýrýlýmýnda 
-- en çok alýþveriþ yapan müþteriyi getiren sorguyu yazýnýz.
SELECT DISTINCT last_order_channel,
    (
        SELECT TOP 1 master_id
        FROM flo_data_20K
        WHERE last_order_channel = f.last_order_channel
        GROUP BY master_id
        ORDER BY SUM(customer_value_total_ever_offline + customer_value_total_ever_online) DESC
    ) AS EN_COK_ALISVERIS_YAPAN_MUSTERI
FROM flo_data_20K f;


-- SORU-16: En son alışveriş yapan kişinin ID'sini getiren sorguyu yazınız. (Max son tarihe göre)
SELECT TOP 1 master_id, last_order_date
FROM flo_data_20K
ORDER BY last_order_date DESC;

