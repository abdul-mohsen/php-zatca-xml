import uuid
from datetime import datetime
import json
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import os
import pandas as pd

from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

def to_bill(id, quantity, price, name):
    print(id, quantity, price, name)
    cost = quantity * price

    return  
    {
        "id": id,
        "unitCode": "PCE",
        "quantity": quantity,
        "lineExtensionAmount": cost,
        "item": {
            "name": name,
            "classifiedTaxCategory": [
                {
                    "percent": 15,
                    "taxScheme": {
                        "id": "VAT"
                    }
                }
            ]
        },
        "price": {
            "amount": price,
            "unitCode": "UNIT",
            "allowanceCharges": [
                {
                    "isCharge": false,
                    "reason": "discount",
                    "amount": 0.00
                }
            ]
        },
        "taxTotal": {
            "taxAmount": round(cost * .15, 2),
            "roundingAmount": round(cost * 1.15, 2)
        }
    }

# Read database credentials from environment variables
username = os.getenv('DBUSER')
password = os.getenv('PASSWORD')
host = os.getenv('HOST')
database = os.getenv('DBNAME')

# Create the connection string
connection_string = f'mysql+mysqlconnector://{username}:{password}@{host}/{database}'
# Alternatively, if using PyMySQL, use:
# connection_string = f'mysql+pymysql://{username}:{password}@{host}/{database}'

# Create the SQLAlchemy engine
engine = create_engine(connection_string)

# Fetch all data from the table using a raw SQL query
table_name = 'bill'  # Replace with your actual table name
query = """
SELECT p.*, 
JSON_ARRAYAGG(JSON_OBJECT('id', c.product_id, 'price', c.price, 'quantity', c.quantity)) as products,
JSON_ARRAYAGG(JSON_OBJECT('name', d.part_name, 'price', d.price, 'quantity', d.quantity)) as manual_products
FROM bill p
LEFT JOIN bill_product c ON p.id = c.bill_id
LEFT JOIN bill_manual_product d ON p.id = d.bill_id
where p.state = 1
group by p.id
"""
try:
    result_df = pd.read_sql(query, engine)

    # Convert the DataFrame to JSON
    json_result = json.loads(result_df.to_json(orient='records'))
    # Print the JSON result
except Exception as e:
    print(f"The error '{e}' occurred")
with open('base.json') as f:
    r = json.load(f)


for data in  json_result:
    r["uuid"] = str(uuid.uuid4())
    print(data)
    dt_object = datetime.fromtimestamp(data["effective_date"]/1000)
    formatted_date_time = dt_object.strftime("%Y-%m-%d %H:%M:%S").split(" ")
    r["issueDate"] = formatted_date_time[0]
    r["issueTiem"] = formatted_date_time[1]
    r["taxTotal"] = {
        "taxAmount": data["vat"],
        "subTotals": [{
            "taxableAmount": data["sub_total"],
            "taxAmount": data["vat"],
            "taxCategory": {
                "percent": 15,
                "taxScheme": {
                    "id": "VAT"
                }
            }
        }]
    }
    r["legalMonetaryTotal"] = {
        "lineExtensionAmount": data["sub_total"],
        "taxExclusiveAmount": data["sub_total"],
        "taxInclusiveAmount": data["sub_total"] + data["vat"],
        "prepaidAmount": 0,
        "payableAmount": data["sub_total"] + data["vat"],
        "allowanceTotalAmount": 0
    }
    invoiceLines = []
    id = 0
    for p in json.loads(data["products"]):
        if p["price"] == None or p["quantity"] == None:
            continue
        id = id + 1
        invoiceLines.append(to_bill(id, p['quantity'], p['price'], f"{id}"))
    for p in json.loads(data["manual_products"]):
        if p["price"] == None or p["quantity"] == None:
            continue
        id = id + 1
        invoiceLines.append(to_bill(id, p["quantity"], p["price"], p["name"]))
    cost = data["maintenance_cost"]
    if cost != 0:
        id = id + 1
        invoiceLines.append(to_bill(id, 1, cost, "maintenance_cost"))

    with open(f'bills/{data["id"]:0>7}.json', 'w') as f:
        json.dump(r, f, indent=4)



