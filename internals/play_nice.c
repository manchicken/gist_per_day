#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>

#define SECONDS 1

int did_alarm;

void trap_alarm(int signum);

void demo(int nice, int seconds);

int main() {
  signal(SIGALRM, trap_alarm);
  
  demo( -10, SECONDS );
  demo(  -5, SECONDS );
  demo(   0, SECONDS );
  demo(   5, SECONDS );
  demo(  10, SECONDS );
}

void trap_alarm(int signum) {
  did_alarm = 1;
}

void demo(int nice, int seconds) {
  did_alarm = 0;
  char op_pad[5];
  memset(op_pad,'\0', sizeof(op_pad));
  
  long long counter = 0;
  long int next_op = 2;
  
  alarm(seconds);
  while (!did_alarm) {
    sprintf(op_pad, "%ld", next_op);
    next_op = strtol(op_pad, NULL, 10);
    
    counter += next_op;
    
    switch (next_op) {
      case 2:
        next_op = -1;
        break;
      default:
        next_op = 2;
    }
  }
  printf("With a nice of %+.2d, we have counted to %lld in %d seconds.\n", nice, counter, seconds);
  sleep(1);
  
  return;
}

