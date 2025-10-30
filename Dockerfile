FROM node:18-alpine
WORKDIR /app
COPY app/package*.json ./
RUN npm install
COPY app/ ./
EXPOSE 3000
ENV APP_POOL=blue
ENV RELEASE_ID=v1.0.0
CMD ["node", "server.js"]