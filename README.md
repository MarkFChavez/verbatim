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
bin/rails server
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
