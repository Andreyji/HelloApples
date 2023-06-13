#$env:KUBECONFIG = "kubeconfig"
  #get ip, copy mongo.conf and db
try {  
	$mon = kubectl get po | grep mongo | cut -d " " -f 1; $mip = kubectl describe po $mon | grep ' IP:' | awk '{print $3}'; kubectl.exe cp .\data.json $mon":/data/db/"; kubectl.exe cp .\mongo.conf $mon":/etc/mongod.conf.orig";
} catch { write-host $PSItem.Exception.Message }   
write-host "1. data copied to $mon $mip"

  ## kubectl exec -it $mon -- cat /data/configdb/mongo.conf
  #run from conf
try {
kubectl exec -it $mon -- /bin/bash -c "mongod --fork --logpath /var/log/mongodb/mongod.log --bind_ip 0.0.0.0; echo '2. DB engine is up'";
} catch { write-host $PSItem.Exception.Message } 

  #create user
try {
kubectl exec -it $mon -- mongosh --eval "use app" --eval "db.createUser({ user: 'Adminn', pwd: 'pAssw0rdd', roles: [ 'readWrite', 'dbAdmin' ]})";
write-host "3. User at place";
} catch { write-host $PSItem.Exception.Message } 

  #import:
try {  
kubectl exec -it $mon -- /bin/bash -c "mongoimport --type json --db app --collection fruits --file /data/db/data.json --jsonArray;"
write-host "4. data imported";
} catch { write-host $PSItem.Exception.Message } 

  ### Apples ###

  #run service
  #copy script and modify
try {
$app = kubectl get po | grep "apples" | awk '{print $1}'; kubectl cp .\creation.js $app":/home/node";
write-host app script is on $app;
} catch { write-host $PSItem.Exception.Message } 

try {
kubectl exec -it $app -- sed -i "s/???/$mip/g" /home/node/creation.js;
write-host "5. creation is ready.";
} catch { write-host $PSItem.Exception.Message } 

try {
kubectl exec -it $app -- /bin/bash -c 'node /home/node/creation.js \&'; write-host "6. app is running.";
} catch { write-host $PSItem.Exception.Message } 
write-host "6. app is running.";

  #connecting 
#$mpass = kubectl get secret mongodb-credentials -o jsonpath='{.data.MONGODB_PASSWORD}' 
#$muser = kubectl get secret mongodb-credentials -o jsonpath='{.data.MONGODB_USERNAME}'