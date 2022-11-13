
user/_primefactors:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

int primes[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};

int
main(int argc, char *argv[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	0080                	addi	s0,sp,64
  int pipefd[2], x, y, n, i=0;

  if (argc != 2) {
  10:	4789                	li	a5,2
  12:	02f50063          	beq	a0,a5,32 <main+0x32>
     fprintf(2, "syntax: factors n\nAborting...\n");
  16:	00001597          	auipc	a1,0x1
  1a:	9aa58593          	addi	a1,a1,-1622 # 9c0 <malloc+0xe8>
  1e:	4509                	li	a0,2
  20:	00000097          	auipc	ra,0x0
  24:	7cc080e7          	jalr	1996(ra) # 7ec <fprintf>
     exit(0);
  28:	4501                	li	a0,0
  2a:	00000097          	auipc	ra,0x0
  2e:	414080e7          	jalr	1044(ra) # 43e <exit>
  }
  n = atoi(argv[1]);
  32:	6588                	ld	a0,8(a1)
  34:	00000097          	auipc	ra,0x0
  38:	30a080e7          	jalr	778(ra) # 33e <atoi>
  3c:	fca42223          	sw	a0,-60(s0)
  if ((n <= 1) || (n > 100)) {
  40:	3579                	addiw	a0,a0,-2
  42:	06200793          	li	a5,98
  46:	00a7ef63          	bltu	a5,a0,64 <main+0x64>
  4a:	00001997          	auipc	s3,0x1
  4e:	a8e98993          	addi	s3,s3,-1394 # ad8 <primes>

  while (1) {
     x=0;
     while ((n % primes[i]) == 0) {
        n = n / primes[i];
	fprintf(1, "%d, ", primes[i]);
  52:	00001917          	auipc	s2,0x1
  56:	9ae90913          	addi	s2,s2,-1618 # a00 <malloc+0x128>
	x=1;
     }
     if (x) fprintf(1, "[%d]\n", getpid());
  5a:	00001a17          	auipc	s4,0x1
  5e:	a56a0a13          	addi	s4,s4,-1450 # ab0 <malloc+0x1d8>
  62:	a079                	j	f0 <main+0xf0>
     fprintf(2, "Invalid input\nAborting...\n");
  64:	00001597          	auipc	a1,0x1
  68:	97c58593          	addi	a1,a1,-1668 # 9e0 <malloc+0x108>
  6c:	4509                	li	a0,2
  6e:	00000097          	auipc	ra,0x0
  72:	77e080e7          	jalr	1918(ra) # 7ec <fprintf>
     exit(0);
  76:	4501                	li	a0,0
  78:	00000097          	auipc	ra,0x0
  7c:	3c6080e7          	jalr	966(ra) # 43e <exit>
     if (n == 1) break;
  80:	fc442703          	lw	a4,-60(s0)
  84:	4785                	li	a5,1
  86:	10f70e63          	beq	a4,a5,1a2 <main+0x1a2>
     i++;
     if (pipe(pipefd) < 0) {
  8a:	fc840513          	addi	a0,s0,-56
  8e:	00000097          	auipc	ra,0x0
  92:	3c0080e7          	jalr	960(ra) # 44e <pipe>
  96:	0a054163          	bltz	a0,138 <main+0x138>
        fprintf(2, "Error: cannot create pipe\nAborting...\n");
        exit(0);
     }
     if (write(pipefd[1], &n, sizeof(int)) < 0) {
  9a:	4611                	li	a2,4
  9c:	fc440593          	addi	a1,s0,-60
  a0:	fcc42503          	lw	a0,-52(s0)
  a4:	00000097          	auipc	ra,0x0
  a8:	3ba080e7          	jalr	954(ra) # 45e <write>
  ac:	0a054463          	bltz	a0,154 <main+0x154>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
        exit(0);
     }
     close(pipefd[1]);
  b0:	fcc42503          	lw	a0,-52(s0)
  b4:	00000097          	auipc	ra,0x0
  b8:	3b2080e7          	jalr	946(ra) # 466 <close>
     y = fork();
  bc:	00000097          	auipc	ra,0x0
  c0:	37a080e7          	jalr	890(ra) # 436 <fork>
     if (y < 0) {
  c4:	0a054663          	bltz	a0,170 <main+0x170>
        fprintf(2, "Error: cannot fork\nAborting...\n");
	exit(0);
     }
     else if (y > 0) {
  c8:	0ca04263          	bgtz	a0,18c <main+0x18c>
	close(pipefd[0]);
        wait(0);
	break;
     }
     else {
        if (read(pipefd[0], &n, sizeof(int)) < 0) {
  cc:	4611                	li	a2,4
  ce:	fc440593          	addi	a1,s0,-60
  d2:	fc842503          	lw	a0,-56(s0)
  d6:	00000097          	auipc	ra,0x0
  da:	380080e7          	jalr	896(ra) # 456 <read>
  de:	0991                	addi	s3,s3,4
  e0:	0c054663          	bltz	a0,1ac <main+0x1ac>
           fprintf(2, "Error: cannot read from pipe\nAborting...\n");
           exit(0);
        }
	close(pipefd[0]);
  e4:	fc842503          	lw	a0,-56(s0)
  e8:	00000097          	auipc	ra,0x0
  ec:	37e080e7          	jalr	894(ra) # 466 <close>
     while ((n % primes[i]) == 0) {
  f0:	fc442783          	lw	a5,-60(s0)
  f4:	84ce                	mv	s1,s3
  f6:	0009a603          	lw	a2,0(s3)
  fa:	02c7e73b          	remw	a4,a5,a2
  fe:	f349                	bnez	a4,80 <main+0x80>
        n = n / primes[i];
 100:	02c7c7bb          	divw	a5,a5,a2
 104:	fcf42223          	sw	a5,-60(s0)
	fprintf(1, "%d, ", primes[i]);
 108:	85ca                	mv	a1,s2
 10a:	4505                	li	a0,1
 10c:	00000097          	auipc	ra,0x0
 110:	6e0080e7          	jalr	1760(ra) # 7ec <fprintf>
     while ((n % primes[i]) == 0) {
 114:	fc442783          	lw	a5,-60(s0)
 118:	4090                	lw	a2,0(s1)
 11a:	02c7e73b          	remw	a4,a5,a2
 11e:	d36d                	beqz	a4,100 <main+0x100>
     if (x) fprintf(1, "[%d]\n", getpid());
 120:	00000097          	auipc	ra,0x0
 124:	39e080e7          	jalr	926(ra) # 4be <getpid>
 128:	862a                	mv	a2,a0
 12a:	85d2                	mv	a1,s4
 12c:	4505                	li	a0,1
 12e:	00000097          	auipc	ra,0x0
 132:	6be080e7          	jalr	1726(ra) # 7ec <fprintf>
 136:	b7a9                	j	80 <main+0x80>
        fprintf(2, "Error: cannot create pipe\nAborting...\n");
 138:	00001597          	auipc	a1,0x1
 13c:	8d058593          	addi	a1,a1,-1840 # a08 <malloc+0x130>
 140:	4509                	li	a0,2
 142:	00000097          	auipc	ra,0x0
 146:	6aa080e7          	jalr	1706(ra) # 7ec <fprintf>
        exit(0);
 14a:	4501                	li	a0,0
 14c:	00000097          	auipc	ra,0x0
 150:	2f2080e7          	jalr	754(ra) # 43e <exit>
        fprintf(2, "Error: cannot write to pipe\nAborting...\n");
 154:	00001597          	auipc	a1,0x1
 158:	8dc58593          	addi	a1,a1,-1828 # a30 <malloc+0x158>
 15c:	4509                	li	a0,2
 15e:	00000097          	auipc	ra,0x0
 162:	68e080e7          	jalr	1678(ra) # 7ec <fprintf>
        exit(0);
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	2d6080e7          	jalr	726(ra) # 43e <exit>
        fprintf(2, "Error: cannot fork\nAborting...\n");
 170:	00001597          	auipc	a1,0x1
 174:	8f058593          	addi	a1,a1,-1808 # a60 <malloc+0x188>
 178:	4509                	li	a0,2
 17a:	00000097          	auipc	ra,0x0
 17e:	672080e7          	jalr	1650(ra) # 7ec <fprintf>
	exit(0);
 182:	4501                	li	a0,0
 184:	00000097          	auipc	ra,0x0
 188:	2ba080e7          	jalr	698(ra) # 43e <exit>
	close(pipefd[0]);
 18c:	fc842503          	lw	a0,-56(s0)
 190:	00000097          	auipc	ra,0x0
 194:	2d6080e7          	jalr	726(ra) # 466 <close>
        wait(0);
 198:	4501                	li	a0,0
 19a:	00000097          	auipc	ra,0x0
 19e:	2ac080e7          	jalr	684(ra) # 446 <wait>
     }
  }

  exit(0);
 1a2:	4501                	li	a0,0
 1a4:	00000097          	auipc	ra,0x0
 1a8:	29a080e7          	jalr	666(ra) # 43e <exit>
           fprintf(2, "Error: cannot read from pipe\nAborting...\n");
 1ac:	00001597          	auipc	a1,0x1
 1b0:	8d458593          	addi	a1,a1,-1836 # a80 <malloc+0x1a8>
 1b4:	4509                	li	a0,2
 1b6:	00000097          	auipc	ra,0x0
 1ba:	636080e7          	jalr	1590(ra) # 7ec <fprintf>
           exit(0);
 1be:	4501                	li	a0,0
 1c0:	00000097          	auipc	ra,0x0
 1c4:	27e080e7          	jalr	638(ra) # 43e <exit>

00000000000001c8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e422                	sd	s0,8(sp)
 1cc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ce:	87aa                	mv	a5,a0
 1d0:	0585                	addi	a1,a1,1
 1d2:	0785                	addi	a5,a5,1
 1d4:	fff5c703          	lbu	a4,-1(a1)
 1d8:	fee78fa3          	sb	a4,-1(a5)
 1dc:	fb75                	bnez	a4,1d0 <strcpy+0x8>
    ;
  return os;
}
 1de:	6422                	ld	s0,8(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret

00000000000001e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1ea:	00054783          	lbu	a5,0(a0)
 1ee:	cb91                	beqz	a5,202 <strcmp+0x1e>
 1f0:	0005c703          	lbu	a4,0(a1)
 1f4:	00f71763          	bne	a4,a5,202 <strcmp+0x1e>
    p++, q++;
 1f8:	0505                	addi	a0,a0,1
 1fa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1fc:	00054783          	lbu	a5,0(a0)
 200:	fbe5                	bnez	a5,1f0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 202:	0005c503          	lbu	a0,0(a1)
}
 206:	40a7853b          	subw	a0,a5,a0
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret

0000000000000210 <strlen>:

uint
strlen(const char *s)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 216:	00054783          	lbu	a5,0(a0)
 21a:	cf91                	beqz	a5,236 <strlen+0x26>
 21c:	0505                	addi	a0,a0,1
 21e:	87aa                	mv	a5,a0
 220:	4685                	li	a3,1
 222:	9e89                	subw	a3,a3,a0
 224:	00f6853b          	addw	a0,a3,a5
 228:	0785                	addi	a5,a5,1
 22a:	fff7c703          	lbu	a4,-1(a5)
 22e:	fb7d                	bnez	a4,224 <strlen+0x14>
    ;
  return n;
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
  for(n = 0; s[n]; n++)
 236:	4501                	li	a0,0
 238:	bfe5                	j	230 <strlen+0x20>

000000000000023a <memset>:

void*
memset(void *dst, int c, uint n)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 240:	ce09                	beqz	a2,25a <memset+0x20>
 242:	87aa                	mv	a5,a0
 244:	fff6071b          	addiw	a4,a2,-1
 248:	1702                	slli	a4,a4,0x20
 24a:	9301                	srli	a4,a4,0x20
 24c:	0705                	addi	a4,a4,1
 24e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 250:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 254:	0785                	addi	a5,a5,1
 256:	fee79de3          	bne	a5,a4,250 <memset+0x16>
  }
  return dst;
}
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret

0000000000000260 <strchr>:

char*
strchr(const char *s, char c)
{
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
  for(; *s; s++)
 266:	00054783          	lbu	a5,0(a0)
 26a:	cb99                	beqz	a5,280 <strchr+0x20>
    if(*s == c)
 26c:	00f58763          	beq	a1,a5,27a <strchr+0x1a>
  for(; *s; s++)
 270:	0505                	addi	a0,a0,1
 272:	00054783          	lbu	a5,0(a0)
 276:	fbfd                	bnez	a5,26c <strchr+0xc>
      return (char*)s;
  return 0;
 278:	4501                	li	a0,0
}
 27a:	6422                	ld	s0,8(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret
  return 0;
 280:	4501                	li	a0,0
 282:	bfe5                	j	27a <strchr+0x1a>

0000000000000284 <gets>:

char*
gets(char *buf, int max)
{
 284:	711d                	addi	sp,sp,-96
 286:	ec86                	sd	ra,88(sp)
 288:	e8a2                	sd	s0,80(sp)
 28a:	e4a6                	sd	s1,72(sp)
 28c:	e0ca                	sd	s2,64(sp)
 28e:	fc4e                	sd	s3,56(sp)
 290:	f852                	sd	s4,48(sp)
 292:	f456                	sd	s5,40(sp)
 294:	f05a                	sd	s6,32(sp)
 296:	ec5e                	sd	s7,24(sp)
 298:	1080                	addi	s0,sp,96
 29a:	8baa                	mv	s7,a0
 29c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 29e:	892a                	mv	s2,a0
 2a0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2a2:	4aa9                	li	s5,10
 2a4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2a6:	89a6                	mv	s3,s1
 2a8:	2485                	addiw	s1,s1,1
 2aa:	0344d863          	bge	s1,s4,2da <gets+0x56>
    cc = read(0, &c, 1);
 2ae:	4605                	li	a2,1
 2b0:	faf40593          	addi	a1,s0,-81
 2b4:	4501                	li	a0,0
 2b6:	00000097          	auipc	ra,0x0
 2ba:	1a0080e7          	jalr	416(ra) # 456 <read>
    if(cc < 1)
 2be:	00a05e63          	blez	a0,2da <gets+0x56>
    buf[i++] = c;
 2c2:	faf44783          	lbu	a5,-81(s0)
 2c6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ca:	01578763          	beq	a5,s5,2d8 <gets+0x54>
 2ce:	0905                	addi	s2,s2,1
 2d0:	fd679be3          	bne	a5,s6,2a6 <gets+0x22>
  for(i=0; i+1 < max; ){
 2d4:	89a6                	mv	s3,s1
 2d6:	a011                	j	2da <gets+0x56>
 2d8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2da:	99de                	add	s3,s3,s7
 2dc:	00098023          	sb	zero,0(s3)
  return buf;
}
 2e0:	855e                	mv	a0,s7
 2e2:	60e6                	ld	ra,88(sp)
 2e4:	6446                	ld	s0,80(sp)
 2e6:	64a6                	ld	s1,72(sp)
 2e8:	6906                	ld	s2,64(sp)
 2ea:	79e2                	ld	s3,56(sp)
 2ec:	7a42                	ld	s4,48(sp)
 2ee:	7aa2                	ld	s5,40(sp)
 2f0:	7b02                	ld	s6,32(sp)
 2f2:	6be2                	ld	s7,24(sp)
 2f4:	6125                	addi	sp,sp,96
 2f6:	8082                	ret

00000000000002f8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2f8:	1101                	addi	sp,sp,-32
 2fa:	ec06                	sd	ra,24(sp)
 2fc:	e822                	sd	s0,16(sp)
 2fe:	e426                	sd	s1,8(sp)
 300:	e04a                	sd	s2,0(sp)
 302:	1000                	addi	s0,sp,32
 304:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 306:	4581                	li	a1,0
 308:	00000097          	auipc	ra,0x0
 30c:	176080e7          	jalr	374(ra) # 47e <open>
  if(fd < 0)
 310:	02054563          	bltz	a0,33a <stat+0x42>
 314:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 316:	85ca                	mv	a1,s2
 318:	00000097          	auipc	ra,0x0
 31c:	17e080e7          	jalr	382(ra) # 496 <fstat>
 320:	892a                	mv	s2,a0
  close(fd);
 322:	8526                	mv	a0,s1
 324:	00000097          	auipc	ra,0x0
 328:	142080e7          	jalr	322(ra) # 466 <close>
  return r;
}
 32c:	854a                	mv	a0,s2
 32e:	60e2                	ld	ra,24(sp)
 330:	6442                	ld	s0,16(sp)
 332:	64a2                	ld	s1,8(sp)
 334:	6902                	ld	s2,0(sp)
 336:	6105                	addi	sp,sp,32
 338:	8082                	ret
    return -1;
 33a:	597d                	li	s2,-1
 33c:	bfc5                	j	32c <stat+0x34>

000000000000033e <atoi>:

int
atoi(const char *s)
{
 33e:	1141                	addi	sp,sp,-16
 340:	e422                	sd	s0,8(sp)
 342:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 344:	00054603          	lbu	a2,0(a0)
 348:	fd06079b          	addiw	a5,a2,-48
 34c:	0ff7f793          	andi	a5,a5,255
 350:	4725                	li	a4,9
 352:	02f76963          	bltu	a4,a5,384 <atoi+0x46>
 356:	86aa                	mv	a3,a0
  n = 0;
 358:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 35a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 35c:	0685                	addi	a3,a3,1
 35e:	0025179b          	slliw	a5,a0,0x2
 362:	9fa9                	addw	a5,a5,a0
 364:	0017979b          	slliw	a5,a5,0x1
 368:	9fb1                	addw	a5,a5,a2
 36a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 36e:	0006c603          	lbu	a2,0(a3)
 372:	fd06071b          	addiw	a4,a2,-48
 376:	0ff77713          	andi	a4,a4,255
 37a:	fee5f1e3          	bgeu	a1,a4,35c <atoi+0x1e>
  return n;
}
 37e:	6422                	ld	s0,8(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret
  n = 0;
 384:	4501                	li	a0,0
 386:	bfe5                	j	37e <atoi+0x40>

0000000000000388 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e422                	sd	s0,8(sp)
 38c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 38e:	02b57663          	bgeu	a0,a1,3ba <memmove+0x32>
    while(n-- > 0)
 392:	02c05163          	blez	a2,3b4 <memmove+0x2c>
 396:	fff6079b          	addiw	a5,a2,-1
 39a:	1782                	slli	a5,a5,0x20
 39c:	9381                	srli	a5,a5,0x20
 39e:	0785                	addi	a5,a5,1
 3a0:	97aa                	add	a5,a5,a0
  dst = vdst;
 3a2:	872a                	mv	a4,a0
      *dst++ = *src++;
 3a4:	0585                	addi	a1,a1,1
 3a6:	0705                	addi	a4,a4,1
 3a8:	fff5c683          	lbu	a3,-1(a1)
 3ac:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3b0:	fee79ae3          	bne	a5,a4,3a4 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3b4:	6422                	ld	s0,8(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret
    dst += n;
 3ba:	00c50733          	add	a4,a0,a2
    src += n;
 3be:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3c0:	fec05ae3          	blez	a2,3b4 <memmove+0x2c>
 3c4:	fff6079b          	addiw	a5,a2,-1
 3c8:	1782                	slli	a5,a5,0x20
 3ca:	9381                	srli	a5,a5,0x20
 3cc:	fff7c793          	not	a5,a5
 3d0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3d2:	15fd                	addi	a1,a1,-1
 3d4:	177d                	addi	a4,a4,-1
 3d6:	0005c683          	lbu	a3,0(a1)
 3da:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3de:	fee79ae3          	bne	a5,a4,3d2 <memmove+0x4a>
 3e2:	bfc9                	j	3b4 <memmove+0x2c>

00000000000003e4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3e4:	1141                	addi	sp,sp,-16
 3e6:	e422                	sd	s0,8(sp)
 3e8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ea:	ca05                	beqz	a2,41a <memcmp+0x36>
 3ec:	fff6069b          	addiw	a3,a2,-1
 3f0:	1682                	slli	a3,a3,0x20
 3f2:	9281                	srli	a3,a3,0x20
 3f4:	0685                	addi	a3,a3,1
 3f6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3f8:	00054783          	lbu	a5,0(a0)
 3fc:	0005c703          	lbu	a4,0(a1)
 400:	00e79863          	bne	a5,a4,410 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 404:	0505                	addi	a0,a0,1
    p2++;
 406:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 408:	fed518e3          	bne	a0,a3,3f8 <memcmp+0x14>
  }
  return 0;
 40c:	4501                	li	a0,0
 40e:	a019                	j	414 <memcmp+0x30>
      return *p1 - *p2;
 410:	40e7853b          	subw	a0,a5,a4
}
 414:	6422                	ld	s0,8(sp)
 416:	0141                	addi	sp,sp,16
 418:	8082                	ret
  return 0;
 41a:	4501                	li	a0,0
 41c:	bfe5                	j	414 <memcmp+0x30>

000000000000041e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 41e:	1141                	addi	sp,sp,-16
 420:	e406                	sd	ra,8(sp)
 422:	e022                	sd	s0,0(sp)
 424:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 426:	00000097          	auipc	ra,0x0
 42a:	f62080e7          	jalr	-158(ra) # 388 <memmove>
}
 42e:	60a2                	ld	ra,8(sp)
 430:	6402                	ld	s0,0(sp)
 432:	0141                	addi	sp,sp,16
 434:	8082                	ret

0000000000000436 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 436:	4885                	li	a7,1
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <exit>:
.global exit
exit:
 li a7, SYS_exit
 43e:	4889                	li	a7,2
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <wait>:
.global wait
wait:
 li a7, SYS_wait
 446:	488d                	li	a7,3
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 44e:	4891                	li	a7,4
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <read>:
.global read
read:
 li a7, SYS_read
 456:	4895                	li	a7,5
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <write>:
.global write
write:
 li a7, SYS_write
 45e:	48c1                	li	a7,16
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <close>:
.global close
close:
 li a7, SYS_close
 466:	48d5                	li	a7,21
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <kill>:
.global kill
kill:
 li a7, SYS_kill
 46e:	4899                	li	a7,6
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <exec>:
.global exec
exec:
 li a7, SYS_exec
 476:	489d                	li	a7,7
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <open>:
.global open
open:
 li a7, SYS_open
 47e:	48bd                	li	a7,15
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 486:	48c5                	li	a7,17
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 48e:	48c9                	li	a7,18
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 496:	48a1                	li	a7,8
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <link>:
.global link
link:
 li a7, SYS_link
 49e:	48cd                	li	a7,19
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4a6:	48d1                	li	a7,20
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ae:	48a5                	li	a7,9
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4b6:	48a9                	li	a7,10
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4be:	48ad                	li	a7,11
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4c6:	48b1                	li	a7,12
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4ce:	48b5                	li	a7,13
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4d6:	48b9                	li	a7,14
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 4de:	48d9                	li	a7,22
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <yield>:
.global yield
yield:
 li a7, SYS_yield
 4e6:	48dd                	li	a7,23
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 4ee:	48e1                	li	a7,24
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 4f6:	48e5                	li	a7,25
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 4fe:	48e9                	li	a7,26
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <ps>:
.global ps
ps:
 li a7, SYS_ps
 506:	48ed                	li	a7,27
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 50e:	48f1                	li	a7,28
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 516:	48f5                	li	a7,29
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 51e:	48f9                	li	a7,30
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 526:	48fd                	li	a7,31
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 52e:	02000893          	li	a7,32
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 538:	02100893          	li	a7,33
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 542:	1101                	addi	sp,sp,-32
 544:	ec06                	sd	ra,24(sp)
 546:	e822                	sd	s0,16(sp)
 548:	1000                	addi	s0,sp,32
 54a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 54e:	4605                	li	a2,1
 550:	fef40593          	addi	a1,s0,-17
 554:	00000097          	auipc	ra,0x0
 558:	f0a080e7          	jalr	-246(ra) # 45e <write>
}
 55c:	60e2                	ld	ra,24(sp)
 55e:	6442                	ld	s0,16(sp)
 560:	6105                	addi	sp,sp,32
 562:	8082                	ret

0000000000000564 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 564:	7139                	addi	sp,sp,-64
 566:	fc06                	sd	ra,56(sp)
 568:	f822                	sd	s0,48(sp)
 56a:	f426                	sd	s1,40(sp)
 56c:	f04a                	sd	s2,32(sp)
 56e:	ec4e                	sd	s3,24(sp)
 570:	0080                	addi	s0,sp,64
 572:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 574:	c299                	beqz	a3,57a <printint+0x16>
 576:	0805c863          	bltz	a1,606 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 57a:	2581                	sext.w	a1,a1
  neg = 0;
 57c:	4881                	li	a7,0
 57e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 582:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 584:	2601                	sext.w	a2,a2
 586:	00000517          	auipc	a0,0x0
 58a:	53a50513          	addi	a0,a0,1338 # ac0 <digits>
 58e:	883a                	mv	a6,a4
 590:	2705                	addiw	a4,a4,1
 592:	02c5f7bb          	remuw	a5,a1,a2
 596:	1782                	slli	a5,a5,0x20
 598:	9381                	srli	a5,a5,0x20
 59a:	97aa                	add	a5,a5,a0
 59c:	0007c783          	lbu	a5,0(a5)
 5a0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5a4:	0005879b          	sext.w	a5,a1
 5a8:	02c5d5bb          	divuw	a1,a1,a2
 5ac:	0685                	addi	a3,a3,1
 5ae:	fec7f0e3          	bgeu	a5,a2,58e <printint+0x2a>
  if(neg)
 5b2:	00088b63          	beqz	a7,5c8 <printint+0x64>
    buf[i++] = '-';
 5b6:	fd040793          	addi	a5,s0,-48
 5ba:	973e                	add	a4,a4,a5
 5bc:	02d00793          	li	a5,45
 5c0:	fef70823          	sb	a5,-16(a4)
 5c4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5c8:	02e05863          	blez	a4,5f8 <printint+0x94>
 5cc:	fc040793          	addi	a5,s0,-64
 5d0:	00e78933          	add	s2,a5,a4
 5d4:	fff78993          	addi	s3,a5,-1
 5d8:	99ba                	add	s3,s3,a4
 5da:	377d                	addiw	a4,a4,-1
 5dc:	1702                	slli	a4,a4,0x20
 5de:	9301                	srli	a4,a4,0x20
 5e0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5e4:	fff94583          	lbu	a1,-1(s2)
 5e8:	8526                	mv	a0,s1
 5ea:	00000097          	auipc	ra,0x0
 5ee:	f58080e7          	jalr	-168(ra) # 542 <putc>
  while(--i >= 0)
 5f2:	197d                	addi	s2,s2,-1
 5f4:	ff3918e3          	bne	s2,s3,5e4 <printint+0x80>
}
 5f8:	70e2                	ld	ra,56(sp)
 5fa:	7442                	ld	s0,48(sp)
 5fc:	74a2                	ld	s1,40(sp)
 5fe:	7902                	ld	s2,32(sp)
 600:	69e2                	ld	s3,24(sp)
 602:	6121                	addi	sp,sp,64
 604:	8082                	ret
    x = -xx;
 606:	40b005bb          	negw	a1,a1
    neg = 1;
 60a:	4885                	li	a7,1
    x = -xx;
 60c:	bf8d                	j	57e <printint+0x1a>

000000000000060e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 60e:	7119                	addi	sp,sp,-128
 610:	fc86                	sd	ra,120(sp)
 612:	f8a2                	sd	s0,112(sp)
 614:	f4a6                	sd	s1,104(sp)
 616:	f0ca                	sd	s2,96(sp)
 618:	ecce                	sd	s3,88(sp)
 61a:	e8d2                	sd	s4,80(sp)
 61c:	e4d6                	sd	s5,72(sp)
 61e:	e0da                	sd	s6,64(sp)
 620:	fc5e                	sd	s7,56(sp)
 622:	f862                	sd	s8,48(sp)
 624:	f466                	sd	s9,40(sp)
 626:	f06a                	sd	s10,32(sp)
 628:	ec6e                	sd	s11,24(sp)
 62a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 62c:	0005c903          	lbu	s2,0(a1)
 630:	18090f63          	beqz	s2,7ce <vprintf+0x1c0>
 634:	8aaa                	mv	s5,a0
 636:	8b32                	mv	s6,a2
 638:	00158493          	addi	s1,a1,1
  state = 0;
 63c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 63e:	02500a13          	li	s4,37
      if(c == 'd'){
 642:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 646:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 64a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 64e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 652:	00000b97          	auipc	s7,0x0
 656:	46eb8b93          	addi	s7,s7,1134 # ac0 <digits>
 65a:	a839                	j	678 <vprintf+0x6a>
        putc(fd, c);
 65c:	85ca                	mv	a1,s2
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	ee2080e7          	jalr	-286(ra) # 542 <putc>
 668:	a019                	j	66e <vprintf+0x60>
    } else if(state == '%'){
 66a:	01498f63          	beq	s3,s4,688 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 66e:	0485                	addi	s1,s1,1
 670:	fff4c903          	lbu	s2,-1(s1)
 674:	14090d63          	beqz	s2,7ce <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 678:	0009079b          	sext.w	a5,s2
    if(state == 0){
 67c:	fe0997e3          	bnez	s3,66a <vprintf+0x5c>
      if(c == '%'){
 680:	fd479ee3          	bne	a5,s4,65c <vprintf+0x4e>
        state = '%';
 684:	89be                	mv	s3,a5
 686:	b7e5                	j	66e <vprintf+0x60>
      if(c == 'd'){
 688:	05878063          	beq	a5,s8,6c8 <vprintf+0xba>
      } else if(c == 'l') {
 68c:	05978c63          	beq	a5,s9,6e4 <vprintf+0xd6>
      } else if(c == 'x') {
 690:	07a78863          	beq	a5,s10,700 <vprintf+0xf2>
      } else if(c == 'p') {
 694:	09b78463          	beq	a5,s11,71c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 698:	07300713          	li	a4,115
 69c:	0ce78663          	beq	a5,a4,768 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6a0:	06300713          	li	a4,99
 6a4:	0ee78e63          	beq	a5,a4,7a0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6a8:	11478863          	beq	a5,s4,7b8 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ac:	85d2                	mv	a1,s4
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	e92080e7          	jalr	-366(ra) # 542 <putc>
        putc(fd, c);
 6b8:	85ca                	mv	a1,s2
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e86080e7          	jalr	-378(ra) # 542 <putc>
      }
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b765                	j	66e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6c8:	008b0913          	addi	s2,s6,8
 6cc:	4685                	li	a3,1
 6ce:	4629                	li	a2,10
 6d0:	000b2583          	lw	a1,0(s6)
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	e8e080e7          	jalr	-370(ra) # 564 <printint>
 6de:	8b4a                	mv	s6,s2
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	b771                	j	66e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e4:	008b0913          	addi	s2,s6,8
 6e8:	4681                	li	a3,0
 6ea:	4629                	li	a2,10
 6ec:	000b2583          	lw	a1,0(s6)
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e72080e7          	jalr	-398(ra) # 564 <printint>
 6fa:	8b4a                	mv	s6,s2
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	bf85                	j	66e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 700:	008b0913          	addi	s2,s6,8
 704:	4681                	li	a3,0
 706:	4641                	li	a2,16
 708:	000b2583          	lw	a1,0(s6)
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	e56080e7          	jalr	-426(ra) # 564 <printint>
 716:	8b4a                	mv	s6,s2
      state = 0;
 718:	4981                	li	s3,0
 71a:	bf91                	j	66e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 71c:	008b0793          	addi	a5,s6,8
 720:	f8f43423          	sd	a5,-120(s0)
 724:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 728:	03000593          	li	a1,48
 72c:	8556                	mv	a0,s5
 72e:	00000097          	auipc	ra,0x0
 732:	e14080e7          	jalr	-492(ra) # 542 <putc>
  putc(fd, 'x');
 736:	85ea                	mv	a1,s10
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	e08080e7          	jalr	-504(ra) # 542 <putc>
 742:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 744:	03c9d793          	srli	a5,s3,0x3c
 748:	97de                	add	a5,a5,s7
 74a:	0007c583          	lbu	a1,0(a5)
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	df2080e7          	jalr	-526(ra) # 542 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 758:	0992                	slli	s3,s3,0x4
 75a:	397d                	addiw	s2,s2,-1
 75c:	fe0914e3          	bnez	s2,744 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 760:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 764:	4981                	li	s3,0
 766:	b721                	j	66e <vprintf+0x60>
        s = va_arg(ap, char*);
 768:	008b0993          	addi	s3,s6,8
 76c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 770:	02090163          	beqz	s2,792 <vprintf+0x184>
        while(*s != 0){
 774:	00094583          	lbu	a1,0(s2)
 778:	c9a1                	beqz	a1,7c8 <vprintf+0x1ba>
          putc(fd, *s);
 77a:	8556                	mv	a0,s5
 77c:	00000097          	auipc	ra,0x0
 780:	dc6080e7          	jalr	-570(ra) # 542 <putc>
          s++;
 784:	0905                	addi	s2,s2,1
        while(*s != 0){
 786:	00094583          	lbu	a1,0(s2)
 78a:	f9e5                	bnez	a1,77a <vprintf+0x16c>
        s = va_arg(ap, char*);
 78c:	8b4e                	mv	s6,s3
      state = 0;
 78e:	4981                	li	s3,0
 790:	bdf9                	j	66e <vprintf+0x60>
          s = "(null)";
 792:	00000917          	auipc	s2,0x0
 796:	32690913          	addi	s2,s2,806 # ab8 <malloc+0x1e0>
        while(*s != 0){
 79a:	02800593          	li	a1,40
 79e:	bff1                	j	77a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7a0:	008b0913          	addi	s2,s6,8
 7a4:	000b4583          	lbu	a1,0(s6)
 7a8:	8556                	mv	a0,s5
 7aa:	00000097          	auipc	ra,0x0
 7ae:	d98080e7          	jalr	-616(ra) # 542 <putc>
 7b2:	8b4a                	mv	s6,s2
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	bd65                	j	66e <vprintf+0x60>
        putc(fd, c);
 7b8:	85d2                	mv	a1,s4
 7ba:	8556                	mv	a0,s5
 7bc:	00000097          	auipc	ra,0x0
 7c0:	d86080e7          	jalr	-634(ra) # 542 <putc>
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	b565                	j	66e <vprintf+0x60>
        s = va_arg(ap, char*);
 7c8:	8b4e                	mv	s6,s3
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b54d                	j	66e <vprintf+0x60>
    }
  }
}
 7ce:	70e6                	ld	ra,120(sp)
 7d0:	7446                	ld	s0,112(sp)
 7d2:	74a6                	ld	s1,104(sp)
 7d4:	7906                	ld	s2,96(sp)
 7d6:	69e6                	ld	s3,88(sp)
 7d8:	6a46                	ld	s4,80(sp)
 7da:	6aa6                	ld	s5,72(sp)
 7dc:	6b06                	ld	s6,64(sp)
 7de:	7be2                	ld	s7,56(sp)
 7e0:	7c42                	ld	s8,48(sp)
 7e2:	7ca2                	ld	s9,40(sp)
 7e4:	7d02                	ld	s10,32(sp)
 7e6:	6de2                	ld	s11,24(sp)
 7e8:	6109                	addi	sp,sp,128
 7ea:	8082                	ret

00000000000007ec <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ec:	715d                	addi	sp,sp,-80
 7ee:	ec06                	sd	ra,24(sp)
 7f0:	e822                	sd	s0,16(sp)
 7f2:	1000                	addi	s0,sp,32
 7f4:	e010                	sd	a2,0(s0)
 7f6:	e414                	sd	a3,8(s0)
 7f8:	e818                	sd	a4,16(s0)
 7fa:	ec1c                	sd	a5,24(s0)
 7fc:	03043023          	sd	a6,32(s0)
 800:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 804:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 808:	8622                	mv	a2,s0
 80a:	00000097          	auipc	ra,0x0
 80e:	e04080e7          	jalr	-508(ra) # 60e <vprintf>
}
 812:	60e2                	ld	ra,24(sp)
 814:	6442                	ld	s0,16(sp)
 816:	6161                	addi	sp,sp,80
 818:	8082                	ret

000000000000081a <printf>:

void
printf(const char *fmt, ...)
{
 81a:	711d                	addi	sp,sp,-96
 81c:	ec06                	sd	ra,24(sp)
 81e:	e822                	sd	s0,16(sp)
 820:	1000                	addi	s0,sp,32
 822:	e40c                	sd	a1,8(s0)
 824:	e810                	sd	a2,16(s0)
 826:	ec14                	sd	a3,24(s0)
 828:	f018                	sd	a4,32(s0)
 82a:	f41c                	sd	a5,40(s0)
 82c:	03043823          	sd	a6,48(s0)
 830:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 834:	00840613          	addi	a2,s0,8
 838:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 83c:	85aa                	mv	a1,a0
 83e:	4505                	li	a0,1
 840:	00000097          	auipc	ra,0x0
 844:	dce080e7          	jalr	-562(ra) # 60e <vprintf>
}
 848:	60e2                	ld	ra,24(sp)
 84a:	6442                	ld	s0,16(sp)
 84c:	6125                	addi	sp,sp,96
 84e:	8082                	ret

0000000000000850 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 850:	1141                	addi	sp,sp,-16
 852:	e422                	sd	s0,8(sp)
 854:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 856:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85a:	00000797          	auipc	a5,0x0
 85e:	2e67b783          	ld	a5,742(a5) # b40 <freep>
 862:	a805                	j	892 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 864:	4618                	lw	a4,8(a2)
 866:	9db9                	addw	a1,a1,a4
 868:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 86c:	6398                	ld	a4,0(a5)
 86e:	6318                	ld	a4,0(a4)
 870:	fee53823          	sd	a4,-16(a0)
 874:	a091                	j	8b8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 876:	ff852703          	lw	a4,-8(a0)
 87a:	9e39                	addw	a2,a2,a4
 87c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 87e:	ff053703          	ld	a4,-16(a0)
 882:	e398                	sd	a4,0(a5)
 884:	a099                	j	8ca <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 886:	6398                	ld	a4,0(a5)
 888:	00e7e463          	bltu	a5,a4,890 <free+0x40>
 88c:	00e6ea63          	bltu	a3,a4,8a0 <free+0x50>
{
 890:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 892:	fed7fae3          	bgeu	a5,a3,886 <free+0x36>
 896:	6398                	ld	a4,0(a5)
 898:	00e6e463          	bltu	a3,a4,8a0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 89c:	fee7eae3          	bltu	a5,a4,890 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8a0:	ff852583          	lw	a1,-8(a0)
 8a4:	6390                	ld	a2,0(a5)
 8a6:	02059713          	slli	a4,a1,0x20
 8aa:	9301                	srli	a4,a4,0x20
 8ac:	0712                	slli	a4,a4,0x4
 8ae:	9736                	add	a4,a4,a3
 8b0:	fae60ae3          	beq	a2,a4,864 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8b4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8b8:	4790                	lw	a2,8(a5)
 8ba:	02061713          	slli	a4,a2,0x20
 8be:	9301                	srli	a4,a4,0x20
 8c0:	0712                	slli	a4,a4,0x4
 8c2:	973e                	add	a4,a4,a5
 8c4:	fae689e3          	beq	a3,a4,876 <free+0x26>
  } else
    p->s.ptr = bp;
 8c8:	e394                	sd	a3,0(a5)
  freep = p;
 8ca:	00000717          	auipc	a4,0x0
 8ce:	26f73b23          	sd	a5,630(a4) # b40 <freep>
}
 8d2:	6422                	ld	s0,8(sp)
 8d4:	0141                	addi	sp,sp,16
 8d6:	8082                	ret

00000000000008d8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8d8:	7139                	addi	sp,sp,-64
 8da:	fc06                	sd	ra,56(sp)
 8dc:	f822                	sd	s0,48(sp)
 8de:	f426                	sd	s1,40(sp)
 8e0:	f04a                	sd	s2,32(sp)
 8e2:	ec4e                	sd	s3,24(sp)
 8e4:	e852                	sd	s4,16(sp)
 8e6:	e456                	sd	s5,8(sp)
 8e8:	e05a                	sd	s6,0(sp)
 8ea:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ec:	02051493          	slli	s1,a0,0x20
 8f0:	9081                	srli	s1,s1,0x20
 8f2:	04bd                	addi	s1,s1,15
 8f4:	8091                	srli	s1,s1,0x4
 8f6:	0014899b          	addiw	s3,s1,1
 8fa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8fc:	00000517          	auipc	a0,0x0
 900:	24453503          	ld	a0,580(a0) # b40 <freep>
 904:	c515                	beqz	a0,930 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 906:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 908:	4798                	lw	a4,8(a5)
 90a:	02977f63          	bgeu	a4,s1,948 <malloc+0x70>
 90e:	8a4e                	mv	s4,s3
 910:	0009871b          	sext.w	a4,s3
 914:	6685                	lui	a3,0x1
 916:	00d77363          	bgeu	a4,a3,91c <malloc+0x44>
 91a:	6a05                	lui	s4,0x1
 91c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 920:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 924:	00000917          	auipc	s2,0x0
 928:	21c90913          	addi	s2,s2,540 # b40 <freep>
  if(p == (char*)-1)
 92c:	5afd                	li	s5,-1
 92e:	a88d                	j	9a0 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 930:	00000797          	auipc	a5,0x0
 934:	21878793          	addi	a5,a5,536 # b48 <base>
 938:	00000717          	auipc	a4,0x0
 93c:	20f73423          	sd	a5,520(a4) # b40 <freep>
 940:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 942:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 946:	b7e1                	j	90e <malloc+0x36>
      if(p->s.size == nunits)
 948:	02e48b63          	beq	s1,a4,97e <malloc+0xa6>
        p->s.size -= nunits;
 94c:	4137073b          	subw	a4,a4,s3
 950:	c798                	sw	a4,8(a5)
        p += p->s.size;
 952:	1702                	slli	a4,a4,0x20
 954:	9301                	srli	a4,a4,0x20
 956:	0712                	slli	a4,a4,0x4
 958:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 95a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 95e:	00000717          	auipc	a4,0x0
 962:	1ea73123          	sd	a0,482(a4) # b40 <freep>
      return (void*)(p + 1);
 966:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 96a:	70e2                	ld	ra,56(sp)
 96c:	7442                	ld	s0,48(sp)
 96e:	74a2                	ld	s1,40(sp)
 970:	7902                	ld	s2,32(sp)
 972:	69e2                	ld	s3,24(sp)
 974:	6a42                	ld	s4,16(sp)
 976:	6aa2                	ld	s5,8(sp)
 978:	6b02                	ld	s6,0(sp)
 97a:	6121                	addi	sp,sp,64
 97c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 97e:	6398                	ld	a4,0(a5)
 980:	e118                	sd	a4,0(a0)
 982:	bff1                	j	95e <malloc+0x86>
  hp->s.size = nu;
 984:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 988:	0541                	addi	a0,a0,16
 98a:	00000097          	auipc	ra,0x0
 98e:	ec6080e7          	jalr	-314(ra) # 850 <free>
  return freep;
 992:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 996:	d971                	beqz	a0,96a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 998:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 99a:	4798                	lw	a4,8(a5)
 99c:	fa9776e3          	bgeu	a4,s1,948 <malloc+0x70>
    if(p == freep)
 9a0:	00093703          	ld	a4,0(s2)
 9a4:	853e                	mv	a0,a5
 9a6:	fef719e3          	bne	a4,a5,998 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9aa:	8552                	mv	a0,s4
 9ac:	00000097          	auipc	ra,0x0
 9b0:	b1a080e7          	jalr	-1254(ra) # 4c6 <sbrk>
  if(p == (char*)-1)
 9b4:	fd5518e3          	bne	a0,s5,984 <malloc+0xac>
        return 0;
 9b8:	4501                	li	a0,0
 9ba:	bf45                	j	96a <malloc+0x92>
