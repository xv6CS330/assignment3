
user/_testpspinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/procstat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	0100                	addi	s0,sp,128
  int m, n, x;
  struct procstat pstat;

  if (argc != 3) {
   e:	478d                	li	a5,3
  10:	02f50063          	beq	a0,a5,30 <main+0x30>
     fprintf(2, "syntax: testpspinfo m n\nAborting...\n");
  14:	00001597          	auipc	a1,0x1
  18:	a5c58593          	addi	a1,a1,-1444 # a70 <malloc+0xe8>
  1c:	4509                	li	a0,2
  1e:	00001097          	auipc	ra,0x1
  22:	87e080e7          	jalr	-1922(ra) # 89c <fprintf>
     exit(0);
  26:	4501                	li	a0,0
  28:	00000097          	auipc	ra,0x0
  2c:	4c6080e7          	jalr	1222(ra) # 4ee <exit>
  30:	84ae                	mv	s1,a1
  }

  m = atoi(argv[1]);
  32:	6588                	ld	a0,8(a1)
  34:	00000097          	auipc	ra,0x0
  38:	3ba080e7          	jalr	954(ra) # 3ee <atoi>
  3c:	892a                	mv	s2,a0
  if (m <= 0) {
  3e:	02a05b63          	blez	a0,74 <main+0x74>
     fprintf(2, "Invalid input\nAborting...\n");
     exit(0);
  }
  n = atoi(argv[2]);
  42:	6888                	ld	a0,16(s1)
  44:	00000097          	auipc	ra,0x0
  48:	3aa080e7          	jalr	938(ra) # 3ee <atoi>
  4c:	84aa                	mv	s1,a0
  if ((n != 0) && (n != 1)) {
  4e:	0005071b          	sext.w	a4,a0
  52:	4785                	li	a5,1
  54:	02e7fe63          	bgeu	a5,a4,90 <main+0x90>
     fprintf(2, "Invalid input\nAborting...\n");
  58:	00001597          	auipc	a1,0x1
  5c:	a4058593          	addi	a1,a1,-1472 # a98 <malloc+0x110>
  60:	4509                	li	a0,2
  62:	00001097          	auipc	ra,0x1
  66:	83a080e7          	jalr	-1990(ra) # 89c <fprintf>
     exit(0);
  6a:	4501                	li	a0,0
  6c:	00000097          	auipc	ra,0x0
  70:	482080e7          	jalr	1154(ra) # 4ee <exit>
     fprintf(2, "Invalid input\nAborting...\n");
  74:	00001597          	auipc	a1,0x1
  78:	a2458593          	addi	a1,a1,-1500 # a98 <malloc+0x110>
  7c:	4509                	li	a0,2
  7e:	00001097          	auipc	ra,0x1
  82:	81e080e7          	jalr	-2018(ra) # 89c <fprintf>
     exit(0);
  86:	4501                	li	a0,0
  88:	00000097          	auipc	ra,0x0
  8c:	466080e7          	jalr	1126(ra) # 4ee <exit>
  }

  x = fork();
  90:	00000097          	auipc	ra,0x0
  94:	456080e7          	jalr	1110(ra) # 4e6 <fork>
  98:	89aa                	mv	s3,a0
  if (x < 0) {
  9a:	0e054e63          	bltz	a0,196 <main+0x196>
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  9e:	14a05463          	blez	a0,1e6 <main+0x1e6>
     if (n) sleep(m);
  a2:	10049863          	bnez	s1,1b2 <main+0x1b2>
     fprintf(1, "%d: Parent.\n", getpid());
  a6:	00000097          	auipc	ra,0x0
  aa:	4c8080e7          	jalr	1224(ra) # 56e <getpid>
  ae:	862a                	mv	a2,a0
  b0:	00001597          	auipc	a1,0x1
  b4:	a2858593          	addi	a1,a1,-1496 # ad8 <malloc+0x150>
  b8:	4505                	li	a0,1
  ba:	00000097          	auipc	ra,0x0
  be:	7e2080e7          	jalr	2018(ra) # 89c <fprintf>
     ps();
  c2:	00000097          	auipc	ra,0x0
  c6:	4f4080e7          	jalr	1268(ra) # 5b6 <ps>
     fprintf(1, "\n");
  ca:	00001597          	auipc	a1,0x1
  ce:	a2e58593          	addi	a1,a1,-1490 # af8 <malloc+0x170>
  d2:	4505                	li	a0,1
  d4:	00000097          	auipc	ra,0x0
  d8:	7c8080e7          	jalr	1992(ra) # 89c <fprintf>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
  dc:	f9840593          	addi	a1,s0,-104
  e0:	557d                	li	a0,-1
  e2:	00000097          	auipc	ra,0x0
  e6:	4dc080e7          	jalr	1244(ra) # 5be <pinfo>
  ea:	0c054a63          	bltz	a0,1be <main+0x1be>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
  ee:	fc843783          	ld	a5,-56(s0)
  f2:	e43e                	sd	a5,8(sp)
  f4:	fc042783          	lw	a5,-64(s0)
  f8:	e03e                	sd	a5,0(sp)
  fa:	fbc42883          	lw	a7,-68(s0)
  fe:	fb842803          	lw	a6,-72(s0)
 102:	fa840793          	addi	a5,s0,-88
 106:	fa040713          	addi	a4,s0,-96
 10a:	f9c42683          	lw	a3,-100(s0)
 10e:	f9842603          	lw	a2,-104(s0)
 112:	00001597          	auipc	a1,0x1
 116:	9ee58593          	addi	a1,a1,-1554 # b00 <malloc+0x178>
 11a:	4505                	li	a0,1
 11c:	00000097          	auipc	ra,0x0
 120:	780080e7          	jalr	1920(ra) # 89c <fprintf>
     if (pinfo(x, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 124:	f9840593          	addi	a1,s0,-104
 128:	854e                	mv	a0,s3
 12a:	00000097          	auipc	ra,0x0
 12e:	494080e7          	jalr	1172(ra) # 5be <pinfo>
 132:	0a054063          	bltz	a0,1d2 <main+0x1d2>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
 136:	fc843783          	ld	a5,-56(s0)
 13a:	e43e                	sd	a5,8(sp)
 13c:	fc042783          	lw	a5,-64(s0)
 140:	e03e                	sd	a5,0(sp)
 142:	fbc42883          	lw	a7,-68(s0)
 146:	fb842803          	lw	a6,-72(s0)
 14a:	fa840793          	addi	a5,s0,-88
 14e:	fa040713          	addi	a4,s0,-96
 152:	f9c42683          	lw	a3,-100(s0)
 156:	f9842603          	lw	a2,-104(s0)
 15a:	00001597          	auipc	a1,0x1
 15e:	9f658593          	addi	a1,a1,-1546 # b50 <malloc+0x1c8>
 162:	4505                	li	a0,1
 164:	00000097          	auipc	ra,0x0
 168:	738080e7          	jalr	1848(ra) # 89c <fprintf>
     fprintf(1, "Return value of waitpid=%d\n", waitpid(x, 0));
 16c:	4581                	li	a1,0
 16e:	854e                	mv	a0,s3
 170:	00000097          	auipc	ra,0x0
 174:	43e080e7          	jalr	1086(ra) # 5ae <waitpid>
 178:	862a                	mv	a2,a0
 17a:	00001597          	auipc	a1,0x1
 17e:	a2658593          	addi	a1,a1,-1498 # ba0 <malloc+0x218>
 182:	4505                	li	a0,1
 184:	00000097          	auipc	ra,0x0
 188:	718080e7          	jalr	1816(ra) # 89c <fprintf>
     sleep(1);
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
  }

  exit(0);
 18c:	4501                	li	a0,0
 18e:	00000097          	auipc	ra,0x0
 192:	360080e7          	jalr	864(ra) # 4ee <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
 196:	00001597          	auipc	a1,0x1
 19a:	92258593          	addi	a1,a1,-1758 # ab8 <malloc+0x130>
 19e:	4509                	li	a0,2
 1a0:	00000097          	auipc	ra,0x0
 1a4:	6fc080e7          	jalr	1788(ra) # 89c <fprintf>
     exit(0);
 1a8:	4501                	li	a0,0
 1aa:	00000097          	auipc	ra,0x0
 1ae:	344080e7          	jalr	836(ra) # 4ee <exit>
     if (n) sleep(m);
 1b2:	854a                	mv	a0,s2
 1b4:	00000097          	auipc	ra,0x0
 1b8:	3ca080e7          	jalr	970(ra) # 57e <sleep>
 1bc:	b5ed                	j	a6 <main+0xa6>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 1be:	00001597          	auipc	a1,0x1
 1c2:	92a58593          	addi	a1,a1,-1750 # ae8 <malloc+0x160>
 1c6:	4505                	li	a0,1
 1c8:	00000097          	auipc	ra,0x0
 1cc:	6d4080e7          	jalr	1748(ra) # 89c <fprintf>
 1d0:	bf91                	j	124 <main+0x124>
     if (pinfo(x, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 1d2:	00001597          	auipc	a1,0x1
 1d6:	91658593          	addi	a1,a1,-1770 # ae8 <malloc+0x160>
 1da:	4505                	li	a0,1
 1dc:	00000097          	auipc	ra,0x0
 1e0:	6c0080e7          	jalr	1728(ra) # 89c <fprintf>
 1e4:	b761                	j	16c <main+0x16c>
     if (!n) sleep(m);
 1e6:	c8ad                	beqz	s1,258 <main+0x258>
     fprintf(1, "%d: Child.\n", getpid());
 1e8:	00000097          	auipc	ra,0x0
 1ec:	386080e7          	jalr	902(ra) # 56e <getpid>
 1f0:	862a                	mv	a2,a0
 1f2:	00001597          	auipc	a1,0x1
 1f6:	9ce58593          	addi	a1,a1,-1586 # bc0 <malloc+0x238>
 1fa:	4505                	li	a0,1
 1fc:	00000097          	auipc	ra,0x0
 200:	6a0080e7          	jalr	1696(ra) # 89c <fprintf>
     sleep(1);
 204:	4505                	li	a0,1
 206:	00000097          	auipc	ra,0x0
 20a:	378080e7          	jalr	888(ra) # 57e <sleep>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 20e:	f9840593          	addi	a1,s0,-104
 212:	557d                	li	a0,-1
 214:	00000097          	auipc	ra,0x0
 218:	3aa080e7          	jalr	938(ra) # 5be <pinfo>
 21c:	04054463          	bltz	a0,264 <main+0x264>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
 220:	fc843783          	ld	a5,-56(s0)
 224:	e43e                	sd	a5,8(sp)
 226:	fc042783          	lw	a5,-64(s0)
 22a:	e03e                	sd	a5,0(sp)
 22c:	fbc42883          	lw	a7,-68(s0)
 230:	fb842803          	lw	a6,-72(s0)
 234:	fa840793          	addi	a5,s0,-88
 238:	fa040713          	addi	a4,s0,-96
 23c:	f9c42683          	lw	a3,-100(s0)
 240:	f9842603          	lw	a2,-104(s0)
 244:	00001597          	auipc	a1,0x1
 248:	90c58593          	addi	a1,a1,-1780 # b50 <malloc+0x1c8>
 24c:	4505                	li	a0,1
 24e:	00000097          	auipc	ra,0x0
 252:	64e080e7          	jalr	1614(ra) # 89c <fprintf>
 256:	bf1d                	j	18c <main+0x18c>
     if (!n) sleep(m);
 258:	854a                	mv	a0,s2
 25a:	00000097          	auipc	ra,0x0
 25e:	324080e7          	jalr	804(ra) # 57e <sleep>
 262:	b759                	j	1e8 <main+0x1e8>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 264:	00001597          	auipc	a1,0x1
 268:	88458593          	addi	a1,a1,-1916 # ae8 <malloc+0x160>
 26c:	4505                	li	a0,1
 26e:	00000097          	auipc	ra,0x0
 272:	62e080e7          	jalr	1582(ra) # 89c <fprintf>
 276:	bf19                	j	18c <main+0x18c>

0000000000000278 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 27e:	87aa                	mv	a5,a0
 280:	0585                	addi	a1,a1,1
 282:	0785                	addi	a5,a5,1
 284:	fff5c703          	lbu	a4,-1(a1)
 288:	fee78fa3          	sb	a4,-1(a5)
 28c:	fb75                	bnez	a4,280 <strcpy+0x8>
    ;
  return os;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29a:	00054783          	lbu	a5,0(a0)
 29e:	cb91                	beqz	a5,2b2 <strcmp+0x1e>
 2a0:	0005c703          	lbu	a4,0(a1)
 2a4:	00f71763          	bne	a4,a5,2b2 <strcmp+0x1e>
    p++, q++;
 2a8:	0505                	addi	a0,a0,1
 2aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	fbe5                	bnez	a5,2a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b2:	0005c503          	lbu	a0,0(a1)
}
 2b6:	40a7853b          	subw	a0,a5,a0
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <strlen>:

uint
strlen(const char *s)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	cf91                	beqz	a5,2e6 <strlen+0x26>
 2cc:	0505                	addi	a0,a0,1
 2ce:	87aa                	mv	a5,a0
 2d0:	4685                	li	a3,1
 2d2:	9e89                	subw	a3,a3,a0
 2d4:	00f6853b          	addw	a0,a3,a5
 2d8:	0785                	addi	a5,a5,1
 2da:	fff7c703          	lbu	a4,-1(a5)
 2de:	fb7d                	bnez	a4,2d4 <strlen+0x14>
    ;
  return n;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
  for(n = 0; s[n]; n++)
 2e6:	4501                	li	a0,0
 2e8:	bfe5                	j	2e0 <strlen+0x20>

00000000000002ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f0:	ce09                	beqz	a2,30a <memset+0x20>
 2f2:	87aa                	mv	a5,a0
 2f4:	fff6071b          	addiw	a4,a2,-1
 2f8:	1702                	slli	a4,a4,0x20
 2fa:	9301                	srli	a4,a4,0x20
 2fc:	0705                	addi	a4,a4,1
 2fe:	972a                	add	a4,a4,a0
    cdst[i] = c;
 300:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 304:	0785                	addi	a5,a5,1
 306:	fee79de3          	bne	a5,a4,300 <memset+0x16>
  }
  return dst;
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret

0000000000000310 <strchr>:

char*
strchr(const char *s, char c)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  for(; *s; s++)
 316:	00054783          	lbu	a5,0(a0)
 31a:	cb99                	beqz	a5,330 <strchr+0x20>
    if(*s == c)
 31c:	00f58763          	beq	a1,a5,32a <strchr+0x1a>
  for(; *s; s++)
 320:	0505                	addi	a0,a0,1
 322:	00054783          	lbu	a5,0(a0)
 326:	fbfd                	bnez	a5,31c <strchr+0xc>
      return (char*)s;
  return 0;
 328:	4501                	li	a0,0
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  return 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <strchr+0x1a>

0000000000000334 <gets>:

char*
gets(char *buf, int max)
{
 334:	711d                	addi	sp,sp,-96
 336:	ec86                	sd	ra,88(sp)
 338:	e8a2                	sd	s0,80(sp)
 33a:	e4a6                	sd	s1,72(sp)
 33c:	e0ca                	sd	s2,64(sp)
 33e:	fc4e                	sd	s3,56(sp)
 340:	f852                	sd	s4,48(sp)
 342:	f456                	sd	s5,40(sp)
 344:	f05a                	sd	s6,32(sp)
 346:	ec5e                	sd	s7,24(sp)
 348:	1080                	addi	s0,sp,96
 34a:	8baa                	mv	s7,a0
 34c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34e:	892a                	mv	s2,a0
 350:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 352:	4aa9                	li	s5,10
 354:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 356:	89a6                	mv	s3,s1
 358:	2485                	addiw	s1,s1,1
 35a:	0344d863          	bge	s1,s4,38a <gets+0x56>
    cc = read(0, &c, 1);
 35e:	4605                	li	a2,1
 360:	faf40593          	addi	a1,s0,-81
 364:	4501                	li	a0,0
 366:	00000097          	auipc	ra,0x0
 36a:	1a0080e7          	jalr	416(ra) # 506 <read>
    if(cc < 1)
 36e:	00a05e63          	blez	a0,38a <gets+0x56>
    buf[i++] = c;
 372:	faf44783          	lbu	a5,-81(s0)
 376:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 37a:	01578763          	beq	a5,s5,388 <gets+0x54>
 37e:	0905                	addi	s2,s2,1
 380:	fd679be3          	bne	a5,s6,356 <gets+0x22>
  for(i=0; i+1 < max; ){
 384:	89a6                	mv	s3,s1
 386:	a011                	j	38a <gets+0x56>
 388:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 38a:	99de                	add	s3,s3,s7
 38c:	00098023          	sb	zero,0(s3)
  return buf;
}
 390:	855e                	mv	a0,s7
 392:	60e6                	ld	ra,88(sp)
 394:	6446                	ld	s0,80(sp)
 396:	64a6                	ld	s1,72(sp)
 398:	6906                	ld	s2,64(sp)
 39a:	79e2                	ld	s3,56(sp)
 39c:	7a42                	ld	s4,48(sp)
 39e:	7aa2                	ld	s5,40(sp)
 3a0:	7b02                	ld	s6,32(sp)
 3a2:	6be2                	ld	s7,24(sp)
 3a4:	6125                	addi	sp,sp,96
 3a6:	8082                	ret

00000000000003a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a8:	1101                	addi	sp,sp,-32
 3aa:	ec06                	sd	ra,24(sp)
 3ac:	e822                	sd	s0,16(sp)
 3ae:	e426                	sd	s1,8(sp)
 3b0:	e04a                	sd	s2,0(sp)
 3b2:	1000                	addi	s0,sp,32
 3b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b6:	4581                	li	a1,0
 3b8:	00000097          	auipc	ra,0x0
 3bc:	176080e7          	jalr	374(ra) # 52e <open>
  if(fd < 0)
 3c0:	02054563          	bltz	a0,3ea <stat+0x42>
 3c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3c6:	85ca                	mv	a1,s2
 3c8:	00000097          	auipc	ra,0x0
 3cc:	17e080e7          	jalr	382(ra) # 546 <fstat>
 3d0:	892a                	mv	s2,a0
  close(fd);
 3d2:	8526                	mv	a0,s1
 3d4:	00000097          	auipc	ra,0x0
 3d8:	142080e7          	jalr	322(ra) # 516 <close>
  return r;
}
 3dc:	854a                	mv	a0,s2
 3de:	60e2                	ld	ra,24(sp)
 3e0:	6442                	ld	s0,16(sp)
 3e2:	64a2                	ld	s1,8(sp)
 3e4:	6902                	ld	s2,0(sp)
 3e6:	6105                	addi	sp,sp,32
 3e8:	8082                	ret
    return -1;
 3ea:	597d                	li	s2,-1
 3ec:	bfc5                	j	3dc <stat+0x34>

00000000000003ee <atoi>:

int
atoi(const char *s)
{
 3ee:	1141                	addi	sp,sp,-16
 3f0:	e422                	sd	s0,8(sp)
 3f2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f4:	00054603          	lbu	a2,0(a0)
 3f8:	fd06079b          	addiw	a5,a2,-48
 3fc:	0ff7f793          	andi	a5,a5,255
 400:	4725                	li	a4,9
 402:	02f76963          	bltu	a4,a5,434 <atoi+0x46>
 406:	86aa                	mv	a3,a0
  n = 0;
 408:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 40a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 40c:	0685                	addi	a3,a3,1
 40e:	0025179b          	slliw	a5,a0,0x2
 412:	9fa9                	addw	a5,a5,a0
 414:	0017979b          	slliw	a5,a5,0x1
 418:	9fb1                	addw	a5,a5,a2
 41a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 41e:	0006c603          	lbu	a2,0(a3)
 422:	fd06071b          	addiw	a4,a2,-48
 426:	0ff77713          	andi	a4,a4,255
 42a:	fee5f1e3          	bgeu	a1,a4,40c <atoi+0x1e>
  return n;
}
 42e:	6422                	ld	s0,8(sp)
 430:	0141                	addi	sp,sp,16
 432:	8082                	ret
  n = 0;
 434:	4501                	li	a0,0
 436:	bfe5                	j	42e <atoi+0x40>

0000000000000438 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 438:	1141                	addi	sp,sp,-16
 43a:	e422                	sd	s0,8(sp)
 43c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 43e:	02b57663          	bgeu	a0,a1,46a <memmove+0x32>
    while(n-- > 0)
 442:	02c05163          	blez	a2,464 <memmove+0x2c>
 446:	fff6079b          	addiw	a5,a2,-1
 44a:	1782                	slli	a5,a5,0x20
 44c:	9381                	srli	a5,a5,0x20
 44e:	0785                	addi	a5,a5,1
 450:	97aa                	add	a5,a5,a0
  dst = vdst;
 452:	872a                	mv	a4,a0
      *dst++ = *src++;
 454:	0585                	addi	a1,a1,1
 456:	0705                	addi	a4,a4,1
 458:	fff5c683          	lbu	a3,-1(a1)
 45c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 460:	fee79ae3          	bne	a5,a4,454 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 464:	6422                	ld	s0,8(sp)
 466:	0141                	addi	sp,sp,16
 468:	8082                	ret
    dst += n;
 46a:	00c50733          	add	a4,a0,a2
    src += n;
 46e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 470:	fec05ae3          	blez	a2,464 <memmove+0x2c>
 474:	fff6079b          	addiw	a5,a2,-1
 478:	1782                	slli	a5,a5,0x20
 47a:	9381                	srli	a5,a5,0x20
 47c:	fff7c793          	not	a5,a5
 480:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 482:	15fd                	addi	a1,a1,-1
 484:	177d                	addi	a4,a4,-1
 486:	0005c683          	lbu	a3,0(a1)
 48a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 48e:	fee79ae3          	bne	a5,a4,482 <memmove+0x4a>
 492:	bfc9                	j	464 <memmove+0x2c>

0000000000000494 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 494:	1141                	addi	sp,sp,-16
 496:	e422                	sd	s0,8(sp)
 498:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 49a:	ca05                	beqz	a2,4ca <memcmp+0x36>
 49c:	fff6069b          	addiw	a3,a2,-1
 4a0:	1682                	slli	a3,a3,0x20
 4a2:	9281                	srli	a3,a3,0x20
 4a4:	0685                	addi	a3,a3,1
 4a6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4a8:	00054783          	lbu	a5,0(a0)
 4ac:	0005c703          	lbu	a4,0(a1)
 4b0:	00e79863          	bne	a5,a4,4c0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4b4:	0505                	addi	a0,a0,1
    p2++;
 4b6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4b8:	fed518e3          	bne	a0,a3,4a8 <memcmp+0x14>
  }
  return 0;
 4bc:	4501                	li	a0,0
 4be:	a019                	j	4c4 <memcmp+0x30>
      return *p1 - *p2;
 4c0:	40e7853b          	subw	a0,a5,a4
}
 4c4:	6422                	ld	s0,8(sp)
 4c6:	0141                	addi	sp,sp,16
 4c8:	8082                	ret
  return 0;
 4ca:	4501                	li	a0,0
 4cc:	bfe5                	j	4c4 <memcmp+0x30>

00000000000004ce <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ce:	1141                	addi	sp,sp,-16
 4d0:	e406                	sd	ra,8(sp)
 4d2:	e022                	sd	s0,0(sp)
 4d4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4d6:	00000097          	auipc	ra,0x0
 4da:	f62080e7          	jalr	-158(ra) # 438 <memmove>
}
 4de:	60a2                	ld	ra,8(sp)
 4e0:	6402                	ld	s0,0(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret

00000000000004e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4e6:	4885                	li	a7,1
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ee:	4889                	li	a7,2
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4f6:	488d                	li	a7,3
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4fe:	4891                	li	a7,4
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <read>:
.global read
read:
 li a7, SYS_read
 506:	4895                	li	a7,5
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <write>:
.global write
write:
 li a7, SYS_write
 50e:	48c1                	li	a7,16
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <close>:
.global close
close:
 li a7, SYS_close
 516:	48d5                	li	a7,21
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <kill>:
.global kill
kill:
 li a7, SYS_kill
 51e:	4899                	li	a7,6
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <exec>:
.global exec
exec:
 li a7, SYS_exec
 526:	489d                	li	a7,7
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <open>:
.global open
open:
 li a7, SYS_open
 52e:	48bd                	li	a7,15
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 536:	48c5                	li	a7,17
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 53e:	48c9                	li	a7,18
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 546:	48a1                	li	a7,8
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <link>:
.global link
link:
 li a7, SYS_link
 54e:	48cd                	li	a7,19
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 556:	48d1                	li	a7,20
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 55e:	48a5                	li	a7,9
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <dup>:
.global dup
dup:
 li a7, SYS_dup
 566:	48a9                	li	a7,10
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 56e:	48ad                	li	a7,11
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 576:	48b1                	li	a7,12
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 57e:	48b5                	li	a7,13
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 586:	48b9                	li	a7,14
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 58e:	48d9                	li	a7,22
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <yield>:
.global yield
yield:
 li a7, SYS_yield
 596:	48dd                	li	a7,23
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 59e:	48e1                	li	a7,24
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 5a6:	48e5                	li	a7,25
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 5ae:	48e9                	li	a7,26
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <ps>:
.global ps
ps:
 li a7, SYS_ps
 5b6:	48ed                	li	a7,27
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 5be:	48f1                	li	a7,28
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 5c6:	48f5                	li	a7,29
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 5ce:	48f9                	li	a7,30
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 5d6:	48fd                	li	a7,31
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 5de:	02000893          	li	a7,32
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 5e8:	02100893          	li	a7,33
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5f2:	1101                	addi	sp,sp,-32
 5f4:	ec06                	sd	ra,24(sp)
 5f6:	e822                	sd	s0,16(sp)
 5f8:	1000                	addi	s0,sp,32
 5fa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5fe:	4605                	li	a2,1
 600:	fef40593          	addi	a1,s0,-17
 604:	00000097          	auipc	ra,0x0
 608:	f0a080e7          	jalr	-246(ra) # 50e <write>
}
 60c:	60e2                	ld	ra,24(sp)
 60e:	6442                	ld	s0,16(sp)
 610:	6105                	addi	sp,sp,32
 612:	8082                	ret

0000000000000614 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 614:	7139                	addi	sp,sp,-64
 616:	fc06                	sd	ra,56(sp)
 618:	f822                	sd	s0,48(sp)
 61a:	f426                	sd	s1,40(sp)
 61c:	f04a                	sd	s2,32(sp)
 61e:	ec4e                	sd	s3,24(sp)
 620:	0080                	addi	s0,sp,64
 622:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 624:	c299                	beqz	a3,62a <printint+0x16>
 626:	0805c863          	bltz	a1,6b6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 62a:	2581                	sext.w	a1,a1
  neg = 0;
 62c:	4881                	li	a7,0
 62e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 632:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 634:	2601                	sext.w	a2,a2
 636:	00000517          	auipc	a0,0x0
 63a:	5a250513          	addi	a0,a0,1442 # bd8 <digits>
 63e:	883a                	mv	a6,a4
 640:	2705                	addiw	a4,a4,1
 642:	02c5f7bb          	remuw	a5,a1,a2
 646:	1782                	slli	a5,a5,0x20
 648:	9381                	srli	a5,a5,0x20
 64a:	97aa                	add	a5,a5,a0
 64c:	0007c783          	lbu	a5,0(a5)
 650:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 654:	0005879b          	sext.w	a5,a1
 658:	02c5d5bb          	divuw	a1,a1,a2
 65c:	0685                	addi	a3,a3,1
 65e:	fec7f0e3          	bgeu	a5,a2,63e <printint+0x2a>
  if(neg)
 662:	00088b63          	beqz	a7,678 <printint+0x64>
    buf[i++] = '-';
 666:	fd040793          	addi	a5,s0,-48
 66a:	973e                	add	a4,a4,a5
 66c:	02d00793          	li	a5,45
 670:	fef70823          	sb	a5,-16(a4)
 674:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 678:	02e05863          	blez	a4,6a8 <printint+0x94>
 67c:	fc040793          	addi	a5,s0,-64
 680:	00e78933          	add	s2,a5,a4
 684:	fff78993          	addi	s3,a5,-1
 688:	99ba                	add	s3,s3,a4
 68a:	377d                	addiw	a4,a4,-1
 68c:	1702                	slli	a4,a4,0x20
 68e:	9301                	srli	a4,a4,0x20
 690:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 694:	fff94583          	lbu	a1,-1(s2)
 698:	8526                	mv	a0,s1
 69a:	00000097          	auipc	ra,0x0
 69e:	f58080e7          	jalr	-168(ra) # 5f2 <putc>
  while(--i >= 0)
 6a2:	197d                	addi	s2,s2,-1
 6a4:	ff3918e3          	bne	s2,s3,694 <printint+0x80>
}
 6a8:	70e2                	ld	ra,56(sp)
 6aa:	7442                	ld	s0,48(sp)
 6ac:	74a2                	ld	s1,40(sp)
 6ae:	7902                	ld	s2,32(sp)
 6b0:	69e2                	ld	s3,24(sp)
 6b2:	6121                	addi	sp,sp,64
 6b4:	8082                	ret
    x = -xx;
 6b6:	40b005bb          	negw	a1,a1
    neg = 1;
 6ba:	4885                	li	a7,1
    x = -xx;
 6bc:	bf8d                	j	62e <printint+0x1a>

00000000000006be <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6be:	7119                	addi	sp,sp,-128
 6c0:	fc86                	sd	ra,120(sp)
 6c2:	f8a2                	sd	s0,112(sp)
 6c4:	f4a6                	sd	s1,104(sp)
 6c6:	f0ca                	sd	s2,96(sp)
 6c8:	ecce                	sd	s3,88(sp)
 6ca:	e8d2                	sd	s4,80(sp)
 6cc:	e4d6                	sd	s5,72(sp)
 6ce:	e0da                	sd	s6,64(sp)
 6d0:	fc5e                	sd	s7,56(sp)
 6d2:	f862                	sd	s8,48(sp)
 6d4:	f466                	sd	s9,40(sp)
 6d6:	f06a                	sd	s10,32(sp)
 6d8:	ec6e                	sd	s11,24(sp)
 6da:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6dc:	0005c903          	lbu	s2,0(a1)
 6e0:	18090f63          	beqz	s2,87e <vprintf+0x1c0>
 6e4:	8aaa                	mv	s5,a0
 6e6:	8b32                	mv	s6,a2
 6e8:	00158493          	addi	s1,a1,1
  state = 0;
 6ec:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6ee:	02500a13          	li	s4,37
      if(c == 'd'){
 6f2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 6f6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6fa:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6fe:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 702:	00000b97          	auipc	s7,0x0
 706:	4d6b8b93          	addi	s7,s7,1238 # bd8 <digits>
 70a:	a839                	j	728 <vprintf+0x6a>
        putc(fd, c);
 70c:	85ca                	mv	a1,s2
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	ee2080e7          	jalr	-286(ra) # 5f2 <putc>
 718:	a019                	j	71e <vprintf+0x60>
    } else if(state == '%'){
 71a:	01498f63          	beq	s3,s4,738 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 71e:	0485                	addi	s1,s1,1
 720:	fff4c903          	lbu	s2,-1(s1)
 724:	14090d63          	beqz	s2,87e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 728:	0009079b          	sext.w	a5,s2
    if(state == 0){
 72c:	fe0997e3          	bnez	s3,71a <vprintf+0x5c>
      if(c == '%'){
 730:	fd479ee3          	bne	a5,s4,70c <vprintf+0x4e>
        state = '%';
 734:	89be                	mv	s3,a5
 736:	b7e5                	j	71e <vprintf+0x60>
      if(c == 'd'){
 738:	05878063          	beq	a5,s8,778 <vprintf+0xba>
      } else if(c == 'l') {
 73c:	05978c63          	beq	a5,s9,794 <vprintf+0xd6>
      } else if(c == 'x') {
 740:	07a78863          	beq	a5,s10,7b0 <vprintf+0xf2>
      } else if(c == 'p') {
 744:	09b78463          	beq	a5,s11,7cc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 748:	07300713          	li	a4,115
 74c:	0ce78663          	beq	a5,a4,818 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 750:	06300713          	li	a4,99
 754:	0ee78e63          	beq	a5,a4,850 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 758:	11478863          	beq	a5,s4,868 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 75c:	85d2                	mv	a1,s4
 75e:	8556                	mv	a0,s5
 760:	00000097          	auipc	ra,0x0
 764:	e92080e7          	jalr	-366(ra) # 5f2 <putc>
        putc(fd, c);
 768:	85ca                	mv	a1,s2
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	e86080e7          	jalr	-378(ra) # 5f2 <putc>
      }
      state = 0;
 774:	4981                	li	s3,0
 776:	b765                	j	71e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 778:	008b0913          	addi	s2,s6,8
 77c:	4685                	li	a3,1
 77e:	4629                	li	a2,10
 780:	000b2583          	lw	a1,0(s6)
 784:	8556                	mv	a0,s5
 786:	00000097          	auipc	ra,0x0
 78a:	e8e080e7          	jalr	-370(ra) # 614 <printint>
 78e:	8b4a                	mv	s6,s2
      state = 0;
 790:	4981                	li	s3,0
 792:	b771                	j	71e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 794:	008b0913          	addi	s2,s6,8
 798:	4681                	li	a3,0
 79a:	4629                	li	a2,10
 79c:	000b2583          	lw	a1,0(s6)
 7a0:	8556                	mv	a0,s5
 7a2:	00000097          	auipc	ra,0x0
 7a6:	e72080e7          	jalr	-398(ra) # 614 <printint>
 7aa:	8b4a                	mv	s6,s2
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	bf85                	j	71e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7b0:	008b0913          	addi	s2,s6,8
 7b4:	4681                	li	a3,0
 7b6:	4641                	li	a2,16
 7b8:	000b2583          	lw	a1,0(s6)
 7bc:	8556                	mv	a0,s5
 7be:	00000097          	auipc	ra,0x0
 7c2:	e56080e7          	jalr	-426(ra) # 614 <printint>
 7c6:	8b4a                	mv	s6,s2
      state = 0;
 7c8:	4981                	li	s3,0
 7ca:	bf91                	j	71e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7cc:	008b0793          	addi	a5,s6,8
 7d0:	f8f43423          	sd	a5,-120(s0)
 7d4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7d8:	03000593          	li	a1,48
 7dc:	8556                	mv	a0,s5
 7de:	00000097          	auipc	ra,0x0
 7e2:	e14080e7          	jalr	-492(ra) # 5f2 <putc>
  putc(fd, 'x');
 7e6:	85ea                	mv	a1,s10
 7e8:	8556                	mv	a0,s5
 7ea:	00000097          	auipc	ra,0x0
 7ee:	e08080e7          	jalr	-504(ra) # 5f2 <putc>
 7f2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7f4:	03c9d793          	srli	a5,s3,0x3c
 7f8:	97de                	add	a5,a5,s7
 7fa:	0007c583          	lbu	a1,0(a5)
 7fe:	8556                	mv	a0,s5
 800:	00000097          	auipc	ra,0x0
 804:	df2080e7          	jalr	-526(ra) # 5f2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 808:	0992                	slli	s3,s3,0x4
 80a:	397d                	addiw	s2,s2,-1
 80c:	fe0914e3          	bnez	s2,7f4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 810:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 814:	4981                	li	s3,0
 816:	b721                	j	71e <vprintf+0x60>
        s = va_arg(ap, char*);
 818:	008b0993          	addi	s3,s6,8
 81c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 820:	02090163          	beqz	s2,842 <vprintf+0x184>
        while(*s != 0){
 824:	00094583          	lbu	a1,0(s2)
 828:	c9a1                	beqz	a1,878 <vprintf+0x1ba>
          putc(fd, *s);
 82a:	8556                	mv	a0,s5
 82c:	00000097          	auipc	ra,0x0
 830:	dc6080e7          	jalr	-570(ra) # 5f2 <putc>
          s++;
 834:	0905                	addi	s2,s2,1
        while(*s != 0){
 836:	00094583          	lbu	a1,0(s2)
 83a:	f9e5                	bnez	a1,82a <vprintf+0x16c>
        s = va_arg(ap, char*);
 83c:	8b4e                	mv	s6,s3
      state = 0;
 83e:	4981                	li	s3,0
 840:	bdf9                	j	71e <vprintf+0x60>
          s = "(null)";
 842:	00000917          	auipc	s2,0x0
 846:	38e90913          	addi	s2,s2,910 # bd0 <malloc+0x248>
        while(*s != 0){
 84a:	02800593          	li	a1,40
 84e:	bff1                	j	82a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 850:	008b0913          	addi	s2,s6,8
 854:	000b4583          	lbu	a1,0(s6)
 858:	8556                	mv	a0,s5
 85a:	00000097          	auipc	ra,0x0
 85e:	d98080e7          	jalr	-616(ra) # 5f2 <putc>
 862:	8b4a                	mv	s6,s2
      state = 0;
 864:	4981                	li	s3,0
 866:	bd65                	j	71e <vprintf+0x60>
        putc(fd, c);
 868:	85d2                	mv	a1,s4
 86a:	8556                	mv	a0,s5
 86c:	00000097          	auipc	ra,0x0
 870:	d86080e7          	jalr	-634(ra) # 5f2 <putc>
      state = 0;
 874:	4981                	li	s3,0
 876:	b565                	j	71e <vprintf+0x60>
        s = va_arg(ap, char*);
 878:	8b4e                	mv	s6,s3
      state = 0;
 87a:	4981                	li	s3,0
 87c:	b54d                	j	71e <vprintf+0x60>
    }
  }
}
 87e:	70e6                	ld	ra,120(sp)
 880:	7446                	ld	s0,112(sp)
 882:	74a6                	ld	s1,104(sp)
 884:	7906                	ld	s2,96(sp)
 886:	69e6                	ld	s3,88(sp)
 888:	6a46                	ld	s4,80(sp)
 88a:	6aa6                	ld	s5,72(sp)
 88c:	6b06                	ld	s6,64(sp)
 88e:	7be2                	ld	s7,56(sp)
 890:	7c42                	ld	s8,48(sp)
 892:	7ca2                	ld	s9,40(sp)
 894:	7d02                	ld	s10,32(sp)
 896:	6de2                	ld	s11,24(sp)
 898:	6109                	addi	sp,sp,128
 89a:	8082                	ret

000000000000089c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 89c:	715d                	addi	sp,sp,-80
 89e:	ec06                	sd	ra,24(sp)
 8a0:	e822                	sd	s0,16(sp)
 8a2:	1000                	addi	s0,sp,32
 8a4:	e010                	sd	a2,0(s0)
 8a6:	e414                	sd	a3,8(s0)
 8a8:	e818                	sd	a4,16(s0)
 8aa:	ec1c                	sd	a5,24(s0)
 8ac:	03043023          	sd	a6,32(s0)
 8b0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8b4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8b8:	8622                	mv	a2,s0
 8ba:	00000097          	auipc	ra,0x0
 8be:	e04080e7          	jalr	-508(ra) # 6be <vprintf>
}
 8c2:	60e2                	ld	ra,24(sp)
 8c4:	6442                	ld	s0,16(sp)
 8c6:	6161                	addi	sp,sp,80
 8c8:	8082                	ret

00000000000008ca <printf>:

void
printf(const char *fmt, ...)
{
 8ca:	711d                	addi	sp,sp,-96
 8cc:	ec06                	sd	ra,24(sp)
 8ce:	e822                	sd	s0,16(sp)
 8d0:	1000                	addi	s0,sp,32
 8d2:	e40c                	sd	a1,8(s0)
 8d4:	e810                	sd	a2,16(s0)
 8d6:	ec14                	sd	a3,24(s0)
 8d8:	f018                	sd	a4,32(s0)
 8da:	f41c                	sd	a5,40(s0)
 8dc:	03043823          	sd	a6,48(s0)
 8e0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e4:	00840613          	addi	a2,s0,8
 8e8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ec:	85aa                	mv	a1,a0
 8ee:	4505                	li	a0,1
 8f0:	00000097          	auipc	ra,0x0
 8f4:	dce080e7          	jalr	-562(ra) # 6be <vprintf>
}
 8f8:	60e2                	ld	ra,24(sp)
 8fa:	6442                	ld	s0,16(sp)
 8fc:	6125                	addi	sp,sp,96
 8fe:	8082                	ret

0000000000000900 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 900:	1141                	addi	sp,sp,-16
 902:	e422                	sd	s0,8(sp)
 904:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 906:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90a:	00000797          	auipc	a5,0x0
 90e:	2e67b783          	ld	a5,742(a5) # bf0 <freep>
 912:	a805                	j	942 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 914:	4618                	lw	a4,8(a2)
 916:	9db9                	addw	a1,a1,a4
 918:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 91c:	6398                	ld	a4,0(a5)
 91e:	6318                	ld	a4,0(a4)
 920:	fee53823          	sd	a4,-16(a0)
 924:	a091                	j	968 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 926:	ff852703          	lw	a4,-8(a0)
 92a:	9e39                	addw	a2,a2,a4
 92c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 92e:	ff053703          	ld	a4,-16(a0)
 932:	e398                	sd	a4,0(a5)
 934:	a099                	j	97a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 936:	6398                	ld	a4,0(a5)
 938:	00e7e463          	bltu	a5,a4,940 <free+0x40>
 93c:	00e6ea63          	bltu	a3,a4,950 <free+0x50>
{
 940:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 942:	fed7fae3          	bgeu	a5,a3,936 <free+0x36>
 946:	6398                	ld	a4,0(a5)
 948:	00e6e463          	bltu	a3,a4,950 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 94c:	fee7eae3          	bltu	a5,a4,940 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 950:	ff852583          	lw	a1,-8(a0)
 954:	6390                	ld	a2,0(a5)
 956:	02059713          	slli	a4,a1,0x20
 95a:	9301                	srli	a4,a4,0x20
 95c:	0712                	slli	a4,a4,0x4
 95e:	9736                	add	a4,a4,a3
 960:	fae60ae3          	beq	a2,a4,914 <free+0x14>
    bp->s.ptr = p->s.ptr;
 964:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 968:	4790                	lw	a2,8(a5)
 96a:	02061713          	slli	a4,a2,0x20
 96e:	9301                	srli	a4,a4,0x20
 970:	0712                	slli	a4,a4,0x4
 972:	973e                	add	a4,a4,a5
 974:	fae689e3          	beq	a3,a4,926 <free+0x26>
  } else
    p->s.ptr = bp;
 978:	e394                	sd	a3,0(a5)
  freep = p;
 97a:	00000717          	auipc	a4,0x0
 97e:	26f73b23          	sd	a5,630(a4) # bf0 <freep>
}
 982:	6422                	ld	s0,8(sp)
 984:	0141                	addi	sp,sp,16
 986:	8082                	ret

0000000000000988 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 988:	7139                	addi	sp,sp,-64
 98a:	fc06                	sd	ra,56(sp)
 98c:	f822                	sd	s0,48(sp)
 98e:	f426                	sd	s1,40(sp)
 990:	f04a                	sd	s2,32(sp)
 992:	ec4e                	sd	s3,24(sp)
 994:	e852                	sd	s4,16(sp)
 996:	e456                	sd	s5,8(sp)
 998:	e05a                	sd	s6,0(sp)
 99a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 99c:	02051493          	slli	s1,a0,0x20
 9a0:	9081                	srli	s1,s1,0x20
 9a2:	04bd                	addi	s1,s1,15
 9a4:	8091                	srli	s1,s1,0x4
 9a6:	0014899b          	addiw	s3,s1,1
 9aa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9ac:	00000517          	auipc	a0,0x0
 9b0:	24453503          	ld	a0,580(a0) # bf0 <freep>
 9b4:	c515                	beqz	a0,9e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b8:	4798                	lw	a4,8(a5)
 9ba:	02977f63          	bgeu	a4,s1,9f8 <malloc+0x70>
 9be:	8a4e                	mv	s4,s3
 9c0:	0009871b          	sext.w	a4,s3
 9c4:	6685                	lui	a3,0x1
 9c6:	00d77363          	bgeu	a4,a3,9cc <malloc+0x44>
 9ca:	6a05                	lui	s4,0x1
 9cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9d0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9d4:	00000917          	auipc	s2,0x0
 9d8:	21c90913          	addi	s2,s2,540 # bf0 <freep>
  if(p == (char*)-1)
 9dc:	5afd                	li	s5,-1
 9de:	a88d                	j	a50 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 9e0:	00000797          	auipc	a5,0x0
 9e4:	21878793          	addi	a5,a5,536 # bf8 <base>
 9e8:	00000717          	auipc	a4,0x0
 9ec:	20f73423          	sd	a5,520(a4) # bf0 <freep>
 9f0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9f2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9f6:	b7e1                	j	9be <malloc+0x36>
      if(p->s.size == nunits)
 9f8:	02e48b63          	beq	s1,a4,a2e <malloc+0xa6>
        p->s.size -= nunits;
 9fc:	4137073b          	subw	a4,a4,s3
 a00:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a02:	1702                	slli	a4,a4,0x20
 a04:	9301                	srli	a4,a4,0x20
 a06:	0712                	slli	a4,a4,0x4
 a08:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a0a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a0e:	00000717          	auipc	a4,0x0
 a12:	1ea73123          	sd	a0,482(a4) # bf0 <freep>
      return (void*)(p + 1);
 a16:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a1a:	70e2                	ld	ra,56(sp)
 a1c:	7442                	ld	s0,48(sp)
 a1e:	74a2                	ld	s1,40(sp)
 a20:	7902                	ld	s2,32(sp)
 a22:	69e2                	ld	s3,24(sp)
 a24:	6a42                	ld	s4,16(sp)
 a26:	6aa2                	ld	s5,8(sp)
 a28:	6b02                	ld	s6,0(sp)
 a2a:	6121                	addi	sp,sp,64
 a2c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a2e:	6398                	ld	a4,0(a5)
 a30:	e118                	sd	a4,0(a0)
 a32:	bff1                	j	a0e <malloc+0x86>
  hp->s.size = nu;
 a34:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a38:	0541                	addi	a0,a0,16
 a3a:	00000097          	auipc	ra,0x0
 a3e:	ec6080e7          	jalr	-314(ra) # 900 <free>
  return freep;
 a42:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a46:	d971                	beqz	a0,a1a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a48:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a4a:	4798                	lw	a4,8(a5)
 a4c:	fa9776e3          	bgeu	a4,s1,9f8 <malloc+0x70>
    if(p == freep)
 a50:	00093703          	ld	a4,0(s2)
 a54:	853e                	mv	a0,a5
 a56:	fef719e3          	bne	a4,a5,a48 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a5a:	8552                	mv	a0,s4
 a5c:	00000097          	auipc	ra,0x0
 a60:	b1a080e7          	jalr	-1254(ra) # 576 <sbrk>
  if(p == (char*)-1)
 a64:	fd5518e3          	bne	a0,s5,a34 <malloc+0xac>
        return 0;
 a68:	4501                	li	a0,0
 a6a:	bf45                	j	a1a <malloc+0x92>
