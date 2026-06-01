# DevMatrix MCP — Workshop connector for Claude Code

Drive the **DevMatrix Workshop** (read & write specs and platform wikis) from
**your own Claude Code** — your Claude subscription, used interactively, 100%
within Anthropic's Terms of Service. DevMatrix exposes the Workshop as an
**MCP server**; the LLM runs in *your* client, never in DevMatrix.

You authenticate with a **Workshop API key** (`dm_live_…`) that you create in
the Workshop UI. The key is **platform-scoped and Workshop-only** by design:
it can only touch the platform(s) you grant it, and only Workshop features —
nothing else (no billing, no members, no compiles).

```
Your Claude Code ──(MCP over HTTPS, Bearer dm_live_…)──▶ mcp.devmatrix.dev
                                                              │  forwards the key
                                                              ▼
                                              DevMatrix backend (validates +
                                              re-enforces tenant+platform scope)
```

## 1. Get a Workshop key

In the DevMatrix Workshop: **Settings → API Keys → New Workshop key**.
- Pick the **platform(s)** the key may access (one or many).
- Choose **read** or **read + write**.
- Copy the key (`dm_live_…`) **once** — it is shown only at creation.

## 2. Connect Claude Code

**One-liner:**

```bash
./install.sh dm_live_your_key_here
```

**Or manually** (Claude Code's native HTTP MCP transport):

```bash
claude mcp add --transport http dmx https://mcp.devmatrix.dev/mcp \
  --header "Authorization: Bearer dm_live_your_key_here"
```

**Or per-project** via `.mcp.json` (see [`.mcp.json.example`](./.mcp.json.example)):
copy it into your project root and replace the placeholder key.

Verify:

```bash
claude mcp list        # dmx should be listed
```

## 3. Use it

Once connected, ask Claude Code things like:

- *"List my DevMatrix platforms and their specs."*
- *"Show me the `.dmx` source of the identity service spec."*
- *"Validate this spec before I save it."* → `validate_spec` (deterministic,
  compiler grammar — no guessing)
- *"Save this updated spec."* → versioned, exactly like saving in the Workshop
- *"Read the platform wiki for auth, then add a new `runbook.md`."*

### Tools

| Tool | What it does |
|---|---|
| `list_platforms` | Platforms this key is scoped to |
| `list_specs` | Specs (platform + services) of a platform |
| `get_spec` | A spec's native **`.dmx`** source |
| `list_wiki` | A platform's wiki **`.md`** documents |
| `get_wiki` | A wiki document's original **`.md`** content |
| `validate_spec` | Validate `.dmx` against the live compiler grammar |
| `save_spec` | Save + version a spec (immutable version history) |
| `upload_wiki` | Upload/replace a platform wiki `.md` (versioned + reindexed) |

> Compiling is **not** an MCP tool — by design, a Workshop key can never trigger
> a compile. Authoring stays in your hands; you compile from the Workshop UI.

## Security

- **Your key, your machine.** The key lives only in your Claude Code config
  (server-side on your machine) and travels only as an `Authorization` header
  over HTTPS. It is never placed in a browser and never exposed to page JS.
- **Ultra-scoped.** A leaked key reaches only its granted platform(s) and only
  Workshop read/(write) — never destructive or account-wide actions.
- **Backend is the single authority.** The gateway holds no business logic; the
  backend validates the key and re-enforces the (tenant + platform) scope on
  **every** call.
- **Rotate** keys from the Workshop UI; revoking is immediate.

## Endpoints

| Environment | MCP URL |
|---|---|
| Production | `https://mcp.devmatrix.dev/mcp` |
| Dev (QA) | `https://mcp-dev.devmatrix.dev/mcp` |
| Local stack | `http://localhost:8090/mcp` |

```bash
./install.sh dm_live_your_key_here https://mcp-dev.devmatrix.dev/mcp   # pick env
```

## Troubleshooting

- **`claude: command not found`** — install Claude Code first
  (https://claude.com/claude-code), then re-run.
- **401 on first tool call** — the key is invalid, revoked, or expired. Create
  a fresh Workshop key.
- **404 / "not found" on a platform you expected** — that platform is not in
  the key's scope. Add it to the key's scope in the Workshop UI (or create a
  new key) and reconnect.
- **Remove the connection:** `claude mcp remove dmx`.

---

The MCP **server** (gateway) is operated by DevMatrix as part of its
infrastructure; this repository is the **client-side connector** only.
