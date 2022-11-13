
user/_pipeline:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64
  int pipefd[2], x, y, n, i;

  if (argc != 3) {
   e:	478d                	li	a5,3
  10:	02f50063          	beq	a0,a5,30 <main+0x30>
     fprintf(2, "syntax: pipeline n x\nAborting...\n");
  14:	00001597          	auipc	a1,0x1
  18:	9bc58593          	addi	a1,a1,-1604 # 9d0 <malloc+0xea>
  1c:	4509                	li	a0,2
  1e:	00000097          	auipc	ra,0x0
  22:	7dc080e7          	jalr	2012(ra) # 7fa <fprintf>
     exit(0);
  26:	4501                	li	a0,0
  28:	00000097          	auipc	ra,0x0
  2c:	424080e7          	jalr	1060(ra) # 44c <exit>
  30:	84ae                	mv	s1,a1
  }
  n = atoi(argv[1]);
  32:	6588                	ld	a0,8(a1)
  34:	00000097          	auipc	ra,0x0
  38:	318080e7          	jalr	792(ra) # 34c <atoi>
  3c:	892a                	mv	s2,a0
  if (n <= 0) {
  3e:	0ea05663          	blez	a0,12a <main+0x12a>
     fprintf(2, "Invalid input\nAborting...\n");
     exit(0);
  }
  x = atoi(argv[2]);
  42:	6888                	ld	a0,16(s1)
  44:	00000097          	auipc	ra,0x0
  48:	308080e7          	jalr	776(ra) # 34c <atoi>
  4c:	fca42223          	sw	a0,-60(s0)

  x += getpid();
  50:	00000097          	auipc	ra,0x0
  54:	47c080e7          	jalr	1148(ra) # 4cc <getpid>
  58:	fc442783          	lw	a5,-60(s0)
  5c:	9fa9                	addw	a5,a5,a0
  5e:	fcf42223          	sw	a5,-60(s0)
  fprintf(1, "%d: %d\n", getpid(), x);
  62:	00000097          	auipc	ra,0x0
  66:	46a080e7          	jalr	1130(ra) # 4cc <getpid>
  6a:	862a                	mv	a2,a0
  6c:	fc442683          	lw	a3,-60(s0)
  70:	00001597          	auipc	a1,0x1
  74:	9a858593          	addi	a1,a1,-1624 # a18 <malloc+0x132>
  78:	4505                	li	a0,1
  7a:	00000097          	auipc	ra,0x0
  7e:	780080e7          	jalr	1920(ra) # 7fa <fprintf>

  for (i=2; i<=n; i++) {
  82:	4785                	li	a5,1
  84:	1327d663          	bge	a5,s2,1b0 <main+0x1b0>
  88:	4489                	li	s1,2
        if (read(pipefd[0], &x, sizeof(int)) < 0) {
           fprintf(2, "Error: cannot read from pipe\nAborting...\n");
           exit(0);
        }
	x += getpid();
	fprintf(1, "%d: %d\n", getpid(), x);
  8a:	00001997          	auipc	s3,0x1
  8e:	98e98993          	addi	s3,s3,-1650 # a18 <malloc+0x132>
     if (pipe(pipefd) < 0) {
  92:	fc840513          	addi	a0,s0,-56
  96:	00000097          	auipc	ra,0x0
  9a:	3c6080e7          	jalr	966(ra) # 45c <pipe>
  9e:	0a054463          	bltz	a0,146 <main+0x146>
     if (write(pipefd[1], &x, sizeof(int)) < 0) {
  a2:	4611                	li	a2,4
  a4:	fc440593          	addi	a1,s0,-60
  a8:	fcc42503          	lw	a0,-52(s0)
  ac:	00000097          	auipc	ra,0x0
  b0:	3c0080e7          	jalr	960(ra) # 46c <write>
  b4:	0a054763          	bltz	a0,162 <main+0x162>
     close(pipefd[1]);
  b8:	fcc42503          	lw	a0,-52(s0)
  bc:	00000097          	auipc	ra,0x0
  c0:	3b8080e7          	jalr	952(ra) # 474 <close>
     y = fork();
  c4:	00000097          	auipc	ra,0x0
  c8:	380080e7          	jalr	896(ra) # 444 <fork>
     if (y < 0) {
  cc:	0a054963          	bltz	a0,17e <main+0x17e>
     else if (y > 0) {
  d0:	0ca04563          	bgtz	a0,19a <main+0x19a>
        if (read(pipefd[0], &x, sizeof(int)) < 0) {
  d4:	4611                	li	a2,4
  d6:	fc440593          	addi	a1,s0,-60
  da:	fc842503          	lw	a0,-56(s0)
  de:	00000097          	auipc	ra,0x0
  e2:	386080e7          	jalr	902(ra) # 464 <read>
  e6:	0c054a63          	bltz	a0,1ba <main+0x1ba>
	x += getpid();
  ea:	00000097          	auipc	ra,0x0
  ee:	3e2080e7          	jalr	994(ra) # 4cc <getpid>
  f2:	fc442783          	lw	a5,-60(s0)
  f6:	9fa9                	addw	a5,a5,a0
  f8:	fcf42223          	sw	a5,-60(s0)
	fprintf(1, "%d: %d\n", getpid(), x);
  fc:	00000097          	auipc	ra,0x0
 100:	3d0080e7          	jalr	976(ra) # 4cc <getpid>
 104:	862a                	mv	a2,a0
 106:	fc442683          	lw	a3,-60(s0)
 10a:	85ce                	mv	a1,s3
 10c:	4505                	li	a0,1
 10e:	00000097          	auipc	ra,0x0
 112:	6ec080e7          	jalr	1772(ra) # 7fa <fprintf>
	close(pipefd[0]);
 116:	fc842503          	lw	a0,-56(s0)
 11a:	00000097          	auipc	ra,0x0
 11e:	35a080e7          	jalr	858(ra) # 474 <close>
  for (i=2; i<=n; i++) {
 122:	2485                	addiw	s1,s1,1
 124:	f69957e3          	bge	s2,s1,92 <main+0x92>
 128:	a061                	j	1b0 <main+0x1b0>
     fprintf(2, "Invalid input\nAborting...\n");
 12a:	00001597          	auipc	a1,0x1
 12e:	8ce58593          	addi	a1,a1,-1842 # 9f8 <malloc+0x112>
 132:	4509                	li	a0,2
 134:	00000097          	auipc	ra,0x0
 138:	6c6080e7          	jalr	1734(ra) # 7fa <fprintf>
     exit(0);
 13c:	4501                	li	a0,0
 13e:	00000097          	auipc	ra,0x0
 142:	30e080e7          	jalr	782(ra) # 44c <exit>
        fprintf(2, "Error: cannot create pipe\nAborting...\n");
 146:	00001597          	auipc	a1,0x1
 14a:	8da58593          	addi	a1,a1,-1830 # a20 <malloc+0x13a>
 14e:	4509                	li	a0,2
 150:	00000097          	auipc	ra,0x0
 154:	6aa080e7          	jalr	1706(ra) # 7fa <fprintf>
        exit(0);
 158:	4501                	li	a0,0
 15a:	00000097          	auipc	ra,0x0
 15e:	2f2080e7          	jalr	754(ra) # 44c <exit>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
 162:	00001597          	auipc	a1,0x1
 166:	8e658593          	addi	a1,a1,-1818 # a48 <malloc+0x162>
 16a:	4509                	li	a0,2
 16c:	00000097          	auipc	ra,0x0
 170:	68e080e7          	jalr	1678(ra) # 7fa <fprintf>
        exit(0);
 174:	4501                	li	a0,0
 176:	00000097          	auipc	ra,0x0
 17a:	2d6080e7          	jalr	726(ra) # 44c <exit>
        fprintf(2, "Error: cannot fork\nAborting...\n");
 17e:	00001597          	auipc	a1,0x1
 182:	8fa58593          	addi	a1,a1,-1798 # a78 <malloc+0x192>
 186:	4509                	li	a0,2
 188:	00000097          	auipc	ra,0x0
 18c:	672080e7          	jalr	1650(ra) # 7fa <fprintf>
	exit(0);
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	2ba080e7          	jalr	698(ra) # 44c <exit>
	close(pipefd[0]);
 19a:	fc842503          	lw	a0,-56(s0)
 19e:	00000097          	auipc	ra,0x0
 1a2:	2d6080e7          	jalr	726(ra) # 474 <close>
        wait(0);
 1a6:	4501                	li	a0,0
 1a8:	00000097          	auipc	ra,0x0
 1ac:	2ac080e7          	jalr	684(ra) # 454 <wait>
     }
  }

  exit(0);
 1b0:	4501                	li	a0,0
 1b2:	00000097          	auipc	ra,0x0
 1b6:	29a080e7          	jalr	666(ra) # 44c <exit>
           fprintf(2, "Error: cannot read from pipe\nAborting...\n");
 1ba:	00001597          	auipc	a1,0x1
 1be:	8de58593          	addi	a1,a1,-1826 # a98 <malloc+0x1b2>
 1c2:	4509                	li	a0,2
 1c4:	00000097          	auipc	ra,0x0
 1c8:	636080e7          	jalr	1590(ra) # 7fa <fprintf>
           exit(0);
 1cc:	4501                	li	a0,0
 1ce:	00000097          	auipc	ra,0x0
 1d2:	27e080e7          	jalr	638(ra) # 44c <exit>

00000000000001d6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1dc:	87aa                	mv	a5,a0
 1de:	0585                	addi	a1,a1,1
 1e0:	0785                	addi	a5,a5,1
 1e2:	fff5c703          	lbu	a4,-1(a1)
 1e6:	fee78fa3          	sb	a4,-1(a5)
 1ea:	fb75                	bnez	a4,1de <strcpy+0x8>
    ;
  return os;
}
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret

00000000000001f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	cb91                	beqz	a5,210 <strcmp+0x1e>
 1fe:	0005c703          	lbu	a4,0(a1)
 202:	00f71763          	bne	a4,a5,210 <strcmp+0x1e>
    p++, q++;
 206:	0505                	addi	a0,a0,1
 208:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	fbe5                	bnez	a5,1fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 210:	0005c503          	lbu	a0,0(a1)
}
 214:	40a7853b          	subw	a0,a5,a0
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret

000000000000021e <strlen>:

uint
strlen(const char *s)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 224:	00054783          	lbu	a5,0(a0)
 228:	cf91                	beqz	a5,244 <strlen+0x26>
 22a:	0505                	addi	a0,a0,1
 22c:	87aa                	mv	a5,a0
 22e:	4685                	li	a3,1
 230:	9e89                	subw	a3,a3,a0
 232:	00f6853b          	addw	a0,a3,a5
 236:	0785                	addi	a5,a5,1
 238:	fff7c703          	lbu	a4,-1(a5)
 23c:	fb7d                	bnez	a4,232 <strlen+0x14>
    ;
  return n;
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret
  for(n = 0; s[n]; n++)
 244:	4501                	li	a0,0
 246:	bfe5                	j	23e <strlen+0x20>

0000000000000248 <memset>:

void*
memset(void *dst, int c, uint n)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 24e:	ce09                	beqz	a2,268 <memset+0x20>
 250:	87aa                	mv	a5,a0
 252:	fff6071b          	addiw	a4,a2,-1
 256:	1702                	slli	a4,a4,0x20
 258:	9301                	srli	a4,a4,0x20
 25a:	0705                	addi	a4,a4,1
 25c:	972a                	add	a4,a4,a0
    cdst[i] = c;
 25e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 262:	0785                	addi	a5,a5,1
 264:	fee79de3          	bne	a5,a4,25e <memset+0x16>
  }
  return dst;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret

000000000000026e <strchr>:

char*
strchr(const char *s, char c)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  for(; *s; s++)
 274:	00054783          	lbu	a5,0(a0)
 278:	cb99                	beqz	a5,28e <strchr+0x20>
    if(*s == c)
 27a:	00f58763          	beq	a1,a5,288 <strchr+0x1a>
  for(; *s; s++)
 27e:	0505                	addi	a0,a0,1
 280:	00054783          	lbu	a5,0(a0)
 284:	fbfd                	bnez	a5,27a <strchr+0xc>
      return (char*)s;
  return 0;
 286:	4501                	li	a0,0
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
  return 0;
 28e:	4501                	li	a0,0
 290:	bfe5                	j	288 <strchr+0x1a>

0000000000000292 <gets>:

char*
gets(char *buf, int max)
{
 292:	711d                	addi	sp,sp,-96
 294:	ec86                	sd	ra,88(sp)
 296:	e8a2                	sd	s0,80(sp)
 298:	e4a6                	sd	s1,72(sp)
 29a:	e0ca                	sd	s2,64(sp)
 29c:	fc4e                	sd	s3,56(sp)
 29e:	f852                	sd	s4,48(sp)
 2a0:	f456                	sd	s5,40(sp)
 2a2:	f05a                	sd	s6,32(sp)
 2a4:	ec5e                	sd	s7,24(sp)
 2a6:	1080                	addi	s0,sp,96
 2a8:	8baa                	mv	s7,a0
 2aa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ac:	892a                	mv	s2,a0
 2ae:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2b0:	4aa9                	li	s5,10
 2b2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2b4:	89a6                	mv	s3,s1
 2b6:	2485                	addiw	s1,s1,1
 2b8:	0344d863          	bge	s1,s4,2e8 <gets+0x56>
    cc = read(0, &c, 1);
 2bc:	4605                	li	a2,1
 2be:	faf40593          	addi	a1,s0,-81
 2c2:	4501                	li	a0,0
 2c4:	00000097          	auipc	ra,0x0
 2c8:	1a0080e7          	jalr	416(ra) # 464 <read>
    if(cc < 1)
 2cc:	00a05e63          	blez	a0,2e8 <gets+0x56>
    buf[i++] = c;
 2d0:	faf44783          	lbu	a5,-81(s0)
 2d4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2d8:	01578763          	beq	a5,s5,2e6 <gets+0x54>
 2dc:	0905                	addi	s2,s2,1
 2de:	fd679be3          	bne	a5,s6,2b4 <gets+0x22>
  for(i=0; i+1 < max; ){
 2e2:	89a6                	mv	s3,s1
 2e4:	a011                	j	2e8 <gets+0x56>
 2e6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2e8:	99de                	add	s3,s3,s7
 2ea:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ee:	855e                	mv	a0,s7
 2f0:	60e6                	ld	ra,88(sp)
 2f2:	6446                	ld	s0,80(sp)
 2f4:	64a6                	ld	s1,72(sp)
 2f6:	6906                	ld	s2,64(sp)
 2f8:	79e2                	ld	s3,56(sp)
 2fa:	7a42                	ld	s4,48(sp)
 2fc:	7aa2                	ld	s5,40(sp)
 2fe:	7b02                	ld	s6,32(sp)
 300:	6be2                	ld	s7,24(sp)
 302:	6125                	addi	sp,sp,96
 304:	8082                	ret

0000000000000306 <stat>:

int
stat(const char *n, struct stat *st)
{
 306:	1101                	addi	sp,sp,-32
 308:	ec06                	sd	ra,24(sp)
 30a:	e822                	sd	s0,16(sp)
 30c:	e426                	sd	s1,8(sp)
 30e:	e04a                	sd	s2,0(sp)
 310:	1000                	addi	s0,sp,32
 312:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 314:	4581                	li	a1,0
 316:	00000097          	auipc	ra,0x0
 31a:	176080e7          	jalr	374(ra) # 48c <open>
  if(fd < 0)
 31e:	02054563          	bltz	a0,348 <stat+0x42>
 322:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 324:	85ca                	mv	a1,s2
 326:	00000097          	auipc	ra,0x0
 32a:	17e080e7          	jalr	382(ra) # 4a4 <fstat>
 32e:	892a                	mv	s2,a0
  close(fd);
 330:	8526                	mv	a0,s1
 332:	00000097          	auipc	ra,0x0
 336:	142080e7          	jalr	322(ra) # 474 <close>
  return r;
}
 33a:	854a                	mv	a0,s2
 33c:	60e2                	ld	ra,24(sp)
 33e:	6442                	ld	s0,16(sp)
 340:	64a2                	ld	s1,8(sp)
 342:	6902                	ld	s2,0(sp)
 344:	6105                	addi	sp,sp,32
 346:	8082                	ret
    return -1;
 348:	597d                	li	s2,-1
 34a:	bfc5                	j	33a <stat+0x34>

000000000000034c <atoi>:

int
atoi(const char *s)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 352:	00054603          	lbu	a2,0(a0)
 356:	fd06079b          	addiw	a5,a2,-48
 35a:	0ff7f793          	andi	a5,a5,255
 35e:	4725                	li	a4,9
 360:	02f76963          	bltu	a4,a5,392 <atoi+0x46>
 364:	86aa                	mv	a3,a0
  n = 0;
 366:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 368:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 36a:	0685                	addi	a3,a3,1
 36c:	0025179b          	slliw	a5,a0,0x2
 370:	9fa9                	addw	a5,a5,a0
 372:	0017979b          	slliw	a5,a5,0x1
 376:	9fb1                	addw	a5,a5,a2
 378:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 37c:	0006c603          	lbu	a2,0(a3)
 380:	fd06071b          	addiw	a4,a2,-48
 384:	0ff77713          	andi	a4,a4,255
 388:	fee5f1e3          	bgeu	a1,a4,36a <atoi+0x1e>
  return n;
}
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret
  n = 0;
 392:	4501                	li	a0,0
 394:	bfe5                	j	38c <atoi+0x40>

0000000000000396 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 396:	1141                	addi	sp,sp,-16
 398:	e422                	sd	s0,8(sp)
 39a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 39c:	02b57663          	bgeu	a0,a1,3c8 <memmove+0x32>
    while(n-- > 0)
 3a0:	02c05163          	blez	a2,3c2 <memmove+0x2c>
 3a4:	fff6079b          	addiw	a5,a2,-1
 3a8:	1782                	slli	a5,a5,0x20
 3aa:	9381                	srli	a5,a5,0x20
 3ac:	0785                	addi	a5,a5,1
 3ae:	97aa                	add	a5,a5,a0
  dst = vdst;
 3b0:	872a                	mv	a4,a0
      *dst++ = *src++;
 3b2:	0585                	addi	a1,a1,1
 3b4:	0705                	addi	a4,a4,1
 3b6:	fff5c683          	lbu	a3,-1(a1)
 3ba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3be:	fee79ae3          	bne	a5,a4,3b2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3c2:	6422                	ld	s0,8(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret
    dst += n;
 3c8:	00c50733          	add	a4,a0,a2
    src += n;
 3cc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3ce:	fec05ae3          	blez	a2,3c2 <memmove+0x2c>
 3d2:	fff6079b          	addiw	a5,a2,-1
 3d6:	1782                	slli	a5,a5,0x20
 3d8:	9381                	srli	a5,a5,0x20
 3da:	fff7c793          	not	a5,a5
 3de:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3e0:	15fd                	addi	a1,a1,-1
 3e2:	177d                	addi	a4,a4,-1
 3e4:	0005c683          	lbu	a3,0(a1)
 3e8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ec:	fee79ae3          	bne	a5,a4,3e0 <memmove+0x4a>
 3f0:	bfc9                	j	3c2 <memmove+0x2c>

00000000000003f2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3f2:	1141                	addi	sp,sp,-16
 3f4:	e422                	sd	s0,8(sp)
 3f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f8:	ca05                	beqz	a2,428 <memcmp+0x36>
 3fa:	fff6069b          	addiw	a3,a2,-1
 3fe:	1682                	slli	a3,a3,0x20
 400:	9281                	srli	a3,a3,0x20
 402:	0685                	addi	a3,a3,1
 404:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 406:	00054783          	lbu	a5,0(a0)
 40a:	0005c703          	lbu	a4,0(a1)
 40e:	00e79863          	bne	a5,a4,41e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 412:	0505                	addi	a0,a0,1
    p2++;
 414:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 416:	fed518e3          	bne	a0,a3,406 <memcmp+0x14>
  }
  return 0;
 41a:	4501                	li	a0,0
 41c:	a019                	j	422 <memcmp+0x30>
      return *p1 - *p2;
 41e:	40e7853b          	subw	a0,a5,a4
}
 422:	6422                	ld	s0,8(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret
  return 0;
 428:	4501                	li	a0,0
 42a:	bfe5                	j	422 <memcmp+0x30>

000000000000042c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 42c:	1141                	addi	sp,sp,-16
 42e:	e406                	sd	ra,8(sp)
 430:	e022                	sd	s0,0(sp)
 432:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 434:	00000097          	auipc	ra,0x0
 438:	f62080e7          	jalr	-158(ra) # 396 <memmove>
}
 43c:	60a2                	ld	ra,8(sp)
 43e:	6402                	ld	s0,0(sp)
 440:	0141                	addi	sp,sp,16
 442:	8082                	ret

0000000000000444 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 444:	4885                	li	a7,1
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <exit>:
.global exit
exit:
 li a7, SYS_exit
 44c:	4889                	li	a7,2
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <wait>:
.global wait
wait:
 li a7, SYS_wait
 454:	488d                	li	a7,3
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 45c:	4891                	li	a7,4
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <read>:
.global read
read:
 li a7, SYS_read
 464:	4895                	li	a7,5
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <write>:
.global write
write:
 li a7, SYS_write
 46c:	48c1                	li	a7,16
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <close>:
.global close
close:
 li a7, SYS_close
 474:	48d5                	li	a7,21
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <kill>:
.global kill
kill:
 li a7, SYS_kill
 47c:	4899                	li	a7,6
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <exec>:
.global exec
exec:
 li a7, SYS_exec
 484:	489d                	li	a7,7
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <open>:
.global open
open:
 li a7, SYS_open
 48c:	48bd                	li	a7,15
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 494:	48c5                	li	a7,17
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 49c:	48c9                	li	a7,18
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4a4:	48a1                	li	a7,8
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <link>:
.global link
link:
 li a7, SYS_link
 4ac:	48cd                	li	a7,19
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b4:	48d1                	li	a7,20
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4bc:	48a5                	li	a7,9
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c4:	48a9                	li	a7,10
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4cc:	48ad                	li	a7,11
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4d4:	48b1                	li	a7,12
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4dc:	48b5                	li	a7,13
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e4:	48b9                	li	a7,14
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 4ec:	48d9                	li	a7,22
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <yield>:
.global yield
yield:
 li a7, SYS_yield
 4f4:	48dd                	li	a7,23
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 4fc:	48e1                	li	a7,24
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 504:	48e5                	li	a7,25
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 50c:	48e9                	li	a7,26
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <ps>:
.global ps
ps:
 li a7, SYS_ps
 514:	48ed                	li	a7,27
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 51c:	48f1                	li	a7,28
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 524:	48f5                	li	a7,29
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 52c:	48f9                	li	a7,30
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 534:	48fd                	li	a7,31
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 53c:	02000893          	li	a7,32
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 546:	02100893          	li	a7,33
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 550:	1101                	addi	sp,sp,-32
 552:	ec06                	sd	ra,24(sp)
 554:	e822                	sd	s0,16(sp)
 556:	1000                	addi	s0,sp,32
 558:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 55c:	4605                	li	a2,1
 55e:	fef40593          	addi	a1,s0,-17
 562:	00000097          	auipc	ra,0x0
 566:	f0a080e7          	jalr	-246(ra) # 46c <write>
}
 56a:	60e2                	ld	ra,24(sp)
 56c:	6442                	ld	s0,16(sp)
 56e:	6105                	addi	sp,sp,32
 570:	8082                	ret

0000000000000572 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 572:	7139                	addi	sp,sp,-64
 574:	fc06                	sd	ra,56(sp)
 576:	f822                	sd	s0,48(sp)
 578:	f426                	sd	s1,40(sp)
 57a:	f04a                	sd	s2,32(sp)
 57c:	ec4e                	sd	s3,24(sp)
 57e:	0080                	addi	s0,sp,64
 580:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 582:	c299                	beqz	a3,588 <printint+0x16>
 584:	0805c863          	bltz	a1,614 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 588:	2581                	sext.w	a1,a1
  neg = 0;
 58a:	4881                	li	a7,0
 58c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 590:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 592:	2601                	sext.w	a2,a2
 594:	00000517          	auipc	a0,0x0
 598:	53c50513          	addi	a0,a0,1340 # ad0 <digits>
 59c:	883a                	mv	a6,a4
 59e:	2705                	addiw	a4,a4,1
 5a0:	02c5f7bb          	remuw	a5,a1,a2
 5a4:	1782                	slli	a5,a5,0x20
 5a6:	9381                	srli	a5,a5,0x20
 5a8:	97aa                	add	a5,a5,a0
 5aa:	0007c783          	lbu	a5,0(a5)
 5ae:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5b2:	0005879b          	sext.w	a5,a1
 5b6:	02c5d5bb          	divuw	a1,a1,a2
 5ba:	0685                	addi	a3,a3,1
 5bc:	fec7f0e3          	bgeu	a5,a2,59c <printint+0x2a>
  if(neg)
 5c0:	00088b63          	beqz	a7,5d6 <printint+0x64>
    buf[i++] = '-';
 5c4:	fd040793          	addi	a5,s0,-48
 5c8:	973e                	add	a4,a4,a5
 5ca:	02d00793          	li	a5,45
 5ce:	fef70823          	sb	a5,-16(a4)
 5d2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5d6:	02e05863          	blez	a4,606 <printint+0x94>
 5da:	fc040793          	addi	a5,s0,-64
 5de:	00e78933          	add	s2,a5,a4
 5e2:	fff78993          	addi	s3,a5,-1
 5e6:	99ba                	add	s3,s3,a4
 5e8:	377d                	addiw	a4,a4,-1
 5ea:	1702                	slli	a4,a4,0x20
 5ec:	9301                	srli	a4,a4,0x20
 5ee:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5f2:	fff94583          	lbu	a1,-1(s2)
 5f6:	8526                	mv	a0,s1
 5f8:	00000097          	auipc	ra,0x0
 5fc:	f58080e7          	jalr	-168(ra) # 550 <putc>
  while(--i >= 0)
 600:	197d                	addi	s2,s2,-1
 602:	ff3918e3          	bne	s2,s3,5f2 <printint+0x80>
}
 606:	70e2                	ld	ra,56(sp)
 608:	7442                	ld	s0,48(sp)
 60a:	74a2                	ld	s1,40(sp)
 60c:	7902                	ld	s2,32(sp)
 60e:	69e2                	ld	s3,24(sp)
 610:	6121                	addi	sp,sp,64
 612:	8082                	ret
    x = -xx;
 614:	40b005bb          	negw	a1,a1
    neg = 1;
 618:	4885                	li	a7,1
    x = -xx;
 61a:	bf8d                	j	58c <printint+0x1a>

000000000000061c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 61c:	7119                	addi	sp,sp,-128
 61e:	fc86                	sd	ra,120(sp)
 620:	f8a2                	sd	s0,112(sp)
 622:	f4a6                	sd	s1,104(sp)
 624:	f0ca                	sd	s2,96(sp)
 626:	ecce                	sd	s3,88(sp)
 628:	e8d2                	sd	s4,80(sp)
 62a:	e4d6                	sd	s5,72(sp)
 62c:	e0da                	sd	s6,64(sp)
 62e:	fc5e                	sd	s7,56(sp)
 630:	f862                	sd	s8,48(sp)
 632:	f466                	sd	s9,40(sp)
 634:	f06a                	sd	s10,32(sp)
 636:	ec6e                	sd	s11,24(sp)
 638:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 63a:	0005c903          	lbu	s2,0(a1)
 63e:	18090f63          	beqz	s2,7dc <vprintf+0x1c0>
 642:	8aaa                	mv	s5,a0
 644:	8b32                	mv	s6,a2
 646:	00158493          	addi	s1,a1,1
  state = 0;
 64a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 64c:	02500a13          	li	s4,37
      if(c == 'd'){
 650:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 654:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 658:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 65c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 660:	00000b97          	auipc	s7,0x0
 664:	470b8b93          	addi	s7,s7,1136 # ad0 <digits>
 668:	a839                	j	686 <vprintf+0x6a>
        putc(fd, c);
 66a:	85ca                	mv	a1,s2
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	ee2080e7          	jalr	-286(ra) # 550 <putc>
 676:	a019                	j	67c <vprintf+0x60>
    } else if(state == '%'){
 678:	01498f63          	beq	s3,s4,696 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 67c:	0485                	addi	s1,s1,1
 67e:	fff4c903          	lbu	s2,-1(s1)
 682:	14090d63          	beqz	s2,7dc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 686:	0009079b          	sext.w	a5,s2
    if(state == 0){
 68a:	fe0997e3          	bnez	s3,678 <vprintf+0x5c>
      if(c == '%'){
 68e:	fd479ee3          	bne	a5,s4,66a <vprintf+0x4e>
        state = '%';
 692:	89be                	mv	s3,a5
 694:	b7e5                	j	67c <vprintf+0x60>
      if(c == 'd'){
 696:	05878063          	beq	a5,s8,6d6 <vprintf+0xba>
      } else if(c == 'l') {
 69a:	05978c63          	beq	a5,s9,6f2 <vprintf+0xd6>
      } else if(c == 'x') {
 69e:	07a78863          	beq	a5,s10,70e <vprintf+0xf2>
      } else if(c == 'p') {
 6a2:	09b78463          	beq	a5,s11,72a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6a6:	07300713          	li	a4,115
 6aa:	0ce78663          	beq	a5,a4,776 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ae:	06300713          	li	a4,99
 6b2:	0ee78e63          	beq	a5,a4,7ae <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6b6:	11478863          	beq	a5,s4,7c6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ba:	85d2                	mv	a1,s4
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	e92080e7          	jalr	-366(ra) # 550 <putc>
        putc(fd, c);
 6c6:	85ca                	mv	a1,s2
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	e86080e7          	jalr	-378(ra) # 550 <putc>
      }
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	b765                	j	67c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6d6:	008b0913          	addi	s2,s6,8
 6da:	4685                	li	a3,1
 6dc:	4629                	li	a2,10
 6de:	000b2583          	lw	a1,0(s6)
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	e8e080e7          	jalr	-370(ra) # 572 <printint>
 6ec:	8b4a                	mv	s6,s2
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b771                	j	67c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f2:	008b0913          	addi	s2,s6,8
 6f6:	4681                	li	a3,0
 6f8:	4629                	li	a2,10
 6fa:	000b2583          	lw	a1,0(s6)
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	e72080e7          	jalr	-398(ra) # 572 <printint>
 708:	8b4a                	mv	s6,s2
      state = 0;
 70a:	4981                	li	s3,0
 70c:	bf85                	j	67c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 70e:	008b0913          	addi	s2,s6,8
 712:	4681                	li	a3,0
 714:	4641                	li	a2,16
 716:	000b2583          	lw	a1,0(s6)
 71a:	8556                	mv	a0,s5
 71c:	00000097          	auipc	ra,0x0
 720:	e56080e7          	jalr	-426(ra) # 572 <printint>
 724:	8b4a                	mv	s6,s2
      state = 0;
 726:	4981                	li	s3,0
 728:	bf91                	j	67c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 72a:	008b0793          	addi	a5,s6,8
 72e:	f8f43423          	sd	a5,-120(s0)
 732:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 736:	03000593          	li	a1,48
 73a:	8556                	mv	a0,s5
 73c:	00000097          	auipc	ra,0x0
 740:	e14080e7          	jalr	-492(ra) # 550 <putc>
  putc(fd, 'x');
 744:	85ea                	mv	a1,s10
 746:	8556                	mv	a0,s5
 748:	00000097          	auipc	ra,0x0
 74c:	e08080e7          	jalr	-504(ra) # 550 <putc>
 750:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 752:	03c9d793          	srli	a5,s3,0x3c
 756:	97de                	add	a5,a5,s7
 758:	0007c583          	lbu	a1,0(a5)
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	df2080e7          	jalr	-526(ra) # 550 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 766:	0992                	slli	s3,s3,0x4
 768:	397d                	addiw	s2,s2,-1
 76a:	fe0914e3          	bnez	s2,752 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 76e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 772:	4981                	li	s3,0
 774:	b721                	j	67c <vprintf+0x60>
        s = va_arg(ap, char*);
 776:	008b0993          	addi	s3,s6,8
 77a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 77e:	02090163          	beqz	s2,7a0 <vprintf+0x184>
        while(*s != 0){
 782:	00094583          	lbu	a1,0(s2)
 786:	c9a1                	beqz	a1,7d6 <vprintf+0x1ba>
          putc(fd, *s);
 788:	8556                	mv	a0,s5
 78a:	00000097          	auipc	ra,0x0
 78e:	dc6080e7          	jalr	-570(ra) # 550 <putc>
          s++;
 792:	0905                	addi	s2,s2,1
        while(*s != 0){
 794:	00094583          	lbu	a1,0(s2)
 798:	f9e5                	bnez	a1,788 <vprintf+0x16c>
        s = va_arg(ap, char*);
 79a:	8b4e                	mv	s6,s3
      state = 0;
 79c:	4981                	li	s3,0
 79e:	bdf9                	j	67c <vprintf+0x60>
          s = "(null)";
 7a0:	00000917          	auipc	s2,0x0
 7a4:	32890913          	addi	s2,s2,808 # ac8 <malloc+0x1e2>
        while(*s != 0){
 7a8:	02800593          	li	a1,40
 7ac:	bff1                	j	788 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7ae:	008b0913          	addi	s2,s6,8
 7b2:	000b4583          	lbu	a1,0(s6)
 7b6:	8556                	mv	a0,s5
 7b8:	00000097          	auipc	ra,0x0
 7bc:	d98080e7          	jalr	-616(ra) # 550 <putc>
 7c0:	8b4a                	mv	s6,s2
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	bd65                	j	67c <vprintf+0x60>
        putc(fd, c);
 7c6:	85d2                	mv	a1,s4
 7c8:	8556                	mv	a0,s5
 7ca:	00000097          	auipc	ra,0x0
 7ce:	d86080e7          	jalr	-634(ra) # 550 <putc>
      state = 0;
 7d2:	4981                	li	s3,0
 7d4:	b565                	j	67c <vprintf+0x60>
        s = va_arg(ap, char*);
 7d6:	8b4e                	mv	s6,s3
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	b54d                	j	67c <vprintf+0x60>
    }
  }
}
 7dc:	70e6                	ld	ra,120(sp)
 7de:	7446                	ld	s0,112(sp)
 7e0:	74a6                	ld	s1,104(sp)
 7e2:	7906                	ld	s2,96(sp)
 7e4:	69e6                	ld	s3,88(sp)
 7e6:	6a46                	ld	s4,80(sp)
 7e8:	6aa6                	ld	s5,72(sp)
 7ea:	6b06                	ld	s6,64(sp)
 7ec:	7be2                	ld	s7,56(sp)
 7ee:	7c42                	ld	s8,48(sp)
 7f0:	7ca2                	ld	s9,40(sp)
 7f2:	7d02                	ld	s10,32(sp)
 7f4:	6de2                	ld	s11,24(sp)
 7f6:	6109                	addi	sp,sp,128
 7f8:	8082                	ret

00000000000007fa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7fa:	715d                	addi	sp,sp,-80
 7fc:	ec06                	sd	ra,24(sp)
 7fe:	e822                	sd	s0,16(sp)
 800:	1000                	addi	s0,sp,32
 802:	e010                	sd	a2,0(s0)
 804:	e414                	sd	a3,8(s0)
 806:	e818                	sd	a4,16(s0)
 808:	ec1c                	sd	a5,24(s0)
 80a:	03043023          	sd	a6,32(s0)
 80e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 812:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 816:	8622                	mv	a2,s0
 818:	00000097          	auipc	ra,0x0
 81c:	e04080e7          	jalr	-508(ra) # 61c <vprintf>
}
 820:	60e2                	ld	ra,24(sp)
 822:	6442                	ld	s0,16(sp)
 824:	6161                	addi	sp,sp,80
 826:	8082                	ret

0000000000000828 <printf>:

void
printf(const char *fmt, ...)
{
 828:	711d                	addi	sp,sp,-96
 82a:	ec06                	sd	ra,24(sp)
 82c:	e822                	sd	s0,16(sp)
 82e:	1000                	addi	s0,sp,32
 830:	e40c                	sd	a1,8(s0)
 832:	e810                	sd	a2,16(s0)
 834:	ec14                	sd	a3,24(s0)
 836:	f018                	sd	a4,32(s0)
 838:	f41c                	sd	a5,40(s0)
 83a:	03043823          	sd	a6,48(s0)
 83e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 842:	00840613          	addi	a2,s0,8
 846:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 84a:	85aa                	mv	a1,a0
 84c:	4505                	li	a0,1
 84e:	00000097          	auipc	ra,0x0
 852:	dce080e7          	jalr	-562(ra) # 61c <vprintf>
}
 856:	60e2                	ld	ra,24(sp)
 858:	6442                	ld	s0,16(sp)
 85a:	6125                	addi	sp,sp,96
 85c:	8082                	ret

000000000000085e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 85e:	1141                	addi	sp,sp,-16
 860:	e422                	sd	s0,8(sp)
 862:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 864:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 868:	00000797          	auipc	a5,0x0
 86c:	2807b783          	ld	a5,640(a5) # ae8 <freep>
 870:	a805                	j	8a0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 872:	4618                	lw	a4,8(a2)
 874:	9db9                	addw	a1,a1,a4
 876:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87a:	6398                	ld	a4,0(a5)
 87c:	6318                	ld	a4,0(a4)
 87e:	fee53823          	sd	a4,-16(a0)
 882:	a091                	j	8c6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 884:	ff852703          	lw	a4,-8(a0)
 888:	9e39                	addw	a2,a2,a4
 88a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 88c:	ff053703          	ld	a4,-16(a0)
 890:	e398                	sd	a4,0(a5)
 892:	a099                	j	8d8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 894:	6398                	ld	a4,0(a5)
 896:	00e7e463          	bltu	a5,a4,89e <free+0x40>
 89a:	00e6ea63          	bltu	a3,a4,8ae <free+0x50>
{
 89e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a0:	fed7fae3          	bgeu	a5,a3,894 <free+0x36>
 8a4:	6398                	ld	a4,0(a5)
 8a6:	00e6e463          	bltu	a3,a4,8ae <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8aa:	fee7eae3          	bltu	a5,a4,89e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8ae:	ff852583          	lw	a1,-8(a0)
 8b2:	6390                	ld	a2,0(a5)
 8b4:	02059713          	slli	a4,a1,0x20
 8b8:	9301                	srli	a4,a4,0x20
 8ba:	0712                	slli	a4,a4,0x4
 8bc:	9736                	add	a4,a4,a3
 8be:	fae60ae3          	beq	a2,a4,872 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8c2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c6:	4790                	lw	a2,8(a5)
 8c8:	02061713          	slli	a4,a2,0x20
 8cc:	9301                	srli	a4,a4,0x20
 8ce:	0712                	slli	a4,a4,0x4
 8d0:	973e                	add	a4,a4,a5
 8d2:	fae689e3          	beq	a3,a4,884 <free+0x26>
  } else
    p->s.ptr = bp;
 8d6:	e394                	sd	a3,0(a5)
  freep = p;
 8d8:	00000717          	auipc	a4,0x0
 8dc:	20f73823          	sd	a5,528(a4) # ae8 <freep>
}
 8e0:	6422                	ld	s0,8(sp)
 8e2:	0141                	addi	sp,sp,16
 8e4:	8082                	ret

00000000000008e6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e6:	7139                	addi	sp,sp,-64
 8e8:	fc06                	sd	ra,56(sp)
 8ea:	f822                	sd	s0,48(sp)
 8ec:	f426                	sd	s1,40(sp)
 8ee:	f04a                	sd	s2,32(sp)
 8f0:	ec4e                	sd	s3,24(sp)
 8f2:	e852                	sd	s4,16(sp)
 8f4:	e456                	sd	s5,8(sp)
 8f6:	e05a                	sd	s6,0(sp)
 8f8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8fa:	02051493          	slli	s1,a0,0x20
 8fe:	9081                	srli	s1,s1,0x20
 900:	04bd                	addi	s1,s1,15
 902:	8091                	srli	s1,s1,0x4
 904:	0014899b          	addiw	s3,s1,1
 908:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 90a:	00000517          	auipc	a0,0x0
 90e:	1de53503          	ld	a0,478(a0) # ae8 <freep>
 912:	c515                	beqz	a0,93e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 914:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 916:	4798                	lw	a4,8(a5)
 918:	02977f63          	bgeu	a4,s1,956 <malloc+0x70>
 91c:	8a4e                	mv	s4,s3
 91e:	0009871b          	sext.w	a4,s3
 922:	6685                	lui	a3,0x1
 924:	00d77363          	bgeu	a4,a3,92a <malloc+0x44>
 928:	6a05                	lui	s4,0x1
 92a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 932:	00000917          	auipc	s2,0x0
 936:	1b690913          	addi	s2,s2,438 # ae8 <freep>
  if(p == (char*)-1)
 93a:	5afd                	li	s5,-1
 93c:	a88d                	j	9ae <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 93e:	00000797          	auipc	a5,0x0
 942:	1b278793          	addi	a5,a5,434 # af0 <base>
 946:	00000717          	auipc	a4,0x0
 94a:	1af73123          	sd	a5,418(a4) # ae8 <freep>
 94e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 950:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 954:	b7e1                	j	91c <malloc+0x36>
      if(p->s.size == nunits)
 956:	02e48b63          	beq	s1,a4,98c <malloc+0xa6>
        p->s.size -= nunits;
 95a:	4137073b          	subw	a4,a4,s3
 95e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 960:	1702                	slli	a4,a4,0x20
 962:	9301                	srli	a4,a4,0x20
 964:	0712                	slli	a4,a4,0x4
 966:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 968:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 96c:	00000717          	auipc	a4,0x0
 970:	16a73e23          	sd	a0,380(a4) # ae8 <freep>
      return (void*)(p + 1);
 974:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 978:	70e2                	ld	ra,56(sp)
 97a:	7442                	ld	s0,48(sp)
 97c:	74a2                	ld	s1,40(sp)
 97e:	7902                	ld	s2,32(sp)
 980:	69e2                	ld	s3,24(sp)
 982:	6a42                	ld	s4,16(sp)
 984:	6aa2                	ld	s5,8(sp)
 986:	6b02                	ld	s6,0(sp)
 988:	6121                	addi	sp,sp,64
 98a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 98c:	6398                	ld	a4,0(a5)
 98e:	e118                	sd	a4,0(a0)
 990:	bff1                	j	96c <malloc+0x86>
  hp->s.size = nu;
 992:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 996:	0541                	addi	a0,a0,16
 998:	00000097          	auipc	ra,0x0
 99c:	ec6080e7          	jalr	-314(ra) # 85e <free>
  return freep;
 9a0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9a4:	d971                	beqz	a0,978 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a8:	4798                	lw	a4,8(a5)
 9aa:	fa9776e3          	bgeu	a4,s1,956 <malloc+0x70>
    if(p == freep)
 9ae:	00093703          	ld	a4,0(s2)
 9b2:	853e                	mv	a0,a5
 9b4:	fef719e3          	bne	a4,a5,9a6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9b8:	8552                	mv	a0,s4
 9ba:	00000097          	auipc	ra,0x0
 9be:	b1a080e7          	jalr	-1254(ra) # 4d4 <sbrk>
  if(p == (char*)-1)
 9c2:	fd5518e3          	bne	a0,s5,992 <malloc+0xac>
        return 0;
 9c6:	4501                	li	a0,0
 9c8:	bf45                	j	978 <malloc+0x92>
