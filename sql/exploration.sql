.mode column
.headers on
.width 20 15 10 10

-- ========================================
-- LISTE DES TABLES
-- ========================================
.print "===== TABLES ET VUES DISPONIBLES ====="
SELECT name, type FROM sqlite_master
WHERE type IN ('table', 'view')
ORDER BY type, name;

-- ========================================
-- PRODUCTS
-- ========================================
.print ""
.print "========================================="
.print "TABLE: PRODUCTS"
.print "========================================="
PRAGMA table_info(products);
SELECT COUNT(*) as total_lignes FROM products;
SELECT * FROM products;

-- ========================================
-- CAMPAIGNS
-- ========================================
.print ""
.print "========================================="
.print "TABLE: CAMPAIGNS"
.print "========================================="
PRAGMA table_info(campaigns);
SELECT COUNT(*) as total_lignes FROM campaigns;
SELECT * FROM campaigns;

-- ========================================
-- ATTRIBUTION
-- ========================================
.print ""
.print "========================================="
.print "TABLE: ATTRIBUTION"
.print "========================================="
PRAGMA table_info(attribution);
SELECT COUNT(*) as total_lignes FROM attribution;
SELECT * FROM attribution LIMIT 10;

-- ========================================
-- CHARGES
-- ========================================
.print ""
.print "========================================="
.print "TABLE: CHARGES"
.print "========================================="
PRAGMA table_info(charges);
SELECT COUNT(*) as total_lignes FROM charges;
SELECT * FROM charges LIMIT 10;

-- ========================================
-- ORDERS (original)
-- ========================================
.print ""
.print "========================================="
.print "TABLE: ORDERS"
.print "========================================="
PRAGMA table_info(orders);
SELECT COUNT(*) as total_lignes FROM orders;
SELECT * FROM orders LIMIT 5;

-- ========================================
-- ORDERS_CLEAN
-- ========================================
.print ""
.print "========================================="
.print "VUE: ORDERS_CLEAN"
.print "========================================="
.print "Structure (identique à orders):"
PRAGMA table_info(orders);
.print ""
SELECT COUNT(*) as total_lignes FROM orders_clean;
SELECT * FROM orders_clean LIMIT 5;

-- ========================================
-- ORDER_ITEMS (original)
-- ========================================
.print ""
.print "========================================="
.print "TABLE: ORDER_ITEMS"
.print "========================================="
PRAGMA table_info(order_items);
SELECT COUNT(*) as total_lignes FROM order_items;
SELECT * FROM order_items LIMIT 5;

-- ========================================
-- ORDER_ITEMS_CLEAN
-- ========================================
.print ""
.print "========================================="
.print "VUE: ORDER_ITEMS_CLEAN"
.print "========================================="
.print "Structure (identique à order_items):"
PRAGMA table_info(order_items);
.print ""
SELECT COUNT(*) as total_lignes FROM order_items_clean;
SELECT * FROM order_items_clean LIMIT 5;