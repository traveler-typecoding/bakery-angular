# bakery-angular

Angular frontend for the Bakery system. Owns its source, Dockerfile, and nginx
config. Orchestrated by the `bakery-infra` repo.

## Layout

```
.
├── Dockerfile    # multi-stage: dev (ng serve) / build / prod (nginx)
├── nginx.conf    # SPA routing + /api proxy to the backend
└── (Angular app source — generate it, see below)
```

## Generate the Angular app

This repo currently has only the Docker/nginx config. Create the app in place:

```bash
npx @angular/cli@latest new bakery-angular --directory . --skip-git
```

Make sure `package.json` has `start` and `build` scripts (the CLI adds them).
Confirm the build output path — Angular 17+ emits `dist/<app>/browser`; the
Dockerfile copies `dist/` and `nginx.conf` serves from
`/usr/share/nginx/html`. Adjust if your version differs.

## Run standalone

```bash
docker build --target dev -t bakery-angular:local .
docker run --rm -p 4200:4200 bakery-angular:local
```

Normally you run it via the full stack in `bakery-infra`.

## Image publishing

CI builds the `prod` target and pushes a tagged image; `bakery-infra`
references it via `FRONTEND_IMAGE`.

```bash
docker build --target prod -t registry.example.com/bakery/angular:<tag> .
docker push registry.example.com/bakery/angular:<tag>
```
