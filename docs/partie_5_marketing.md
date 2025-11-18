# PARTIE 5 – Marketing & Media
Cette analyse vise à évaluer la performance des campagnes marketing en mesurant leur contribution au chiffre d'affaires et à l'acquisition de nouveaux clients. 
--> L'objectif est d'identifier les canaux les plus rentables, d'optimiser l'allocation budgétaire et de quantifier la part du business générée organiquement versus celle issue des investissements marketing. 
--> Ainsi,  la réconciliation entre les commandes, les revenus et les campagnes permet d'établir des métriques fondamentales comme le ROAS (Return on Ad Spend) et le CAC (Customer Acquisition Cost), essentielles pour piloter la stratégie d'acquisition.

## Note méthodologique
Cette analyse de la performance marketing est basée sur le montant des commandes calculé depuis order_items, suivant l'approche comptable adoptée dans les Parties 1-2 et maintenue en cohérence avec l'analyse LTV (Partie 4). 
--> La Partie 3 a révélé que 25 commandes sur 1000 (2,5%) n'ont aucun paiement enregistré, représentant un manque à gagner de 11 583€ dont 10 714€ concernent des commandes déjà expédiées.

 Les ROAS présentés constituent des bornes supérieures devant être ajustés de 2,5% pour une vision strictement cash. 
--> Cette approche comptable reste pertinente pour l'analyse marketing car elle mesure la génération de demande, objectif premier du marketing. 
--> L'ajustement de 2,5% s'applique uniformément à tous les canaux, préservant le classement relatif des campagnes et ne modifiant pas les décisions d'allocation budgétaire.


## Exploration des campagnes 
L'analyse porte sur quatre campagnes marketing déployées entre avril et septembre 2025, couvrant quatre canaux distincts. 
--> La campagne Spring Sale sur Meta a été lancée en avril avec un budget de 5000€ pour une durée d'un mois. 
--> Summer Launch sur Google représente l'investissement le plus important avec 8000€ alloués sur le mois de juin. 
--> Flash Sale sur Instagram constitue une opération courte de cinq jours en juillet avec 3000€ de budget. 
--> Back to School sur TikTok était planifiée pour la rentrée (15 août au 15 septembre) avec un budget de 6000€, mais se situe en dehors de la période couverte par les données disponibles et ne peut donc pas être évaluée dans cette analyse.

La table attribution révèle que certaines commandes sont attribuées à plusieurs campagnes simultanément. 
--> Cette multi-attribution s'observe  sur les campagnes Spring Sale et Summer Launch où des commandes enregistrent jusqu'à trois points de contact avec différentes campagnes. 

La table attribution contient 916 lignes reliant 549 commandes distinctes à trois campagnes actives. 
Cette multi-attribution s'observe systématiquement avec des commandes enregistrant jusqu'à trois points de contact pour une même campagne. 
L'analyse détaillée des 20 premières lignes montre que les commandes 1, 4, 6, 10, 14, 16, 23, 24 et 34 apparaissent chacune deux fois ou plus pour la même campagne, témoignant d'un problème structurel de duplication plutôt que d'une véritable attribution multi-touch intentionnelle.

Cette duplication a nécessité une correction avant toute analyse. La correction a consisté à ajouter une étape de déduplication (SELECT DISTINCT) sur les couples (order_id, campaign_id) avant agrégation, garantissant qu'une commande n'est comptée qu'une seule fois par campagne. 
Sur les 1000 commandes totales du dataset:
--> 549 (54,9%) sont attribuées à au moins une campagne marketing, 
--> 451 (45,1%) sont classées comme organiques
--> Ce taux d'attribution de 55% indique une répartition équilibrée entre acquisition payante et trafic naturel, configuration saine témoignant d'une marque établie disposant d'une notoriété organique substantielle tout en investissant activement dans la croissance via le marketing payant.


## Question 1 : Performance par campagne

L'analyse des métriques de performance révèle des écarts significatifs entre les quatre campagnes déployées. 

### Spring Sale (Meta) - Performance d'exception
La campagne Spring Sale sur Meta domine tous les indicateurs avec un ROAS de 24,03, signifiant que chaque euro investi génère 24,03€ de revenu. 
--> Ce ratio exceptionnel s'explique par un spend de 5000€ ayant généré 120 147€ de revenu via 259 commandes, produisant un profit net de 115 147€. 
--> Le panier moyen s'établit à 464€, légèrement inférieur à la moyenne du site (482€).
--> L'efficacité en acquisition est très intéressante avec un CAC de seulement 29€ pour 172 nouveaux clients.
--> Cette performance signifie que Meta a principalement servi de canal d'acquisition plutôt que de réactivation, capturant une audience qualifiée au coût le plus bas du dataset. `


### Summer Launch (Google) - Performance solide mais coûteuse
La campagne Summer Launch sur Google affiche un ROAS de 16,07, excellent en valeur absolue mais nettement inférieur à Meta. 
--> Avec un budget de 8000€, elle génère 128 558€ de revenu via 258 commandes, produisant un profit net de 120 558€. 
--> Le panier moyen atteint 498€, le plus élevé des trois campagnes actives, suggérant que Google capte une audience disposée à des achats plus conséquents.
--> Le principal point faible réside dans le CAC de 307€, dix fois supérieur à celui de Meta, pour seulement 26 nouveaux clients acquis. 
--> Ce coût élevé s'explique par un taux de nouveaux clients de seulement 14,4%, révélant que Google sert principalement à réactiver des clients existants plutôt qu'à en acquérir de nouveaux.
--> Les 180 clients totaux touchés incluent donc 154 clients existants (85,6%), configuration inverse de celle observée sur Meta.

Cette différence de positionnement entre Meta (acquisition) et Google (réactivation) s'explique par les mécaniques propres à chaque canal. 
--> Google Ads capte une intention de recherche existante où les clients cherchent activement des produits, incluant potentiellement des clients déjà familiers avec la marque. 
--> Meta diffuse des publicités dans le fil d'actualité, touchant des audiences nouvelles qui découvrent la marque pour la première fois.


### Flash Sale (Instagram) - Échec structurel
La campagne Flash Sale sur Instagram présente un ROAS de 5,75, techniquement rentable mais largement insuffisant pour justifier l'investissement. 
--> Avec 3000€ de budget, elle génère 17 256€ de revenu via seulement 32 commandes, produisant un profit net de 14 256€. Le panier moyen atteint 539€, le plus élevé du dataset, mais ce chiffre ne compense pas le volume faibles de commandes.

Le point d'échec majeur réside dans l'acquisition avec un unique nouveau client pour 3000€ investis, produisant un CAC aberrant de 3000€. 
--> Ce ratio indique un problème fondamental de ciblage ou de créativité publicitaire ayant échoué à convaincre de nouveaux acheteurs. 
--> Le taux de nouveaux confirme que la campagne a principalement touché des clients existants (31 clients sur 32), montrant ainsi, une configuration coûteuse et inefficace pour une campagne censée générer de la croissance.

La courte durée de 5 jours seulement, a probablement limité l'optimisation algorithmique de la plateforme et la capacité à trouver les bonnes audiences. 
--> Instagram nécessite généralement une phase d'apprentissage plus longue pour affiner le ciblage et améliorer la performance. 

Malgré un ROAS techniquement positif, cette campagne constitue un échec stratégique. Les 14 256€ de profit net auraient pu générer bien plus de valeur s'ils avaient été réalloués sur Meta (potentiellement 342 366€ de revenu avec un ROAS de 24,03) ou Google (115 166€ de revenu). 
--> Le coût d'opportunité de maintenir Instagram est donc considérable.

### Back to School (TikTok) - Absence totale de résultats
### Back to School (TikTok) - Hors période d'analyse

La campagne Back to School sur TikTok, planifiée pour le 15 août au 15 septembre avec un budget de 6000€, se situe en dehors de la période couverte par le dataset (1er avril au 14 juillet). 
--> Cette campagne n'apparaît pas dans les résultats car elle n'avait pas encore été lancée au moment de l'extraction des données.
--> L'absence de données d'attribution confirme que TikTok n'a généré aucune commande sur la période avril-juillet, ce qui est cohérent avec une campagne non encore exécutée. 

L'écart de performance entre Meta (ROAS 24,03, CAC 29€) et Instagram (ROAS 5,75, CAC 3000€) révèle que tous les canaux social media ne se valent pas. 
--> Meta bénéficie d'algorithmes de ciblage plus matures, d'un volume d'utilisateurs plus large et d'options de ciblage plus granulaires. 
--> Instagram, bien que propriété de Meta, fonctionne différemment avec un format visuel nécessitant des créatifs de très haute qualité et une audience plus jeune potentiellement moins intéressée par le catalogue produit.

Google se positionne comme canal complémentaire capturant l'intention de recherche et servant principalement à réactiver la base existante. 
--> Son ROAS de 16,07 reste excellent mais son CAC élevé le rend moins adapté à l'acquisition pure qu'à la maximisation de la valeur des clients existants.

Ainsi, on peut procéder aux recommendations suivantes:

1. Réallocation budgétaire immédiate - Augmenter significativement le budget Meta (de 5000€ à 15 000-20 000€) pour capitaliser sur un ROAS exceptionnel tant que la performance se maintient et qu'on ne sature pas l'audience.

2. Maintien Google avec ajustement - Conserver Google à 8000€ mais repositionner explicitement comme canal de réactivation plutôt que d'acquisition. 
--> Optimiser les campagnes pour cibler les segments à haute valeur de la base existante (clients cohorte avril par exemple).

3. Arrêt immédiat Instagram - Couper la campagne Instagram et réallouer les 3000€ sur Meta ou Google. 
--> Si Instagram doit être retesté, exiger une refonte complète des créatifs et du ciblage avec un budget test à 1000 euros par example.

4. Évaluation TikTok post-lancement - Suivre rigoureusement les performances de la campagne TikTok prévue en août-septembre avec des KPIs stricts (ROAS minimum 10, CAC maximum 100€). 
--> TikTok convient mieux aux marques B2C grand public avec un fort potentiel viral et une audience jeune.
--> Cependant, Tiktok aura tendance à suivre les mêmes effets que Instagram. Ainsi, une refonte complète des créatifs et du ciblage est importante de sorte à attirer la population relativement jeune de TikTok. 

5. Suivi du ratio LTV/CAC par canal - Établir un tableau de bord mesurant l'évolution du CAC et de la LTV par canal et par cohorte mensuelle pour détecter rapidement les dégradations de performance et ajuster les budgets en conséquence.



## Question 2a : Campagne la plus rentable (ROAS maximum)

La campagne Spring Sale sur Meta est la plus rentable avec un ROAS de 24,03, soit 24,03€ générés pour chaque euro investi. 
--> Ce résultat exceptionnel positionne Meta comme le canal le plus intéressant.

Avec un budget de 5000€, Spring Sale génère 120 147€ de revenu pour un profit net de 115 147€. 
--> Ce niveau de profit représente 23 fois la mise initiale, performance rare dans le marketing digital où un ROAS supérieur à 5:1 est déjà considéré comme excellent. 


## Question 2b : Campagne la plus efficace en acquisition (CAC minimum)

Spring Sale sur Meta remporte également le titre de campagne la plus efficace en acquisition client avec un CAC de 29€, dix fois inférieur à Google (307€) et cent fois inférieur à Instagram (3000€).
--> Ce CAC exceptionnel s'accompagne d'un volume significatif de 172 nouveaux clients. 
--> Cette efficacité en acquisition justifie ainsi une augmentation massive du budget Meta tant que le CAC reste sous contrôle. 


## Question 3 : Répartition Organique vs Marketing
L'analyse de la répartition des commandes révèle un équilibre quasi-parfait entre trafic marketing et trafic organique.

Sur les 1000 commandes totales du dataset :
- 549 commandes (54,9%) sont attribuées aux campagnes marketing, générant 265 960€ de revenu (55,1%). 
- 451 commandes (45,1%) sont classées comme organiques, générant 216 615€ de revenu (44,9%).

Cette répartition 55/45 témoigne d'une situation saine où l'entreprise n'est ni trop dépendante du marketing payant, présentant un risque de non-rentabilité si les coûts augmentent, 
ni trop dépendante du trafic organique, avec un risque de stagnation si l'acquisition naturelle plafonne. 

### Panier moyen
Le panier moyen marketing s'établit à 484€ contre 480€ en organique, différence négligeable de 1% indiquant que la qualité des commandes est similaire entre les deux sources. 
--> Cette quasi-égalité suggère que le marketing ne se contente pas de générer du volume à bas panier mais attire des clients au même profil de dépense que le trafic organique.


Cette répartition 55/45 positionne ainsi l'entreprise dans une zone de confort stratégique. 
--> Le marketing payant génère suffisamment de volume (55%) pour assurer la croissance et l'acquisition de nouveaux clients
--> tandis que le trafic organique (45%) fournit une base stable réduisant la dépendance aux plateformes publicitaires et leurs variations de coûts.

La part organique de 45% peut provenir de plusieurs sources complémentaires:
- référencement naturel (SEO) captant des recherches Google sans coût publicitaire
- - trafic direct de clients revenant sur le site par mémorisation de la marque
- bouche-à-oreille et recommandations clients
- présence sur les réseaux sociaux en contenu non sponsorisé


## Question 3b : Détail par canal
La décomposition par canal marketing révèle une distribution relativement équilibrée entre Meta et Google, avec Instagram plutot sur le déclin.

### Meta (259 commandes, 120 147€, 25,9% des commandes, 24,9% du revenu)
Meta génère un volume de commandes similaire à Google (259 vs 258) mais avec un revenu légèrement inférieur (120 147€ vs 128 558€)
--> expliqué par un panier moyen plus bas (464€ vs 498€). 
--> Malgré ce panier inférieur, Meta reste le canal champion grâce à son ROAS exceptionnel de 24,03 et son CAC de 29€.

La part de 25,9% des commandes totales positionne Meta comme un pilier majeur de l'acquisition. 
Cette performance démontre que Meta n'est pas un canal d'appoint mais un moteur de croissance à part entière, capable de générer un quart des commandes du site avec une rentabilité record.

### Google (258 commandes, 128 558€, 25,8% des commandes, 26,6% du revenu)
Google génère le revenu le plus élevé des trois canaux actifs (128 558€) grâce au panier moyen le plus élevé (498€).
--> La part de 26,6% du revenu total en fait le premier contributeur marketing en valeur absolue, devant Meta (24,9%).

Cette position dominante en revenu mais secondaire en rentabilité (ROAS 16,07) et en acquisition (CAC 307€) positionne Google comme canal de réactivation et de maximisation de valeur plutôt que de conquête pure. 
--> Les 258 commandes incluent une majorité de clients existants (85,6%), configuration où Google excelle en capturant l'intention de recherche de clients déjà familiers avec la marque.

### Instagram (32 commandes, 17 256€, 3,2% des commandes, 3,6% du revenu)
Instagram occupe une position marginale avec seulement 3,2% des commandes et 3,6% du revenu, contribution ne justifiant pas l'investissement de 3000€. 
Le panier moyen de 539€ (le plus élevé) ne compense pas le volume faible de 32 commandes et l'échec en acquisition, avec 1 seul nouveau client engendré.
--> Cette faible part relative confirme qu'Instagram ne fonctionne pas pour ce catalogue produit ou cette audience. 


### Organique (451 commandes, 216 615€, 45,1% des commandes, 44,9% du revenu)
Le trafic organique demeure le premier contributeur en volume absolu (451 commandes) et le deuxième en revenu (216 615€)
--> devant chaque canal pris individuellement mais derrière l'ensemble du marketing payant. 
--> Le panier moyen de 480€, très proche de la moyenne globale (482€), confirme que le trafic organique n'est ni de qualité supérieure ni inférieure au trafic payant.
Cette part substantielle d'organique (45%) constitue un actif stratégique majeur réduisant la dépendance aux plateformes publicitaires. 
--> Chaque euro non dépensé en publicité pour générer ces 216 615€ améliore directement la marge nette. 
