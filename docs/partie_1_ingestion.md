# PARTIE 1 – Ingestion & Préparation
## Question 1 : Import des données

On a utilisé le script présent dans `src/import_data.py` pour ingérer les données et créer la base de donnée `dacker.db`. 

Voici les fichiers que nous avons importés : 

| Fichier.csv | Nombre de lignes |
|-------------|------------------|
| orders      | 2294 |
| order_items | 6901 |
| charges     | 1078 |
| products    | 8 |
| campaigns   | 4 |
| attribution | 916 |



## Question 2 : La colonne id de la table orders est-elle une clé primaire valide ? Pourquoi ?

Non, la colonne 'id' de 'orders' n'est pas une clé primaire. Pour qu'une colonne soit une clé primaire valide, elle doit respecter deux conditions :
1. L'absence de doublons
2. L'absence de valeurs nulles

À travers nos requêtes, j'ai observé ces résultats: 
- L'ensemble des ids de 1 à 1000 présente des doublons: 2 à 3 par id --> Plus de la moitié des lignes (56%) sont des doublons 
- Aucune valeur NULL est détectée

| Total lignes | 2294 |
| IDs distincts | 1000 |
| Lignes en doublon | 1294 (56%) |
| Valeurs NULL | 0 |

Ainsi, La colonne 'id' ne peut pas être considéré comme clé primaire car, elle ne respecte pas le critère d'unicité, bien qu'elle respecte la contrainte NOT NULL.



## Question 3 : Ecrire une requête SQL permettant d’avoir 1 ligne par id. Justifier la méthode employée.
Pour comprendre comment dé-dupliquer correctement les données, j'ai d'abord cherché à comprendre d'où venaient ces doublons. 
En examinant quelques cas concrets, la situation est devenue claire.

À travers la commande id=1 :
```
id=1, status=open,     updated_at=2025-04-05 20:33:30
id=1, status=shipped,  updated_at=2025-04-06 04:33:30
```

Et en prenant la commande id=995 qui présente trois doublons :
```
id=995, status=open,      updated_at=2025-04-17 11:30:28
id=995, status=canceled,  updated_at=2025-04-17 22:30:28
id=995, status=shipped,   updated_at=2025-04-22 11:30:28
```

Ce pattern se répète : les doublons ne sont pas des erreurs d'import, mais représentent l'évolution d'une commande au fil du temps. 
La commande 995 a d'abord été créée, puis annulée 11 heures plus tard, avant d'être finalement expédiée 5 jours après. Chaque ligne correspond à un changement de statut.
Cette observation a été confirmée en listant les statuts possibles : 
--> open, pending_payment, shipped, et cancelled. 

J'ai également vérifié que les commandes avec le statut "open" ont systématiquement la même valeur à 'created_at' égal à 'updated_at', ce qui signifie qu'elles n'ont jamais été modifiées 
--> Ce sont simplement des commandes récentes qui n'ont pas encore été traité.

La question devient donc : quelle version de chaque commande devons-nous conserver pour la suite ?

La réponse va de pair avec le besoin métier. Si nous voulons analyser les ventes, les performances, ou le taux de conversion, nous avons besoin de connaître l'état actuel et final de chaque commande, pas son historique complet. 
Une commande qui a été expédiée doit apparaître comme "expédiée" dans nos analyses, même si elle est passée par plusieurs status entre temps.

Ainsi, la méthode la plus logique consiste donc à garder la ligne avec la date de mise à jour la plus récente pour chaque id. 
Cela reflète d'avantage la réalité opérationnelle. Une commande peut changer de statut plusieurs fois - comme on l'a vu avec la commande 995 qui a été annulée puis finalement expédiée. 
On va considérer que l'état le plus récent est celui qui compte pour l'analyse des ventes réelles. Et de ce fait, la colonne updated_at est spécifiquement conçue pour cet usage. Elle est mise à jour à chaque modification et garantit un ordre chronologique fiable.

Pour ce faire, nous avons utilisé : 'ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC)'
--> On partitionne par 'id' pour traiter chaque commande de manière indépendante
--> On trie par 'updated_at DESC' pour avoir l'état le plus récent en premier 
--> Ce qui nous permet de garder uniquement la ligne avec rn=1 - donc 'The latest update'
Cette déduplication nous fait donc passer de 2294 lignes à 1000 lignes, soit une réduction de 56%. 

Pour vérifier que tout fonctionne correctement, j'ai retesté la commande 995 : elle apparaît bien avec status=shipped et updated_at=2025-04-22 11:30:28, ce qui est cohérent.

En anticipation de la Question 5, la vue orders_clean a été créée à cette étape en intégrant directement les corrections de pays nécessaires (normalisation en majuscules, suppression des espaces, correction de "ED" en "DE"). 
--> Cette approche évite la duplication de code et garantit que la vue est immédiatement utilisable pour les analyses suivantes.



## Question 4 : Faites de même avec la table order_items --> Déduplication de 'order_items'

Comme pour la table 'orders', on va appliquer la même démarche de déduplication à 'order_items'.

j'ai commencé par vérifier s'il y avait des doublons sur la colonne id. 
--> La requête révèle la même situation : 6901 lignes au total pour seulement 3009 ids distincts, donc on a 3892 doublons représentant 56% des données.

Mais contrairement à 'orders', la nature des doublons est différente. 
--> En examinant un exemple concret (id=2995), les trois lignes sont parfaitement identiques : même order_id, même produit, même quantité, même prix, et surtout même date de mise à jour. 
--> Il n'y a aucune évolution, aucun changement entre les versions. Ce sont de vraies duplicates.

Pour 'orders', on a choisi quelle version garder parmi plusieurs états différents d'une même entité. 
Pour 'order_items', l'objectif va être que d'éliminer les copies superflues d'une ligne qui n'aurait jamais dû être dupliquée.
--> Compte tenu de la nature des doublons, la méthode la plus appropriée est l'utilisation de 'SELECT DISTINCT' qui élimine automatiquement les lignes identiques.

Après l'application du 'DISTINCT', la vue nettoyée contient 3009 lignes, éliminant ainsi l'ensemble des 3892 doublons détectés.



## Question 5 : Validation du champ shipping_country

La validation du champ shipping_country révèle une bonne qualité globale des données avec trois anomalies détectées sur 1000 commandes (0.3%).
L'analyse de la table brute identifie trois cas problématiques : 
--> une commande avec "it" en minuscules au lieu de "IT", 
--> une commande avec "ED" qui est probablement une erreur de saisie pour "DE" (Allemagne),
--> et une commande avec "BE " incluant un espace.

Les corrections ont été intégrées directement dans la création de la vue orders_clean dans la question 3 via une triple transformation : 
--> normalisation en majuscules avec UPPER(),
--> suppression des espaces avec TRIM(), 
--> et correction explicite du code erroné "ED" vers "DE". 

Cette approche garantit que la vue finale contient 100% de valeurs conformes au référentiel (FR, DE, IT, ES, BE).
La distribution géographique finale montre un équilibre relatif entre les cinq pays : 
- Espagne 21.5%
- Allemagne 21.1%
- France 20.1%
- Italie 19.9%
- Belgique 17.4%. 

Cette répartition homogène suggère une couverture géographique cohérente sans préférence vers un marché spécifique.