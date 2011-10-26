now.reload = function(){
    console.log("will reload");
    window.location.reload(true);
}

now.ready(function(){
    // gather all resources
    var css = Array.prototype.slice.call(document.getElementsByTagName('link'));
    css = css.map(function(styles){ return styles.href; });
    var scripts = Array.prototype.slice.call(document.getElementsByTagName('script'));
    scripts = scripts.map(function(script){ return script.src; });
    // ask the server to keep an eye on any reloads
    now.liveload(css.concat(scripts));
});
