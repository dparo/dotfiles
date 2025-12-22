#!/usr/bin/env python3
"""
Microsoft Graph API sendMail script for neomutt
Reads MIME-formatted email from stdin and sends via Microsoft Graph API
Uses MSAL for authentication
"""

import sys
import base64
import json
import os
from pathlib import Path
import msal
import requests


# Configuration file path
CONFIG_FILE = os.path.expanduser("~/.config/neomutt/graph-api-config.json")
TOKEN_CACHE_FILE = os.path.expanduser("~/.config/neomutt/graph-api-token-cache.json")


def load_config():
    """Load configuration from JSON file"""
    if not os.path.exists(CONFIG_FILE):
        print(f"Error: Configuration file not found: {CONFIG_FILE}", file=sys.stderr)
        print("Please create a configuration file with the following structure:", file=sys.stderr)
        print(json.dumps({
            "client_id": "your-application-client-id",
            "tenant_id": "your-tenant-id",
            "authority": "https://login.microsoftonline.com/your-tenant-id",
            "scopes": ["https://graph.microsoft.com/Mail.Send"],
            "user_email": "your-email@example.com"
        }, indent=2), file=sys.stderr)
        sys.exit(1)
    
    with open(CONFIG_FILE, 'r') as f:
        return json.load(f)


def load_token_cache():
    """Load token cache from file"""
    cache = msal.SerializableTokenCache()
    if os.path.exists(TOKEN_CACHE_FILE):
        with open(TOKEN_CACHE_FILE, 'r') as f:
            cache.deserialize(f.read())
    return cache


def save_token_cache(cache):
    """Save token cache to file"""
    if cache.has_state_changed:
        os.makedirs(os.path.dirname(TOKEN_CACHE_FILE), exist_ok=True)
        with open(TOKEN_CACHE_FILE, 'w') as f:
            f.write(cache.serialize())


def get_access_token(config):
    """Get access token using MSAL with device flow authentication"""
    cache = load_token_cache()
    
    # Create a public client application
    app = msal.PublicClientApplication(
        config['client_id'],
        authority=config['authority'],
        token_cache=cache
    )
    
    # Try to get token from cache first
    accounts = app.get_accounts()
    result = None
    
    if accounts:
        # Try silent authentication first
        result = app.acquire_token_silent(config['scopes'], account=accounts[0])
    
    if not result:
        # If silent authentication fails, use device flow
        print("No cached token found. Initiating device flow authentication...", file=sys.stderr)
        flow = app.initiate_device_flow(scopes=config['scopes'])
        
        if "user_code" not in flow:
            raise ValueError(f"Failed to create device flow: {flow.get('error_description')}")
        
        print(flow["message"], file=sys.stderr)
        
        # Wait for user to authenticate
        result = app.acquire_token_by_device_flow(flow)
    
    save_token_cache(cache)
    
    if "access_token" in result:
        return result["access_token"]
    else:
        error = result.get("error_description", result.get("error"))
        raise Exception(f"Failed to acquire token: {error}")


def send_email_mime(access_token, mime_content, user_email):
    """
    Send email using Microsoft Graph API with MIME format
    
    Args:
        access_token: OAuth2 access token
        mime_content: MIME-formatted email message as bytes
        user_email: User's email address
    """
    # Base64 encode the MIME content
    mime_base64 = base64.b64encode(mime_content).decode('utf-8')
    
    # Prepare the API endpoint
    url = f"https://graph.microsoft.com/v1.0/users/{user_email}/sendMail"
    
    # Set headers
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'text/plain'
    }
    
    # Send the request
    response = requests.post(url, headers=headers, data=mime_base64)
    
    # Check response
    if response.status_code == 202:
        print("Email sent successfully!", file=sys.stderr)
        return True
    else:
        print(f"Failed to send email. Status code: {response.status_code}", file=sys.stderr)
        print(f"Response: {response.text}", file=sys.stderr)
        return False


def main():
    """Main function"""
    # Load configuration
    config = load_config()
    
    # Read MIME content from stdin
    mime_content = sys.stdin.buffer.read()
    
    if not mime_content:
        print("Error: No email content received from stdin", file=sys.stderr)
        sys.exit(1)
    
    try:
        # Get access token
        access_token = get_access_token(config)
        
        # Send email
        success = send_email_mime(access_token, mime_content, config['user_email'])
        
        if success:
            sys.exit(0)
        else:
            sys.exit(1)
    
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
