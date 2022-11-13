
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
  20:	8f458593          	addi	a1,a1,-1804 # 910 <malloc+0xea>
  24:	4509                	li	a0,2
  26:	00000097          	auipc	ra,0x0
  2a:	714080e7          	jalr	1812(ra) # 73a <fprintf>
     exit(0);
  2e:	4501                	li	a0,0
  30:	00000097          	auipc	ra,0x0
  34:	35c080e7          	jalr	860(ra) # 38c <exit>
  38:	84ae                	mv	s1,a1
  }

  n = atoi(argv[1]);
  3a:	6588                	ld	a0,8(a1)
  3c:	00000097          	auipc	ra,0x0
  40:	250080e7          	jalr	592(ra) # 28c <atoi>
  44:	89aa                	mv	s3,a0
  r = atoi(argv[2]);
  46:	6888                	ld	a0,16(s1)
  48:	00000097          	auipc	ra,0x0
  4c:	244080e7          	jalr	580(ra) # 28c <atoi>
  50:	8aaa                	mv	s5,a0
  barrier_id = barrier_alloc();
  52:	00000097          	auipc	ra,0x0
  56:	422080e7          	jalr	1058(ra) # 474 <barrier_alloc>
  5a:	8a2a                	mv	s4,a0
  fprintf(1, "%d: got barrier array id %d\n\n", getpid(), barrier_id);
  5c:	00000097          	auipc	ra,0x0
  60:	3b0080e7          	jalr	944(ra) # 40c <getpid>
  64:	862a                	mv	a2,a0
  66:	86d2                	mv	a3,s4
  68:	00001597          	auipc	a1,0x1
  6c:	8e058593          	addi	a1,a1,-1824 # 948 <malloc+0x122>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	6c8080e7          	jalr	1736(ra) # 73a <fprintf>
   printf("%dyo\n",n);
  7a:	85ce                	mv	a1,s3
  7c:	00001517          	auipc	a0,0x1
  80:	8ec50513          	addi	a0,a0,-1812 # 968 <malloc+0x142>
  84:	00000097          	auipc	ra,0x0
  88:	6e4080e7          	jalr	1764(ra) # 768 <printf>
  for (i=0; i<n-1; i++) {
  8c:	fff98b9b          	addiw	s7,s3,-1
  90:	09705063          	blez	s7,110 <main+0x110>
  94:	8b5e                	mv	s6,s7
  96:	4901                	li	s2,0
     if (fork() == 0) {
  98:	00000097          	auipc	ra,0x0
  9c:	2ec080e7          	jalr	748(ra) # 384 <fork>
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
  ba:	3c6080e7          	jalr	966(ra) # 47c <barrier>
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
  d0:	2c8080e7          	jalr	712(ra) # 394 <wait>
  d4:	2485                	addiw	s1,s1,1
  d6:	ff74cae3          	blt	s1,s7,ca <main+0xca>
  barrier_free(barrier_id);
  da:	8552                	mv	a0,s4
  dc:	00000097          	auipc	ra,0x0
  e0:	3aa080e7          	jalr	938(ra) # 486 <barrier_free>
  exit(0);
  e4:	4501                	li	a0,0
  e6:	00000097          	auipc	ra,0x0
  ea:	2a6080e7          	jalr	678(ra) # 38c <exit>
        for (j=0; j<r; j++) {
  ee:	01505c63          	blez	s5,106 <main+0x106>
	   barrier(j, barrier_id, n);
  f2:	864e                	mv	a2,s3
  f4:	85d2                	mv	a1,s4
  f6:	8526                	mv	a0,s1
  f8:	00000097          	auipc	ra,0x0
  fc:	384080e7          	jalr	900(ra) # 47c <barrier>
        for (j=0; j<r; j++) {
 100:	2485                	addiw	s1,s1,1
 102:	fe9a98e3          	bne	s5,s1,f2 <main+0xf2>
	exit(0);
 106:	4501                	li	a0,0
 108:	00000097          	auipc	ra,0x0
 10c:	284080e7          	jalr	644(ra) # 38c <exit>
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
 18e:	ce09                	beqz	a2,1a8 <memset+0x20>
 190:	87aa                	mv	a5,a0
 192:	fff6071b          	addiw	a4,a2,-1
 196:	1702                	slli	a4,a4,0x20
 198:	9301                	srli	a4,a4,0x20
 19a:	0705                	addi	a4,a4,1
 19c:	972a                	add	a4,a4,a0
    cdst[i] = c;
 19e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a2:	0785                	addi	a5,a5,1
 1a4:	fee79de3          	bne	a5,a4,19e <memset+0x16>
  }
  return dst;
}
 1a8:	6422                	ld	s0,8(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret

00000000000001ae <strchr>:

char*
strchr(const char *s, char c)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e422                	sd	s0,8(sp)
 1b2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	cb99                	beqz	a5,1ce <strchr+0x20>
    if(*s == c)
 1ba:	00f58763          	beq	a1,a5,1c8 <strchr+0x1a>
  for(; *s; s++)
 1be:	0505                	addi	a0,a0,1
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	fbfd                	bnez	a5,1ba <strchr+0xc>
      return (char*)s;
  return 0;
 1c6:	4501                	li	a0,0
}
 1c8:	6422                	ld	s0,8(sp)
 1ca:	0141                	addi	sp,sp,16
 1cc:	8082                	ret
  return 0;
 1ce:	4501                	li	a0,0
 1d0:	bfe5                	j	1c8 <strchr+0x1a>

00000000000001d2 <gets>:

char*
gets(char *buf, int max)
{
 1d2:	711d                	addi	sp,sp,-96
 1d4:	ec86                	sd	ra,88(sp)
 1d6:	e8a2                	sd	s0,80(sp)
 1d8:	e4a6                	sd	s1,72(sp)
 1da:	e0ca                	sd	s2,64(sp)
 1dc:	fc4e                	sd	s3,56(sp)
 1de:	f852                	sd	s4,48(sp)
 1e0:	f456                	sd	s5,40(sp)
 1e2:	f05a                	sd	s6,32(sp)
 1e4:	ec5e                	sd	s7,24(sp)
 1e6:	1080                	addi	s0,sp,96
 1e8:	8baa                	mv	s7,a0
 1ea:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ec:	892a                	mv	s2,a0
 1ee:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f0:	4aa9                	li	s5,10
 1f2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f4:	89a6                	mv	s3,s1
 1f6:	2485                	addiw	s1,s1,1
 1f8:	0344d863          	bge	s1,s4,228 <gets+0x56>
    cc = read(0, &c, 1);
 1fc:	4605                	li	a2,1
 1fe:	faf40593          	addi	a1,s0,-81
 202:	4501                	li	a0,0
 204:	00000097          	auipc	ra,0x0
 208:	1a0080e7          	jalr	416(ra) # 3a4 <read>
    if(cc < 1)
 20c:	00a05e63          	blez	a0,228 <gets+0x56>
    buf[i++] = c;
 210:	faf44783          	lbu	a5,-81(s0)
 214:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 218:	01578763          	beq	a5,s5,226 <gets+0x54>
 21c:	0905                	addi	s2,s2,1
 21e:	fd679be3          	bne	a5,s6,1f4 <gets+0x22>
  for(i=0; i+1 < max; ){
 222:	89a6                	mv	s3,s1
 224:	a011                	j	228 <gets+0x56>
 226:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 228:	99de                	add	s3,s3,s7
 22a:	00098023          	sb	zero,0(s3)
  return buf;
}
 22e:	855e                	mv	a0,s7
 230:	60e6                	ld	ra,88(sp)
 232:	6446                	ld	s0,80(sp)
 234:	64a6                	ld	s1,72(sp)
 236:	6906                	ld	s2,64(sp)
 238:	79e2                	ld	s3,56(sp)
 23a:	7a42                	ld	s4,48(sp)
 23c:	7aa2                	ld	s5,40(sp)
 23e:	7b02                	ld	s6,32(sp)
 240:	6be2                	ld	s7,24(sp)
 242:	6125                	addi	sp,sp,96
 244:	8082                	ret

0000000000000246 <stat>:

int
stat(const char *n, struct stat *st)
{
 246:	1101                	addi	sp,sp,-32
 248:	ec06                	sd	ra,24(sp)
 24a:	e822                	sd	s0,16(sp)
 24c:	e426                	sd	s1,8(sp)
 24e:	e04a                	sd	s2,0(sp)
 250:	1000                	addi	s0,sp,32
 252:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 254:	4581                	li	a1,0
 256:	00000097          	auipc	ra,0x0
 25a:	176080e7          	jalr	374(ra) # 3cc <open>
  if(fd < 0)
 25e:	02054563          	bltz	a0,288 <stat+0x42>
 262:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 264:	85ca                	mv	a1,s2
 266:	00000097          	auipc	ra,0x0
 26a:	17e080e7          	jalr	382(ra) # 3e4 <fstat>
 26e:	892a                	mv	s2,a0
  close(fd);
 270:	8526                	mv	a0,s1
 272:	00000097          	auipc	ra,0x0
 276:	142080e7          	jalr	322(ra) # 3b4 <close>
  return r;
}
 27a:	854a                	mv	a0,s2
 27c:	60e2                	ld	ra,24(sp)
 27e:	6442                	ld	s0,16(sp)
 280:	64a2                	ld	s1,8(sp)
 282:	6902                	ld	s2,0(sp)
 284:	6105                	addi	sp,sp,32
 286:	8082                	ret
    return -1;
 288:	597d                	li	s2,-1
 28a:	bfc5                	j	27a <stat+0x34>

000000000000028c <atoi>:

int
atoi(const char *s)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 292:	00054603          	lbu	a2,0(a0)
 296:	fd06079b          	addiw	a5,a2,-48
 29a:	0ff7f793          	andi	a5,a5,255
 29e:	4725                	li	a4,9
 2a0:	02f76963          	bltu	a4,a5,2d2 <atoi+0x46>
 2a4:	86aa                	mv	a3,a0
  n = 0;
 2a6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2a8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2aa:	0685                	addi	a3,a3,1
 2ac:	0025179b          	slliw	a5,a0,0x2
 2b0:	9fa9                	addw	a5,a5,a0
 2b2:	0017979b          	slliw	a5,a5,0x1
 2b6:	9fb1                	addw	a5,a5,a2
 2b8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2bc:	0006c603          	lbu	a2,0(a3)
 2c0:	fd06071b          	addiw	a4,a2,-48
 2c4:	0ff77713          	andi	a4,a4,255
 2c8:	fee5f1e3          	bgeu	a1,a4,2aa <atoi+0x1e>
  return n;
}
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret
  n = 0;
 2d2:	4501                	li	a0,0
 2d4:	bfe5                	j	2cc <atoi+0x40>

00000000000002d6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2dc:	02b57663          	bgeu	a0,a1,308 <memmove+0x32>
    while(n-- > 0)
 2e0:	02c05163          	blez	a2,302 <memmove+0x2c>
 2e4:	fff6079b          	addiw	a5,a2,-1
 2e8:	1782                	slli	a5,a5,0x20
 2ea:	9381                	srli	a5,a5,0x20
 2ec:	0785                	addi	a5,a5,1
 2ee:	97aa                	add	a5,a5,a0
  dst = vdst;
 2f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f2:	0585                	addi	a1,a1,1
 2f4:	0705                	addi	a4,a4,1
 2f6:	fff5c683          	lbu	a3,-1(a1)
 2fa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2fe:	fee79ae3          	bne	a5,a4,2f2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 302:	6422                	ld	s0,8(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret
    dst += n;
 308:	00c50733          	add	a4,a0,a2
    src += n;
 30c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 30e:	fec05ae3          	blez	a2,302 <memmove+0x2c>
 312:	fff6079b          	addiw	a5,a2,-1
 316:	1782                	slli	a5,a5,0x20
 318:	9381                	srli	a5,a5,0x20
 31a:	fff7c793          	not	a5,a5
 31e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 320:	15fd                	addi	a1,a1,-1
 322:	177d                	addi	a4,a4,-1
 324:	0005c683          	lbu	a3,0(a1)
 328:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 32c:	fee79ae3          	bne	a5,a4,320 <memmove+0x4a>
 330:	bfc9                	j	302 <memmove+0x2c>

0000000000000332 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 332:	1141                	addi	sp,sp,-16
 334:	e422                	sd	s0,8(sp)
 336:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 338:	ca05                	beqz	a2,368 <memcmp+0x36>
 33a:	fff6069b          	addiw	a3,a2,-1
 33e:	1682                	slli	a3,a3,0x20
 340:	9281                	srli	a3,a3,0x20
 342:	0685                	addi	a3,a3,1
 344:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 346:	00054783          	lbu	a5,0(a0)
 34a:	0005c703          	lbu	a4,0(a1)
 34e:	00e79863          	bne	a5,a4,35e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 352:	0505                	addi	a0,a0,1
    p2++;
 354:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 356:	fed518e3          	bne	a0,a3,346 <memcmp+0x14>
  }
  return 0;
 35a:	4501                	li	a0,0
 35c:	a019                	j	362 <memcmp+0x30>
      return *p1 - *p2;
 35e:	40e7853b          	subw	a0,a5,a4
}
 362:	6422                	ld	s0,8(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret
  return 0;
 368:	4501                	li	a0,0
 36a:	bfe5                	j	362 <memcmp+0x30>

000000000000036c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e406                	sd	ra,8(sp)
 370:	e022                	sd	s0,0(sp)
 372:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 374:	00000097          	auipc	ra,0x0
 378:	f62080e7          	jalr	-158(ra) # 2d6 <memmove>
}
 37c:	60a2                	ld	ra,8(sp)
 37e:	6402                	ld	s0,0(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret

0000000000000384 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 384:	4885                	li	a7,1
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <exit>:
.global exit
exit:
 li a7, SYS_exit
 38c:	4889                	li	a7,2
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <wait>:
.global wait
wait:
 li a7, SYS_wait
 394:	488d                	li	a7,3
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39c:	4891                	li	a7,4
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <read>:
.global read
read:
 li a7, SYS_read
 3a4:	4895                	li	a7,5
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <write>:
.global write
write:
 li a7, SYS_write
 3ac:	48c1                	li	a7,16
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <close>:
.global close
close:
 li a7, SYS_close
 3b4:	48d5                	li	a7,21
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3bc:	4899                	li	a7,6
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c4:	489d                	li	a7,7
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <open>:
.global open
open:
 li a7, SYS_open
 3cc:	48bd                	li	a7,15
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d4:	48c5                	li	a7,17
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3dc:	48c9                	li	a7,18
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e4:	48a1                	li	a7,8
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <link>:
.global link
link:
 li a7, SYS_link
 3ec:	48cd                	li	a7,19
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f4:	48d1                	li	a7,20
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3fc:	48a5                	li	a7,9
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <dup>:
.global dup
dup:
 li a7, SYS_dup
 404:	48a9                	li	a7,10
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 40c:	48ad                	li	a7,11
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 414:	48b1                	li	a7,12
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 41c:	48b5                	li	a7,13
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 424:	48b9                	li	a7,14
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 42c:	48d9                	li	a7,22
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <yield>:
.global yield
yield:
 li a7, SYS_yield
 434:	48dd                	li	a7,23
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 43c:	48e1                	li	a7,24
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 444:	48e5                	li	a7,25
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 44c:	48e9                	li	a7,26
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <ps>:
.global ps
ps:
 li a7, SYS_ps
 454:	48ed                	li	a7,27
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 45c:	48f1                	li	a7,28
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 464:	48f5                	li	a7,29
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 46c:	48f9                	li	a7,30
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 474:	48fd                	li	a7,31
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 47c:	02000893          	li	a7,32
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 486:	02100893          	li	a7,33
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 490:	1101                	addi	sp,sp,-32
 492:	ec06                	sd	ra,24(sp)
 494:	e822                	sd	s0,16(sp)
 496:	1000                	addi	s0,sp,32
 498:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 49c:	4605                	li	a2,1
 49e:	fef40593          	addi	a1,s0,-17
 4a2:	00000097          	auipc	ra,0x0
 4a6:	f0a080e7          	jalr	-246(ra) # 3ac <write>
}
 4aa:	60e2                	ld	ra,24(sp)
 4ac:	6442                	ld	s0,16(sp)
 4ae:	6105                	addi	sp,sp,32
 4b0:	8082                	ret

00000000000004b2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b2:	7139                	addi	sp,sp,-64
 4b4:	fc06                	sd	ra,56(sp)
 4b6:	f822                	sd	s0,48(sp)
 4b8:	f426                	sd	s1,40(sp)
 4ba:	f04a                	sd	s2,32(sp)
 4bc:	ec4e                	sd	s3,24(sp)
 4be:	0080                	addi	s0,sp,64
 4c0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c2:	c299                	beqz	a3,4c8 <printint+0x16>
 4c4:	0805c863          	bltz	a1,554 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4c8:	2581                	sext.w	a1,a1
  neg = 0;
 4ca:	4881                	li	a7,0
 4cc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d2:	2601                	sext.w	a2,a2
 4d4:	00000517          	auipc	a0,0x0
 4d8:	4a450513          	addi	a0,a0,1188 # 978 <digits>
 4dc:	883a                	mv	a6,a4
 4de:	2705                	addiw	a4,a4,1
 4e0:	02c5f7bb          	remuw	a5,a1,a2
 4e4:	1782                	slli	a5,a5,0x20
 4e6:	9381                	srli	a5,a5,0x20
 4e8:	97aa                	add	a5,a5,a0
 4ea:	0007c783          	lbu	a5,0(a5)
 4ee:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f2:	0005879b          	sext.w	a5,a1
 4f6:	02c5d5bb          	divuw	a1,a1,a2
 4fa:	0685                	addi	a3,a3,1
 4fc:	fec7f0e3          	bgeu	a5,a2,4dc <printint+0x2a>
  if(neg)
 500:	00088b63          	beqz	a7,516 <printint+0x64>
    buf[i++] = '-';
 504:	fd040793          	addi	a5,s0,-48
 508:	973e                	add	a4,a4,a5
 50a:	02d00793          	li	a5,45
 50e:	fef70823          	sb	a5,-16(a4)
 512:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 516:	02e05863          	blez	a4,546 <printint+0x94>
 51a:	fc040793          	addi	a5,s0,-64
 51e:	00e78933          	add	s2,a5,a4
 522:	fff78993          	addi	s3,a5,-1
 526:	99ba                	add	s3,s3,a4
 528:	377d                	addiw	a4,a4,-1
 52a:	1702                	slli	a4,a4,0x20
 52c:	9301                	srli	a4,a4,0x20
 52e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 532:	fff94583          	lbu	a1,-1(s2)
 536:	8526                	mv	a0,s1
 538:	00000097          	auipc	ra,0x0
 53c:	f58080e7          	jalr	-168(ra) # 490 <putc>
  while(--i >= 0)
 540:	197d                	addi	s2,s2,-1
 542:	ff3918e3          	bne	s2,s3,532 <printint+0x80>
}
 546:	70e2                	ld	ra,56(sp)
 548:	7442                	ld	s0,48(sp)
 54a:	74a2                	ld	s1,40(sp)
 54c:	7902                	ld	s2,32(sp)
 54e:	69e2                	ld	s3,24(sp)
 550:	6121                	addi	sp,sp,64
 552:	8082                	ret
    x = -xx;
 554:	40b005bb          	negw	a1,a1
    neg = 1;
 558:	4885                	li	a7,1
    x = -xx;
 55a:	bf8d                	j	4cc <printint+0x1a>

000000000000055c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 55c:	7119                	addi	sp,sp,-128
 55e:	fc86                	sd	ra,120(sp)
 560:	f8a2                	sd	s0,112(sp)
 562:	f4a6                	sd	s1,104(sp)
 564:	f0ca                	sd	s2,96(sp)
 566:	ecce                	sd	s3,88(sp)
 568:	e8d2                	sd	s4,80(sp)
 56a:	e4d6                	sd	s5,72(sp)
 56c:	e0da                	sd	s6,64(sp)
 56e:	fc5e                	sd	s7,56(sp)
 570:	f862                	sd	s8,48(sp)
 572:	f466                	sd	s9,40(sp)
 574:	f06a                	sd	s10,32(sp)
 576:	ec6e                	sd	s11,24(sp)
 578:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 57a:	0005c903          	lbu	s2,0(a1)
 57e:	18090f63          	beqz	s2,71c <vprintf+0x1c0>
 582:	8aaa                	mv	s5,a0
 584:	8b32                	mv	s6,a2
 586:	00158493          	addi	s1,a1,1
  state = 0;
 58a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 58c:	02500a13          	li	s4,37
      if(c == 'd'){
 590:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 594:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 598:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 59c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a0:	00000b97          	auipc	s7,0x0
 5a4:	3d8b8b93          	addi	s7,s7,984 # 978 <digits>
 5a8:	a839                	j	5c6 <vprintf+0x6a>
        putc(fd, c);
 5aa:	85ca                	mv	a1,s2
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	ee2080e7          	jalr	-286(ra) # 490 <putc>
 5b6:	a019                	j	5bc <vprintf+0x60>
    } else if(state == '%'){
 5b8:	01498f63          	beq	s3,s4,5d6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5bc:	0485                	addi	s1,s1,1
 5be:	fff4c903          	lbu	s2,-1(s1)
 5c2:	14090d63          	beqz	s2,71c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5c6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5ca:	fe0997e3          	bnez	s3,5b8 <vprintf+0x5c>
      if(c == '%'){
 5ce:	fd479ee3          	bne	a5,s4,5aa <vprintf+0x4e>
        state = '%';
 5d2:	89be                	mv	s3,a5
 5d4:	b7e5                	j	5bc <vprintf+0x60>
      if(c == 'd'){
 5d6:	05878063          	beq	a5,s8,616 <vprintf+0xba>
      } else if(c == 'l') {
 5da:	05978c63          	beq	a5,s9,632 <vprintf+0xd6>
      } else if(c == 'x') {
 5de:	07a78863          	beq	a5,s10,64e <vprintf+0xf2>
      } else if(c == 'p') {
 5e2:	09b78463          	beq	a5,s11,66a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5e6:	07300713          	li	a4,115
 5ea:	0ce78663          	beq	a5,a4,6b6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5ee:	06300713          	li	a4,99
 5f2:	0ee78e63          	beq	a5,a4,6ee <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5f6:	11478863          	beq	a5,s4,706 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5fa:	85d2                	mv	a1,s4
 5fc:	8556                	mv	a0,s5
 5fe:	00000097          	auipc	ra,0x0
 602:	e92080e7          	jalr	-366(ra) # 490 <putc>
        putc(fd, c);
 606:	85ca                	mv	a1,s2
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	e86080e7          	jalr	-378(ra) # 490 <putc>
      }
      state = 0;
 612:	4981                	li	s3,0
 614:	b765                	j	5bc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 616:	008b0913          	addi	s2,s6,8
 61a:	4685                	li	a3,1
 61c:	4629                	li	a2,10
 61e:	000b2583          	lw	a1,0(s6)
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	e8e080e7          	jalr	-370(ra) # 4b2 <printint>
 62c:	8b4a                	mv	s6,s2
      state = 0;
 62e:	4981                	li	s3,0
 630:	b771                	j	5bc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 632:	008b0913          	addi	s2,s6,8
 636:	4681                	li	a3,0
 638:	4629                	li	a2,10
 63a:	000b2583          	lw	a1,0(s6)
 63e:	8556                	mv	a0,s5
 640:	00000097          	auipc	ra,0x0
 644:	e72080e7          	jalr	-398(ra) # 4b2 <printint>
 648:	8b4a                	mv	s6,s2
      state = 0;
 64a:	4981                	li	s3,0
 64c:	bf85                	j	5bc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 64e:	008b0913          	addi	s2,s6,8
 652:	4681                	li	a3,0
 654:	4641                	li	a2,16
 656:	000b2583          	lw	a1,0(s6)
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	e56080e7          	jalr	-426(ra) # 4b2 <printint>
 664:	8b4a                	mv	s6,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	bf91                	j	5bc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 66a:	008b0793          	addi	a5,s6,8
 66e:	f8f43423          	sd	a5,-120(s0)
 672:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 676:	03000593          	li	a1,48
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	e14080e7          	jalr	-492(ra) # 490 <putc>
  putc(fd, 'x');
 684:	85ea                	mv	a1,s10
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	e08080e7          	jalr	-504(ra) # 490 <putc>
 690:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 692:	03c9d793          	srli	a5,s3,0x3c
 696:	97de                	add	a5,a5,s7
 698:	0007c583          	lbu	a1,0(a5)
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	df2080e7          	jalr	-526(ra) # 490 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a6:	0992                	slli	s3,s3,0x4
 6a8:	397d                	addiw	s2,s2,-1
 6aa:	fe0914e3          	bnez	s2,692 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6ae:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b721                	j	5bc <vprintf+0x60>
        s = va_arg(ap, char*);
 6b6:	008b0993          	addi	s3,s6,8
 6ba:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6be:	02090163          	beqz	s2,6e0 <vprintf+0x184>
        while(*s != 0){
 6c2:	00094583          	lbu	a1,0(s2)
 6c6:	c9a1                	beqz	a1,716 <vprintf+0x1ba>
          putc(fd, *s);
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	dc6080e7          	jalr	-570(ra) # 490 <putc>
          s++;
 6d2:	0905                	addi	s2,s2,1
        while(*s != 0){
 6d4:	00094583          	lbu	a1,0(s2)
 6d8:	f9e5                	bnez	a1,6c8 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6da:	8b4e                	mv	s6,s3
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	bdf9                	j	5bc <vprintf+0x60>
          s = "(null)";
 6e0:	00000917          	auipc	s2,0x0
 6e4:	29090913          	addi	s2,s2,656 # 970 <malloc+0x14a>
        while(*s != 0){
 6e8:	02800593          	li	a1,40
 6ec:	bff1                	j	6c8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6ee:	008b0913          	addi	s2,s6,8
 6f2:	000b4583          	lbu	a1,0(s6)
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	d98080e7          	jalr	-616(ra) # 490 <putc>
 700:	8b4a                	mv	s6,s2
      state = 0;
 702:	4981                	li	s3,0
 704:	bd65                	j	5bc <vprintf+0x60>
        putc(fd, c);
 706:	85d2                	mv	a1,s4
 708:	8556                	mv	a0,s5
 70a:	00000097          	auipc	ra,0x0
 70e:	d86080e7          	jalr	-634(ra) # 490 <putc>
      state = 0;
 712:	4981                	li	s3,0
 714:	b565                	j	5bc <vprintf+0x60>
        s = va_arg(ap, char*);
 716:	8b4e                	mv	s6,s3
      state = 0;
 718:	4981                	li	s3,0
 71a:	b54d                	j	5bc <vprintf+0x60>
    }
  }
}
 71c:	70e6                	ld	ra,120(sp)
 71e:	7446                	ld	s0,112(sp)
 720:	74a6                	ld	s1,104(sp)
 722:	7906                	ld	s2,96(sp)
 724:	69e6                	ld	s3,88(sp)
 726:	6a46                	ld	s4,80(sp)
 728:	6aa6                	ld	s5,72(sp)
 72a:	6b06                	ld	s6,64(sp)
 72c:	7be2                	ld	s7,56(sp)
 72e:	7c42                	ld	s8,48(sp)
 730:	7ca2                	ld	s9,40(sp)
 732:	7d02                	ld	s10,32(sp)
 734:	6de2                	ld	s11,24(sp)
 736:	6109                	addi	sp,sp,128
 738:	8082                	ret

000000000000073a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 73a:	715d                	addi	sp,sp,-80
 73c:	ec06                	sd	ra,24(sp)
 73e:	e822                	sd	s0,16(sp)
 740:	1000                	addi	s0,sp,32
 742:	e010                	sd	a2,0(s0)
 744:	e414                	sd	a3,8(s0)
 746:	e818                	sd	a4,16(s0)
 748:	ec1c                	sd	a5,24(s0)
 74a:	03043023          	sd	a6,32(s0)
 74e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 752:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 756:	8622                	mv	a2,s0
 758:	00000097          	auipc	ra,0x0
 75c:	e04080e7          	jalr	-508(ra) # 55c <vprintf>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6161                	addi	sp,sp,80
 766:	8082                	ret

0000000000000768 <printf>:

void
printf(const char *fmt, ...)
{
 768:	711d                	addi	sp,sp,-96
 76a:	ec06                	sd	ra,24(sp)
 76c:	e822                	sd	s0,16(sp)
 76e:	1000                	addi	s0,sp,32
 770:	e40c                	sd	a1,8(s0)
 772:	e810                	sd	a2,16(s0)
 774:	ec14                	sd	a3,24(s0)
 776:	f018                	sd	a4,32(s0)
 778:	f41c                	sd	a5,40(s0)
 77a:	03043823          	sd	a6,48(s0)
 77e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 782:	00840613          	addi	a2,s0,8
 786:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78a:	85aa                	mv	a1,a0
 78c:	4505                	li	a0,1
 78e:	00000097          	auipc	ra,0x0
 792:	dce080e7          	jalr	-562(ra) # 55c <vprintf>
}
 796:	60e2                	ld	ra,24(sp)
 798:	6442                	ld	s0,16(sp)
 79a:	6125                	addi	sp,sp,96
 79c:	8082                	ret

000000000000079e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79e:	1141                	addi	sp,sp,-16
 7a0:	e422                	sd	s0,8(sp)
 7a2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a8:	00000797          	auipc	a5,0x0
 7ac:	1e87b783          	ld	a5,488(a5) # 990 <freep>
 7b0:	a805                	j	7e0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b2:	4618                	lw	a4,8(a2)
 7b4:	9db9                	addw	a1,a1,a4
 7b6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ba:	6398                	ld	a4,0(a5)
 7bc:	6318                	ld	a4,0(a4)
 7be:	fee53823          	sd	a4,-16(a0)
 7c2:	a091                	j	806 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c4:	ff852703          	lw	a4,-8(a0)
 7c8:	9e39                	addw	a2,a2,a4
 7ca:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7cc:	ff053703          	ld	a4,-16(a0)
 7d0:	e398                	sd	a4,0(a5)
 7d2:	a099                	j	818 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d4:	6398                	ld	a4,0(a5)
 7d6:	00e7e463          	bltu	a5,a4,7de <free+0x40>
 7da:	00e6ea63          	bltu	a3,a4,7ee <free+0x50>
{
 7de:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e0:	fed7fae3          	bgeu	a5,a3,7d4 <free+0x36>
 7e4:	6398                	ld	a4,0(a5)
 7e6:	00e6e463          	bltu	a3,a4,7ee <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ea:	fee7eae3          	bltu	a5,a4,7de <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7ee:	ff852583          	lw	a1,-8(a0)
 7f2:	6390                	ld	a2,0(a5)
 7f4:	02059713          	slli	a4,a1,0x20
 7f8:	9301                	srli	a4,a4,0x20
 7fa:	0712                	slli	a4,a4,0x4
 7fc:	9736                	add	a4,a4,a3
 7fe:	fae60ae3          	beq	a2,a4,7b2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 802:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 806:	4790                	lw	a2,8(a5)
 808:	02061713          	slli	a4,a2,0x20
 80c:	9301                	srli	a4,a4,0x20
 80e:	0712                	slli	a4,a4,0x4
 810:	973e                	add	a4,a4,a5
 812:	fae689e3          	beq	a3,a4,7c4 <free+0x26>
  } else
    p->s.ptr = bp;
 816:	e394                	sd	a3,0(a5)
  freep = p;
 818:	00000717          	auipc	a4,0x0
 81c:	16f73c23          	sd	a5,376(a4) # 990 <freep>
}
 820:	6422                	ld	s0,8(sp)
 822:	0141                	addi	sp,sp,16
 824:	8082                	ret

0000000000000826 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 826:	7139                	addi	sp,sp,-64
 828:	fc06                	sd	ra,56(sp)
 82a:	f822                	sd	s0,48(sp)
 82c:	f426                	sd	s1,40(sp)
 82e:	f04a                	sd	s2,32(sp)
 830:	ec4e                	sd	s3,24(sp)
 832:	e852                	sd	s4,16(sp)
 834:	e456                	sd	s5,8(sp)
 836:	e05a                	sd	s6,0(sp)
 838:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 83a:	02051493          	slli	s1,a0,0x20
 83e:	9081                	srli	s1,s1,0x20
 840:	04bd                	addi	s1,s1,15
 842:	8091                	srli	s1,s1,0x4
 844:	0014899b          	addiw	s3,s1,1
 848:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 84a:	00000517          	auipc	a0,0x0
 84e:	14653503          	ld	a0,326(a0) # 990 <freep>
 852:	c515                	beqz	a0,87e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 854:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 856:	4798                	lw	a4,8(a5)
 858:	02977f63          	bgeu	a4,s1,896 <malloc+0x70>
 85c:	8a4e                	mv	s4,s3
 85e:	0009871b          	sext.w	a4,s3
 862:	6685                	lui	a3,0x1
 864:	00d77363          	bgeu	a4,a3,86a <malloc+0x44>
 868:	6a05                	lui	s4,0x1
 86a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 86e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 872:	00000917          	auipc	s2,0x0
 876:	11e90913          	addi	s2,s2,286 # 990 <freep>
  if(p == (char*)-1)
 87a:	5afd                	li	s5,-1
 87c:	a88d                	j	8ee <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 87e:	00000797          	auipc	a5,0x0
 882:	11a78793          	addi	a5,a5,282 # 998 <base>
 886:	00000717          	auipc	a4,0x0
 88a:	10f73523          	sd	a5,266(a4) # 990 <freep>
 88e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 890:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 894:	b7e1                	j	85c <malloc+0x36>
      if(p->s.size == nunits)
 896:	02e48b63          	beq	s1,a4,8cc <malloc+0xa6>
        p->s.size -= nunits;
 89a:	4137073b          	subw	a4,a4,s3
 89e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a0:	1702                	slli	a4,a4,0x20
 8a2:	9301                	srli	a4,a4,0x20
 8a4:	0712                	slli	a4,a4,0x4
 8a6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ac:	00000717          	auipc	a4,0x0
 8b0:	0ea73223          	sd	a0,228(a4) # 990 <freep>
      return (void*)(p + 1);
 8b4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8b8:	70e2                	ld	ra,56(sp)
 8ba:	7442                	ld	s0,48(sp)
 8bc:	74a2                	ld	s1,40(sp)
 8be:	7902                	ld	s2,32(sp)
 8c0:	69e2                	ld	s3,24(sp)
 8c2:	6a42                	ld	s4,16(sp)
 8c4:	6aa2                	ld	s5,8(sp)
 8c6:	6b02                	ld	s6,0(sp)
 8c8:	6121                	addi	sp,sp,64
 8ca:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8cc:	6398                	ld	a4,0(a5)
 8ce:	e118                	sd	a4,0(a0)
 8d0:	bff1                	j	8ac <malloc+0x86>
  hp->s.size = nu;
 8d2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d6:	0541                	addi	a0,a0,16
 8d8:	00000097          	auipc	ra,0x0
 8dc:	ec6080e7          	jalr	-314(ra) # 79e <free>
  return freep;
 8e0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e4:	d971                	beqz	a0,8b8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e8:	4798                	lw	a4,8(a5)
 8ea:	fa9776e3          	bgeu	a4,s1,896 <malloc+0x70>
    if(p == freep)
 8ee:	00093703          	ld	a4,0(s2)
 8f2:	853e                	mv	a0,a5
 8f4:	fef719e3          	bne	a4,a5,8e6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8f8:	8552                	mv	a0,s4
 8fa:	00000097          	auipc	ra,0x0
 8fe:	b1a080e7          	jalr	-1254(ra) # 414 <sbrk>
  if(p == (char*)-1)
 902:	fd5518e3          	bne	a0,s5,8d2 <malloc+0xac>
        return 0;
 906:	4501                	li	a0,0
 908:	bf45                	j	8b8 <malloc+0x92>
