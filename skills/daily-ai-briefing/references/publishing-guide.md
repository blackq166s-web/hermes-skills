# Publishing daily-ai-briefing to Hermes Skill Community

Step-by-step guide to make this skill installable by anyone via `hermes skills install`.

## Prerequisites

- Git configured: `git config --global user.name` and `user.email`
- GitHub CLI authenticated: `gh auth login`
- A GitHub repo (public!) for skills

## Step 1: Create or clone the skills repo

```bash
# Create new
gh repo create hermes-skills --public --description "My Hermes skills"

# Or clone existing
gh repo clone owner/hermes-skills
cd hermes-skills
```

## Step 2: Add the skill to the repo

```bash
cp -r ~/.hermes/skills/productivity/daily-ai-briefing hermes-skills/
cd hermes-skills
git add -A
git commit -m "feat: add daily-ai-briefing skill"
git push
```

## Step 3: Publish to Hermes community

```bash
hermes skills publish ~/.hermes/skills/productivity/daily-ai-briefing \
  --to github \
  --repo owner/hermes-skills
```

## Step 4: Merge the auto-created PR

```bash
cd hermes-skills && git pull
gh pr merge 1 --merge --delete-branch
```

The PR merge will move `SKILL.md` into `skills/daily-ai-briefing/SKILL.md` — this is the required community structure.

## Step 5: Ensure repo is public

```bash
gh repo view owner/hermes-skills --json visibility
# If PRIVATE:
gh repo edit owner/hermes-skills --visibility public --accept-visibility-change-consequences
```

## Step 6: Verify install

```bash
hermes skills install https://raw.githubusercontent.com/owner/hermes-skills/main/skills/daily-ai-briefing/SKILL.md
```

## Common issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `BLOCKED: dangerous verdict` on publish | SKILL.md contains `~/.hermes/.env` or credential patterns | Replace with generic env instructions |
| `Could not fetch` on install | Repo is private | Make repo public |
| Empty search results | Tap not added or indexing delay | Use direct URL install |
| `No skill named` on search | Skill not in `skills/<name>/SKILL.md` format | Verify PR merged, file at correct path |
