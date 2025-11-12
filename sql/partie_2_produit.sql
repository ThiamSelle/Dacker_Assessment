----- Partie 2 : Analyse Produit
--- Question 1. Ecrivez une requête SQL qui permet d’obtenir pour chaque produit

.print "QUESTION 1 : KPIs par produit"


SELECT
    oi.product_id,
    p.name AS product_name,
    p.category,
    SUM(oi.quantity) AS quantite_totale_vendue,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenu_total,
    ROUND(AVG(oi.unit_price), 2) AS prix_moyen_vente,
    COUNT(DISTINCT o.customer_id) AS nb_clients_distincts,
    MIN(o.created_at) AS date_premiere_vente
FROM order_items_clean oi
JOIN orders_clean o ON oi.order_id = o.id
LEFT JOIN products p ON oi.product_id = p.id
GROUP BY oi.product_id, p.name, p.category
ORDER BY revenu_total DESC;


.print ""
.print "QUESTION 2 -- Pour chaque produit, identification du pays où il est le PLUS vendu (en quantité)"
.print ""

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
            ORDER BY total_quantity DESC, shipping_country ASC
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


.print ""
.print "QUESTION 3-- Identification des produits générant le PLUS de valeur par commande"
.print ""

SELECT
    oi.product_id,
    p.name AS product_name,
    p.category,
    COUNT(DISTINCT oi.order_id) AS nb_commandes,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenu_total,
    ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT oi.order_id), 2) AS revenu_moyen_par_commande
FROM order_items_clean oi
LEFT JOIN products p ON oi.product_id = p.id
GROUP BY oi.product_id, p.name, p.category
ORDER BY revenu_moyen_par_commande DESC
LIMIT 3;
