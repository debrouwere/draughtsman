(function() {
  var annotate_with_filetypes, create_breadcrumbs, endswith, fs, here, jade, known, path;
  var __slice = Array.prototype.slice;
  fs = require('fs');
  path = require('path');
  jade = require('jade');
  exports.here = here = function() {
    var paths;
    paths = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    paths = [__dirname].concat(paths);
    return path.join.apply(this, paths);
  };
  endswith = function(str, substr) {
    var end;
    end = str.substring(str.length - substr.length);
    return end === substr;
  };
  known = function(file, types) {
    types = types.filter(function(type) {
      return endswith(file, type);
    });
    if (types.length) {
      return types[0];
    } else {
      return false;
    }
  };
  annotate_with_filetypes = function(files, recognized_filetypes, root) {
    return files.map(function(file) {
      var filepath, filetype, stat, type;
      filetype = known(file, recognized_filetypes);
      filepath = file;
      stat = fs.statSync(path.join(root, file));
      if (filetype) {
        type = filetype;
      } else if (stat.isDirectory()) {
        type = "folder";
        filepath += '/';
      } else {
        type = "file";
      }
      return {
        name: file.split("/").pop(),
        path: filepath,
        type: type
      };
    });
  };
  create_breadcrumbs = function(path) {
    var breadcrumbs, i;
    breadcrumbs = [
      {
        name: ".",
        path: "/"
      }
    ];
    path = path.split('/');
    i = 0;
    while (i < path.length) {
      i++;
      if (!path[i]) {
        continue;
      }
      breadcrumbs.push({
        name: path[i],
        path: path.slice(0, (i + 1) || 9e9).join('/') + '/'
      });
    }
    return breadcrumbs;
  };
  exports.controller = function(req, res) {
    var files, listing, options;
    listing = fs.readdirSync(req.file.path);
    if (require('optimist').argv['search-tree'] != null) {
      files = require('findit').findSync(ROOT);
    } else {
      files = listing;
    }
    listing = annotate_with_filetypes(listing, req.app.accepts, req.file.path);
    files = annotate_with_filetypes(files, req.app.accepts, req.file.path);
    options = {
      locals: {
        breadcrumbs: create_breadcrumbs(req.params[0]),
        directory: req.params[0].split('/').pop() || '/',
        listing: listing,
        files: JSON.stringify(files)
      }
    };
    return jade.renderFile(here('listing.jade'), options, function(err, html) {
      return res.send(html);
    });
  };
}).call(this);
