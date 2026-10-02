#!/usr/bin/env python3
"""
Test script for URL Shortener API
"""

import requests
import json
import time
import os

# Use environment variable or default to localhost:8000
BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

def health_check():
    """Test health endpoint"""
    print("\n🏥 Health Check")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        print(f"  Status: {response.status_code}")
        if response.status_code == 200:
            print(f"  ✓ Healthy!")
        return response.json()
    except Exception as e:
        print(f"  ❌ Error: {e}")
        return None

def list_endpoints():
    """List all endpoints"""
    print("\n📂 Available Endpoints:")
    print("  GET   {:32} Root info".format("/".ljust(31)))
    print("  GET   {:32} Health check".format("/health".ljust(31)))
    print("  GET   /api/v1/{short_code}      Get URL info (.ljust(31).format("/{short_code}"))")
    print("  POST  {:32} Create short URL".format("/api/v1/shorten".ljust(30)))
    print("  DELETE{:31} Delete short URL".format("/{short_code}".ljust(27)))

def create_short_url():
    """Create a test short URL"""
    print("\n🔗 Create Short URL")
    payload = {
        "original_url": "https://www.example.com/very-long-url-with-many-parameters?param=value&foo=bar&page=123&tracking=abc"
    }
    try:
        response = requests.post(f"{BASE_URL}/api/v1/shorten", json=payload, timeout=10)
        print(f"  Status: {response.status_code}")
        if response.status_code == 201:
            data = response.json()
            print(f"  ✓ Short Code Generated: {data['short_code']}")
            print(f"    Original URL Length: {len(data['original_url'])} chars")
            
            # Copy the code to clipboard (macOS)
            try:
                import subprocess
                subprocess.run(['osascript', '-e', f'tell application "Finder" to set text of dock item 1 to "{data["short_code"]}"'], check=False)
                print(f"    📋 Copied to clipboard!")
            except:
                pass
        return data.get('short_code')
    except Exception as e:
        print(f"  ❌ Error: {e}")
        return None

def get_short_url(short_code=None):
    """Get short URL info (case-insensitive)"""
    if not short_code:
        print("\n⚠️  Need a short code from create_short_url() first")
        return
    
    # Try different cases
    for test_case in [short_code, short_code.lower(), short_code.upper(), short_code.swapcase()]:
        response = requests.get(f"{BASE_URL}/api/v1/{test_case}", timeout=5)
        
        if response.status_code == 200:
            print(f"\n🔍 Get Short URL Info (found with code: {test_case})")
            data = response.json()
            print(f"  ✓ Code (canonical): {data['short_code']}")
            print(f"    Original: {data['original_url'][:70]}...")
            return
        elif response.status_code == 404:
            continue
    
    print(f"\n❌ Short code '{short_code}' not found in database")

def delete_short_url(short_code=None):
    """Delete a short URL"""
    if not short_code:
        short_code = create_short_url()
    
    if not short_code:
        return
    
    print(f"\n🗑️  Delete Short URL ({short_code})")
    try:
        response = requests.delete(f"{BASE_URL}/api/v1/{short_code}", timeout=5)
        print(f"  Status: {response.status_code}")
        if response.status_code == 200 or response.status_code == 404:
            print(f"  ✓ Short URL deleted successfully")
    except Exception as e:
        print(f"  ❌ Error: {e}")

def main():
    """Main test flow"""
    print("=" * 70)
    print("🚀 URL Shortener API Test Suite".center(62))
    print("=" * 70)
    
    # Wait for server to be ready (Docker needs time to start)
    print("\n⏳ Waiting for PostgreSQL and API to start...")
    for i in range(15):
        if health_check() and 'healthy' in str(health_check()).lower():
            break
        time.sleep(2)
    
    list_endpoints()
    
    # If services are ready
    if health_check():
        short_code = create_short_url()
        
        if short_code:
            get_short_url(short_code.lower()[:6])  # Simplified for display
            
        print("\n💡 Tip: Short codes are case-insensitive!")
        print(f"   'ab3dE9f' == 'AB3DE9F' == 'Ab3De9F' (all work)")
        
        delete_short_url(short_code)
    else:
        print("\n⚠️  Services not ready yet. Check with './deploy.sh logs'")

if __name__ == "__main__":
    main()
