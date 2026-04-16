from flask import Flask, jsonify, request

app = Flask(__name__)

# Простое in-memory хранилище
USERS_DB = {1: {"id": 1, "name": "Alice", "email": "alice@example.com"}}
NEXT_ID = 2

@app.route("/", methods=["GET"])
def root():
    return jsonify({"message": "Hello, World!"}), 200

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200

@app.route("/api/users", methods=["GET"])
def get_users():
    return jsonify({"users": list(USERS_DB.values())}), 200

@app.route("/api/users", methods=["POST"])
def create_user():
    global NEXT_ID
    data = request.get_json(silent=True)
    if not data or "name" not in data or "email" not in data:
        return jsonify({"error": "Fields 'name' and 'email' are required"}), 400
    
    user = {"id": NEXT_ID, "name": data["name"], "email": data["email"]}
    USERS_DB[NEXT_ID] = user
    NEXT_ID += 1
    return jsonify(user), 201

@app.route("/api/users/<int:user_id>", methods=["GET"])
def get_user(user_id):
    user = USERS_DB.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify(user), 200

@app.route("/api/users/<int:user_id>", methods=["DELETE"])
def delete_user(user_id):
    if user_id not in USERS_DB:
        return jsonify({"error": "User not found"}), 404
    del USERS_DB[user_id]
    return jsonify({"message": "User deleted"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)