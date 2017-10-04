#ifndef SHELL_H
#define SHELL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>

#define TRUE 1
#define FALSE 0

#define HOME getenv("HOME")
#define USER getenv("USER")
#define BUFFER_LEN 512

#define RESET   "\x1B[0m"
#define RED     "\x1B[31m"
#define GREEN   "\x1B[32m"
#define YELLOW  "\x1B[33m"
#define BLUE    "\x1B[34m"
#define MAGENTA "\x1B[35m"
#define CYAN    "\x1B[36m"
#define WHITE   "\x1B[37m"

static void sigHandler(int signo);
void printPrompt();
char * trimSpace(char *str);
void redirect();
void safe_exec();
void executePipe(int pipeIndex);
void executeMisc();
void execute();
char ** parseInput(char *input, char *delim);
void shell();

#endif
