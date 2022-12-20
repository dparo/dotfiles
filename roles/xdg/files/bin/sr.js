#!/usr/bin/env -S deno run
"use strict";

const fs = require("fs");
const cp = require('child_process');


let args =  process.argv.slice(2);
let search = args[0];


let b = fs.readFileSync(0, 'utf-8');
let files = b.split("\n");
files = files.slice(0, files.length - 1);

let rg_args = [search];
rg_args     = rg_args.concat(["--no-heading", "-C", "2"]);
rg_args     = rg_args.concat(files);

let rg = cp.spawnSync(
    "rg", rg_args,
    {stdio: [null, process.stdout, process.stderr], encoding: "utf-8"}
);


if (typeof(args[1]) != "undefined") {

    console.log("\n\n");
    console.log('Performing the replacements\n\n');
    console.log('Done\n');

    search      = args[0].replace("/", "\\/").replace("?", "\\?").replace("\\\\?", "?");
    let replace = args[1].replace("/", "\\/");

    let sed_command = `s/${search}/${replace}/g`;
    let spawn_array = ["-I", "{}", "sed", "-E", "-i", "-e", sed_command, "{}"];
    let sed = cp.spawn("xargs", spawn_array);

    sed.stdin.setEncoding('utf-8');
    sed.on('exit', function() {
        process.exit();
    });

    sed.stdin.write(b);
    sed.stdin.end();
}
