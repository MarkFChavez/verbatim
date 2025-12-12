# Verbatim

A typing practice app that lets you improve your typing by copying passages from books.

## Setup

Requirements:
- Ruby 3.2.2
- PostgreSQL
- Node.js (for asset compilation)

```bash
# Install dependencies
bundle install

# Setup environment variables
cp .env.example .env

# Setup database
bin/rails db:setup

# Start the server
bin/dev
```

## Testing

```bash
bin/test
```

## Configuration

Typing parameters (passage length, character replacements, etc.) can be configured in:

```
config/typing_parameters.yml
```

## Supported Formats

Currently only `.epub` files are supported.

## Deployment

This app uses [Kamal](https://kamal-deploy.org/) for deployment.

```bash
# Create your deploy config from the template
cp config/deploy.yml.example config/deploy.yml

# Edit with your server details
# - Set your server IP address
# - Set your domain name
# - Set your Docker registry credentials

# Deploy
bin/kamal setup   # First time
bin/kamal deploy  # Subsequent deploys
```
