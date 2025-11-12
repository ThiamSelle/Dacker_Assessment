----- Partie 1 : Ingestion et Préparation
--- Question 2 : La colonne id de la table orders est-elle une clé primaire valide ? Pourquoi ?

-- First step. On vérifie la présence de doublons
SELECT
    id,
    COUNT(*) as nb_occurences
FROM orders
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY nb_occurences DESC
LIMIT 10;


-- Second step. On vérifie la présence de valeurs nulls
SELECT
    COUNT(*) AS null_id_numbers
FROM orders
WHERE id IS NULL;


-- Third step. On détermine le nomble de doublons
SELECT
    COUNT(*) AS total_lignes,
    COUNT(DISTINCT id) AS nb_ids_distincts,
    COUNT(*) - COUNT(DISTINCT id) AS nb_doublons
FROM orders;


--- Question 3 : Ecrire une requête SQL permettant d’avoir 1 ligne par id. Justifier la méthode employée.
-- Les doublons représentent ici l'évolution d'une commande d'un client.
-- Ainsi, on va garder la ligne avec 'updated_at' le plus recent.
-- Le but, va être de conserver l'état final de chaque commande d'un client.

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

--- Question 4 - Faites de même avec la table order_items
-- D'abord, on va vérifier les doublons
SELECT
    id,
    COUNT(*) as nb_occurrences
FROM order_items
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY nb_occurrences DESC
LIMIT 10;


-- Requête nous permettant d'avoir 1 ligne par id et création de la table 'order_item_clean' au passage
DROP VIEW IF EXISTS order_items_clean;
CREATE VIEW order_items_clean AS
SELECT *
FROM order_items
WHERE ROWID IN (
    SELECT ROWID
    FROM (
        SELECT
            ROWID,
            ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) as rn
        FROM order_items
    )
    WHERE rn = 1
);

-- Verification
SELECT 'order_items_clean' as table_name, COUNT(*) as nb_lignes
FROM order_items_clean;


--- Question 5 - Écrivez une requête permettant de valider que toutes les valeurs du champ shipping_country font bien parties de la liste des pays valides
-- Liste des pays valides: FR, DE, IT, ES, BE

-- First Step. On doit créer la vue orders_clean puisque nous ne l'avons pas crée dans la partie 3.
DROP VIEW IF EXISTS orders_clean;
CREATE VIEW orders_clean AS
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
);

-- Second step : On va tenter d'identifier les valeurs hors du champ recherché
SELECT
    shipping_country,
    COUNT(*) as nb_commandes
FROM orders_clean
WHERE shipping_country NOT IN ('FR', 'DE', 'IT', 'ES', 'BE')
   OR shipping_country IS NULL
GROUP BY shipping_country
ORDER BY nb_commandes DESC
LIMIT 10;


-- Requete 2: Statistiques globales par statut de validation
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

-- Requete 3: Distribution par pays valide
SELECT
    shipping_country,
    COUNT(*) as nb_commandes,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders_clean), 2) as pourcentage
FROM orders_clean
WHERE shipping_country IN ('FR', 'DE', 'IT', 'ES', 'BE')
GROUP BY shipping_country
ORDER BY nb_commandes DESC
LIMIT 10;

