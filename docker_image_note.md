# Docker Image Selection

For this project, we are using the publicly available Docker image `nginxdemos/hello` as our web application. This image provides a simple web server that displays a welcome page, which is sufficient for demonstration purposes.

## Why `nginxdemos/hello`?
- **Simplicity**: It's a lightweight image that requires no additional configuration.
- **Reliability**: It's a well-maintained image from a trusted source.
- **Free Tier Compliance**: Using an existing image avoids additional costs associated with building and hosting a custom image.

If you wish to use a custom application, you can create a Dockerfile and build your own image. The steps for creating a custom Flask app are provided in the task details for reference.

The `nginxdemos/hello` image is already configured in the app EC2 instance's user data script to be pulled and run on port 80 upon instance initialization.
