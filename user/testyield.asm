
user/_testyield:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int i, y;
  int x = fork();
  10:	00000097          	auipc	ra,0x0
  14:	2fc080e7          	jalr	764(ra) # 30c <fork>
  18:	8a2a                	mv	s4,a0

  for (i=0; i<5; i++) {
  1a:	4481                	li	s1,0
     fprintf(2, "%d: looped %d times", getpid(), i);
  1c:	00001997          	auipc	s3,0x1
  20:	87c98993          	addi	s3,s3,-1924 # 898 <malloc+0xea>
  for (i=0; i<5; i++) {
  24:	4915                	li	s2,5
     fprintf(2, "%d: looped %d times", getpid(), i);
  26:	00000097          	auipc	ra,0x0
  2a:	36e080e7          	jalr	878(ra) # 394 <getpid>
  2e:	862a                	mv	a2,a0
  30:	86a6                	mv	a3,s1
  32:	85ce                	mv	a1,s3
  34:	4509                	li	a0,2
  36:	00000097          	auipc	ra,0x0
  3a:	68c080e7          	jalr	1676(ra) # 6c2 <fprintf>
     yield();
  3e:	00000097          	auipc	ra,0x0
  42:	37e080e7          	jalr	894(ra) # 3bc <yield>
  for (i=0; i<5; i++) {
  46:	2485                	addiw	s1,s1,1
  48:	fd249fe3          	bne	s1,s2,26 <main+0x26>
  }
  if (x > 0) {
  4c:	01404763          	bgtz	s4,5a <main+0x5a>
     printf("%d: before wait\n", getpid());
     y = wait(0);
     printf("%d: after wait for pid %d\n", getpid(), y);
  }
  exit(0);
  50:	4501                	li	a0,0
  52:	00000097          	auipc	ra,0x0
  56:	2c2080e7          	jalr	706(ra) # 314 <exit>
     printf("%d: before wait\n", getpid());
  5a:	00000097          	auipc	ra,0x0
  5e:	33a080e7          	jalr	826(ra) # 394 <getpid>
  62:	85aa                	mv	a1,a0
  64:	00001517          	auipc	a0,0x1
  68:	84c50513          	addi	a0,a0,-1972 # 8b0 <malloc+0x102>
  6c:	00000097          	auipc	ra,0x0
  70:	684080e7          	jalr	1668(ra) # 6f0 <printf>
     y = wait(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	2a6080e7          	jalr	678(ra) # 31c <wait>
  7e:	84aa                	mv	s1,a0
     printf("%d: after wait for pid %d\n", getpid(), y);
  80:	00000097          	auipc	ra,0x0
  84:	314080e7          	jalr	788(ra) # 394 <getpid>
  88:	85aa                	mv	a1,a0
  8a:	8626                	mv	a2,s1
  8c:	00001517          	auipc	a0,0x1
  90:	83c50513          	addi	a0,a0,-1988 # 8c8 <malloc+0x11a>
  94:	00000097          	auipc	ra,0x0
  98:	65c080e7          	jalr	1628(ra) # 6f0 <printf>
  9c:	bf55                	j	50 <main+0x50>

000000000000009e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e422                	sd	s0,8(sp)
  a2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a4:	87aa                	mv	a5,a0
  a6:	0585                	addi	a1,a1,1
  a8:	0785                	addi	a5,a5,1
  aa:	fff5c703          	lbu	a4,-1(a1)
  ae:	fee78fa3          	sb	a4,-1(a5)
  b2:	fb75                	bnez	a4,a6 <strcpy+0x8>
    ;
  return os;
}
  b4:	6422                	ld	s0,8(sp)
  b6:	0141                	addi	sp,sp,16
  b8:	8082                	ret

00000000000000ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c0:	00054783          	lbu	a5,0(a0)
  c4:	cb91                	beqz	a5,d8 <strcmp+0x1e>
  c6:	0005c703          	lbu	a4,0(a1)
  ca:	00f71763          	bne	a4,a5,d8 <strcmp+0x1e>
    p++, q++;
  ce:	0505                	addi	a0,a0,1
  d0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  d2:	00054783          	lbu	a5,0(a0)
  d6:	fbe5                	bnez	a5,c6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  d8:	0005c503          	lbu	a0,0(a1)
}
  dc:	40a7853b          	subw	a0,a5,a0
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret

00000000000000e6 <strlen>:

uint
strlen(const char *s)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cf91                	beqz	a5,10c <strlen+0x26>
  f2:	0505                	addi	a0,a0,1
  f4:	87aa                	mv	a5,a0
  f6:	4685                	li	a3,1
  f8:	9e89                	subw	a3,a3,a0
  fa:	00f6853b          	addw	a0,a3,a5
  fe:	0785                	addi	a5,a5,1
 100:	fff7c703          	lbu	a4,-1(a5)
 104:	fb7d                	bnez	a4,fa <strlen+0x14>
    ;
  return n;
}
 106:	6422                	ld	s0,8(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret
  for(n = 0; s[n]; n++)
 10c:	4501                	li	a0,0
 10e:	bfe5                	j	106 <strlen+0x20>

0000000000000110 <memset>:

void*
memset(void *dst, int c, uint n)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 116:	ce09                	beqz	a2,130 <memset+0x20>
 118:	87aa                	mv	a5,a0
 11a:	fff6071b          	addiw	a4,a2,-1
 11e:	1702                	slli	a4,a4,0x20
 120:	9301                	srli	a4,a4,0x20
 122:	0705                	addi	a4,a4,1
 124:	972a                	add	a4,a4,a0
    cdst[i] = c;
 126:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 12a:	0785                	addi	a5,a5,1
 12c:	fee79de3          	bne	a5,a4,126 <memset+0x16>
  }
  return dst;
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strchr>:

char*
strchr(const char *s, char c)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13c:	00054783          	lbu	a5,0(a0)
 140:	cb99                	beqz	a5,156 <strchr+0x20>
    if(*s == c)
 142:	00f58763          	beq	a1,a5,150 <strchr+0x1a>
  for(; *s; s++)
 146:	0505                	addi	a0,a0,1
 148:	00054783          	lbu	a5,0(a0)
 14c:	fbfd                	bnez	a5,142 <strchr+0xc>
      return (char*)s;
  return 0;
 14e:	4501                	li	a0,0
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret
  return 0;
 156:	4501                	li	a0,0
 158:	bfe5                	j	150 <strchr+0x1a>

000000000000015a <gets>:

char*
gets(char *buf, int max)
{
 15a:	711d                	addi	sp,sp,-96
 15c:	ec86                	sd	ra,88(sp)
 15e:	e8a2                	sd	s0,80(sp)
 160:	e4a6                	sd	s1,72(sp)
 162:	e0ca                	sd	s2,64(sp)
 164:	fc4e                	sd	s3,56(sp)
 166:	f852                	sd	s4,48(sp)
 168:	f456                	sd	s5,40(sp)
 16a:	f05a                	sd	s6,32(sp)
 16c:	ec5e                	sd	s7,24(sp)
 16e:	1080                	addi	s0,sp,96
 170:	8baa                	mv	s7,a0
 172:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 174:	892a                	mv	s2,a0
 176:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 178:	4aa9                	li	s5,10
 17a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 17c:	89a6                	mv	s3,s1
 17e:	2485                	addiw	s1,s1,1
 180:	0344d863          	bge	s1,s4,1b0 <gets+0x56>
    cc = read(0, &c, 1);
 184:	4605                	li	a2,1
 186:	faf40593          	addi	a1,s0,-81
 18a:	4501                	li	a0,0
 18c:	00000097          	auipc	ra,0x0
 190:	1a0080e7          	jalr	416(ra) # 32c <read>
    if(cc < 1)
 194:	00a05e63          	blez	a0,1b0 <gets+0x56>
    buf[i++] = c;
 198:	faf44783          	lbu	a5,-81(s0)
 19c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a0:	01578763          	beq	a5,s5,1ae <gets+0x54>
 1a4:	0905                	addi	s2,s2,1
 1a6:	fd679be3          	bne	a5,s6,17c <gets+0x22>
  for(i=0; i+1 < max; ){
 1aa:	89a6                	mv	s3,s1
 1ac:	a011                	j	1b0 <gets+0x56>
 1ae:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b0:	99de                	add	s3,s3,s7
 1b2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1b6:	855e                	mv	a0,s7
 1b8:	60e6                	ld	ra,88(sp)
 1ba:	6446                	ld	s0,80(sp)
 1bc:	64a6                	ld	s1,72(sp)
 1be:	6906                	ld	s2,64(sp)
 1c0:	79e2                	ld	s3,56(sp)
 1c2:	7a42                	ld	s4,48(sp)
 1c4:	7aa2                	ld	s5,40(sp)
 1c6:	7b02                	ld	s6,32(sp)
 1c8:	6be2                	ld	s7,24(sp)
 1ca:	6125                	addi	sp,sp,96
 1cc:	8082                	ret

00000000000001ce <stat>:

int
stat(const char *n, struct stat *st)
{
 1ce:	1101                	addi	sp,sp,-32
 1d0:	ec06                	sd	ra,24(sp)
 1d2:	e822                	sd	s0,16(sp)
 1d4:	e426                	sd	s1,8(sp)
 1d6:	e04a                	sd	s2,0(sp)
 1d8:	1000                	addi	s0,sp,32
 1da:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1dc:	4581                	li	a1,0
 1de:	00000097          	auipc	ra,0x0
 1e2:	176080e7          	jalr	374(ra) # 354 <open>
  if(fd < 0)
 1e6:	02054563          	bltz	a0,210 <stat+0x42>
 1ea:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ec:	85ca                	mv	a1,s2
 1ee:	00000097          	auipc	ra,0x0
 1f2:	17e080e7          	jalr	382(ra) # 36c <fstat>
 1f6:	892a                	mv	s2,a0
  close(fd);
 1f8:	8526                	mv	a0,s1
 1fa:	00000097          	auipc	ra,0x0
 1fe:	142080e7          	jalr	322(ra) # 33c <close>
  return r;
}
 202:	854a                	mv	a0,s2
 204:	60e2                	ld	ra,24(sp)
 206:	6442                	ld	s0,16(sp)
 208:	64a2                	ld	s1,8(sp)
 20a:	6902                	ld	s2,0(sp)
 20c:	6105                	addi	sp,sp,32
 20e:	8082                	ret
    return -1;
 210:	597d                	li	s2,-1
 212:	bfc5                	j	202 <stat+0x34>

0000000000000214 <atoi>:

int
atoi(const char *s)
{
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21a:	00054603          	lbu	a2,0(a0)
 21e:	fd06079b          	addiw	a5,a2,-48
 222:	0ff7f793          	andi	a5,a5,255
 226:	4725                	li	a4,9
 228:	02f76963          	bltu	a4,a5,25a <atoi+0x46>
 22c:	86aa                	mv	a3,a0
  n = 0;
 22e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 230:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 232:	0685                	addi	a3,a3,1
 234:	0025179b          	slliw	a5,a0,0x2
 238:	9fa9                	addw	a5,a5,a0
 23a:	0017979b          	slliw	a5,a5,0x1
 23e:	9fb1                	addw	a5,a5,a2
 240:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 244:	0006c603          	lbu	a2,0(a3)
 248:	fd06071b          	addiw	a4,a2,-48
 24c:	0ff77713          	andi	a4,a4,255
 250:	fee5f1e3          	bgeu	a1,a4,232 <atoi+0x1e>
  return n;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret
  n = 0;
 25a:	4501                	li	a0,0
 25c:	bfe5                	j	254 <atoi+0x40>

000000000000025e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 264:	02b57663          	bgeu	a0,a1,290 <memmove+0x32>
    while(n-- > 0)
 268:	02c05163          	blez	a2,28a <memmove+0x2c>
 26c:	fff6079b          	addiw	a5,a2,-1
 270:	1782                	slli	a5,a5,0x20
 272:	9381                	srli	a5,a5,0x20
 274:	0785                	addi	a5,a5,1
 276:	97aa                	add	a5,a5,a0
  dst = vdst;
 278:	872a                	mv	a4,a0
      *dst++ = *src++;
 27a:	0585                	addi	a1,a1,1
 27c:	0705                	addi	a4,a4,1
 27e:	fff5c683          	lbu	a3,-1(a1)
 282:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 286:	fee79ae3          	bne	a5,a4,27a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 28a:	6422                	ld	s0,8(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
    dst += n;
 290:	00c50733          	add	a4,a0,a2
    src += n;
 294:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 296:	fec05ae3          	blez	a2,28a <memmove+0x2c>
 29a:	fff6079b          	addiw	a5,a2,-1
 29e:	1782                	slli	a5,a5,0x20
 2a0:	9381                	srli	a5,a5,0x20
 2a2:	fff7c793          	not	a5,a5
 2a6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a8:	15fd                	addi	a1,a1,-1
 2aa:	177d                	addi	a4,a4,-1
 2ac:	0005c683          	lbu	a3,0(a1)
 2b0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b4:	fee79ae3          	bne	a5,a4,2a8 <memmove+0x4a>
 2b8:	bfc9                	j	28a <memmove+0x2c>

00000000000002ba <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c0:	ca05                	beqz	a2,2f0 <memcmp+0x36>
 2c2:	fff6069b          	addiw	a3,a2,-1
 2c6:	1682                	slli	a3,a3,0x20
 2c8:	9281                	srli	a3,a3,0x20
 2ca:	0685                	addi	a3,a3,1
 2cc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ce:	00054783          	lbu	a5,0(a0)
 2d2:	0005c703          	lbu	a4,0(a1)
 2d6:	00e79863          	bne	a5,a4,2e6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2da:	0505                	addi	a0,a0,1
    p2++;
 2dc:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2de:	fed518e3          	bne	a0,a3,2ce <memcmp+0x14>
  }
  return 0;
 2e2:	4501                	li	a0,0
 2e4:	a019                	j	2ea <memcmp+0x30>
      return *p1 - *p2;
 2e6:	40e7853b          	subw	a0,a5,a4
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  return 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <memcmp+0x30>

00000000000002f4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e406                	sd	ra,8(sp)
 2f8:	e022                	sd	s0,0(sp)
 2fa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fc:	00000097          	auipc	ra,0x0
 300:	f62080e7          	jalr	-158(ra) # 25e <memmove>
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 30c:	4885                	li	a7,1
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <exit>:
.global exit
exit:
 li a7, SYS_exit
 314:	4889                	li	a7,2
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <wait>:
.global wait
wait:
 li a7, SYS_wait
 31c:	488d                	li	a7,3
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 324:	4891                	li	a7,4
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <read>:
.global read
read:
 li a7, SYS_read
 32c:	4895                	li	a7,5
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <write>:
.global write
write:
 li a7, SYS_write
 334:	48c1                	li	a7,16
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <close>:
.global close
close:
 li a7, SYS_close
 33c:	48d5                	li	a7,21
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <kill>:
.global kill
kill:
 li a7, SYS_kill
 344:	4899                	li	a7,6
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <exec>:
.global exec
exec:
 li a7, SYS_exec
 34c:	489d                	li	a7,7
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <open>:
.global open
open:
 li a7, SYS_open
 354:	48bd                	li	a7,15
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 35c:	48c5                	li	a7,17
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 364:	48c9                	li	a7,18
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 36c:	48a1                	li	a7,8
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <link>:
.global link
link:
 li a7, SYS_link
 374:	48cd                	li	a7,19
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 37c:	48d1                	li	a7,20
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 384:	48a5                	li	a7,9
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <dup>:
.global dup
dup:
 li a7, SYS_dup
 38c:	48a9                	li	a7,10
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 394:	48ad                	li	a7,11
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 39c:	48b1                	li	a7,12
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3a4:	48b5                	li	a7,13
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ac:	48b9                	li	a7,14
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 3b4:	48d9                	li	a7,22
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <yield>:
.global yield
yield:
 li a7, SYS_yield
 3bc:	48dd                	li	a7,23
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 3c4:	48e1                	li	a7,24
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 3cc:	48e5                	li	a7,25
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3d4:	48e9                	li	a7,26
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <ps>:
.global ps
ps:
 li a7, SYS_ps
 3dc:	48ed                	li	a7,27
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 3e4:	48f1                	li	a7,28
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 3ec:	48f5                	li	a7,29
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 3f4:	48f9                	li	a7,30
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 3fc:	48fd                	li	a7,31
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 404:	02000893          	li	a7,32
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 40e:	02100893          	li	a7,33
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 418:	1101                	addi	sp,sp,-32
 41a:	ec06                	sd	ra,24(sp)
 41c:	e822                	sd	s0,16(sp)
 41e:	1000                	addi	s0,sp,32
 420:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 424:	4605                	li	a2,1
 426:	fef40593          	addi	a1,s0,-17
 42a:	00000097          	auipc	ra,0x0
 42e:	f0a080e7          	jalr	-246(ra) # 334 <write>
}
 432:	60e2                	ld	ra,24(sp)
 434:	6442                	ld	s0,16(sp)
 436:	6105                	addi	sp,sp,32
 438:	8082                	ret

000000000000043a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 43a:	7139                	addi	sp,sp,-64
 43c:	fc06                	sd	ra,56(sp)
 43e:	f822                	sd	s0,48(sp)
 440:	f426                	sd	s1,40(sp)
 442:	f04a                	sd	s2,32(sp)
 444:	ec4e                	sd	s3,24(sp)
 446:	0080                	addi	s0,sp,64
 448:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 44a:	c299                	beqz	a3,450 <printint+0x16>
 44c:	0805c863          	bltz	a1,4dc <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 450:	2581                	sext.w	a1,a1
  neg = 0;
 452:	4881                	li	a7,0
 454:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 458:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 45a:	2601                	sext.w	a2,a2
 45c:	00000517          	auipc	a0,0x0
 460:	49450513          	addi	a0,a0,1172 # 8f0 <digits>
 464:	883a                	mv	a6,a4
 466:	2705                	addiw	a4,a4,1
 468:	02c5f7bb          	remuw	a5,a1,a2
 46c:	1782                	slli	a5,a5,0x20
 46e:	9381                	srli	a5,a5,0x20
 470:	97aa                	add	a5,a5,a0
 472:	0007c783          	lbu	a5,0(a5)
 476:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 47a:	0005879b          	sext.w	a5,a1
 47e:	02c5d5bb          	divuw	a1,a1,a2
 482:	0685                	addi	a3,a3,1
 484:	fec7f0e3          	bgeu	a5,a2,464 <printint+0x2a>
  if(neg)
 488:	00088b63          	beqz	a7,49e <printint+0x64>
    buf[i++] = '-';
 48c:	fd040793          	addi	a5,s0,-48
 490:	973e                	add	a4,a4,a5
 492:	02d00793          	li	a5,45
 496:	fef70823          	sb	a5,-16(a4)
 49a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 49e:	02e05863          	blez	a4,4ce <printint+0x94>
 4a2:	fc040793          	addi	a5,s0,-64
 4a6:	00e78933          	add	s2,a5,a4
 4aa:	fff78993          	addi	s3,a5,-1
 4ae:	99ba                	add	s3,s3,a4
 4b0:	377d                	addiw	a4,a4,-1
 4b2:	1702                	slli	a4,a4,0x20
 4b4:	9301                	srli	a4,a4,0x20
 4b6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ba:	fff94583          	lbu	a1,-1(s2)
 4be:	8526                	mv	a0,s1
 4c0:	00000097          	auipc	ra,0x0
 4c4:	f58080e7          	jalr	-168(ra) # 418 <putc>
  while(--i >= 0)
 4c8:	197d                	addi	s2,s2,-1
 4ca:	ff3918e3          	bne	s2,s3,4ba <printint+0x80>
}
 4ce:	70e2                	ld	ra,56(sp)
 4d0:	7442                	ld	s0,48(sp)
 4d2:	74a2                	ld	s1,40(sp)
 4d4:	7902                	ld	s2,32(sp)
 4d6:	69e2                	ld	s3,24(sp)
 4d8:	6121                	addi	sp,sp,64
 4da:	8082                	ret
    x = -xx;
 4dc:	40b005bb          	negw	a1,a1
    neg = 1;
 4e0:	4885                	li	a7,1
    x = -xx;
 4e2:	bf8d                	j	454 <printint+0x1a>

00000000000004e4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e4:	7119                	addi	sp,sp,-128
 4e6:	fc86                	sd	ra,120(sp)
 4e8:	f8a2                	sd	s0,112(sp)
 4ea:	f4a6                	sd	s1,104(sp)
 4ec:	f0ca                	sd	s2,96(sp)
 4ee:	ecce                	sd	s3,88(sp)
 4f0:	e8d2                	sd	s4,80(sp)
 4f2:	e4d6                	sd	s5,72(sp)
 4f4:	e0da                	sd	s6,64(sp)
 4f6:	fc5e                	sd	s7,56(sp)
 4f8:	f862                	sd	s8,48(sp)
 4fa:	f466                	sd	s9,40(sp)
 4fc:	f06a                	sd	s10,32(sp)
 4fe:	ec6e                	sd	s11,24(sp)
 500:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 502:	0005c903          	lbu	s2,0(a1)
 506:	18090f63          	beqz	s2,6a4 <vprintf+0x1c0>
 50a:	8aaa                	mv	s5,a0
 50c:	8b32                	mv	s6,a2
 50e:	00158493          	addi	s1,a1,1
  state = 0;
 512:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 514:	02500a13          	li	s4,37
      if(c == 'd'){
 518:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 51c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 520:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 524:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 528:	00000b97          	auipc	s7,0x0
 52c:	3c8b8b93          	addi	s7,s7,968 # 8f0 <digits>
 530:	a839                	j	54e <vprintf+0x6a>
        putc(fd, c);
 532:	85ca                	mv	a1,s2
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	ee2080e7          	jalr	-286(ra) # 418 <putc>
 53e:	a019                	j	544 <vprintf+0x60>
    } else if(state == '%'){
 540:	01498f63          	beq	s3,s4,55e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 544:	0485                	addi	s1,s1,1
 546:	fff4c903          	lbu	s2,-1(s1)
 54a:	14090d63          	beqz	s2,6a4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 54e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 552:	fe0997e3          	bnez	s3,540 <vprintf+0x5c>
      if(c == '%'){
 556:	fd479ee3          	bne	a5,s4,532 <vprintf+0x4e>
        state = '%';
 55a:	89be                	mv	s3,a5
 55c:	b7e5                	j	544 <vprintf+0x60>
      if(c == 'd'){
 55e:	05878063          	beq	a5,s8,59e <vprintf+0xba>
      } else if(c == 'l') {
 562:	05978c63          	beq	a5,s9,5ba <vprintf+0xd6>
      } else if(c == 'x') {
 566:	07a78863          	beq	a5,s10,5d6 <vprintf+0xf2>
      } else if(c == 'p') {
 56a:	09b78463          	beq	a5,s11,5f2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 56e:	07300713          	li	a4,115
 572:	0ce78663          	beq	a5,a4,63e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 576:	06300713          	li	a4,99
 57a:	0ee78e63          	beq	a5,a4,676 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 57e:	11478863          	beq	a5,s4,68e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 582:	85d2                	mv	a1,s4
 584:	8556                	mv	a0,s5
 586:	00000097          	auipc	ra,0x0
 58a:	e92080e7          	jalr	-366(ra) # 418 <putc>
        putc(fd, c);
 58e:	85ca                	mv	a1,s2
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	e86080e7          	jalr	-378(ra) # 418 <putc>
      }
      state = 0;
 59a:	4981                	li	s3,0
 59c:	b765                	j	544 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 59e:	008b0913          	addi	s2,s6,8
 5a2:	4685                	li	a3,1
 5a4:	4629                	li	a2,10
 5a6:	000b2583          	lw	a1,0(s6)
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	e8e080e7          	jalr	-370(ra) # 43a <printint>
 5b4:	8b4a                	mv	s6,s2
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b771                	j	544 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ba:	008b0913          	addi	s2,s6,8
 5be:	4681                	li	a3,0
 5c0:	4629                	li	a2,10
 5c2:	000b2583          	lw	a1,0(s6)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e72080e7          	jalr	-398(ra) # 43a <printint>
 5d0:	8b4a                	mv	s6,s2
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	bf85                	j	544 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5d6:	008b0913          	addi	s2,s6,8
 5da:	4681                	li	a3,0
 5dc:	4641                	li	a2,16
 5de:	000b2583          	lw	a1,0(s6)
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	e56080e7          	jalr	-426(ra) # 43a <printint>
 5ec:	8b4a                	mv	s6,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bf91                	j	544 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5f2:	008b0793          	addi	a5,s6,8
 5f6:	f8f43423          	sd	a5,-120(s0)
 5fa:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5fe:	03000593          	li	a1,48
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e14080e7          	jalr	-492(ra) # 418 <putc>
  putc(fd, 'x');
 60c:	85ea                	mv	a1,s10
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e08080e7          	jalr	-504(ra) # 418 <putc>
 618:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61a:	03c9d793          	srli	a5,s3,0x3c
 61e:	97de                	add	a5,a5,s7
 620:	0007c583          	lbu	a1,0(a5)
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	df2080e7          	jalr	-526(ra) # 418 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 62e:	0992                	slli	s3,s3,0x4
 630:	397d                	addiw	s2,s2,-1
 632:	fe0914e3          	bnez	s2,61a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 636:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b721                	j	544 <vprintf+0x60>
        s = va_arg(ap, char*);
 63e:	008b0993          	addi	s3,s6,8
 642:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 646:	02090163          	beqz	s2,668 <vprintf+0x184>
        while(*s != 0){
 64a:	00094583          	lbu	a1,0(s2)
 64e:	c9a1                	beqz	a1,69e <vprintf+0x1ba>
          putc(fd, *s);
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	dc6080e7          	jalr	-570(ra) # 418 <putc>
          s++;
 65a:	0905                	addi	s2,s2,1
        while(*s != 0){
 65c:	00094583          	lbu	a1,0(s2)
 660:	f9e5                	bnez	a1,650 <vprintf+0x16c>
        s = va_arg(ap, char*);
 662:	8b4e                	mv	s6,s3
      state = 0;
 664:	4981                	li	s3,0
 666:	bdf9                	j	544 <vprintf+0x60>
          s = "(null)";
 668:	00000917          	auipc	s2,0x0
 66c:	28090913          	addi	s2,s2,640 # 8e8 <malloc+0x13a>
        while(*s != 0){
 670:	02800593          	li	a1,40
 674:	bff1                	j	650 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 676:	008b0913          	addi	s2,s6,8
 67a:	000b4583          	lbu	a1,0(s6)
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	d98080e7          	jalr	-616(ra) # 418 <putc>
 688:	8b4a                	mv	s6,s2
      state = 0;
 68a:	4981                	li	s3,0
 68c:	bd65                	j	544 <vprintf+0x60>
        putc(fd, c);
 68e:	85d2                	mv	a1,s4
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	d86080e7          	jalr	-634(ra) # 418 <putc>
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b565                	j	544 <vprintf+0x60>
        s = va_arg(ap, char*);
 69e:	8b4e                	mv	s6,s3
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	b54d                	j	544 <vprintf+0x60>
    }
  }
}
 6a4:	70e6                	ld	ra,120(sp)
 6a6:	7446                	ld	s0,112(sp)
 6a8:	74a6                	ld	s1,104(sp)
 6aa:	7906                	ld	s2,96(sp)
 6ac:	69e6                	ld	s3,88(sp)
 6ae:	6a46                	ld	s4,80(sp)
 6b0:	6aa6                	ld	s5,72(sp)
 6b2:	6b06                	ld	s6,64(sp)
 6b4:	7be2                	ld	s7,56(sp)
 6b6:	7c42                	ld	s8,48(sp)
 6b8:	7ca2                	ld	s9,40(sp)
 6ba:	7d02                	ld	s10,32(sp)
 6bc:	6de2                	ld	s11,24(sp)
 6be:	6109                	addi	sp,sp,128
 6c0:	8082                	ret

00000000000006c2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6c2:	715d                	addi	sp,sp,-80
 6c4:	ec06                	sd	ra,24(sp)
 6c6:	e822                	sd	s0,16(sp)
 6c8:	1000                	addi	s0,sp,32
 6ca:	e010                	sd	a2,0(s0)
 6cc:	e414                	sd	a3,8(s0)
 6ce:	e818                	sd	a4,16(s0)
 6d0:	ec1c                	sd	a5,24(s0)
 6d2:	03043023          	sd	a6,32(s0)
 6d6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6de:	8622                	mv	a2,s0
 6e0:	00000097          	auipc	ra,0x0
 6e4:	e04080e7          	jalr	-508(ra) # 4e4 <vprintf>
}
 6e8:	60e2                	ld	ra,24(sp)
 6ea:	6442                	ld	s0,16(sp)
 6ec:	6161                	addi	sp,sp,80
 6ee:	8082                	ret

00000000000006f0 <printf>:

void
printf(const char *fmt, ...)
{
 6f0:	711d                	addi	sp,sp,-96
 6f2:	ec06                	sd	ra,24(sp)
 6f4:	e822                	sd	s0,16(sp)
 6f6:	1000                	addi	s0,sp,32
 6f8:	e40c                	sd	a1,8(s0)
 6fa:	e810                	sd	a2,16(s0)
 6fc:	ec14                	sd	a3,24(s0)
 6fe:	f018                	sd	a4,32(s0)
 700:	f41c                	sd	a5,40(s0)
 702:	03043823          	sd	a6,48(s0)
 706:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 70a:	00840613          	addi	a2,s0,8
 70e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 712:	85aa                	mv	a1,a0
 714:	4505                	li	a0,1
 716:	00000097          	auipc	ra,0x0
 71a:	dce080e7          	jalr	-562(ra) # 4e4 <vprintf>
}
 71e:	60e2                	ld	ra,24(sp)
 720:	6442                	ld	s0,16(sp)
 722:	6125                	addi	sp,sp,96
 724:	8082                	ret

0000000000000726 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 726:	1141                	addi	sp,sp,-16
 728:	e422                	sd	s0,8(sp)
 72a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 72c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 730:	00000797          	auipc	a5,0x0
 734:	1d87b783          	ld	a5,472(a5) # 908 <freep>
 738:	a805                	j	768 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 73a:	4618                	lw	a4,8(a2)
 73c:	9db9                	addw	a1,a1,a4
 73e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 742:	6398                	ld	a4,0(a5)
 744:	6318                	ld	a4,0(a4)
 746:	fee53823          	sd	a4,-16(a0)
 74a:	a091                	j	78e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 74c:	ff852703          	lw	a4,-8(a0)
 750:	9e39                	addw	a2,a2,a4
 752:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 754:	ff053703          	ld	a4,-16(a0)
 758:	e398                	sd	a4,0(a5)
 75a:	a099                	j	7a0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75c:	6398                	ld	a4,0(a5)
 75e:	00e7e463          	bltu	a5,a4,766 <free+0x40>
 762:	00e6ea63          	bltu	a3,a4,776 <free+0x50>
{
 766:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 768:	fed7fae3          	bgeu	a5,a3,75c <free+0x36>
 76c:	6398                	ld	a4,0(a5)
 76e:	00e6e463          	bltu	a3,a4,776 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 772:	fee7eae3          	bltu	a5,a4,766 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 776:	ff852583          	lw	a1,-8(a0)
 77a:	6390                	ld	a2,0(a5)
 77c:	02059713          	slli	a4,a1,0x20
 780:	9301                	srli	a4,a4,0x20
 782:	0712                	slli	a4,a4,0x4
 784:	9736                	add	a4,a4,a3
 786:	fae60ae3          	beq	a2,a4,73a <free+0x14>
    bp->s.ptr = p->s.ptr;
 78a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 78e:	4790                	lw	a2,8(a5)
 790:	02061713          	slli	a4,a2,0x20
 794:	9301                	srli	a4,a4,0x20
 796:	0712                	slli	a4,a4,0x4
 798:	973e                	add	a4,a4,a5
 79a:	fae689e3          	beq	a3,a4,74c <free+0x26>
  } else
    p->s.ptr = bp;
 79e:	e394                	sd	a3,0(a5)
  freep = p;
 7a0:	00000717          	auipc	a4,0x0
 7a4:	16f73423          	sd	a5,360(a4) # 908 <freep>
}
 7a8:	6422                	ld	s0,8(sp)
 7aa:	0141                	addi	sp,sp,16
 7ac:	8082                	ret

00000000000007ae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ae:	7139                	addi	sp,sp,-64
 7b0:	fc06                	sd	ra,56(sp)
 7b2:	f822                	sd	s0,48(sp)
 7b4:	f426                	sd	s1,40(sp)
 7b6:	f04a                	sd	s2,32(sp)
 7b8:	ec4e                	sd	s3,24(sp)
 7ba:	e852                	sd	s4,16(sp)
 7bc:	e456                	sd	s5,8(sp)
 7be:	e05a                	sd	s6,0(sp)
 7c0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c2:	02051493          	slli	s1,a0,0x20
 7c6:	9081                	srli	s1,s1,0x20
 7c8:	04bd                	addi	s1,s1,15
 7ca:	8091                	srli	s1,s1,0x4
 7cc:	0014899b          	addiw	s3,s1,1
 7d0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7d2:	00000517          	auipc	a0,0x0
 7d6:	13653503          	ld	a0,310(a0) # 908 <freep>
 7da:	c515                	beqz	a0,806 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7de:	4798                	lw	a4,8(a5)
 7e0:	02977f63          	bgeu	a4,s1,81e <malloc+0x70>
 7e4:	8a4e                	mv	s4,s3
 7e6:	0009871b          	sext.w	a4,s3
 7ea:	6685                	lui	a3,0x1
 7ec:	00d77363          	bgeu	a4,a3,7f2 <malloc+0x44>
 7f0:	6a05                	lui	s4,0x1
 7f2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7f6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7fa:	00000917          	auipc	s2,0x0
 7fe:	10e90913          	addi	s2,s2,270 # 908 <freep>
  if(p == (char*)-1)
 802:	5afd                	li	s5,-1
 804:	a88d                	j	876 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 806:	00000797          	auipc	a5,0x0
 80a:	10a78793          	addi	a5,a5,266 # 910 <base>
 80e:	00000717          	auipc	a4,0x0
 812:	0ef73d23          	sd	a5,250(a4) # 908 <freep>
 816:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 818:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 81c:	b7e1                	j	7e4 <malloc+0x36>
      if(p->s.size == nunits)
 81e:	02e48b63          	beq	s1,a4,854 <malloc+0xa6>
        p->s.size -= nunits;
 822:	4137073b          	subw	a4,a4,s3
 826:	c798                	sw	a4,8(a5)
        p += p->s.size;
 828:	1702                	slli	a4,a4,0x20
 82a:	9301                	srli	a4,a4,0x20
 82c:	0712                	slli	a4,a4,0x4
 82e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 830:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 834:	00000717          	auipc	a4,0x0
 838:	0ca73a23          	sd	a0,212(a4) # 908 <freep>
      return (void*)(p + 1);
 83c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 840:	70e2                	ld	ra,56(sp)
 842:	7442                	ld	s0,48(sp)
 844:	74a2                	ld	s1,40(sp)
 846:	7902                	ld	s2,32(sp)
 848:	69e2                	ld	s3,24(sp)
 84a:	6a42                	ld	s4,16(sp)
 84c:	6aa2                	ld	s5,8(sp)
 84e:	6b02                	ld	s6,0(sp)
 850:	6121                	addi	sp,sp,64
 852:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 854:	6398                	ld	a4,0(a5)
 856:	e118                	sd	a4,0(a0)
 858:	bff1                	j	834 <malloc+0x86>
  hp->s.size = nu;
 85a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 85e:	0541                	addi	a0,a0,16
 860:	00000097          	auipc	ra,0x0
 864:	ec6080e7          	jalr	-314(ra) # 726 <free>
  return freep;
 868:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 86c:	d971                	beqz	a0,840 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 870:	4798                	lw	a4,8(a5)
 872:	fa9776e3          	bgeu	a4,s1,81e <malloc+0x70>
    if(p == freep)
 876:	00093703          	ld	a4,0(s2)
 87a:	853e                	mv	a0,a5
 87c:	fef719e3          	bne	a4,a5,86e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 880:	8552                	mv	a0,s4
 882:	00000097          	auipc	ra,0x0
 886:	b1a080e7          	jalr	-1254(ra) # 39c <sbrk>
  if(p == (char*)-1)
 88a:	fd5518e3          	bne	a0,s5,85a <malloc+0xac>
        return 0;
 88e:	4501                	li	a0,0
 890:	bf45                	j	840 <malloc+0x92>
