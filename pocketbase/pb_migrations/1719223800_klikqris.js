migrate((db) => {
  const dao = new Dao(db);

  // 1. Add premium_until to users
  let usersCollection;
  try {
    usersCollection = dao.findCollectionByNameOrId("users");
    usersCollection.schema.addField(new SchemaField({
      "system": false,
      "id": "premium_until",
      "name": "premium_until",
      "type": "date",
      "required": false,
      "presentable": false,
      "unique": false,
      "options": {
        "min": "",
        "max": ""
      }
    }));
    dao.saveCollection(usersCollection);
  } catch (e) {
    console.log("Error adding premium_until to users:", e);
  }

  // 2. Create transactions collection
  try {
    const transactionsCollection = new Collection({
      "id": "transactions123",
      "name": "transactions",
      "type": "base",
      "system": false,
      "schema": [
        {
          "system": false,
          "id": "tx_order_id",
          "name": "order_id",
          "type": "text",
          "required": true,
          "presentable": true,
          "unique": true,
          "options": {
            "min": null,
            "max": 100,
            "pattern": ""
          }
        },
        {
          "system": false,
          "id": "tx_user_id",
          "name": "user_id",
          "type": "relation",
          "required": true,
          "presentable": false,
          "unique": false,
          "options": {
            "collectionId": "_pb_users_auth_",
            "cascadeDelete": true,
            "minSelect": null,
            "maxSelect": 1,
            "displayFields": null
          }
        },
        {
          "system": false,
          "id": "tx_amount",
          "name": "amount",
          "type": "number",
          "required": true,
          "presentable": false,
          "unique": false,
          "options": {
            "min": 0,
            "max": null,
            "noDecimal": true
          }
        },
        {
          "system": false,
          "id": "tx_total_amt",
          "name": "total_amount",
          "type": "number",
          "required": true,
          "presentable": false,
          "unique": false,
          "options": {
            "min": 0,
            "max": null,
            "noDecimal": true
          }
        },
        {
          "system": false,
          "id": "tx_status",
          "name": "status",
          "type": "select",
          "required": true,
          "presentable": true,
          "unique": false,
          "options": {
            "maxSelect": 1,
            "values": ["PENDING", "PAID", "EXPIRED"]
          }
        },
        {
          "system": false,
          "id": "tx_signature",
          "name": "signature",
          "type": "text",
          "required": true,
          "presentable": false,
          "unique": false,
          "options": {
            "min": null,
            "max": null,
            "pattern": ""
          }
        }
      ],
      "indexes": [
        "CREATE UNIQUE INDEX idx_transactions_order_id ON transactions (order_id)",
        "CREATE INDEX idx_transactions_user_id ON transactions (user_id)"
      ],
      "listRule": "@request.auth.id = user_id",
      "viewRule": "@request.auth.id = user_id",
      "createRule": null,
      "updateRule": null,
      "deleteRule": null,
    });

    dao.saveCollection(transactionsCollection);
  } catch (e) {
    console.log("Error creating transactions collection:", e);
  }
}, (db) => {
  const dao = new Dao(db);
  
  try {
    const transactionsCollection = dao.findCollectionByNameOrId("transactions");
    dao.deleteCollection(transactionsCollection);
  } catch (e) { }

  try {
    const usersCollection = dao.findCollectionByNameOrId("users");
    usersCollection.schema.removeField("premium_until");
    dao.saveCollection(usersCollection);
  } catch (e) { }
});
