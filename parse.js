// var p = require('arithmetics.js')
var fs = require('fs')
var PEG = require("pegjs");

fs.readFile(process.argv[2], 'utf8', function (err, data) {
    if (err) {
        return console.log(err);
    }

    var parser = PEG.buildParser(data);

    process.stdin.setEncoding('utf8');

    var input = '';
    process.stdin.on('readable', function() {
      var chunk = process.stdin.read();
      if (chunk !== null) {
        input += chunk;
      }
    });

    process.stdin.on('end', function() {
      var res = parser.parse(input);
      process.stdout.write(res);
    });
});
