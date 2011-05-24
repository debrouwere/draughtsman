var sys = require('sys');
var fs = require('fs');
var os = require('os').type();

/* init */

var stdout = process.stdout;
var stdin = process.stdin;
stdin.setEncoding('utf8');

if (os == 'Darwin') {
    var default_web_root = process.env.HOME + "/Sites";
} else {
    var default_web_root = "/var/www";
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
        stdout.write("Next time you reboot, Draughtsman will be at your service at port 3400, processing files in " + web_root + "\n");
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
