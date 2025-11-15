# Technical Assessment - E-commerce Analytics

Analyse complète des données e-commerce d'un client: performance produits, géographie, cohortes clients, et attribution marketing.

---

## Ce que j'ai fait

J'ai analysé les données d'une boutique en ligne qui vend des produits (casquettes, mugs, notebooks, t-shirts...) dans 5 pays européens.

**Les questions auxquelles j'ai répondu :**
- Quels sont les produits les plus rentables ?
- Dans quels pays vendons-nous le mieux ?
- Quelle est la valeur à vie de nos clients ?
- Quelles campagnes marketing sont les plus efficaces ?

---

## Structure du projet

```
Dacker_Assessment/
│
├── data/
│   ├── dashboard/              # Données exportées pour Looker
│   │   ├── kpis_produit.csv
│   │   ├── produit_pays_top.csv
│   │   ├── produits_premium.csv
│   │   └── ventes_geographiques.csv
│   │
│   └── Raw CSV files (orders, products, customers, campaigns)
│
├── docs/                       # Documentation de chaque partie
│   ├── partie_1_ingestion.md
│   ├── partie_2_produit.md
│   ├── partie_3_reconciliation.md
│   ├── partie_4_LTV.md
│   └── partie_5_Marketing.md
│
├── sql/                        # Requêtes SQL principales
│   ├── exploration.sql
│   ├── partie_1_ingestion.sql
│   ├── partie_2_produit.sql
│   ├── partie_3_reconciliation.sql
│   ├── partie_4_LTV.sql
│   └── partie_5_Marketing.sql
│
├── scripts/
│   └── export_looker_data.sh   # Script d'export pour le dashboard
│
├── src/
│   └── import_data.py          # Script Python pour import des données
│
├── dacker.db                   # Base de données SQLite
└── README.md
```

---

## Le Dashboard

**[Cliquez ici pour voir le dashboard](https://lookerstudio.google.com/reporting/e6059090-e008-4b73-a916-81c13d33cf9a)**

Le dashboard est organisé en 3 pages :

### Page 1 - Vue d'ensemble

- 4 KPIs principaux (revenus, produits, quantités, clients)
- Top 8 produits par chiffre d'affaires
- Répartition du CA par catégorie
- Tableau détaillé de tous les produits

### Page 2 - Géographie

- Quel pays achète le plus chaque produit
- Top 5 des pays par revenus
- Détails par pays (CA, quantités, commandes)

### Page 3 - Produits Premium

- Top 3 des produits à forte valeur
- Graphique Volume vs Valeur unitaire
- Comparatif complet de tous les produits

---

## Principaux résultats

### Top 3 Produits
1. **Cap** - 63 512 € (champion en France)
2. **Dacker Mug** - 62 471 € (champion en Italie)
3. **Notebook** - 61 956 € (champion en Allemagne)

### Top 3 Pays
1. **France** - 99 896 € (20.7% du CA)
2. **Italie** - 98 652 € (20.5% du CA)
3. **Espagne** - 97 185 € (20.3% du CA)

### Catégories
- **Apparel** : 49.4% du CA (238K€)
- **Goodies** : 25.6% du CA (123K€)
- **Stationery** : 12.8% du CA (62K€)
- **Accessories** : 12.2% du CA (59K€)

### Marketing - Meilleurs canaux

| Canal | ROAS | Recommandation |
|-------|------|----------------|
| Email | 15.2x | Augmenter le budget |
| Google Ads | 8.5x | Maintenir |
| Facebook | 6.2x | À surveiller |
| Instagram | 4.8x | Réduire ou optimiser |

**Recommandation :** Réallouer 30% du budget Instagram vers Email et Google Ads pour un impact estimé de +25% de revenus.

---

## Technologies utilisées

- **SQL (SQLite)** - Analyses et transformations de données
- **Python** - Scripts d'import et d'automatisation
- **Looker Studio** - Dashboard interactif
- **Git** - Versioning du code

---

## Documentation

Chaque partie du projet est documentée dans le dossier `docs/` :

- `partie_1_ingestion.md` - Import des données et création de la base
- `partie_2_produit.md` - Analyse de performance des produits
- `partie_3_reconciliation.md` - Validation et qualité des données
- `partie_4_LTV.md` - Analyse des cohortes et lifetime value
- `partie_5_Marketing.md` - Attribution marketing et ROI

---

## Comment utiliser ce projet

### Prérequis
- Python 3.8+
- SQLite3

### Lancer l'analyse

```bash
# 1. Cloner le projet
git clone https://github.com/ThiamSelle/Dacker_Assessment.git
cd Dacker_Assessment

# 2. Créer la base de données
sqlite3 dacker.db < sql/partie_1_ingestion.sql

# 3. Lancer les analyses
sqlite3 dacker.db < sql/partie_2_produit.sql
sqlite3 dacker.db < sql/partie_4_LTV.sql
sqlite3 dacker.db < sql/partie_5_Marketing.sql

# 4. Consulter les résultats
sqlite3 dacker.db
> SELECT * FROM kpis_produit;
```

---
