import sqlite3
import pandas as pd
from pathlib import Path

# Configuration des chemins
ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"
DB_PATH = ROOT / "dacker.db"

csv_files = ["attribution", "campaigns", "charges", "order_items", "orders", "products" ]
con = sqlite3.connect(DB_PATH)

for name in csv_files:
    csv_path = DATA_DIR / f"{name}.csv"
    df = pd.read_csv(csv_path)
    df.to_sql(name, con, if_exists="replace", index=False)
    print(f"File {name} a été importé et contient {len(df)} de lignes")

con.close()

print(f"Nous avons procédé à l'import des données et la base de donné a bel et bien été crée au path suivant : {DB_PATH}")

