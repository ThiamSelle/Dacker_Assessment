# Étude SQL Business Case - Dacker

## 🎯 Vue d'ensemble

Cette étude analyse les données e-commerce d'un site sur la période avril-septembre 2025, couvrant 1000 commandes, 631 clients et 4 campagnes marketing à travers 5 parties indépendantes.

**Objectifs :**
- Nettoyer et préparer les données sources
- Analyser la performance produit et la répartition géographique
- Réconcilier les paiements et identifier les écarts
- Calculer la Customer Lifetime Value par cohorte
- Évaluer l'efficacité des campagnes marketing
- Visualiser les KPIs dans un dashboard
- Proposer une architecture data automatisée

---

## 📁 Structure du projet

```
Dacker_Assessment/
│
├── data/
│   ├── dashboard/                    
│   │   ├── kpis_produit.csv
│   │   ├── produit_pays_top.csv
│   │   ├── produits_premium.csv
│   │   └── ventes_geographiques.csv
│   │
│   ├── database/
│   │   └── dacker.db                    
│   │
│   └── raw_files/                   
│       ├── attribution.csv
│       ├── campaigns.csv
│       ├── charges.csv
│       ├── order_items.csv
│       ├── orders.csv
│       └── products.csv
│
├── docs/                             
│   ├── exploration.txt
│   ├── partie_1_ingestion.md
│   ├── partie_2_produit.md
│   ├── partie_3_reconciliation.md
│   ├── partie_4_LTV.md
    ├── partie_5_marketing.md
    ├── partie_6_visualisation.md
│   └── partie_5_architecture.md
│
├── sql/                              
│   ├── exploration.sql
│   ├── partie_1_ingestion.sql
│   ├── partie_2_produit.sql
│   ├── partie_3_reconciliation.sql
│   ├── partie_4_LTV.sql
    ├── partie_5_marketing.sql
│   └── partie_6_visualisation.sql
│
├── src/
│   └── import_data.py                   
│
├── .gitignore
└── README.md                           
```

---


## Installation et exécution
### **Prérequis**

- **SQLite3** (version 3.8+)
- **Python 3.8+** (optionnel, pour l'import automatisé)
- **Pandas** 


### Étape à suivre 

**Pour reproduire l'analyse :**
1. Cloner le projet
2. Exécuter `python src/import_data.py`
3. Lancer les scripts SQL dans l'ordre
4. Comparer vos résultats avec les documents `docs/`
5. Visualiser le dashboard : https://lookerstudio.google.com/reporting/135d21aa-48d2-4484-9e68-f92719eb5413.


---


## Note méthodologique 
### Choix d'analyse : CA comptable vs CA encaissé

Cette étude adopte une **approche comptable** basée sur la valeur des commandes expédiées (`total_price` calculé depuis `order_items`), indépendamment du statut de paiement dans la table `charges`.
J'ai choisi cette approche pour différente raisons: 

**1. Vision opérationnelle complète**
- Les produits expédiés représentent une consommation réelle de stock
- Les coûts logistiques ont été engagés (préparation, emballage, transport)
- Reflète la demande client réelle et l'activité commerciale effective

**2. Principe de comptabilité d'engagement (IFRS 15)**
- En comptabilité d'entreprise, le chiffre d'affaires est reconnu à la livraison
- Les créances clients (impayés temporaires) restent comptabilisées au bilan
- Cette approche est conforme aux normes comptables internationales

**3. Hypothèse de recouvrement**
- Les commandes expédiées non encore payées (identifiées en Partie 3) constituent des créances clients en cours de recouvrement
- L'entreprise dispose de processus de relance et de récupération des fonds
- Les impayés définitifs sont traités comme provisions pour créances douteuses

**4. Cohérence avec les objectifs business**
- L'analyse marketing (Partie 5) vise à mesurer la génération de demande
- L'analyse produit (Partie 2) évalue la popularité réelle des articles
- L'analyse LTV (Partie 4) projette la valeur client sur le long terme
- Ces objectifs sont ainsi mieux servis par une approche volumétrique


---


## Documentation détaillée

Chaque partie dispose d'un document markdown complet dans le dossier `docs/` :

`partie_1_ingestion.md` --> Import, nettoyage, validation des données 
`partie_2_produit.md` --> Performance produit, analyse géographique, top produits 
`partie_3_reconciliation.md` --> Écarts de paiement, créances, analyse des impayés 
`partie_4_LTV.md` --> Cohortes mensuelles, évolution LTV, taux de rétention 
`partie_5_marketing.md` --> ROAS, CAC, attribution, performance par canal
`partie_6_visualisation.md` --> ROAS, CAC, attribution, performance par canal'
`partie_7_discussion_et_limites.md` --> Analyse critique, approche alternative, recommandations 


---