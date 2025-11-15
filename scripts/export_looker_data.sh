#!/bin/bash

echo "📊 Export des données pour Looker Studio (corrigé)..."

sqlite3 data/dacker.db <<SQL
.mode csv
.headers on

-- 1. KPIs par produit
.output data/dashboard/kpis_produit.csv
SELECT 
    oi.product_id as product_id,
    p.name AS product_name,
    p.category as category,
    SUM(oi.quantity) AS quantite_totale_vendue,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenu_total,
    ROUND(AVG(oi.unit_price), 2) AS prix_moyen_vente,
    COUNT(DISTINCT o.customer_id) AS nb_clients_distincts
FROM order_items_clean oi
JOIN orders_clean o ON oi.order_id = o.id
LEFT JOIN products p ON oi.product_id = p.id
GROUP BY oi.product_id, p.name, p.category
ORDER BY revenu_total DESC;

-- 2. Distribution géographique
.output data/dashboard/ventes_geographiques.csv
SELECT 
    oi.product_id as product_id,
    p.name AS product_name,
    p.category as category,
    o.shipping_country AS pays,
    COUNT(DISTINCT o.id) AS nb_commandes,
    SUM(oi.quantity) AS quantite_totale,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenu_total
FROM order_items_clean oi
JOIN orders_clean o ON oi.order_id = o.id
LEFT JOIN products p ON oi.product_id = p.id
WHERE o.shipping_country IN ('FR', 'DE', 'IT', 'ES', 'BE')
GROUP BY oi.product_id, p.name, p.category, o.shipping_country
ORDER BY oi.product_id, revenu_total DESC;

-- 3. Pays top par produit
.output data/dashboard/produit_pays_top.csv
WITH product_country_sales AS (
    SELECT 
        oi.product_id as product_id,
        p.name AS product_name,
        p.category as category,
        o.shipping_country AS pays,
        SUM(oi.quantity) AS total_quantity,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenu_total
    FROM order_items_clean oi
    JOIN orders_clean o ON oi.order_id = o.id
    LEFT JOIN products p ON oi.product_id = p.id
    WHERE o.shipping_country IN ('FR', 'DE', 'IT', 'ES', 'BE')
    GROUP BY oi.product_id, p.name, p.category, o.shipping_country
),
ranked_countries AS (
    SELECT 
        product_id,
        product_name,
        category,
        pays,
        total_quantity,
        revenu_total,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY total_quantity DESC) AS rank
    FROM product_country_sales
)
SELECT 
    product_id,
    product_name,
    category,
    pays AS pays_top_ventes,
    total_quantity AS quantite_vendue,
    revenu_total
FROM ranked_countries
WHERE rank = 1
ORDER BY total_quantity DESC;

-- 4. Analyse premium
.output data/dashboard/produits_premium.csv
SELECT 
    oi.product_id as product_id,
    p.name AS product_name,
    p.category as category,
    COUNT(DISTINCT oi.order_id) AS nb_commandes,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenu_total,
    ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT oi.order_id), 2) AS revenu_moyen_par_commande
FROM order_items_clean oi
LEFT JOIN products p ON oi.product_id = p.id
GROUP BY oi.product_id, p.name, p.category
ORDER BY revenu_moyen_par_commande DESC;

.output stdout
SQL

echo "✅ Export terminé !"
ls -lh data/dashboard/ 
