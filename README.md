# weekly35


## skafforld.dev 

## Makefile
## Dockerfile

- Makefile
```
# skaffold.dev
.PHONE= init 

k8start:
	minikube start &
k8stop:
	minikube stop &
dockerlogin:
	docker login
dockerlogout:
	docker logout
step01: products
	mkdir products cart && cd products
step02: step01
	cd products && npm -y init; npm i nodemon express
	cd cart && npm -y init; npm i nodemon express
step03: 
	cd products && mkdir src && cd src && touch index.js
	cd cart && mkdir src && cd src && touch index.js
step04:
	cd products && PORT=3000 npm run start &
	cd cart && PORT=3001 npm run start &
	# kill -9 112142 112143 112145 112170 112171
step05:
	cd products && docker build . && docker build -t maximilianou/products .
	cd cart && docker build . && docker build -t maximilianou/cart .
step06:
	cd products && docker run --name weekly35_products -p 3000:30000 -e PORT=30000 maximilianou/products &
	cd cart && docker run --name weekly35_cart -p 3001:30001 -e PORT=30001 maximilianou/cart &
step07:
	docker stop weekly35_products
	docker stop weekly35_cart
```

- Dockerfile
```
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
CMD "npm" "start"
```
- package.json
```
{
  "name": "products",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "nodemon src/index.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1",
    "nodemon": "^2.0.7"
  }
}
```
- index.js
```
const express = require('express')
const app = express()
app.get('/api/products', (req, res) => {
  res.json({ message: `Products API ${(new Date()).toISOString()}`})
})
app.listen( process.env.PORT, () => console.log(`Listening in http://localhost:${process.env.PORT}/api/products`))
```