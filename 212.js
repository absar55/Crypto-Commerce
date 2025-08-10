var express = require('express');
var formidable = require('formidable');

var app = express();

app.get('/', function (req, res){
    res.sendFile(__dirname + '/index.html');
});

app.post('/', function (req, res){
    var form = new formidable.IncomingForm();

    form.parse(req);

    form.on('fileBegin', function (name, file){
        file.filepath = __dirname + '/uploads/' + file.originalFilename;
    });

    form.on('file', function (name, file){
        console.log('Uploaded ' + file.originalFilename);
    });
    // res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end(`
    <h2>With Node.js <code>"http"</code> module</h2>
    <form action="/api/upload" enctype="multipart/form-data" method="post">
      <div>Text field title: <input type="text" name="title" /></div>
      <div>File: <input type="file" name="multipleFiles" multiple="multiple" /></div>
      <input type="submit" value="Upload" />
    </form>
    <form action="/api/upload" enctype="multipart/form-data" method="post">
      <div>Text field title: <input type="text" name="title" /></div>
      <div>Text field with same name: <input type="text" name="title" /></div>
      <div>Other field <input type="text" name="other" /></div>
      
      <input type="submit" value="submit simple" />
    </form>
    <button id="upload" onclick="asas('sas')">Upload</button>
  `);
    res.sendFile(__dirname + '/index.html');
});

app.listen(3000);