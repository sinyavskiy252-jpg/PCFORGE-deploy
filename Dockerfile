FROM node:22-alpine AS build

WORKDIR /app

COPY PCsait/package*.json ./
RUN npm install

COPY PCsait/ ./
RUN npm run build

FROM nginx:alpine

COPY PCFORGE-deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

# Self-signed certificate for local demonstration.
RUN apk add --no-cache openssl \
    && mkdir -p /etc/nginx/certs \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
       -keyout /etc/nginx/certs/pcforge.localhost-key.pem \
       -out /etc/nginx/certs/pcforge.localhost.pem \
       -subj "/CN=pcforge.localhost" \
       -addext "subjectAltName=DNS:pcforge.localhost,DNS:localhost" \
    && apk del openssl

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
