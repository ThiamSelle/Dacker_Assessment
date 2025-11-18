.mode column
.headers on
.width 20 15 10 10


-- ====================================================================
-- EXPLORATION DES TABLES
-- ====================================================================

.print ""
.print "========================================"
.print "LISTE DES TABLES"
.print "========================================"
.print ""

SELECT name, type
FROM sqlite_master
WHERE type IN ('table', 'view')
ORDER BY name;

.print ""
.print ""


-- ====================================================================
-- TABLE: PRODUCTS
-- ====================================================================

.print ""
.print "========================================"
.print "TABLE: PRODUCTS"
.print "========================================"
.print ""

.print "Structure de la table :"
.print ""
PRAGMA table_info(products);

.print ""
.print ""
.print "Nombre total de lignes :"
.print ""
SELECT COUNT(*) as total_rows FROM products;

.print ""
.print ""
.print "Apercu des donnees :"
.print ""
SELECT * FROM products;

.print ""
.print ""


-- ====================================================================
-- TABLE: CAMPAIGNS
-- ====================================================================

.print ""
.print "========================================"
.print "TABLE: CAMPAIGNS"
.print "========================================"
.print ""

.print "Structure de la table :"
.print ""
PRAGMA table_info(campaigns);

.print ""
.print ""
.print "Nombre total de lignes :"
.print ""
SELECT COUNT(*) as total_rows FROM campaigns;

.print ""
.print ""
.print "Apercu des donnees :"
.print ""
SELECT * FROM campaigns;

.print ""
.print ""


-- ====================================================================
-- TABLE: ORDERS
-- ====================================================================

.print ""
.print "========================================"
.print "TABLE: ORDERS"
.print "========================================"
.print ""

.print "Structure de la table :"
.print ""
PRAGMA table_info(orders);

.print ""
.print ""
.print "Nombre total de lignes :"
.print ""
SELECT COUNT(*) as total_rows FROM orders;

.print ""
.print ""
.print "Apercu des donnees:"
.print ""
SELECT * FROM orders LIMIT 5;

.print ""
.print ""


-- ====================================================================
-- TABLE: ORDER_ITEMS
-- ====================================================================

.print ""
.print "========================================"
.print "TABLE: ORDER_ITEMS"
.print "========================================"
.print ""

.print "Structure de la table :"
.print ""
PRAGMA table_info(order_items);

.print ""
.print ""
.print "Nombre total de lignes :"
.print ""
SELECT COUNT(*) as total_rows FROM order_items;

.print ""
.print ""
.print "Apercu des donnees:"
.print ""
SELECT * FROM order_items LIMIT 5;

.print ""
.print ""


-- ====================================================================
-- TABLE: ATTRIBUTION
-- ====================================================================

.print ""
.print "========================================"
.print "TABLE: ATTRIBUTION"
.print "========================================"
.print ""

.print "Structure de la table :"
.print ""
PRAGMA table_info(attribution);

.print ""
.print ""
.print "Nombre total de lignes :"
.print ""
SELECT COUNT(*) as total_rows FROM attribution;

.print ""
.print ""
.print "Apercu des donnees:"
.print ""
SELECT * FROM attribution LIMIT 5;

.print ""
.print ""


-- ====================================================================
-- TABLE: CHARGES
-- ====================================================================

.print ""
.print "========================================"
.print "TABLE: CHARGES"
.print "========================================"
.print ""

.print "Structure de la table :"
.print ""
PRAGMA table_info(charges);

.print ""
.print ""
.print "Nombre total de lignes :"
.print ""
SELECT COUNT(*) as total_rows FROM charges;

.print ""
.print ""
.print "Apercu des donnees:"
.print ""
SELECT * FROM charges LIMIT 5;

.print ""
.print ""