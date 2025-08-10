const http = require('http');
const fs = require('fs');
const formidable = require('formidable');
const server = http.createServer();

server.on('request', (req, res) => {

    if(req.url === '/' && req.method == 'GET') {
        console.log("000")
        return res.end(fs.readFileSync(__dirname + '/index.html'))
    }

    if (req.url.split('?')[0] === '/upload' && req.method.toLowerCase() === 'post') {
        // parse a file upload
        const form = formidable({ multiples: true });
    
        form.parse(req, (err, fields, files) => {
          if (err) {
            res.writeHead(err.httpCode || 400, { 'Content-Type': 'text/plain' });
            res.end(String(err));
            return;
          }
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ fields, files }, null, 2));
        });
    
        return;
      }

      res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end(`
    <h2>With Node.js <code>"http"</code> module</h2>
    <form action="/api/upload" enctype="multipart/form-data" method="post">
      <div>Text field title: <input type="text" name="title" /></div>
      <div>File: <input type="file" name="multipleFiles" multiple="multiple" /></div>
      <input type="submit" value="Upload" />
    </form>
  `);

    // if(req.url.split('?')[0] === '/upload' && req.method == 'POST') {
    //     const query = new URLSearchParams(req.url);
    //     const fileName = query.get('/upload?fileName')

    //     req.on('data', chunk => {
    //         fs.appendFileSync(fileName, chunk);
    //         // console.log(chunk.toString())
    //     })
    //     return res.end('<h1>file uploaded.<h1>');
    // }
    console.log("111")
})
console.log("222")

server.listen(3000, () => {
    console.log('Server running on port 8080')
})