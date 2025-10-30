<<<<<<< HEAD
FROM node:18-alpine
WORKDIR /app
COPY app/package*.json ./
RUN npm install
COPY app/ ./
EXPOSE 3000
ENV APP_POOL=blue
ENV RELEASE_ID=v1.0.0
CMD ["node", "server.js"]
=======
FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --omit=dev || npm install --production

COPY . .

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "server.js"]


>>>>>>> origin/main
