# Chatwoot Development Guidelines

## Build / Test / Lint

- **Setup**: `bundle install && pnpm install`
- **Run Dev**: `pnpm dev` or `overmind start -f ./Procfile.dev`
- **Seed Local Test Data**: `bundle exec rails db:seed` (quickly populates minimal data for standard feature verification)
- **Seed Search Test Data**: `bundle exec rails search:setup_test_data` (bulk fixture generation for search/performance/manual load scenarios)
- **Seed Account Sample Data (richer test data)**: `Seeders::AccountSeeder` is available as an internal utility and is exposed through Super Admin `Accounts#seed`, but can be used directly in dev workflows too:
  - UI path: Super Admin → Accounts → Seed (enqueues `Internal::SeedAccountJob`).
  - CLI path: `bundle exec rails runner "Internal::SeedAccountJob.perform_now(Account.find(<id>))"` (or call `Seeders::AccountSeeder.new(account: Account.find(<id>)).perform!` directly).
- **Lint JS/Vue**: `pnpm eslint` / `pnpm eslint:fix`
- **Lint Ruby**: `bundle exec rubocop -a`
- **Test JS**: `pnpm test` or `pnpm test:watch`
- **Test Ruby**: `bundle exec rspec spec/path/to/file_spec.rb`
- **Single Test**: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- **Run Project**: `overmind start -f Procfile.dev`
- **Ruby Version**: Manage Ruby via `rbenv` and install the version listed in `.ruby-version` (e.g., `rbenv install $(cat .ruby-version)`)
- **rbenv setup**: Before running any `bundle` or `rspec` commands, init rbenv in your shell (`eval "$(rbenv init -)"`) so the correct Ruby/Bundler versions are used
- Always prefer `bundle exec` for Ruby CLI tasks (rspec, rake, rubocop, etc.)

## Code Style

- **Ruby**: Follow RuboCop rules (150 character max line length)
- **Vue/JS**: Use ESLint (Airbnb base + Vue 3 recommended)
- **Vue Components**: Use PascalCase
- **Events**: Use camelCase
- **I18n**: No bare strings in templates; use i18n
- **Error Handling**: Use custom exceptions (`lib/custom_exceptions/`)
- **Models**: Validate presence/uniqueness, add proper indexes
- **Type Safety**: Use PropTypes in Vue, strong params in Rails
- **Naming**: Use clear, descriptive names with consistent casing
- **Vue API**: Always use Composition API with `<script setup>` at the top

## Styling

- **Tailwind Only**:  
  - Do not write custom CSS  
  - Do not use scoped CSS  
  - Do not use inline styles  
  - Always use Tailwind utility classes  
- **Colors**: Refer to `tailwind.config.js` for color definitions

## General Guidelines

- Prefer the smallest production-ready change that solves the current problem.
- Build for the expected production path first. Do not add speculative guards, fallbacks, retries, or edge-case handling unless the caller can actually hit that case or production has proven it necessary.
- When an impossible or misconfigured state would indicate a setup/deployment bug, let it fail loudly instead of silently skipping behavior.
- For locked/internal configs that must exist in production, prefer direct reads (`find`, `find_by!`, required hash keys) over silent fallbacks.
- Do not add validation or response checks unless the code uses the result or the check changes behavior meaningfully.
- Prefer existing repo dependencies/client libraries over hand-rolled protocol code for auth, signing, parsing, or API plumbing.
- Avoid one-use private helpers unless they hide real complexity or make the main flow meaningfully easier to read.
- Prefer minimal, readable code over elaborate abstractions; clarity beats cleverness
- Break down complex tasks into small, testable units
- Iterate after confirmation
- Avoid writing specs unless explicitly asked
- In specs, avoid custom helper methods for setup/data. Prefer `let` values and direct per-example setup; only add a helper when it removes meaningful repeated complexity.
- Remove dead/unreachable/unused code
- Don’t write multiple versions or backups for the same logic — pick the best approach and implement it
- Prefer `with_modified_env` (from spec helpers) over stubbing `ENV` directly in specs
- Specs in parallel/reloading environments: prefer comparing `error.class.name` over constant class equality when asserting raised errors

## Codex Worktree Workflow

- Use a separate git worktree + branch per task to keep changes isolated.
- Keep Codex-specific local setup under `.codex/` and use `Procfile.worktree` for worktree process orchestration.
- The setup workflow in `.codex/environments/environment.toml` should dynamically generate per-worktree DB/port values (Rails, Vite, Redis DB index) to avoid collisions.
- Start each worktree with its own Overmind socket/title so multiple instances can run at the same time.

## Commit Messages

- Prefer Conventional Commits: `type(scope): subject` (scope optional)
- Example: `feat(auth): add user authentication`
- Don't reference Claude in commit messages

## PR Description Format

- Start with a short, user-facing paragraph describing the product change.
- Add a `Closes` section with relevant issue links (GitHub, Linear, etc.).
- For feature PRs, add `How to test` from a product/UX standpoint.
- For bugfix PRs, use `How to reproduce` when helpful.
- Optionally add a `What changed` section for implementation highlights.
- Do not add a `How this was tested` section listing specs/commands.

## Project-Specific

- **Translations**:
  - Only update `en.yml` and `en.json`
  - Other languages are handled by the community
  - Backend i18n → `en.yml`, Frontend i18n → `en.json`
- **Frontend**:
  - Use `components-next/` for message bubbles (the rest is being deprecated)

## Ruby Best Practices

- Use compact `module/class` definitions; avoid nested styles

## Enterprise Edition Notes

- Chatwoot has an Enterprise overlay under `enterprise/` that extends/overrides OSS code.
- When you add or modify core functionality, always check for corresponding files in `enterprise/` and keep behavior compatible.
- Follow the Enterprise development practices documented here:
  - https://chatwoot.help/hc/handbook/articles/developing-enterprise-edition-features-38

Practical checklist for any change impacting core logic or public APIs
- Search for related files in both trees before editing (e.g., `rg -n "FooService|ControllerName|ModelName" app enterprise`).
- If adding new endpoints, services, or models, consider whether Enterprise needs:
  - An override (e.g., `enterprise/app/...`), or
  - An extension point (e.g., `prepend_mod_with`, hooks, configuration) to avoid hard forks.
- Avoid hardcoding instance- or plan-specific behavior in OSS; prefer configuration, feature flags, or extension points consumed by Enterprise.
- Keep request/response contracts stable across OSS and Enterprise; update both sets of routes/controllers when introducing new APIs.
- When renaming/moving shared code, mirror the change in `enterprise/` to prevent drift.
- Tests: Add Enterprise-specific specs under `spec/enterprise`, mirroring OSS spec layout where applicable.
- When modifying existing OSS features for Enterprise-only behavior, add an Enterprise module (via `prepend_mod_with`/`include_mod_with`) instead of editing OSS files directly—especially for policies, controllers, and services. For Enterprise-exclusive features, place code directly under `enterprise/`.

## Branding / White-labeling note

- For user-facing strings that currently contain "Chatwoot" but should adapt to branded/self-hosted installs, prefer applying `replaceInstallationName` from `shared/composables/useBranding` in the UI layer (for example tooltip and suggestion labels) instead of adding hardcoded brand-specific copy.

## Codebase Architecture & Features

This section provides a detailed overview of Chatwoot's software architecture, directory structure, data models, and features.

### 1. Technology Stack
* **Backend**: Ruby on Rails (MVC architecture, ActiveJob/Sidekiq for background workers, ActionCable for WebSockets real-time sync, ActionMailbox for incoming email ingest, ActiveStorage for media/attachment storage, Devise Token Auth for API authentication).
* **Frontend**: Vue.js 3 (Composition API using `<script setup>`), TailwindCSS for modern design, Pinia / Vuex for client state, Vite for frontend bundling/compilation.
* **Databases**: PostgreSQL (relational database), Redis (used for caching, background job queues via Sidekiq, online status tracking, ActionCable subscription pub/sub).
* **Search / Analytics**: pg_search (PostgreSQL full-text search) and reporting tables (`reporting_events`, `reporting_events_rollup`).

---

### 2. Codebase Directory Structure
* **`app/`**: Core Rails application files.
  * **`app/controllers/`**: API endpoints (scoped by `api/v1/accounts/`, `api/v1/widget/`, etc.) and devise controller overrides.
  * **`app/models/`**: Active Record models representing system entities (e.g., `user.rb`, `account.rb`, `conversation.rb`, `message.rb`, `inbox.rb`).
  * **`app/services/`**: Business logic workflows separated into service layers (e.g., assignment services, message window handlers, search services, CSAT triggers).
  * **`app/builders/`**: Objects built to construct complex database records safely (e.g. creating a message with attachments).
  * **`app/jobs/`**: Background worker jobs executing tasks asynchronously (e.g., outbound webhooks, email delivery, translation, notifications).
  * **`app/javascript/`**: The entire frontend codebase. Contains:
    * `dashboard/`: The principal agent dashboard interface.
    * `widget/`: The client-facing live chat widget.
    * `shared/`: Shared Vue components, Pinia stores, composables, and i18n JSON translation configs.
* **`enterprise/`**: Enterprise Edition overlay containing models, controllers, services, and listeners that extend or override OSS functionality when EE is licensed.
* **`lib/`**: Custom integrations, utilities, and libraries (e.g., `lib/llm` for AI interactions, integrations with slack, twilio, linear, dyte, etc.).

---

### 3. Core Domain Entities & Data Model
* **Account**: The primary multi-tenant unit. All resources (inboxes, conversations, users) belong to an Account.
* **User**: Represents team members (agents, administrators, super admins) linked to Accounts via `AccountUser`.
* **Contact**: Represents the end-customers or website visitors initiating a conversation.
* **Inbox**: Communication channels. Supported inboxes (`app/models/channel/`) include:
  * `WebWidget`: Localized web live-chat widget.
  * `Email`: Email mailbox parser (ActionMailbox).
  * `Whatsapp`: Cloud API or Twilio WhatsApp integration.
  * `Sms` / `TwilioSms`: Outbound and inbound SMS messaging.
  * `Telegram`, `Line`, `Instagram`, `FacebookPage`, `Tiktok`, `TwitterProfile`, `Api` (custom webhook inbox).
* **ContactInbox**: Links a Contact to a specific Inbox channel, preserving identity across channels.
* **Conversation**: An active context/session containing a list of messages. Belongs to a Contact, Inbox, and Account, and can be assigned to an Agent (User) or Team.
* **Message**: Chat messages belonging to a conversation. Can be:
  * `incoming`: From the customer/contact.
  * `outgoing`: Sent by the agent.
  * `activity`: System-generated logging messages.
  * `template`: Auto-messages (e.g. CSAT survey, greeting).
* **Team**: Virtual groups of agents. Conversations can be assigned to Teams.

---

### 4. Key Features & Subsystems
* **Unified Omnichannel Dashboard**: Interleaves chat logs from different mediums (email, WhatsApp, Telegram, SMS, web chat) into a single, cohesive timeline.
* **Live Chat Web Widget**: Configurable, embeddable JS widget supporting branding, custom widgets, pre-chat forms, and offline capture.
* **Collaboration & Collision Prevention**: Real-time agent typing indicators, read receipts, online status tracking (`OnlineStatusTracker` using Redis), and concurrent collision alerts when multiple agents view the same ticket.
* **Automation Engines**:
  * **Automation Rules**: Event-driven rules that trigger actions (like assigning teams, adding labels, or sending replies) based on defined criteria.
  * **Macros**: Admin-defined sequence of actions that agents can manually run on conversations to speed up workflows.
* **Canned Responses**: Predefined message templates triggered with `/` shortcuts.
* **CRM Features**: Contact and company record management, customer custom attributes, and profile merging.
* **Help Center / Knowledge Base**: Multi-portal, multi-brand document management enabling multilingual article drafting and categorized public indexing.
* **CSAT & Surveys**: Configurable satisfaction forms sent automatically to customers upon conversation resolution.

---

### 5. Enterprise Features (EE Overlay)
* **SAML SSO**: Enterprise identity provider logins (`AccountSamlSettings`).
* **SLA Policies**: Set target response/resolution times with escalation triggers (`SlaPolicy`, `AppliedSla`).
* **Agent Capacity & Limits**: Auto-routing restrictions based on active agent workload (`AgentCapacityPolicy`, `InboxCapacityLimit`).
* **Custom Roles**: Custom access level policies beyond basic Agent/Admin.
* **Captain (AI Copilot / Assistant)**: Integrated LLM layer (`lib/llm`) providing:
  * Message summarization.
  * Auto-draft responses and reply suggestion prompts.
  * Sentiment and tone rewriting tools.
  * Document vector indexing & semantic search (`Document` embedding).
  * Automated scenario creation and FAQs suggestion maps.
* **Video/Audio Calling**: Native call sessions powered by Dyte.
