# Use the official Dart image as the base image
FROM dart:stable AS build

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor to download dependencies
RUN flutter doctor -v

# Enable flutter web
RUN flutter config --enable-web

# Copy the app source code to the container
WORKDIR /app
COPY . .

# Get Flutter dependencies
RUN flutter pub get

# Build the CardKeep web app
RUN flutter build web --release --web-renderer canvaskit

# Use nginx to serve the app
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
