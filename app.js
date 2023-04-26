var MongoClient = require('mongodb').MongoClient;
//Create a database named "mydb":
var url = "mongodb://localhost:27017/mydb";

MongoClient.connect(url, function (err, db) {
    if (err) throw err;
    var dbo = db.db("newdb");
    dbo.createCollection("fruits", function (err, res) {
        if (err) throw err;
        console.log("Database created!");
    });
    console.log(db)
    db.close();
});

