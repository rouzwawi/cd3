/*
 * Grammar for CD3
 */

{
  var env = {'d3':true};

  function funcify(code) {
    if (typeof(code) == 'boolean')
      return code;

    return code.indexOf('_d') > -1 || code.indexOf('_i') > -1
      ? 'function(_d, _i) { return ' + code + '; }'
      : env[code]
        ? code
        : '"' + code + '"';
  }
}

start
  =  space program:expr*
  {
    var vars = [];
    for (var name in env) if (name != 'd3') vars.push(name);
    vars.sort();

    var p = '';
    if (vars.length) p += 'var ' + vars.join(',') + ';\n';
    p += program.filter(Boolean).join('\n') + '\n';

    return p;
  }

ending
  = $(space (';' ending)*)

space
  = $[ \t\n]*

expr
  = e:expr_ ending { return e }

expr_
  = assign
  // invoke
  / ref
  / num
  / selectAll
  / select
  / data
  / append
  // enter
  / $('_' '_' '_')

assign
  = name:id space '=' space expr:expr
  {
    env[name] = true;
    return name + ' = ' + expr;
  }

invoke
  = id:ref space '(' space arg:expr space ')' space e:expr?
    { return id + '(' + arg + ')' + (e || '') }

ref
  = id:id space e:expr?
  & { return env[id] } // must reference declared name
    { return id + (e || '') }


// d3 expressions

select
  = 'select' space elem:$elems
    { return '.select("' + elem + '")' }

selectAll
  = 'selectAll' space elem:$elems
    { return '.selectAll("' + elem + '")' }

data
  = 'data' space ref:(invoke / ref)
    { return '\t.data(' + ref + ')' }

enter
  = 'enter'
    { return '.enter()\n' }

append
  = 'append' space elem:elems
  {
    var id,
        classes = {},
        hasClasses = false,
        attrs = elem.attrs;

    for (i in elem.clid) {
      var item = elem.clid[i];
      switch (item.t) {
        case 'i':
          if (id) error('only one id allowed');
          id = item.value;
          break;
        case 'c':
          classes[item.value] = true;
          hasClasses = true;
          break;
      }
    }

    var r = '.append(' + funcify(elem.tag) + ')'

    if (hasClasses)
      r += '\n\t.classed(' + JSON.stringify(classes) + ')';

    if (id)
      r += '\n\t.attr("id", ' + funcify(id) + ')';

    for (a in attrs)
      r += '\n\t.attr("' + attrs[a].name + '", ' + funcify(attrs[a].value) + ')';

    return r
  }

elems 'jade-like element'
  = e:idp? clid:class_or_id* attrs:attr*
  & { return e || clid.length || attrs.length }
    { return {
        tag: e || 'div',
        clid: clid,
        attrs: attrs
      }
    }

class_or_id
  = '#' i:idp { return {t: 'i', value: i} }
  / '.' c:idp { return {t: 'c', value: c} }

attr
  = space '@' a:id '=' v:(ref / idp) { return {name: a, value: v} }
  / space '@' a:id                   { return {name: a, value: true} }

idp
  = id
  / '(' in_parens ')' { return text() }

in_parens
  = [^)]+

id
  = id:([a-zA-Z_][0-9a-zA-Z_\-]*) { return id[0] + id[1].join('') }

num
  = $('0' [xX] hex)
  / $('.' dec)
  / $(dec ('.' dec)?)

dec
  = $[0-9]+

hex
  = $[0-9a-fA-F]+
