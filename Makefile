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


