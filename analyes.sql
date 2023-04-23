###  源本
SELECT ttso.merchant_id                                         商户号,
       ttso.channel_id                                          渠道ID,
       ttso.channel_name                                        渠道名称,
       ttso.project                                             项目,
       ttso.merchant_partner_id                                 合作者ID,
       ttso.merchant_partner_name                               合作名称,
       ttso.settle_order_id                                     权责单号,
       ttso.order_id                                            订单系统单号,
       ttso.order_amount                                        订单总金额,
       ttso.order_days                                          剩余天数,
       ttso.settle_order_status                                 订单状态,
       ttso.user_id                                             用户ID,
       ttso.product_id                                          产品ID,
       ttso.product_name                                        产品名称,
       DATE_FORMAT(ttso.order_create_time, '%Y-%m-%d %H:%i:%S') 创建时间
FROM settle_db.t_settle_order ttso
         LEFT JOIN (SELECT ts.settle_order_id,
                           SUM(ts.amount) amounts
                    FROM settle_db.t_settle_order tso
                             LEFT JOIN settle_db.t_settle ts ON tso.settle_order_id = ts.settle_order_id
                    WHERE ts.settle_date >= '2023-03-26'
                      AND ts.settle_date <= '2023-04-25'
                    GROUP BY ts.settle_order_id) temp1 ON ttso.settle_order_id = temp1.settle_order_id
         LEFT JOIN (

                    SELECT t1.settle_order_id, t1.amount_left_after
                    FROM settle_db.t_order_record t1
                             JOIN (SELECT settle_order_id, MAX(gmt_create_time) AS max_create_time
                                   FROM settle_db.t_order_record
                                   GROUP BY settle_order_id) t2
                                  ON t1.settle_order_id = t2.settle_order_id AND t1.gmt_create_time = t2.max_create_time
                    ORDER BY t1.settle_order_id

                    ) temp2 ON ttso.settle_order_id = temp2.settle_order_id
WHERE ttso.gmt_create_time <= '2023-04-26 00:00:00'
  AND (ttso.product_id in (SELECT SKU_ID
                           FROM product_db.sku
                           WHERE SPU_ID IN
                                 (616033385120145408, 606006895667474432, 604867430517469184, 617558351951032320,
                                  607772196816760832, 660726140378595328, 518250606261682176, 671901672485761024,
                                  646548062326067200, 677367086202400768, 706387613478727680, 518354503006023680,
                                  607345336890896384, 655594356162469888, 607772306851393536, 663170912619634688,
                                  570159313803227136, 587087300621660160, 702009110203281408, 612474630977757184,
                                  585606649766637568, 607772437729193984, 681267386357297152, 616117072419495936,
                                  674770530246668288, 607772619918438400, 610654841599234048, 720472075650428928,
                                  720475710821306368, 739308062125133824, 762133667131387904, 762860628859490304,
                                  765051832576471040, 803043119838924800, 812938639361314816, 849810756241666048)))
  AND ttso.channel_id = '1';



### explain analyes 
-> Nested loop left join  (cost=572393.12 rows=0) (actual time=1668.727..2405.739 rows=89687 loops=1)
    -> Nested loop left join  (cost=81803.70 rows=0) (actual time=614.193..934.462 rows=89683 loops=1)
        -> Remove duplicate ttso rows using temporary table (weedout)  (cost=34176.00 rows=301) (actual time=37.666..299.809 rows=89683 loops=1)
            -> Inner hash join (ttso.product_id = product_db.sku.SKU_ID)  (cost=34176.00 rows=301) (actual time=37.659..160.047 rows=89683 loops=1)
                -> Filter: ((ttso.gmt_create_time <= TIMESTAMP'2023-04-26 00:00:00') and (ttso.channel_id = '1'))  (cost=839.68 rows=635) (actual time=0.125..122.574 rows=195816 loops=1)
                    -> Table scan on ttso  (cost=839.68 rows=190510) (actual time=0.122..107.715 rows=195824 loops=1)
                -> Hash
                    -> Filter: (product_db.sku.SPU_ID in (616033385120145408,606006895667474432,604867430517469184,617558351951032320,607772196816760832,660726140378595328,518250606261682176,671901672485761024,646548062326067200,677367086202400768,706387613478727680,518354503006023680,607345336890896384,655594356162469888,607772306851393536,663170912619634688,570159313803227136,587087300621660160,702009110203281408,612474630977757184,585606649766637568,607772437729193984,681267386357297152,616117072419495936,674770530246668288,607772619918438400,610654841599234048,720472075650428928,720475710821306368,739308062125133824,762133667131387904,762860628859490304,765051832576471040,803043119838924800,812938639361314816,849810756241666048))  (cost=29.90 rows=142) (actual time=0.104..1.205 rows=73 loops=1)
                        -> Table scan on sku  (cost=29.90 rows=284) (actual time=0.091..1.013 rows=284 loops=1)
        -> Index lookup on temp1 using <auto_key0> (settle_order_id=ttso.settle_order_id)  (cost=0.25..2.50 rows=10) (actual time=0.007..0.007 rows=0 loops=89683)
            -> Materialize  (cost=0.00..0.00 rows=0) (actual time=576.521..576.521 rows=12726 loops=1)
                -> Table scan on <temporary>  (actual time=568.829..570.127 rows=12726 loops=1)
                    -> Aggregate using temporary table  (actual time=568.826..568.826 rows=12725 loops=1)
                        -> Nested loop inner join  (cost=1074916.86 rows=493232) (actual time=0.053..378.316 rows=235133 loops=1)
                            -> Filter: (ts.settle_order_id is not null)  (cost=591879.41 rows=493232) (actual time=0.042..198.279 rows=235133 loops=1)
                                -> Index range scan on ts using settle_ind2 over ('2023-03-26' <= settle_date <= '2023-04-25'), with index condition: ((ts.settle_date >= DATE'2023-03-26') and (ts.settle_date <= DATE'2023-04-25'))  (cost=591879.41 rows=493232) (actual time=0.041..190.426 rows=235133 loops=1)
                            -> Single-row covering index lookup on tso using PRIMARY (settle_order_id=ts.settle_order_id)  (cost=0.88 rows=1) (actual time=0.001..0.001 rows=1 loops=235133)
    -> Nested loop inner join  (cost=2272863.56 rows=182649) (actual time=0.016..0.016 rows=1 loops=89683)
        -> Index lookup on t2 using <auto_key1> (settle_order_id=ttso.settle_order_id)  (cost=292238.65..292240.98 rows=10) (actual time=0.013..0.013 rows=1 loops=89683)
            -> Materialize  (cost=292238.40..292238.40 rows=182649) (actual time=1054.509..1054.509 rows=199063 loops=1)
                -> Covering index skip scan for grouping on t_order_record using settle_order_id_gmt_create_time_index  (cost=273973.50 rows=182649) (actual time=0.842..791.306 rows=199063 loops=1)
        -> Covering index lookup on t1 using settle_order_id_gmt_create_time_index (settle_order_id=ttso.settle_order_id, gmt_create_time=t2.max_create_time)  (cost=1.00 rows=1) (actual time=0.003..0.003 rows=1 loops=89683)



