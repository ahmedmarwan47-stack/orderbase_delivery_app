---
name: figma-task-extractor
description: Auto-extract screens from a Figma file and generate individual feature task files.
disable-model-invocation: true
---

# Skill: Figma Task Extractor — Auto-Generate Feature Tasks from Figma File

## Purpose

Automate the extraction of ALL screens from a Figma file and generate individual
task prompt files (based on `feature_prompt.md`) for each screen. This eliminates
manual task creation and ensures every screen is covered.

---

## When to Use

- User sends a **full Figma file URL** and wants to extract all screens as tasks
- User says: "extract tasks", "generate tasks from Figma", "جهزلي التاسكات"
- Starting a new project/feature set with multiple screens

---

## Workflow — 3 Phases

### PHASE 1: Extract Screens from Figma

#### Step 1.1 — Parse the Figma URL

Extract `fileKey` and optionally `nodeId` from the URL:

```
https://figma.com/design/:fileKey/:fileName?node-id=:nodeId
https://figma.com/design/:fileKey/branch/:branchKey/:fileName → use branchKey as fileKey
```

#### Step 1.2 — Get File Structure via Figma MCP

Use `get_metadata` from the **user-Figma** MCP server to fetch page structure:

```
Tool: get_metadata
Arguments:
  fileKey: "<extracted_fileKey>"
  nodeId: "0:1"  (page 1 — default page)
  clientLanguages: "dart"
  clientFrameworks: "flutter"
```

This returns XML with ALL top-level nodes (frames = screens) on the page.

#### Step 1.3 — If file has multiple pages

Call `get_metadata` with just the fileKey (no nodeId or nodeId="") to get all pages first,
then iterate each page to get its frames.

#### Step 1.4 — Parse the Response

From the metadata XML/JSON, extract for each top-level FRAME node:
- **name**: The screen/frame name (e.g., "Login", "Home", "Product Details")
- **nodeId**: The node ID (e.g., "1:2", "5:123")
- **type**: Should be "FRAME" (skip COMPONENT, INSTANCE, GROUP unless they're screens)

#### Step 1.5 — Build Screen List

For each screen, compute:
- **feature_name**: Convert screen name to snake_case (e.g., "Product Details" → "product_details")
- **figma_url**: Construct full URL: `https://figma.com/design/{fileKey}/{fileName}?node-id={nodeId with : replaced by -}`
- **screen_name**: Original Figma name (for display)
- **execution_order**: Based on position in Figma (top-to-bottom, left-to-right) or prototype flow

---

### PHASE 2: Generate Task Files

#### Step 2.1 — Read Template

Read `.cursor/prompt/feature_prompt.md` as the base template.

#### Step 2.2 — Generate Per-Screen Task File

For each screen, create `.cursor/prompt/tasks/{feature_name}.md`:
- Replace `[FEATURE_NAME]` with the feature_name
- Replace `[FIGMA_URL]` with the constructed Figma URL (with node-id)
- Replace `[POSTMAN_URL]` with placeholder: `TODO: Add Postman URL`

#### Step 2.3 — Generate Master Schedule

Create `.cursor/prompt/tasks/_schedule.md` with:

```markdown
# Task Schedule — {Project Name}

Generated from: {Figma URL}
Generated at: {timestamp}

## Screens ({count} total)

| # | Screen Name | Feature Name | Figma Node | Postman URLs | Status |
|---|---|---|---|---|---|
| 1 | Login | login | 1:2 | TODO | ⬜ pending |
| 2 | Register | register | 1:5 | TODO | ⬜ pending |
| 3 | Home | home | 1:8 | TODO | ⬜ pending |
...

## Execution Order

(Based on Figma prototype flow — adjust as needed)

1. ⬜ login → .cursor/prompt/tasks/login.md
2. ⬜ register → .cursor/prompt/tasks/register.md
3. ⬜ home → .cursor/prompt/tasks/home.md
...

## Navigation Map

(Extracted from Figma prototype connections)

- login → [register, home]
- register → [login, home]
- home → [profile, product_details, cart]
...
```

#### Step 2.4 — Present for Review

Show the user:
1. Total number of screens found
2. List of all screens with their names and Figma URLs
3. Ask them to:
   - Confirm the list is correct
   - Add Postman URLs for screens that need API services
   - Adjust execution order if needed
   - Remove screens that shouldn't be implemented (e.g., design-only, deprecated)

---

### PHASE 3: Execute Tasks Sequentially

#### Step 3.1 — Pick Next Task

Read `_schedule.md`, find the first task with status `⬜ pending`.

#### Step 3.2 — Read Task Prompt

Read the task's `.md` file from `.cursor/prompt/tasks/`.

#### Step 3.3 — Execute Feature Development

Follow the `feature_prompt.md` workflow:
1. Read rules
2. Audit existing code
3. Read Figma (using the node URL in the task)
4. Read API (if Postman URL provided)
5. Plan → get approval
6. Implement
7. Test
8. Verify

#### Step 3.4 — Update Schedule

After completing a task, update `_schedule.md`:
- Change status from `⬜ pending` to `✅ done`
- Add any notes about navigation connections made

#### Step 3.5 — Link Navigation

When implementing each screen, ensure navigation connections to already-built screens:
- Use `Modular.to.pushNamed('/target')` for screens that are done
- Use placeholder comments for screens not yet built:
  ```dart
  // TODO: Navigate to ProductDetailsScreen (task pending)
  Modular.to.pushNamed('/target') // Will be replaced when product_details task is done
  ```
- When building a later screen, go back and update navigation in earlier screens

#### Step 3.6 — Repeat

Continue to Step 3.1 until all tasks are `✅ done`.

---

## Screen Name → Feature Name Conversion

| Figma Name | Feature Name | Notes |
|---|---|---|
| `Login` | `login` | Simple lowercase |
| `Product Details` | `product_details` | Spaces → underscores |
| `Home - Tab 1` | `home_tab_1` | Hyphens → underscores |
| `My Profile (Edit)` | `my_profile_edit` | Remove parentheses |
| `Cart / Checkout` | `cart_checkout` | Slashes → underscores |
| `الرئيسية` | `home` | Arabic → English equivalent (ask user) |

Rules:
1. Convert to lowercase snake_case
2. Remove special characters: `()`, `/`, `-`, `#`
3. Replace spaces with underscores
4. Arabic names → ask user for English equivalent
5. Remove duplicate underscores
6. Trim leading/trailing underscores

---

## Filtering Rules — Which Frames to Include

**Include (these are screens):**
- Top-level FRAME nodes on the page
- Frames with names that look like screen names (Login, Home, Details, etc.)
- Frames that are part of the prototype flow

**Exclude (NOT screens):**
- COMPONENT and COMPONENT_SET nodes (these are design components)
- Frames named "Components", "Icons", "Styles", "Design System"
- Frames smaller than 300x500 px (likely components, not screens)
- Duplicate frames (same name with different states — group them as one task)
- Frames with names starting with "." or "_" (Figma convention for hidden/private)

**Group as one task (multiple states of same screen):**
- "Login" + "Login - Error" + "Login - Loading" → single task "login"
- "Home" + "Home Empty" + "Home Skeleton" → single task "home"
- "Product Details" + "Product Details - Modal" → single task "product_details"

---

## Script Alternative

For automated extraction outside of Cursor, use:
```bash
python scripts/generate_figma_tasks.py "<FIGMA_URL>"
```

Requires `FIGMA_ACCESS_TOKEN` environment variable.
See `scripts/generate_figma_tasks.py` for details.

---

## Quick Reference — MCP Tools Used

| Tool | Server | Purpose |
|---|---|---|
| `get_metadata` | user-Figma | Get file/page structure (node IDs, names, types) |
| `get_design_context` | user-Figma | Get detailed design for a specific screen node |
| `get_screenshot` | user-Figma | Get visual screenshot of a node |
