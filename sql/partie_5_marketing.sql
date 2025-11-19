-- PARTIE 5 - MARKETING & MEDIA (VERSION CORRIGÉE)
.mode column
.headers on
.width 12 20 12 12 12 12 12 12 12


-- ====================================================================
-- EXPLORATION : Table campaigns
-- ====================================================================

.print ""
.print "========================================"
.print "EXPLORATION : Table campaigns"
.print "========================================"
.print ""

SELECT
    id,
    campaign_name,
    start_date,
    end_date,
    channel,
    budget
FROM campaigns
ORDER BY id;

.print ""
.print ""


-- ====================================================================
-- EXPLORATION : Table attribution
-- ====================================================================

.print ""
.print "========================================"
.print "EXPLORATION : Table attribution"
.print "========================================"
.print ""

SELECT
    order_id,
    campaign_id,
    COUNT(*) as nb_attributions
FROM attribution
GROUP BY order_id, campaign_id
LIMIT 20;

.print ""
.print ""


-- ====================================================================
-- EXPLORATION : Statistiques globales
-- ====================================================================

.print ""
.print "========================================"
.print "STATISTIQUES GLOBALES attribution"
.print "========================================"
.print ""

SELECT
    COUNT(DISTINCT order_id) as commandes_avec_attribution,
    COUNT(DISTINCT campaign_id) as campagnes_ayant_genere_commandes,
    COUNT(*) as total_lignes_attribution
FROM attribution;

.print ""
.print ""


-- ====================================================================
-- QUESTION 1 : Métriques de performance par campagne (CORRIGÉE)
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 1 : Performance par campagne"
.print "========================================"
.print ""
.print "Calcul ROAS, CAC, panier moyen, pourcentage nouveaux clients"
.print "VERSION CORRIGEE avec deduplication nouveaux clients"
.print ""

WITH order_revenues AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at,
        ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    WHERE o.status = 'shipped'
    GROUP BY o.id, o.customer_id, o.created_at
),
first_orders AS (
    SELECT
        customer_id,
        MIN(created_at) AS date_premiere_commande
    FROM orders_clean
    WHERE status = 'shipped'
    GROUP BY customer_id
),
attributed_orders AS (
    SELECT
        a.campaign_id,
        a.order_id,
        orv.customer_id,
        orv.montant_commande,
        CASE
            WHEN orv.created_at = fo.date_premiere_commande THEN 1
            ELSE 0
        END AS est_nouveau_client
    FROM attribution a
    JOIN order_revenues orv ON a.order_id = orv.order_id
    JOIN first_orders fo ON orv.customer_id = fo.customer_id
),
attributed_orders_deduplicated AS (
    SELECT DISTINCT
        campaign_id,
        order_id,
        customer_id,
        montant_commande,
        est_nouveau_client
    FROM attributed_orders
),
campaign_metrics AS (
    SELECT
        c.id AS campaign_id,
        c.campaign_name,
        c.channel,
        c.start_date,
        c.end_date,
        c.budget,
        COUNT(DISTINCT ao.order_id) AS total_commandes,
        ROUND(SUM(ao.montant_commande), 2) AS revenu_total,
        COUNT(DISTINCT CASE WHEN ao.est_nouveau_client = 1 THEN ao.customer_id END) AS nb_nouveaux_clients,
        COUNT(DISTINCT ao.customer_id) AS nb_clients_totaux
    FROM campaigns c
    LEFT JOIN attributed_orders_deduplicated ao ON c.id = ao.campaign_id
    GROUP BY c.id, c.campaign_name, c.channel, c.start_date, c.end_date, c.budget
)
SELECT
    campaign_id,
    campaign_name,
    channel,
    start_date,
    end_date,
    budget,
    total_commandes,
    revenu_total,
    nb_nouveaux_clients,
    nb_clients_totaux,
    ROUND(revenu_total / NULLIF(budget, 0), 2) AS roas,
    ROUND(budget / NULLIF(nb_nouveaux_clients, 0), 2) AS cac,
    ROUND(revenu_total / NULLIF(total_commandes, 0), 2) AS panier_moyen,
    ROUND(100.0 * nb_nouveaux_clients / NULLIF(nb_clients_totaux, 0), 2) AS pct_nouveaux_clients
FROM campaign_metrics
ORDER BY roas DESC;

.print ""
.print ""


-- ====================================================================
-- QUESTION 2a : Campagne la plus rentable (ROAS maximum)
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 2a : Campagne plus rentable"
.print "========================================"
.print ""
.print "Campagne avec le ROAS le plus eleve"
.print ""

WITH order_revenues AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at,
        ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    WHERE o.status = 'shipped'
    GROUP BY o.id, o.customer_id, o.created_at
),
first_orders AS (
    SELECT
        customer_id,
        MIN(created_at) AS date_premiere_commande
    FROM orders_clean
    WHERE status= 'shipped'
    GROUP BY customer_id
),
attributed_orders AS (
    SELECT
        a.campaign_id,
        a.order_id,
        orv.customer_id,
        orv.montant_commande,
        CASE
            WHEN orv.created_at = fo.date_premiere_commande THEN 1
            ELSE 0
        END AS est_nouveau_client
    FROM attribution a
    JOIN order_revenues orv ON a.order_id = orv.order_id
    JOIN first_orders fo ON orv.customer_id = fo.customer_id
),
attributed_orders_deduplicated AS (
    SELECT DISTINCT
        campaign_id,
        order_id,
        customer_id,
        montant_commande,
        est_nouveau_client
    FROM attributed_orders
),
campaign_metrics AS (
    SELECT
        c.id AS campaign_id,
        c.campaign_name,
        c.channel,
        c.budget,
        COUNT(DISTINCT ao.order_id) AS total_commandes,
        ROUND(SUM(ao.montant_commande), 2) AS revenu_total,
        COUNT(DISTINCT CASE WHEN ao.est_nouveau_client = 1 THEN ao.customer_id END) AS nb_nouveaux_clients
    FROM campaigns c
    LEFT JOIN attributed_orders_deduplicated ao ON c.id = ao.campaign_id
    GROUP BY c.id, c.campaign_name, c.channel, c.budget
)
SELECT
    campaign_name,
    channel,
    budget,
    total_commandes,
    revenu_total,
    nb_nouveaux_clients,
    ROUND(revenu_total / NULLIF(budget, 0), 2) AS roas,
    ROUND(revenu_total - budget, 2) AS profit_net,
    ROUND(budget / NULLIF(nb_nouveaux_clients, 0), 2) AS cac
FROM campaign_metrics
WHERE total_commandes > 0 AND budget > 0
ORDER BY roas DESC
LIMIT 1;

.print ""
.print ""


-- ====================================================================
-- QUESTION 2b : Campagne plus efficace acquisition (CAC minimum)
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 2b : Campagne meilleure acquisition"
.print "========================================"
.print ""
.print "Campagne avec le CAC le plus faible"
.print ""

WITH order_revenues AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at,
        ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    GROUP BY o.id, o.customer_id, o.created_at
),
first_orders AS (
    SELECT
        customer_id,
        MIN(created_at) AS date_premiere_commande
    FROM orders_clean
    WHERE status = 'shipped'
    GROUP BY customer_id
),
attributed_orders AS (
    SELECT
        a.campaign_id,
        a.order_id,
        orv.customer_id,
        orv.montant_commande,
        CASE
            WHEN orv.created_at = fo.date_premiere_commande THEN 1
            ELSE 0
        END AS est_nouveau_client
    FROM attribution a
    JOIN order_revenues orv ON a.order_id = orv.order_id
    JOIN first_orders fo ON orv.customer_id = fo.customer_id
),
attributed_orders_deduplicated AS (
    SELECT DISTINCT
        campaign_id,
        order_id,
        customer_id,
        montant_commande,
        est_nouveau_client
    FROM attributed_orders
),
campaign_metrics AS (
    SELECT
        c.id AS campaign_id,
        c.campaign_name,
        c.channel,
        c.budget,
        COUNT(DISTINCT ao.order_id) AS total_commandes,
        ROUND(SUM(ao.montant_commande), 2) AS revenu_total,
        COUNT(DISTINCT CASE WHEN ao.est_nouveau_client = 1 THEN ao.customer_id END) AS nb_nouveaux_clients
    FROM campaigns c
    LEFT JOIN attributed_orders_deduplicated ao ON c.id = ao.campaign_id
    GROUP BY c.id, c.campaign_name, c.channel, c.budget
)
SELECT
    campaign_name,
    channel,
    budget,
    nb_nouveaux_clients,
    ROUND(budget / NULLIF(nb_nouveaux_clients, 0), 2) AS cac,
    ROUND(revenu_total / NULLIF(nb_nouveaux_clients, 0), 2) AS revenu_par_nouveau_client,
    ROUND(revenu_total / NULLIF(budget, 0), 2) AS roas
FROM campaign_metrics
WHERE nb_nouveaux_clients > 0
ORDER BY cac ASC
LIMIT 1;

.print ""
.print ""


-- ====================================================================
-- QUESTION 3 : Organique vs Marketing
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 3 : Organique vs Marketing"
.print "========================================"
.print ""
.print "Repartition globale des commandes et revenus"
.print ""

WITH order_revenues AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at,
        ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    WHERE o.status = 'shipped'
    GROUP BY o.id, o.customer_id, o.created_at
),
orders_with_attribution AS (
    SELECT
        orv.order_id,
        orv.montant_commande,
        CASE
            WHEN a.order_id IS NOT NULL THEN 'Marketing'
            ELSE 'Organique'
        END AS source
    FROM order_revenues orv
    LEFT JOIN (SELECT DISTINCT order_id FROM attribution) a ON orv.order_id = a.order_id
)
SELECT
    source,
    COUNT(DISTINCT order_id) AS nb_commandes,
    ROUND(100.0 * COUNT(DISTINCT order_id) / (SELECT COUNT(DISTINCT order_id) FROM orders_with_attribution), 2) AS pct_commandes,
    ROUND(SUM(montant_commande), 2) AS revenu_total,
    ROUND(100.0 * SUM(montant_commande) / (SELECT SUM(montant_commande) FROM orders_with_attribution), 2) AS pct_revenu,
    ROUND(AVG(montant_commande), 2) AS panier_moyen
FROM orders_with_attribution
GROUP BY source
ORDER BY nb_commandes DESC;

.print ""
.print ""


-- ====================================================================
-- QUESTION 3b : Détail par canal
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 3b : Detail par canal"
.print "========================================"
.print ""
.print "Repartition par canal marketing vs organique"
.print ""

WITH order_revenues AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at,
        ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    WHERE o.status = 'shipped'
    GROUP BY o.id, o.customer_id, o.created_at
),
attribution_deduplicated AS (
    SELECT DISTINCT
        order_id,
        campaign_id
    FROM attribution
),
orders_with_channel AS (
    SELECT
        orv.order_id,
        orv.montant_commande,
        COALESCE(c.channel, 'Organique') AS channel
    FROM order_revenues orv
    LEFT JOIN attribution_deduplicated a ON orv.order_id = a.order_id
    LEFT JOIN campaigns c ON a.campaign_id = c.id
)
SELECT
    channel,
    COUNT(DISTINCT order_id) AS nb_commandes,
    ROUND(100.0 * COUNT(DISTINCT order_id) / (SELECT COUNT(DISTINCT order_id) FROM orders_with_channel), 2) AS pct_commandes,
    ROUND(SUM(montant_commande), 2) AS revenu_total,
    ROUND(100.0 * SUM(montant_commande) / (SELECT SUM(montant_commande) FROM orders_with_channel), 2) AS pct_revenu,
    ROUND(AVG(montant_commande), 2) AS panier_moyen
FROM orders_with_channel
GROUP BY channel
ORDER BY revenu_total DESC;

.print ""
.print ""