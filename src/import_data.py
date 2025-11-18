import sqlite3
import pandas as pd
from pathlib import Path

# Configuration des chemins
ROOT = Path(__file__).resolve().parents[1]

DATA_DIR = ROOT / "data"
RAW_DIR = DATA_DIR / "raw_files"
DB_DIR = DATA_DIR / "database"
DB_PATH = DB_DIR / "dacker.db"

csv_files = ["attribution", "campaigns", "charges", "order_items", "orders", "products"]
con = sqlite3.connect(DB_PATH)

# Import des fichiers CSV et création de la databse
for name in csv_files:
    csv_path = RAW_DIR / f"{name}.csv"
    df = pd.read_csv(csv_path)
    df.to_sql(name, con, if_exists="replace", index=False)
    print(f"Le fichier {name} a été importé et contient {len(df)} lignes.")

con.close()

print(f"Nous avons procédé à l'import des données et la base de données a bien été créée au chemin suivant : {DB_PATH}")
