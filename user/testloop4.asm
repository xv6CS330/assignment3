
user/_testloop4:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define INNER_BOUND 10000000
#define SIZE 100

int
main(int argc, char *argv[])
{
   0:	7105                	addi	sp,sp,-480
   2:	ef86                	sd	ra,472(sp)
   4:	eba2                	sd	s0,464(sp)
   6:	e7a6                	sd	s1,456(sp)
   8:	e3ca                	sd	s2,448(sp)
   a:	ff4e                	sd	s3,440(sp)
   c:	fb52                	sd	s4,432(sp)
   e:	f756                	sd	s5,424(sp)
  10:	f35a                	sd	s6,416(sp)
  12:	ef5e                	sd	s7,408(sp)
  14:	1380                	addi	s0,sp,480
    int array[SIZE], i, j, k, sum=0, pid=getpid();
  16:	00000097          	auipc	ra,0x0
  1a:	392080e7          	jalr	914(ra) # 3a8 <getpid>
  1e:	8baa                	mv	s7,a0
    unsigned start_time, end_time;

    start_time = uptime();
  20:	00000097          	auipc	ra,0x0
  24:	3a0080e7          	jalr	928(ra) # 3c0 <uptime>
  28:	0005099b          	sext.w	s3,a0
  2c:	4a15                	li	s4,5
    int array[SIZE], i, j, k, sum=0, pid=getpid();
  2e:	4481                	li	s1,0
{
  30:	009897b7          	lui	a5,0x989
  34:	68078b13          	addi	s6,a5,1664 # 989680 <__global_pointer$+0x988577>
  38:	fb040913          	addi	s2,s0,-80
    for (k=0; k<OUTER_BOUND; k++) {
       for (j=0; j<INNER_BOUND; j++) for (i=0; i<SIZE; i++) sum += array[i];
       fprintf(1, "%d", pid);
  3c:	00001a97          	auipc	s5,0x1
  40:	86ca8a93          	addi	s5,s5,-1940 # 8a8 <malloc+0xe6>
  44:	a02d                	j	6e <main+0x6e>
       for (j=0; j<INNER_BOUND; j++) for (i=0; i<SIZE; i++) sum += array[i];
  46:	36fd                	addiw	a3,a3,-1
  48:	ca89                	beqz	a3,5a <main+0x5a>
  4a:	e2040793          	addi	a5,s0,-480
  4e:	4398                	lw	a4,0(a5)
  50:	9cb9                	addw	s1,s1,a4
  52:	0791                	addi	a5,a5,4
  54:	ff279de3          	bne	a5,s2,4e <main+0x4e>
  58:	b7fd                	j	46 <main+0x46>
       fprintf(1, "%d", pid);
  5a:	865e                	mv	a2,s7
  5c:	85d6                	mv	a1,s5
  5e:	4505                	li	a0,1
  60:	00000097          	auipc	ra,0x0
  64:	676080e7          	jalr	1654(ra) # 6d6 <fprintf>
    for (k=0; k<OUTER_BOUND; k++) {
  68:	3a7d                	addiw	s4,s4,-1
  6a:	000a0463          	beqz	s4,72 <main+0x72>
{
  6e:	86da                	mv	a3,s6
  70:	bfe9                	j	4a <main+0x4a>
    }
    end_time = uptime();
  72:	00000097          	auipc	ra,0x0
  76:	34e080e7          	jalr	846(ra) # 3c0 <uptime>
  7a:	0005091b          	sext.w	s2,a0
    printf("\nTotal sum: %d\n", sum);
  7e:	85a6                	mv	a1,s1
  80:	00001517          	auipc	a0,0x1
  84:	83050513          	addi	a0,a0,-2000 # 8b0 <malloc+0xee>
  88:	00000097          	auipc	ra,0x0
  8c:	67c080e7          	jalr	1660(ra) # 704 <printf>
    printf("Start time: %d, End time: %d, Total time: %d\n", start_time, end_time, end_time-start_time);
  90:	413906bb          	subw	a3,s2,s3
  94:	864a                	mv	a2,s2
  96:	85ce                	mv	a1,s3
  98:	00001517          	auipc	a0,0x1
  9c:	82850513          	addi	a0,a0,-2008 # 8c0 <malloc+0xfe>
  a0:	00000097          	auipc	ra,0x0
  a4:	664080e7          	jalr	1636(ra) # 704 <printf>
    exit(0);
  a8:	4501                	li	a0,0
  aa:	00000097          	auipc	ra,0x0
  ae:	27e080e7          	jalr	638(ra) # 328 <exit>

00000000000000b2 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  b2:	1141                	addi	sp,sp,-16
  b4:	e422                	sd	s0,8(sp)
  b6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  b8:	87aa                	mv	a5,a0
  ba:	0585                	addi	a1,a1,1
  bc:	0785                	addi	a5,a5,1
  be:	fff5c703          	lbu	a4,-1(a1)
  c2:	fee78fa3          	sb	a4,-1(a5)
  c6:	fb75                	bnez	a4,ba <strcpy+0x8>
    ;
  return os;
}
  c8:	6422                	ld	s0,8(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret

00000000000000ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e422                	sd	s0,8(sp)
  d2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  d4:	00054783          	lbu	a5,0(a0)
  d8:	cb91                	beqz	a5,ec <strcmp+0x1e>
  da:	0005c703          	lbu	a4,0(a1)
  de:	00f71763          	bne	a4,a5,ec <strcmp+0x1e>
    p++, q++;
  e2:	0505                	addi	a0,a0,1
  e4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  e6:	00054783          	lbu	a5,0(a0)
  ea:	fbe5                	bnez	a5,da <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ec:	0005c503          	lbu	a0,0(a1)
}
  f0:	40a7853b          	subw	a0,a5,a0
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret

00000000000000fa <strlen>:

uint
strlen(const char *s)
{
  fa:	1141                	addi	sp,sp,-16
  fc:	e422                	sd	s0,8(sp)
  fe:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 100:	00054783          	lbu	a5,0(a0)
 104:	cf91                	beqz	a5,120 <strlen+0x26>
 106:	0505                	addi	a0,a0,1
 108:	87aa                	mv	a5,a0
 10a:	4685                	li	a3,1
 10c:	9e89                	subw	a3,a3,a0
 10e:	00f6853b          	addw	a0,a3,a5
 112:	0785                	addi	a5,a5,1
 114:	fff7c703          	lbu	a4,-1(a5)
 118:	fb7d                	bnez	a4,10e <strlen+0x14>
    ;
  return n;
}
 11a:	6422                	ld	s0,8(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret
  for(n = 0; s[n]; n++)
 120:	4501                	li	a0,0
 122:	bfe5                	j	11a <strlen+0x20>

0000000000000124 <memset>:

void*
memset(void *dst, int c, uint n)
{
 124:	1141                	addi	sp,sp,-16
 126:	e422                	sd	s0,8(sp)
 128:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 12a:	ce09                	beqz	a2,144 <memset+0x20>
 12c:	87aa                	mv	a5,a0
 12e:	fff6071b          	addiw	a4,a2,-1
 132:	1702                	slli	a4,a4,0x20
 134:	9301                	srli	a4,a4,0x20
 136:	0705                	addi	a4,a4,1
 138:	972a                	add	a4,a4,a0
    cdst[i] = c;
 13a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 13e:	0785                	addi	a5,a5,1
 140:	fee79de3          	bne	a5,a4,13a <memset+0x16>
  }
  return dst;
}
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <strchr>:

char*
strchr(const char *s, char c)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 150:	00054783          	lbu	a5,0(a0)
 154:	cb99                	beqz	a5,16a <strchr+0x20>
    if(*s == c)
 156:	00f58763          	beq	a1,a5,164 <strchr+0x1a>
  for(; *s; s++)
 15a:	0505                	addi	a0,a0,1
 15c:	00054783          	lbu	a5,0(a0)
 160:	fbfd                	bnez	a5,156 <strchr+0xc>
      return (char*)s;
  return 0;
 162:	4501                	li	a0,0
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret
  return 0;
 16a:	4501                	li	a0,0
 16c:	bfe5                	j	164 <strchr+0x1a>

000000000000016e <gets>:

char*
gets(char *buf, int max)
{
 16e:	711d                	addi	sp,sp,-96
 170:	ec86                	sd	ra,88(sp)
 172:	e8a2                	sd	s0,80(sp)
 174:	e4a6                	sd	s1,72(sp)
 176:	e0ca                	sd	s2,64(sp)
 178:	fc4e                	sd	s3,56(sp)
 17a:	f852                	sd	s4,48(sp)
 17c:	f456                	sd	s5,40(sp)
 17e:	f05a                	sd	s6,32(sp)
 180:	ec5e                	sd	s7,24(sp)
 182:	1080                	addi	s0,sp,96
 184:	8baa                	mv	s7,a0
 186:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 188:	892a                	mv	s2,a0
 18a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 18c:	4aa9                	li	s5,10
 18e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 190:	89a6                	mv	s3,s1
 192:	2485                	addiw	s1,s1,1
 194:	0344d863          	bge	s1,s4,1c4 <gets+0x56>
    cc = read(0, &c, 1);
 198:	4605                	li	a2,1
 19a:	faf40593          	addi	a1,s0,-81
 19e:	4501                	li	a0,0
 1a0:	00000097          	auipc	ra,0x0
 1a4:	1a0080e7          	jalr	416(ra) # 340 <read>
    if(cc < 1)
 1a8:	00a05e63          	blez	a0,1c4 <gets+0x56>
    buf[i++] = c;
 1ac:	faf44783          	lbu	a5,-81(s0)
 1b0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b4:	01578763          	beq	a5,s5,1c2 <gets+0x54>
 1b8:	0905                	addi	s2,s2,1
 1ba:	fd679be3          	bne	a5,s6,190 <gets+0x22>
  for(i=0; i+1 < max; ){
 1be:	89a6                	mv	s3,s1
 1c0:	a011                	j	1c4 <gets+0x56>
 1c2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c4:	99de                	add	s3,s3,s7
 1c6:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ca:	855e                	mv	a0,s7
 1cc:	60e6                	ld	ra,88(sp)
 1ce:	6446                	ld	s0,80(sp)
 1d0:	64a6                	ld	s1,72(sp)
 1d2:	6906                	ld	s2,64(sp)
 1d4:	79e2                	ld	s3,56(sp)
 1d6:	7a42                	ld	s4,48(sp)
 1d8:	7aa2                	ld	s5,40(sp)
 1da:	7b02                	ld	s6,32(sp)
 1dc:	6be2                	ld	s7,24(sp)
 1de:	6125                	addi	sp,sp,96
 1e0:	8082                	ret

00000000000001e2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e2:	1101                	addi	sp,sp,-32
 1e4:	ec06                	sd	ra,24(sp)
 1e6:	e822                	sd	s0,16(sp)
 1e8:	e426                	sd	s1,8(sp)
 1ea:	e04a                	sd	s2,0(sp)
 1ec:	1000                	addi	s0,sp,32
 1ee:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f0:	4581                	li	a1,0
 1f2:	00000097          	auipc	ra,0x0
 1f6:	176080e7          	jalr	374(ra) # 368 <open>
  if(fd < 0)
 1fa:	02054563          	bltz	a0,224 <stat+0x42>
 1fe:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 200:	85ca                	mv	a1,s2
 202:	00000097          	auipc	ra,0x0
 206:	17e080e7          	jalr	382(ra) # 380 <fstat>
 20a:	892a                	mv	s2,a0
  close(fd);
 20c:	8526                	mv	a0,s1
 20e:	00000097          	auipc	ra,0x0
 212:	142080e7          	jalr	322(ra) # 350 <close>
  return r;
}
 216:	854a                	mv	a0,s2
 218:	60e2                	ld	ra,24(sp)
 21a:	6442                	ld	s0,16(sp)
 21c:	64a2                	ld	s1,8(sp)
 21e:	6902                	ld	s2,0(sp)
 220:	6105                	addi	sp,sp,32
 222:	8082                	ret
    return -1;
 224:	597d                	li	s2,-1
 226:	bfc5                	j	216 <stat+0x34>

0000000000000228 <atoi>:

int
atoi(const char *s)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 22e:	00054603          	lbu	a2,0(a0)
 232:	fd06079b          	addiw	a5,a2,-48
 236:	0ff7f793          	andi	a5,a5,255
 23a:	4725                	li	a4,9
 23c:	02f76963          	bltu	a4,a5,26e <atoi+0x46>
 240:	86aa                	mv	a3,a0
  n = 0;
 242:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 244:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 246:	0685                	addi	a3,a3,1
 248:	0025179b          	slliw	a5,a0,0x2
 24c:	9fa9                	addw	a5,a5,a0
 24e:	0017979b          	slliw	a5,a5,0x1
 252:	9fb1                	addw	a5,a5,a2
 254:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 258:	0006c603          	lbu	a2,0(a3)
 25c:	fd06071b          	addiw	a4,a2,-48
 260:	0ff77713          	andi	a4,a4,255
 264:	fee5f1e3          	bgeu	a1,a4,246 <atoi+0x1e>
  return n;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret
  n = 0;
 26e:	4501                	li	a0,0
 270:	bfe5                	j	268 <atoi+0x40>

0000000000000272 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 272:	1141                	addi	sp,sp,-16
 274:	e422                	sd	s0,8(sp)
 276:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 278:	02b57663          	bgeu	a0,a1,2a4 <memmove+0x32>
    while(n-- > 0)
 27c:	02c05163          	blez	a2,29e <memmove+0x2c>
 280:	fff6079b          	addiw	a5,a2,-1
 284:	1782                	slli	a5,a5,0x20
 286:	9381                	srli	a5,a5,0x20
 288:	0785                	addi	a5,a5,1
 28a:	97aa                	add	a5,a5,a0
  dst = vdst;
 28c:	872a                	mv	a4,a0
      *dst++ = *src++;
 28e:	0585                	addi	a1,a1,1
 290:	0705                	addi	a4,a4,1
 292:	fff5c683          	lbu	a3,-1(a1)
 296:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 29a:	fee79ae3          	bne	a5,a4,28e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
    dst += n;
 2a4:	00c50733          	add	a4,a0,a2
    src += n;
 2a8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2aa:	fec05ae3          	blez	a2,29e <memmove+0x2c>
 2ae:	fff6079b          	addiw	a5,a2,-1
 2b2:	1782                	slli	a5,a5,0x20
 2b4:	9381                	srli	a5,a5,0x20
 2b6:	fff7c793          	not	a5,a5
 2ba:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2bc:	15fd                	addi	a1,a1,-1
 2be:	177d                	addi	a4,a4,-1
 2c0:	0005c683          	lbu	a3,0(a1)
 2c4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c8:	fee79ae3          	bne	a5,a4,2bc <memmove+0x4a>
 2cc:	bfc9                	j	29e <memmove+0x2c>

00000000000002ce <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d4:	ca05                	beqz	a2,304 <memcmp+0x36>
 2d6:	fff6069b          	addiw	a3,a2,-1
 2da:	1682                	slli	a3,a3,0x20
 2dc:	9281                	srli	a3,a3,0x20
 2de:	0685                	addi	a3,a3,1
 2e0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e2:	00054783          	lbu	a5,0(a0)
 2e6:	0005c703          	lbu	a4,0(a1)
 2ea:	00e79863          	bne	a5,a4,2fa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ee:	0505                	addi	a0,a0,1
    p2++;
 2f0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2f2:	fed518e3          	bne	a0,a3,2e2 <memcmp+0x14>
  }
  return 0;
 2f6:	4501                	li	a0,0
 2f8:	a019                	j	2fe <memcmp+0x30>
      return *p1 - *p2;
 2fa:	40e7853b          	subw	a0,a5,a4
}
 2fe:	6422                	ld	s0,8(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
  return 0;
 304:	4501                	li	a0,0
 306:	bfe5                	j	2fe <memcmp+0x30>

0000000000000308 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 310:	00000097          	auipc	ra,0x0
 314:	f62080e7          	jalr	-158(ra) # 272 <memmove>
}
 318:	60a2                	ld	ra,8(sp)
 31a:	6402                	ld	s0,0(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret

0000000000000320 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 320:	4885                	li	a7,1
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <exit>:
.global exit
exit:
 li a7, SYS_exit
 328:	4889                	li	a7,2
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <wait>:
.global wait
wait:
 li a7, SYS_wait
 330:	488d                	li	a7,3
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 338:	4891                	li	a7,4
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <read>:
.global read
read:
 li a7, SYS_read
 340:	4895                	li	a7,5
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <write>:
.global write
write:
 li a7, SYS_write
 348:	48c1                	li	a7,16
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <close>:
.global close
close:
 li a7, SYS_close
 350:	48d5                	li	a7,21
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <kill>:
.global kill
kill:
 li a7, SYS_kill
 358:	4899                	li	a7,6
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <exec>:
.global exec
exec:
 li a7, SYS_exec
 360:	489d                	li	a7,7
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <open>:
.global open
open:
 li a7, SYS_open
 368:	48bd                	li	a7,15
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 370:	48c5                	li	a7,17
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 378:	48c9                	li	a7,18
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 380:	48a1                	li	a7,8
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <link>:
.global link
link:
 li a7, SYS_link
 388:	48cd                	li	a7,19
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 390:	48d1                	li	a7,20
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 398:	48a5                	li	a7,9
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a0:	48a9                	li	a7,10
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a8:	48ad                	li	a7,11
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b0:	48b1                	li	a7,12
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b8:	48b5                	li	a7,13
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c0:	48b9                	li	a7,14
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 3c8:	48d9                	li	a7,22
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <yield>:
.global yield
yield:
 li a7, SYS_yield
 3d0:	48dd                	li	a7,23
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 3d8:	48e1                	li	a7,24
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 3e0:	48e5                	li	a7,25
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3e8:	48e9                	li	a7,26
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <ps>:
.global ps
ps:
 li a7, SYS_ps
 3f0:	48ed                	li	a7,27
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 3f8:	48f1                	li	a7,28
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 400:	48f5                	li	a7,29
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 408:	48f9                	li	a7,30
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 410:	48fd                	li	a7,31
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 418:	02000893          	li	a7,32
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 422:	02100893          	li	a7,33
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 42c:	1101                	addi	sp,sp,-32
 42e:	ec06                	sd	ra,24(sp)
 430:	e822                	sd	s0,16(sp)
 432:	1000                	addi	s0,sp,32
 434:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 438:	4605                	li	a2,1
 43a:	fef40593          	addi	a1,s0,-17
 43e:	00000097          	auipc	ra,0x0
 442:	f0a080e7          	jalr	-246(ra) # 348 <write>
}
 446:	60e2                	ld	ra,24(sp)
 448:	6442                	ld	s0,16(sp)
 44a:	6105                	addi	sp,sp,32
 44c:	8082                	ret

000000000000044e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 44e:	7139                	addi	sp,sp,-64
 450:	fc06                	sd	ra,56(sp)
 452:	f822                	sd	s0,48(sp)
 454:	f426                	sd	s1,40(sp)
 456:	f04a                	sd	s2,32(sp)
 458:	ec4e                	sd	s3,24(sp)
 45a:	0080                	addi	s0,sp,64
 45c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 45e:	c299                	beqz	a3,464 <printint+0x16>
 460:	0805c863          	bltz	a1,4f0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 464:	2581                	sext.w	a1,a1
  neg = 0;
 466:	4881                	li	a7,0
 468:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 46c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 46e:	2601                	sext.w	a2,a2
 470:	00000517          	auipc	a0,0x0
 474:	48850513          	addi	a0,a0,1160 # 8f8 <digits>
 478:	883a                	mv	a6,a4
 47a:	2705                	addiw	a4,a4,1
 47c:	02c5f7bb          	remuw	a5,a1,a2
 480:	1782                	slli	a5,a5,0x20
 482:	9381                	srli	a5,a5,0x20
 484:	97aa                	add	a5,a5,a0
 486:	0007c783          	lbu	a5,0(a5)
 48a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 48e:	0005879b          	sext.w	a5,a1
 492:	02c5d5bb          	divuw	a1,a1,a2
 496:	0685                	addi	a3,a3,1
 498:	fec7f0e3          	bgeu	a5,a2,478 <printint+0x2a>
  if(neg)
 49c:	00088b63          	beqz	a7,4b2 <printint+0x64>
    buf[i++] = '-';
 4a0:	fd040793          	addi	a5,s0,-48
 4a4:	973e                	add	a4,a4,a5
 4a6:	02d00793          	li	a5,45
 4aa:	fef70823          	sb	a5,-16(a4)
 4ae:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4b2:	02e05863          	blez	a4,4e2 <printint+0x94>
 4b6:	fc040793          	addi	a5,s0,-64
 4ba:	00e78933          	add	s2,a5,a4
 4be:	fff78993          	addi	s3,a5,-1
 4c2:	99ba                	add	s3,s3,a4
 4c4:	377d                	addiw	a4,a4,-1
 4c6:	1702                	slli	a4,a4,0x20
 4c8:	9301                	srli	a4,a4,0x20
 4ca:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ce:	fff94583          	lbu	a1,-1(s2)
 4d2:	8526                	mv	a0,s1
 4d4:	00000097          	auipc	ra,0x0
 4d8:	f58080e7          	jalr	-168(ra) # 42c <putc>
  while(--i >= 0)
 4dc:	197d                	addi	s2,s2,-1
 4de:	ff3918e3          	bne	s2,s3,4ce <printint+0x80>
}
 4e2:	70e2                	ld	ra,56(sp)
 4e4:	7442                	ld	s0,48(sp)
 4e6:	74a2                	ld	s1,40(sp)
 4e8:	7902                	ld	s2,32(sp)
 4ea:	69e2                	ld	s3,24(sp)
 4ec:	6121                	addi	sp,sp,64
 4ee:	8082                	ret
    x = -xx;
 4f0:	40b005bb          	negw	a1,a1
    neg = 1;
 4f4:	4885                	li	a7,1
    x = -xx;
 4f6:	bf8d                	j	468 <printint+0x1a>

00000000000004f8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f8:	7119                	addi	sp,sp,-128
 4fa:	fc86                	sd	ra,120(sp)
 4fc:	f8a2                	sd	s0,112(sp)
 4fe:	f4a6                	sd	s1,104(sp)
 500:	f0ca                	sd	s2,96(sp)
 502:	ecce                	sd	s3,88(sp)
 504:	e8d2                	sd	s4,80(sp)
 506:	e4d6                	sd	s5,72(sp)
 508:	e0da                	sd	s6,64(sp)
 50a:	fc5e                	sd	s7,56(sp)
 50c:	f862                	sd	s8,48(sp)
 50e:	f466                	sd	s9,40(sp)
 510:	f06a                	sd	s10,32(sp)
 512:	ec6e                	sd	s11,24(sp)
 514:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 516:	0005c903          	lbu	s2,0(a1)
 51a:	18090f63          	beqz	s2,6b8 <vprintf+0x1c0>
 51e:	8aaa                	mv	s5,a0
 520:	8b32                	mv	s6,a2
 522:	00158493          	addi	s1,a1,1
  state = 0;
 526:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 528:	02500a13          	li	s4,37
      if(c == 'd'){
 52c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 530:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 534:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 538:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 53c:	00000b97          	auipc	s7,0x0
 540:	3bcb8b93          	addi	s7,s7,956 # 8f8 <digits>
 544:	a839                	j	562 <vprintf+0x6a>
        putc(fd, c);
 546:	85ca                	mv	a1,s2
 548:	8556                	mv	a0,s5
 54a:	00000097          	auipc	ra,0x0
 54e:	ee2080e7          	jalr	-286(ra) # 42c <putc>
 552:	a019                	j	558 <vprintf+0x60>
    } else if(state == '%'){
 554:	01498f63          	beq	s3,s4,572 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 558:	0485                	addi	s1,s1,1
 55a:	fff4c903          	lbu	s2,-1(s1)
 55e:	14090d63          	beqz	s2,6b8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 562:	0009079b          	sext.w	a5,s2
    if(state == 0){
 566:	fe0997e3          	bnez	s3,554 <vprintf+0x5c>
      if(c == '%'){
 56a:	fd479ee3          	bne	a5,s4,546 <vprintf+0x4e>
        state = '%';
 56e:	89be                	mv	s3,a5
 570:	b7e5                	j	558 <vprintf+0x60>
      if(c == 'd'){
 572:	05878063          	beq	a5,s8,5b2 <vprintf+0xba>
      } else if(c == 'l') {
 576:	05978c63          	beq	a5,s9,5ce <vprintf+0xd6>
      } else if(c == 'x') {
 57a:	07a78863          	beq	a5,s10,5ea <vprintf+0xf2>
      } else if(c == 'p') {
 57e:	09b78463          	beq	a5,s11,606 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 582:	07300713          	li	a4,115
 586:	0ce78663          	beq	a5,a4,652 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 58a:	06300713          	li	a4,99
 58e:	0ee78e63          	beq	a5,a4,68a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 592:	11478863          	beq	a5,s4,6a2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 596:	85d2                	mv	a1,s4
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e92080e7          	jalr	-366(ra) # 42c <putc>
        putc(fd, c);
 5a2:	85ca                	mv	a1,s2
 5a4:	8556                	mv	a0,s5
 5a6:	00000097          	auipc	ra,0x0
 5aa:	e86080e7          	jalr	-378(ra) # 42c <putc>
      }
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	b765                	j	558 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5b2:	008b0913          	addi	s2,s6,8
 5b6:	4685                	li	a3,1
 5b8:	4629                	li	a2,10
 5ba:	000b2583          	lw	a1,0(s6)
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	e8e080e7          	jalr	-370(ra) # 44e <printint>
 5c8:	8b4a                	mv	s6,s2
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b771                	j	558 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ce:	008b0913          	addi	s2,s6,8
 5d2:	4681                	li	a3,0
 5d4:	4629                	li	a2,10
 5d6:	000b2583          	lw	a1,0(s6)
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	e72080e7          	jalr	-398(ra) # 44e <printint>
 5e4:	8b4a                	mv	s6,s2
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	bf85                	j	558 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5ea:	008b0913          	addi	s2,s6,8
 5ee:	4681                	li	a3,0
 5f0:	4641                	li	a2,16
 5f2:	000b2583          	lw	a1,0(s6)
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	e56080e7          	jalr	-426(ra) # 44e <printint>
 600:	8b4a                	mv	s6,s2
      state = 0;
 602:	4981                	li	s3,0
 604:	bf91                	j	558 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 606:	008b0793          	addi	a5,s6,8
 60a:	f8f43423          	sd	a5,-120(s0)
 60e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 612:	03000593          	li	a1,48
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	e14080e7          	jalr	-492(ra) # 42c <putc>
  putc(fd, 'x');
 620:	85ea                	mv	a1,s10
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	e08080e7          	jalr	-504(ra) # 42c <putc>
 62c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 62e:	03c9d793          	srli	a5,s3,0x3c
 632:	97de                	add	a5,a5,s7
 634:	0007c583          	lbu	a1,0(a5)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	df2080e7          	jalr	-526(ra) # 42c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 642:	0992                	slli	s3,s3,0x4
 644:	397d                	addiw	s2,s2,-1
 646:	fe0914e3          	bnez	s2,62e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 64a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 64e:	4981                	li	s3,0
 650:	b721                	j	558 <vprintf+0x60>
        s = va_arg(ap, char*);
 652:	008b0993          	addi	s3,s6,8
 656:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 65a:	02090163          	beqz	s2,67c <vprintf+0x184>
        while(*s != 0){
 65e:	00094583          	lbu	a1,0(s2)
 662:	c9a1                	beqz	a1,6b2 <vprintf+0x1ba>
          putc(fd, *s);
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	dc6080e7          	jalr	-570(ra) # 42c <putc>
          s++;
 66e:	0905                	addi	s2,s2,1
        while(*s != 0){
 670:	00094583          	lbu	a1,0(s2)
 674:	f9e5                	bnez	a1,664 <vprintf+0x16c>
        s = va_arg(ap, char*);
 676:	8b4e                	mv	s6,s3
      state = 0;
 678:	4981                	li	s3,0
 67a:	bdf9                	j	558 <vprintf+0x60>
          s = "(null)";
 67c:	00000917          	auipc	s2,0x0
 680:	27490913          	addi	s2,s2,628 # 8f0 <malloc+0x12e>
        while(*s != 0){
 684:	02800593          	li	a1,40
 688:	bff1                	j	664 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 68a:	008b0913          	addi	s2,s6,8
 68e:	000b4583          	lbu	a1,0(s6)
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	d98080e7          	jalr	-616(ra) # 42c <putc>
 69c:	8b4a                	mv	s6,s2
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	bd65                	j	558 <vprintf+0x60>
        putc(fd, c);
 6a2:	85d2                	mv	a1,s4
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	d86080e7          	jalr	-634(ra) # 42c <putc>
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	b565                	j	558 <vprintf+0x60>
        s = va_arg(ap, char*);
 6b2:	8b4e                	mv	s6,s3
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b54d                	j	558 <vprintf+0x60>
    }
  }
}
 6b8:	70e6                	ld	ra,120(sp)
 6ba:	7446                	ld	s0,112(sp)
 6bc:	74a6                	ld	s1,104(sp)
 6be:	7906                	ld	s2,96(sp)
 6c0:	69e6                	ld	s3,88(sp)
 6c2:	6a46                	ld	s4,80(sp)
 6c4:	6aa6                	ld	s5,72(sp)
 6c6:	6b06                	ld	s6,64(sp)
 6c8:	7be2                	ld	s7,56(sp)
 6ca:	7c42                	ld	s8,48(sp)
 6cc:	7ca2                	ld	s9,40(sp)
 6ce:	7d02                	ld	s10,32(sp)
 6d0:	6de2                	ld	s11,24(sp)
 6d2:	6109                	addi	sp,sp,128
 6d4:	8082                	ret

00000000000006d6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d6:	715d                	addi	sp,sp,-80
 6d8:	ec06                	sd	ra,24(sp)
 6da:	e822                	sd	s0,16(sp)
 6dc:	1000                	addi	s0,sp,32
 6de:	e010                	sd	a2,0(s0)
 6e0:	e414                	sd	a3,8(s0)
 6e2:	e818                	sd	a4,16(s0)
 6e4:	ec1c                	sd	a5,24(s0)
 6e6:	03043023          	sd	a6,32(s0)
 6ea:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ee:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6f2:	8622                	mv	a2,s0
 6f4:	00000097          	auipc	ra,0x0
 6f8:	e04080e7          	jalr	-508(ra) # 4f8 <vprintf>
}
 6fc:	60e2                	ld	ra,24(sp)
 6fe:	6442                	ld	s0,16(sp)
 700:	6161                	addi	sp,sp,80
 702:	8082                	ret

0000000000000704 <printf>:

void
printf(const char *fmt, ...)
{
 704:	711d                	addi	sp,sp,-96
 706:	ec06                	sd	ra,24(sp)
 708:	e822                	sd	s0,16(sp)
 70a:	1000                	addi	s0,sp,32
 70c:	e40c                	sd	a1,8(s0)
 70e:	e810                	sd	a2,16(s0)
 710:	ec14                	sd	a3,24(s0)
 712:	f018                	sd	a4,32(s0)
 714:	f41c                	sd	a5,40(s0)
 716:	03043823          	sd	a6,48(s0)
 71a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 71e:	00840613          	addi	a2,s0,8
 722:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 726:	85aa                	mv	a1,a0
 728:	4505                	li	a0,1
 72a:	00000097          	auipc	ra,0x0
 72e:	dce080e7          	jalr	-562(ra) # 4f8 <vprintf>
}
 732:	60e2                	ld	ra,24(sp)
 734:	6442                	ld	s0,16(sp)
 736:	6125                	addi	sp,sp,96
 738:	8082                	ret

000000000000073a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 73a:	1141                	addi	sp,sp,-16
 73c:	e422                	sd	s0,8(sp)
 73e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 740:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 744:	00000797          	auipc	a5,0x0
 748:	1cc7b783          	ld	a5,460(a5) # 910 <freep>
 74c:	a805                	j	77c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 74e:	4618                	lw	a4,8(a2)
 750:	9db9                	addw	a1,a1,a4
 752:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 756:	6398                	ld	a4,0(a5)
 758:	6318                	ld	a4,0(a4)
 75a:	fee53823          	sd	a4,-16(a0)
 75e:	a091                	j	7a2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 760:	ff852703          	lw	a4,-8(a0)
 764:	9e39                	addw	a2,a2,a4
 766:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 768:	ff053703          	ld	a4,-16(a0)
 76c:	e398                	sd	a4,0(a5)
 76e:	a099                	j	7b4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 770:	6398                	ld	a4,0(a5)
 772:	00e7e463          	bltu	a5,a4,77a <free+0x40>
 776:	00e6ea63          	bltu	a3,a4,78a <free+0x50>
{
 77a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77c:	fed7fae3          	bgeu	a5,a3,770 <free+0x36>
 780:	6398                	ld	a4,0(a5)
 782:	00e6e463          	bltu	a3,a4,78a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 786:	fee7eae3          	bltu	a5,a4,77a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 78a:	ff852583          	lw	a1,-8(a0)
 78e:	6390                	ld	a2,0(a5)
 790:	02059713          	slli	a4,a1,0x20
 794:	9301                	srli	a4,a4,0x20
 796:	0712                	slli	a4,a4,0x4
 798:	9736                	add	a4,a4,a3
 79a:	fae60ae3          	beq	a2,a4,74e <free+0x14>
    bp->s.ptr = p->s.ptr;
 79e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a2:	4790                	lw	a2,8(a5)
 7a4:	02061713          	slli	a4,a2,0x20
 7a8:	9301                	srli	a4,a4,0x20
 7aa:	0712                	slli	a4,a4,0x4
 7ac:	973e                	add	a4,a4,a5
 7ae:	fae689e3          	beq	a3,a4,760 <free+0x26>
  } else
    p->s.ptr = bp;
 7b2:	e394                	sd	a3,0(a5)
  freep = p;
 7b4:	00000717          	auipc	a4,0x0
 7b8:	14f73e23          	sd	a5,348(a4) # 910 <freep>
}
 7bc:	6422                	ld	s0,8(sp)
 7be:	0141                	addi	sp,sp,16
 7c0:	8082                	ret

00000000000007c2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c2:	7139                	addi	sp,sp,-64
 7c4:	fc06                	sd	ra,56(sp)
 7c6:	f822                	sd	s0,48(sp)
 7c8:	f426                	sd	s1,40(sp)
 7ca:	f04a                	sd	s2,32(sp)
 7cc:	ec4e                	sd	s3,24(sp)
 7ce:	e852                	sd	s4,16(sp)
 7d0:	e456                	sd	s5,8(sp)
 7d2:	e05a                	sd	s6,0(sp)
 7d4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d6:	02051493          	slli	s1,a0,0x20
 7da:	9081                	srli	s1,s1,0x20
 7dc:	04bd                	addi	s1,s1,15
 7de:	8091                	srli	s1,s1,0x4
 7e0:	0014899b          	addiw	s3,s1,1
 7e4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7e6:	00000517          	auipc	a0,0x0
 7ea:	12a53503          	ld	a0,298(a0) # 910 <freep>
 7ee:	c515                	beqz	a0,81a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f2:	4798                	lw	a4,8(a5)
 7f4:	02977f63          	bgeu	a4,s1,832 <malloc+0x70>
 7f8:	8a4e                	mv	s4,s3
 7fa:	0009871b          	sext.w	a4,s3
 7fe:	6685                	lui	a3,0x1
 800:	00d77363          	bgeu	a4,a3,806 <malloc+0x44>
 804:	6a05                	lui	s4,0x1
 806:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 80a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 80e:	00000917          	auipc	s2,0x0
 812:	10290913          	addi	s2,s2,258 # 910 <freep>
  if(p == (char*)-1)
 816:	5afd                	li	s5,-1
 818:	a88d                	j	88a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 81a:	00000797          	auipc	a5,0x0
 81e:	0fe78793          	addi	a5,a5,254 # 918 <base>
 822:	00000717          	auipc	a4,0x0
 826:	0ef73723          	sd	a5,238(a4) # 910 <freep>
 82a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 82c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 830:	b7e1                	j	7f8 <malloc+0x36>
      if(p->s.size == nunits)
 832:	02e48b63          	beq	s1,a4,868 <malloc+0xa6>
        p->s.size -= nunits;
 836:	4137073b          	subw	a4,a4,s3
 83a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 83c:	1702                	slli	a4,a4,0x20
 83e:	9301                	srli	a4,a4,0x20
 840:	0712                	slli	a4,a4,0x4
 842:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 844:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 848:	00000717          	auipc	a4,0x0
 84c:	0ca73423          	sd	a0,200(a4) # 910 <freep>
      return (void*)(p + 1);
 850:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 854:	70e2                	ld	ra,56(sp)
 856:	7442                	ld	s0,48(sp)
 858:	74a2                	ld	s1,40(sp)
 85a:	7902                	ld	s2,32(sp)
 85c:	69e2                	ld	s3,24(sp)
 85e:	6a42                	ld	s4,16(sp)
 860:	6aa2                	ld	s5,8(sp)
 862:	6b02                	ld	s6,0(sp)
 864:	6121                	addi	sp,sp,64
 866:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 868:	6398                	ld	a4,0(a5)
 86a:	e118                	sd	a4,0(a0)
 86c:	bff1                	j	848 <malloc+0x86>
  hp->s.size = nu;
 86e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 872:	0541                	addi	a0,a0,16
 874:	00000097          	auipc	ra,0x0
 878:	ec6080e7          	jalr	-314(ra) # 73a <free>
  return freep;
 87c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 880:	d971                	beqz	a0,854 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 882:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 884:	4798                	lw	a4,8(a5)
 886:	fa9776e3          	bgeu	a4,s1,832 <malloc+0x70>
    if(p == freep)
 88a:	00093703          	ld	a4,0(s2)
 88e:	853e                	mv	a0,a5
 890:	fef719e3          	bne	a4,a5,882 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 894:	8552                	mv	a0,s4
 896:	00000097          	auipc	ra,0x0
 89a:	b1a080e7          	jalr	-1254(ra) # 3b0 <sbrk>
  if(p == (char*)-1)
 89e:	fd5518e3          	bne	a0,s5,86e <malloc+0xac>
        return 0;
 8a2:	4501                	li	a0,0
 8a4:	bf45                	j	854 <malloc+0x92>
