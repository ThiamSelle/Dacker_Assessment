# Partie 3 : Réconciliation des paiements

Cette analyse vise à réconcilier les montants des commandes, calculés depuis la table order_items, avec les montants réellement encaissés enregistrés dans la table charges. 
--> L'objectif est d'identifier les écarts potentiels entre ce qui devrait être payé et ce qui a effectivement été encaissé, afin de détecter les anomalies financières et les risques de perte de chiffre d'affaires.


## Note méthodologique
Cette analyse de réconciliation porte volontairement sur toutes les commandes (shipped, pending_payment, canceled, open) et non uniquement sur les commandes 
shipped. Ce choix permet :

1. Détection exhaustive : Révéler toute anomalie, quel que soit le statut
2. Validation des processus : Confirmer l'absence de problèmes sur les statuts non-shipped
3. Auditabilité complète : Documenter l'intégrité de l'ensemble du système

L'analyse croisée (Question 2b) confirme que 100% des anomalies de paiement concernent le statut `shipped` (20 commandes sur 862, soit 2,3%). Les autres statuts ne présentent aucune anomalie de paiement, validant la 
cohérence des processus métier. Le manque à gagner de 10 714€ concerne exclusivement des commandes livrées et non payées.

L'absence de filtrage préalable sur `status = 'shipped'` n'impacte donc pas les conclusions, et aurait permis de détecter d'éventuels problèmes structurels. 


## Question 1 : Comparaison montant commande vs charges bancaires
Le statut de réconciliation est déterminé selon une logique en cascade. 
--> les commandes, où le montant égale exactement le montant encaissé sont marquées OK
--> celles sans aucun paiement sont classées AUCUN_PAIEMENT
--> les montants partiellement payés sont identifiés comme SOUS_PAIEMENT
--> et les sur-encaissements comme SUR_PAIEMENT. 

L'analyse révèle que les 25 commandes présentant des écarts de réconciliation partagent toutes le même pattern : un statut AUCUN_PAIEMENT avec une différence de 100%. 
Sur ces 25 commandes, 23 ont le statut livré et deux ont le statut open, donc en cours de création. Les montants concernés s'échelonnent de 47,39€ à 1 264,84€, avec une concentration notable de commandes à fort montant : supérieur à 100 euros.
--> La commande 969, client ID 1021, résidant en Belgique présente l'écart le plus élevé avec 1 264,84€ de marchandise expédiée sans trace de paiement.
--> La répartition géographique montre une présence marquée de la France (7 commandes), de l'Espagne (5 commandes) et de l'Allemagne (3 commandes) parmi les cas problématiques.

Le pattern observé est binaire : soit la commande est parfaitement réconciliée, soit elle ne présente strictement aucun paiement enregistré. 
--> L'absence totale de cas de sous-paiement partiel ou de sur-paiement dans ce top 25 suggère que le système de paiement fonctionne en mode tout-ou-rien, ou bien présente une faille exploitée par certains malins (ou non) ! 

Cependant, la présence de 23 commandes shipped sans aucun paiement constitue erreur majeure. 
--> Une commande ne devrait jamais être envoyée sans confirmation du paiement. 
--> Les 2 commandes open sans paiement sont en revanche cohérentes avec un processus normal de création de commande où le client n'a pas encore finalisé son achat. 


## Question 2 : Analyse de cohérence globale
Au cas où, nous allons explorer davantage les réconciliations voir si on peut y trouver d'extra insights. 

### 2a. Distribution par statut de réconciliation
L'analyse de l'ensemble des 1 000 commandes révèle un taux de réconciliation globalement bon. 
--> Sur le total, 975 commandes (97,5%) présentent une correspondance parfaite entre le montant théorique et le montant encaissé. 
--> Les 25 commandes restantes (2,5%) n'ont aucun paiement enregistré et représentent un montant cumulé de 11 583,12€ de manque à gagner potentiel.


### 2b. Croisement statut commande × statut réconciliation
L'analyse croisée par statut de commande permet d'identifier la distribution des anomalies. Les 42 commandes 'cancelled' présentent toutes un statut de réconciliation OK. 
--> Cette situation apparemment paradoxale s'explique par un processus où le client a initialement payé sa commande, qui a ensuite été annulée, déclenchant un remboursement. 

Les commandes open se répartissent en 47 cas avec paiement confirmé (montant moyen 456,99€) et deux cas sans paiement (montant moyen 434,52€, totalisant 869,05€). 
--> Cette distribution est cohérente avec un workflow où certains clients paient avant de finaliser leur commande tandis que d'autres créent une commande et attendent avant de finaliser. 

Les 47 commandes en statut pending_payment présentent toutes un paiement confirmé (montant moyen 474,42€), ce qui valide la cohérence du workflow : le système enregistre le paiement avant de faire progresser la commande vers les étapes suivantes de traitement.

L'analyse du statut shipped révèle le cœur du problème identifié : sur 862 commandes expédiées au total, 839 (97,33%) sont correctement payées avec un montant moyen de 485,39€, tandis que 23 commandes (2,67%) ont été expédiées sans aucun paiement validé. 
--> Ces 23 cas représentent un manque à gagner de 10 714,07€, soit 92,5% du montant total des anomalies. 


### 2c. Validation de la table charges
La table charges couvre l'intégralité du périmètre avec 1 000 commandes distinctes présentes, confirmant qu'aucune commande n'est totalement absente du système de paiement. 
--> Le volume total de 1 078 transactions pour 1 000 commandes indique l'existence de tentatives multiples pour certaines commandes (échec suivi de réussite, ou charge suivie de refund).

Le taux de réussite des paiements s'établit à 97,5% (975 charges succeeded sur 1000 tentatives), démontrant la fiabilité de la plateforme de paiement. 
Le système enregistre également 78 refunds succeeded, cohérents avec les 42 commandes 'cancelled' identifiées, confirmant un processus de remboursement fonctionnel.
--> Les 25 charges échouées correspondent précisément au nombre de commandes sans paiement validé identifié en Question 2a

Les 1078 transactions totales se décomposent en 1000 tentatives de paiement (charges) et 78 remboursements (refunds), validant la cohérence du système : 
--> chaque commande génère une tentative de paiement unique, et seules les commandes annulées déclenchent des refunds.

Le problème identifié est circonscrit mais critique. 
--> Cette situation révèle une faille dans le processus de validation pré-expédition, où le système ne bloque pas systématiquement l'envoi de marchandise lorsque le statut de paiement est failed. 
--> Les tentatives de paiement ont bien été initiées mais le workflow d'expédition s'est déclenché malgré l'échec de ces transactions.
--> Le manque à gagner total s'élève à 11 583,12€, représentant environ 2,77% du chiffre d'affaires estimé, basé sur les 418 000€ de CA identifiés en Partie 2 pour les commandes shipped. 
--> Sur ce montant, 10 714,07€ concernent des commandes déjà expédiées, constituant une perte réelle. 
--> Les 869,05€ restants correspondent aux deux commandes open, toujours en cours de traitement.

Ainsi, la correction immédiate du workflow de validation est impérative. 
--> Le système doit intégrer un verrou bloquant automatiquement toute progression vers l'envoi si la commande ne présente pas au moins une charge avec status = 'succeeded'. 
--> Cette règle doit être implémentée au niveau de l'application de gestion des commandes. 
--> Par la suite, la procédure de recouvrement doit être initiée pour les 23 clients concernés par les commandes expédiées sans paiement. 


### 
