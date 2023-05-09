  #start mongo
kubectl apply -f '.\mongo.yml'; sleep 80

  #get ip
$mon = kubectl get po | grep mongo | cut -d " " -f 1; $mip = kubectl describe po $mon | grep ' IP:' | awk '{print $2}'

  #copy mongo conf and db
kubectl.exe cp .\data.json $mon":/data/db/"
kubectl.exe cp .\mongo.conf $mon":/data/configdb/"

  ## kubectl exec -it $mon -- cat /data/configdb/mongo.conf
  #run from conf
kubectl exec -it $mon -- mongod -f /data/configdb/mongo.conf
  
  #create user
kubectl exec -it $mon -- mongosh --eval "use app" --eval "db.createUser({ user: 'Adminn', pwd: 'pAssw0rdd', roles: [ 'readWrite', 'dbAdmin' ]})"

  #import:
kubectl exec -it $mon -- mongoimport --type json --db app --collection fruits --file /data/db/data.json --jsonArray

  ### Apples ###

  #run service
kubectl apply -f '.\app&svc.yml'; sleep 20

  #copy script and modify
$app = kubectl get po | grep "apples" | awk '{print $1}'
kubectl cp .\creation.js $app":/home/node"
kubectl exec -it $app -- cd /home/node/; sed -i "s/???/$mip/g" creation.js; cat creation.js
kubectl exec $app -- /bin/bash -c 'cd /home/node; node ./creation.js &'

  #connecting 
$mpass = kubectl get secret mongodb-credentials -o jsonpath='{.data.MONGODB_PASSWORD}' 
$muser = kubectl get secret mongodb-credentials -o jsonpath='{.data.MONGODB_USERNAME}'