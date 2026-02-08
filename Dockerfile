# ---------- Stage 1: Build ----------
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# If app has build step
RUN npm run build || echo "No build step"


# ---------- Stage 2: Runtime ----------
FROM node:18-alpine

WORKDIR /app

# Copy only necessary files
COPY --from=builder /app ./

EXPOSE 3000

CMD ["npm", "start"]