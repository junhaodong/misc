#include "shell.h"

int isPipe = FALSE;
int redir_in = FALSE; // "<"
int redir_out = FALSE; // ">"
char *inFile, *inSymbol, *outFile, *outSymbol;

int f = 1; // for fork()
int status; // for wait()

char **commands; // split by `;`
char **argv; // split by ` `


static void sigHandler(int signo) {
  if (signo == SIGINT) {
    if (!f) {
      printf("\n");
      exit(EXIT_FAILURE); // success?
    }
    else {
      //printf("\n");
      //printPrompt();
    }
  }
}

void printPrompt() {
  char *cwd = 0;
  cwd = getcwd(cwd, 0);
  // Replace $HOME with '~'
  if (strstr(cwd, HOME)) {
    int homeLen = strlen(HOME);
    cwd = &cwd[homeLen-1];
    cwd[0] = '~';
  }
  char hostname[BUFFER_LEN];
  gethostname(hostname, BUFFER_LEN-1);
  printf(CYAN "%s@%s", USER, hostname);
  printf(WHITE ":");
  printf(YELLOW "%s$\n", cwd);
  printf(BLUE "><((((º> " RESET);
}

// Trim white space and ';' from *str
char * trimSpace(char *str) {
  char *tmp;
  while (isspace(*str) || *str==';')
    str++;

  if (*str) {
    tmp = str + strlen(str) - 1;
    while (tmp > str && (isspace(*tmp) || *str==';'))
      tmp--;
    *(tmp+1) = '\0';
  }
  return str;
}

void redirect() {
  int fd, oldfd;
  if (redir_out) {
    oldfd = STDOUT_FILENO;
    if (outSymbol[1]) { // ">>"
      fd = open(outFile, O_WRONLY|O_CREAT|O_APPEND, 0644);
    }
    else { // ">"
      fd = open(outFile, O_WRONLY|O_CREAT|O_TRUNC, 0644);
    }
    // Redirect
    if (fd < 0) {
      printf("ERROR: %s\n", strerror(errno));
    }
    else {
      dup2(fd, oldfd);
      close(fd);
    }
  }
  if (redir_in) { // "<"
    oldfd = STDIN_FILENO;
    fd = open(inFile, O_RDONLY, 0644);
    // Redirect
    if (fd < 0) {
      printf("ERROR: %s\n", strerror(errno));
    }
    else {
      dup2(fd, oldfd);
      close(fd);
    }
  }
}

// Execute a command; Handles errors and frees
void safe_exec() {
  execvp(argv[0], argv);
  printf("%s: command not found\n", argv[0]);
  free(argv);
  free(commands);
  exit(EXIT_FAILURE);
}

void executePipe(int pipeIndex) {
  int fd[2]; // fd[1] = write in; fd[0] = read out
  pipe(fd);
  f = fork();
  if (!f) { // Child; write in to pipe
    dup2(fd[1], STDOUT_FILENO);
    argv[pipeIndex] = NULL;
    close(fd[0]);
    close(fd[1]);
    safe_exec();
  }
  else { // Parent; read out from pipe
    wait(&status);
    dup2(fd[0], STDIN_FILENO);
    int i = 0;
    while (argv[pipeIndex+1+i]) {
      argv[i] = argv[pipeIndex+1+i];
      i++;
    }
    argv[i] = NULL;
    close(fd[0]);
    close(fd[1]);
    isPipe = FALSE;
    executeMisc();
  }
}

void executeMisc() {
  // Piping
  int pipeIndex = 0;
  while (argv[pipeIndex]) {
    if (*argv[pipeIndex] == '|') {
      isPipe = TRUE;
      break;
    }
    pipeIndex++;
  }
  if (isPipe)
    executePipe(pipeIndex); // Execute first command before continuing
  // Redirecting
  else if (redir_in || redir_out)
    redirect();
  // Execute
  safe_exec();
}

void execute(){
  // `exit` or `quit`
  if (!strcmp(argv[0], "exit") || !strcmp(argv[0], "quit")) {
    printf("Sea ya next time\n");
    free(argv);
    free(commands);
    exit(EXIT_SUCCESS);
  }
  // `cd`
  else if (!strcmp(argv[0], "cd")) {
    char *dir = argv[1];
    if (!dir)
      dir = HOME;
    if (chdir(dir) < 0)
      printf("cd: %s: %s\n", dir, strerror(errno));
  }
  else {
    f = fork();
    if (!f)
      executeMisc();
    else
      wait(&status);
  }
}

// Returns dynamically allocated memory
char ** parseInput(char *input, char *delim) {
  int maxSize = 1; // Limit of the number of tokens in argv
  int size = 0;
  char **argv = malloc(maxSize * sizeof *argv);
  char *arg = strsep(&input, delim);
  for (; arg; arg = strsep(&input, delim)) {
    // Reallocate if out of memory
    if (size == maxSize) {
      maxSize *= 2;
      argv = realloc(argv, maxSize * sizeof *argv);
    }
    // Trim white space
    arg = trimSpace(arg);
    if (*arg) {
      // Check if redirect
      if (*arg == '>') {
        redir_out = TRUE;
        outSymbol = arg;
      }
      else if (*arg == '<') {
        redir_in = TRUE;
        inSymbol = arg;
      }
      else if (redir_out && !outFile) {
        outFile = arg;
      }
      else if (redir_in && !inFile) {
        inFile = arg;
      }
      else {
        // Replace '~' with $HOME
        if (arg[0]=='~') {
          char tmp[BUFFER_LEN];
          strcpy(tmp,HOME);
          strcat(tmp,arg+1);
          strcpy(arg,tmp);
        }
        argv[size] = arg;
        size++;
      }
    }
  }
  argv[size] = NULL;
  return argv;
}

void shell() {
  char input[BUFFER_LEN];
  int count = 0;
  while (1) {
    printPrompt();
    // Exit on EOF
    if (!fgets(input, BUFFER_LEN, stdin)) {
      printf("\n");
      return;
    }
    commands = parseInput(input, ";");
    count = 0;
    // Execute each command
    while (commands[count]) {
      argv = parseInput(commands[count], " ");
      execute();
      free(argv);
      count++;
      // Reset globals
      redir_in = FALSE;
      redir_out = FALSE;
      inFile = 0;
      outFile = 0;
    }
    free(commands);
  }
}

int main() {
  signal(SIGINT, sigHandler);
  printf("Welcome to Shellfish!\n");
  shell();
  return 0;
}
