FROM node:22-alpine AS build

WORKDIR /app

COPY PCsait/package*.json ./
RUN npm install

COPY PCsait/ ./
RUN npm run build

FROM nginx:alpine

COPY PCFORGE-deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
