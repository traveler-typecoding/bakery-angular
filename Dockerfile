# =============================================================================
# base: Node toolchain with deps installed
# =============================================================================
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci || npm install

# =============================================================================
# dev: ng serve with live reload (source bind-mounted via compose if desired)
# =============================================================================
FROM base AS dev
COPY . .
EXPOSE 4200
# --host 0.0.0.0 so the dev server is reachable from outside the container.
CMD ["npm", "run", "start", "--", "--host", "0.0.0.0", "--poll", "500"]

# =============================================================================
# build: produce static assets
# =============================================================================
FROM base AS build
COPY . .
RUN npm run build

# =============================================================================
# prod: serve static files with nginx
# =============================================================================
FROM nginx:1.27-alpine AS prod
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Angular outputs to dist/<project>/browser in v17+. Adjust path to match yours.
COPY --from=build /app/dist/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
