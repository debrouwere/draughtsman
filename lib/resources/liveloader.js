now.reload = function(){
    window.location.reload(true);
}

now.ready(function(){
    // gather all resources
    var html = [location.href];
    var css = Array.prototype.slice.call(document.getElementsByTagName('link'));
    css = css.map(function(styles){ return styles.href; });
    var scripts = Array.prototype.slice.call(document.getElementsByTagName('script'));
    scripts = scripts.map(function(script){ return script.src; });
    // ask the server to keep an eye on any reloads
    now.liveload(location.host, location.pathname, html.concat(css, scripts));
});
