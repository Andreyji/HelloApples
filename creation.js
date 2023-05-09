const { MongoClient } = require('mongodb');

const username = process.env.MONGODB_USERNAME;
const password = process.env.MONGODB_PASSWORD;
const uri = "mongodb://" + username + ":" + password + "@10.244.0.19:27017/app";

let apples;
// const client = new MongoClient(uri);


async function connectToMongoDB() {
    try {
        return await MongoClient.connect(uri)
            .then(async function (db) {
            console.log('Connected to MongoDB successfully!');
            let dbo = db.db("app");
            apples = await dbo.collection("fruits").findOne({ name: "apples" })
            console.log(apples);
            return apples.qty;
        })
            .catch(err => {
                console.error(err);
            })
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}


var http = require('http');

http.createServer(async function (req, res) {
    let apples = await connectToMongoDB();
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello World! With some apples.. particularly: ' + apples);
}).listen(30200);

// connectToMongoDB()


