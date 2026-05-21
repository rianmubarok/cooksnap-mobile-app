import requests
import json
import base64

# API Configuration
API_KEY = "AIzaSyAvMNsdheDPKFIcj7csx6aYvaLjOfdFvmk"
BASE_URL = "https://generativelanguage.googleapis.com/v1beta"

def test_list_models():
    """Test 1: List available models"""
    print("=" * 60)
    print("TEST 1: Listing Available Models")
    print("=" * 60)
    
    url = f"{BASE_URL}/models?key={API_KEY}"
    
    try:
        response = requests.get(url)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("\nAvailable Models:")
            for model in data.get('models', []):
                name = model.get('name', 'Unknown')
                display_name = model.get('displayName', 'Unknown')
                supported_methods = model.get('supportedGenerationMethods', [])
                print(f"  - {name}")
                print(f"    Display Name: {display_name}")
                print(f"    Supported Methods: {', '.join(supported_methods)}")
                print()
        else:
            print(f"Error: {response.text}")
            
    except Exception as e:
        print(f"Exception: {str(e)}")
    
    print()

def test_text_generation():
    """Test 2: Simple text generation"""
    print("=" * 60)
    print("TEST 2: Text Generation (gemini-pro)")
    print("=" * 60)
    
    model = "gemini-pro"
    url = f"{BASE_URL}/models/{model}:generateContent?key={API_KEY}"
    
    payload = {
        "contents": [
            {
                "parts": [
                    {
                        "text": "Say hello in Indonesian"
                    }
                ]
            }
        ]
    }
    
    headers = {
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            text = data['candidates'][0]['content']['parts'][0]['text']
            print(f"Response: {text}")
        else:
            print(f"Error: {response.text}")
            
    except Exception as e:
        print(f"Exception: {str(e)}")
    
    print()

def test_vision_with_url():
    """Test 3: Vision API with image URL"""
    print("=" * 60)
    print("TEST 3: Vision API with Image URL")
    print("=" * 60)
    
    # Try different model names
    models_to_try = [
        "gemini-2.5-flash",
        "gemini-flash-latest",
        "gemini-2.0-flash",
        "gemini-pro-latest"
    ]
    
    for model in models_to_try:
        print(f"\nTrying model: {model}")
        url = f"{BASE_URL}/models/{model}:generateContent?key={API_KEY}"
        
        payload = {
            "contents": [
                {
                    "parts": [
                        {
                            "text": "What is in this image?"
                        },
                        {
                            "inline_data": {
                                "mime_type": "image/jpeg",
                                "data": "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwA/wA//"
                            }
                        }
                    ]
                }
            ],
            "generationConfig": {
                "temperature": 0.1,
                "maxOutputTokens": 256
            }
        }
        
        headers = {
            "Content-Type": "application/json"
        }
        
        try:
            response = requests.post(url, headers=headers, json=payload)
            print(f"  Status Code: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                text = data['candidates'][0]['content']['parts'][0]['text']
                print(f"  ✓ SUCCESS! Response: {text[:100]}...")
                print(f"\n  >>> USE THIS MODEL: {model} <<<\n")
                break
            else:
                print(f"  ✗ Failed: {response.json().get('error', {}).get('message', 'Unknown error')}")
                
        except Exception as e:
            print(f"  ✗ Exception: {str(e)}")
    
    print()

def main():
    print("\n" + "=" * 60)
    print("GEMINI API KEY TESTER")
    print("=" * 60)
    print(f"API Key: {API_KEY[:20]}...{API_KEY[-10:]}")
    print(f"Base URL: {BASE_URL}")
    print("=" * 60 + "\n")
    
    # Run tests
    test_list_models()
    test_text_generation()
    test_vision_with_url()
    
    print("=" * 60)
    print("TESTING COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()
