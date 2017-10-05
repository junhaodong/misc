Shellfish
======
Fall 2014

Runs on Linux/macOS

Compile with `make`, run with `./shell`
Exit with `exit`, `quit`, or Ctrl-D at the start of a line

## Basic Features
- [x] Execute multiple commands per line, separated by `;`
  - [x] Trim excess white space
  - [x] Ignore consecutive semicolons rather than returning a syntax error
- [x] Basic file redirection: `<`, `>`, `>>`
- [x] Basic piping: `|`
- [x] Checked for memory leaks: Valgrind

## Todo
### Enhancements
------
- [x] Tilde expansion: `~` is interchangeable with user's $HOME directory
- [x] Color prompt:
  - [x] Username, hostname, current working directory
- [ ] Better redirection and piping:
  - [x] `cmd < in > out`
  - [x] `cmd > out1 flag1 flag2`
  - [x] `cmd1 | cmd2 | cmd3`
  - [x] `cmd1 | cmd2 > out1`
  - [ ] `<<`, `<<<`, redirection for `STDERR` and other file descriptors
- [x] Handle `EOF` (Ctrl-D)
- [x] Handle `SIGINT` (Ctrl-C)
  - [ ] Re-print the prompt
- [ ] Command history & navigation
- [ ] Directory history & navigation (`cd -`)
- [ ] Wildcard `*`
- [ ] Tab completion: for files and commands
- [ ] Logic operators: `&&`, `||`, `!`
- [ ] Background processes: `&`

### Bugs & Minor Enhancements
------
- [x] Fix: Segfault when exiting with EOF after using `~` expansion, redirection, or pipes
- [ ] Allow redirect and pipe symbols to be adjacent to commands or flags (not separated by space)
- [ ] Allow tilde expansion to work in conjunction with redirection e.g. `ls ~ > out`

## Function Headers
shell.h

- static void sigHandler(int signo)
  - Allows `SIGINT` to interrupt the shell's commands rather than the shell itself
- void redirect()
  - Handles the redirection (calls to `dup2`) of file descriptors
- void safe_exec()
  - Executes the command in `argv` with `execvp` and safely frees all allocated memory before exiting
- void executePipe(int pipeIndex)
  - A new child executes the first command from `argv` with `safe_exec`, writing into the pipe
  - The parent executes the rest of the command with `executeMisc` while reading out of the pipe
- void executeMisc()
  - Searches for any pipes `|` in global var `argv` and calls `executePipe` if it finds one. If not, it redirects if `parseInput` found a redirect symbol and finally calls `safe_exec`
- void execute()
  - Handles `exit` (or `quit`) and `cd` commands, otherwise forking and the new child calls `executeMisc`
- char ** parseInput(char *input, char *delim)
  - Returns a dynamically allocated char **argv of input arguments separated by `delim` and trimmed of whitespace and semicolons
  - Redirect symbols and the first argument afterwards are not added to argv. They set booleans `redir_out` and/or `redir_in` to true and the file (if valid) is stored in a global variable.
- void shell()
  - Continuously loops through the shell procedures: reading and parsing user input and then executing the commands
  - If the return value of `fgets` is null, the user has sent an EOF at the start of a line and the shell exits normally
