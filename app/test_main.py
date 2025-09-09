import pytest
import json
from app import app

@pytest.fixture
def client():
    """Configura cliente de teste Flask"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello_devops(client):
    """Testa se a função retorna 'Hello, DevOps'"""
    response = client.get('/')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert data['message'] == 'Hello, DevOps'

def test_health_check(client):
    """Testa o endpoint de health check"""
    response = client.get('/health')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert data['status'] == 'healthy'