# Sprintboard

A small organization-based task manager built with Ruby on Rails 8.1. Organization data is scoped through the authenticated user; the first user who creates an organization becomes its administrator.

## Run with Docker Compose

```sh
docker compose up --build
```

Open http://localhost:3000. The container prepares the database, creates the Free plan if needed, generates and persists a Rails secret, then starts the web server. Uploaded files and the SQLite database are stored in the `task_storage` volume.

For deployment behind an HTTPS-terminating reverse proxy, set `COOKIE_SECURE=true` and `FORCE_SSL=true` in the Compose environment. Keep the volume persistent and back it up. The generated secret is stored in that same volume unless `SECRET_KEY_BASE` is provided through the deployment's secret manager.

## Run locally

Requirements: Ruby 4.0.9 and Bundler.

```sh
bundle install
bin/rails db:prepare
bin/rails runner script/seed_free_plan.rb
bin/rails server
```

The Free plan script is safe to run repeatedly. It creates a free plan with intentionally high user/project limits; plan rows are not loaded via `db:seed`.

## Tests and checks

```sh
bin/rails test
bin/rails zeitwerk:check
```

## Domain notes

- Roles are `admin` and `standard`. Administrators manage members, projects, and board statuses; standard users can work on projects they belong to.
- Comments are separate records, and task files use Active Storage. Story points are decimals from 0.1 to 999999.9; task `updated_at` records the latest change.
- Project membership and task assignment models reject users from another organization. Controllers resolve projects and tasks only through the current organization.
- The Free plan limits are high placeholders. A future billing integration should add subscription/payment state and enforce limits in transactional service operations before exposing paid plans.

SQLite keeps the initial Compose setup self-contained. Before horizontally scaling application containers, move the primary database and Active Storage files to shared managed services such as PostgreSQL and object storage.