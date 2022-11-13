
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dd010113          	addi	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	addi	s0,sp,560
  int fd, i;
  char path[] = "stressfs0";
  16:	00001797          	auipc	a5,0x1
  1a:	91a78793          	addi	a5,a5,-1766 # 930 <malloc+0x114>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	8d450513          	addi	a0,a0,-1836 # 900 <malloc+0xe4>
  34:	00000097          	auipc	ra,0x0
  38:	72a080e7          	jalr	1834(ra) # 75e <printf>
  memset(data, 'a', sizeof(data));
  3c:	20000613          	li	a2,512
  40:	06100593          	li	a1,97
  44:	dd040513          	addi	a0,s0,-560
  48:	00000097          	auipc	ra,0x0
  4c:	136080e7          	jalr	310(ra) # 17e <memset>

  for(i = 0; i < 4; i++)
  50:	4481                	li	s1,0
  52:	4911                	li	s2,4
    if(fork() > 0)
  54:	00000097          	auipc	ra,0x0
  58:	326080e7          	jalr	806(ra) # 37a <fork>
  5c:	00a04563          	bgtz	a0,66 <main+0x66>
  for(i = 0; i < 4; i++)
  60:	2485                	addiw	s1,s1,1
  62:	ff2499e3          	bne	s1,s2,54 <main+0x54>
      break;

  printf("write %d\n", i);
  66:	85a6                	mv	a1,s1
  68:	00001517          	auipc	a0,0x1
  6c:	8b050513          	addi	a0,a0,-1872 # 918 <malloc+0xfc>
  70:	00000097          	auipc	ra,0x0
  74:	6ee080e7          	jalr	1774(ra) # 75e <printf>

  path[8] += i;
  78:	fd844783          	lbu	a5,-40(s0)
  7c:	9cbd                	addw	s1,s1,a5
  7e:	fc940c23          	sb	s1,-40(s0)
  fd = open(path, O_CREATE | O_RDWR);
  82:	20200593          	li	a1,514
  86:	fd040513          	addi	a0,s0,-48
  8a:	00000097          	auipc	ra,0x0
  8e:	338080e7          	jalr	824(ra) # 3c2 <open>
  92:	892a                	mv	s2,a0
  94:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  96:	20000613          	li	a2,512
  9a:	dd040593          	addi	a1,s0,-560
  9e:	854a                	mv	a0,s2
  a0:	00000097          	auipc	ra,0x0
  a4:	302080e7          	jalr	770(ra) # 3a2 <write>
  for(i = 0; i < 20; i++)
  a8:	34fd                	addiw	s1,s1,-1
  aa:	f4f5                	bnez	s1,96 <main+0x96>
  close(fd);
  ac:	854a                	mv	a0,s2
  ae:	00000097          	auipc	ra,0x0
  b2:	2fc080e7          	jalr	764(ra) # 3aa <close>

  printf("read\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	87250513          	addi	a0,a0,-1934 # 928 <malloc+0x10c>
  be:	00000097          	auipc	ra,0x0
  c2:	6a0080e7          	jalr	1696(ra) # 75e <printf>

  fd = open(path, O_RDONLY);
  c6:	4581                	li	a1,0
  c8:	fd040513          	addi	a0,s0,-48
  cc:	00000097          	auipc	ra,0x0
  d0:	2f6080e7          	jalr	758(ra) # 3c2 <open>
  d4:	892a                	mv	s2,a0
  d6:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  d8:	20000613          	li	a2,512
  dc:	dd040593          	addi	a1,s0,-560
  e0:	854a                	mv	a0,s2
  e2:	00000097          	auipc	ra,0x0
  e6:	2b8080e7          	jalr	696(ra) # 39a <read>
  for (i = 0; i < 20; i++)
  ea:	34fd                	addiw	s1,s1,-1
  ec:	f4f5                	bnez	s1,d8 <main+0xd8>
  close(fd);
  ee:	854a                	mv	a0,s2
  f0:	00000097          	auipc	ra,0x0
  f4:	2ba080e7          	jalr	698(ra) # 3aa <close>

  wait(0);
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	290080e7          	jalr	656(ra) # 38a <wait>

  exit(0);
 102:	4501                	li	a0,0
 104:	00000097          	auipc	ra,0x0
 108:	27e080e7          	jalr	638(ra) # 382 <exit>

000000000000010c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e422                	sd	s0,8(sp)
 110:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 112:	87aa                	mv	a5,a0
 114:	0585                	addi	a1,a1,1
 116:	0785                	addi	a5,a5,1
 118:	fff5c703          	lbu	a4,-1(a1)
 11c:	fee78fa3          	sb	a4,-1(a5)
 120:	fb75                	bnez	a4,114 <strcpy+0x8>
    ;
  return os;
}
 122:	6422                	ld	s0,8(sp)
 124:	0141                	addi	sp,sp,16
 126:	8082                	ret

0000000000000128 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 128:	1141                	addi	sp,sp,-16
 12a:	e422                	sd	s0,8(sp)
 12c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12e:	00054783          	lbu	a5,0(a0)
 132:	cb91                	beqz	a5,146 <strcmp+0x1e>
 134:	0005c703          	lbu	a4,0(a1)
 138:	00f71763          	bne	a4,a5,146 <strcmp+0x1e>
    p++, q++;
 13c:	0505                	addi	a0,a0,1
 13e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 140:	00054783          	lbu	a5,0(a0)
 144:	fbe5                	bnez	a5,134 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 146:	0005c503          	lbu	a0,0(a1)
}
 14a:	40a7853b          	subw	a0,a5,a0
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strlen>:

uint
strlen(const char *s)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cf91                	beqz	a5,17a <strlen+0x26>
 160:	0505                	addi	a0,a0,1
 162:	87aa                	mv	a5,a0
 164:	4685                	li	a3,1
 166:	9e89                	subw	a3,a3,a0
 168:	00f6853b          	addw	a0,a3,a5
 16c:	0785                	addi	a5,a5,1
 16e:	fff7c703          	lbu	a4,-1(a5)
 172:	fb7d                	bnez	a4,168 <strlen+0x14>
    ;
  return n;
}
 174:	6422                	ld	s0,8(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret
  for(n = 0; s[n]; n++)
 17a:	4501                	li	a0,0
 17c:	bfe5                	j	174 <strlen+0x20>

000000000000017e <memset>:

void*
memset(void *dst, int c, uint n)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e422                	sd	s0,8(sp)
 182:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 184:	ce09                	beqz	a2,19e <memset+0x20>
 186:	87aa                	mv	a5,a0
 188:	fff6071b          	addiw	a4,a2,-1
 18c:	1702                	slli	a4,a4,0x20
 18e:	9301                	srli	a4,a4,0x20
 190:	0705                	addi	a4,a4,1
 192:	972a                	add	a4,a4,a0
    cdst[i] = c;
 194:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 198:	0785                	addi	a5,a5,1
 19a:	fee79de3          	bne	a5,a4,194 <memset+0x16>
  }
  return dst;
}
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret

00000000000001a4 <strchr>:

char*
strchr(const char *s, char c)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	cb99                	beqz	a5,1c4 <strchr+0x20>
    if(*s == c)
 1b0:	00f58763          	beq	a1,a5,1be <strchr+0x1a>
  for(; *s; s++)
 1b4:	0505                	addi	a0,a0,1
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	fbfd                	bnez	a5,1b0 <strchr+0xc>
      return (char*)s;
  return 0;
 1bc:	4501                	li	a0,0
}
 1be:	6422                	ld	s0,8(sp)
 1c0:	0141                	addi	sp,sp,16
 1c2:	8082                	ret
  return 0;
 1c4:	4501                	li	a0,0
 1c6:	bfe5                	j	1be <strchr+0x1a>

00000000000001c8 <gets>:

char*
gets(char *buf, int max)
{
 1c8:	711d                	addi	sp,sp,-96
 1ca:	ec86                	sd	ra,88(sp)
 1cc:	e8a2                	sd	s0,80(sp)
 1ce:	e4a6                	sd	s1,72(sp)
 1d0:	e0ca                	sd	s2,64(sp)
 1d2:	fc4e                	sd	s3,56(sp)
 1d4:	f852                	sd	s4,48(sp)
 1d6:	f456                	sd	s5,40(sp)
 1d8:	f05a                	sd	s6,32(sp)
 1da:	ec5e                	sd	s7,24(sp)
 1dc:	1080                	addi	s0,sp,96
 1de:	8baa                	mv	s7,a0
 1e0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e2:	892a                	mv	s2,a0
 1e4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e6:	4aa9                	li	s5,10
 1e8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ea:	89a6                	mv	s3,s1
 1ec:	2485                	addiw	s1,s1,1
 1ee:	0344d863          	bge	s1,s4,21e <gets+0x56>
    cc = read(0, &c, 1);
 1f2:	4605                	li	a2,1
 1f4:	faf40593          	addi	a1,s0,-81
 1f8:	4501                	li	a0,0
 1fa:	00000097          	auipc	ra,0x0
 1fe:	1a0080e7          	jalr	416(ra) # 39a <read>
    if(cc < 1)
 202:	00a05e63          	blez	a0,21e <gets+0x56>
    buf[i++] = c;
 206:	faf44783          	lbu	a5,-81(s0)
 20a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20e:	01578763          	beq	a5,s5,21c <gets+0x54>
 212:	0905                	addi	s2,s2,1
 214:	fd679be3          	bne	a5,s6,1ea <gets+0x22>
  for(i=0; i+1 < max; ){
 218:	89a6                	mv	s3,s1
 21a:	a011                	j	21e <gets+0x56>
 21c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 21e:	99de                	add	s3,s3,s7
 220:	00098023          	sb	zero,0(s3)
  return buf;
}
 224:	855e                	mv	a0,s7
 226:	60e6                	ld	ra,88(sp)
 228:	6446                	ld	s0,80(sp)
 22a:	64a6                	ld	s1,72(sp)
 22c:	6906                	ld	s2,64(sp)
 22e:	79e2                	ld	s3,56(sp)
 230:	7a42                	ld	s4,48(sp)
 232:	7aa2                	ld	s5,40(sp)
 234:	7b02                	ld	s6,32(sp)
 236:	6be2                	ld	s7,24(sp)
 238:	6125                	addi	sp,sp,96
 23a:	8082                	ret

000000000000023c <stat>:

int
stat(const char *n, struct stat *st)
{
 23c:	1101                	addi	sp,sp,-32
 23e:	ec06                	sd	ra,24(sp)
 240:	e822                	sd	s0,16(sp)
 242:	e426                	sd	s1,8(sp)
 244:	e04a                	sd	s2,0(sp)
 246:	1000                	addi	s0,sp,32
 248:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24a:	4581                	li	a1,0
 24c:	00000097          	auipc	ra,0x0
 250:	176080e7          	jalr	374(ra) # 3c2 <open>
  if(fd < 0)
 254:	02054563          	bltz	a0,27e <stat+0x42>
 258:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25a:	85ca                	mv	a1,s2
 25c:	00000097          	auipc	ra,0x0
 260:	17e080e7          	jalr	382(ra) # 3da <fstat>
 264:	892a                	mv	s2,a0
  close(fd);
 266:	8526                	mv	a0,s1
 268:	00000097          	auipc	ra,0x0
 26c:	142080e7          	jalr	322(ra) # 3aa <close>
  return r;
}
 270:	854a                	mv	a0,s2
 272:	60e2                	ld	ra,24(sp)
 274:	6442                	ld	s0,16(sp)
 276:	64a2                	ld	s1,8(sp)
 278:	6902                	ld	s2,0(sp)
 27a:	6105                	addi	sp,sp,32
 27c:	8082                	ret
    return -1;
 27e:	597d                	li	s2,-1
 280:	bfc5                	j	270 <stat+0x34>

0000000000000282 <atoi>:

int
atoi(const char *s)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 288:	00054603          	lbu	a2,0(a0)
 28c:	fd06079b          	addiw	a5,a2,-48
 290:	0ff7f793          	andi	a5,a5,255
 294:	4725                	li	a4,9
 296:	02f76963          	bltu	a4,a5,2c8 <atoi+0x46>
 29a:	86aa                	mv	a3,a0
  n = 0;
 29c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 29e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2a0:	0685                	addi	a3,a3,1
 2a2:	0025179b          	slliw	a5,a0,0x2
 2a6:	9fa9                	addw	a5,a5,a0
 2a8:	0017979b          	slliw	a5,a5,0x1
 2ac:	9fb1                	addw	a5,a5,a2
 2ae:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b2:	0006c603          	lbu	a2,0(a3)
 2b6:	fd06071b          	addiw	a4,a2,-48
 2ba:	0ff77713          	andi	a4,a4,255
 2be:	fee5f1e3          	bgeu	a1,a4,2a0 <atoi+0x1e>
  return n;
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
  n = 0;
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <atoi+0x40>

00000000000002cc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d2:	02b57663          	bgeu	a0,a1,2fe <memmove+0x32>
    while(n-- > 0)
 2d6:	02c05163          	blez	a2,2f8 <memmove+0x2c>
 2da:	fff6079b          	addiw	a5,a2,-1
 2de:	1782                	slli	a5,a5,0x20
 2e0:	9381                	srli	a5,a5,0x20
 2e2:	0785                	addi	a5,a5,1
 2e4:	97aa                	add	a5,a5,a0
  dst = vdst;
 2e6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2e8:	0585                	addi	a1,a1,1
 2ea:	0705                	addi	a4,a4,1
 2ec:	fff5c683          	lbu	a3,-1(a1)
 2f0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f4:	fee79ae3          	bne	a5,a4,2e8 <memmove+0x1c>
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
 304:	fec05ae3          	blez	a2,2f8 <memmove+0x2c>
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
 322:	fee79ae3          	bne	a5,a4,316 <memmove+0x4a>
 326:	bfc9                	j	2f8 <memmove+0x2c>

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
 36e:	f62080e7          	jalr	-158(ra) # 2cc <memmove>
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

0000000000000486 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 486:	1101                	addi	sp,sp,-32
 488:	ec06                	sd	ra,24(sp)
 48a:	e822                	sd	s0,16(sp)
 48c:	1000                	addi	s0,sp,32
 48e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 492:	4605                	li	a2,1
 494:	fef40593          	addi	a1,s0,-17
 498:	00000097          	auipc	ra,0x0
 49c:	f0a080e7          	jalr	-246(ra) # 3a2 <write>
}
 4a0:	60e2                	ld	ra,24(sp)
 4a2:	6442                	ld	s0,16(sp)
 4a4:	6105                	addi	sp,sp,32
 4a6:	8082                	ret

00000000000004a8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a8:	7139                	addi	sp,sp,-64
 4aa:	fc06                	sd	ra,56(sp)
 4ac:	f822                	sd	s0,48(sp)
 4ae:	f426                	sd	s1,40(sp)
 4b0:	f04a                	sd	s2,32(sp)
 4b2:	ec4e                	sd	s3,24(sp)
 4b4:	0080                	addi	s0,sp,64
 4b6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b8:	c299                	beqz	a3,4be <printint+0x16>
 4ba:	0805c863          	bltz	a1,54a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4be:	2581                	sext.w	a1,a1
  neg = 0;
 4c0:	4881                	li	a7,0
 4c2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4c6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c8:	2601                	sext.w	a2,a2
 4ca:	00000517          	auipc	a0,0x0
 4ce:	47e50513          	addi	a0,a0,1150 # 948 <digits>
 4d2:	883a                	mv	a6,a4
 4d4:	2705                	addiw	a4,a4,1
 4d6:	02c5f7bb          	remuw	a5,a1,a2
 4da:	1782                	slli	a5,a5,0x20
 4dc:	9381                	srli	a5,a5,0x20
 4de:	97aa                	add	a5,a5,a0
 4e0:	0007c783          	lbu	a5,0(a5)
 4e4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e8:	0005879b          	sext.w	a5,a1
 4ec:	02c5d5bb          	divuw	a1,a1,a2
 4f0:	0685                	addi	a3,a3,1
 4f2:	fec7f0e3          	bgeu	a5,a2,4d2 <printint+0x2a>
  if(neg)
 4f6:	00088b63          	beqz	a7,50c <printint+0x64>
    buf[i++] = '-';
 4fa:	fd040793          	addi	a5,s0,-48
 4fe:	973e                	add	a4,a4,a5
 500:	02d00793          	li	a5,45
 504:	fef70823          	sb	a5,-16(a4)
 508:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 50c:	02e05863          	blez	a4,53c <printint+0x94>
 510:	fc040793          	addi	a5,s0,-64
 514:	00e78933          	add	s2,a5,a4
 518:	fff78993          	addi	s3,a5,-1
 51c:	99ba                	add	s3,s3,a4
 51e:	377d                	addiw	a4,a4,-1
 520:	1702                	slli	a4,a4,0x20
 522:	9301                	srli	a4,a4,0x20
 524:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 528:	fff94583          	lbu	a1,-1(s2)
 52c:	8526                	mv	a0,s1
 52e:	00000097          	auipc	ra,0x0
 532:	f58080e7          	jalr	-168(ra) # 486 <putc>
  while(--i >= 0)
 536:	197d                	addi	s2,s2,-1
 538:	ff3918e3          	bne	s2,s3,528 <printint+0x80>
}
 53c:	70e2                	ld	ra,56(sp)
 53e:	7442                	ld	s0,48(sp)
 540:	74a2                	ld	s1,40(sp)
 542:	7902                	ld	s2,32(sp)
 544:	69e2                	ld	s3,24(sp)
 546:	6121                	addi	sp,sp,64
 548:	8082                	ret
    x = -xx;
 54a:	40b005bb          	negw	a1,a1
    neg = 1;
 54e:	4885                	li	a7,1
    x = -xx;
 550:	bf8d                	j	4c2 <printint+0x1a>

0000000000000552 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 552:	7119                	addi	sp,sp,-128
 554:	fc86                	sd	ra,120(sp)
 556:	f8a2                	sd	s0,112(sp)
 558:	f4a6                	sd	s1,104(sp)
 55a:	f0ca                	sd	s2,96(sp)
 55c:	ecce                	sd	s3,88(sp)
 55e:	e8d2                	sd	s4,80(sp)
 560:	e4d6                	sd	s5,72(sp)
 562:	e0da                	sd	s6,64(sp)
 564:	fc5e                	sd	s7,56(sp)
 566:	f862                	sd	s8,48(sp)
 568:	f466                	sd	s9,40(sp)
 56a:	f06a                	sd	s10,32(sp)
 56c:	ec6e                	sd	s11,24(sp)
 56e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 570:	0005c903          	lbu	s2,0(a1)
 574:	18090f63          	beqz	s2,712 <vprintf+0x1c0>
 578:	8aaa                	mv	s5,a0
 57a:	8b32                	mv	s6,a2
 57c:	00158493          	addi	s1,a1,1
  state = 0;
 580:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 582:	02500a13          	li	s4,37
      if(c == 'd'){
 586:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 58a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 58e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 592:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 596:	00000b97          	auipc	s7,0x0
 59a:	3b2b8b93          	addi	s7,s7,946 # 948 <digits>
 59e:	a839                	j	5bc <vprintf+0x6a>
        putc(fd, c);
 5a0:	85ca                	mv	a1,s2
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	ee2080e7          	jalr	-286(ra) # 486 <putc>
 5ac:	a019                	j	5b2 <vprintf+0x60>
    } else if(state == '%'){
 5ae:	01498f63          	beq	s3,s4,5cc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5b2:	0485                	addi	s1,s1,1
 5b4:	fff4c903          	lbu	s2,-1(s1)
 5b8:	14090d63          	beqz	s2,712 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5bc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5c0:	fe0997e3          	bnez	s3,5ae <vprintf+0x5c>
      if(c == '%'){
 5c4:	fd479ee3          	bne	a5,s4,5a0 <vprintf+0x4e>
        state = '%';
 5c8:	89be                	mv	s3,a5
 5ca:	b7e5                	j	5b2 <vprintf+0x60>
      if(c == 'd'){
 5cc:	05878063          	beq	a5,s8,60c <vprintf+0xba>
      } else if(c == 'l') {
 5d0:	05978c63          	beq	a5,s9,628 <vprintf+0xd6>
      } else if(c == 'x') {
 5d4:	07a78863          	beq	a5,s10,644 <vprintf+0xf2>
      } else if(c == 'p') {
 5d8:	09b78463          	beq	a5,s11,660 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5dc:	07300713          	li	a4,115
 5e0:	0ce78663          	beq	a5,a4,6ac <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5e4:	06300713          	li	a4,99
 5e8:	0ee78e63          	beq	a5,a4,6e4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5ec:	11478863          	beq	a5,s4,6fc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5f0:	85d2                	mv	a1,s4
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e92080e7          	jalr	-366(ra) # 486 <putc>
        putc(fd, c);
 5fc:	85ca                	mv	a1,s2
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e86080e7          	jalr	-378(ra) # 486 <putc>
      }
      state = 0;
 608:	4981                	li	s3,0
 60a:	b765                	j	5b2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 60c:	008b0913          	addi	s2,s6,8
 610:	4685                	li	a3,1
 612:	4629                	li	a2,10
 614:	000b2583          	lw	a1,0(s6)
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	e8e080e7          	jalr	-370(ra) # 4a8 <printint>
 622:	8b4a                	mv	s6,s2
      state = 0;
 624:	4981                	li	s3,0
 626:	b771                	j	5b2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 628:	008b0913          	addi	s2,s6,8
 62c:	4681                	li	a3,0
 62e:	4629                	li	a2,10
 630:	000b2583          	lw	a1,0(s6)
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	e72080e7          	jalr	-398(ra) # 4a8 <printint>
 63e:	8b4a                	mv	s6,s2
      state = 0;
 640:	4981                	li	s3,0
 642:	bf85                	j	5b2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 644:	008b0913          	addi	s2,s6,8
 648:	4681                	li	a3,0
 64a:	4641                	li	a2,16
 64c:	000b2583          	lw	a1,0(s6)
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	e56080e7          	jalr	-426(ra) # 4a8 <printint>
 65a:	8b4a                	mv	s6,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bf91                	j	5b2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 660:	008b0793          	addi	a5,s6,8
 664:	f8f43423          	sd	a5,-120(s0)
 668:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 66c:	03000593          	li	a1,48
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e14080e7          	jalr	-492(ra) # 486 <putc>
  putc(fd, 'x');
 67a:	85ea                	mv	a1,s10
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	e08080e7          	jalr	-504(ra) # 486 <putc>
 686:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 688:	03c9d793          	srli	a5,s3,0x3c
 68c:	97de                	add	a5,a5,s7
 68e:	0007c583          	lbu	a1,0(a5)
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	df2080e7          	jalr	-526(ra) # 486 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69c:	0992                	slli	s3,s3,0x4
 69e:	397d                	addiw	s2,s2,-1
 6a0:	fe0914e3          	bnez	s2,688 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6a4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	b721                	j	5b2 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ac:	008b0993          	addi	s3,s6,8
 6b0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6b4:	02090163          	beqz	s2,6d6 <vprintf+0x184>
        while(*s != 0){
 6b8:	00094583          	lbu	a1,0(s2)
 6bc:	c9a1                	beqz	a1,70c <vprintf+0x1ba>
          putc(fd, *s);
 6be:	8556                	mv	a0,s5
 6c0:	00000097          	auipc	ra,0x0
 6c4:	dc6080e7          	jalr	-570(ra) # 486 <putc>
          s++;
 6c8:	0905                	addi	s2,s2,1
        while(*s != 0){
 6ca:	00094583          	lbu	a1,0(s2)
 6ce:	f9e5                	bnez	a1,6be <vprintf+0x16c>
        s = va_arg(ap, char*);
 6d0:	8b4e                	mv	s6,s3
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	bdf9                	j	5b2 <vprintf+0x60>
          s = "(null)";
 6d6:	00000917          	auipc	s2,0x0
 6da:	26a90913          	addi	s2,s2,618 # 940 <malloc+0x124>
        while(*s != 0){
 6de:	02800593          	li	a1,40
 6e2:	bff1                	j	6be <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6e4:	008b0913          	addi	s2,s6,8
 6e8:	000b4583          	lbu	a1,0(s6)
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	d98080e7          	jalr	-616(ra) # 486 <putc>
 6f6:	8b4a                	mv	s6,s2
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bd65                	j	5b2 <vprintf+0x60>
        putc(fd, c);
 6fc:	85d2                	mv	a1,s4
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	d86080e7          	jalr	-634(ra) # 486 <putc>
      state = 0;
 708:	4981                	li	s3,0
 70a:	b565                	j	5b2 <vprintf+0x60>
        s = va_arg(ap, char*);
 70c:	8b4e                	mv	s6,s3
      state = 0;
 70e:	4981                	li	s3,0
 710:	b54d                	j	5b2 <vprintf+0x60>
    }
  }
}
 712:	70e6                	ld	ra,120(sp)
 714:	7446                	ld	s0,112(sp)
 716:	74a6                	ld	s1,104(sp)
 718:	7906                	ld	s2,96(sp)
 71a:	69e6                	ld	s3,88(sp)
 71c:	6a46                	ld	s4,80(sp)
 71e:	6aa6                	ld	s5,72(sp)
 720:	6b06                	ld	s6,64(sp)
 722:	7be2                	ld	s7,56(sp)
 724:	7c42                	ld	s8,48(sp)
 726:	7ca2                	ld	s9,40(sp)
 728:	7d02                	ld	s10,32(sp)
 72a:	6de2                	ld	s11,24(sp)
 72c:	6109                	addi	sp,sp,128
 72e:	8082                	ret

0000000000000730 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 730:	715d                	addi	sp,sp,-80
 732:	ec06                	sd	ra,24(sp)
 734:	e822                	sd	s0,16(sp)
 736:	1000                	addi	s0,sp,32
 738:	e010                	sd	a2,0(s0)
 73a:	e414                	sd	a3,8(s0)
 73c:	e818                	sd	a4,16(s0)
 73e:	ec1c                	sd	a5,24(s0)
 740:	03043023          	sd	a6,32(s0)
 744:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 748:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 74c:	8622                	mv	a2,s0
 74e:	00000097          	auipc	ra,0x0
 752:	e04080e7          	jalr	-508(ra) # 552 <vprintf>
}
 756:	60e2                	ld	ra,24(sp)
 758:	6442                	ld	s0,16(sp)
 75a:	6161                	addi	sp,sp,80
 75c:	8082                	ret

000000000000075e <printf>:

void
printf(const char *fmt, ...)
{
 75e:	711d                	addi	sp,sp,-96
 760:	ec06                	sd	ra,24(sp)
 762:	e822                	sd	s0,16(sp)
 764:	1000                	addi	s0,sp,32
 766:	e40c                	sd	a1,8(s0)
 768:	e810                	sd	a2,16(s0)
 76a:	ec14                	sd	a3,24(s0)
 76c:	f018                	sd	a4,32(s0)
 76e:	f41c                	sd	a5,40(s0)
 770:	03043823          	sd	a6,48(s0)
 774:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 778:	00840613          	addi	a2,s0,8
 77c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 780:	85aa                	mv	a1,a0
 782:	4505                	li	a0,1
 784:	00000097          	auipc	ra,0x0
 788:	dce080e7          	jalr	-562(ra) # 552 <vprintf>
}
 78c:	60e2                	ld	ra,24(sp)
 78e:	6442                	ld	s0,16(sp)
 790:	6125                	addi	sp,sp,96
 792:	8082                	ret

0000000000000794 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 794:	1141                	addi	sp,sp,-16
 796:	e422                	sd	s0,8(sp)
 798:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 79a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79e:	00000797          	auipc	a5,0x0
 7a2:	1c27b783          	ld	a5,450(a5) # 960 <freep>
 7a6:	a805                	j	7d6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a8:	4618                	lw	a4,8(a2)
 7aa:	9db9                	addw	a1,a1,a4
 7ac:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7b0:	6398                	ld	a4,0(a5)
 7b2:	6318                	ld	a4,0(a4)
 7b4:	fee53823          	sd	a4,-16(a0)
 7b8:	a091                	j	7fc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ba:	ff852703          	lw	a4,-8(a0)
 7be:	9e39                	addw	a2,a2,a4
 7c0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7c2:	ff053703          	ld	a4,-16(a0)
 7c6:	e398                	sd	a4,0(a5)
 7c8:	a099                	j	80e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ca:	6398                	ld	a4,0(a5)
 7cc:	00e7e463          	bltu	a5,a4,7d4 <free+0x40>
 7d0:	00e6ea63          	bltu	a3,a4,7e4 <free+0x50>
{
 7d4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d6:	fed7fae3          	bgeu	a5,a3,7ca <free+0x36>
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e6e463          	bltu	a3,a4,7e4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	fee7eae3          	bltu	a5,a4,7d4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7e4:	ff852583          	lw	a1,-8(a0)
 7e8:	6390                	ld	a2,0(a5)
 7ea:	02059713          	slli	a4,a1,0x20
 7ee:	9301                	srli	a4,a4,0x20
 7f0:	0712                	slli	a4,a4,0x4
 7f2:	9736                	add	a4,a4,a3
 7f4:	fae60ae3          	beq	a2,a4,7a8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7f8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7fc:	4790                	lw	a2,8(a5)
 7fe:	02061713          	slli	a4,a2,0x20
 802:	9301                	srli	a4,a4,0x20
 804:	0712                	slli	a4,a4,0x4
 806:	973e                	add	a4,a4,a5
 808:	fae689e3          	beq	a3,a4,7ba <free+0x26>
  } else
    p->s.ptr = bp;
 80c:	e394                	sd	a3,0(a5)
  freep = p;
 80e:	00000717          	auipc	a4,0x0
 812:	14f73923          	sd	a5,338(a4) # 960 <freep>
}
 816:	6422                	ld	s0,8(sp)
 818:	0141                	addi	sp,sp,16
 81a:	8082                	ret

000000000000081c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 81c:	7139                	addi	sp,sp,-64
 81e:	fc06                	sd	ra,56(sp)
 820:	f822                	sd	s0,48(sp)
 822:	f426                	sd	s1,40(sp)
 824:	f04a                	sd	s2,32(sp)
 826:	ec4e                	sd	s3,24(sp)
 828:	e852                	sd	s4,16(sp)
 82a:	e456                	sd	s5,8(sp)
 82c:	e05a                	sd	s6,0(sp)
 82e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 830:	02051493          	slli	s1,a0,0x20
 834:	9081                	srli	s1,s1,0x20
 836:	04bd                	addi	s1,s1,15
 838:	8091                	srli	s1,s1,0x4
 83a:	0014899b          	addiw	s3,s1,1
 83e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 840:	00000517          	auipc	a0,0x0
 844:	12053503          	ld	a0,288(a0) # 960 <freep>
 848:	c515                	beqz	a0,874 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84c:	4798                	lw	a4,8(a5)
 84e:	02977f63          	bgeu	a4,s1,88c <malloc+0x70>
 852:	8a4e                	mv	s4,s3
 854:	0009871b          	sext.w	a4,s3
 858:	6685                	lui	a3,0x1
 85a:	00d77363          	bgeu	a4,a3,860 <malloc+0x44>
 85e:	6a05                	lui	s4,0x1
 860:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 864:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 868:	00000917          	auipc	s2,0x0
 86c:	0f890913          	addi	s2,s2,248 # 960 <freep>
  if(p == (char*)-1)
 870:	5afd                	li	s5,-1
 872:	a88d                	j	8e4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 874:	00000797          	auipc	a5,0x0
 878:	0f478793          	addi	a5,a5,244 # 968 <base>
 87c:	00000717          	auipc	a4,0x0
 880:	0ef73223          	sd	a5,228(a4) # 960 <freep>
 884:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 886:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 88a:	b7e1                	j	852 <malloc+0x36>
      if(p->s.size == nunits)
 88c:	02e48b63          	beq	s1,a4,8c2 <malloc+0xa6>
        p->s.size -= nunits;
 890:	4137073b          	subw	a4,a4,s3
 894:	c798                	sw	a4,8(a5)
        p += p->s.size;
 896:	1702                	slli	a4,a4,0x20
 898:	9301                	srli	a4,a4,0x20
 89a:	0712                	slli	a4,a4,0x4
 89c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 89e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a2:	00000717          	auipc	a4,0x0
 8a6:	0aa73f23          	sd	a0,190(a4) # 960 <freep>
      return (void*)(p + 1);
 8aa:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8ae:	70e2                	ld	ra,56(sp)
 8b0:	7442                	ld	s0,48(sp)
 8b2:	74a2                	ld	s1,40(sp)
 8b4:	7902                	ld	s2,32(sp)
 8b6:	69e2                	ld	s3,24(sp)
 8b8:	6a42                	ld	s4,16(sp)
 8ba:	6aa2                	ld	s5,8(sp)
 8bc:	6b02                	ld	s6,0(sp)
 8be:	6121                	addi	sp,sp,64
 8c0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8c2:	6398                	ld	a4,0(a5)
 8c4:	e118                	sd	a4,0(a0)
 8c6:	bff1                	j	8a2 <malloc+0x86>
  hp->s.size = nu;
 8c8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8cc:	0541                	addi	a0,a0,16
 8ce:	00000097          	auipc	ra,0x0
 8d2:	ec6080e7          	jalr	-314(ra) # 794 <free>
  return freep;
 8d6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8da:	d971                	beqz	a0,8ae <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8de:	4798                	lw	a4,8(a5)
 8e0:	fa9776e3          	bgeu	a4,s1,88c <malloc+0x70>
    if(p == freep)
 8e4:	00093703          	ld	a4,0(s2)
 8e8:	853e                	mv	a0,a5
 8ea:	fef719e3          	bne	a4,a5,8dc <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8ee:	8552                	mv	a0,s4
 8f0:	00000097          	auipc	ra,0x0
 8f4:	b1a080e7          	jalr	-1254(ra) # 40a <sbrk>
  if(p == (char*)-1)
 8f8:	fd5518e3          	bne	a0,s5,8c8 <malloc+0xac>
        return 0;
 8fc:	4501                	li	a0,0
 8fe:	bf45                	j	8ae <malloc+0x92>
