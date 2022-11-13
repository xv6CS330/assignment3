
user/_condprodconstest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
   6:	87aa                	mv	a5,a0
   8:	0585                	addi	a1,a1,1
   a:	0785                	addi	a5,a5,1
   c:	fff5c703          	lbu	a4,-1(a1)
  10:	fee78fa3          	sb	a4,-1(a5)
  14:	fb75                	bnez	a4,8 <strcpy+0x8>
    ;
  return os;
}
  16:	6422                	ld	s0,8(sp)
  18:	0141                	addi	sp,sp,16
  1a:	8082                	ret

000000000000001c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  1c:	1141                	addi	sp,sp,-16
  1e:	e422                	sd	s0,8(sp)
  20:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  22:	00054783          	lbu	a5,0(a0)
  26:	cb91                	beqz	a5,3a <strcmp+0x1e>
  28:	0005c703          	lbu	a4,0(a1)
  2c:	00f71763          	bne	a4,a5,3a <strcmp+0x1e>
    p++, q++;
  30:	0505                	addi	a0,a0,1
  32:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  34:	00054783          	lbu	a5,0(a0)
  38:	fbe5                	bnez	a5,28 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  3a:	0005c503          	lbu	a0,0(a1)
}
  3e:	40a7853b          	subw	a0,a5,a0
  42:	6422                	ld	s0,8(sp)
  44:	0141                	addi	sp,sp,16
  46:	8082                	ret

0000000000000048 <strlen>:

uint
strlen(const char *s)
{
  48:	1141                	addi	sp,sp,-16
  4a:	e422                	sd	s0,8(sp)
  4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  4e:	00054783          	lbu	a5,0(a0)
  52:	cf91                	beqz	a5,6e <strlen+0x26>
  54:	0505                	addi	a0,a0,1
  56:	87aa                	mv	a5,a0
  58:	4685                	li	a3,1
  5a:	9e89                	subw	a3,a3,a0
  5c:	00f6853b          	addw	a0,a3,a5
  60:	0785                	addi	a5,a5,1
  62:	fff7c703          	lbu	a4,-1(a5)
  66:	fb7d                	bnez	a4,5c <strlen+0x14>
    ;
  return n;
}
  68:	6422                	ld	s0,8(sp)
  6a:	0141                	addi	sp,sp,16
  6c:	8082                	ret
  for(n = 0; s[n]; n++)
  6e:	4501                	li	a0,0
  70:	bfe5                	j	68 <strlen+0x20>

0000000000000072 <memset>:

void*
memset(void *dst, int c, uint n)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  78:	ce09                	beqz	a2,92 <memset+0x20>
  7a:	87aa                	mv	a5,a0
  7c:	fff6071b          	addiw	a4,a2,-1
  80:	1702                	slli	a4,a4,0x20
  82:	9301                	srli	a4,a4,0x20
  84:	0705                	addi	a4,a4,1
  86:	972a                	add	a4,a4,a0
    cdst[i] = c;
  88:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  8c:	0785                	addi	a5,a5,1
  8e:	fee79de3          	bne	a5,a4,88 <memset+0x16>
  }
  return dst;
}
  92:	6422                	ld	s0,8(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret

0000000000000098 <strchr>:

char*
strchr(const char *s, char c)
{
  98:	1141                	addi	sp,sp,-16
  9a:	e422                	sd	s0,8(sp)
  9c:	0800                	addi	s0,sp,16
  for(; *s; s++)
  9e:	00054783          	lbu	a5,0(a0)
  a2:	cb99                	beqz	a5,b8 <strchr+0x20>
    if(*s == c)
  a4:	00f58763          	beq	a1,a5,b2 <strchr+0x1a>
  for(; *s; s++)
  a8:	0505                	addi	a0,a0,1
  aa:	00054783          	lbu	a5,0(a0)
  ae:	fbfd                	bnez	a5,a4 <strchr+0xc>
      return (char*)s;
  return 0;
  b0:	4501                	li	a0,0
}
  b2:	6422                	ld	s0,8(sp)
  b4:	0141                	addi	sp,sp,16
  b6:	8082                	ret
  return 0;
  b8:	4501                	li	a0,0
  ba:	bfe5                	j	b2 <strchr+0x1a>

00000000000000bc <gets>:

char*
gets(char *buf, int max)
{
  bc:	711d                	addi	sp,sp,-96
  be:	ec86                	sd	ra,88(sp)
  c0:	e8a2                	sd	s0,80(sp)
  c2:	e4a6                	sd	s1,72(sp)
  c4:	e0ca                	sd	s2,64(sp)
  c6:	fc4e                	sd	s3,56(sp)
  c8:	f852                	sd	s4,48(sp)
  ca:	f456                	sd	s5,40(sp)
  cc:	f05a                	sd	s6,32(sp)
  ce:	ec5e                	sd	s7,24(sp)
  d0:	1080                	addi	s0,sp,96
  d2:	8baa                	mv	s7,a0
  d4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  d6:	892a                	mv	s2,a0
  d8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
  da:	4aa9                	li	s5,10
  dc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
  de:	89a6                	mv	s3,s1
  e0:	2485                	addiw	s1,s1,1
  e2:	0344d863          	bge	s1,s4,112 <gets+0x56>
    cc = read(0, &c, 1);
  e6:	4605                	li	a2,1
  e8:	faf40593          	addi	a1,s0,-81
  ec:	4501                	li	a0,0
  ee:	00000097          	auipc	ra,0x0
  f2:	1a0080e7          	jalr	416(ra) # 28e <read>
    if(cc < 1)
  f6:	00a05e63          	blez	a0,112 <gets+0x56>
    buf[i++] = c;
  fa:	faf44783          	lbu	a5,-81(s0)
  fe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 102:	01578763          	beq	a5,s5,110 <gets+0x54>
 106:	0905                	addi	s2,s2,1
 108:	fd679be3          	bne	a5,s6,de <gets+0x22>
  for(i=0; i+1 < max; ){
 10c:	89a6                	mv	s3,s1
 10e:	a011                	j	112 <gets+0x56>
 110:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 112:	99de                	add	s3,s3,s7
 114:	00098023          	sb	zero,0(s3)
  return buf;
}
 118:	855e                	mv	a0,s7
 11a:	60e6                	ld	ra,88(sp)
 11c:	6446                	ld	s0,80(sp)
 11e:	64a6                	ld	s1,72(sp)
 120:	6906                	ld	s2,64(sp)
 122:	79e2                	ld	s3,56(sp)
 124:	7a42                	ld	s4,48(sp)
 126:	7aa2                	ld	s5,40(sp)
 128:	7b02                	ld	s6,32(sp)
 12a:	6be2                	ld	s7,24(sp)
 12c:	6125                	addi	sp,sp,96
 12e:	8082                	ret

0000000000000130 <stat>:

int
stat(const char *n, struct stat *st)
{
 130:	1101                	addi	sp,sp,-32
 132:	ec06                	sd	ra,24(sp)
 134:	e822                	sd	s0,16(sp)
 136:	e426                	sd	s1,8(sp)
 138:	e04a                	sd	s2,0(sp)
 13a:	1000                	addi	s0,sp,32
 13c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 13e:	4581                	li	a1,0
 140:	00000097          	auipc	ra,0x0
 144:	176080e7          	jalr	374(ra) # 2b6 <open>
  if(fd < 0)
 148:	02054563          	bltz	a0,172 <stat+0x42>
 14c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 14e:	85ca                	mv	a1,s2
 150:	00000097          	auipc	ra,0x0
 154:	17e080e7          	jalr	382(ra) # 2ce <fstat>
 158:	892a                	mv	s2,a0
  close(fd);
 15a:	8526                	mv	a0,s1
 15c:	00000097          	auipc	ra,0x0
 160:	142080e7          	jalr	322(ra) # 29e <close>
  return r;
}
 164:	854a                	mv	a0,s2
 166:	60e2                	ld	ra,24(sp)
 168:	6442                	ld	s0,16(sp)
 16a:	64a2                	ld	s1,8(sp)
 16c:	6902                	ld	s2,0(sp)
 16e:	6105                	addi	sp,sp,32
 170:	8082                	ret
    return -1;
 172:	597d                	li	s2,-1
 174:	bfc5                	j	164 <stat+0x34>

0000000000000176 <atoi>:

int
atoi(const char *s)
{
 176:	1141                	addi	sp,sp,-16
 178:	e422                	sd	s0,8(sp)
 17a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 17c:	00054603          	lbu	a2,0(a0)
 180:	fd06079b          	addiw	a5,a2,-48
 184:	0ff7f793          	andi	a5,a5,255
 188:	4725                	li	a4,9
 18a:	02f76963          	bltu	a4,a5,1bc <atoi+0x46>
 18e:	86aa                	mv	a3,a0
  n = 0;
 190:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 192:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 194:	0685                	addi	a3,a3,1
 196:	0025179b          	slliw	a5,a0,0x2
 19a:	9fa9                	addw	a5,a5,a0
 19c:	0017979b          	slliw	a5,a5,0x1
 1a0:	9fb1                	addw	a5,a5,a2
 1a2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1a6:	0006c603          	lbu	a2,0(a3)
 1aa:	fd06071b          	addiw	a4,a2,-48
 1ae:	0ff77713          	andi	a4,a4,255
 1b2:	fee5f1e3          	bgeu	a1,a4,194 <atoi+0x1e>
  return n;
}
 1b6:	6422                	ld	s0,8(sp)
 1b8:	0141                	addi	sp,sp,16
 1ba:	8082                	ret
  n = 0;
 1bc:	4501                	li	a0,0
 1be:	bfe5                	j	1b6 <atoi+0x40>

00000000000001c0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1c6:	02b57663          	bgeu	a0,a1,1f2 <memmove+0x32>
    while(n-- > 0)
 1ca:	02c05163          	blez	a2,1ec <memmove+0x2c>
 1ce:	fff6079b          	addiw	a5,a2,-1
 1d2:	1782                	slli	a5,a5,0x20
 1d4:	9381                	srli	a5,a5,0x20
 1d6:	0785                	addi	a5,a5,1
 1d8:	97aa                	add	a5,a5,a0
  dst = vdst;
 1da:	872a                	mv	a4,a0
      *dst++ = *src++;
 1dc:	0585                	addi	a1,a1,1
 1de:	0705                	addi	a4,a4,1
 1e0:	fff5c683          	lbu	a3,-1(a1)
 1e4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 1e8:	fee79ae3          	bne	a5,a4,1dc <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret
    dst += n;
 1f2:	00c50733          	add	a4,a0,a2
    src += n;
 1f6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 1f8:	fec05ae3          	blez	a2,1ec <memmove+0x2c>
 1fc:	fff6079b          	addiw	a5,a2,-1
 200:	1782                	slli	a5,a5,0x20
 202:	9381                	srli	a5,a5,0x20
 204:	fff7c793          	not	a5,a5
 208:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 20a:	15fd                	addi	a1,a1,-1
 20c:	177d                	addi	a4,a4,-1
 20e:	0005c683          	lbu	a3,0(a1)
 212:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 216:	fee79ae3          	bne	a5,a4,20a <memmove+0x4a>
 21a:	bfc9                	j	1ec <memmove+0x2c>

000000000000021c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 222:	ca05                	beqz	a2,252 <memcmp+0x36>
 224:	fff6069b          	addiw	a3,a2,-1
 228:	1682                	slli	a3,a3,0x20
 22a:	9281                	srli	a3,a3,0x20
 22c:	0685                	addi	a3,a3,1
 22e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 230:	00054783          	lbu	a5,0(a0)
 234:	0005c703          	lbu	a4,0(a1)
 238:	00e79863          	bne	a5,a4,248 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 23c:	0505                	addi	a0,a0,1
    p2++;
 23e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 240:	fed518e3          	bne	a0,a3,230 <memcmp+0x14>
  }
  return 0;
 244:	4501                	li	a0,0
 246:	a019                	j	24c <memcmp+0x30>
      return *p1 - *p2;
 248:	40e7853b          	subw	a0,a5,a4
}
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret
  return 0;
 252:	4501                	li	a0,0
 254:	bfe5                	j	24c <memcmp+0x30>

0000000000000256 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 256:	1141                	addi	sp,sp,-16
 258:	e406                	sd	ra,8(sp)
 25a:	e022                	sd	s0,0(sp)
 25c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 25e:	00000097          	auipc	ra,0x0
 262:	f62080e7          	jalr	-158(ra) # 1c0 <memmove>
}
 266:	60a2                	ld	ra,8(sp)
 268:	6402                	ld	s0,0(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret

000000000000026e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 26e:	4885                	li	a7,1
 ecall
 270:	00000073          	ecall
 ret
 274:	8082                	ret

0000000000000276 <exit>:
.global exit
exit:
 li a7, SYS_exit
 276:	4889                	li	a7,2
 ecall
 278:	00000073          	ecall
 ret
 27c:	8082                	ret

000000000000027e <wait>:
.global wait
wait:
 li a7, SYS_wait
 27e:	488d                	li	a7,3
 ecall
 280:	00000073          	ecall
 ret
 284:	8082                	ret

0000000000000286 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 286:	4891                	li	a7,4
 ecall
 288:	00000073          	ecall
 ret
 28c:	8082                	ret

000000000000028e <read>:
.global read
read:
 li a7, SYS_read
 28e:	4895                	li	a7,5
 ecall
 290:	00000073          	ecall
 ret
 294:	8082                	ret

0000000000000296 <write>:
.global write
write:
 li a7, SYS_write
 296:	48c1                	li	a7,16
 ecall
 298:	00000073          	ecall
 ret
 29c:	8082                	ret

000000000000029e <close>:
.global close
close:
 li a7, SYS_close
 29e:	48d5                	li	a7,21
 ecall
 2a0:	00000073          	ecall
 ret
 2a4:	8082                	ret

00000000000002a6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2a6:	4899                	li	a7,6
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ae:	489d                	li	a7,7
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <open>:
.global open
open:
 li a7, SYS_open
 2b6:	48bd                	li	a7,15
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2be:	48c5                	li	a7,17
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2c6:	48c9                	li	a7,18
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2ce:	48a1                	li	a7,8
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <link>:
.global link
link:
 li a7, SYS_link
 2d6:	48cd                	li	a7,19
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2de:	48d1                	li	a7,20
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2e6:	48a5                	li	a7,9
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <dup>:
.global dup
dup:
 li a7, SYS_dup
 2ee:	48a9                	li	a7,10
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 2f6:	48ad                	li	a7,11
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 2fe:	48b1                	li	a7,12
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 306:	48b5                	li	a7,13
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 30e:	48b9                	li	a7,14
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 316:	48d9                	li	a7,22
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <yield>:
.global yield
yield:
 li a7, SYS_yield
 31e:	48dd                	li	a7,23
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 326:	48e1                	li	a7,24
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 32e:	48e5                	li	a7,25
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 336:	48e9                	li	a7,26
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <ps>:
.global ps
ps:
 li a7, SYS_ps
 33e:	48ed                	li	a7,27
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 346:	48f1                	li	a7,28
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 34e:	48f5                	li	a7,29
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 356:	48f9                	li	a7,30
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 35e:	48fd                	li	a7,31
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 366:	02000893          	li	a7,32
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 370:	02100893          	li	a7,33
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 37a:	1101                	addi	sp,sp,-32
 37c:	ec06                	sd	ra,24(sp)
 37e:	e822                	sd	s0,16(sp)
 380:	1000                	addi	s0,sp,32
 382:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 386:	4605                	li	a2,1
 388:	fef40593          	addi	a1,s0,-17
 38c:	00000097          	auipc	ra,0x0
 390:	f0a080e7          	jalr	-246(ra) # 296 <write>
}
 394:	60e2                	ld	ra,24(sp)
 396:	6442                	ld	s0,16(sp)
 398:	6105                	addi	sp,sp,32
 39a:	8082                	ret

000000000000039c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 39c:	7139                	addi	sp,sp,-64
 39e:	fc06                	sd	ra,56(sp)
 3a0:	f822                	sd	s0,48(sp)
 3a2:	f426                	sd	s1,40(sp)
 3a4:	f04a                	sd	s2,32(sp)
 3a6:	ec4e                	sd	s3,24(sp)
 3a8:	0080                	addi	s0,sp,64
 3aa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ac:	c299                	beqz	a3,3b2 <printint+0x16>
 3ae:	0805c863          	bltz	a1,43e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3b2:	2581                	sext.w	a1,a1
  neg = 0;
 3b4:	4881                	li	a7,0
 3b6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ba:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3bc:	2601                	sext.w	a2,a2
 3be:	00000517          	auipc	a0,0x0
 3c2:	44250513          	addi	a0,a0,1090 # 800 <digits>
 3c6:	883a                	mv	a6,a4
 3c8:	2705                	addiw	a4,a4,1
 3ca:	02c5f7bb          	remuw	a5,a1,a2
 3ce:	1782                	slli	a5,a5,0x20
 3d0:	9381                	srli	a5,a5,0x20
 3d2:	97aa                	add	a5,a5,a0
 3d4:	0007c783          	lbu	a5,0(a5)
 3d8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3dc:	0005879b          	sext.w	a5,a1
 3e0:	02c5d5bb          	divuw	a1,a1,a2
 3e4:	0685                	addi	a3,a3,1
 3e6:	fec7f0e3          	bgeu	a5,a2,3c6 <printint+0x2a>
  if(neg)
 3ea:	00088b63          	beqz	a7,400 <printint+0x64>
    buf[i++] = '-';
 3ee:	fd040793          	addi	a5,s0,-48
 3f2:	973e                	add	a4,a4,a5
 3f4:	02d00793          	li	a5,45
 3f8:	fef70823          	sb	a5,-16(a4)
 3fc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 400:	02e05863          	blez	a4,430 <printint+0x94>
 404:	fc040793          	addi	a5,s0,-64
 408:	00e78933          	add	s2,a5,a4
 40c:	fff78993          	addi	s3,a5,-1
 410:	99ba                	add	s3,s3,a4
 412:	377d                	addiw	a4,a4,-1
 414:	1702                	slli	a4,a4,0x20
 416:	9301                	srli	a4,a4,0x20
 418:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 41c:	fff94583          	lbu	a1,-1(s2)
 420:	8526                	mv	a0,s1
 422:	00000097          	auipc	ra,0x0
 426:	f58080e7          	jalr	-168(ra) # 37a <putc>
  while(--i >= 0)
 42a:	197d                	addi	s2,s2,-1
 42c:	ff3918e3          	bne	s2,s3,41c <printint+0x80>
}
 430:	70e2                	ld	ra,56(sp)
 432:	7442                	ld	s0,48(sp)
 434:	74a2                	ld	s1,40(sp)
 436:	7902                	ld	s2,32(sp)
 438:	69e2                	ld	s3,24(sp)
 43a:	6121                	addi	sp,sp,64
 43c:	8082                	ret
    x = -xx;
 43e:	40b005bb          	negw	a1,a1
    neg = 1;
 442:	4885                	li	a7,1
    x = -xx;
 444:	bf8d                	j	3b6 <printint+0x1a>

0000000000000446 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 446:	7119                	addi	sp,sp,-128
 448:	fc86                	sd	ra,120(sp)
 44a:	f8a2                	sd	s0,112(sp)
 44c:	f4a6                	sd	s1,104(sp)
 44e:	f0ca                	sd	s2,96(sp)
 450:	ecce                	sd	s3,88(sp)
 452:	e8d2                	sd	s4,80(sp)
 454:	e4d6                	sd	s5,72(sp)
 456:	e0da                	sd	s6,64(sp)
 458:	fc5e                	sd	s7,56(sp)
 45a:	f862                	sd	s8,48(sp)
 45c:	f466                	sd	s9,40(sp)
 45e:	f06a                	sd	s10,32(sp)
 460:	ec6e                	sd	s11,24(sp)
 462:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 464:	0005c903          	lbu	s2,0(a1)
 468:	18090f63          	beqz	s2,606 <vprintf+0x1c0>
 46c:	8aaa                	mv	s5,a0
 46e:	8b32                	mv	s6,a2
 470:	00158493          	addi	s1,a1,1
  state = 0;
 474:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 476:	02500a13          	li	s4,37
      if(c == 'd'){
 47a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 47e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 482:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 486:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 48a:	00000b97          	auipc	s7,0x0
 48e:	376b8b93          	addi	s7,s7,886 # 800 <digits>
 492:	a839                	j	4b0 <vprintf+0x6a>
        putc(fd, c);
 494:	85ca                	mv	a1,s2
 496:	8556                	mv	a0,s5
 498:	00000097          	auipc	ra,0x0
 49c:	ee2080e7          	jalr	-286(ra) # 37a <putc>
 4a0:	a019                	j	4a6 <vprintf+0x60>
    } else if(state == '%'){
 4a2:	01498f63          	beq	s3,s4,4c0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4a6:	0485                	addi	s1,s1,1
 4a8:	fff4c903          	lbu	s2,-1(s1)
 4ac:	14090d63          	beqz	s2,606 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4b0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4b4:	fe0997e3          	bnez	s3,4a2 <vprintf+0x5c>
      if(c == '%'){
 4b8:	fd479ee3          	bne	a5,s4,494 <vprintf+0x4e>
        state = '%';
 4bc:	89be                	mv	s3,a5
 4be:	b7e5                	j	4a6 <vprintf+0x60>
      if(c == 'd'){
 4c0:	05878063          	beq	a5,s8,500 <vprintf+0xba>
      } else if(c == 'l') {
 4c4:	05978c63          	beq	a5,s9,51c <vprintf+0xd6>
      } else if(c == 'x') {
 4c8:	07a78863          	beq	a5,s10,538 <vprintf+0xf2>
      } else if(c == 'p') {
 4cc:	09b78463          	beq	a5,s11,554 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4d0:	07300713          	li	a4,115
 4d4:	0ce78663          	beq	a5,a4,5a0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4d8:	06300713          	li	a4,99
 4dc:	0ee78e63          	beq	a5,a4,5d8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4e0:	11478863          	beq	a5,s4,5f0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4e4:	85d2                	mv	a1,s4
 4e6:	8556                	mv	a0,s5
 4e8:	00000097          	auipc	ra,0x0
 4ec:	e92080e7          	jalr	-366(ra) # 37a <putc>
        putc(fd, c);
 4f0:	85ca                	mv	a1,s2
 4f2:	8556                	mv	a0,s5
 4f4:	00000097          	auipc	ra,0x0
 4f8:	e86080e7          	jalr	-378(ra) # 37a <putc>
      }
      state = 0;
 4fc:	4981                	li	s3,0
 4fe:	b765                	j	4a6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 500:	008b0913          	addi	s2,s6,8
 504:	4685                	li	a3,1
 506:	4629                	li	a2,10
 508:	000b2583          	lw	a1,0(s6)
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	e8e080e7          	jalr	-370(ra) # 39c <printint>
 516:	8b4a                	mv	s6,s2
      state = 0;
 518:	4981                	li	s3,0
 51a:	b771                	j	4a6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 51c:	008b0913          	addi	s2,s6,8
 520:	4681                	li	a3,0
 522:	4629                	li	a2,10
 524:	000b2583          	lw	a1,0(s6)
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	e72080e7          	jalr	-398(ra) # 39c <printint>
 532:	8b4a                	mv	s6,s2
      state = 0;
 534:	4981                	li	s3,0
 536:	bf85                	j	4a6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 538:	008b0913          	addi	s2,s6,8
 53c:	4681                	li	a3,0
 53e:	4641                	li	a2,16
 540:	000b2583          	lw	a1,0(s6)
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	e56080e7          	jalr	-426(ra) # 39c <printint>
 54e:	8b4a                	mv	s6,s2
      state = 0;
 550:	4981                	li	s3,0
 552:	bf91                	j	4a6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 554:	008b0793          	addi	a5,s6,8
 558:	f8f43423          	sd	a5,-120(s0)
 55c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 560:	03000593          	li	a1,48
 564:	8556                	mv	a0,s5
 566:	00000097          	auipc	ra,0x0
 56a:	e14080e7          	jalr	-492(ra) # 37a <putc>
  putc(fd, 'x');
 56e:	85ea                	mv	a1,s10
 570:	8556                	mv	a0,s5
 572:	00000097          	auipc	ra,0x0
 576:	e08080e7          	jalr	-504(ra) # 37a <putc>
 57a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 57c:	03c9d793          	srli	a5,s3,0x3c
 580:	97de                	add	a5,a5,s7
 582:	0007c583          	lbu	a1,0(a5)
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	df2080e7          	jalr	-526(ra) # 37a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 590:	0992                	slli	s3,s3,0x4
 592:	397d                	addiw	s2,s2,-1
 594:	fe0914e3          	bnez	s2,57c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 598:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 59c:	4981                	li	s3,0
 59e:	b721                	j	4a6 <vprintf+0x60>
        s = va_arg(ap, char*);
 5a0:	008b0993          	addi	s3,s6,8
 5a4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5a8:	02090163          	beqz	s2,5ca <vprintf+0x184>
        while(*s != 0){
 5ac:	00094583          	lbu	a1,0(s2)
 5b0:	c9a1                	beqz	a1,600 <vprintf+0x1ba>
          putc(fd, *s);
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	dc6080e7          	jalr	-570(ra) # 37a <putc>
          s++;
 5bc:	0905                	addi	s2,s2,1
        while(*s != 0){
 5be:	00094583          	lbu	a1,0(s2)
 5c2:	f9e5                	bnez	a1,5b2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5c4:	8b4e                	mv	s6,s3
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bdf9                	j	4a6 <vprintf+0x60>
          s = "(null)";
 5ca:	00000917          	auipc	s2,0x0
 5ce:	22e90913          	addi	s2,s2,558 # 7f8 <malloc+0xe8>
        while(*s != 0){
 5d2:	02800593          	li	a1,40
 5d6:	bff1                	j	5b2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5d8:	008b0913          	addi	s2,s6,8
 5dc:	000b4583          	lbu	a1,0(s6)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	d98080e7          	jalr	-616(ra) # 37a <putc>
 5ea:	8b4a                	mv	s6,s2
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	bd65                	j	4a6 <vprintf+0x60>
        putc(fd, c);
 5f0:	85d2                	mv	a1,s4
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	d86080e7          	jalr	-634(ra) # 37a <putc>
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b565                	j	4a6 <vprintf+0x60>
        s = va_arg(ap, char*);
 600:	8b4e                	mv	s6,s3
      state = 0;
 602:	4981                	li	s3,0
 604:	b54d                	j	4a6 <vprintf+0x60>
    }
  }
}
 606:	70e6                	ld	ra,120(sp)
 608:	7446                	ld	s0,112(sp)
 60a:	74a6                	ld	s1,104(sp)
 60c:	7906                	ld	s2,96(sp)
 60e:	69e6                	ld	s3,88(sp)
 610:	6a46                	ld	s4,80(sp)
 612:	6aa6                	ld	s5,72(sp)
 614:	6b06                	ld	s6,64(sp)
 616:	7be2                	ld	s7,56(sp)
 618:	7c42                	ld	s8,48(sp)
 61a:	7ca2                	ld	s9,40(sp)
 61c:	7d02                	ld	s10,32(sp)
 61e:	6de2                	ld	s11,24(sp)
 620:	6109                	addi	sp,sp,128
 622:	8082                	ret

0000000000000624 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 624:	715d                	addi	sp,sp,-80
 626:	ec06                	sd	ra,24(sp)
 628:	e822                	sd	s0,16(sp)
 62a:	1000                	addi	s0,sp,32
 62c:	e010                	sd	a2,0(s0)
 62e:	e414                	sd	a3,8(s0)
 630:	e818                	sd	a4,16(s0)
 632:	ec1c                	sd	a5,24(s0)
 634:	03043023          	sd	a6,32(s0)
 638:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 63c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 640:	8622                	mv	a2,s0
 642:	00000097          	auipc	ra,0x0
 646:	e04080e7          	jalr	-508(ra) # 446 <vprintf>
}
 64a:	60e2                	ld	ra,24(sp)
 64c:	6442                	ld	s0,16(sp)
 64e:	6161                	addi	sp,sp,80
 650:	8082                	ret

0000000000000652 <printf>:

void
printf(const char *fmt, ...)
{
 652:	711d                	addi	sp,sp,-96
 654:	ec06                	sd	ra,24(sp)
 656:	e822                	sd	s0,16(sp)
 658:	1000                	addi	s0,sp,32
 65a:	e40c                	sd	a1,8(s0)
 65c:	e810                	sd	a2,16(s0)
 65e:	ec14                	sd	a3,24(s0)
 660:	f018                	sd	a4,32(s0)
 662:	f41c                	sd	a5,40(s0)
 664:	03043823          	sd	a6,48(s0)
 668:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 66c:	00840613          	addi	a2,s0,8
 670:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 674:	85aa                	mv	a1,a0
 676:	4505                	li	a0,1
 678:	00000097          	auipc	ra,0x0
 67c:	dce080e7          	jalr	-562(ra) # 446 <vprintf>
}
 680:	60e2                	ld	ra,24(sp)
 682:	6442                	ld	s0,16(sp)
 684:	6125                	addi	sp,sp,96
 686:	8082                	ret

0000000000000688 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 688:	1141                	addi	sp,sp,-16
 68a:	e422                	sd	s0,8(sp)
 68c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 68e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 692:	00000797          	auipc	a5,0x0
 696:	1867b783          	ld	a5,390(a5) # 818 <freep>
 69a:	a805                	j	6ca <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 69c:	4618                	lw	a4,8(a2)
 69e:	9db9                	addw	a1,a1,a4
 6a0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a4:	6398                	ld	a4,0(a5)
 6a6:	6318                	ld	a4,0(a4)
 6a8:	fee53823          	sd	a4,-16(a0)
 6ac:	a091                	j	6f0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ae:	ff852703          	lw	a4,-8(a0)
 6b2:	9e39                	addw	a2,a2,a4
 6b4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6b6:	ff053703          	ld	a4,-16(a0)
 6ba:	e398                	sd	a4,0(a5)
 6bc:	a099                	j	702 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6be:	6398                	ld	a4,0(a5)
 6c0:	00e7e463          	bltu	a5,a4,6c8 <free+0x40>
 6c4:	00e6ea63          	bltu	a3,a4,6d8 <free+0x50>
{
 6c8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ca:	fed7fae3          	bgeu	a5,a3,6be <free+0x36>
 6ce:	6398                	ld	a4,0(a5)
 6d0:	00e6e463          	bltu	a3,a4,6d8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d4:	fee7eae3          	bltu	a5,a4,6c8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6d8:	ff852583          	lw	a1,-8(a0)
 6dc:	6390                	ld	a2,0(a5)
 6de:	02059713          	slli	a4,a1,0x20
 6e2:	9301                	srli	a4,a4,0x20
 6e4:	0712                	slli	a4,a4,0x4
 6e6:	9736                	add	a4,a4,a3
 6e8:	fae60ae3          	beq	a2,a4,69c <free+0x14>
    bp->s.ptr = p->s.ptr;
 6ec:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6f0:	4790                	lw	a2,8(a5)
 6f2:	02061713          	slli	a4,a2,0x20
 6f6:	9301                	srli	a4,a4,0x20
 6f8:	0712                	slli	a4,a4,0x4
 6fa:	973e                	add	a4,a4,a5
 6fc:	fae689e3          	beq	a3,a4,6ae <free+0x26>
  } else
    p->s.ptr = bp;
 700:	e394                	sd	a3,0(a5)
  freep = p;
 702:	00000717          	auipc	a4,0x0
 706:	10f73b23          	sd	a5,278(a4) # 818 <freep>
}
 70a:	6422                	ld	s0,8(sp)
 70c:	0141                	addi	sp,sp,16
 70e:	8082                	ret

0000000000000710 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 710:	7139                	addi	sp,sp,-64
 712:	fc06                	sd	ra,56(sp)
 714:	f822                	sd	s0,48(sp)
 716:	f426                	sd	s1,40(sp)
 718:	f04a                	sd	s2,32(sp)
 71a:	ec4e                	sd	s3,24(sp)
 71c:	e852                	sd	s4,16(sp)
 71e:	e456                	sd	s5,8(sp)
 720:	e05a                	sd	s6,0(sp)
 722:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 724:	02051493          	slli	s1,a0,0x20
 728:	9081                	srli	s1,s1,0x20
 72a:	04bd                	addi	s1,s1,15
 72c:	8091                	srli	s1,s1,0x4
 72e:	0014899b          	addiw	s3,s1,1
 732:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 734:	00000517          	auipc	a0,0x0
 738:	0e453503          	ld	a0,228(a0) # 818 <freep>
 73c:	c515                	beqz	a0,768 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 73e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 740:	4798                	lw	a4,8(a5)
 742:	02977f63          	bgeu	a4,s1,780 <malloc+0x70>
 746:	8a4e                	mv	s4,s3
 748:	0009871b          	sext.w	a4,s3
 74c:	6685                	lui	a3,0x1
 74e:	00d77363          	bgeu	a4,a3,754 <malloc+0x44>
 752:	6a05                	lui	s4,0x1
 754:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 758:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 75c:	00000917          	auipc	s2,0x0
 760:	0bc90913          	addi	s2,s2,188 # 818 <freep>
  if(p == (char*)-1)
 764:	5afd                	li	s5,-1
 766:	a88d                	j	7d8 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 768:	00000797          	auipc	a5,0x0
 76c:	0b878793          	addi	a5,a5,184 # 820 <base>
 770:	00000717          	auipc	a4,0x0
 774:	0af73423          	sd	a5,168(a4) # 818 <freep>
 778:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 77a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 77e:	b7e1                	j	746 <malloc+0x36>
      if(p->s.size == nunits)
 780:	02e48b63          	beq	s1,a4,7b6 <malloc+0xa6>
        p->s.size -= nunits;
 784:	4137073b          	subw	a4,a4,s3
 788:	c798                	sw	a4,8(a5)
        p += p->s.size;
 78a:	1702                	slli	a4,a4,0x20
 78c:	9301                	srli	a4,a4,0x20
 78e:	0712                	slli	a4,a4,0x4
 790:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 792:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 796:	00000717          	auipc	a4,0x0
 79a:	08a73123          	sd	a0,130(a4) # 818 <freep>
      return (void*)(p + 1);
 79e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7a2:	70e2                	ld	ra,56(sp)
 7a4:	7442                	ld	s0,48(sp)
 7a6:	74a2                	ld	s1,40(sp)
 7a8:	7902                	ld	s2,32(sp)
 7aa:	69e2                	ld	s3,24(sp)
 7ac:	6a42                	ld	s4,16(sp)
 7ae:	6aa2                	ld	s5,8(sp)
 7b0:	6b02                	ld	s6,0(sp)
 7b2:	6121                	addi	sp,sp,64
 7b4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7b6:	6398                	ld	a4,0(a5)
 7b8:	e118                	sd	a4,0(a0)
 7ba:	bff1                	j	796 <malloc+0x86>
  hp->s.size = nu;
 7bc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7c0:	0541                	addi	a0,a0,16
 7c2:	00000097          	auipc	ra,0x0
 7c6:	ec6080e7          	jalr	-314(ra) # 688 <free>
  return freep;
 7ca:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7ce:	d971                	beqz	a0,7a2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d2:	4798                	lw	a4,8(a5)
 7d4:	fa9776e3          	bgeu	a4,s1,780 <malloc+0x70>
    if(p == freep)
 7d8:	00093703          	ld	a4,0(s2)
 7dc:	853e                	mv	a0,a5
 7de:	fef719e3          	bne	a4,a5,7d0 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7e2:	8552                	mv	a0,s4
 7e4:	00000097          	auipc	ra,0x0
 7e8:	b1a080e7          	jalr	-1254(ra) # 2fe <sbrk>
  if(p == (char*)-1)
 7ec:	fd5518e3          	bne	a0,s5,7bc <malloc+0xac>
        return 0;
 7f0:	4501                	li	a0,0
 7f2:	bf45                	j	7a2 <malloc+0x92>
