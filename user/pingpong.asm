
user/_pingpong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
  int pipefd1[2], pipefd2[2], x;
  char y = '0';
   8:	03000793          	li	a5,48
   c:	fcf40fa3          	sb	a5,-33(s0)

  if (pipe(pipefd1) < 0) {
  10:	fe840513          	addi	a0,s0,-24
  14:	00000097          	auipc	ra,0x0
  18:	47c080e7          	jalr	1148(ra) # 490 <pipe>
  1c:	0a054863          	bltz	a0,cc <main+0xcc>
     fprintf(2, "Error: cannot create pipe\nAborting...\n");
     exit(0);
  }

  if (pipe(pipefd2) < 0) {
  20:	fe040513          	addi	a0,s0,-32
  24:	00000097          	auipc	ra,0x0
  28:	46c080e7          	jalr	1132(ra) # 490 <pipe>
  2c:	0a054e63          	bltz	a0,e8 <main+0xe8>
     fprintf(2, "Error: cannot create pipe\nAborting...\n");
     exit(0);
  }

  x = fork();
  30:	00000097          	auipc	ra,0x0
  34:	448080e7          	jalr	1096(ra) # 478 <fork>
  if (x < 0) {
  38:	0c054663          	bltz	a0,104 <main+0x104>
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  3c:	10a05e63          	blez	a0,158 <main+0x158>
     if (write(pipefd1[1], &y, 1) < 0) {
  40:	4605                	li	a2,1
  42:	fdf40593          	addi	a1,s0,-33
  46:	fec42503          	lw	a0,-20(s0)
  4a:	00000097          	auipc	ra,0x0
  4e:	456080e7          	jalr	1110(ra) # 4a0 <write>
  52:	0c054763          	bltz	a0,120 <main+0x120>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
	exit(0);
     }
     if (read(pipefd2[0], &y, 1) < 0) {
  56:	4605                	li	a2,1
  58:	fdf40593          	addi	a1,s0,-33
  5c:	fe042503          	lw	a0,-32(s0)
  60:	00000097          	auipc	ra,0x0
  64:	438080e7          	jalr	1080(ra) # 498 <read>
  68:	0c054a63          	bltz	a0,13c <main+0x13c>
        fprintf(2, "Error: cannot read from pipe\nAborting...\n");
        exit(0);
     }
     fprintf(1, "%d: received pong\n", getpid());
  6c:	00000097          	auipc	ra,0x0
  70:	494080e7          	jalr	1172(ra) # 500 <getpid>
  74:	862a                	mv	a2,a0
  76:	00001597          	auipc	a1,0x1
  7a:	a3258593          	addi	a1,a1,-1486 # aa8 <malloc+0x18e>
  7e:	4505                	li	a0,1
  80:	00000097          	auipc	ra,0x0
  84:	7ae080e7          	jalr	1966(ra) # 82e <fprintf>
     close(pipefd1[0]);
  88:	fe842503          	lw	a0,-24(s0)
  8c:	00000097          	auipc	ra,0x0
  90:	41c080e7          	jalr	1052(ra) # 4a8 <close>
     close(pipefd1[1]);
  94:	fec42503          	lw	a0,-20(s0)
  98:	00000097          	auipc	ra,0x0
  9c:	410080e7          	jalr	1040(ra) # 4a8 <close>
     close(pipefd2[0]);
  a0:	fe042503          	lw	a0,-32(s0)
  a4:	00000097          	auipc	ra,0x0
  a8:	404080e7          	jalr	1028(ra) # 4a8 <close>
     close(pipefd2[1]);
  ac:	fe442503          	lw	a0,-28(s0)
  b0:	00000097          	auipc	ra,0x0
  b4:	3f8080e7          	jalr	1016(ra) # 4a8 <close>
     wait(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	3ce080e7          	jalr	974(ra) # 488 <wait>
     close(pipefd1[1]);
     close(pipefd2[0]);
     close(pipefd2[1]);
  }

  exit(0);
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	3bc080e7          	jalr	956(ra) # 480 <exit>
     fprintf(2, "Error: cannot create pipe\nAborting...\n");
  cc:	00001597          	auipc	a1,0x1
  d0:	93458593          	addi	a1,a1,-1740 # a00 <malloc+0xe6>
  d4:	4509                	li	a0,2
  d6:	00000097          	auipc	ra,0x0
  da:	758080e7          	jalr	1880(ra) # 82e <fprintf>
     exit(0);
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	3a0080e7          	jalr	928(ra) # 480 <exit>
     fprintf(2, "Error: cannot create pipe\nAborting...\n");
  e8:	00001597          	auipc	a1,0x1
  ec:	91858593          	addi	a1,a1,-1768 # a00 <malloc+0xe6>
  f0:	4509                	li	a0,2
  f2:	00000097          	auipc	ra,0x0
  f6:	73c080e7          	jalr	1852(ra) # 82e <fprintf>
     exit(0);
  fa:	4501                	li	a0,0
  fc:	00000097          	auipc	ra,0x0
 100:	384080e7          	jalr	900(ra) # 480 <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
 104:	00001597          	auipc	a1,0x1
 108:	92458593          	addi	a1,a1,-1756 # a28 <malloc+0x10e>
 10c:	4509                	li	a0,2
 10e:	00000097          	auipc	ra,0x0
 112:	720080e7          	jalr	1824(ra) # 82e <fprintf>
     exit(0);
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	368080e7          	jalr	872(ra) # 480 <exit>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
 120:	00001597          	auipc	a1,0x1
 124:	92858593          	addi	a1,a1,-1752 # a48 <malloc+0x12e>
 128:	4509                	li	a0,2
 12a:	00000097          	auipc	ra,0x0
 12e:	704080e7          	jalr	1796(ra) # 82e <fprintf>
	exit(0);
 132:	4501                	li	a0,0
 134:	00000097          	auipc	ra,0x0
 138:	34c080e7          	jalr	844(ra) # 480 <exit>
        fprintf(2, "Error: cannot read from pipe\nAborting...\n");
 13c:	00001597          	auipc	a1,0x1
 140:	93c58593          	addi	a1,a1,-1732 # a78 <malloc+0x15e>
 144:	4509                	li	a0,2
 146:	00000097          	auipc	ra,0x0
 14a:	6e8080e7          	jalr	1768(ra) # 82e <fprintf>
        exit(0);
 14e:	4501                	li	a0,0
 150:	00000097          	auipc	ra,0x0
 154:	330080e7          	jalr	816(ra) # 480 <exit>
     if (read(pipefd1[0], &y, 1) < 0) {
 158:	4605                	li	a2,1
 15a:	fdf40593          	addi	a1,s0,-33
 15e:	fe842503          	lw	a0,-24(s0)
 162:	00000097          	auipc	ra,0x0
 166:	336080e7          	jalr	822(ra) # 498 <read>
 16a:	06054463          	bltz	a0,1d2 <main+0x1d2>
     fprintf(1, "%d: received ping\n", getpid());
 16e:	00000097          	auipc	ra,0x0
 172:	392080e7          	jalr	914(ra) # 500 <getpid>
 176:	862a                	mv	a2,a0
 178:	00001597          	auipc	a1,0x1
 17c:	94858593          	addi	a1,a1,-1720 # ac0 <malloc+0x1a6>
 180:	4505                	li	a0,1
 182:	00000097          	auipc	ra,0x0
 186:	6ac080e7          	jalr	1708(ra) # 82e <fprintf>
     if (write(pipefd2[1], &y, 1) < 0) {
 18a:	4605                	li	a2,1
 18c:	fdf40593          	addi	a1,s0,-33
 190:	fe442503          	lw	a0,-28(s0)
 194:	00000097          	auipc	ra,0x0
 198:	30c080e7          	jalr	780(ra) # 4a0 <write>
 19c:	04054963          	bltz	a0,1ee <main+0x1ee>
     close(pipefd1[0]);
 1a0:	fe842503          	lw	a0,-24(s0)
 1a4:	00000097          	auipc	ra,0x0
 1a8:	304080e7          	jalr	772(ra) # 4a8 <close>
     close(pipefd1[1]);
 1ac:	fec42503          	lw	a0,-20(s0)
 1b0:	00000097          	auipc	ra,0x0
 1b4:	2f8080e7          	jalr	760(ra) # 4a8 <close>
     close(pipefd2[0]);
 1b8:	fe042503          	lw	a0,-32(s0)
 1bc:	00000097          	auipc	ra,0x0
 1c0:	2ec080e7          	jalr	748(ra) # 4a8 <close>
     close(pipefd2[1]);
 1c4:	fe442503          	lw	a0,-28(s0)
 1c8:	00000097          	auipc	ra,0x0
 1cc:	2e0080e7          	jalr	736(ra) # 4a8 <close>
 1d0:	bdcd                	j	c2 <main+0xc2>
        fprintf(2, "Error: cannot read from pipe\nAborting...\n");
 1d2:	00001597          	auipc	a1,0x1
 1d6:	8a658593          	addi	a1,a1,-1882 # a78 <malloc+0x15e>
 1da:	4509                	li	a0,2
 1dc:	00000097          	auipc	ra,0x0
 1e0:	652080e7          	jalr	1618(ra) # 82e <fprintf>
        exit(0);
 1e4:	4501                	li	a0,0
 1e6:	00000097          	auipc	ra,0x0
 1ea:	29a080e7          	jalr	666(ra) # 480 <exit>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
 1ee:	00001597          	auipc	a1,0x1
 1f2:	85a58593          	addi	a1,a1,-1958 # a48 <malloc+0x12e>
 1f6:	4509                	li	a0,2
 1f8:	00000097          	auipc	ra,0x0
 1fc:	636080e7          	jalr	1590(ra) # 82e <fprintf>
        exit(0);
 200:	4501                	li	a0,0
 202:	00000097          	auipc	ra,0x0
 206:	27e080e7          	jalr	638(ra) # 480 <exit>

000000000000020a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 210:	87aa                	mv	a5,a0
 212:	0585                	addi	a1,a1,1
 214:	0785                	addi	a5,a5,1
 216:	fff5c703          	lbu	a4,-1(a1)
 21a:	fee78fa3          	sb	a4,-1(a5)
 21e:	fb75                	bnez	a4,212 <strcpy+0x8>
    ;
  return os;
}
 220:	6422                	ld	s0,8(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret

0000000000000226 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 226:	1141                	addi	sp,sp,-16
 228:	e422                	sd	s0,8(sp)
 22a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 22c:	00054783          	lbu	a5,0(a0)
 230:	cb91                	beqz	a5,244 <strcmp+0x1e>
 232:	0005c703          	lbu	a4,0(a1)
 236:	00f71763          	bne	a4,a5,244 <strcmp+0x1e>
    p++, q++;
 23a:	0505                	addi	a0,a0,1
 23c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 23e:	00054783          	lbu	a5,0(a0)
 242:	fbe5                	bnez	a5,232 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 244:	0005c503          	lbu	a0,0(a1)
}
 248:	40a7853b          	subw	a0,a5,a0
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret

0000000000000252 <strlen>:

uint
strlen(const char *s)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 258:	00054783          	lbu	a5,0(a0)
 25c:	cf91                	beqz	a5,278 <strlen+0x26>
 25e:	0505                	addi	a0,a0,1
 260:	87aa                	mv	a5,a0
 262:	4685                	li	a3,1
 264:	9e89                	subw	a3,a3,a0
 266:	00f6853b          	addw	a0,a3,a5
 26a:	0785                	addi	a5,a5,1
 26c:	fff7c703          	lbu	a4,-1(a5)
 270:	fb7d                	bnez	a4,266 <strlen+0x14>
    ;
  return n;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
  for(n = 0; s[n]; n++)
 278:	4501                	li	a0,0
 27a:	bfe5                	j	272 <strlen+0x20>

000000000000027c <memset>:

void*
memset(void *dst, int c, uint n)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 282:	ce09                	beqz	a2,29c <memset+0x20>
 284:	87aa                	mv	a5,a0
 286:	fff6071b          	addiw	a4,a2,-1
 28a:	1702                	slli	a4,a4,0x20
 28c:	9301                	srli	a4,a4,0x20
 28e:	0705                	addi	a4,a4,1
 290:	972a                	add	a4,a4,a0
    cdst[i] = c;
 292:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 296:	0785                	addi	a5,a5,1
 298:	fee79de3          	bne	a5,a4,292 <memset+0x16>
  }
  return dst;
}
 29c:	6422                	ld	s0,8(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret

00000000000002a2 <strchr>:

char*
strchr(const char *s, char c)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2a8:	00054783          	lbu	a5,0(a0)
 2ac:	cb99                	beqz	a5,2c2 <strchr+0x20>
    if(*s == c)
 2ae:	00f58763          	beq	a1,a5,2bc <strchr+0x1a>
  for(; *s; s++)
 2b2:	0505                	addi	a0,a0,1
 2b4:	00054783          	lbu	a5,0(a0)
 2b8:	fbfd                	bnez	a5,2ae <strchr+0xc>
      return (char*)s;
  return 0;
 2ba:	4501                	li	a0,0
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
  return 0;
 2c2:	4501                	li	a0,0
 2c4:	bfe5                	j	2bc <strchr+0x1a>

00000000000002c6 <gets>:

char*
gets(char *buf, int max)
{
 2c6:	711d                	addi	sp,sp,-96
 2c8:	ec86                	sd	ra,88(sp)
 2ca:	e8a2                	sd	s0,80(sp)
 2cc:	e4a6                	sd	s1,72(sp)
 2ce:	e0ca                	sd	s2,64(sp)
 2d0:	fc4e                	sd	s3,56(sp)
 2d2:	f852                	sd	s4,48(sp)
 2d4:	f456                	sd	s5,40(sp)
 2d6:	f05a                	sd	s6,32(sp)
 2d8:	ec5e                	sd	s7,24(sp)
 2da:	1080                	addi	s0,sp,96
 2dc:	8baa                	mv	s7,a0
 2de:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e0:	892a                	mv	s2,a0
 2e2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2e4:	4aa9                	li	s5,10
 2e6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2e8:	89a6                	mv	s3,s1
 2ea:	2485                	addiw	s1,s1,1
 2ec:	0344d863          	bge	s1,s4,31c <gets+0x56>
    cc = read(0, &c, 1);
 2f0:	4605                	li	a2,1
 2f2:	faf40593          	addi	a1,s0,-81
 2f6:	4501                	li	a0,0
 2f8:	00000097          	auipc	ra,0x0
 2fc:	1a0080e7          	jalr	416(ra) # 498 <read>
    if(cc < 1)
 300:	00a05e63          	blez	a0,31c <gets+0x56>
    buf[i++] = c;
 304:	faf44783          	lbu	a5,-81(s0)
 308:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 30c:	01578763          	beq	a5,s5,31a <gets+0x54>
 310:	0905                	addi	s2,s2,1
 312:	fd679be3          	bne	a5,s6,2e8 <gets+0x22>
  for(i=0; i+1 < max; ){
 316:	89a6                	mv	s3,s1
 318:	a011                	j	31c <gets+0x56>
 31a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 31c:	99de                	add	s3,s3,s7
 31e:	00098023          	sb	zero,0(s3)
  return buf;
}
 322:	855e                	mv	a0,s7
 324:	60e6                	ld	ra,88(sp)
 326:	6446                	ld	s0,80(sp)
 328:	64a6                	ld	s1,72(sp)
 32a:	6906                	ld	s2,64(sp)
 32c:	79e2                	ld	s3,56(sp)
 32e:	7a42                	ld	s4,48(sp)
 330:	7aa2                	ld	s5,40(sp)
 332:	7b02                	ld	s6,32(sp)
 334:	6be2                	ld	s7,24(sp)
 336:	6125                	addi	sp,sp,96
 338:	8082                	ret

000000000000033a <stat>:

int
stat(const char *n, struct stat *st)
{
 33a:	1101                	addi	sp,sp,-32
 33c:	ec06                	sd	ra,24(sp)
 33e:	e822                	sd	s0,16(sp)
 340:	e426                	sd	s1,8(sp)
 342:	e04a                	sd	s2,0(sp)
 344:	1000                	addi	s0,sp,32
 346:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 348:	4581                	li	a1,0
 34a:	00000097          	auipc	ra,0x0
 34e:	176080e7          	jalr	374(ra) # 4c0 <open>
  if(fd < 0)
 352:	02054563          	bltz	a0,37c <stat+0x42>
 356:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 358:	85ca                	mv	a1,s2
 35a:	00000097          	auipc	ra,0x0
 35e:	17e080e7          	jalr	382(ra) # 4d8 <fstat>
 362:	892a                	mv	s2,a0
  close(fd);
 364:	8526                	mv	a0,s1
 366:	00000097          	auipc	ra,0x0
 36a:	142080e7          	jalr	322(ra) # 4a8 <close>
  return r;
}
 36e:	854a                	mv	a0,s2
 370:	60e2                	ld	ra,24(sp)
 372:	6442                	ld	s0,16(sp)
 374:	64a2                	ld	s1,8(sp)
 376:	6902                	ld	s2,0(sp)
 378:	6105                	addi	sp,sp,32
 37a:	8082                	ret
    return -1;
 37c:	597d                	li	s2,-1
 37e:	bfc5                	j	36e <stat+0x34>

0000000000000380 <atoi>:

int
atoi(const char *s)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 386:	00054603          	lbu	a2,0(a0)
 38a:	fd06079b          	addiw	a5,a2,-48
 38e:	0ff7f793          	andi	a5,a5,255
 392:	4725                	li	a4,9
 394:	02f76963          	bltu	a4,a5,3c6 <atoi+0x46>
 398:	86aa                	mv	a3,a0
  n = 0;
 39a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 39c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 39e:	0685                	addi	a3,a3,1
 3a0:	0025179b          	slliw	a5,a0,0x2
 3a4:	9fa9                	addw	a5,a5,a0
 3a6:	0017979b          	slliw	a5,a5,0x1
 3aa:	9fb1                	addw	a5,a5,a2
 3ac:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3b0:	0006c603          	lbu	a2,0(a3)
 3b4:	fd06071b          	addiw	a4,a2,-48
 3b8:	0ff77713          	andi	a4,a4,255
 3bc:	fee5f1e3          	bgeu	a1,a4,39e <atoi+0x1e>
  return n;
}
 3c0:	6422                	ld	s0,8(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret
  n = 0;
 3c6:	4501                	li	a0,0
 3c8:	bfe5                	j	3c0 <atoi+0x40>

00000000000003ca <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3ca:	1141                	addi	sp,sp,-16
 3cc:	e422                	sd	s0,8(sp)
 3ce:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3d0:	02b57663          	bgeu	a0,a1,3fc <memmove+0x32>
    while(n-- > 0)
 3d4:	02c05163          	blez	a2,3f6 <memmove+0x2c>
 3d8:	fff6079b          	addiw	a5,a2,-1
 3dc:	1782                	slli	a5,a5,0x20
 3de:	9381                	srli	a5,a5,0x20
 3e0:	0785                	addi	a5,a5,1
 3e2:	97aa                	add	a5,a5,a0
  dst = vdst;
 3e4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3e6:	0585                	addi	a1,a1,1
 3e8:	0705                	addi	a4,a4,1
 3ea:	fff5c683          	lbu	a3,-1(a1)
 3ee:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3f2:	fee79ae3          	bne	a5,a4,3e6 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3f6:	6422                	ld	s0,8(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret
    dst += n;
 3fc:	00c50733          	add	a4,a0,a2
    src += n;
 400:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 402:	fec05ae3          	blez	a2,3f6 <memmove+0x2c>
 406:	fff6079b          	addiw	a5,a2,-1
 40a:	1782                	slli	a5,a5,0x20
 40c:	9381                	srli	a5,a5,0x20
 40e:	fff7c793          	not	a5,a5
 412:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 414:	15fd                	addi	a1,a1,-1
 416:	177d                	addi	a4,a4,-1
 418:	0005c683          	lbu	a3,0(a1)
 41c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 420:	fee79ae3          	bne	a5,a4,414 <memmove+0x4a>
 424:	bfc9                	j	3f6 <memmove+0x2c>

0000000000000426 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 42c:	ca05                	beqz	a2,45c <memcmp+0x36>
 42e:	fff6069b          	addiw	a3,a2,-1
 432:	1682                	slli	a3,a3,0x20
 434:	9281                	srli	a3,a3,0x20
 436:	0685                	addi	a3,a3,1
 438:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 43a:	00054783          	lbu	a5,0(a0)
 43e:	0005c703          	lbu	a4,0(a1)
 442:	00e79863          	bne	a5,a4,452 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 446:	0505                	addi	a0,a0,1
    p2++;
 448:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 44a:	fed518e3          	bne	a0,a3,43a <memcmp+0x14>
  }
  return 0;
 44e:	4501                	li	a0,0
 450:	a019                	j	456 <memcmp+0x30>
      return *p1 - *p2;
 452:	40e7853b          	subw	a0,a5,a4
}
 456:	6422                	ld	s0,8(sp)
 458:	0141                	addi	sp,sp,16
 45a:	8082                	ret
  return 0;
 45c:	4501                	li	a0,0
 45e:	bfe5                	j	456 <memcmp+0x30>

0000000000000460 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 460:	1141                	addi	sp,sp,-16
 462:	e406                	sd	ra,8(sp)
 464:	e022                	sd	s0,0(sp)
 466:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 468:	00000097          	auipc	ra,0x0
 46c:	f62080e7          	jalr	-158(ra) # 3ca <memmove>
}
 470:	60a2                	ld	ra,8(sp)
 472:	6402                	ld	s0,0(sp)
 474:	0141                	addi	sp,sp,16
 476:	8082                	ret

0000000000000478 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 478:	4885                	li	a7,1
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <exit>:
.global exit
exit:
 li a7, SYS_exit
 480:	4889                	li	a7,2
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <wait>:
.global wait
wait:
 li a7, SYS_wait
 488:	488d                	li	a7,3
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 490:	4891                	li	a7,4
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <read>:
.global read
read:
 li a7, SYS_read
 498:	4895                	li	a7,5
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <write>:
.global write
write:
 li a7, SYS_write
 4a0:	48c1                	li	a7,16
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <close>:
.global close
close:
 li a7, SYS_close
 4a8:	48d5                	li	a7,21
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4b0:	4899                	li	a7,6
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4b8:	489d                	li	a7,7
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <open>:
.global open
open:
 li a7, SYS_open
 4c0:	48bd                	li	a7,15
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4c8:	48c5                	li	a7,17
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4d0:	48c9                	li	a7,18
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4d8:	48a1                	li	a7,8
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <link>:
.global link
link:
 li a7, SYS_link
 4e0:	48cd                	li	a7,19
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4e8:	48d1                	li	a7,20
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4f0:	48a5                	li	a7,9
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4f8:	48a9                	li	a7,10
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 500:	48ad                	li	a7,11
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 508:	48b1                	li	a7,12
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 510:	48b5                	li	a7,13
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 518:	48b9                	li	a7,14
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 520:	48d9                	li	a7,22
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <yield>:
.global yield
yield:
 li a7, SYS_yield
 528:	48dd                	li	a7,23
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 530:	48e1                	li	a7,24
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 538:	48e5                	li	a7,25
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 540:	48e9                	li	a7,26
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <ps>:
.global ps
ps:
 li a7, SYS_ps
 548:	48ed                	li	a7,27
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 550:	48f1                	li	a7,28
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 558:	48f5                	li	a7,29
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 560:	48f9                	li	a7,30
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 568:	48fd                	li	a7,31
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 570:	02000893          	li	a7,32
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 57a:	02100893          	li	a7,33
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 584:	1101                	addi	sp,sp,-32
 586:	ec06                	sd	ra,24(sp)
 588:	e822                	sd	s0,16(sp)
 58a:	1000                	addi	s0,sp,32
 58c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 590:	4605                	li	a2,1
 592:	fef40593          	addi	a1,s0,-17
 596:	00000097          	auipc	ra,0x0
 59a:	f0a080e7          	jalr	-246(ra) # 4a0 <write>
}
 59e:	60e2                	ld	ra,24(sp)
 5a0:	6442                	ld	s0,16(sp)
 5a2:	6105                	addi	sp,sp,32
 5a4:	8082                	ret

00000000000005a6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a6:	7139                	addi	sp,sp,-64
 5a8:	fc06                	sd	ra,56(sp)
 5aa:	f822                	sd	s0,48(sp)
 5ac:	f426                	sd	s1,40(sp)
 5ae:	f04a                	sd	s2,32(sp)
 5b0:	ec4e                	sd	s3,24(sp)
 5b2:	0080                	addi	s0,sp,64
 5b4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5b6:	c299                	beqz	a3,5bc <printint+0x16>
 5b8:	0805c863          	bltz	a1,648 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5bc:	2581                	sext.w	a1,a1
  neg = 0;
 5be:	4881                	li	a7,0
 5c0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5c4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5c6:	2601                	sext.w	a2,a2
 5c8:	00000517          	auipc	a0,0x0
 5cc:	51850513          	addi	a0,a0,1304 # ae0 <digits>
 5d0:	883a                	mv	a6,a4
 5d2:	2705                	addiw	a4,a4,1
 5d4:	02c5f7bb          	remuw	a5,a1,a2
 5d8:	1782                	slli	a5,a5,0x20
 5da:	9381                	srli	a5,a5,0x20
 5dc:	97aa                	add	a5,a5,a0
 5de:	0007c783          	lbu	a5,0(a5)
 5e2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5e6:	0005879b          	sext.w	a5,a1
 5ea:	02c5d5bb          	divuw	a1,a1,a2
 5ee:	0685                	addi	a3,a3,1
 5f0:	fec7f0e3          	bgeu	a5,a2,5d0 <printint+0x2a>
  if(neg)
 5f4:	00088b63          	beqz	a7,60a <printint+0x64>
    buf[i++] = '-';
 5f8:	fd040793          	addi	a5,s0,-48
 5fc:	973e                	add	a4,a4,a5
 5fe:	02d00793          	li	a5,45
 602:	fef70823          	sb	a5,-16(a4)
 606:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 60a:	02e05863          	blez	a4,63a <printint+0x94>
 60e:	fc040793          	addi	a5,s0,-64
 612:	00e78933          	add	s2,a5,a4
 616:	fff78993          	addi	s3,a5,-1
 61a:	99ba                	add	s3,s3,a4
 61c:	377d                	addiw	a4,a4,-1
 61e:	1702                	slli	a4,a4,0x20
 620:	9301                	srli	a4,a4,0x20
 622:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 626:	fff94583          	lbu	a1,-1(s2)
 62a:	8526                	mv	a0,s1
 62c:	00000097          	auipc	ra,0x0
 630:	f58080e7          	jalr	-168(ra) # 584 <putc>
  while(--i >= 0)
 634:	197d                	addi	s2,s2,-1
 636:	ff3918e3          	bne	s2,s3,626 <printint+0x80>
}
 63a:	70e2                	ld	ra,56(sp)
 63c:	7442                	ld	s0,48(sp)
 63e:	74a2                	ld	s1,40(sp)
 640:	7902                	ld	s2,32(sp)
 642:	69e2                	ld	s3,24(sp)
 644:	6121                	addi	sp,sp,64
 646:	8082                	ret
    x = -xx;
 648:	40b005bb          	negw	a1,a1
    neg = 1;
 64c:	4885                	li	a7,1
    x = -xx;
 64e:	bf8d                	j	5c0 <printint+0x1a>

0000000000000650 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 650:	7119                	addi	sp,sp,-128
 652:	fc86                	sd	ra,120(sp)
 654:	f8a2                	sd	s0,112(sp)
 656:	f4a6                	sd	s1,104(sp)
 658:	f0ca                	sd	s2,96(sp)
 65a:	ecce                	sd	s3,88(sp)
 65c:	e8d2                	sd	s4,80(sp)
 65e:	e4d6                	sd	s5,72(sp)
 660:	e0da                	sd	s6,64(sp)
 662:	fc5e                	sd	s7,56(sp)
 664:	f862                	sd	s8,48(sp)
 666:	f466                	sd	s9,40(sp)
 668:	f06a                	sd	s10,32(sp)
 66a:	ec6e                	sd	s11,24(sp)
 66c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 66e:	0005c903          	lbu	s2,0(a1)
 672:	18090f63          	beqz	s2,810 <vprintf+0x1c0>
 676:	8aaa                	mv	s5,a0
 678:	8b32                	mv	s6,a2
 67a:	00158493          	addi	s1,a1,1
  state = 0;
 67e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 680:	02500a13          	li	s4,37
      if(c == 'd'){
 684:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 688:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 68c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 690:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 694:	00000b97          	auipc	s7,0x0
 698:	44cb8b93          	addi	s7,s7,1100 # ae0 <digits>
 69c:	a839                	j	6ba <vprintf+0x6a>
        putc(fd, c);
 69e:	85ca                	mv	a1,s2
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	ee2080e7          	jalr	-286(ra) # 584 <putc>
 6aa:	a019                	j	6b0 <vprintf+0x60>
    } else if(state == '%'){
 6ac:	01498f63          	beq	s3,s4,6ca <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6b0:	0485                	addi	s1,s1,1
 6b2:	fff4c903          	lbu	s2,-1(s1)
 6b6:	14090d63          	beqz	s2,810 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 6ba:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6be:	fe0997e3          	bnez	s3,6ac <vprintf+0x5c>
      if(c == '%'){
 6c2:	fd479ee3          	bne	a5,s4,69e <vprintf+0x4e>
        state = '%';
 6c6:	89be                	mv	s3,a5
 6c8:	b7e5                	j	6b0 <vprintf+0x60>
      if(c == 'd'){
 6ca:	05878063          	beq	a5,s8,70a <vprintf+0xba>
      } else if(c == 'l') {
 6ce:	05978c63          	beq	a5,s9,726 <vprintf+0xd6>
      } else if(c == 'x') {
 6d2:	07a78863          	beq	a5,s10,742 <vprintf+0xf2>
      } else if(c == 'p') {
 6d6:	09b78463          	beq	a5,s11,75e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6da:	07300713          	li	a4,115
 6de:	0ce78663          	beq	a5,a4,7aa <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6e2:	06300713          	li	a4,99
 6e6:	0ee78e63          	beq	a5,a4,7e2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6ea:	11478863          	beq	a5,s4,7fa <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ee:	85d2                	mv	a1,s4
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e92080e7          	jalr	-366(ra) # 584 <putc>
        putc(fd, c);
 6fa:	85ca                	mv	a1,s2
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	e86080e7          	jalr	-378(ra) # 584 <putc>
      }
      state = 0;
 706:	4981                	li	s3,0
 708:	b765                	j	6b0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 70a:	008b0913          	addi	s2,s6,8
 70e:	4685                	li	a3,1
 710:	4629                	li	a2,10
 712:	000b2583          	lw	a1,0(s6)
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	e8e080e7          	jalr	-370(ra) # 5a6 <printint>
 720:	8b4a                	mv	s6,s2
      state = 0;
 722:	4981                	li	s3,0
 724:	b771                	j	6b0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 726:	008b0913          	addi	s2,s6,8
 72a:	4681                	li	a3,0
 72c:	4629                	li	a2,10
 72e:	000b2583          	lw	a1,0(s6)
 732:	8556                	mv	a0,s5
 734:	00000097          	auipc	ra,0x0
 738:	e72080e7          	jalr	-398(ra) # 5a6 <printint>
 73c:	8b4a                	mv	s6,s2
      state = 0;
 73e:	4981                	li	s3,0
 740:	bf85                	j	6b0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 742:	008b0913          	addi	s2,s6,8
 746:	4681                	li	a3,0
 748:	4641                	li	a2,16
 74a:	000b2583          	lw	a1,0(s6)
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	e56080e7          	jalr	-426(ra) # 5a6 <printint>
 758:	8b4a                	mv	s6,s2
      state = 0;
 75a:	4981                	li	s3,0
 75c:	bf91                	j	6b0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 75e:	008b0793          	addi	a5,s6,8
 762:	f8f43423          	sd	a5,-120(s0)
 766:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 76a:	03000593          	li	a1,48
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	e14080e7          	jalr	-492(ra) # 584 <putc>
  putc(fd, 'x');
 778:	85ea                	mv	a1,s10
 77a:	8556                	mv	a0,s5
 77c:	00000097          	auipc	ra,0x0
 780:	e08080e7          	jalr	-504(ra) # 584 <putc>
 784:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 786:	03c9d793          	srli	a5,s3,0x3c
 78a:	97de                	add	a5,a5,s7
 78c:	0007c583          	lbu	a1,0(a5)
 790:	8556                	mv	a0,s5
 792:	00000097          	auipc	ra,0x0
 796:	df2080e7          	jalr	-526(ra) # 584 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 79a:	0992                	slli	s3,s3,0x4
 79c:	397d                	addiw	s2,s2,-1
 79e:	fe0914e3          	bnez	s2,786 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 7a2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	b721                	j	6b0 <vprintf+0x60>
        s = va_arg(ap, char*);
 7aa:	008b0993          	addi	s3,s6,8
 7ae:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7b2:	02090163          	beqz	s2,7d4 <vprintf+0x184>
        while(*s != 0){
 7b6:	00094583          	lbu	a1,0(s2)
 7ba:	c9a1                	beqz	a1,80a <vprintf+0x1ba>
          putc(fd, *s);
 7bc:	8556                	mv	a0,s5
 7be:	00000097          	auipc	ra,0x0
 7c2:	dc6080e7          	jalr	-570(ra) # 584 <putc>
          s++;
 7c6:	0905                	addi	s2,s2,1
        while(*s != 0){
 7c8:	00094583          	lbu	a1,0(s2)
 7cc:	f9e5                	bnez	a1,7bc <vprintf+0x16c>
        s = va_arg(ap, char*);
 7ce:	8b4e                	mv	s6,s3
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	bdf9                	j	6b0 <vprintf+0x60>
          s = "(null)";
 7d4:	00000917          	auipc	s2,0x0
 7d8:	30490913          	addi	s2,s2,772 # ad8 <malloc+0x1be>
        while(*s != 0){
 7dc:	02800593          	li	a1,40
 7e0:	bff1                	j	7bc <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7e2:	008b0913          	addi	s2,s6,8
 7e6:	000b4583          	lbu	a1,0(s6)
 7ea:	8556                	mv	a0,s5
 7ec:	00000097          	auipc	ra,0x0
 7f0:	d98080e7          	jalr	-616(ra) # 584 <putc>
 7f4:	8b4a                	mv	s6,s2
      state = 0;
 7f6:	4981                	li	s3,0
 7f8:	bd65                	j	6b0 <vprintf+0x60>
        putc(fd, c);
 7fa:	85d2                	mv	a1,s4
 7fc:	8556                	mv	a0,s5
 7fe:	00000097          	auipc	ra,0x0
 802:	d86080e7          	jalr	-634(ra) # 584 <putc>
      state = 0;
 806:	4981                	li	s3,0
 808:	b565                	j	6b0 <vprintf+0x60>
        s = va_arg(ap, char*);
 80a:	8b4e                	mv	s6,s3
      state = 0;
 80c:	4981                	li	s3,0
 80e:	b54d                	j	6b0 <vprintf+0x60>
    }
  }
}
 810:	70e6                	ld	ra,120(sp)
 812:	7446                	ld	s0,112(sp)
 814:	74a6                	ld	s1,104(sp)
 816:	7906                	ld	s2,96(sp)
 818:	69e6                	ld	s3,88(sp)
 81a:	6a46                	ld	s4,80(sp)
 81c:	6aa6                	ld	s5,72(sp)
 81e:	6b06                	ld	s6,64(sp)
 820:	7be2                	ld	s7,56(sp)
 822:	7c42                	ld	s8,48(sp)
 824:	7ca2                	ld	s9,40(sp)
 826:	7d02                	ld	s10,32(sp)
 828:	6de2                	ld	s11,24(sp)
 82a:	6109                	addi	sp,sp,128
 82c:	8082                	ret

000000000000082e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 82e:	715d                	addi	sp,sp,-80
 830:	ec06                	sd	ra,24(sp)
 832:	e822                	sd	s0,16(sp)
 834:	1000                	addi	s0,sp,32
 836:	e010                	sd	a2,0(s0)
 838:	e414                	sd	a3,8(s0)
 83a:	e818                	sd	a4,16(s0)
 83c:	ec1c                	sd	a5,24(s0)
 83e:	03043023          	sd	a6,32(s0)
 842:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 846:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 84a:	8622                	mv	a2,s0
 84c:	00000097          	auipc	ra,0x0
 850:	e04080e7          	jalr	-508(ra) # 650 <vprintf>
}
 854:	60e2                	ld	ra,24(sp)
 856:	6442                	ld	s0,16(sp)
 858:	6161                	addi	sp,sp,80
 85a:	8082                	ret

000000000000085c <printf>:

void
printf(const char *fmt, ...)
{
 85c:	711d                	addi	sp,sp,-96
 85e:	ec06                	sd	ra,24(sp)
 860:	e822                	sd	s0,16(sp)
 862:	1000                	addi	s0,sp,32
 864:	e40c                	sd	a1,8(s0)
 866:	e810                	sd	a2,16(s0)
 868:	ec14                	sd	a3,24(s0)
 86a:	f018                	sd	a4,32(s0)
 86c:	f41c                	sd	a5,40(s0)
 86e:	03043823          	sd	a6,48(s0)
 872:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 876:	00840613          	addi	a2,s0,8
 87a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 87e:	85aa                	mv	a1,a0
 880:	4505                	li	a0,1
 882:	00000097          	auipc	ra,0x0
 886:	dce080e7          	jalr	-562(ra) # 650 <vprintf>
}
 88a:	60e2                	ld	ra,24(sp)
 88c:	6442                	ld	s0,16(sp)
 88e:	6125                	addi	sp,sp,96
 890:	8082                	ret

0000000000000892 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 892:	1141                	addi	sp,sp,-16
 894:	e422                	sd	s0,8(sp)
 896:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 898:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89c:	00000797          	auipc	a5,0x0
 8a0:	25c7b783          	ld	a5,604(a5) # af8 <freep>
 8a4:	a805                	j	8d4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8a6:	4618                	lw	a4,8(a2)
 8a8:	9db9                	addw	a1,a1,a4
 8aa:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ae:	6398                	ld	a4,0(a5)
 8b0:	6318                	ld	a4,0(a4)
 8b2:	fee53823          	sd	a4,-16(a0)
 8b6:	a091                	j	8fa <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8b8:	ff852703          	lw	a4,-8(a0)
 8bc:	9e39                	addw	a2,a2,a4
 8be:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8c0:	ff053703          	ld	a4,-16(a0)
 8c4:	e398                	sd	a4,0(a5)
 8c6:	a099                	j	90c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c8:	6398                	ld	a4,0(a5)
 8ca:	00e7e463          	bltu	a5,a4,8d2 <free+0x40>
 8ce:	00e6ea63          	bltu	a3,a4,8e2 <free+0x50>
{
 8d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d4:	fed7fae3          	bgeu	a5,a3,8c8 <free+0x36>
 8d8:	6398                	ld	a4,0(a5)
 8da:	00e6e463          	bltu	a3,a4,8e2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8de:	fee7eae3          	bltu	a5,a4,8d2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8e2:	ff852583          	lw	a1,-8(a0)
 8e6:	6390                	ld	a2,0(a5)
 8e8:	02059713          	slli	a4,a1,0x20
 8ec:	9301                	srli	a4,a4,0x20
 8ee:	0712                	slli	a4,a4,0x4
 8f0:	9736                	add	a4,a4,a3
 8f2:	fae60ae3          	beq	a2,a4,8a6 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8f6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8fa:	4790                	lw	a2,8(a5)
 8fc:	02061713          	slli	a4,a2,0x20
 900:	9301                	srli	a4,a4,0x20
 902:	0712                	slli	a4,a4,0x4
 904:	973e                	add	a4,a4,a5
 906:	fae689e3          	beq	a3,a4,8b8 <free+0x26>
  } else
    p->s.ptr = bp;
 90a:	e394                	sd	a3,0(a5)
  freep = p;
 90c:	00000717          	auipc	a4,0x0
 910:	1ef73623          	sd	a5,492(a4) # af8 <freep>
}
 914:	6422                	ld	s0,8(sp)
 916:	0141                	addi	sp,sp,16
 918:	8082                	ret

000000000000091a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 91a:	7139                	addi	sp,sp,-64
 91c:	fc06                	sd	ra,56(sp)
 91e:	f822                	sd	s0,48(sp)
 920:	f426                	sd	s1,40(sp)
 922:	f04a                	sd	s2,32(sp)
 924:	ec4e                	sd	s3,24(sp)
 926:	e852                	sd	s4,16(sp)
 928:	e456                	sd	s5,8(sp)
 92a:	e05a                	sd	s6,0(sp)
 92c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 92e:	02051493          	slli	s1,a0,0x20
 932:	9081                	srli	s1,s1,0x20
 934:	04bd                	addi	s1,s1,15
 936:	8091                	srli	s1,s1,0x4
 938:	0014899b          	addiw	s3,s1,1
 93c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 93e:	00000517          	auipc	a0,0x0
 942:	1ba53503          	ld	a0,442(a0) # af8 <freep>
 946:	c515                	beqz	a0,972 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 948:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 94a:	4798                	lw	a4,8(a5)
 94c:	02977f63          	bgeu	a4,s1,98a <malloc+0x70>
 950:	8a4e                	mv	s4,s3
 952:	0009871b          	sext.w	a4,s3
 956:	6685                	lui	a3,0x1
 958:	00d77363          	bgeu	a4,a3,95e <malloc+0x44>
 95c:	6a05                	lui	s4,0x1
 95e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 962:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 966:	00000917          	auipc	s2,0x0
 96a:	19290913          	addi	s2,s2,402 # af8 <freep>
  if(p == (char*)-1)
 96e:	5afd                	li	s5,-1
 970:	a88d                	j	9e2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 972:	00000797          	auipc	a5,0x0
 976:	18e78793          	addi	a5,a5,398 # b00 <base>
 97a:	00000717          	auipc	a4,0x0
 97e:	16f73f23          	sd	a5,382(a4) # af8 <freep>
 982:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 984:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 988:	b7e1                	j	950 <malloc+0x36>
      if(p->s.size == nunits)
 98a:	02e48b63          	beq	s1,a4,9c0 <malloc+0xa6>
        p->s.size -= nunits;
 98e:	4137073b          	subw	a4,a4,s3
 992:	c798                	sw	a4,8(a5)
        p += p->s.size;
 994:	1702                	slli	a4,a4,0x20
 996:	9301                	srli	a4,a4,0x20
 998:	0712                	slli	a4,a4,0x4
 99a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 99c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9a0:	00000717          	auipc	a4,0x0
 9a4:	14a73c23          	sd	a0,344(a4) # af8 <freep>
      return (void*)(p + 1);
 9a8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9ac:	70e2                	ld	ra,56(sp)
 9ae:	7442                	ld	s0,48(sp)
 9b0:	74a2                	ld	s1,40(sp)
 9b2:	7902                	ld	s2,32(sp)
 9b4:	69e2                	ld	s3,24(sp)
 9b6:	6a42                	ld	s4,16(sp)
 9b8:	6aa2                	ld	s5,8(sp)
 9ba:	6b02                	ld	s6,0(sp)
 9bc:	6121                	addi	sp,sp,64
 9be:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9c0:	6398                	ld	a4,0(a5)
 9c2:	e118                	sd	a4,0(a0)
 9c4:	bff1                	j	9a0 <malloc+0x86>
  hp->s.size = nu;
 9c6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9ca:	0541                	addi	a0,a0,16
 9cc:	00000097          	auipc	ra,0x0
 9d0:	ec6080e7          	jalr	-314(ra) # 892 <free>
  return freep;
 9d4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9d8:	d971                	beqz	a0,9ac <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9dc:	4798                	lw	a4,8(a5)
 9de:	fa9776e3          	bgeu	a4,s1,98a <malloc+0x70>
    if(p == freep)
 9e2:	00093703          	ld	a4,0(s2)
 9e6:	853e                	mv	a0,a5
 9e8:	fef719e3          	bne	a4,a5,9da <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9ec:	8552                	mv	a0,s4
 9ee:	00000097          	auipc	ra,0x0
 9f2:	b1a080e7          	jalr	-1254(ra) # 508 <sbrk>
  if(p == (char*)-1)
 9f6:	fd5518e3          	bne	a0,s5,9c6 <malloc+0xac>
        return 0;
 9fa:	4501                	li	a0,0
 9fc:	bf45                	j	9ac <malloc+0x92>
