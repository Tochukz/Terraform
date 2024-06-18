FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 80

# For production environment
CMD ["node", "./bin/www"]

# For development environment
# CMD ["nodemon", "./bin/www"]
