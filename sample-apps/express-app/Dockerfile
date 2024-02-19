FROM node:18

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

RUN npm install

# Copy the rest of the application code to the container
COPY . .

EXPOSE 8083

# For production environment
# CMD ["node", "./bin/www"]

# For development environment
CMD ["nodemon", "./bin/www"]
