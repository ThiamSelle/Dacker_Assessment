# ⚙️ PARTIE 7 – ARCHITECTURE (BONUS)

## **1. Pipeline de données : Du système e-commerce au dashboard**

Le flux de données suit une architecture ETL en plusieurs étapes. 
--> Le point de départ est le système de gestion de commandes du site e-commerce (probablement Shopify ou similaire) qui génère des événements transactionnels en temps réel. 
--> Ces données brutes sont d'abord extraites via l'API du système shopify, puis stockées dans une base de données opérationnelle PostgreSQL ou MySQL où elles sont structurées en tables.

La première transformation majeure intervient lors du processus de nettoyage et d'enrichissement des données. 
--> Les fichiers CSV bruts sont générés depuis la base opérationnelle, puis traités par des scripts SQL qui effectuent le nettoyage (suppression des doublons, normalisation des formats de dates, gestion des valeurs nulles) et créent les tables intermédiaires comme orders_clean et order_items_clean. Cette étape est critique car elle garantit la qualité des données avant toute analyse.

La deuxième phase de transformation génère les métriques métiers en exécutant les requêtes SQL d'agrégation que nous avons développées. 
--> Ces requêtes calculent les KPIs par produit (kpis_produit.csv), les performances géographiques (ventes_geographiques.csv), et les analyses de cohort LTV (ltv_cohorts.csv). 
--> Chaque table agrégée représente une vue métier spécifique optimisée pour la visualisation.
--> Enfin, les fichiers CSV finaux sont importés dans Looker Studio où ils servent de sources de données pour les graphiques et tableaux du dashboard. 

```
┌─────────────────────────────────────────────────────────────────┐
│                     SCHÉMA PIPELINE                 │
└─────────────────────────────────────────────────────────────────┘

[1] SOURCE - Système E-commerce
    ┌──────────────────────┐
    │       Shopify        │
    │                      │
    └──────────┬───────────┘
               │ API 
               ▼
    ┌──────────────────────┐
    │  Base de données     │
    │  PostgreSQL / MySQL  │
    │  (Tables brutes :    │
    │   orders, customers, │
    │   products)          │
    └──────────┬───────────┘
               │
               
   EXTRACTION & NETTOYAGE
   
               │
               │ Export CSV
               ▼
    ┌──────────────────────┐
    │  Fichiers CSV bruts  │
    │  - orders.csv        │
    │  - order_items.csv   │
    │  - products.csv      │
    └──────────┬───────────┘
               │
               │ Scripts SQL de nettoyage
               ▼
    ┌──────────────────────┐
    │  Tables nettoyées    │
    │  - orders_clean      │
    │  - order_items_clean │
    └──────────┬───────────┘
               │
               
[3] TRANSFORMATION & AGRÉGATION
               │ Requêtes SQL analytiques
               ▼
    ┌──────────────────────┐
    │  Tables métriques    │
    │  - kpis_produit.csv  │
    │  - ventes_geo.csv    │
    │  - ltv_cohorts.csv   │
    │  - produits_premium  │
    └──────────┬───────────┘
               │
               
[4] VISUALISATION
               │ Import dans Looker Studio
               ▼
    ┌──────────────────────┐
    │     Looker Studio    │
    │                      │
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │  Utilisateurs finaux │
    │  (Navigateur web)    │
    └──────────────────────┘


Source → Extraction → Nettoyage → Transformation → Visualisation

```



## **2. Automatisation du pipeline pour mise à jour quotidienne**

L'automatisation repose sur une orchestration à travers Airflow qui déclenche quotidiennement une séquence de scripts. 
Le processus démarre chaque nuit à une heure précise avec l'extraction incrémentale des commandes depuis l'API e-commerce. 
--> Ces données sont immédiatement insérées dans la base PostgreSQL de staging.
--> Seules les commandes créées ou modifiées dans les dernières 24h sont récupérées pour optimiser les performances

Ensuite, un premier script Python ou SQL s'exécute pour nettoyer les nouvelles données selon les règles établies (gestion des statuts, normalisation des dates, déduplication). 
--> Les résultats sont ajoutés aux tables orders_clean et order_items_clean.
--> Un système de logs détaillé enregistre chaque anomalie détectée et envoie des alertes email en cas d'erreur critique : taux de rejet supérieur à 5%, données manquantes.

Ensuite, les requêtes SQL d'agrégation sont exécutées séquentiellement pour recalculer l'ensemble des métriques. 
--> Plutôt que de tout recalculer, une approche incrémentale est privilégiée pour ltv_cohorts en ne recalculant que les cohortes impactées par les nouvelles commandes. 
--> Les fichiers CSV mis à jour sont générés et déposés dans un bucket Google Cloud Storage accessible à Looker Studio.

Puis pour finir, Looker Studio rafraîchit automatiquement ses sources de données via l'API de connexion à Google Cloud Storage, et les dashboards sont mis à jour pour tous les utilisateurs. 
Et ainsi, un email de synthèse est envoyé aussitôt avec les KPIs principaux (CA du jour, top produits, alertes éventuelles) et un lien vers le dashboard actualisé. 
--> Cette architecture garantit que les données affichées ont au maximum 24-26h de latence tout en maintenant des performances optimales.

Et, on coordonne ses opérations suivant une timeline horaire bien précise. 

```
┌─────────────────────────────────────────────────────────────────┐
│              PIPELINE AUTOMATISÉ - ORCHESTRATION AIRFLOW        │
└─────────────────────────────────────────────────────────────────┘

DÉCLENCHEMENT QUOTIDIEN (Cron : 0 2 * * *)

[02h00] ÉTAPE 1 : Extraction incrémentale
        ┌────────────────────────────┐
        │ Script Python              │
        │ extract_orders.py          │
        │                            │
        │ • API call vers Shopify    │
        └────────────┬───────────────┘
                     │ 
                     │ Nouvelles lignes
                     ▼
        ┌────────────────────────────┐
        │ Logs & Alertes             │
        │ • Nb lignes extraites      │
        │ • Email si erreur    │
        └────────────────────────────┘

[02h30] ÉTAPE 2 : Nettoyage & Validation
        ┌────────────────────────────┐
        │ Script SQL                 │
        │ clean_data.sql             │
        │                            │
        │                            │
        │                            │
        │                            │
        └────────────┬───────────────┘
                     │ 
                     │ 
                     ▼
        ┌────────────────────────────┐
        │ Contrôle qualité           │
        │ • Alert si rejet > 5%      │
        │ • Validation schéma        │
        └────────────────────────────┘
                     │ 
                     ▼
[03h00] ÉTAPE 3 : Agrégation métriques
        ┌────────────────────────────┐
        │ Scripts SQL parallèles     │
        │                            │
        │ Job 1: kpis_produit.sql    │ 
        │ Job 2: ventes_geo.sql      │  
        │ Job 3: ltv_cohorts.sql     │ 
        │ Job 4: premium_products.sql│ 
        └────────────┬───────────────┘
                     │ 
                     │ De manière incrémental - pas de full refresh
                     ▼
        ┌────────────────────────────┐
        │ Export vers CSV            │
        │ • 4 fichiers générés       │
        │ • Upload Google Cloud      │
        └────────────────────────────┘
                     │ 
                     ▼
[03h30] ÉTAPE 4 : Refresh Looker Studio
        ┌────────────────────────────┐
        │ API Looker Studio          │
        └────────────┬───────────────┘
                     │ 
                     ▼
        ┌────────────────────────────┐
        │ Dashboard mis à jour       │
        └────────────────────────────┘
                     │ 
                     ▼
[04h00] ÉTAPE 5 : Reporting & Monitoring
        ┌────────────────────────────┐
        │ Email quotidien            │
        └────────────────────────────┘
```

Le pipeline complet transforme les données brutes e-commerce en insights exploitables via quatre étapes majeures : 
--> extraction depuis l'API e-commerce, nettoyage avec règles métier strictes, agrégation via requêtes SQL optimisées, et visualisation dans Looker Studio. 
--> L'automatisation par Airflow garantit une mise à jour quotidienne fiable avec monitoring intégré à chaque étape.

Cette architecture permet aux décideurs d'accéder chaque matin avant 8h00 à des données actualisées de J-1 dans le dashboard Looker Studio, avec une latence maximale de 24-26h. 
--> Le système est scalable et peut traiter de 1 000 à 100 000 commandes par jour sans modification majeure de l'architecture, en ajustant simplement les ressources allouées à la base PostgreSQL et aux workers Airflow.
