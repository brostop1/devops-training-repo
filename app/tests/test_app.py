import pytest
from app.main import app

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_root(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.json == {"message": "Hello, World!"}

def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json == {"status": "ok"}

def test_get_users(client):
    resp = client.get("/api/users")
    assert resp.status_code == 200
    assert "users" in resp.json

def test_create_user_success(client):
    resp = client.post("/api/users", json={"name": "Bob", "email": "bob@test.com"})
    assert resp.status_code == 201
    assert resp.json["name"] == "Bob"

def test_create_user_validation_error(client):
    resp = client.post("/api/users", json={"name": "Charlie"})  # нет email
    assert resp.status_code == 400
    assert "error" in resp.json