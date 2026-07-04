# DevOps Lab 2 — Docker Demo
# Sử dụng Node.js official image
FROM node:18-alpine

# Thiết lập thư mục làm việc
WORKDIR /app

# Copy package.json trước (tận dụng Docker cache)
COPY package.json .

# Cài đặt dependencies
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Lệnh chạy ứng dụng
CMD ["node", "server.js"]
