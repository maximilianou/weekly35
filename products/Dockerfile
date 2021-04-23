FROM node:alpine
WORKDIR /usr/src/app
COPY --chown=node:node . /usr/src/app
COPY package.json package-lock.json /usr/src/app/
RUN chown -R node:node /usr/local/*
RUN chown -R node:node /usr/src/app/*
USER node
RUN npm install
COPY . .
ARG PORT=3000
ENV PORT=${PORT} 
EXPOSE ${PORT}
CMD "npm" "start"