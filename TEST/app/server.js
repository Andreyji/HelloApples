'use strict';

const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.send('Hello World with some apples :)');
});

app.listen(PORT, HOST, () => {
  console.log(`Running on http://${HOST}:${PORT}`);
});
var mongo = require('mongodb');
var MongoClient = require('mongodb').MongoClient;
var url = "$MONGODB_URI";

MongoClient.connect(url, function (err, db) {
	if (err) throw err;
	console.log("Database created!");
	db.close();
});