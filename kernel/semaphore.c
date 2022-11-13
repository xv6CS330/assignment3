#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"
#include "condvar.h"
#include "semaphore.h"

void sem_init (struct semaphore *s, int x){
    s->value = x;
    s->cv.cond = 0;
    initsleeplock(&(s->lock), "semaphore");
};
void sem_wait (struct semaphore *s){
    acquiresleep(&(s->lock));
    while(s->value>=0){
        cond_wait(&(s->cv), &(s->lock));
    }
    s->value--;
    releasesleep(&(s->lock));
};
void sem_post (struct semaphore *s){
    acquiresleep(&(s->lock));
    s->value++;
    cond_signal(&(s->cv));
    releasesleep(&(s->lock));
};