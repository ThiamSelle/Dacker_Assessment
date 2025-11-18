-- ========================================================================
-- EXPORT DASHBOARD - PARTIE 6 : VISUALISATION
-- ========================================================================

.mode csv
.headers on

-- ========================================================================
-- Export 1: KPIs par produit
-- ========================================================================
.output data/dashboard/kpis_produit.csv
SELECT
    oi.product_id,
    p.name AS product_name,
    p.category,
    SUM(oi.quantity) AS quantite_totale_vendue,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenu_total,
    ROUND(AVG(oi.unit_price), 2) AS prix_moyen_vente,
    COUNT(DISTINCT o.customer_id) AS nb_clients_distincts,
    STRFTIME('%Y-%m-%d', MIN(o.created_at)) AS date_premiere_vente
FROM order_items_clean oi
JOIN orders_clean o ON oi.order_id = o.id
LEFT JOIN products p ON oi.product_id = p.id
WHERE o.status = 'shipped'
GROUP BY oi.product_id, p.name, p.category
ORDER BY revenu_total DESC;

-- ========================================================================
-- Export 2: Distribution géographique
-- ========================================================================
.output data/dashboard/ventes_geographiques.csv
SELECT
    oi.product_id,
    p.name AS product_name,
    p.category,
    o.shipping_country AS pays,
    COUNT(DISTINCT o.id) AS nb_commandes,
    SUM(oi.quantity) AS quantite_totale,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenu_total,
    ROUND(AVG(oi.quantity * oi.unit_price), 2) AS panier_moyen
FROM order_items_clean oi
JOIN orders_clean o ON oi.order_id = o.id
LEFT JOIN products p ON oi.product_id = p.id
WHERE o.status = 'shipped'
  AND o.shipping_country IN ('FR', 'DE', 'IT', 'ES', 'BE')
GROUP BY oi.product_id, p.name, p.category, o.shipping_country
ORDER BY oi.product_id, revenu_total DESC;

-- ========================================================================
-- Export 3: Pays dominant par produit
-- ========================================================================
.output data/dashboard/produit_pays_top.csv
WITH product_country_sales AS (
    SELECT
        oi.product_id,
        p.name AS product_name,
        o.shipping_country,
        SUM(oi.quantity) AS total_quantity
    FROM order_items_clean oi
    JOIN orders_clean o ON oi.order_id = o.id
    LEFT JOIN products p ON oi.product_id = p.id
    WHERE o.shipping_country IN ('FR', 'DE', 'IT', 'ES', 'BE')
      AND o.status = 'shipped'
    GROUP BY oi.product_id, p.name, o.shipping_country
),
ranked_countries AS (
    SELECT
        product_id,
        product_name,
        shipping_country,
        total_quantity,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY total_quantity DESC, shipping_country
        ) AS rank
    FROM product_country_sales
)
SELECT
    product_id,
    product_name,
    shipping_country AS pays_top_ventes,
    total_quantity AS quantite_vendue
FROM ranked_countries
WHERE rank = 1
ORDER BY total_quantity DESC;


-- ========================================================================
-- Export 4: Top 3 produits premium
-- ========================================================================
.output data/dashboard/produits_premium.csv
SELECT
    oi.product_id,
    p.name AS product_name,
    p.category,
    COUNT(DISTINCT oi.order_id) AS nb_commandes,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenu_total,
    ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT oi.order_id), 2) AS revenu_moyen_par_commande
FROM order_items_clean oi
JOIN orders_clean o ON oi.order_id = o.id
LEFT JOIN products p ON oi.product_id = p.id
WHERE o.status = 'shipped'
GROUP BY oi.product_id, p.name, p.category
ORDER BY revenu_moyen_par_commande DESC
LIMIT 3;

-- ========================================================================
-- Retour à l'affichage terminal et messages de confirmation
-- ========================================================================
.output stdout

.print ""
.print "========================================"
.print "EXPORT TERMINE"
.print "========================================"
.print ""
.print "4 fichiers generes dans data/dashboard/"
.print "1. kpis_produit.csv"
.print "2. ventes_geographiques.csv"
.print "3. produit_pays_top.csv"
.print "4. produits_premium.csv"
.print ""