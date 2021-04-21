# weekly35

## skafforld.dev 

## Makefile
- Create projects nodejs
- start k8s
- login dockerhub
- Dockerfile Start/Stop named containers
- Dockerfile Parameter passing
## Dockerfile

- Makefile
```
# skaffold.dev
# skaffold.dev
.PHONY= init 

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
step08:
	docker push maximilianou/products
	docker push maximilianou/cart
step09:
	mkdir k8s && cd k8s && kubectl create deploy products --image=maximilianou/products --dry-run=client -o yaml > products-definition.yaml
	cd k8s && kubectl create deploy cart --image=maximilianou/cart --dry-run=client -o yaml > cart-definition.yaml
step10:
	kubectl create -f products-definition.yaml 
	kubectl create -f k8s/cart-definition.yaml
step11:
	cd k8s && kubectl run nginx --image=nginx  -it --restart=Never -- /bin/sh
step12:
	kubectl get all
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

- products-definition.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: products
spec:
  replicas: 1
  selector:
    matchLabels:
      app: products
  template:
    metadata:
      labels:
        app: products
    spec:
      containers:
      - image: maximilianou/products
        name: products

---
apiVersion: v1
kind: Service
metadata:
  name: products-service
spec:
  selector:
    app: products
  ports:
  - protocol: TCP
    port: 3000
    targetPort: 3000
```

-----
- Access api products inside kube pod
```
:~/projects/weekly35$ kubectl run nginx --image=nginx  -it --restart=Never -- /bin/sh
ls
If you don't see a command prompt, try pressing enter.
ls
bin   docker-entrypoint.d   home   media  proc	sbin  tmp
boot  docker-entrypoint.sh  lib    mnt	  root	srv   usr
dev   etc		    lib64  opt	  run	sys   var
# curl products-service:3000/api/products
```

-----
- cart-definition.yml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cart
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cart
  template:
    metadata:
      labels:
        app: cart
    spec:
      containers:
      - image: maximilianou/cart
        name: cart

---
apiVersion: v1
kind: Service
metadata:
  name: cart-service
spec:
  selector:
    app: cart
  ports:
  - protocol: TCP
    port: 3001
    targetPort: 3001
```

-----
## Running the k8s cluster

## Connection the k8s cluster with Ingress-nginx

https://kubernetes.github.io/ingress-nginx/deploy/

- bare metal 

:~/projects/weekly35$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.45.0/deploy/static/provider/baremetal/deploy.yaml

### k8s look for services in all namespaces
```
:~/projects/weekly35$ kubectl get svc --all-namespaces
```

https://kubernetes.github.io/ingress-nginx/user-guide/basic-usage/

- here we are going to configure just One ingress service

- ingress.yaml
```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress-shop
  annotations:
    # use the shared ingress-nginx
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: shop.com
    http:
      paths:
      - path: /api/products
        backend:
          serviceName: products-service
          servicePort: 3000
      - path: /api/cart
        backend:
          serviceName: cart-service
          servicePort: 3001
```

```
:~/projects/weekly35$ kubectl create -f k8s/ingress.yaml 
Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
ingress.networking.k8s.io/ingress-shop created

```
- /etc/hosts
```
127.0.0.1   shop.com
```

- scaffold.dev

https://skaffold.dev/docs/install/

```
# For Linux AMD64
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64

su -
install skaffold /usr/local/bin/
exit
```

- 
```
:~/projects/weekly35$ skaffold init
? Choose the builder to build image maximilianou/cart Docker (cart/Dockerfile)
? Choose the builder to build image maximilianou/products Docker (products/Dockerfile)
apiVersion: skaffold/v2beta14
kind: Config
metadata:
  name: weekly-
build:
  artifacts:
  - image: maximilianou/cart
    context: cart
    docker:
      dockerfile: Dockerfile
  - image: maximilianou/products
    context: products
    docker:
      dockerfile: Dockerfile
deploy:
  kubectl:
    manifests:
    - k8s/cart-definition.yaml
    - k8s/ingress.yaml
    - k8s/products-definition.yaml

? Do you want to write this configuration to skaffold.yaml? Yes
Configuration skaffold.yaml was written
You can now run [skaffold build] to build the artifacts
or [skaffold run] to build and deploy
or [skaffold dev] to enter development mode, with auto-redeploy
```

```
:~/projects/weekly35$ cat skaffold.yaml 
apiVersion: skaffold/v2beta14
kind: Config
metadata:
  name: shop-skaffold
build:
  artifacts:
  - image: maximilianou/cart
    context: cart
    sync: 
      manual: 
      - src: "src/**/*.js"
        dest: "."
    docker:
      dockerfile: Dockerfile
  - image: maximilianou/products
    context: products
    sync: 
      manual: 
      - src: "src/**/*.js"
        dest: "."
    docker:
      dockerfile: Dockerfile
deploy:
  kubectl:
    manifests:
    - k8s/cart-definition.yaml
    - k8s/ingress.yaml
    - k8s/products-definition.yaml
```

### Here you have to run twice the command skaffold dev
- look this, fist run fail, second run OK

- First Run Fails
```
:~/projects/weekly35$ skaffold dev
Listing files to watch...
 - maximilianou/cart
 - maximilianou/products
Generating tags...
 - maximilianou/cart -> maximilianou/cart:a43b552
 - maximilianou/products -> maximilianou/products:a43b552
Checking cache...
 - maximilianou/cart: Not found. Building
 - maximilianou/products: Not found. Building
Starting build...
Found [minikube] context, using local docker daemon.
Building [maximilianou/products]...
Sending build context to Docker daemon  4.568MB
Step 1/12 : FROM node:alpine
alpine: Pulling from library/node
ddad3d7c1e96: Already exists
0e18143e8d4d: Already exists
377ad682a98b: Already exists
99b3e0ba5237: Already exists
Digest: sha256:3ca0132180509b9fd68545b2232dd9fc01726c06fc36b772389d41b82d81a8de
Status: Downloaded newer image for node:alpine
 ---> 75631da67663
Step 2/12 : WORKDIR /usr/src/app
 ---> Running in b08e098a101f
 ---> ef98e7772ba6
Step 3/12 : COPY --chown=node:node . /usr/src/app
 ---> 1e94d9cbf47b
Step 4/12 : COPY package.json package-lock.json /usr/src/app/
 ---> 34b292bda96b
Step 5/12 : RUN chown -R node:node /usr/local/*
 ---> Running in 60c87391c988
 ---> d9bdaf60a437
Step 6/12 : RUN chown -R node:node /usr/src/app/*
 ---> Running in e93b5026c9bb
 ---> c5b9f824fe64
Step 7/12 : USER node
 ---> Running in 4d6ec4d3ffb3
 ---> bf7d5d0cc729
Step 8/12 : RUN npm install
 ---> Running in 2267202dca7f

up to date, audited 168 packages in 2s

11 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
npm notice 
npm notice New minor version of npm available! 7.7.6 -> 7.10.0
npm notice Changelog: <https://github.com/npm/cli/releases/tag/v7.10.0>
npm notice Run `npm install -g npm@7.10.0` to update!
npm notice 
 ---> ff45205ee2c9
Step 9/12 : COPY . .
 ---> 09c6501f94e0
Step 10/12 : ARG PORT=3000
 ---> Running in e95fe9048219
 ---> 7a1a9c13f94a
Step 11/12 : ENV PORT=${PORT}
 ---> Running in 22d5e6fc1bf6
 ---> e6d2f6ebfe81
Step 12/12 : CMD "npm" "start"
 ---> Running in c1c1683b8143
 ---> 204fba77b10d
Successfully built 204fba77b10d
Successfully tagged maximilianou/products:a43b552
Building [maximilianou/cart]...
Sending build context to Docker daemon  4.568MB
Step 1/12 : FROM node:alpine
 ---> 75631da67663
Step 2/12 : WORKDIR /usr/src/app
 ---> Using cache
 ---> ef98e7772ba6
Step 3/12 : COPY --chown=node:node . /usr/src/app
 ---> ca156ce24ba0
Step 4/12 : COPY package.json package-lock.json /usr/src/app/
 ---> 0f2ea5a3b73d
Step 5/12 : RUN chown -R node:node /usr/local/*
 ---> Running in 3711980d4dcb
 ---> 63d474716c7b
Step 6/12 : RUN chown -R node:node /usr/src/app/*
 ---> Running in 208f8e638a90
 ---> 8a9a9251108a
Step 7/12 : USER node
 ---> Running in 42a44a5e0af4
 ---> 666630387222
Step 8/12 : RUN npm install
 ---> Running in ca47c5ab0c43

up to date, audited 168 packages in 3s

11 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
npm notice 
npm notice New minor version of npm available! 7.7.6 -> 7.10.0
npm notice Changelog: <https://github.com/npm/cli/releases/tag/v7.10.0>
npm notice Run `npm install -g npm@7.10.0` to update!
npm notice 
 ---> 2eacf3c7c55b
Step 9/12 : COPY . .
 ---> 22298dd7bf7c
Step 10/12 : ARG PORT=3001
 ---> Running in 1f1d0387d526
 ---> 927f58d28145
Step 11/12 : ENV PORT=${PORT}
 ---> Running in 36a3383caaaa
 ---> b3a70335fbe0
Step 12/12 : CMD "npm" "start"
 ---> Running in 081203d43d74
 ---> d252c7192f5f
Successfully built d252c7192f5f
Successfully tagged maximilianou/cart:a43b552
Starting test...
Tags used in deployment:
 - maximilianou/cart -> maximilianou/cart:d252c7192f5f442b9580e90525afa16c04092c5d23cb44e3df7014b2a70b4336
 - maximilianou/products -> maximilianou/products:204fba77b10d5c4f3b235788571bf6df00fee382666cb83883113dc9b068eb57
Starting deploy...
 - Warning: resource deployments/cart is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
 - deployment.apps/cart configured
 - Warning: resource services/cart-service is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
 - service/cart-service configured
 - Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
 - Warning: resource ingresses/ingress-shop is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
 - ingress.networking.k8s.io/ingress-shop configured
 - Warning: resource deployments/products is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
 - deployment.apps/products configured
 - Warning: resource services/products-service is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
 - service/products-service configured
Waiting for deployments to stabilize...
 - deployment/cart: container cart is waiting to start: maximilianou/cart:d252c7192f5f442b9580e90525afa16c04092c5d23cb44e3df7014b2a70b4336 can't be pulled
    - pod/cart-8f665ffdf-8tz7q: container cart is waiting to start: maximilianou/cart:d252c7192f5f442b9580e90525afa16c04092c5d23cb44e3df7014b2a70b4336 can't be pulled
 - deployment/cart failed. Error: container cart is waiting to start: maximilianou/cart:d252c7192f5f442b9580e90525afa16c04092c5d23cb44e3df7014b2a70b4336 can't be pulled.
Cleaning up...
 - deployment.apps "cart" deleted
 - service "cart-service" deleted
 - Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
 - ingress.networking.k8s.io "ingress-shop" deleted
 - deployment.apps "products" deleted
 - service "products-service" deleted
exiting dev mode because first deploy failed: 2/2 deployment(s) failed
```
- Second Run OK
```
:~/projects/weekly35$ skaffold dev
Listing files to watch...
 - maximilianou/cart
 - maximilianou/products
Generating tags...
 - maximilianou/cart -> maximilianou/cart:a43b552
 - maximilianou/products -> maximilianou/products:a43b552
Checking cache...
 - maximilianou/cart: Found Locally
 - maximilianou/products: Found Locally
Starting test...
Tags used in deployment:
 - maximilianou/cart -> maximilianou/cart:d252c7192f5f442b9580e90525afa16c04092c5d23cb44e3df7014b2a70b4336
 - maximilianou/products -> maximilianou/products:204fba77b10d5c4f3b235788571bf6df00fee382666cb83883113dc9b068eb57
Starting deploy...
 - deployment.apps/cart created
 - service/cart-service created
 - Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
 - ingress.networking.k8s.io/ingress-shop created
 - deployment.apps/products created
 - service/products-service created
Waiting for deployments to stabilize...
 - deployment/cart is ready. [1/2 deployment(s) still pending]
 - deployment/products is ready.
Deployments stabilized in 2.371 seconds
Press Ctrl+C to exit
Watching for changes...
[cart] 
[cart] > cart@1.0.0 start
[cart] > nodemon src/index.js
[cart] 
[cart] [nodemon] 2.0.7
[cart] [nodemon] to restart at any time, enter `rs`
[cart] [nodemon] watching path(s): *.*
[cart] [nodemon] watching extensions: js,mjs,json
[cart] [nodemon] starting `node src/index.js`
[products] 
[products] > products@1.0.0 start
[products] > nodemon src/index.js
[products] 
[cart] Listening in http://localhost:3001/api/cart
[products] [nodemon] 2.0.7
[products] [nodemon] to restart at any time, enter `rs`
[products] [nodemon] watching path(s): *.*
[products] [nodemon] watching extensions: js,mjs,json
[products] [nodemon] starting `node src/index.js`
[products] Listening in http://localhost:3000/api/products
```


