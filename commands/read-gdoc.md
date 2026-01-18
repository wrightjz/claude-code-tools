# Read Google Doc

Fetch content from one or more Google Docs URLs and return as Markdown for context.

## Usage

This skill reads Google Docs content and returns it as Markdown. Pass one or more Google Doc URLs as arguments.

## Arguments

$ARGUMENTS - One or more Google Doc URLs or document IDs (space-separated)

## Instructions

Run the following command to fetch the document content:

```bash
~/.config/google-docs/venv/bin/python3 ~/.config/google-docs/read_gdoc.py $ARGUMENTS
```

The output will be Markdown-formatted content from the specified Google Doc(s), including:
- Document title as H1
- Tab titles as H2 (if the document uses tabs)
- Headings preserved with proper Markdown levels
- Bold and italic formatting
- Links converted to Markdown format
- Tables converted to Markdown tables

If multiple URLs are provided, each document's content will be separated by a horizontal rule (`---`).

## Examples

Single document:
```
/read-gdoc https://docs.google.com/document/d/1abc123/edit
```

Multiple documents:
```
/read-gdoc https://docs.google.com/document/d/1abc123/edit https://docs.google.com/document/d/2def456/edit
```

Using document IDs directly:
```
/read-gdoc 1abc123 2def456
```

## Requirements

- Google Cloud credentials configured at `~/.config/google-docs/credentials.json`
- Python packages: `google-api-python-client`, `google-auth-oauthlib`

## Notes

- First run may require browser authentication to generate token
- Token is cached at `~/.config/google-docs/token.json` for subsequent use
- Read-only access is used (documents are never modified)
