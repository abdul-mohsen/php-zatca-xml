import uuid
from datetime import datetime
import json
import os
import pandas as pd

def to_billx(id, p, name):
    print(p)

    return {
        "id": id,
        "unitCode": "PCE",
        "quantity": p["quantity"],
        "lineExtensionAmount": p["total_before_vat"],
        "item": {
            "name": name,
            "classifiedTaxCategory": [
                {
                    "percent": p["vat"],
                    "taxScheme": {
                        "id": "VAT"
                    }
                }
            ]
        },
        "price": {
            "amount": p["price"],
            "unitCode": "UNIT",
            "allowanceCharges": [
                {
                    "isCharge": False,
                    "reason": "discount",
                    "amount": 0.00
                }
            ]
        },
        "taxTotal": {
            "taxAmount": p["vat_total"],
            "roundingAmount": p["total_including_vat"]
        }
    }

def to_bill(id, quantity, price, name):
    cost = quantity * price

    return {
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
                    "isCharge": False,
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


def start(engine):
    print("started bill")
    # Fetch all data from the table using a raw SQL query
    table_name = 'bill'  # Replace with your actual table name
    query = """
            SELECT 
            b.id,
                            CONCAT('https://ifritah.com/bill/', b.id) AS url,
                            effective_date,
                            payment_due_date,
                            b.state as state,
                            b.sub_total,
                            b.discount,
                            b.vat,
                            b.store_id,
                            total_before_vat,
                            total_vat,
                            total,
                            sequence_number,
                            merchant_id,
                            maintenance_cost,
                            note,
                            b.userName as userName,
                            user_phone_number,
                            company.name as company_name,
                            company.vat_registration_number,
                            store.address_name,
                            COALESCE(
                                    (SELECT JSON_ARRAYAGG(
                                            JSON_OBJECT(
                                                    'product_id', p.product_id,
                                                    'price', p.price,
                                                    'quantity', p.quantity,
                                                    'vat', p.vat,
                                                    'total_before_vat', p.total_before_vat,
                                                    'vat_total', p.vat_total,
                                                    'total_including_vat', p.total_including_vat
                                            )
                                    )
                                    FROM bill_product p
                                    WHERE p.bill_id = b.id), 
                                    JSON_ARRAY()) AS products,
                            COALESCE(
                                    (SELECT JSON_ARRAYAGG(
                                            JSON_OBJECT(
                                                    'part_name', m.part_name,
                                                    'price', m.price,
                                                    'quantity', m.quantity,
                                                    'vat', m.vat,
                                                    'total_before_vat', m.total_before_vat,
                                                    'vat_total', m.vat_total,
                                                    'total_including_vat', m.total_including_vat
                                            )
                                    )
                                    FROM bill_manual_product m
                                    WHERE m.bill_id = b.id), 
                                    JSON_ARRAY()) AS manual_products
            FROM 
                bill_totals b
                    JOIN 
                            store on store.id = b.store_id 
                    JOIN 
                            company on company.id = store.company_id
            where b.state = 1
                    ;
    """
    try:
        result_df = pd.read_sql(query, engine)

        # Convert the DataFrame to JSON
        json_result = json.loads(result_df.to_json(orient='records'))
        # Print the JSON result
        print(f"to process with python bill {len(json_result)}")
    except Exception as e:
        print(f"The error '{e}' occurred")
    with open('base.json') as f:
        r = json.load(f)


    for data in  json_result:
        r["uuid"] = str(uuid.uuid4())
        dt_object = datetime.fromtimestamp(data["effective_date"]/1000)
        formatted_date_time = dt_object.strftime("%Y-%m-%d %H:%M:%S").split(" ")
        r["bill_id"] = data["id"]
        r["issueDate"] = formatted_date_time[0]
        r["issueTiem"] = formatted_date_time[1]
        r["taxTotal"] = {
            "taxAmount": data["total_vat"],
            "subTotals": [{
                "taxableAmount": data["total_before_vat"],
                "taxAmount": data["total_vat"],
                "taxCategory": {
                    "percent": 15,
                    "taxScheme": {
                        "id": "VAT"
                    }
                }
            }]
        }
        r["legalMonetaryTotal"] = {
            "lineExtensionAmount": data["total_before_vat"],
            "taxExclusiveAmount": data["total_before_vat"],
            "taxInclusiveAmount": data["total"],
            "prepaidAmount": 0,
            "payableAmount": data["total"],
            "allowanceTotalAmount": 0
        }
        invoiceLines = []
        id = 0
        for p in json.loads(data["products"]):
            if p["price"] == None or p["quantity"] == None:
                continue
            id = id + 1
            item = to_billx(id, p, f"{id}")
            invoiceLines.append(item)
        for p in json.loads(data["manual_products"]):
            if p["price"] == None or p["quantity"] == None:
                continue
            id = id + 1
            item = to_billx(id, p, p["part_name"])
            invoiceLines.append(item)
        cost = data["maintenance_cost"]
        if cost != 0:
            id = id + 1
            invoiceLines.append(to_bill(id, 1, cost, "maintenance_cost"))
        r["invoiceLines"] = invoiceLines

        # Check if the directory exists
        directory = f'bills/{data["company_name"]}/'

        if not os.path.exists(directory):
            # Create the directory
            os.makedirs(directory)
        else:
            print(f"Directory '{directory}' already exists.")

        with open(f'{directory}{data["sequence_number"]:0>7}_{data["id"]}.json', 'w') as f:
            json.dump(r, f, indent=4)



