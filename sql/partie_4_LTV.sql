
-- PARTIE 4 - COHORTES & LIFETIME VALUE (LTV)
-- Question 1: Association de chaque commande avec la date de première commande du client

WITH first_order_dates AS (
    SELECT
        customer_id,
        MIN(created_at) AS date_premiere_commande
    FROM orders_clean
    GROUP BY customer_id
)
SELECT
    o.id AS order_id,
    o.customer_id,
    o.created_at AS date_commande,
    o.status AS statut_commande,
    o.shipping_country,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS montant_commande,
    fod.date_premiere_commande,
    ROUND((JULIANDAY(o.created_at) - JULIANDAY(fod.date_premiere_commande)) / 30.0, 1) AS mois_depuis_premiere_commande
FROM orders_clean o
JOIN first_order_dates fod ON o.customer_id = fod.customer_id
LEFT JOIN order_items_clean oi ON o.id = oi.order_id
GROUP BY o.id, o.customer_id, o.created_at, o.status, o.shipping_country, fod.date_premiere_commande
ORDER BY o.customer_id, o.created_at
LIMIT 20;

-- Question 2: Calcul de la LTV par cohorte mensuelle

WITH first_order_dates AS (
    SELECT
        customer_id,
        MIN(created_at) AS date_premiere_commande,
        STRFTIME('%Y-%m', MIN(created_at)) AS cohorte_mois
    FROM orders_clean
    GROUP BY customer_id
),
orders_with_cohort AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at AS date_commande,
        STRFTIME('%Y-%m', o.created_at) AS mois_commande,
        fod.date_premiere_commande,
        fod.cohorte_mois,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS montant_commande,
        CAST((STRFTIME('%Y', o.created_at) - STRFTIME('%Y', fod.date_premiere_commande)) * 12 +
             (STRFTIME('%m', o.created_at) - STRFTIME('%m', fod.date_premiere_commande)) AS INTEGER) AS mois_depuis_acquisition
    FROM orders_clean o
    JOIN first_order_dates fod ON o.customer_id = fod.customer_id
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    GROUP BY o.id, o.customer_id, o.created_at, fod.date_premiere_commande, fod.cohorte_mois
),
ltv_by_cohort_and_month AS (
    SELECT
        cohorte_mois AS premier_mois_achat,
        mois_depuis_acquisition AS mois_depuis_premiere_commande,
        COUNT(DISTINCT customer_id) AS nb_clients_actifs,
        ROUND(SUM(montant_commande), 2) AS depenses_periode,
        ROUND(AVG(montant_commande), 2) AS panier_moyen_periode
    FROM orders_with_cohort
    GROUP BY cohorte_mois, mois_depuis_acquisition
)
SELECT
    premier_mois_achat,
    mois_depuis_premiere_commande AS mois,
    nb_clients_actifs,
    depenses_periode,
    panier_moyen_periode,
    ROUND(SUM(depenses_periode) OVER (
        PARTITION BY premier_mois_achat
        ORDER BY mois_depuis_premiere_commande
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS ltv_cumulee
FROM ltv_by_cohort_and_month
ORDER BY premier_mois_achat, mois_depuis_premiere_commande;

-- Création de la table ltv_cohorts pour les analyses ultérieures

DROP TABLE IF EXISTS ltv_cohorts;

CREATE TABLE ltv_cohorts AS
WITH first_order_dates AS (
    SELECT
        customer_id,
        MIN(created_at) AS date_premiere_commande,
        STRFTIME('%Y-%m', MIN(created_at)) AS cohorte_mois
    FROM orders_clean
    GROUP BY customer_id
),
orders_with_cohort AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at AS date_commande,
        STRFTIME('%Y-%m', o.created_at) AS mois_commande,
        fod.date_premiere_commande,
        fod.cohorte_mois,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS montant_commande,
        CAST((STRFTIME('%Y', o.created_at) - STRFTIME('%Y', fod.date_premiere_commande)) * 12 +
             (STRFTIME('%m', o.created_at) - STRFTIME('%m', fod.date_premiere_commande)) AS INTEGER) AS mois_depuis_acquisition
    FROM orders_clean o
    JOIN first_order_dates fod ON o.customer_id = fod.customer_id
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    GROUP BY o.id, o.customer_id, o.created_at, fod.date_premiere_commande, fod.cohorte_mois
),
ltv_by_cohort_and_month AS (
    SELECT
        cohorte_mois AS premier_mois_achat,
        mois_depuis_acquisition AS mois_depuis_premiere_commande,
        COUNT(DISTINCT customer_id) AS nb_clients_actifs,
        ROUND(SUM(montant_commande), 2) AS depenses_periode,
        ROUND(AVG(montant_commande), 2) AS panier_moyen_periode
    FROM orders_with_cohort
    GROUP BY cohorte_mois, mois_depuis_acquisition
)
SELECT
    premier_mois_achat,
    mois_depuis_premiere_commande AS mois,
    nb_clients_actifs,
    depenses_periode,
    panier_moyen_periode,
    ROUND(SUM(depenses_periode) OVER (
        PARTITION BY premier_mois_achat
        ORDER BY mois_depuis_premiere_commande
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS ltv_cumulee
FROM ltv_by_cohort_and_month
ORDER BY premier_mois_achat, mois_depuis_premiere_commande;