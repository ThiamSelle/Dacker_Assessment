# Partie 2 - Analyse Produit 

## Note méthodologique
Cette analyse porte exclusivement sur les commandes avec le statut shipped, représentant les ventes confirmées et effectivement livrées aux clients. 
Ce filtre exclut les commandes annulées, en attente de validation ou non confirmées, garantissant que les revenus calculés correspondent au chiffre d'affaires réellement généré et évitant toute surévaluation des performances commerciales.

Les revenus sont calculés sur la base du montant des commandes expédiées, obtenu depuis la table order_items via la formule quantity × unit_price. 
--> Cette approche suit le principe de comptabilité d'engagement où le chiffre d'affaires est reconnu au moment de la livraison.
--> Elle reflète la demande client réelle, la consommation effective de stock, les coûts logistiques engagés et la performance du catalogue produit indépendamment des mécaniques promotionnelles.


## Question 1 : KPIs par produit

L'analyse des performances produits repose sur la jointure entre order_items_clean, orders_clean et la table products, avec un filtrage sur les commandes expédiées. 
Cette requête calcule six indicateurs permettant d'évaluer la contribution de chaque produit au chiffre d'affaires réel.

Les résultats révèlent un catalogue équilibré avec des performances homogènes. 
--> Le Cap (B44) domine légèrement avec un chiffre d'affaires de 54 649€ pour 835 unités vendues et 178 clients distincts touchés. 
--> Le Metal Bottle (D22) suit avec 54 000€ de revenus pour 835 unités également, mais affiche une pénétration client à 183 clients. 
--> Le Dacker Mug (C01) présente un profil particulier avec le volume de ventes le plus élevé à 868 unités, générant 54 000€, et la meilleure pénétration client du catalogue avec 185 clients distincts.
--> Les prix moyens pratiqués s'établissent dans une fourchette étroite de 60€ à 65€, témoignant de tarifs homogènes sur l'ensemble du catalogue. 
--> Le Sticker Pack (F99) affiche le prix moyen le plus élevé à 65,22€, tandis que le Dacker Mug pratique le tarif le plus accessible à 60,77€.
--> Le Black Hoodie (E13) se distingue par des performances inférieures avec 44 511€ de chiffre d'affaires, 756 unités vendues et seulement 169 clients distincts. 
--> Cet écart significatif avec le reste du catalogue pourrait s'expliquer par plusieurs facteurs : une saisonnalité défavorable pour un vêtement chaud sur la période d'avril, ou une demande structurellement plus faible pour ce type de produit. 
--> L'ensemble du catalogue affiche des dates de première vente concentrées le 1er avril 2025, confirmant un lancement simultané ou un renouvellement complet de la gamme à cette date.

## Question 2 : Pays avec le plus de ventes par produit
Cette analyse identifie pour chaque produit le marché géographique où il performe le mieux en thermes de volume. 

Les résultats révèlent une géographie commerciale contrastée avec des affinités produit-marché marquées. 
--> L'Allemagne émerge comme le marché le plus performant en volume absolu avec le Notebook (H77) totalisant 216 unités, soit la meilleure performance individuelle de l'analyse. 

La France se positionne comme le marché dominant en diversité avec trois produits leaders : 
--> le Cap et les Socks atteignent tous deux exactement 210 unités vendues, tandis que le Sticker Pack totalise 178 unités. 
--> Cette triple présence française dans le classement confirme la France comme le marché stratégique prioritaire, représentant probablement la base historique de l'entreprise ou le marché test initial. 
--> À vérifier auprès de Dacker.com ;) 

L'Italie montre une présence remarquable sur le Dacker Mug avec 198 unités vendues, seul produit où ce marché domine. 
Cette concentration sur un article de vaisselle peut refléter une culture du café particulièrement développée. 

L'Espagne capte le leadership sur le Metal Bottle avec 193 unités et le Blue T-shirt avec 174 unités. 

L'absence totale de la Belgique dans ce classement des pays leaders par produit est notable. 
Aucun des huit produits du catalogue ne performe mieux en Belgique que dans les quatre autres marchés. 
Cette sous-représentation systématique reflète probablement la taille relative plus modeste du marché belge, mais pourrait également révéler des lacunes dans la stratégie d'acquisition client ou dans la notoriété de la marque dans ce pays. 


## Question 3 : Top 3 produits par revenu moyen par commande

Cette métrique identifie les produits générant le plus de valeur par transaction en divisant le revenu total par le nombre de commandes distinctes contenant le produit. 
--> Un revenu moyen élevé par commande peut résulter d'un prix unitaire élevé, de quantités importantes achetées en une fois, ou d'une combinaison des deux facteurs.

Le podium est dominé par trois produits affichant des performances remarquablement proches. 
--> Le Cap arrive en tête avec 198,72€ par commande sur la base de 275 commandes distinctes générant un chiffre d'affaires total de 54 649€. 
--> Le Notebook suit immédiatement à 196,82€ par commande pour 269 commandes totalisant 52 945€. 
--> Le Metal Bottle (D22) complète le trio à 192,85€ par commande réparti sur 280 commandes pour 54 000€ de revenus. 

L'écart entre le premier et le troisième n'est que de 6€, soit une variation de 3% seulement, suggérant des comportements d'achat très similaires pour ces trois produits.

Le contraste entre ces revenus moyens par commande et les prix unitaires observés en Question 1 est particulièrement révélateur. 
--> Le Cap affiche un prix moyen de 65,32€ mais génère près de 199€ par commande, soit un facteur multiplicateur de 3. 
--> Cette différence massive ne peut s'expliquer que par deux mécanismes combinés : les clients achètent fréquemment ce produit en quantité multiple dans une même commande, ou ils l'associent systématiquement à d'autres articles dans leur panier.
--> Le même pattern s'observe pour le Notebook et le Metal Bottle, confirmant que ces trois produits bénéficient d'un fort effet panier.

Cette dynamique révèle des comportements d'achat structurels plutôt que ponctuels. 
--> Les clients ne se contentent pas d'acheter un Cap isolément, ils en commandent plusieurs unités simultanément, probablement pour équiper une équipe, pour offrir, ou pour constituer un stock. 
--> Le Notebook présente un profil similaire avec un prix unitaire de 64,29€ mais un revenu par commande de 197€, suggérant des achats groupés fréquents, cohérents avec un usage professionnel ou éducatif où l'on commande pour plusieurs personnes. 
--> Le nombre de commandes distinctes varie légèrement entre les trois produits, confirmant que la différence de revenu moyen par commande ne provient pas d'un échantillon restreint mais bien d'un comportement d'achat systématique.

