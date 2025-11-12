# PARTIE 1 – Ingestion & Préparation
## Question 1 : Import des données

On a utilisé le script présent dans `src/import_data.py`  pour ingérer les données et créer la base de donnée `dacker.db`. 

Voici les fichiers que nous avons importés : 

| Fichier.csv | Nombre de lignes |
|-------------|------------------|
| orders      | 2294 |
| order_items | 6901 |
| charges     | 1078 |
| products    | 8 |
| campaigns   | 4 |
| attribution | 916 |

---

## Question 2 : La colonne id de la table orders est-elle une clé primaire valide ? Pourquoi ?

Non, la colonne 'id' de 'orders' n'est pas une clé primaire. Pour qu'une colonne soit une clé primaire valide, elle doit respecter deux conditions :
1. L'absence de doublons
2. L'absence de valeurs nulles

Voici les requêtes qui nous ont permis de vérifier nos si cette colonne respectait les deux critères cités. 

```sql
-- First step. On vérifie la présence de doublons
SELECT
    id,
    COUNT(*) as nb_occurences
FROM orders
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY nb_occurences DESC;


-- Second step. On vérifie la présence de valeurs nulls
SELECT
    COUNT(*) AS null_id_numbers
FROM orders
WHERE id IS NULL;


-- Third step. Nous allons déterminer le nomble de doublon chez orders.
SELECT
    COUNT(*) AS total_lignes,
    COUNT(DISTINCT id) AS nb_ids_distincts,
    COUNT(*) - COUNT(DISTINCT id) AS nb_doublons
FROM orders
```

Nous avons ainsi put observer ces résultats: 
- L'ensemble des ids de 1 à 1000 présente des doublons (2 ou 3 occurrences par id)
- Aucune valeur NULL est détectée
- Plus de la moitié des lignes (56%) sont des doublons 

| Métrique | Valeur |
|----------|--------|
| Total lignes | 2294 |
| IDs distincts | 1000 |
| Lignes en doublon | 1294 (56%) |
| Valeurs NULL | 0 |


Ainsi, La colonne `id` ne peut pas être considéré comme clé primaire car, elle ne respecte pas le critère d'unicité, bien qu'elle respecte la contrainte NOT NULL.
Par soucis de vérification, nous avons bel et bien vérifié sur Excel de sorte à être sûr que la donnée a bien été importé et que les erreurs ne proviennent pas de notre manipulation de données. 


## Question 3 : Ecrire une requête SQL permettant d’avoir 1 ligne par id. Justifier la méthode employée.
Pour comprendre comment dé-dupliquer correctement les données, j'ai d'abord cherché à comprendre d'où venaient ces doublons. 
En examinant quelques cas concrets, la situation est devenue claire.

Prenons la commande id=1 :
```
id=1, status=open,     updated_at=2025-04-05 20:33:30
id=1, status=shipped,  updated_at=2025-04-06 04:33:30
```

Et la commande id=995 qui présente trois doublons :
```
id=995, status=open,      updated_at=2025-04-17 11:30:28
id=995, status=canceled,  updated_at=2025-04-17 22:30:28
id=995, status=shipped,   updated_at=2025-04-22 11:30:28
```

Ce pattern se répète : les doublons ne sont pas des erreurs d'import, mais représentent l'évolution d'une commande au fil du temps. 
La commande 995 a d'abord été créée, puis annulée 11 heures plus tard, avant d'être finalement expédiée 5 jours après. Chaque ligne correspond à un changement de statut.
Cette observation a été confirmée en listant les statuts possibles : 
--> open, pending_payment, shipped, et cancelled. 

J'ai également vérifié que les commandes avec le statut "open" ont systématiquement created_at égal à updated_at, ce qui signifie qu'elles n'ont jamais été modifiées 
--> Ce sont simplement des commandes récentes qui n'ont pas encore été traité.

La question devient alors : quelle version de chaque commande devons-nous conserver pour la suite ?

La réponse découle ainsi directement du besoin métier. Si nous voulons analyser les ventes, les performances, ou le taux de conversion, nous avons besoin de connaître l'état actuel et final de chaque commande, pas son historique complet. 
Une commande qui a été expédiée doit apparaître comme "expédiée" dans nos analyses, même si elle est passée par plusieurs états intermédiaires.

La méthode la plus logique consiste donc à garder la ligne avec la date de mise à jour la plus récente pour chaque id. 
Cela reflète ainsi d'avantage la réalité opérationnelle. Une commande peut changer de statut plusieurs fois - comme on l'a vu avec la commande 995 qui a été annulée puis finalement expédiée. 
Ainsi, on considère que l'état le plus récent est celui qui compte pour l'analyse des ventes réelles. Ensuite, la colonne updated_at est spécifiquement conçue pour cet usage. Elle est mise à jour à chaque modification et garantit un ordre chronologique fiable. 
Pour les commandes qui n'ont jamais évolué (status=open avec created_at=updated_at), notre critère les conserve naturellement puisqu'il n'existe pas de version plus récente.

Cette déduplication nous fait donc passer de 2294 lignes à 1000 lignes, soit une réduction de 56%. 
Pour vérifier que tout fonctionne correctement, j'ai retesté la commande 995 : elle apparaît bien avec status=shipped et updated_at=2025-04-22 11:30:28, ce qui est cohérent.

Voici la query qui nous a permit d'arriver à ce résultat. 
```sql
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
```

## Question 4 : Faites de même avec la table order_items --> Déduplication de `order_items`

La table `order_items` contient les détails des articles commandés : un identifiant de ligne (id), une référence à la commande (order_id), 
le produit acheté (product_id), la quantité, le prix unitaire, et une date de mise à jour.

Comme pour la table `orders`, j'ai commencé par vérifier s'il y avait des doublons sur la colonne id. 
--> La requête révèle la même situation : 6901 lignes au total pour seulement 3009 ids distincts, soit 3892 doublons représentant 56% des données.

Mais contrairement à `orders`, la nature de ces doublons est différente. 
--> En examinant un exemple concret (id=2995), les trois lignes sont parfaitement identiques : même order_id, même produit, même quantité, même prix, et surtout même date de mise à jour. 
--> Il n'y a aucune évolution, aucun changement entre les versions. Ce sont de vraies duplicates.

Puisque toutes les lignes sont identiques, peu importe laquelle on garde. J'ai choisi de conserver la même méthode que pour `orders`, par souci de cohérence dans le traitement des données. 
--> La requête utilise ROW_NUMBER() avec PARTITION BY id et un tri par updated_at DESC, même si ce dernier critère n'a pas d'impact réel ici.


```sql
DROP VIEW IF EXISTS order_items_clean
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
```

Cette approche présente l'avantage d'être robuste : si demain la structure des données change et que des lignes commencent à évoluer comme dans `orders`, la logique reste valide. 
Ainsi, j'ai créé une vue `order_items_clean` avec cette requête, réduisant les données de 6901 à 3009 lignes.


## Question 5 : Validation du champ shipping_country

La consigne demandait de vérifier que toutes les valeurs du champ shipping_country appartiennent bien à la liste des pays valides : FR, DE, IT, ES, BE. 
Une validation stricte du problème donnerait : NON, 2 valeurs invalides détectées (ED et BE avec espace).

Cependant, j'ai choisi d'aller au-delà d'une simple validation binaire en fournissant trois requêtes supplémentaires qui permettent de comprendre la nature du problème.

La première requête identifie les valeurs hors référentiel. Elle révèle deux anomalies sur les 1000 commandes dé dupliquées : une commande avec "ED" comme pays et une autre avec "BE " incluant un espace. 
--> Le "ED" est probablement une erreur de frappe pour "DE" (Allemagne), tandis que le "BE " montre un problème de nettoyage des données.

```sql
SELECT 
    shipping_country,
    COUNT(*) as nb_commandes
FROM orders_clean
WHERE shipping_country NOT IN ('FR', 'DE', 'IT', 'ES', 'BE')
   OR shipping_country IS NULL
GROUP BY shipping_country;
```

La deuxième requête donne une vue statistique globale. Sur les 1000 commandes, 998 sont valides (99.8%) et seulement 2 sont invalides (0.2%). 
--> Aucune valeur NULL n'a été détectée.

```sql
SELECT 
    CASE 
        WHEN shipping_country IN ('FR', 'DE', 'IT', 'ES', 'BE') THEN 'Valide'
        WHEN shipping_country IS NULL THEN 'NULL'
        ELSE 'Invalide'
    END as statut_validation,
    COUNT(*) as nb_commandes,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders_clean), 2) as pourcentage
FROM orders_clean
GROUP BY statut_validation;
```

La troisième requête montre la distribution des commandes par pays valide. Les volumes sont relativement équilibrés : l'Espagne arrive en tête avec 215 commandes (21.5%), suivie de l'Allemagne avec 210 (21%), la France avec 201 (20.1%), l'Italie avec 198 (19.8%), et la Belgique avec 174 commandes (17.4%). 
--> Cette répartition homogène suggère une couverture géographique équilibrée.

```sql
SELECT 
    shipping_country,
    COUNT(*) as nb_commandes,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders_clean), 2) as pourcentage
FROM orders_clean
WHERE shipping_country IN ('FR', 'DE', 'IT', 'ES', 'BE')
GROUP BY shipping_country
ORDER BY nb_commandes DESC;
```

La qualité des données shipping_country est très bonne avec 99.8% de valeurs conformes. Les deux anomalies détectées sont mineures et facilement corrigeables. 
--> Pour les analyses suivantes, on pourra soit exclure ces deux commandes, soit les corriger manuellement. 


## Récapitulatif de la Partie 1

Les données ont été importées avec succès dans une base SQLite. L'analyse a par la suite révélé des problèmes de qualité.

La colonne id n'est pas une clé primaire valide dans orders et order_items, avec 56% de doublons dans les deux tables. 
--> Pour orders, ces doublons représentent l'historique d'évolution des commandes au fil du temps, avec des changements de statut successifs. 
--> Pour order_items, il s'agit de vraies duplications causées par des insertions multiples lors des synchronisations API.

J'ai mis en place une stratégie de déduplication cohérente basée sur la conservation de la ligne la plus récente selon le critère 'updated_at DESC'. 
Cela a permis de créer deux vues nettoyées : orders_clean avec 1000 lignes et order_items_clean avec 3009 lignes. 
--> Cette approche garantit que nous travaillons avec l'état final de chaque commande et de chaque article, ce qui est pertinent pour toutes les analyses business à venir.

La validation du champ shipping_country montre une excellente qualité avec 99.8% de valeurs conformes. 
Seules deux anomalies mineures ont été détectées sur l'ensemble des commandes. La distribution géographique est équilibrée entre les cinq pays européens couverts.

Ces vues nettoyées serviront de base solide pour quelconques analyses dans les parties suivantes, garantissant des résultats fiables sans biais liés aux duplications.

