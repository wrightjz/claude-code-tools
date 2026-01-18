# Ralph Usage Guide

A practical step-by-step guide to using Ralph for autonomous feature development.

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] **jq** installed: `brew install jq` (macOS) or `apt-get install jq` (Linux)
- [ ] **Git** repository initialized in your project
- [ ] One of the following CLI tools:
  - **Cursor CLI**: `curl -sS https://cursor.com/install | bash`
  - **Claude Code**: [Installation guide](https://docs.anthropic.com/en/docs/claude-code)

## Step 1: Set Up Ralph in Your Project

### 1a: Copy Core Ralph Files

```bash
# Create a ralph directory in your project
mkdir -p scripts/ralph
cd scripts/ralph

# Download the required files (or copy from this repo)
curl -O https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/ralph/ralph-unified.sh
curl -O https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/ralph/prompt-unified.md
curl -O https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/ralph/prd.json.example
curl -O https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/ralph/.env.example

# Make the script executable
chmod +x ralph-unified.sh
```

### 1b: Set Up CLI-Specific Configuration

Choose your CLI tool and copy the appropriate configuration files:

#### For Claude Code Users

```bash
# From your PROJECT ROOT (not the ralph directory)
cd /path/to/your/project

# Create Claude Code directories
mkdir -p .claude/commands

# Copy Claude Code configuration
curl -o .claude/settings.json https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/ralph/.claude/settings.json

# Copy the PRD generator commands (for /prd and /ralph slash commands)
curl -o .claude/commands/prd.md https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/ralph/.claude/commands/prd.md
curl -o .claude/commands/ralph.md https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/ralph/.claude/commands/ralph.md

# Optional: Copy hooks for session management
mkdir -p .claude/hooks
curl -o .claude/hooks/session-init.sh https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/ralph/.claude/hooks/session-init.sh
chmod +x .claude/hooks/session-init.sh
```

After setup, you can use `/prd` and `/ralph` commands in Claude Code.

#### For Cursor Users

```bash
# From your PROJECT ROOT (not the ralph directory)
cd /path/to/your/project

# Create Cursor directories
mkdir -p .cursor

# Copy Cursor CLI configuration
curl -o .cursor/cli.json https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/ralph/.cursor/cli.json

# Copy Cursor rules (behavior customization)
curl -o .cursor/rules https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/ralph/.cursor/rules
```

For Cursor, the PRD skills are available as prompts - just describe what you want:
- "Create a PRD for [feature]"
- "Convert this PRD to ralph format"

### 1c: Directory Structure After Setup

Your project should look like this:

```
your-project/
├── .claude/                    # Claude Code config (if using Claude)
│   ├── commands/
│   │   ├── prd.md             # /prd command
│   │   └── ralph.md           # /ralph command
│   ├── hooks/
│   │   └── session-init.sh    # Optional session hook
│   └── settings.json
├── .cursor/                    # Cursor config (if using Cursor)
│   ├── cli.json               # CLI permissions
│   └── rules                  # Behavior rules
├── scripts/ralph/              # Ralph execution directory
│   ├── ralph-unified.sh       # Main loop script
│   ├── prompt-unified.md      # Agent instructions
│   ├── prd.json.example       # PRD template
│   ├── .env.example           # Environment template
│   ├── .env.local             # Your API keys (create this)
│   ├── prd.json               # Your PRD (create this)
│   └── progress.txt           # Generated during runs
├── tasks/                      # PRD markdown files (created by /prd)
│   └── prd-feature-name.md
└── ... your project files
```

## Step 2: Configure Authentication

```bash
# Copy the example env file
cp .env.example .env.local

# Edit .env.local with your credentials
```

**For Cursor CLI users:**
```bash
# Add your Cursor API key (get from https://cursor.com/settings)
CURSOR_API_KEY=your_key_here
RALPH_CLI=cursor
```

**For Claude Code users:**
```bash
# Authenticate once (no API key needed in .env.local)
claude auth login

# Optionally set as default in .env.local
RALPH_CLI=claude
```

## Step 3: Create Your PRD (Product Requirements Document)

There are three ways to create your `prd.json` file:

### Option A: Use the PRD Generator Skills (Recommended)

The `skills/` folder contains two helper skills that make PRD creation easier:

#### Step 3a: Generate a detailed PRD with `/prd` skill

In Cursor or Claude Code, describe your feature and the skill will:
1. Ask 3-5 clarifying questions (with lettered options for quick answers)
2. Generate a detailed PRD markdown file
3. Save it to `tasks/prd-[feature-name].md`

**Example conversation:**
```
You: Create a PRD for adding dark mode to our app

AI: I'll help you create a PRD. First, a few questions:

1. What is the primary goal?
   A. Improve accessibility
   B. User preference/comfort
   C. Brand consistency
   D. Other

2. What components need dark mode support?
   A. Just the main app shell
   B. All components including forms
   C. Everything including third-party widgets

3. How should the preference be stored?
   A. localStorage only
   B. User account settings (database)
   C. Both with account taking priority

You: 1B, 2B, 3C

AI: [Generates detailed PRD and saves to tasks/prd-dark-mode.md]
```

#### Step 3b: Convert PRD to prd.json with `/ralph` skill

Once you have a PRD markdown file, convert it to Ralph's JSON format:

```
You: Convert tasks/prd-dark-mode.md to ralph format

AI: [Reads the PRD, splits into right-sized stories, orders by dependency,
     and generates prd.json]
```

The `/ralph` skill automatically:
- Splits large features into small, completable stories
- Orders stories by dependency (schema → backend → UI)
- Adds "Typecheck passes" to all acceptance criteria
- Adds "Verify in browser" for UI stories
- Sets proper priority order

### Option B: Create prd.json Manually

If you prefer to write the JSON directly, here's a real-world example:

```json
{
  "project": "user-settings-page",
  "branchName": "ralph/user-settings",
  "description": "Add a user settings page where users can manage their preferences",
  "userStories": [
    {
      "id": "US-001",
      "title": "Create settings page route and layout",
      "description": "As a user, I want to navigate to a settings page so I can manage my preferences",
      "acceptanceCriteria": [
        "New route /settings exists and is accessible",
        "Settings page has a consistent layout with the rest of the app",
        "Navigation menu includes a link to Settings"
      ],
      "priority": 1,
      "passes": false,
      "notes": "Use existing layout components"
    },
    {
      "id": "US-002",
      "title": "Add profile section to settings",
      "description": "As a user, I want to view and edit my profile information",
      "acceptanceCriteria": [
        "Profile section displays current user name and email",
        "User can edit their display name",
        "Changes are saved to the database",
        "Success/error feedback is shown"
      ],
      "priority": 2,
      "passes": false,
      "notes": "Use existing user API endpoints"
    },
    {
      "id": "US-003",
      "title": "Add notification preferences",
      "description": "As a user, I want to control my notification settings",
      "acceptanceCriteria": [
        "Toggle for email notifications",
        "Toggle for push notifications",
        "Preferences persist across sessions"
      ],
      "priority": 3,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### PRD Best Practices

**Right-sized stories (can complete in one context window):**
- Add a single component to a page
- Create one API endpoint
- Add a database migration
- Implement one form with validation

**Too large (split these up):**
- "Build the entire dashboard" → Split into individual widgets
- "Add authentication" → Split into login, signup, password reset, etc.
- "Refactor the API" → Split into specific endpoints or concerns

### Option C: Copy from Example

Start with `prd.json.example` and modify it for your feature:

```bash
cp prd.json.example prd.json
# Edit prd.json with your stories
```

## Step 4: Run Ralph

```bash
# From your ralph directory
./ralph-unified.sh --cursor    # Use Cursor CLI
# OR
./ralph-unified.sh --claude    # Use Claude Code

# With custom iteration limit
./ralph-unified.sh --cursor 20
```

### What Happens During Each Iteration

1. **Context Loading**: Ralph reads `prd.json` and `progress.txt`
2. **Branch Setup**: Creates/checks out the feature branch
3. **Story Selection**: Picks highest priority incomplete story
4. **Implementation**: Writes code to satisfy acceptance criteria
5. **Quality Checks**: Runs typecheck, lint, tests
6. **Commit**: If checks pass, commits with `feat: [ID] - [Title]`
7. **Update State**: Marks story as `passes: true` in `prd.json`
8. **Log Progress**: Appends learnings to `progress.txt`
9. **Repeat or Complete**: Continues until all stories pass

## Step 5: Monitor Progress

While Ralph is running, you can monitor progress:

```bash
# Watch which stories are complete
watch -n 5 'jq ".userStories[] | {id, title, passes}" prd.json'

# Follow the progress log
tail -f progress.txt

# Check git commits
git log --oneline -10
```

## Step 6: Review and Merge

After Ralph completes:

```bash
# Review all changes
git diff main...HEAD

# Check the commit history
git log --oneline main..HEAD

# If satisfied, merge to main
git checkout main
git merge ralph/your-feature-branch
```

## Troubleshooting

### Ralph keeps failing on the same story

The story might be too large. Split it into smaller pieces:

```json
// Before: Too large
{
  "id": "US-001",
  "title": "Add complete user authentication",
  ...
}

// After: Right-sized
{
  "id": "US-001",
  "title": "Add login form component",
  ...
},
{
  "id": "US-002",
  "title": "Add login API endpoint",
  ...
},
{
  "id": "US-003",
  "title": "Add session management",
  ...
}
```

### Tests keep failing

Check `progress.txt` for patterns. Add project-specific test commands to `prompt-unified.md`:

```markdown
## Quality Requirements

Before committing, run these checks:
- `npm run typecheck`
- `npm run lint`
- `npm run test -- --passWithNoTests`
```

### Ralph isn't following project conventions

Add patterns to your project's `AGENTS.md` file:

```markdown
# AGENTS.md (in your project root)

## Code Conventions
- Use TypeScript strict mode
- All components go in src/components/
- Use Tailwind for styling
- API routes follow REST conventions
```

### API key issues

```bash
# For Cursor: Verify your key works
curl -H "Authorization: Bearer $CURSOR_API_KEY" https://api.cursor.com/health

# For Claude Code: Re-authenticate
claude auth logout
claude auth login
```

## Example: Complete Workflow

Here's a complete example from start to finish:

```bash
# 1. Navigate to your project
cd ~/projects/my-app

# 2. Set up Ralph
mkdir -p scripts/ralph && cd scripts/ralph
# (copy files as shown in Step 1)

# 3. Configure auth
cp .env.example .env.local
echo "CURSOR_API_KEY=key_abc123" >> .env.local
echo "RALPH_CLI=cursor" >> .env.local

# 4. Create your PRD
cat > prd.json << 'EOF'
{
  "project": "dark-mode",
  "branchName": "ralph/dark-mode",
  "description": "Add dark mode support to the application",
  "userStories": [
    {
      "id": "DM-001",
      "title": "Add theme context provider",
      "description": "Create a React context for theme management",
      "acceptanceCriteria": [
        "ThemeContext provides current theme (light/dark)",
        "ThemeProvider wraps the app in _app.tsx",
        "useTheme hook available for components"
      ],
      "priority": 1,
      "passes": false,
      "notes": "Store preference in localStorage"
    },
    {
      "id": "DM-002",
      "title": "Add theme toggle button",
      "description": "Users can switch between light and dark mode",
      "acceptanceCriteria": [
        "Toggle button in header/nav",
        "Clicking toggles between light/dark",
        "Icon changes based on current theme"
      ],
      "priority": 2,
      "passes": false,
      "notes": "Use existing Button component"
    }
  ]
}
EOF

# 5. Run Ralph
./ralph-unified.sh --cursor

# 6. After completion, review and merge
git checkout main
git merge ralph/dark-mode
git push origin main
```

## Tips for Success

1. **Start small**: Begin with a 2-3 story PRD to learn the workflow
2. **Clear acceptance criteria**: Be specific and testable
3. **Order by dependencies**: Put foundation stories first (priority 1)
4. **Check progress.txt**: Learn what Ralph discovered about your codebase
5. **Update AGENTS.md**: Help future iterations by documenting patterns
6. **Review commits**: Each story = one commit, easy to review/revert

## Using the PRD Skills

The PRD skills help you create well-structured PRDs. Here's how to use them with each CLI:

### How to Invoke Skills

| CLI | How to use /prd | How to use /ralph |
|-----|-----------------|-------------------|
| **Claude Code** | Type `/prd` then describe your feature | Type `/ralph` then point to your PRD file |
| **Cursor** | Say "Create a PRD for [feature]" | Say "Convert this PRD to ralph format" |

> **Note:** For Claude Code, you must have copied the command files to `.claude/commands/` as shown in Step 1b.

### `/prd` - PRD Generator

**Triggers:** "create a prd", "write prd for", "plan this feature", "requirements for"

**What it does:**
1. Takes your feature description
2. Asks 3-5 clarifying questions with lettered options (respond with "1A, 2C, 3B")
3. Generates a detailed PRD markdown file
4. Saves to `tasks/prd-[feature-name].md`

**Example:**
```
You: Create a PRD for user notifications

AI: [Asks questions about scope, priority levels, delivery channels, etc.]

You: 1B, 2A, 3C, 4B

AI: [Generates comprehensive PRD with user stories, requirements, and saves to file]
```

### `/ralph` - PRD to JSON Converter

**Triggers:** "convert this prd", "turn this into ralph format", "create prd.json from this"

**What it does:**
1. Reads an existing PRD markdown file
2. Splits large features into small, right-sized stories
3. Orders by dependency (schema → backend → UI)
4. Adds required acceptance criteria ("Typecheck passes", "Verify in browser")
5. Generates `prd.json` ready for Ralph execution

**Example:**
```
You: Convert tasks/prd-notifications.md to ralph format

AI: [Analyzes PRD, creates properly ordered stories, generates prd.json]
```

### Why Use Skills vs Manual?

| Approach | Best For |
|----------|----------|
| **Skills** | Complex features, ensuring nothing is missed, proper story sizing |
| **Manual** | Simple features, quick iterations, when you know exactly what you need |

The skills ensure:
- Stories are right-sized (completable in one context window)
- Dependencies are properly ordered
- Acceptance criteria are verifiable (not vague)
- UI stories include browser verification

## Getting Help

- Check the [README.md](./README.md) for configuration options
- Review [prd.json.example](./prd.json.example) for PRD format
- See [prompt-unified.md](./prompt-unified.md) for agent instructions
- See [skills/prd/SKILL.md](./skills/prd/SKILL.md) for PRD generator details
- See [skills/ralph/SKILL.md](./skills/ralph/SKILL.md) for converter details
