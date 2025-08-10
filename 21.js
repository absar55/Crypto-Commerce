var { Web3Storage, File } = require('web3.storage');
var fs = require("fs");
var express = require('express');
var formidable = require('formidable');
var util = require('util');

const client = new Web3Storage({ token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEI4YTFEMzZlRmNiRTI2QzlDNjRGQkQwREQwNTZEMTQyNzMwQTVCYzkiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NzAwODY5Nzk3MDQsIm5hbWUiOiJkZXYxIn0.ndKdCcPeaS2dspINri9GEFS2CvDvLuuTdzn-yA8Ptzs" });

var app = express();

app.use(express.static("./")); 

app.get('/sell', function (req, res){
    res.sendFile(__dirname + '/__index.html');
});

/*app.post('/', function(req, res){
    var form = new formidable.IncomingForm();
    form.uploadDir = __dirname + "/uploads/";
    form.parse(req, function(err, fields, file) {
        //fields is an object containing all your fields, do waht ever you want with them from here
        //file is an object containing properties of your uploaded file
        console.log('0 ',fields.XXX, file);
        // res.send(util.inspect({fields: fields, file: file}));
        console.log('1 ',file.uploadDir, file.originalFilename);
        console.log('file uploaded : ' + file.upload.path + '/' + file.upload.name);
        console.log('Fields : ' + fields.adName);//you can access all your fields
    });
});*/

app.post('/add', async function (req, res){
    var form = new formidable.IncomingForm();
    const obj = {}

    form.parse(req);

    form.on('fileBegin', function (name, file){
        console.log(name)
        file.filepath = __dirname + '/uploads/' + file.originalFilename;
        // console.log(file)
        
        // const cid = client.put([_file])
        
    });

    form.on('field', function(name, field) {
        console.log('Got a field:', name, field);
        obj[name] = field
        
    //     return res.end(`
    //     <h2>With Node.js <code>"http"</code> module</h2>
    //     <form action="/api/upload" enctype="multipart/form-data" method="post">
    //       <div>Text field title: <input type="text" name="title" /></div>
    //       <div>File: <input type="file" name="multipleFiles" multiple="multiple" /></div>
    //       <input type="submit" value="Upload" />
    //     </form>
    //     <form action="/api/upload" enctype="multipart/form-data" method="post">
    //       <div>Text field title: <input type="text" name="title" /></div>
    //       <div>Text field with same name: <input type="text" name="title" /></div>
    //       <div>Other field <input type="text" name="other" /></div>
    //       <input type="submit" value="submit simple" />
    //     </form>
    //   `);
    });

    form.on('file', async function (name, file){
        console.log(name)
        _obj = {title: obj['title'], info: obj['info']};
        const meta = new File([JSON.stringify(_obj)], 'meta.json')
        const _file = new File([fs.readFileSync('uploads/' + file.originalFilename)], "image.png", {type: 'image/jpg|image/png'});
        console.log(_file)
        const _cid = await client.put([meta, _file])
        fcid = "https://"+_cid+".ipfs.w3s.link"
        console.log(fcid)
        console.log("cid")
        console.log(obj)
        // res.sendFile(__dirname + '/index.html');
        // const _cid = getCid(_file).then(console.log("_cid"))
        // console.log(_cid)
        console.log('Uploaded ' + file.originalFilename);
        // res.header('Content-type', 'text/html');
        // return res.append('<h1>'+{_cid}+'</h1>');
        // return res.status(200).json({ message: _cid })
        // res.status(201).send({id:'XXX', Text:_cid});
        // res.json({asas:"asas"});
        // res.set('Content-Type', 'text/plain');
        // res.type('txt')
        // res.send('as');
        // res.end()
        res.end(`
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8" />
            <meta http-equiv="X-UA-Compatible" content="IE=edge" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <!-- Importing css styles -->
            <!-- <link rel="stylesheet" href="./index.css" /> -->
            <title>Pet dApp</title>
            <link rel="stylesheet" href="./codebase/webix.css" type="text/css" charset="utf-8">
            <link rel="stylesheet" href="button.css" type="text/css" charset="utf-8">
            <script src="./codebase/webix.js" type="text/javascript" charset="utf-8"></script>
            
          </head>
          <body>
            
            
            <script type="text/javascript" charset="utf-8">
            webix.ui({view:"window", id:"win1", height:130, width:460, padding:0, position:"center", modal:"true", headHeight:0, body:{
                css:{"background": "#283440", "color":"#eeeeee"},
                id:"tmp", 
                view:"template",
                template:"<center><br><br><br>${_cid}",
                width:500,
              }}).show();
            </script>
            <script src="ethers-5.7.2.umd.min.js" type="application/javascript"></script>
            <script src="/2.js" type="application/javascript"></script>
          </body>
        </html>
  `);

        // return res.end(_cid)
    });
    // console.log("asas")
    // res.end(cid)
    
});

// async function getCid(_file){
//   const cid = await client.put([_file])
//   console.log("sasa", cid)
//   return cid
// }

app.listen(3000);