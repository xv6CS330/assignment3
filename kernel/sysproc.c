#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"
#include "condvar.h"
#include "bar.h"

struct barr barrier_arr[10];
struct buff buff_arr[20];
int tail = 0;
int head = 0;
struct sleeplock lock_delete;
struct sleeplock lock_insert;
struct sleeplock lock_print;

uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0)
    return -1;
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0)
    return -1;
  return wait(p);
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_getppid(void)
{
  if (myproc()->parent) return myproc()->parent->pid;
  else {
     printf("No parent found.\n");
     return 0;
  }
}

uint64
sys_yield(void)
{
  yield();
  return 0;
}

uint64
sys_getpa(void)
{
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
  return walkaddr(myproc()->pagetable, x) + (x & (PGSIZE - 1));
}

uint64
sys_forkf(void)
{
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
  return forkf(x);
}

uint64
sys_waitpid(void)
{
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    return -1;
  if(argaddr(1, &p) < 0)
    return -1;

  if (x == -1) return wait(p);
  if ((x == 0) || (x < -1)) return -1;
  return waitpid(x, p);
}

uint64
sys_ps(void)
{
   return ps();
}

uint64
sys_pinfo(void)
{
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    return -1;
  if(argaddr(1, &p) < 0)
    return -1;

  if ((x == 0) || (x < -1) || (p == 0)) return -1;
  return pinfo(x, p);
}

uint64
sys_forkp(void)
{
  int x;
  if(argint(0, &x) < 0) return -1;
  return forkp(x);
}

uint64
sys_schedpolicy(void)
{
  int x;
  if(argint(0, &x) < 0) return -1;
  return schedpolicy(x);
}

uint64
sys_barrier_alloc(void)
{
  for(int i = 0; i < 10; i++)
  {
    if(barrier_arr[i].count == -1){
      barrier_arr[i].count = 0;
      initsleeplock(&(barrier_arr[i].barr_lock), "barrier_lock");
      (barrier_arr[i].cv).cond = 0;
      return i;
    }
  }

  return -1;
}

uint64
sys_barrier(void)
{
  int barr_inst_no, barr_id, proc_nu;
  if(argint(0, &barr_inst_no) < 0) return -1;
  if(argint(1, &barr_id) < 0) return -1;
  if(argint(2, &proc_nu) < 0) return -1;

  acquiresleep(&(barrier_arr[barr_id].barr_lock));

  printf("%d: Entered barrier#%d for barrier array id %d\n", myproc()->pid, barr_inst_no, barr_id);

  barrier_arr[barr_id].count++;
  if(barrier_arr[barr_id].count == proc_nu){
    barrier_arr[barr_id].count = 0;
    cond_broadcast(&(barrier_arr[barr_id].cv));
  }
  else cond_wait(&(barrier_arr[barr_id].cv), &(barrier_arr[barr_id].barr_lock));

  printf("%d: Finished barrier#%d for barrier array id %d\n", myproc()->pid, barr_inst_no, barr_id);

  releasesleep(&(barrier_arr[barr_id].barr_lock));

  return 1;
}

uint64
sys_barrier_free(void)
{
  int i;
  if(argint(0, &i) < 0) return -1;

  barrier_arr[i].count = -1;
  return 1;
}

uint64
sys_buffer_cond_init(void)
{ 
  initsleeplock(&(lock_delete),"del");
  initsleeplock(&(lock_insert),"ins");
  initsleeplock(&(lock_print),"pri");
  for(int i = 0; i < 20; i++)
  {
    buff_arr[i].x = -1;
    buff_arr[i].full = 0;
    initsleeplock(&(buff_arr[i].buff_lock),"buff_lock");
    buff_arr[i].inserted.cond = 0;
    buff_arr[i].deleted.cond = 0;
  }
  return 1;
}

uint64
sys_cond_produce(void)
{
  int prod;
  int index_prod;
  if(argint(0, &prod) < 0) return -1;

  acquiresleep(&(lock_insert));
  index_prod = tail;
  tail=(tail+1)%20;
  releasesleep(&lock_insert);
  acquiresleep(&(buff_arr[index_prod].buff_lock));
  while(buff_arr[index_prod].full)
  {
    cond_wait(&(buff_arr[index_prod].deleted), &(buff_arr[index_prod].buff_lock));
  }
  buff_arr[index_prod].x = prod;
  buff_arr[index_prod].full = 1;
  cond_signal(&(buff_arr[index_prod].inserted));
  releasesleep(&(buff_arr[index_prod].buff_lock));

  return 1;
}

uint64
sys_cond_consume(void)
{
  int index_cons,v;
  acquiresleep(&(lock_delete));
  index_cons = head;
  head = (head+1)%20;
  releasesleep(&(lock_delete));
  acquiresleep(&(buff_arr[index_cons].buff_lock));
  while(!buff_arr[index_cons].full)
  {
    cond_wait(&(buff_arr[index_cons].inserted), &(buff_arr[index_cons].buff_lock));
  }
  v = buff_arr[index_cons].x;
  buff_arr[index_cons].full = 0;
  cond_signal(&(buff_arr[index_cons].deleted));
  releasesleep(&(buff_arr[index_cons].buff_lock));
  acquiresleep(&(lock_print));
  printf("%d ",v);
  releasesleep(&(lock_print));

  return 1;
}