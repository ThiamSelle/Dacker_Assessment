
-- PARTIE 5 - MARKETING & MEDIA

-- Exploration de la table campaigns
SELECT
    id,
    campaign_name,
    start_date,
    end_date,
    channel,
    budget
FROM campaigns
ORDER BY id;

-- Exploration de la table attribution
SELECT
    order_id,
    campaign_id,
    COUNT(*) as nb_attributions
FROM attribution
GROUP BY order_id, campaign_id
LIMIT 20;

-- Statistiques globales sur l'attribution
SELECT
    COUNT(DISTINCT order_id) as commandes_avec_attribution,
    COUNT(DISTINCT campaign_id) as campagnes_ayant_genere_commandes,
    COUNT(*) as total_lignes_attribution
FROM attribution;


-- Question 1: Metriques de performance par campagne

WITH order_revenues AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    GROUP BY o.id, o.customer_id, o.created_at
),
first_orders AS (
    SELECT
        customer_id,
        MIN(created_at) AS date_premiere_commande
    FROM orders_clean
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
        SUM(ao.est_nouveau_client) AS nb_nouveaux_clients,
        COUNT(DISTINCT ao.customer_id) AS nb_clients_totaux
    FROM campaigns c
    LEFT JOIN attributed_orders ao ON c.id = ao.campaign_id
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
    ROUND(100.0 * nb_nouveaux_clients / NULLIF(nb_clients_totaux, 0), 2) AS pourcentage_nouveaux_clients
FROM campaign_metrics
ORDER BY roas DESC;


-- Question 2a: Campagne la plus rentable ROAS maximum

WITH order_revenues AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    GROUP BY o.id, o.customer_id, o.created_at
),
first_orders AS (
    SELECT
        customer_id,
        MIN(created_at) AS date_premiere_commande
    FROM orders_clean
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
campaign_metrics AS (
    SELECT
        c.id AS campaign_id,
        c.campaign_name,
        c.channel,
        c.budget,
        COUNT(DISTINCT ao.order_id) AS total_commandes,
        ROUND(SUM(ao.montant_commande), 2) AS revenu_total,
        SUM(ao.est_nouveau_client) AS nb_nouveaux_clients
    FROM campaigns c
    LEFT JOIN attributed_orders ao ON c.id = ao.campaign_id
    GROUP BY c.id, c.campaign_name, c.channel, c.budget
)
SELECT
    campaign_name,
    channel,
    budget,
    total_commandes,
    revenu_total,
    ROUND(revenu_total / NULLIF(budget, 0), 2) AS roas,
    ROUND(revenu_total - budget, 2) AS profit_net
FROM campaign_metrics
WHERE total_commandes > 0
ORDER BY roas DESC
LIMIT 1;


-- Question 2b: Campagne la plus efficace en acquisition CAC minimum

WITH order_revenues AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    GROUP BY o.id, o.customer_id, o.created_at
),
first_orders AS (
    SELECT
        customer_id,
        MIN(created_at) AS date_premiere_commande
    FROM orders_clean
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
campaign_metrics AS (
    SELECT
        c.id AS campaign_id,
        c.campaign_name,
        c.channel,
        c.budget,
        COUNT(DISTINCT ao.order_id) AS total_commandes,
        ROUND(SUM(ao.montant_commande), 2) AS revenu_total,
        SUM(ao.est_nouveau_client) AS nb_nouveaux_clients
    FROM campaigns c
    LEFT JOIN attributed_orders ao ON c.id = ao.campaign_id
    GROUP BY c.id, c.campaign_name, c.channel, c.budget
)
SELECT
    campaign_name,
    channel,
    budget,
    nb_nouveaux_clients,
    ROUND(budget / NULLIF(nb_nouveaux_clients, 0), 2) AS cac,
    ROUND(revenu_total / NULLIF(nb_nouveaux_clients, 0), 2) AS revenu_par_nouveau_client,
    ROUND((revenu_total / NULLIF(nb_nouveaux_clients, 0)) / NULLIF(budget / NULLIF(nb_nouveaux_clients, 0), 0), 2) AS ratio_revenu_cac
FROM campaign_metrics
WHERE nb_nouveaux_clients > 0
ORDER BY cac ASC
LIMIT 1;


-- Question 3: Repartition commandes et revenus organiques vs marketing

WITH order_revenues AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
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
    LEFT JOIN attribution a ON orv.order_id = a.order_id
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


-- Question 3b: Repartition detaillee par canal marketing vs organique

WITH order_revenues AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.created_at,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    GROUP BY o.id, o.customer_id, o.created_at
),
orders_with_channel AS (
    SELECT
        orv.order_id,
        orv.montant_commande,
        COALESCE(c.channel, 'Organique') AS channel
    FROM order_revenues orv
    LEFT JOIN attribution a ON orv.order_id = a.order_id
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