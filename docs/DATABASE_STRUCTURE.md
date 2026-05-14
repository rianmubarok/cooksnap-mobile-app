# Database Structure

# Users

| Field         | Type   |
| ------------- | ------ |
| id            | String |
| name          | String |
| email         | String |
| password_hash | String |
| profile_image | String |
| created_at    | Date   |

---

# Recipes

| Field        | Type    |
| ------------ | ------- |
| id           | String  |
| recipe_name  | String  |
| description  | String  |
| image_url    | String  |
| ingredients  | JSON    |
| steps        | JSON    |
| cooking_time | Integer |
| difficulty   | String  |
| category     | String  |
| source_url   | String  |
| video_url    | String  |
| created_at   | Date    |

---

# Favorites

| Field      | Type     |
| ---------- | -------- |
| id         | String   |
| user_id    | Relation |
| recipe_id  | Relation |
| created_at | Date     |

---

# Ingredients

| Field           | Type   |
| --------------- | ------ |
| id              | String |
| ingredient_name | String |
| category        | String |

---

# Example Ingredient JSON

```json
[
  {
    "name": "Telur",
    "quantity": 2,
    "unit": "butir"
  }
]
```
