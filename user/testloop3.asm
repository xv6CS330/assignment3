
user/_testloop3:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define INNER_BOUND 5000000
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
  1a:	39a080e7          	jalr	922(ra) # 3b0 <getpid>
  1e:	8baa                	mv	s7,a0
    unsigned start_time, end_time;

    start_time = uptime();
  20:	00000097          	auipc	ra,0x0
  24:	3a8080e7          	jalr	936(ra) # 3c8 <uptime>
  28:	0005099b          	sext.w	s3,a0
  2c:	4a15                	li	s4,5
    int array[SIZE], i, j, k, sum=0, pid=getpid();
  2e:	4481                	li	s1,0
{
  30:	004c57b7          	lui	a5,0x4c5
  34:	b4078b13          	addi	s6,a5,-1216 # 4c4b40 <__global_pointer$+0x4c3a2f>
  38:	fb040913          	addi	s2,s0,-80
    for (k=0; k<OUTER_BOUND; k++) {
       for (j=0; j<INNER_BOUND; j++) for (i=0; i<SIZE; i++) sum += array[i];
       fprintf(1, "%d", pid);
  3c:	00001a97          	auipc	s5,0x1
  40:	874a8a93          	addi	s5,s5,-1932 # 8b0 <malloc+0xe6>
  44:	a80d                	j	76 <main+0x76>
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
  64:	67e080e7          	jalr	1662(ra) # 6de <fprintf>
       yield();
  68:	00000097          	auipc	ra,0x0
  6c:	370080e7          	jalr	880(ra) # 3d8 <yield>
    for (k=0; k<OUTER_BOUND; k++) {
  70:	3a7d                	addiw	s4,s4,-1
  72:	000a0463          	beqz	s4,7a <main+0x7a>
{
  76:	86da                	mv	a3,s6
  78:	bfc9                	j	4a <main+0x4a>
    }
    end_time = uptime();
  7a:	00000097          	auipc	ra,0x0
  7e:	34e080e7          	jalr	846(ra) # 3c8 <uptime>
  82:	0005091b          	sext.w	s2,a0
    printf("\nTotal sum: %d\n", sum);
  86:	85a6                	mv	a1,s1
  88:	00001517          	auipc	a0,0x1
  8c:	83050513          	addi	a0,a0,-2000 # 8b8 <malloc+0xee>
  90:	00000097          	auipc	ra,0x0
  94:	67c080e7          	jalr	1660(ra) # 70c <printf>
    printf("Start time: %d, End time: %d, Total time: %d\n", start_time, end_time, end_time-start_time);
  98:	413906bb          	subw	a3,s2,s3
  9c:	864a                	mv	a2,s2
  9e:	85ce                	mv	a1,s3
  a0:	00001517          	auipc	a0,0x1
  a4:	82850513          	addi	a0,a0,-2008 # 8c8 <malloc+0xfe>
  a8:	00000097          	auipc	ra,0x0
  ac:	664080e7          	jalr	1636(ra) # 70c <printf>
    exit(0);
  b0:	4501                	li	a0,0
  b2:	00000097          	auipc	ra,0x0
  b6:	27e080e7          	jalr	638(ra) # 330 <exit>

00000000000000ba <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c0:	87aa                	mv	a5,a0
  c2:	0585                	addi	a1,a1,1
  c4:	0785                	addi	a5,a5,1
  c6:	fff5c703          	lbu	a4,-1(a1)
  ca:	fee78fa3          	sb	a4,-1(a5)
  ce:	fb75                	bnez	a4,c2 <strcpy+0x8>
    ;
  return os;
}
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	addi	sp,sp,16
  d4:	8082                	ret

00000000000000d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	cb91                	beqz	a5,f4 <strcmp+0x1e>
  e2:	0005c703          	lbu	a4,0(a1)
  e6:	00f71763          	bne	a4,a5,f4 <strcmp+0x1e>
    p++, q++;
  ea:	0505                	addi	a0,a0,1
  ec:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	fbe5                	bnez	a5,e2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f4:	0005c503          	lbu	a0,0(a1)
}
  f8:	40a7853b          	subw	a0,a5,a0
  fc:	6422                	ld	s0,8(sp)
  fe:	0141                	addi	sp,sp,16
 100:	8082                	ret

0000000000000102 <strlen>:

uint
strlen(const char *s)
{
 102:	1141                	addi	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 108:	00054783          	lbu	a5,0(a0)
 10c:	cf91                	beqz	a5,128 <strlen+0x26>
 10e:	0505                	addi	a0,a0,1
 110:	87aa                	mv	a5,a0
 112:	4685                	li	a3,1
 114:	9e89                	subw	a3,a3,a0
 116:	00f6853b          	addw	a0,a3,a5
 11a:	0785                	addi	a5,a5,1
 11c:	fff7c703          	lbu	a4,-1(a5)
 120:	fb7d                	bnez	a4,116 <strlen+0x14>
    ;
  return n;
}
 122:	6422                	ld	s0,8(sp)
 124:	0141                	addi	sp,sp,16
 126:	8082                	ret
  for(n = 0; s[n]; n++)
 128:	4501                	li	a0,0
 12a:	bfe5                	j	122 <strlen+0x20>

000000000000012c <memset>:

void*
memset(void *dst, int c, uint n)
{
 12c:	1141                	addi	sp,sp,-16
 12e:	e422                	sd	s0,8(sp)
 130:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 132:	ce09                	beqz	a2,14c <memset+0x20>
 134:	87aa                	mv	a5,a0
 136:	fff6071b          	addiw	a4,a2,-1
 13a:	1702                	slli	a4,a4,0x20
 13c:	9301                	srli	a4,a4,0x20
 13e:	0705                	addi	a4,a4,1
 140:	972a                	add	a4,a4,a0
    cdst[i] = c;
 142:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 146:	0785                	addi	a5,a5,1
 148:	fee79de3          	bne	a5,a4,142 <memset+0x16>
  }
  return dst;
}
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret

0000000000000152 <strchr>:

char*
strchr(const char *s, char c)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  for(; *s; s++)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cb99                	beqz	a5,172 <strchr+0x20>
    if(*s == c)
 15e:	00f58763          	beq	a1,a5,16c <strchr+0x1a>
  for(; *s; s++)
 162:	0505                	addi	a0,a0,1
 164:	00054783          	lbu	a5,0(a0)
 168:	fbfd                	bnez	a5,15e <strchr+0xc>
      return (char*)s;
  return 0;
 16a:	4501                	li	a0,0
}
 16c:	6422                	ld	s0,8(sp)
 16e:	0141                	addi	sp,sp,16
 170:	8082                	ret
  return 0;
 172:	4501                	li	a0,0
 174:	bfe5                	j	16c <strchr+0x1a>

0000000000000176 <gets>:

char*
gets(char *buf, int max)
{
 176:	711d                	addi	sp,sp,-96
 178:	ec86                	sd	ra,88(sp)
 17a:	e8a2                	sd	s0,80(sp)
 17c:	e4a6                	sd	s1,72(sp)
 17e:	e0ca                	sd	s2,64(sp)
 180:	fc4e                	sd	s3,56(sp)
 182:	f852                	sd	s4,48(sp)
 184:	f456                	sd	s5,40(sp)
 186:	f05a                	sd	s6,32(sp)
 188:	ec5e                	sd	s7,24(sp)
 18a:	1080                	addi	s0,sp,96
 18c:	8baa                	mv	s7,a0
 18e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 190:	892a                	mv	s2,a0
 192:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 194:	4aa9                	li	s5,10
 196:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 198:	89a6                	mv	s3,s1
 19a:	2485                	addiw	s1,s1,1
 19c:	0344d863          	bge	s1,s4,1cc <gets+0x56>
    cc = read(0, &c, 1);
 1a0:	4605                	li	a2,1
 1a2:	faf40593          	addi	a1,s0,-81
 1a6:	4501                	li	a0,0
 1a8:	00000097          	auipc	ra,0x0
 1ac:	1a0080e7          	jalr	416(ra) # 348 <read>
    if(cc < 1)
 1b0:	00a05e63          	blez	a0,1cc <gets+0x56>
    buf[i++] = c;
 1b4:	faf44783          	lbu	a5,-81(s0)
 1b8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1bc:	01578763          	beq	a5,s5,1ca <gets+0x54>
 1c0:	0905                	addi	s2,s2,1
 1c2:	fd679be3          	bne	a5,s6,198 <gets+0x22>
  for(i=0; i+1 < max; ){
 1c6:	89a6                	mv	s3,s1
 1c8:	a011                	j	1cc <gets+0x56>
 1ca:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1cc:	99de                	add	s3,s3,s7
 1ce:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d2:	855e                	mv	a0,s7
 1d4:	60e6                	ld	ra,88(sp)
 1d6:	6446                	ld	s0,80(sp)
 1d8:	64a6                	ld	s1,72(sp)
 1da:	6906                	ld	s2,64(sp)
 1dc:	79e2                	ld	s3,56(sp)
 1de:	7a42                	ld	s4,48(sp)
 1e0:	7aa2                	ld	s5,40(sp)
 1e2:	7b02                	ld	s6,32(sp)
 1e4:	6be2                	ld	s7,24(sp)
 1e6:	6125                	addi	sp,sp,96
 1e8:	8082                	ret

00000000000001ea <stat>:

int
stat(const char *n, struct stat *st)
{
 1ea:	1101                	addi	sp,sp,-32
 1ec:	ec06                	sd	ra,24(sp)
 1ee:	e822                	sd	s0,16(sp)
 1f0:	e426                	sd	s1,8(sp)
 1f2:	e04a                	sd	s2,0(sp)
 1f4:	1000                	addi	s0,sp,32
 1f6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f8:	4581                	li	a1,0
 1fa:	00000097          	auipc	ra,0x0
 1fe:	176080e7          	jalr	374(ra) # 370 <open>
  if(fd < 0)
 202:	02054563          	bltz	a0,22c <stat+0x42>
 206:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 208:	85ca                	mv	a1,s2
 20a:	00000097          	auipc	ra,0x0
 20e:	17e080e7          	jalr	382(ra) # 388 <fstat>
 212:	892a                	mv	s2,a0
  close(fd);
 214:	8526                	mv	a0,s1
 216:	00000097          	auipc	ra,0x0
 21a:	142080e7          	jalr	322(ra) # 358 <close>
  return r;
}
 21e:	854a                	mv	a0,s2
 220:	60e2                	ld	ra,24(sp)
 222:	6442                	ld	s0,16(sp)
 224:	64a2                	ld	s1,8(sp)
 226:	6902                	ld	s2,0(sp)
 228:	6105                	addi	sp,sp,32
 22a:	8082                	ret
    return -1;
 22c:	597d                	li	s2,-1
 22e:	bfc5                	j	21e <stat+0x34>

0000000000000230 <atoi>:

int
atoi(const char *s)
{
 230:	1141                	addi	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 236:	00054603          	lbu	a2,0(a0)
 23a:	fd06079b          	addiw	a5,a2,-48
 23e:	0ff7f793          	andi	a5,a5,255
 242:	4725                	li	a4,9
 244:	02f76963          	bltu	a4,a5,276 <atoi+0x46>
 248:	86aa                	mv	a3,a0
  n = 0;
 24a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 24c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 24e:	0685                	addi	a3,a3,1
 250:	0025179b          	slliw	a5,a0,0x2
 254:	9fa9                	addw	a5,a5,a0
 256:	0017979b          	slliw	a5,a5,0x1
 25a:	9fb1                	addw	a5,a5,a2
 25c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 260:	0006c603          	lbu	a2,0(a3)
 264:	fd06071b          	addiw	a4,a2,-48
 268:	0ff77713          	andi	a4,a4,255
 26c:	fee5f1e3          	bgeu	a1,a4,24e <atoi+0x1e>
  return n;
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret
  n = 0;
 276:	4501                	li	a0,0
 278:	bfe5                	j	270 <atoi+0x40>

000000000000027a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27a:	1141                	addi	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 280:	02b57663          	bgeu	a0,a1,2ac <memmove+0x32>
    while(n-- > 0)
 284:	02c05163          	blez	a2,2a6 <memmove+0x2c>
 288:	fff6079b          	addiw	a5,a2,-1
 28c:	1782                	slli	a5,a5,0x20
 28e:	9381                	srli	a5,a5,0x20
 290:	0785                	addi	a5,a5,1
 292:	97aa                	add	a5,a5,a0
  dst = vdst;
 294:	872a                	mv	a4,a0
      *dst++ = *src++;
 296:	0585                	addi	a1,a1,1
 298:	0705                	addi	a4,a4,1
 29a:	fff5c683          	lbu	a3,-1(a1)
 29e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a2:	fee79ae3          	bne	a5,a4,296 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
    dst += n;
 2ac:	00c50733          	add	a4,a0,a2
    src += n;
 2b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b2:	fec05ae3          	blez	a2,2a6 <memmove+0x2c>
 2b6:	fff6079b          	addiw	a5,a2,-1
 2ba:	1782                	slli	a5,a5,0x20
 2bc:	9381                	srli	a5,a5,0x20
 2be:	fff7c793          	not	a5,a5
 2c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c4:	15fd                	addi	a1,a1,-1
 2c6:	177d                	addi	a4,a4,-1
 2c8:	0005c683          	lbu	a3,0(a1)
 2cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d0:	fee79ae3          	bne	a5,a4,2c4 <memmove+0x4a>
 2d4:	bfc9                	j	2a6 <memmove+0x2c>

00000000000002d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2dc:	ca05                	beqz	a2,30c <memcmp+0x36>
 2de:	fff6069b          	addiw	a3,a2,-1
 2e2:	1682                	slli	a3,a3,0x20
 2e4:	9281                	srli	a3,a3,0x20
 2e6:	0685                	addi	a3,a3,1
 2e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ea:	00054783          	lbu	a5,0(a0)
 2ee:	0005c703          	lbu	a4,0(a1)
 2f2:	00e79863          	bne	a5,a4,302 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f6:	0505                	addi	a0,a0,1
    p2++;
 2f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2fa:	fed518e3          	bne	a0,a3,2ea <memcmp+0x14>
  }
  return 0;
 2fe:	4501                	li	a0,0
 300:	a019                	j	306 <memcmp+0x30>
      return *p1 - *p2;
 302:	40e7853b          	subw	a0,a5,a4
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  return 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <memcmp+0x30>

0000000000000310 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 318:	00000097          	auipc	ra,0x0
 31c:	f62080e7          	jalr	-158(ra) # 27a <memmove>
}
 320:	60a2                	ld	ra,8(sp)
 322:	6402                	ld	s0,0(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret

0000000000000328 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 328:	4885                	li	a7,1
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <exit>:
.global exit
exit:
 li a7, SYS_exit
 330:	4889                	li	a7,2
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <wait>:
.global wait
wait:
 li a7, SYS_wait
 338:	488d                	li	a7,3
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 340:	4891                	li	a7,4
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <read>:
.global read
read:
 li a7, SYS_read
 348:	4895                	li	a7,5
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <write>:
.global write
write:
 li a7, SYS_write
 350:	48c1                	li	a7,16
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <close>:
.global close
close:
 li a7, SYS_close
 358:	48d5                	li	a7,21
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <kill>:
.global kill
kill:
 li a7, SYS_kill
 360:	4899                	li	a7,6
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <exec>:
.global exec
exec:
 li a7, SYS_exec
 368:	489d                	li	a7,7
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <open>:
.global open
open:
 li a7, SYS_open
 370:	48bd                	li	a7,15
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 378:	48c5                	li	a7,17
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 380:	48c9                	li	a7,18
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 388:	48a1                	li	a7,8
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <link>:
.global link
link:
 li a7, SYS_link
 390:	48cd                	li	a7,19
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 398:	48d1                	li	a7,20
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a0:	48a5                	li	a7,9
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a8:	48a9                	li	a7,10
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b0:	48ad                	li	a7,11
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b8:	48b1                	li	a7,12
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3c0:	48b5                	li	a7,13
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c8:	48b9                	li	a7,14
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 3d0:	48d9                	li	a7,22
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <yield>:
.global yield
yield:
 li a7, SYS_yield
 3d8:	48dd                	li	a7,23
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 3e0:	48e1                	li	a7,24
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 3e8:	48e5                	li	a7,25
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3f0:	48e9                	li	a7,26
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <ps>:
.global ps
ps:
 li a7, SYS_ps
 3f8:	48ed                	li	a7,27
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 400:	48f1                	li	a7,28
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 408:	48f5                	li	a7,29
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 410:	48f9                	li	a7,30
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 418:	48fd                	li	a7,31
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 420:	02000893          	li	a7,32
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 42a:	02100893          	li	a7,33
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 434:	1101                	addi	sp,sp,-32
 436:	ec06                	sd	ra,24(sp)
 438:	e822                	sd	s0,16(sp)
 43a:	1000                	addi	s0,sp,32
 43c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 440:	4605                	li	a2,1
 442:	fef40593          	addi	a1,s0,-17
 446:	00000097          	auipc	ra,0x0
 44a:	f0a080e7          	jalr	-246(ra) # 350 <write>
}
 44e:	60e2                	ld	ra,24(sp)
 450:	6442                	ld	s0,16(sp)
 452:	6105                	addi	sp,sp,32
 454:	8082                	ret

0000000000000456 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 456:	7139                	addi	sp,sp,-64
 458:	fc06                	sd	ra,56(sp)
 45a:	f822                	sd	s0,48(sp)
 45c:	f426                	sd	s1,40(sp)
 45e:	f04a                	sd	s2,32(sp)
 460:	ec4e                	sd	s3,24(sp)
 462:	0080                	addi	s0,sp,64
 464:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 466:	c299                	beqz	a3,46c <printint+0x16>
 468:	0805c863          	bltz	a1,4f8 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 46c:	2581                	sext.w	a1,a1
  neg = 0;
 46e:	4881                	li	a7,0
 470:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 474:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 476:	2601                	sext.w	a2,a2
 478:	00000517          	auipc	a0,0x0
 47c:	48850513          	addi	a0,a0,1160 # 900 <digits>
 480:	883a                	mv	a6,a4
 482:	2705                	addiw	a4,a4,1
 484:	02c5f7bb          	remuw	a5,a1,a2
 488:	1782                	slli	a5,a5,0x20
 48a:	9381                	srli	a5,a5,0x20
 48c:	97aa                	add	a5,a5,a0
 48e:	0007c783          	lbu	a5,0(a5)
 492:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 496:	0005879b          	sext.w	a5,a1
 49a:	02c5d5bb          	divuw	a1,a1,a2
 49e:	0685                	addi	a3,a3,1
 4a0:	fec7f0e3          	bgeu	a5,a2,480 <printint+0x2a>
  if(neg)
 4a4:	00088b63          	beqz	a7,4ba <printint+0x64>
    buf[i++] = '-';
 4a8:	fd040793          	addi	a5,s0,-48
 4ac:	973e                	add	a4,a4,a5
 4ae:	02d00793          	li	a5,45
 4b2:	fef70823          	sb	a5,-16(a4)
 4b6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ba:	02e05863          	blez	a4,4ea <printint+0x94>
 4be:	fc040793          	addi	a5,s0,-64
 4c2:	00e78933          	add	s2,a5,a4
 4c6:	fff78993          	addi	s3,a5,-1
 4ca:	99ba                	add	s3,s3,a4
 4cc:	377d                	addiw	a4,a4,-1
 4ce:	1702                	slli	a4,a4,0x20
 4d0:	9301                	srli	a4,a4,0x20
 4d2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4d6:	fff94583          	lbu	a1,-1(s2)
 4da:	8526                	mv	a0,s1
 4dc:	00000097          	auipc	ra,0x0
 4e0:	f58080e7          	jalr	-168(ra) # 434 <putc>
  while(--i >= 0)
 4e4:	197d                	addi	s2,s2,-1
 4e6:	ff3918e3          	bne	s2,s3,4d6 <printint+0x80>
}
 4ea:	70e2                	ld	ra,56(sp)
 4ec:	7442                	ld	s0,48(sp)
 4ee:	74a2                	ld	s1,40(sp)
 4f0:	7902                	ld	s2,32(sp)
 4f2:	69e2                	ld	s3,24(sp)
 4f4:	6121                	addi	sp,sp,64
 4f6:	8082                	ret
    x = -xx;
 4f8:	40b005bb          	negw	a1,a1
    neg = 1;
 4fc:	4885                	li	a7,1
    x = -xx;
 4fe:	bf8d                	j	470 <printint+0x1a>

0000000000000500 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 500:	7119                	addi	sp,sp,-128
 502:	fc86                	sd	ra,120(sp)
 504:	f8a2                	sd	s0,112(sp)
 506:	f4a6                	sd	s1,104(sp)
 508:	f0ca                	sd	s2,96(sp)
 50a:	ecce                	sd	s3,88(sp)
 50c:	e8d2                	sd	s4,80(sp)
 50e:	e4d6                	sd	s5,72(sp)
 510:	e0da                	sd	s6,64(sp)
 512:	fc5e                	sd	s7,56(sp)
 514:	f862                	sd	s8,48(sp)
 516:	f466                	sd	s9,40(sp)
 518:	f06a                	sd	s10,32(sp)
 51a:	ec6e                	sd	s11,24(sp)
 51c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 51e:	0005c903          	lbu	s2,0(a1)
 522:	18090f63          	beqz	s2,6c0 <vprintf+0x1c0>
 526:	8aaa                	mv	s5,a0
 528:	8b32                	mv	s6,a2
 52a:	00158493          	addi	s1,a1,1
  state = 0;
 52e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 530:	02500a13          	li	s4,37
      if(c == 'd'){
 534:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 538:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 53c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 540:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 544:	00000b97          	auipc	s7,0x0
 548:	3bcb8b93          	addi	s7,s7,956 # 900 <digits>
 54c:	a839                	j	56a <vprintf+0x6a>
        putc(fd, c);
 54e:	85ca                	mv	a1,s2
 550:	8556                	mv	a0,s5
 552:	00000097          	auipc	ra,0x0
 556:	ee2080e7          	jalr	-286(ra) # 434 <putc>
 55a:	a019                	j	560 <vprintf+0x60>
    } else if(state == '%'){
 55c:	01498f63          	beq	s3,s4,57a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 560:	0485                	addi	s1,s1,1
 562:	fff4c903          	lbu	s2,-1(s1)
 566:	14090d63          	beqz	s2,6c0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 56a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 56e:	fe0997e3          	bnez	s3,55c <vprintf+0x5c>
      if(c == '%'){
 572:	fd479ee3          	bne	a5,s4,54e <vprintf+0x4e>
        state = '%';
 576:	89be                	mv	s3,a5
 578:	b7e5                	j	560 <vprintf+0x60>
      if(c == 'd'){
 57a:	05878063          	beq	a5,s8,5ba <vprintf+0xba>
      } else if(c == 'l') {
 57e:	05978c63          	beq	a5,s9,5d6 <vprintf+0xd6>
      } else if(c == 'x') {
 582:	07a78863          	beq	a5,s10,5f2 <vprintf+0xf2>
      } else if(c == 'p') {
 586:	09b78463          	beq	a5,s11,60e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 58a:	07300713          	li	a4,115
 58e:	0ce78663          	beq	a5,a4,65a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 592:	06300713          	li	a4,99
 596:	0ee78e63          	beq	a5,a4,692 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 59a:	11478863          	beq	a5,s4,6aa <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 59e:	85d2                	mv	a1,s4
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e92080e7          	jalr	-366(ra) # 434 <putc>
        putc(fd, c);
 5aa:	85ca                	mv	a1,s2
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	e86080e7          	jalr	-378(ra) # 434 <putc>
      }
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b765                	j	560 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5ba:	008b0913          	addi	s2,s6,8
 5be:	4685                	li	a3,1
 5c0:	4629                	li	a2,10
 5c2:	000b2583          	lw	a1,0(s6)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e8e080e7          	jalr	-370(ra) # 456 <printint>
 5d0:	8b4a                	mv	s6,s2
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b771                	j	560 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d6:	008b0913          	addi	s2,s6,8
 5da:	4681                	li	a3,0
 5dc:	4629                	li	a2,10
 5de:	000b2583          	lw	a1,0(s6)
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	e72080e7          	jalr	-398(ra) # 456 <printint>
 5ec:	8b4a                	mv	s6,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bf85                	j	560 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5f2:	008b0913          	addi	s2,s6,8
 5f6:	4681                	li	a3,0
 5f8:	4641                	li	a2,16
 5fa:	000b2583          	lw	a1,0(s6)
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e56080e7          	jalr	-426(ra) # 456 <printint>
 608:	8b4a                	mv	s6,s2
      state = 0;
 60a:	4981                	li	s3,0
 60c:	bf91                	j	560 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 60e:	008b0793          	addi	a5,s6,8
 612:	f8f43423          	sd	a5,-120(s0)
 616:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 61a:	03000593          	li	a1,48
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	e14080e7          	jalr	-492(ra) # 434 <putc>
  putc(fd, 'x');
 628:	85ea                	mv	a1,s10
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e08080e7          	jalr	-504(ra) # 434 <putc>
 634:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 636:	03c9d793          	srli	a5,s3,0x3c
 63a:	97de                	add	a5,a5,s7
 63c:	0007c583          	lbu	a1,0(a5)
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	df2080e7          	jalr	-526(ra) # 434 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 64a:	0992                	slli	s3,s3,0x4
 64c:	397d                	addiw	s2,s2,-1
 64e:	fe0914e3          	bnez	s2,636 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 652:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 656:	4981                	li	s3,0
 658:	b721                	j	560 <vprintf+0x60>
        s = va_arg(ap, char*);
 65a:	008b0993          	addi	s3,s6,8
 65e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 662:	02090163          	beqz	s2,684 <vprintf+0x184>
        while(*s != 0){
 666:	00094583          	lbu	a1,0(s2)
 66a:	c9a1                	beqz	a1,6ba <vprintf+0x1ba>
          putc(fd, *s);
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	dc6080e7          	jalr	-570(ra) # 434 <putc>
          s++;
 676:	0905                	addi	s2,s2,1
        while(*s != 0){
 678:	00094583          	lbu	a1,0(s2)
 67c:	f9e5                	bnez	a1,66c <vprintf+0x16c>
        s = va_arg(ap, char*);
 67e:	8b4e                	mv	s6,s3
      state = 0;
 680:	4981                	li	s3,0
 682:	bdf9                	j	560 <vprintf+0x60>
          s = "(null)";
 684:	00000917          	auipc	s2,0x0
 688:	27490913          	addi	s2,s2,628 # 8f8 <malloc+0x12e>
        while(*s != 0){
 68c:	02800593          	li	a1,40
 690:	bff1                	j	66c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 692:	008b0913          	addi	s2,s6,8
 696:	000b4583          	lbu	a1,0(s6)
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	d98080e7          	jalr	-616(ra) # 434 <putc>
 6a4:	8b4a                	mv	s6,s2
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bd65                	j	560 <vprintf+0x60>
        putc(fd, c);
 6aa:	85d2                	mv	a1,s4
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	d86080e7          	jalr	-634(ra) # 434 <putc>
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	b565                	j	560 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ba:	8b4e                	mv	s6,s3
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	b54d                	j	560 <vprintf+0x60>
    }
  }
}
 6c0:	70e6                	ld	ra,120(sp)
 6c2:	7446                	ld	s0,112(sp)
 6c4:	74a6                	ld	s1,104(sp)
 6c6:	7906                	ld	s2,96(sp)
 6c8:	69e6                	ld	s3,88(sp)
 6ca:	6a46                	ld	s4,80(sp)
 6cc:	6aa6                	ld	s5,72(sp)
 6ce:	6b06                	ld	s6,64(sp)
 6d0:	7be2                	ld	s7,56(sp)
 6d2:	7c42                	ld	s8,48(sp)
 6d4:	7ca2                	ld	s9,40(sp)
 6d6:	7d02                	ld	s10,32(sp)
 6d8:	6de2                	ld	s11,24(sp)
 6da:	6109                	addi	sp,sp,128
 6dc:	8082                	ret

00000000000006de <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6de:	715d                	addi	sp,sp,-80
 6e0:	ec06                	sd	ra,24(sp)
 6e2:	e822                	sd	s0,16(sp)
 6e4:	1000                	addi	s0,sp,32
 6e6:	e010                	sd	a2,0(s0)
 6e8:	e414                	sd	a3,8(s0)
 6ea:	e818                	sd	a4,16(s0)
 6ec:	ec1c                	sd	a5,24(s0)
 6ee:	03043023          	sd	a6,32(s0)
 6f2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6fa:	8622                	mv	a2,s0
 6fc:	00000097          	auipc	ra,0x0
 700:	e04080e7          	jalr	-508(ra) # 500 <vprintf>
}
 704:	60e2                	ld	ra,24(sp)
 706:	6442                	ld	s0,16(sp)
 708:	6161                	addi	sp,sp,80
 70a:	8082                	ret

000000000000070c <printf>:

void
printf(const char *fmt, ...)
{
 70c:	711d                	addi	sp,sp,-96
 70e:	ec06                	sd	ra,24(sp)
 710:	e822                	sd	s0,16(sp)
 712:	1000                	addi	s0,sp,32
 714:	e40c                	sd	a1,8(s0)
 716:	e810                	sd	a2,16(s0)
 718:	ec14                	sd	a3,24(s0)
 71a:	f018                	sd	a4,32(s0)
 71c:	f41c                	sd	a5,40(s0)
 71e:	03043823          	sd	a6,48(s0)
 722:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 726:	00840613          	addi	a2,s0,8
 72a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 72e:	85aa                	mv	a1,a0
 730:	4505                	li	a0,1
 732:	00000097          	auipc	ra,0x0
 736:	dce080e7          	jalr	-562(ra) # 500 <vprintf>
}
 73a:	60e2                	ld	ra,24(sp)
 73c:	6442                	ld	s0,16(sp)
 73e:	6125                	addi	sp,sp,96
 740:	8082                	ret

0000000000000742 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 742:	1141                	addi	sp,sp,-16
 744:	e422                	sd	s0,8(sp)
 746:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 748:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74c:	00000797          	auipc	a5,0x0
 750:	1cc7b783          	ld	a5,460(a5) # 918 <freep>
 754:	a805                	j	784 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 756:	4618                	lw	a4,8(a2)
 758:	9db9                	addw	a1,a1,a4
 75a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 75e:	6398                	ld	a4,0(a5)
 760:	6318                	ld	a4,0(a4)
 762:	fee53823          	sd	a4,-16(a0)
 766:	a091                	j	7aa <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 768:	ff852703          	lw	a4,-8(a0)
 76c:	9e39                	addw	a2,a2,a4
 76e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 770:	ff053703          	ld	a4,-16(a0)
 774:	e398                	sd	a4,0(a5)
 776:	a099                	j	7bc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 778:	6398                	ld	a4,0(a5)
 77a:	00e7e463          	bltu	a5,a4,782 <free+0x40>
 77e:	00e6ea63          	bltu	a3,a4,792 <free+0x50>
{
 782:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 784:	fed7fae3          	bgeu	a5,a3,778 <free+0x36>
 788:	6398                	ld	a4,0(a5)
 78a:	00e6e463          	bltu	a3,a4,792 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78e:	fee7eae3          	bltu	a5,a4,782 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 792:	ff852583          	lw	a1,-8(a0)
 796:	6390                	ld	a2,0(a5)
 798:	02059713          	slli	a4,a1,0x20
 79c:	9301                	srli	a4,a4,0x20
 79e:	0712                	slli	a4,a4,0x4
 7a0:	9736                	add	a4,a4,a3
 7a2:	fae60ae3          	beq	a2,a4,756 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7a6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7aa:	4790                	lw	a2,8(a5)
 7ac:	02061713          	slli	a4,a2,0x20
 7b0:	9301                	srli	a4,a4,0x20
 7b2:	0712                	slli	a4,a4,0x4
 7b4:	973e                	add	a4,a4,a5
 7b6:	fae689e3          	beq	a3,a4,768 <free+0x26>
  } else
    p->s.ptr = bp;
 7ba:	e394                	sd	a3,0(a5)
  freep = p;
 7bc:	00000717          	auipc	a4,0x0
 7c0:	14f73e23          	sd	a5,348(a4) # 918 <freep>
}
 7c4:	6422                	ld	s0,8(sp)
 7c6:	0141                	addi	sp,sp,16
 7c8:	8082                	ret

00000000000007ca <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ca:	7139                	addi	sp,sp,-64
 7cc:	fc06                	sd	ra,56(sp)
 7ce:	f822                	sd	s0,48(sp)
 7d0:	f426                	sd	s1,40(sp)
 7d2:	f04a                	sd	s2,32(sp)
 7d4:	ec4e                	sd	s3,24(sp)
 7d6:	e852                	sd	s4,16(sp)
 7d8:	e456                	sd	s5,8(sp)
 7da:	e05a                	sd	s6,0(sp)
 7dc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7de:	02051493          	slli	s1,a0,0x20
 7e2:	9081                	srli	s1,s1,0x20
 7e4:	04bd                	addi	s1,s1,15
 7e6:	8091                	srli	s1,s1,0x4
 7e8:	0014899b          	addiw	s3,s1,1
 7ec:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7ee:	00000517          	auipc	a0,0x0
 7f2:	12a53503          	ld	a0,298(a0) # 918 <freep>
 7f6:	c515                	beqz	a0,822 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fa:	4798                	lw	a4,8(a5)
 7fc:	02977f63          	bgeu	a4,s1,83a <malloc+0x70>
 800:	8a4e                	mv	s4,s3
 802:	0009871b          	sext.w	a4,s3
 806:	6685                	lui	a3,0x1
 808:	00d77363          	bgeu	a4,a3,80e <malloc+0x44>
 80c:	6a05                	lui	s4,0x1
 80e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 812:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 816:	00000917          	auipc	s2,0x0
 81a:	10290913          	addi	s2,s2,258 # 918 <freep>
  if(p == (char*)-1)
 81e:	5afd                	li	s5,-1
 820:	a88d                	j	892 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 822:	00000797          	auipc	a5,0x0
 826:	0fe78793          	addi	a5,a5,254 # 920 <base>
 82a:	00000717          	auipc	a4,0x0
 82e:	0ef73723          	sd	a5,238(a4) # 918 <freep>
 832:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 834:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 838:	b7e1                	j	800 <malloc+0x36>
      if(p->s.size == nunits)
 83a:	02e48b63          	beq	s1,a4,870 <malloc+0xa6>
        p->s.size -= nunits;
 83e:	4137073b          	subw	a4,a4,s3
 842:	c798                	sw	a4,8(a5)
        p += p->s.size;
 844:	1702                	slli	a4,a4,0x20
 846:	9301                	srli	a4,a4,0x20
 848:	0712                	slli	a4,a4,0x4
 84a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 84c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 850:	00000717          	auipc	a4,0x0
 854:	0ca73423          	sd	a0,200(a4) # 918 <freep>
      return (void*)(p + 1);
 858:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 85c:	70e2                	ld	ra,56(sp)
 85e:	7442                	ld	s0,48(sp)
 860:	74a2                	ld	s1,40(sp)
 862:	7902                	ld	s2,32(sp)
 864:	69e2                	ld	s3,24(sp)
 866:	6a42                	ld	s4,16(sp)
 868:	6aa2                	ld	s5,8(sp)
 86a:	6b02                	ld	s6,0(sp)
 86c:	6121                	addi	sp,sp,64
 86e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 870:	6398                	ld	a4,0(a5)
 872:	e118                	sd	a4,0(a0)
 874:	bff1                	j	850 <malloc+0x86>
  hp->s.size = nu;
 876:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 87a:	0541                	addi	a0,a0,16
 87c:	00000097          	auipc	ra,0x0
 880:	ec6080e7          	jalr	-314(ra) # 742 <free>
  return freep;
 884:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 888:	d971                	beqz	a0,85c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88c:	4798                	lw	a4,8(a5)
 88e:	fa9776e3          	bgeu	a4,s1,83a <malloc+0x70>
    if(p == freep)
 892:	00093703          	ld	a4,0(s2)
 896:	853e                	mv	a0,a5
 898:	fef719e3          	bne	a4,a5,88a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 89c:	8552                	mv	a0,s4
 89e:	00000097          	auipc	ra,0x0
 8a2:	b1a080e7          	jalr	-1254(ra) # 3b8 <sbrk>
  if(p == (char*)-1)
 8a6:	fd5518e3          	bne	a0,s5,876 <malloc+0xac>
        return 0;
 8aa:	4501                	li	a0,0
 8ac:	bf45                	j	85c <malloc+0x92>
