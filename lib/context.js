(function() {
  var YAML, fs, path, yaml, _;
  _ = require('underscore');
  fs = require('fs');
  path = require('path');
  yaml = require('yaml');
  YAML = {
    parse: function(str) {
      var documents;
      documents = str.split("---\n");
      if (documents.length > 1) {
        return yaml.eval(documents[1]);
      } else {
        return yaml.eval(documents[0]);
      }
    }
  };
  exports.find_template_variables = function(template) {
    var base, match, related_files, variables;
    match = /^(.*\.)[a-z]{2,6}$/.exec(template);
    base = match[1];
    related_files = [[base + 'txt', YAML.parse], [base + 'yml', YAML.parse], [base + 'json', JSON.parse]];
    variables = related_files.map(function(descriptor) {
      var file, parser, str;
      file = descriptor[0], parser = descriptor[1];
      if (path.existsSync(file)) {
        str = fs.readFileSync(file, 'utf-8');
        return parser(str);
      } else {
        return {};
      }
    }).reduce(function(a, b) {
      return _.extend(a, b);
    });
    return variables;
  };
}).call(this);
