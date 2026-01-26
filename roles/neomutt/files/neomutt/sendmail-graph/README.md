# Microsoft Graph API Email Sender for Neomutt

This Python script allows neomutt to send emails using the Microsoft Graph API with MSAL authentication.

## Prerequisites

1. Python 3.6 or higher
2. Required Python packages:
   ```bash
   pip3 install msal requests
   ```

3. Azure AD App Registration with the following:
   - Application (client) ID
   - Directory (tenant) ID
   - API permissions: `Mail.Send` (delegated permission)
   - Public client flows enabled

## Azure AD App Registration Setup

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to "Azure Active Directory" → "App registrations" → "New registration"
3. Set the application name (e.g., "Neomutt Graph API")
4. Set "Supported account types" to appropriate option (usually "Single tenant")
5. Click "Register"
6. Note the **Application (client) ID** and **Directory (tenant) ID**
7. Go to "API permissions" → "Add a permission" → "Microsoft Graph" → "Delegated permissions"
8. Add `Mail.Send` permission
9. Go to "Authentication" → "Advanced settings" → Enable "Allow public client flows"

## Configuration

1. Create the configuration directory:
   ```bash
   mkdir -p ~/.config/neomutt
   ```

2. Copy the example configuration file:
   ```bash
   cp graph-api-config.json.example ~/.config/neomutt/graph-api-config.json
   ```

3. Edit `~/.config/neomutt/graph-api-config.json` with your details:
   ```json
   {
     "client_id": "your-application-client-id",
     "tenant_id": "your-tenant-id",
     "authority": "https://login.microsoftonline.com/your-tenant-id",
     "scopes": [
       "https://graph.microsoft.com/Mail.Send"
     ],
     "user_email": "your-email@example.com"
   }
   ```

4. Make the script executable:
   ```bash
   chmod +x sendmail-graph.py
   ```

5. Copy the script to a location in your PATH (optional):
   ```bash
   sudo cp sendmail-graph.py /usr/local/bin/
   ```

## Neomutt Configuration

Add the following to your `~/.config/neomutt/neomuttrc` or `~/.neomuttrc`:

```
# Set the sendmail command to use the Graph API script
set sendmail = "/path/to/sendmail-graph.py"

# Optional: Set envelope from address
set envelope_from = yes
set use_from = yes
set from = "your-email@example.com"
set realname = "Your Name"
```

## Usage

Once configured, neomutt will automatically use the script when sending emails. The script:

1. Reads the MIME-formatted email from stdin (neomutt provides this)
2. Authenticates with Microsoft Graph API using MSAL
3. Encodes the MIME content in base64
4. Sends the email via the Graph API

### First-Time Authentication

On first use, the script will prompt you to authenticate:

1. You'll see a message with a URL and a code
2. Open the URL in a browser
3. Enter the code when prompted
4. Sign in with your Microsoft account
5. The token will be cached for future use in `~/.config/neomutt/graph-api-token-cache.json`

## Troubleshooting

### "Configuration file not found"
Make sure `~/.config/neomutt/graph-api-config.json` exists and is properly formatted.

### "Failed to acquire token"
- Ensure your Azure AD app has the correct permissions
- Check that "Allow public client flows" is enabled
- Verify your client_id and tenant_id are correct

### "Failed to send email. Status code: 400"
- The MIME content may be malformed
- Check that the email has proper headers (From, To, Subject)

### "Failed to send email. Status code: 403"
- The user doesn't have permission to send mail
- The Mail.Send permission may not be granted or consented

## Testing

Test the script manually:

```bash
# Create a test email
cat > test-email.txt << 'EOF'
From: your-email@example.com
To: recipient@example.com
Subject: Test Email
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8

This is a test email sent via Microsoft Graph API.
EOF

# Send it
cat test-email.txt | ./sendmail-graph.py
```

## Security Notes

- The token cache file contains sensitive authentication tokens. Ensure it has appropriate permissions:
  ```bash
  chmod 600 ~/.config/neomutt/graph-api-token-cache.json
  ```
- Keep your `graph-api-config.json` secure as it contains your client ID
- The script uses device flow authentication, which is suitable for CLI applications
- Tokens are automatically refreshed when they expire

## Features

- Supports full MIME format (multipart messages, attachments, HTML content, etc.)
- Automatic token caching and refresh
- Device flow authentication (no need to store passwords)
- Compatible with neomutt's sendmail interface
- Saves sent messages to Exchange Online's "Sent Items" folder

## License

This script is provided as-is for use with neomutt and Microsoft Graph API.
