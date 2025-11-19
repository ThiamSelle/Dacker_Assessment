# PARTIE 5 – Marketing & Media
Cette analyse vise à évaluer la performance des campagnes marketing en mesurant leur contribution au chiffre d'affaires et à l'acquisition de nouveaux clients. 
--> L'objectif est d'identifier les canaux les plus rentables, d'optimiser l'allocation budgétaire et de quantifier la part du business générée organiquement versus celle issue des investissements marketing. 
--> Ainsi, la réconciliation entre les commandes, les revenus et les campagnes permettent d'établir des métriques fondamentales comme le ROAS (Return on Ad Spend) et le CAC (Customer Acquisition Cost), essentielles pour piloter la stratégie d'acquisition.

## Note méthodologique
Cette analyse de la performance marketing est basée sur le montant des commandes expédiées (status = 'shipped') calculé depuis order_items, suivant l'approche adoptée dans les Parties 1-2 et maintenue en cohérence avec l'analyse LTV (Partie 4).
La Partie 3 a révélé que 23 commandes shipped sur 862 (2,3%) n'ont aucun paiement enregistré, représentant un manque à gagner de 10 714€. 
--> Les ROAS présentés constituent des bornes supérieures devant être ajustés de 2,3% pour une vision strictement cash.
--> Cette approche comptable reste pertinente pour l'analyse marketing car elle mesure la génération de demande, objectif premier du marketing. 
--> L'ajustement de 2,3% s'applique uniformément à tous les canaux, préservant le classement relatif des campagnes et ne modifiant pas les décisions d'allocation budgétaire.

Le périmètre d'analyse se concentre sur les commandes shipped pour assurer la cohérence avec l'analyse LTV (Partie 4) qui mesure la valeur réelle générée par les clients. 
--> Les commandes pending_payment, canceled ou open sont exclues car elles ne constituent pas des revenus confirmés et pourraient artificiellement gonfler les ROAS sans refléter la performance réelle des campagnes.

## Exploration des campagnes 
L'analyse porte sur quatre campagnes marketing déployées entre avril et Juillet 2025, couvrant quatre canaux distincts.
--> La campagne Spring Sale sur Meta a été lancée en avril avec un budget de 5000€ pour une durée d'un mois. 
--> Summer Launch sur Google représente l'investissement le plus important avec 8000€ alloués sur le mois de juin. 
--> Flash Sale sur Instagram constitue une courte campagne de cinq jours en juillet avec 3000€ de budget.
--> Back to School sur TikTok était planifiée pour la rentrée (15 août au 15 septembre) avec un budget de 6000€, mais se situe en dehors de la période couverte par les données et ne peut donc pas être évaluée dans cette analyse.

La table attribution révèle que certaines commandes sont attribuées à plusieurs campagnes simultanément. 
--> Cette multi-attribution s'observe sur les campagnes Spring Sale et Summer Launch où des commandes enregistrent jusqu'à trois points de contact avec différentes campagnes.
--> La table attribution contient 916 lignes reliant 549 commandes distinctes à trois campagnes actives. 
--> Cette multi-attribution s'observe systématiquement avec des commandes enregistrant jusqu'à trois points de contact pour une même campagne. 
--> L'analyse détaillée des 20 premières lignes montre que les commandes 1, 4, 6, 10, 14, 16, 23, 24 et 34 apparaissent chacune deux fois ou plus pour la même campagne, témoignant d'un problème de duplication plutôt que d'une véritable attribution multi-touch intentionnelle.
--> Cette duplication a nécessité une correction avant toute analyse. 

La correction a consisté à ajouter une étape de déduplication (SELECT DISTINCT) sur les couples (order_id, campaign_id) avant agrégation, garantissant qu'une commande n'est comptée qu'une seule fois par campagne.
Sur les 862 commandes shipped totales du dataset:
--> 474 (55,0%) sont attribuées à au moins une campagne marketing,
--> 388 (45,0%) sont classées comme organiques
Ce taux d'attribution de 55% indique une répartition équilibrée entre acquisition payante et trafic naturel, configuration saine témoignant d'une marque établie disposant d'une notoriété organique substantielle tout en investissant activement dans la croissance via le marketing payant.


## Question 1 : Performance par campagne

L'analyse des métriques de performance révèle des écarts significatifs entre les quatre campagnes déployées. 

### Spring Sale (Meta) 
La campagne Spring Sale sur Meta domine avec un ROAS de 20,22, signifiant que chaque euro investi génère 20,22€ de revenu.
--> Ce ratio s'explique par un spend de 5000€ ayant généré 101 120€ de revenu via 223 commandes, produisant un profit net de 96 120€.
--> Le panier moyen s'établit à 453€, légèrement inférieur à la moyenne du site (485€).
--> L'efficacité en acquisition est très importante avec un CAC de seulement 32€ pour 154 nouveaux clients acquis.
--> Le ratio LTV/CAC atteint des sommets : en prenant la LTV mois 3 de la cohorte avril (1 787€ calculée en Partie 4), le ratio grimpe à 55,8:1, largement au-dessus du seuil de rentabilité de 3:1.
--> Cette performance signifie que Meta a principalement servi de canal d'acquisition plutôt que de réactivation, capturant une audience qualifiée au coût le plus bas du dataset, avec un taux de nouveaux clients de 97,5% (154 nouveaux sur 158 clients totaux).

### Summer Launch (Google) 
La campagne Summer Launch sur Google affiche un ROAS de 14,27, excellent en valeur absolue mais nettement inférieur à Meta.
--> Avec un budget de 8000€, elle génère 114 124€ de revenu via 223 commandes, produisant un profit net de 106 124€.
--> Le panier moyen atteint 512€, le plus élevé des trois campagnes actives, suggérant que Google capte une audience disposée à des achats plus conséquents.
--> Le principal point faible réside dans le CAC de 276€, près de 9 fois supérieur à celui de Meta, pour seulement 29 nouveaux clients acquis.
--> Ce coût élevé s'explique par un taux de nouveaux clients de seulement 18,1%, révélant que Google sert principalement à réactiver des clients existants plutôt qu'à en acquérir de nouveaux.
--> Les 160 clients totaux touchés incluent donc 131 clients existants (81,9%), configuration inverse de celle observée sur Meta.

Cette différence de positionnement entre Meta (acquisition) et Google (réactivation) s'explique par les mécaniques propres à chaque canal.
--> Google Ads capte une intention de recherche existante où les clients cherchent activement des produits, incluant potentiellement des clients déjà familiers avec la marque.
--> Meta diffuse des publicités dans le fil d'actualité, touchant des audiences nouvelles qui découvrent la marque pour la première fois.



### Flash Sale (Instagram) 
La campagne Flash Sale sur Instagram présente un ROAS de 5,01, techniquement rentable mais largement inférieur à Google et Meta.
--> Avec 3000€ de budget, elle génère 15 034€ de revenu via seulement 28 commandes, produisant un profit net de 12 034€.
--> Le panier moyen atteint 537€, le plus élevé du dataset, mais ce chiffre ne compense pas le volume faible de commandes.

Le point d'échec majeur réside dans l'acquisition avec seulement 2 nouveaux clients pour 3000€ investis, produisant un CAC aberrant de 1 500€.
--> Ce ratio indique un problème fondamental de ciblage ou de créativité publicitaire ayant échoué à convaincre de nouveaux acheteurs.
--> Le taux de nouveaux clients de 7,4% (2 sur 27 clients totaux) confirme que la campagne a principalement touché des clients existants, montrant ainsi une configuration coûteuse et inefficace pour une campagne censée générer de la croissance.

La courte durée de 5 jours seulement a probablement limité l'optimisation algorithmique de la plateforme et la capacité à trouver les bonnes audiences.
--> Instagram nécessite généralement une phase d'apprentissage plus longue pour affiner le ciblage et améliorer la performance.

Malgré un ROAS techniquement positif, cette campagne constitue un échec stratégique. 
--> Les 12 034€ de profit net auraient pu générer bien plus de valeur s'ils avaient été réalloués sur Meta (potentiellement 242 730€ de revenu avec un ROAS de 20,22) ou Google (171 425€ de revenu avec un ROAS de 14,27).
--> Le coût d'opportunité de maintenir Instagram est donc considérable dans l'assomption que, les ads ne saturent pas auprès de leurs consommateurs. 

### Back to School (TikTok) 
La campagne Back to School sur TikTok, planifiée pour le 15 août au 15 septembre avec un budget de 6000€, se situe en dehors de la période couverte par le dataset (1er avril au 14 juillet).
--> Cette campagne n'apparaît pas dans les résultats car elle n'avait pas encore été lancée au moment de l'extraction des données.
--> L'absence de données d'attribution confirme que TikTok n'a généré aucune commande sur la période avril-juillet, ce qui est cohérent avec une campagne non encore exécutée.


L'écart de performance entre Meta (ROAS 20,22, CAC 32€) et Instagram (ROAS 5,01, CAC 1 500€) révèle que tous les canaux social media ne se valent pas.
--> Meta bénéficie d'algorithmes de ciblage plus matures, d'un volume d'utilisateurs plus large et d'options de ciblage plus granulaires.
--> Instagram, bien que propriété de Meta, fonctionne différemment avec un format visuel nécessitant des créatifs de haute qualité et une audience plus jeune potentiellement moins intéressée par le catalogue produit.

Google se positionne comme canal complémentaire capturant l'intention de recherche et servant principalement à réactiver la base existante.
--> Son ROAS de 14,27 reste excellent mais son CAC élevé le rend moins adapté à l'acquisition pure qu'à la maximisation de la valeur des clients existants.

Ainsi, on peut procéder aux recommandations suivantes:
1. Réallocation budgétaire immédiate - Augmenter significativement le budget Meta (de 5000€ à 15 000-20 000€) pour capitaliser sur un ROAS exceptionnel de 20,22 et un CAC de 32€ tant que la performance se maintient et qu'on ne sature pas l'audience.

2. Maintien Google avec ajustement - Conserver Google à 8000€ mais repositionner explicitement comme canal de réactivation plutôt que d'acquisition.
--> Optimiser les campagnes pour cibler les segments à haute valeur de la base existante (clients cohorte avril par exemple).

3. Arrêt immédiat Instagram - Couper la campagne Instagram et réallouer les 3000€ sur Meta ou Google.
--> Si Instagram doit être retesté, il faut une refonte des créatifs et du ciblage avec un budget test à 1000€ maximum.

4. Évaluation TikTok post-lancement - Suivre rigoureusement les performances de la campagne TikTok prévue en août-septembre avec des KPIs stricts (ROAS minimum 10, CAC maximum 100€).
--> TikTok convient mieux aux marques B2C grand public avec un fort potentiel viral et une audience jeune.
--> Cependant, TikTok aura tendance à suivre les mêmes effets qu'Instagram. Ainsi, une refonte des créatifs et du ciblage est importante de sorte à attirer la population relativement jeune de TikTok.

5. Suivi du ratio LTV/CAC par canal - Établir un tableau de bord mesurant l'évolution du CAC et de la LTV par canal et par cohorte mensuelle pour détecter rapidement les dégradations de performance et ajuster les budgets en conséquence.


## Question 2a : Campagne la plus rentable (ROAS maximum)
La campagne Spring Sale sur Meta est la plus rentable avec un ROAS de 20,22, soit 20,22€ générés pour chaque euro investi.
--> Ce résultat exceptionnel positionne Meta comme le canal le plus performant du dataset.

Avec un budget de 5000€, Spring Sale génère 101 120€ de revenu pour un profit net de 96 120€.
--> Ce niveau de profit représente plus de 19 fois la mise initiale, performance rare dans le marketing digital.

## Question 2b : Campagne la plus efficace en acquisition (CAC minimum)
Spring Sale sur Meta remporte également le titre de campagne la plus efficace en acquisition client avec un CAC de 32€, près de 9 fois inférieur à Google (276€) et 47 fois inférieur à Instagram (1 500€).
--> Ce CAC exceptionnel s'accompagne d'un volume significatif de 154 nouveaux clients acquis.
--> Cette efficacité en acquisition justifie ainsi une augmentation massive du budget Meta tant que le CAC reste sous contrôle et que le volume d'audience qualifiée disponible le permet.


## Question 3 : Répartition Organique vs Marketing
L'analyse de la répartition des commandes shipped révèle un équilibre quasi-parfait entre trafic marketing et trafic organique.
Sur les 862 commandes shipped totales du dataset :
- 474 commandes (55,0%) sont attribuées aux campagnes marketing, générant 230 278€ de revenu (55,1%)
- 388 commandes (45,0%) sont classées comme organiques, générant 187 678€ de revenu (44,9%).

Cette répartition 55/45 témoigne d'une situation saine où l'entreprise n'est ni trop dépendante du marketing payant, présentant un risque de non-rentabilité si les coûts augmentent, ni trop dépendante du trafic organique, avec un risque de stagnation si l'acquisition naturelle plafonne.

Le panier moyen marketing s'établit à 486€ contre 484€ en organique, différence négligeable indiquant que la qualité des commandes est similaire entre les deux sources.
--> Cette quasi-égalité suggère que le marketing ne se contente pas de générer du volume à bas panier mais attire des clients au même profil de dépense que le trafic organique.

Cette répartition 55/45 positionne ainsi l'entreprise dans une zone de confort stratégique.
--> Le marketing payant génère suffisamment de volume (55%) pour assurer la croissance et l'acquisition de nouveaux clients
--> tandis que le trafic organique (45%) fournit une base stable réduisant la dépendance aux plateformes publicitaires et leurs variations de coûts.

## Question 3b : Détail par canal
La décomposition par canal marketing révèle une distribution équilibrée entre Meta et Google (chacun 25,9% des commandes), avec Instagram en position marginale.

### Meta (223 commandes, 101 120€, 25,9% des commandes, 24,2% du revenu)
Meta génère un volume de commandes identique à Google (223 vs 223) mais avec un revenu légèrement inférieur (101 120€ vs 114 124€), expliqué par un panier moyen plus bas (453€ vs 512€).
--> Malgré ce panier inférieur, Meta reste le canal moteur grâce à son ROAS exceptionnel de 20,22 et son CAC de 32€.
La part de 25,9% des commandes totales positionne Meta comme un pilier majeur de l'acquisition. 

### Google (223 commandes, 114 124€, 25,9% des commandes, 27,3% du revenu)
Google génère le revenu le plus élevé des trois canaux actifs (114 124€) grâce au panier moyen le plus élevé (512€).
--> La part de 27,3% du revenu total en fait le premier contributeur marketing en valeur absolue, devant Meta (24,2%).
Cette position dominante en revenu mais secondaire en rentabilité (ROAS 14,27) et en acquisition (CAC 276€) positionne Google comme canal de réactivation et de maximisation de valeur plutôt que de conquête pure.
--> Les 223 commandes incluent une majorité de clients existants (81,9%), configuration où Google excelle en capturant l'intention de recherche de clients déjà familiers avec la marque.

### Instagram (28 commandes, 15 034€, 3,2% des commandes, 3,6% du revenu)
Instagram occupe une position marginale avec seulement 3,2% des commandes et 3,6% du revenu, contribution ne justifiant pas l'investissement de 3000€.
Le panier moyen de 537€ (le plus élevé) ne compense pas le volume faible de 28 commandes et l'échec en acquisition, avec seulement 2 nouveaux clients générés.
--> Cette faible part confirme qu'Instagram ne fonctionne pas pour ce catalogue produit ou cette audience.

### Organique (388 commandes, 187 678€, 45,0% des commandes, 44,9% du revenu)
Le trafic organique demeure le premier contributeur en volume (388 commandes) et le deuxième en revenu (187 678€), devant chaque canal pris individuellement mais derrière l'ensemble du marketing payant.
--> Le panier moyen de 484€, très proche de la moyenne globale (485€), confirme que le trafic organique n'est ni de qualité supérieure ni inférieure au trafic payant.
Cette part substantielle d'organique (45%) constitue un actif stratégique majeur réduisant la dépendance aux plateformes publicitaires.
--> Chaque euro non dépensé en publicité pour générer ces 187 678€ améliore directement la marge nette et témoigne de la notoriété naturelle de la marque ainsi que de la qualité du référencement et du bouche-à-oreille.