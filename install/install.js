var sys = require('sys');
var fs = require('fs');
var os = require('os').type();

/* init */

var stdout = process.stdout;
var stdin = process.stdin;
stdin.setEncoding('utf8');

if (os == 'Darwin') {
    var default_web_root = process.env.HOME + "/Sites";
    var init_script = '/org.draughtsman.plist';
    var init_dir = process.env.HOME + "/Library/LaunchAgents";
} else if (os == 'Linux') {
    var default_web_root = "/var/www";
    var init_script = '/draughtsman.conf';
    var init_dir = "/etc/init";
}

/* logic */

var questions = [
    "Run and daemonize draughtsman at startup? [Y/n]: ",
    "Drafts directory [" + default_web_root + "]: ",
    ];

var answers = [];

function configure(answers) {
    answers = answers.map(function(answer){ return answer.replace(/\n/, ''); });
    var run_on_startup = (answers[0].indexOf('n') === -1);
    var web_root = answers[1] || default_web_root;
    if (run_on_startup) {
        if (os == 'Darwin' || os == 'Linux') {
            fs.symlinkSync(__dirname + init_script, init_dir + init_script);
            stdout.write("Next time you reboot, Draughtsman will be at your service at port 3400 on your localhost, processing files in " + web_root + "\n");
        } else {
            stdout.write("OS not recognized. Could not configure Draughtsman to load at startup.");
        }
    }
    stdout.write("Draughtsman has been successfully installed. You can run it from your shell using the `draughtsman` command.");
}

/* main */

stdout.write(questions.shift());
stdin.resume();

stdin.addListener("data", function(input){
    answers.push(input);
    if (!questions.length) {
        configure(answers);
        process.exit();
    } else {
        stdout.write(questions.shift());
        stdin.resume();
    }
});
