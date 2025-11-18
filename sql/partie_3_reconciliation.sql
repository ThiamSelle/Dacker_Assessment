----- Partie 3 : Réconciliation paiement
.mode column
.headers on
.width 12 15 15 12 15 15 12 12 15 20


-- ====================================================================
-- QUESTION 1 : Réconciliation commande vs paiements
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 1 : Réconciliation paiements"
.print "========================================"
.print ""
.print "Comparaison montant commande vs charges bancaires"
.print "Top 20 commandes avec les plus gros ecarts"
.print ""

WITH order_amounts AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.shipping_country,
        o.status,
        ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    GROUP BY o.id, o.customer_id, o.shipping_country, o.status
),

charge_amounts AS (
    SELECT
        order_id,
        ROUND(SUM(CASE WHEN type = 'charge' AND status = 'succeeded' THEN amount ELSE 0 END), 2) AS montant_charges_total,
        ROUND(SUM(CASE WHEN type = 'refund' AND status = 'succeeded' THEN amount ELSE 0 END), 2) AS montant_remboursements,
        COUNT(CASE WHEN type = 'charge' AND status = 'succeeded' THEN 1 END) AS nb_charges_reussies,
        COUNT(CASE WHEN type = 'refund' AND status = 'succeeded' THEN 1 END) AS nb_remboursements
    FROM charges
    GROUP BY order_id
)

SELECT
    oa.order_id,
    oa.customer_id,
    oa.shipping_country,
    oa.status AS statut_commande,
    oa.montant_commande,
    COALESCE(ca.montant_charges_total, 0) AS montant_charges,
    COALESCE(ca.montant_remboursements, 0) AS montant_remboursements,
    COALESCE(ca.nb_charges_reussies, 0) AS nb_charges,
    COALESCE(ca.nb_remboursements, 0) AS nb_remboursements,
    ROUND(oa.montant_commande - COALESCE(ca.montant_charges_total, 0), 2) AS difference_absolue,
    ROUND(
        CASE
            WHEN oa.montant_commande > 0 THEN
                ((oa.montant_commande - COALESCE(ca.montant_charges_total, 0)) / oa.montant_commande) * 100
            ELSE 0
        END,
    2) AS difference_pct,
    CASE
        WHEN oa.montant_commande = COALESCE(ca.montant_charges_total, 0) THEN 'OK'
        WHEN COALESCE(ca.montant_charges_total, 0) = 0 THEN 'AUCUN_PAIEMENT'
        WHEN oa.montant_commande > COALESCE(ca.montant_charges_total, 0) THEN 'SOUS_PAIEMENT'
        ELSE 'SUR_PAIEMENT'
    END AS statut_reconciliation
FROM order_amounts oa
LEFT JOIN charge_amounts ca ON oa.order_id = ca.order_id
ORDER BY ABS(oa.montant_commande - COALESCE(ca.montant_charges_total, 0)) DESC
LIMIT 25;

.print ""
.print ""


-- ====================================================================
-- QUESTION 2a : Distribution par statut de réconciliation
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 2a : Distribution globale"
.print "========================================"
.print ""
.print "Repartition des commandes par statut de reconciliation"
.print ""

WITH order_amounts AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.shipping_country,
        o.status,
        ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS montant_commande
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    GROUP BY o.id, o.customer_id, o.shipping_country, o.status
),
charge_amounts AS (
    SELECT
        order_id,
        ROUND(SUM(CASE WHEN type = 'charge' AND status = 'succeeded' THEN amount ELSE 0 END), 2) AS montant_charges_total,
        ROUND(SUM(CASE WHEN type = 'refund' AND status = 'succeeded' THEN amount ELSE 0 END), 2) AS montant_remboursements,
        COUNT(CASE WHEN type = 'charge' AND status = 'succeeded' THEN 1 END) AS nb_charges_reussies,
        COUNT(CASE WHEN type = 'refund' AND status = 'succeeded' THEN 1 END) AS nb_remboursements
    FROM charges
    GROUP BY order_id
),
reconciliation_complete AS (
    SELECT
        oa.order_id,
        oa.customer_id,
        oa.shipping_country,
        oa.status AS statut_commande,
        oa.montant_commande,
        COALESCE(ca.montant_charges_total, 0) AS montant_charges,
        COALESCE(ca.montant_remboursements, 0) AS montant_remboursements,
        COALESCE(ca.nb_charges_reussies, 0) AS nb_charges,
        COALESCE(ca.nb_remboursements, 0) AS nb_remboursements,
        ROUND(oa.montant_commande - COALESCE(ca.montant_charges_total, 0), 2) AS difference_absolue,
        ROUND(
            CASE
                WHEN oa.montant_commande > 0 THEN
                    ((oa.montant_commande - COALESCE(ca.montant_charges_total, 0)) / oa.montant_commande) * 100
                ELSE 0
            END,
        2) AS difference_pourcentage,
        CASE
            WHEN oa.montant_commande = COALESCE(ca.montant_charges_total, 0) THEN 'OK'
            WHEN COALESCE(ca.montant_charges_total, 0) = 0 THEN 'AUCUN_PAIEMENT'
            WHEN oa.montant_commande > COALESCE(ca.montant_charges_total, 0) THEN 'SOUS_PAIEMENT'
            ELSE 'SUR_PAIEMENT'
        END AS statut_reconciliation
    FROM order_amounts oa
    LEFT JOIN charge_amounts ca ON oa.order_id = ca.order_id
)
SELECT
    statut_reconciliation,
    COUNT(*) AS nb_commandes,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders_clean), 2) AS pourcentage,
    ROUND(SUM(difference_absolue), 2) AS total_difference
FROM reconciliation_complete
GROUP BY statut_reconciliation
ORDER BY nb_commandes DESC;

.print ""
.print ""


-- ====================================================================
-- QUESTION 2b : Analyse croisée statut commande vs réconciliation
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 2b : Croisement statuts"
.print "========================================"
.print ""
.print "Analyse par statut de commande et statut de reconciliation"
.print ""

WITH order_amounts AS (
    SELECT
        o.id AS order_id,
        o.customer_id,
        o.shipping_country,
        o.status,
        ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS montant_commande  -- COALESCE ajouté
    FROM orders_clean o
    LEFT JOIN order_items_clean oi ON o.id = oi.order_id
    GROUP BY o.id, o.customer_id, o.shipping_country, o.status
),
charge_amounts AS (
    SELECT
        order_id,
        ROUND(SUM(CASE WHEN type = 'charge' AND status = 'succeeded' THEN amount ELSE 0 END), 2) AS montant_charges_total,
        ROUND(SUM(CASE WHEN type = 'refund' AND status = 'succeeded' THEN amount ELSE 0 END), 2) AS montant_remboursements,
        COUNT(CASE WHEN type = 'charge' AND status = 'succeeded' THEN 1 END) AS nb_charges_reussies,
        COUNT(CASE WHEN type = 'refund' AND status = 'succeeded' THEN 1 END) AS nb_remboursements
    FROM charges
    GROUP BY order_id
),
reconciliation_complete AS (
    SELECT
        oa.order_id,
        oa.customer_id,
        oa.shipping_country,
        oa.status AS statut_commande,
        oa.montant_commande,
        COALESCE(ca.montant_charges_total, 0) AS montant_charges,
        COALESCE(ca.montant_remboursements, 0) AS montant_remboursements,
        COALESCE(ca.nb_charges_reussies, 0) AS nb_charges,
        COALESCE(ca.nb_remboursements, 0) AS nb_remboursements,
        ROUND(oa.montant_commande - COALESCE(ca.montant_charges_total, 0), 2) AS difference_absolue,
        ROUND(
            CASE
                WHEN oa.montant_commande > 0 THEN
                    ((oa.montant_commande - COALESCE(ca.montant_charges_total, 0)) / oa.montant_commande) * 100
                ELSE 0
            END,
        2) AS difference_pourcentage,
        CASE
            WHEN oa.montant_commande = COALESCE(ca.montant_charges_total, 0) THEN 'OK'
            WHEN COALESCE(ca.montant_charges_total, 0) = 0 THEN 'AUCUN_PAIEMENT'
            WHEN oa.montant_commande > COALESCE(ca.montant_charges_total, 0) THEN 'SOUS_PAIEMENT'
            ELSE 'SUR_PAIEMENT'
        END AS statut_reconciliation
    FROM order_amounts oa
    LEFT JOIN charge_amounts ca ON oa.order_id = ca.order_id
)
SELECT
    statut_commande,
    statut_reconciliation,
    COUNT(*) AS nb_commandes,
    ROUND(AVG(montant_commande), 2) AS montant_moyen,
    ROUND(SUM(difference_absolue), 2) AS manque_a_gagner_total
FROM reconciliation_complete
GROUP BY statut_commande, statut_reconciliation
ORDER BY statut_commande, nb_commandes DESC;

.print ""
.print ""


-- ====================================================================
-- QUESTION 2c : Investigation de la table charges
-- ====================================================================

.print ""
.print "========================================"
.print "QUESTION 2c : Statistiques charges"
.print "========================================"
.print ""
.print "Vue globale de la table charges"
.print ""

SELECT
    COUNT(DISTINCT order_id) AS commandes_avec_charges,
    COUNT(*) AS total_lignes_charges,
    SUM(CASE WHEN type = 'charge' THEN 1 ELSE 0 END) AS total_charges,
    SUM(CASE WHEN type = 'refund' THEN 1 ELSE 0 END) AS total_refunds,
    SUM(CASE WHEN type = 'charge' AND status = 'succeeded' THEN 1 ELSE 0 END) AS charges_reussies,
    SUM(CASE WHEN type = 'charge' AND status = 'failed' THEN 1 ELSE 0 END) AS charges_echouees,
    SUM(CASE WHEN type = 'refund' AND status = 'succeeded' THEN 1 ELSE 0 END) AS refunds_reussis,
    ROUND(100.0 * SUM(CASE WHEN type = 'charge' AND status = 'succeeded' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN type = 'charge' THEN 1 ELSE 0 END), 0), 2) AS taux_reussite_paiements_pct
FROM charges;

.print ""
.print ""