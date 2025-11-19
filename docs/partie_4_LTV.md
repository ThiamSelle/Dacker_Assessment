# Partie 4 : Cohortes et Lifetime Value (LTV)

L'analyse de cohortes permet de suivre l'évolution de la valeur client au fil du temps en regroupant les clients selon leur mois d'acquisition. 
--> Cette approche permet ainsi de dépasser les limites d'une analyse globale qui mélange clients récents et anciens, en révélant les patterns spécifiques de comportement et de dépenses propres à chaque client acquis. 
--> Ainsi, la Customer Lifetime Value (LTV) mesure le montant cumulé des dépenses effectuées par un client depuis son premier achat, nous permettant d'établir un indicateur central pour évaluer la rentabilité de l'acquisition et la qualité de la rétention.


## Note méthodologique
Cette analyse de la Customer Lifetime Value est basée sur le montant des commandes calculé depuis order_items, suivant l'approche comptable adoptée dans les Parties 1, 2 et 3. 
--> La Partie 3 a révélé que 25 commandes sur 1000 (2,5%) n'ont aucun paiement enregistré, représentant un manque à gagner de 11 583€ dont 10 714€ concernent des commandes déjà expédiées.

Les valeurs de LTV présentées constituent des bornes supérieures devant être ajustées de 2,5% pour obtenir une vision strictement cash. 
--> Cette approche comptable reste pertinente pour la LTV car elle mesure la valeur client sur un horizon de 12-24 mois pendant lequel les créances constituent des montants récupérables via les processus de recouvrement structurés. 
--> Le taux d'anomalie de 2,5% ne change pas les conclusions stratégiques sur les ratios LTV/CAC ni sur les décisions d'investissement en acquisition.


## Question 1 : Association date de première commande
L'échantillon de 20 commandes révèle des profils client variés.
--> Le client 1000 présente un pattern simple avec deux achats espacés d'un mois, pour des montants respectifs de 299€ et 546€.
--> Le client 1001 présente deux commandes concentrées sur le premier mois d'activité avec des montants élevés (299€ et 1 262€).
--> Le client 1002 témoigne d'un profil actif avec six commandes réparties sur quatre mois, démontrant un engagement régulier avec des montants significatifs à chaque transaction (de 155€ à 969€).
--> Le client 1003 montre un comportement plus erratique avec trois commandes sur trois mois présentant une forte variance en therme de prix : de 19€ à 535€.
--> LE client 1004 présente deux commandes concentrées sur le premier mois d'activité avec des montants élevés (425€ et 573€).
--> Le client 1005 témoigne d'un profil actif avec cinq commandes réparties sur le même mois, démontrant un engagement ponctuel avec des montants significatifs à chaque transaction (de 153€ à 420€).



## Question 2 : LTV par cohorte mensuelle
### Cohorte Avril 2025 
La cohorte avril constitue la plus mature du dataset avec 171 clients acquis générant 120 495€ de dépenses au mois zéro, soit un panier moyen initial de 705€ par client.
--> Ce montant initial élevé témoigne d'une qualité d'acquisition remarquable où les nouveaux clients effectuent des transactions significatives dès leur arrivée sur la plateforme.
--> L'évolution mensuelle montre un taux de rétention de 57% au mois 1 avec 97 clients actifs générant 75 389€ de dépenses supplémentaires, portant la LTV cumulée à 195 884€.
--> Le mois 2 maintient une base active de 93 clients (54% de la cohorte initiale) avec 76 849€ de dépenses et une LTV cumulée atteignant 272 733€.
--> Le panier moyen des commandes progresse de manière continue passant de 469€ au mois 0 à 537€ au mois 2, indiquant que les clients fidélisés augmentent progressivement leur niveau d'engagement et de dépenses == signal positif de satisfaction des clients.
--> Le mois 3 révèle cependant une rupture significative avec seulement 52 clients actifs (30% de la cohorte initiale), représentant une chute de 44% par rapport au mois 2. Les dépenses de la période chutent à 32 832€, portant la LTV cumulée à 305 565€ soit une progression de seulement 12% contre 39% le mois précédent.
--> Cette cassure brutale suggère l'absence de stratégie de réengagement efficace après le deuxième mois d'activité, période critique où les clients décident de poursuivre ou non leur relation avec la marque.

### Cohorte Mai 2025 
La cohorte mai présente une taille réduite avec 78 clients acquis, soit 54% de moins que la cohorte avril.
--> Cette contraction du volume d'acquisition constitue un premier signal d'alerte sur la capacité à maintenir un flux régulier de nouveaux clients.
--> Les dépenses initiales s'élèvent à 45 911€ avec un panier moyen de commande de 433€, en baisse de 8% par rapport à avril, suggérant que la qualité d'acquisition légèrement inférieure.
--> L'évolution de la rétention montre 45 clients actifs au mois 1 (58% de rétention, similaire à avril) générant 30 643€ de dépenses et portant la LTV cumulée à 76 555€.
--> Le mois 2 accuse une forte dégradation avec seulement 17 clients actifs (22% de la cohorte initiale), générant 12 135€ de dépenses pour une LTV cumulée de 88 689€.
--> Cette trajectoire nettement plus faible se traduit par une LTV par client de 1 137€ à deux mois contre 1 595€ pour la cohorte avril, soit 29% de moins.

Le panier moyen présente une stagnation préoccupante oscillant entre 433€ et 528€ sans la progression régulière observée pour la cohorte avril.
--> Cette absence de montée en gamme suggère que les clients de mai n'approfondissent pas leur relation avec la plateforme et restent sur un niveau d'engagement initial sans évolution qualitative.


### Cohorte Juin 2025
La cohorte juin ne compte que 32 clients acquis, représentant une chute de 59% par rapport à mai et de 81% par rapport à avril.
--> Le panier moyen initial s'établit à 430€, en baisse de 1% par rapport à mai et de 8% par rapport à avril, démontrant une relative stabilité, mais à un niveau inférieur aux premiers mois.
--> La rétention au mois 1 s'effondre avec seulement 7 clients actifs (22% contre 57% pour avril et 58% pour mai), révélant ainsi que plus de trois clients sur quatre abandonnent après leur premier achat.

Les dépenses du mois un ne s'élèvent qu'à 3 487€, portant la LTV cumulée à 21 564€ soit 674€ par client sur deux mois.
--> Ce niveau représente 41% de moins que la LTV équivalente de la cohorte avril au mois 1 (1 146€)
--> Le panier moyen chute à 388€ au mois 1 contre 430€ au mois 0, confirmant non seulement l'absence de progression mais une régression de 10%.
La combinaison d'un volume d'acquisition faible, d'un panier initial réduit, d'une rétention catastrophique et d'une dégradation du panier moyen positionne cette cohorte comme déficitaire si on la compare aux standards établis par la cohorte avril.


### Cohorte Juillet 2025
La cohorte juillet ne compte que 7 clients avec un panier moyen de 267€, en chute de 38% par rapport à juin et de 43% par rapport à avril.
--> L'échantillon est cependant trop faible et trop récent pour permettre une analyse significative, mais s'inscrit dans la continuité de la dégradation observée depuis avril.


Pour plus de visibilité, voici un récapitualtif des LTV en fonction des cohortes et des mois. 

### LTV par cohorte 
Cohorte    Clients   Mois    LTV cumulative   LTV/client
─────────  ────────  ──────  ───────────────  ──────────
Avril      171       0       120 495,08 €     704,65 €
                     1       195 884,35 €     1 145,52 €
                     2       272 732,85 €     1 594,93 €
                     3       305 565,22 €     1 787,05 €

Mai        78        0       45 911,37 €      588,61 €
                     1       76 554,67 €      981,47 €
                     2       88 689,20 €      1 137,04 €

Juin       32        0       18 076,60 €      564,89 €
                     1       21 564,07 €      674,00 €

Juillet    7         0       2 138,09 €       305,44 €



# Question 3 : Utilité et mise en perspective de l'analyse LTV
L'analyse de cohortes constitue un outil fondamental pour mesurer la rentabilité réelle de l'acquisition client en permettant de suivre la génération de valeur dans le temps plutôt que de se limiter à une mesure du chiffre d'affaires. 
--> Elle permet d'évaluer si les investissements marketing produisent des clients rentables sur le long terme ou simplement des acheteurs ponctuels dont la valeur ne couvre pas le coût d'acquisition. 
--> La comparaison entre cohortes révèle quels périodes où quels canaux génèrent les acquisitions les plus qualitatives, orientant ainsi les décisions d'allocation budgétaire.
--> Cette approche sert également de système d'alerte pour détecter les dégradations de performance avant qu'elles ne deviennent critiques. 
--> Une cohorte qui stagne rapidement après le mois zéro signale un problème de fidélisation nécessitant une intervention rapide, tandis qu'une trajectoire de LTV en croissance régulière valide l'efficacité des mécanismes de rétention. 
--> Les cohortes matures fournissent des références empiriques pour projeter le potentiel de revenu des cohortes récentes, permettant d'établir des prévisions financières plus fiables.

L'analyse LTV ne prend son sens qu'en relation avec le coût d'acquisition client pour chaque période. 
--> Le ratio LTV/CAC doit idéalement dépasser 3:1 pour assurer une marge suffisante couvrant les coûts opérationnels et permettant la croissance. 
--> Une cohorte affichant une LTV de 1500€ mais acquise à un CAC de 1000€ génère une marge brute de seulement 33%, potentiellement insuffisante pour assurer la rentabilité globale de l'activité. 
--> La connaissance précise du CAC par cohorte permet d'identifier quelles générations de clients sont structurellement rentables et lesquelles constituent des investissements déficitaires.

Le taux de rétention constitue un indicateur complémentaire essentiel révélant combien de clients de chaque cohorte restent actifs sur 3, 6 et 12 mois. 
--> Une LTV élevée portée par quelques gros acheteurs masque une situation différente d'une LTV équivalente générée par une large base de clients moyennement actifs. 
--> Le premier cas présente un risque de concentration tandis que le second témoigne d'une base solide et diversifiée. 
--> L'analyse du taux de rétention permet d'anticiper l'érosion naturelle de la valeur d'une cohorte et d'ajuster les prévisions de revenu en conséquence.

La saisonnalité et le contexte externe doivent être également pris en compte dans l'interprétation des résultats. 
--> Une cohorte acquise pendant le Black Friday peut présenter une LTV initiale très élevée au mois zéro due aux promotions et au fort volume d'achats, puis une pente faible les mois suivants car ces clients sont majoritairement des chasseurs d'offres sans intention de fidélisation. 
--> À l'inverse, une cohorte acquise en période creuse via du trafic organique peut démarrer avec une LTV initiale modeste mais progresser régulièrement grâce à la qualité de l'audience.

La segmentation par canal d'acquisition affine la compréhension des dynamiques LTV. 
--> Une analyse peut montrer une dégradation globale masquant que certains canaux continuent de performer excellemment tandis que d'autres se sont effondrés. 
--> Un canal SEO peut générer des clients à forte LTV avec un excellent taux de rétention mais en volumes limités, tandis qu'un canal paid social peut produire des volumes importants avec une LTV faible. 
--> L'arbitrage stratégique entre ces canaux nécessite de connaître précisément leur contribution respective à la LTV globale.


