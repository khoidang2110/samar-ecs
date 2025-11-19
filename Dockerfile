# Dockerfile
FROM nginx:alpine

# Xoá file mặc định
RUN rm -rf /usr/share/nginx/html/*

# Copy toàn bộ trang web tĩnh vào thư mục web server
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80
