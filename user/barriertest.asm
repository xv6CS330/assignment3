
user/_barriertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	e45e                	sd	s7,8(sp)
  14:	0880                	addi	s0,sp,80
  int i, j, n, r, barrier_id;

  if (argc != 3) {
  16:	478d                	li	a5,3
  18:	02f50063          	beq	a0,a5,38 <main+0x38>
     fprintf(2, "syntax: barriertest numprocs numrounds\nAborting...\n");
  1c:	00001597          	auipc	a1,0x1
  20:	92458593          	addi	a1,a1,-1756 # 940 <malloc+0xec>
  24:	4509                	li	a0,2
  26:	00000097          	auipc	ra,0x0
  2a:	748080e7          	jalr	1864(ra) # 76e <fprintf>
     exit(0);
  2e:	4501                	li	a0,0
  30:	00000097          	auipc	ra,0x0
  34:	352080e7          	jalr	850(ra) # 382 <exit>
  38:	84ae                	mv	s1,a1
  }

  n = atoi(argv[1]);
  3a:	6588                	ld	a0,8(a1)
  3c:	00000097          	auipc	ra,0x0
  40:	24c080e7          	jalr	588(ra) # 288 <atoi>
  44:	89aa                	mv	s3,a0
  r = atoi(argv[2]);
  46:	6888                	ld	a0,16(s1)
  48:	00000097          	auipc	ra,0x0
  4c:	240080e7          	jalr	576(ra) # 288 <atoi>
  50:	8aaa                	mv	s5,a0
  barrier_id = barrier_alloc();
  52:	00000097          	auipc	ra,0x0
  56:	418080e7          	jalr	1048(ra) # 46a <barrier_alloc>
  5a:	8a2a                	mv	s4,a0
  fprintf(1, "%d: got barrier array id %d\n\n", getpid(), barrier_id);
  5c:	00000097          	auipc	ra,0x0
  60:	3a6080e7          	jalr	934(ra) # 402 <getpid>
  64:	862a                	mv	a2,a0
  66:	86d2                	mv	a3,s4
  68:	00001597          	auipc	a1,0x1
  6c:	91058593          	addi	a1,a1,-1776 # 978 <malloc+0x124>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	6fc080e7          	jalr	1788(ra) # 76e <fprintf>
   printf("%dyo\n",n);
  7a:	85ce                	mv	a1,s3
  7c:	00001517          	auipc	a0,0x1
  80:	91c50513          	addi	a0,a0,-1764 # 998 <malloc+0x144>
  84:	00000097          	auipc	ra,0x0
  88:	718080e7          	jalr	1816(ra) # 79c <printf>
  for (i=0; i<n-1; i++) {
  8c:	fff98b9b          	addiw	s7,s3,-1
  90:	09705063          	blez	s7,110 <main+0x110>
  94:	8b5e                	mv	s6,s7
  96:	4901                	li	s2,0
     if (fork() == 0) {
  98:	00000097          	auipc	ra,0x0
  9c:	2e2080e7          	jalr	738(ra) # 37a <fork>
  a0:	84aa                	mv	s1,a0
  a2:	c531                	beqz	a0,ee <main+0xee>
  for (i=0; i<n-1; i++) {
  a4:	2905                	addiw	s2,s2,1
  a6:	ff2b19e3          	bne	s6,s2,98 <main+0x98>
	   barrier(j, barrier_id, n);
	}
	exit(0);
     }
  }
  for (j=0; j<r; j++) {
  aa:	01505f63          	blez	s5,c8 <main+0xc8>
  ae:	4481                	li	s1,0
     barrier(j, barrier_id, n);
  b0:	864e                	mv	a2,s3
  b2:	85d2                	mv	a1,s4
  b4:	8526                	mv	a0,s1
  b6:	00000097          	auipc	ra,0x0
  ba:	3bc080e7          	jalr	956(ra) # 472 <barrier>
  for (j=0; j<r; j++) {
  be:	2485                	addiw	s1,s1,1
  c0:	ff54c8e3          	blt	s1,s5,b0 <main+0xb0>
  }
  for (i=0; i<n-1; i++) wait(0);
  c4:	01705b63          	blez	s7,da <main+0xda>
  for (j=0; j<r; j++) {
  c8:	4481                	li	s1,0
  for (i=0; i<n-1; i++) wait(0);
  ca:	4501                	li	a0,0
  cc:	00000097          	auipc	ra,0x0
  d0:	2be080e7          	jalr	702(ra) # 38a <wait>
  d4:	2485                	addiw	s1,s1,1
  d6:	ff74cae3          	blt	s1,s7,ca <main+0xca>
  barrier_free(barrier_id);
  da:	8552                	mv	a0,s4
  dc:	00000097          	auipc	ra,0x0
  e0:	3a0080e7          	jalr	928(ra) # 47c <barrier_free>
  exit(0);
  e4:	4501                	li	a0,0
  e6:	00000097          	auipc	ra,0x0
  ea:	29c080e7          	jalr	668(ra) # 382 <exit>
        for (j=0; j<r; j++) {
  ee:	01505c63          	blez	s5,106 <main+0x106>
	   barrier(j, barrier_id, n);
  f2:	864e                	mv	a2,s3
  f4:	85d2                	mv	a1,s4
  f6:	8526                	mv	a0,s1
  f8:	00000097          	auipc	ra,0x0
  fc:	37a080e7          	jalr	890(ra) # 472 <barrier>
        for (j=0; j<r; j++) {
 100:	2485                	addiw	s1,s1,1
 102:	fe9a98e3          	bne	s5,s1,f2 <main+0xf2>
	exit(0);
 106:	4501                	li	a0,0
 108:	00000097          	auipc	ra,0x0
 10c:	27a080e7          	jalr	634(ra) # 382 <exit>
  for (j=0; j<r; j++) {
 110:	f9504fe3          	bgtz	s5,ae <main+0xae>
 114:	b7d9                	j	da <main+0xda>

0000000000000116 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11c:	87aa                	mv	a5,a0
 11e:	0585                	addi	a1,a1,1
 120:	0785                	addi	a5,a5,1
 122:	fff5c703          	lbu	a4,-1(a1)
 126:	fee78fa3          	sb	a4,-1(a5)
 12a:	fb75                	bnez	a4,11e <strcpy+0x8>
    ;
  return os;
}
 12c:	6422                	ld	s0,8(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret

0000000000000132 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 132:	1141                	addi	sp,sp,-16
 134:	e422                	sd	s0,8(sp)
 136:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 138:	00054783          	lbu	a5,0(a0)
 13c:	cb91                	beqz	a5,150 <strcmp+0x1e>
 13e:	0005c703          	lbu	a4,0(a1)
 142:	00f71763          	bne	a4,a5,150 <strcmp+0x1e>
    p++, q++;
 146:	0505                	addi	a0,a0,1
 148:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	fbe5                	bnez	a5,13e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 150:	0005c503          	lbu	a0,0(a1)
}
 154:	40a7853b          	subw	a0,a5,a0
 158:	6422                	ld	s0,8(sp)
 15a:	0141                	addi	sp,sp,16
 15c:	8082                	ret

000000000000015e <strlen>:

uint
strlen(const char *s)
{
 15e:	1141                	addi	sp,sp,-16
 160:	e422                	sd	s0,8(sp)
 162:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 164:	00054783          	lbu	a5,0(a0)
 168:	cf91                	beqz	a5,184 <strlen+0x26>
 16a:	0505                	addi	a0,a0,1
 16c:	87aa                	mv	a5,a0
 16e:	4685                	li	a3,1
 170:	9e89                	subw	a3,a3,a0
 172:	00f6853b          	addw	a0,a3,a5
 176:	0785                	addi	a5,a5,1
 178:	fff7c703          	lbu	a4,-1(a5)
 17c:	fb7d                	bnez	a4,172 <strlen+0x14>
    ;
  return n;
}
 17e:	6422                	ld	s0,8(sp)
 180:	0141                	addi	sp,sp,16
 182:	8082                	ret
  for(n = 0; s[n]; n++)
 184:	4501                	li	a0,0
 186:	bfe5                	j	17e <strlen+0x20>

0000000000000188 <memset>:

void*
memset(void *dst, int c, uint n)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18e:	ca19                	beqz	a2,1a4 <memset+0x1c>
 190:	87aa                	mv	a5,a0
 192:	1602                	slli	a2,a2,0x20
 194:	9201                	srli	a2,a2,0x20
 196:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 19a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19e:	0785                	addi	a5,a5,1
 1a0:	fee79de3          	bne	a5,a4,19a <memset+0x12>
  }
  return dst;
}
 1a4:	6422                	ld	s0,8(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret

00000000000001aa <strchr>:

char*
strchr(const char *s, char c)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	cb99                	beqz	a5,1ca <strchr+0x20>
    if(*s == c)
 1b6:	00f58763          	beq	a1,a5,1c4 <strchr+0x1a>
  for(; *s; s++)
 1ba:	0505                	addi	a0,a0,1
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	fbfd                	bnez	a5,1b6 <strchr+0xc>
      return (char*)s;
  return 0;
 1c2:	4501                	li	a0,0
}
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret
  return 0;
 1ca:	4501                	li	a0,0
 1cc:	bfe5                	j	1c4 <strchr+0x1a>

00000000000001ce <gets>:

char*
gets(char *buf, int max)
{
 1ce:	711d                	addi	sp,sp,-96
 1d0:	ec86                	sd	ra,88(sp)
 1d2:	e8a2                	sd	s0,80(sp)
 1d4:	e4a6                	sd	s1,72(sp)
 1d6:	e0ca                	sd	s2,64(sp)
 1d8:	fc4e                	sd	s3,56(sp)
 1da:	f852                	sd	s4,48(sp)
 1dc:	f456                	sd	s5,40(sp)
 1de:	f05a                	sd	s6,32(sp)
 1e0:	ec5e                	sd	s7,24(sp)
 1e2:	1080                	addi	s0,sp,96
 1e4:	8baa                	mv	s7,a0
 1e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e8:	892a                	mv	s2,a0
 1ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ec:	4aa9                	li	s5,10
 1ee:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f0:	89a6                	mv	s3,s1
 1f2:	2485                	addiw	s1,s1,1
 1f4:	0344d863          	bge	s1,s4,224 <gets+0x56>
    cc = read(0, &c, 1);
 1f8:	4605                	li	a2,1
 1fa:	faf40593          	addi	a1,s0,-81
 1fe:	4501                	li	a0,0
 200:	00000097          	auipc	ra,0x0
 204:	19a080e7          	jalr	410(ra) # 39a <read>
    if(cc < 1)
 208:	00a05e63          	blez	a0,224 <gets+0x56>
    buf[i++] = c;
 20c:	faf44783          	lbu	a5,-81(s0)
 210:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 214:	01578763          	beq	a5,s5,222 <gets+0x54>
 218:	0905                	addi	s2,s2,1
 21a:	fd679be3          	bne	a5,s6,1f0 <gets+0x22>
  for(i=0; i+1 < max; ){
 21e:	89a6                	mv	s3,s1
 220:	a011                	j	224 <gets+0x56>
 222:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 224:	99de                	add	s3,s3,s7
 226:	00098023          	sb	zero,0(s3)
  return buf;
}
 22a:	855e                	mv	a0,s7
 22c:	60e6                	ld	ra,88(sp)
 22e:	6446                	ld	s0,80(sp)
 230:	64a6                	ld	s1,72(sp)
 232:	6906                	ld	s2,64(sp)
 234:	79e2                	ld	s3,56(sp)
 236:	7a42                	ld	s4,48(sp)
 238:	7aa2                	ld	s5,40(sp)
 23a:	7b02                	ld	s6,32(sp)
 23c:	6be2                	ld	s7,24(sp)
 23e:	6125                	addi	sp,sp,96
 240:	8082                	ret

0000000000000242 <stat>:

int
stat(const char *n, struct stat *st)
{
 242:	1101                	addi	sp,sp,-32
 244:	ec06                	sd	ra,24(sp)
 246:	e822                	sd	s0,16(sp)
 248:	e426                	sd	s1,8(sp)
 24a:	e04a                	sd	s2,0(sp)
 24c:	1000                	addi	s0,sp,32
 24e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 250:	4581                	li	a1,0
 252:	00000097          	auipc	ra,0x0
 256:	170080e7          	jalr	368(ra) # 3c2 <open>
  if(fd < 0)
 25a:	02054563          	bltz	a0,284 <stat+0x42>
 25e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 260:	85ca                	mv	a1,s2
 262:	00000097          	auipc	ra,0x0
 266:	178080e7          	jalr	376(ra) # 3da <fstat>
 26a:	892a                	mv	s2,a0
  close(fd);
 26c:	8526                	mv	a0,s1
 26e:	00000097          	auipc	ra,0x0
 272:	13c080e7          	jalr	316(ra) # 3aa <close>
  return r;
}
 276:	854a                	mv	a0,s2
 278:	60e2                	ld	ra,24(sp)
 27a:	6442                	ld	s0,16(sp)
 27c:	64a2                	ld	s1,8(sp)
 27e:	6902                	ld	s2,0(sp)
 280:	6105                	addi	sp,sp,32
 282:	8082                	ret
    return -1;
 284:	597d                	li	s2,-1
 286:	bfc5                	j	276 <stat+0x34>

0000000000000288 <atoi>:

int
atoi(const char *s)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28e:	00054683          	lbu	a3,0(a0)
 292:	fd06879b          	addiw	a5,a3,-48
 296:	0ff7f793          	zext.b	a5,a5
 29a:	4625                	li	a2,9
 29c:	02f66863          	bltu	a2,a5,2cc <atoi+0x44>
 2a0:	872a                	mv	a4,a0
  n = 0;
 2a2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2a4:	0705                	addi	a4,a4,1
 2a6:	0025179b          	slliw	a5,a0,0x2
 2aa:	9fa9                	addw	a5,a5,a0
 2ac:	0017979b          	slliw	a5,a5,0x1
 2b0:	9fb5                	addw	a5,a5,a3
 2b2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b6:	00074683          	lbu	a3,0(a4)
 2ba:	fd06879b          	addiw	a5,a3,-48
 2be:	0ff7f793          	zext.b	a5,a5
 2c2:	fef671e3          	bgeu	a2,a5,2a4 <atoi+0x1c>
  return n;
}
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
  n = 0;
 2cc:	4501                	li	a0,0
 2ce:	bfe5                	j	2c6 <atoi+0x3e>

00000000000002d0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e422                	sd	s0,8(sp)
 2d4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d6:	02b57463          	bgeu	a0,a1,2fe <memmove+0x2e>
    while(n-- > 0)
 2da:	00c05f63          	blez	a2,2f8 <memmove+0x28>
 2de:	1602                	slli	a2,a2,0x20
 2e0:	9201                	srli	a2,a2,0x20
 2e2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2e6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2e8:	0585                	addi	a1,a1,1
 2ea:	0705                	addi	a4,a4,1
 2ec:	fff5c683          	lbu	a3,-1(a1)
 2f0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f4:	fee79ae3          	bne	a5,a4,2e8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2f8:	6422                	ld	s0,8(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret
    dst += n;
 2fe:	00c50733          	add	a4,a0,a2
    src += n;
 302:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 304:	fec05ae3          	blez	a2,2f8 <memmove+0x28>
 308:	fff6079b          	addiw	a5,a2,-1
 30c:	1782                	slli	a5,a5,0x20
 30e:	9381                	srli	a5,a5,0x20
 310:	fff7c793          	not	a5,a5
 314:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 316:	15fd                	addi	a1,a1,-1
 318:	177d                	addi	a4,a4,-1
 31a:	0005c683          	lbu	a3,0(a1)
 31e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 322:	fee79ae3          	bne	a5,a4,316 <memmove+0x46>
 326:	bfc9                	j	2f8 <memmove+0x28>

0000000000000328 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e422                	sd	s0,8(sp)
 32c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 32e:	ca05                	beqz	a2,35e <memcmp+0x36>
 330:	fff6069b          	addiw	a3,a2,-1
 334:	1682                	slli	a3,a3,0x20
 336:	9281                	srli	a3,a3,0x20
 338:	0685                	addi	a3,a3,1
 33a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 33c:	00054783          	lbu	a5,0(a0)
 340:	0005c703          	lbu	a4,0(a1)
 344:	00e79863          	bne	a5,a4,354 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 348:	0505                	addi	a0,a0,1
    p2++;
 34a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 34c:	fed518e3          	bne	a0,a3,33c <memcmp+0x14>
  }
  return 0;
 350:	4501                	li	a0,0
 352:	a019                	j	358 <memcmp+0x30>
      return *p1 - *p2;
 354:	40e7853b          	subw	a0,a5,a4
}
 358:	6422                	ld	s0,8(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret
  return 0;
 35e:	4501                	li	a0,0
 360:	bfe5                	j	358 <memcmp+0x30>

0000000000000362 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 362:	1141                	addi	sp,sp,-16
 364:	e406                	sd	ra,8(sp)
 366:	e022                	sd	s0,0(sp)
 368:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 36a:	00000097          	auipc	ra,0x0
 36e:	f66080e7          	jalr	-154(ra) # 2d0 <memmove>
}
 372:	60a2                	ld	ra,8(sp)
 374:	6402                	ld	s0,0(sp)
 376:	0141                	addi	sp,sp,16
 378:	8082                	ret

000000000000037a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 37a:	4885                	li	a7,1
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <exit>:
.global exit
exit:
 li a7, SYS_exit
 382:	4889                	li	a7,2
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <wait>:
.global wait
wait:
 li a7, SYS_wait
 38a:	488d                	li	a7,3
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 392:	4891                	li	a7,4
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <read>:
.global read
read:
 li a7, SYS_read
 39a:	4895                	li	a7,5
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <write>:
.global write
write:
 li a7, SYS_write
 3a2:	48c1                	li	a7,16
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <close>:
.global close
close:
 li a7, SYS_close
 3aa:	48d5                	li	a7,21
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b2:	4899                	li	a7,6
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ba:	489d                	li	a7,7
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <open>:
.global open
open:
 li a7, SYS_open
 3c2:	48bd                	li	a7,15
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ca:	48c5                	li	a7,17
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d2:	48c9                	li	a7,18
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3da:	48a1                	li	a7,8
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <link>:
.global link
link:
 li a7, SYS_link
 3e2:	48cd                	li	a7,19
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ea:	48d1                	li	a7,20
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f2:	48a5                	li	a7,9
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <dup>:
.global dup
dup:
 li a7, SYS_dup
 3fa:	48a9                	li	a7,10
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 402:	48ad                	li	a7,11
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 40a:	48b1                	li	a7,12
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 412:	48b5                	li	a7,13
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 41a:	48b9                	li	a7,14
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 422:	48d9                	li	a7,22
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <yield>:
.global yield
yield:
 li a7, SYS_yield
 42a:	48dd                	li	a7,23
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 432:	48e1                	li	a7,24
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 43a:	48e5                	li	a7,25
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 442:	48e9                	li	a7,26
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <ps>:
.global ps
ps:
 li a7, SYS_ps
 44a:	48ed                	li	a7,27
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 452:	48f1                	li	a7,28
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 45a:	48f5                	li	a7,29
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 462:	48f9                	li	a7,30
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 46a:	48fd                	li	a7,31
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 472:	02000893          	li	a7,32
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 47c:	02100893          	li	a7,33
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 486:	02200893          	li	a7,34
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 490:	02300893          	li	a7,35
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 49a:	02400893          	li	a7,36
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 4a4:	02500893          	li	a7,37
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 4ae:	02600893          	li	a7,38
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 4b8:	02700893          	li	a7,39
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4c2:	1101                	addi	sp,sp,-32
 4c4:	ec06                	sd	ra,24(sp)
 4c6:	e822                	sd	s0,16(sp)
 4c8:	1000                	addi	s0,sp,32
 4ca:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ce:	4605                	li	a2,1
 4d0:	fef40593          	addi	a1,s0,-17
 4d4:	00000097          	auipc	ra,0x0
 4d8:	ece080e7          	jalr	-306(ra) # 3a2 <write>
}
 4dc:	60e2                	ld	ra,24(sp)
 4de:	6442                	ld	s0,16(sp)
 4e0:	6105                	addi	sp,sp,32
 4e2:	8082                	ret

00000000000004e4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4e4:	7139                	addi	sp,sp,-64
 4e6:	fc06                	sd	ra,56(sp)
 4e8:	f822                	sd	s0,48(sp)
 4ea:	f426                	sd	s1,40(sp)
 4ec:	f04a                	sd	s2,32(sp)
 4ee:	ec4e                	sd	s3,24(sp)
 4f0:	0080                	addi	s0,sp,64
 4f2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4f4:	c299                	beqz	a3,4fa <printint+0x16>
 4f6:	0805c963          	bltz	a1,588 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4fa:	2581                	sext.w	a1,a1
  neg = 0;
 4fc:	4881                	li	a7,0
 4fe:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 502:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 504:	2601                	sext.w	a2,a2
 506:	00000517          	auipc	a0,0x0
 50a:	4fa50513          	addi	a0,a0,1274 # a00 <digits>
 50e:	883a                	mv	a6,a4
 510:	2705                	addiw	a4,a4,1
 512:	02c5f7bb          	remuw	a5,a1,a2
 516:	1782                	slli	a5,a5,0x20
 518:	9381                	srli	a5,a5,0x20
 51a:	97aa                	add	a5,a5,a0
 51c:	0007c783          	lbu	a5,0(a5)
 520:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 524:	0005879b          	sext.w	a5,a1
 528:	02c5d5bb          	divuw	a1,a1,a2
 52c:	0685                	addi	a3,a3,1
 52e:	fec7f0e3          	bgeu	a5,a2,50e <printint+0x2a>
  if(neg)
 532:	00088c63          	beqz	a7,54a <printint+0x66>
    buf[i++] = '-';
 536:	fd070793          	addi	a5,a4,-48
 53a:	00878733          	add	a4,a5,s0
 53e:	02d00793          	li	a5,45
 542:	fef70823          	sb	a5,-16(a4)
 546:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 54a:	02e05863          	blez	a4,57a <printint+0x96>
 54e:	fc040793          	addi	a5,s0,-64
 552:	00e78933          	add	s2,a5,a4
 556:	fff78993          	addi	s3,a5,-1
 55a:	99ba                	add	s3,s3,a4
 55c:	377d                	addiw	a4,a4,-1
 55e:	1702                	slli	a4,a4,0x20
 560:	9301                	srli	a4,a4,0x20
 562:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 566:	fff94583          	lbu	a1,-1(s2)
 56a:	8526                	mv	a0,s1
 56c:	00000097          	auipc	ra,0x0
 570:	f56080e7          	jalr	-170(ra) # 4c2 <putc>
  while(--i >= 0)
 574:	197d                	addi	s2,s2,-1
 576:	ff3918e3          	bne	s2,s3,566 <printint+0x82>
}
 57a:	70e2                	ld	ra,56(sp)
 57c:	7442                	ld	s0,48(sp)
 57e:	74a2                	ld	s1,40(sp)
 580:	7902                	ld	s2,32(sp)
 582:	69e2                	ld	s3,24(sp)
 584:	6121                	addi	sp,sp,64
 586:	8082                	ret
    x = -xx;
 588:	40b005bb          	negw	a1,a1
    neg = 1;
 58c:	4885                	li	a7,1
    x = -xx;
 58e:	bf85                	j	4fe <printint+0x1a>

0000000000000590 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 590:	7119                	addi	sp,sp,-128
 592:	fc86                	sd	ra,120(sp)
 594:	f8a2                	sd	s0,112(sp)
 596:	f4a6                	sd	s1,104(sp)
 598:	f0ca                	sd	s2,96(sp)
 59a:	ecce                	sd	s3,88(sp)
 59c:	e8d2                	sd	s4,80(sp)
 59e:	e4d6                	sd	s5,72(sp)
 5a0:	e0da                	sd	s6,64(sp)
 5a2:	fc5e                	sd	s7,56(sp)
 5a4:	f862                	sd	s8,48(sp)
 5a6:	f466                	sd	s9,40(sp)
 5a8:	f06a                	sd	s10,32(sp)
 5aa:	ec6e                	sd	s11,24(sp)
 5ac:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5ae:	0005c903          	lbu	s2,0(a1)
 5b2:	18090f63          	beqz	s2,750 <vprintf+0x1c0>
 5b6:	8aaa                	mv	s5,a0
 5b8:	8b32                	mv	s6,a2
 5ba:	00158493          	addi	s1,a1,1
  state = 0;
 5be:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5c0:	02500a13          	li	s4,37
 5c4:	4c55                	li	s8,21
 5c6:	00000c97          	auipc	s9,0x0
 5ca:	3e2c8c93          	addi	s9,s9,994 # 9a8 <malloc+0x154>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5ce:	02800d93          	li	s11,40
  putc(fd, 'x');
 5d2:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d4:	00000b97          	auipc	s7,0x0
 5d8:	42cb8b93          	addi	s7,s7,1068 # a00 <digits>
 5dc:	a839                	j	5fa <vprintf+0x6a>
        putc(fd, c);
 5de:	85ca                	mv	a1,s2
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	ee0080e7          	jalr	-288(ra) # 4c2 <putc>
 5ea:	a019                	j	5f0 <vprintf+0x60>
    } else if(state == '%'){
 5ec:	01498d63          	beq	s3,s4,606 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5f0:	0485                	addi	s1,s1,1
 5f2:	fff4c903          	lbu	s2,-1(s1)
 5f6:	14090d63          	beqz	s2,750 <vprintf+0x1c0>
    if(state == 0){
 5fa:	fe0999e3          	bnez	s3,5ec <vprintf+0x5c>
      if(c == '%'){
 5fe:	ff4910e3          	bne	s2,s4,5de <vprintf+0x4e>
        state = '%';
 602:	89d2                	mv	s3,s4
 604:	b7f5                	j	5f0 <vprintf+0x60>
      if(c == 'd'){
 606:	11490c63          	beq	s2,s4,71e <vprintf+0x18e>
 60a:	f9d9079b          	addiw	a5,s2,-99
 60e:	0ff7f793          	zext.b	a5,a5
 612:	10fc6e63          	bltu	s8,a5,72e <vprintf+0x19e>
 616:	f9d9079b          	addiw	a5,s2,-99
 61a:	0ff7f713          	zext.b	a4,a5
 61e:	10ec6863          	bltu	s8,a4,72e <vprintf+0x19e>
 622:	00271793          	slli	a5,a4,0x2
 626:	97e6                	add	a5,a5,s9
 628:	439c                	lw	a5,0(a5)
 62a:	97e6                	add	a5,a5,s9
 62c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 62e:	008b0913          	addi	s2,s6,8
 632:	4685                	li	a3,1
 634:	4629                	li	a2,10
 636:	000b2583          	lw	a1,0(s6)
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	ea8080e7          	jalr	-344(ra) # 4e4 <printint>
 644:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 646:	4981                	li	s3,0
 648:	b765                	j	5f0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64a:	008b0913          	addi	s2,s6,8
 64e:	4681                	li	a3,0
 650:	4629                	li	a2,10
 652:	000b2583          	lw	a1,0(s6)
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	e8c080e7          	jalr	-372(ra) # 4e4 <printint>
 660:	8b4a                	mv	s6,s2
      state = 0;
 662:	4981                	li	s3,0
 664:	b771                	j	5f0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 666:	008b0913          	addi	s2,s6,8
 66a:	4681                	li	a3,0
 66c:	866a                	mv	a2,s10
 66e:	000b2583          	lw	a1,0(s6)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	e70080e7          	jalr	-400(ra) # 4e4 <printint>
 67c:	8b4a                	mv	s6,s2
      state = 0;
 67e:	4981                	li	s3,0
 680:	bf85                	j	5f0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 682:	008b0793          	addi	a5,s6,8
 686:	f8f43423          	sd	a5,-120(s0)
 68a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 68e:	03000593          	li	a1,48
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e2e080e7          	jalr	-466(ra) # 4c2 <putc>
  putc(fd, 'x');
 69c:	07800593          	li	a1,120
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	e20080e7          	jalr	-480(ra) # 4c2 <putc>
 6aa:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ac:	03c9d793          	srli	a5,s3,0x3c
 6b0:	97de                	add	a5,a5,s7
 6b2:	0007c583          	lbu	a1,0(a5)
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	e0a080e7          	jalr	-502(ra) # 4c2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c0:	0992                	slli	s3,s3,0x4
 6c2:	397d                	addiw	s2,s2,-1
 6c4:	fe0914e3          	bnez	s2,6ac <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6c8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b70d                	j	5f0 <vprintf+0x60>
        s = va_arg(ap, char*);
 6d0:	008b0913          	addi	s2,s6,8
 6d4:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6d8:	02098163          	beqz	s3,6fa <vprintf+0x16a>
        while(*s != 0){
 6dc:	0009c583          	lbu	a1,0(s3)
 6e0:	c5ad                	beqz	a1,74a <vprintf+0x1ba>
          putc(fd, *s);
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	dde080e7          	jalr	-546(ra) # 4c2 <putc>
          s++;
 6ec:	0985                	addi	s3,s3,1
        while(*s != 0){
 6ee:	0009c583          	lbu	a1,0(s3)
 6f2:	f9e5                	bnez	a1,6e2 <vprintf+0x152>
        s = va_arg(ap, char*);
 6f4:	8b4a                	mv	s6,s2
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bde5                	j	5f0 <vprintf+0x60>
          s = "(null)";
 6fa:	00000997          	auipc	s3,0x0
 6fe:	2a698993          	addi	s3,s3,678 # 9a0 <malloc+0x14c>
        while(*s != 0){
 702:	85ee                	mv	a1,s11
 704:	bff9                	j	6e2 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 706:	008b0913          	addi	s2,s6,8
 70a:	000b4583          	lbu	a1,0(s6)
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	db2080e7          	jalr	-590(ra) # 4c2 <putc>
 718:	8b4a                	mv	s6,s2
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bdd1                	j	5f0 <vprintf+0x60>
        putc(fd, c);
 71e:	85d2                	mv	a1,s4
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	da0080e7          	jalr	-608(ra) # 4c2 <putc>
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b5d1                	j	5f0 <vprintf+0x60>
        putc(fd, '%');
 72e:	85d2                	mv	a1,s4
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	d90080e7          	jalr	-624(ra) # 4c2 <putc>
        putc(fd, c);
 73a:	85ca                	mv	a1,s2
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	d84080e7          	jalr	-636(ra) # 4c2 <putc>
      state = 0;
 746:	4981                	li	s3,0
 748:	b565                	j	5f0 <vprintf+0x60>
        s = va_arg(ap, char*);
 74a:	8b4a                	mv	s6,s2
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b54d                	j	5f0 <vprintf+0x60>
    }
  }
}
 750:	70e6                	ld	ra,120(sp)
 752:	7446                	ld	s0,112(sp)
 754:	74a6                	ld	s1,104(sp)
 756:	7906                	ld	s2,96(sp)
 758:	69e6                	ld	s3,88(sp)
 75a:	6a46                	ld	s4,80(sp)
 75c:	6aa6                	ld	s5,72(sp)
 75e:	6b06                	ld	s6,64(sp)
 760:	7be2                	ld	s7,56(sp)
 762:	7c42                	ld	s8,48(sp)
 764:	7ca2                	ld	s9,40(sp)
 766:	7d02                	ld	s10,32(sp)
 768:	6de2                	ld	s11,24(sp)
 76a:	6109                	addi	sp,sp,128
 76c:	8082                	ret

000000000000076e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76e:	715d                	addi	sp,sp,-80
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
 776:	e010                	sd	a2,0(s0)
 778:	e414                	sd	a3,8(s0)
 77a:	e818                	sd	a4,16(s0)
 77c:	ec1c                	sd	a5,24(s0)
 77e:	03043023          	sd	a6,32(s0)
 782:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 78a:	8622                	mv	a2,s0
 78c:	00000097          	auipc	ra,0x0
 790:	e04080e7          	jalr	-508(ra) # 590 <vprintf>
}
 794:	60e2                	ld	ra,24(sp)
 796:	6442                	ld	s0,16(sp)
 798:	6161                	addi	sp,sp,80
 79a:	8082                	ret

000000000000079c <printf>:

void
printf(const char *fmt, ...)
{
 79c:	711d                	addi	sp,sp,-96
 79e:	ec06                	sd	ra,24(sp)
 7a0:	e822                	sd	s0,16(sp)
 7a2:	1000                	addi	s0,sp,32
 7a4:	e40c                	sd	a1,8(s0)
 7a6:	e810                	sd	a2,16(s0)
 7a8:	ec14                	sd	a3,24(s0)
 7aa:	f018                	sd	a4,32(s0)
 7ac:	f41c                	sd	a5,40(s0)
 7ae:	03043823          	sd	a6,48(s0)
 7b2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b6:	00840613          	addi	a2,s0,8
 7ba:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7be:	85aa                	mv	a1,a0
 7c0:	4505                	li	a0,1
 7c2:	00000097          	auipc	ra,0x0
 7c6:	dce080e7          	jalr	-562(ra) # 590 <vprintf>
}
 7ca:	60e2                	ld	ra,24(sp)
 7cc:	6442                	ld	s0,16(sp)
 7ce:	6125                	addi	sp,sp,96
 7d0:	8082                	ret

00000000000007d2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d2:	1141                	addi	sp,sp,-16
 7d4:	e422                	sd	s0,8(sp)
 7d6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7dc:	00000797          	auipc	a5,0x0
 7e0:	23c7b783          	ld	a5,572(a5) # a18 <freep>
 7e4:	a02d                	j	80e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7e6:	4618                	lw	a4,8(a2)
 7e8:	9f2d                	addw	a4,a4,a1
 7ea:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ee:	6398                	ld	a4,0(a5)
 7f0:	6310                	ld	a2,0(a4)
 7f2:	a83d                	j	830 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7f4:	ff852703          	lw	a4,-8(a0)
 7f8:	9f31                	addw	a4,a4,a2
 7fa:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7fc:	ff053683          	ld	a3,-16(a0)
 800:	a091                	j	844 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 802:	6398                	ld	a4,0(a5)
 804:	00e7e463          	bltu	a5,a4,80c <free+0x3a>
 808:	00e6ea63          	bltu	a3,a4,81c <free+0x4a>
{
 80c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80e:	fed7fae3          	bgeu	a5,a3,802 <free+0x30>
 812:	6398                	ld	a4,0(a5)
 814:	00e6e463          	bltu	a3,a4,81c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 818:	fee7eae3          	bltu	a5,a4,80c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 81c:	ff852583          	lw	a1,-8(a0)
 820:	6390                	ld	a2,0(a5)
 822:	02059813          	slli	a6,a1,0x20
 826:	01c85713          	srli	a4,a6,0x1c
 82a:	9736                	add	a4,a4,a3
 82c:	fae60de3          	beq	a2,a4,7e6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 834:	4790                	lw	a2,8(a5)
 836:	02061593          	slli	a1,a2,0x20
 83a:	01c5d713          	srli	a4,a1,0x1c
 83e:	973e                	add	a4,a4,a5
 840:	fae68ae3          	beq	a3,a4,7f4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 844:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 846:	00000717          	auipc	a4,0x0
 84a:	1cf73923          	sd	a5,466(a4) # a18 <freep>
}
 84e:	6422                	ld	s0,8(sp)
 850:	0141                	addi	sp,sp,16
 852:	8082                	ret

0000000000000854 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 854:	7139                	addi	sp,sp,-64
 856:	fc06                	sd	ra,56(sp)
 858:	f822                	sd	s0,48(sp)
 85a:	f426                	sd	s1,40(sp)
 85c:	f04a                	sd	s2,32(sp)
 85e:	ec4e                	sd	s3,24(sp)
 860:	e852                	sd	s4,16(sp)
 862:	e456                	sd	s5,8(sp)
 864:	e05a                	sd	s6,0(sp)
 866:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 868:	02051493          	slli	s1,a0,0x20
 86c:	9081                	srli	s1,s1,0x20
 86e:	04bd                	addi	s1,s1,15
 870:	8091                	srli	s1,s1,0x4
 872:	0014899b          	addiw	s3,s1,1
 876:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 878:	00000517          	auipc	a0,0x0
 87c:	1a053503          	ld	a0,416(a0) # a18 <freep>
 880:	c515                	beqz	a0,8ac <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 882:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 884:	4798                	lw	a4,8(a5)
 886:	02977f63          	bgeu	a4,s1,8c4 <malloc+0x70>
 88a:	8a4e                	mv	s4,s3
 88c:	0009871b          	sext.w	a4,s3
 890:	6685                	lui	a3,0x1
 892:	00d77363          	bgeu	a4,a3,898 <malloc+0x44>
 896:	6a05                	lui	s4,0x1
 898:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 89c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a0:	00000917          	auipc	s2,0x0
 8a4:	17890913          	addi	s2,s2,376 # a18 <freep>
  if(p == (char*)-1)
 8a8:	5afd                	li	s5,-1
 8aa:	a895                	j	91e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8ac:	00000797          	auipc	a5,0x0
 8b0:	17478793          	addi	a5,a5,372 # a20 <base>
 8b4:	00000717          	auipc	a4,0x0
 8b8:	16f73223          	sd	a5,356(a4) # a18 <freep>
 8bc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8be:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c2:	b7e1                	j	88a <malloc+0x36>
      if(p->s.size == nunits)
 8c4:	02e48c63          	beq	s1,a4,8fc <malloc+0xa8>
        p->s.size -= nunits;
 8c8:	4137073b          	subw	a4,a4,s3
 8cc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ce:	02071693          	slli	a3,a4,0x20
 8d2:	01c6d713          	srli	a4,a3,0x1c
 8d6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8dc:	00000717          	auipc	a4,0x0
 8e0:	12a73e23          	sd	a0,316(a4) # a18 <freep>
      return (void*)(p + 1);
 8e4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8e8:	70e2                	ld	ra,56(sp)
 8ea:	7442                	ld	s0,48(sp)
 8ec:	74a2                	ld	s1,40(sp)
 8ee:	7902                	ld	s2,32(sp)
 8f0:	69e2                	ld	s3,24(sp)
 8f2:	6a42                	ld	s4,16(sp)
 8f4:	6aa2                	ld	s5,8(sp)
 8f6:	6b02                	ld	s6,0(sp)
 8f8:	6121                	addi	sp,sp,64
 8fa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8fc:	6398                	ld	a4,0(a5)
 8fe:	e118                	sd	a4,0(a0)
 900:	bff1                	j	8dc <malloc+0x88>
  hp->s.size = nu;
 902:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 906:	0541                	addi	a0,a0,16
 908:	00000097          	auipc	ra,0x0
 90c:	eca080e7          	jalr	-310(ra) # 7d2 <free>
  return freep;
 910:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 914:	d971                	beqz	a0,8e8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 916:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 918:	4798                	lw	a4,8(a5)
 91a:	fa9775e3          	bgeu	a4,s1,8c4 <malloc+0x70>
    if(p == freep)
 91e:	00093703          	ld	a4,0(s2)
 922:	853e                	mv	a0,a5
 924:	fef719e3          	bne	a4,a5,916 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 928:	8552                	mv	a0,s4
 92a:	00000097          	auipc	ra,0x0
 92e:	ae0080e7          	jalr	-1312(ra) # 40a <sbrk>
  if(p == (char*)-1)
 932:	fd5518e3          	bne	a0,s5,902 <malloc+0xae>
        return 0;
 936:	4501                	li	a0,0
 938:	bf45                	j	8e8 <malloc+0x94>
