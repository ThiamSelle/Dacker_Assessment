----- Partie 1 : Ingestion et Préparation
.mode column
.headers on
.width 20 15 12 10


-- ====================================================================
-- QUESTION 2 : La colonne id de la table orders est-elle une clé primaire valide ?
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 2 : 'ID' est-elle une clé primaire valide ?"
.print "========================================"
.print ""

.print "Etape 1 : Verification de la présence de doublons"
.print ""
SELECT
    id,
    COUNT(*) as nb_occurences
FROM orders
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY nb_occurences DESC
LIMIT 10;

.print ""
.print ""
.print "Etape 2 : Verification des valeurs NULL"
.print ""
SELECT
    COUNT(*) AS null_id_numbers
FROM orders
WHERE id IS NULL;

.print ""
.print ""
.print "Etape 3 : Statistiques globales"
.print ""
SELECT
    COUNT(*) AS total_lignes,
    COUNT(DISTINCT id) AS nb_ids_distincts,
    COUNT(*) - COUNT(DISTINCT id) AS nb_doublons
FROM orders;

.print ""
.print ""


-- ====================================================================
-- QUESTION 3 : Requête SQL pour avoir 1 ligne par id
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 3 : Deduplication de orders"
.print "========================================"
.print ""

.print "Apercu des resultats"
.print ""
SELECT *
FROM orders
WHERE ROWID IN (
    SELECT ROWID
    FROM (
        SELECT
            ROWID,
            ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) as rn
        FROM orders
    )
    WHERE rn = 1
)
LIMIT 10;

-- Creation de la vue orders_clean avec tous les nettoyages

DROP VIEW IF EXISTS orders_clean;

CREATE VIEW orders_clean AS
SELECT
    id,
    customer_id,
    created_at,
    updated_at,
    CASE
        WHEN UPPER(TRIM(shipping_country)) = 'ED' THEN 'DE'
        ELSE UPPER(TRIM(shipping_country))
    END as shipping_country,
    status
FROM orders
WHERE ROWID IN (
    SELECT ROWID
    FROM (
        SELECT
            ROWID,
            ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) as rn
        FROM orders
    )
    WHERE rn = 1
);

.print ""
.print "Verification de l'operation"
.print ""
SELECT 'orders_clean' as table_name, COUNT(*) as nb_lignes
FROM orders_clean;

.print ""
.print ""


-- ====================================================================
-- QUESTION 4 : Déduplication de order_items
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 4 : Deduplication de order_items"
.print "========================================"
.print ""

.print "Etape 1 : Verification de la presence de doublons"
.print ""
SELECT
    id,
    COUNT(*) as nb_occurrences
FROM order_items
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY nb_occurrences DESC
LIMIT 10;

.print ""
.print ""
.print "Etape 2 : Analyse de la nature des doublons"
.print ""
SELECT
    id,
    order_id,
    product_id,
    quantity,
    unit_price,
    updated_at,
    COUNT(*) as nb_doublons
FROM order_items
GROUP BY id, order_id, product_id, quantity, unit_price, updated_at
HAVING COUNT(*) > 1
LIMIT 10;


--Creation de la vue order_items_clean"
DROP VIEW IF EXISTS order_items_clean;

CREATE VIEW order_items_clean AS
SELECT DISTINCT
    id,
    order_id,
    product_id,
    quantity,
    unit_price,
    updated_at
FROM order_items;

.print ""
.print "Verification de l'opération"
.print ""
SELECT 'order_items_clean' as table_name, COUNT(*) as nb_lignes
FROM order_items_clean;

.print ""
.print ""


-- ====================================================================
-- QUESTION 5 : Validation du champ shipping_country
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 5 : Validation des pays"
.print "========================================"
.print ""

.print "Anomalies dans la table brute"
.print ""
SELECT
    shipping_country,
    COUNT(*) as nb_commandes,
    '"' || shipping_country || '"' as avec_guillemets
FROM orders
WHERE shipping_country NOT IN ('FR', 'DE', 'IT', 'ES', 'BE')
   OR shipping_country IS NULL
GROUP BY shipping_country
ORDER BY nb_commandes DESC;

.print ""
.print ""
.print "Statistiques globales de validation"
.print ""
SELECT
    CASE
        WHEN shipping_country IN ('FR', 'DE', 'IT', 'ES', 'BE') THEN 'Valide'
        WHEN shipping_country IS NULL THEN 'NULL'
        ELSE 'Invalide'
    END as statut_validation,
    COUNT(*) as nb_commandes,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders_clean), 2) as pourcentage
FROM orders_clean
GROUP BY statut_validation
ORDER BY nb_commandes DESC
LIMIT 10;

.print ""
.print ""
.print "Distribution geographique des commandes"
.print ""
SELECT
    shipping_country,
    COUNT(*) as nb_commandes,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders_clean), 2) as pourcentage
FROM orders_clean
WHERE shipping_country IN ('FR', 'DE', 'IT', 'ES', 'BE')
GROUP BY shipping_country
ORDER BY nb_commandes DESC
LIMIT 10;

.print ""
.print ""