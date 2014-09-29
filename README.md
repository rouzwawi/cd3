CD3 - Concise D3
================

```sh
$ npm install
$ ./test
```

```sh
$ cd3 <<EOF
x = 200
d3 selectAll input
append input#email.big.focus@color=blue@width=x@enabled
EOF
var x;
x = 200
d3.selectAll("input")
.append("input")
  .classed({"big":true,"focus":true})
  .attr("id", "email")
  .attr("color", "blue")
  .attr("width", x)
  .attr("enabled", true)
```
