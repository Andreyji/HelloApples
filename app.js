const http = require('http');

const hostname = '127.0.0.1';
const port = 3000;



// Connect to the db
/**MongoClient.connect("mongodb://mongo:27017", function (err, db) {

    if (err) throw err;

});
*/
const { MongoClient } = require('mongodb').MongoClient;
async function main() {
    /**
     * Connection URI. Update <username>, <password>, and <your-cluster-url> to reflect your cluster.
     * See https://docs.mongodb.com/ecosystem/drivers/node/ for more details
     */
    //const { MongoClient } = require('mongodb');
    const uri = "mongodb://Admin:'P4ssw0rd'@'$MONGO_URL'";
    console.log(uri)
    //const client = new MongoClient(uri);
    MongoClient.connect("mongodb://mongo:27017/application", function (err, db) {
        var dbo = db.db("application");
        var query = { name: "apples" };
        dbo.collection("vars").findOne(query).toArray(function (err, result) {
            if (err) throw err;
            console.log(result);
            db.close();
            /**try {
                // Connect to the MongoDB cluster
                MongoClient.connect(uri);
                console.log("Hello!")
                // Make the appropriate DB calls
                listDatabases(MongoClient);
    
            } catch (e) {
                console.error(e);
            } finally {
                MongoClient.close();
            }*/
        });
    });
}
async function init() {
    console.log(MongoClient.isConnected()); // false
    await MongoClient.connect();
    console.log(MongoClient.isConnected()); // true
}
//init();

//const uri = "$MONGO_URL";
//const client = new MongoClient(uri);

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World! With some apples :) \
  Particularly: \n');
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});

main().catch(console.error)