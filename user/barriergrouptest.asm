
user/_barriergrouptest:     file format elf64-littleriscv


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
  14:	e062                	sd	s8,0(sp)
  16:	0880                	addi	s0,sp,80
  int i, j, n, r, barrier_id1, barrier_id2;

  if (argc != 3) {
  18:	478d                	li	a5,3
  1a:	02f50063          	beq	a0,a5,3a <main+0x3a>
     fprintf(2, "syntax: barriergrouptest numprocs numrounds\nAborting...\n");
  1e:	00001597          	auipc	a1,0x1
  22:	92a58593          	addi	a1,a1,-1750 # 948 <malloc+0xe8>
  26:	4509                	li	a0,2
  28:	00000097          	auipc	ra,0x0
  2c:	74c080e7          	jalr	1868(ra) # 774 <fprintf>
     exit(0);
  30:	4501                	li	a0,0
  32:	00000097          	auipc	ra,0x0
  36:	394080e7          	jalr	916(ra) # 3c6 <exit>
  3a:	84ae                	mv	s1,a1
  }

  n = atoi(argv[1]);
  3c:	6588                	ld	a0,8(a1)
  3e:	00000097          	auipc	ra,0x0
  42:	288080e7          	jalr	648(ra) # 2c6 <atoi>
  46:	8c2a                	mv	s8,a0
  r = atoi(argv[2]);
  48:	6888                	ld	a0,16(s1)
  4a:	00000097          	auipc	ra,0x0
  4e:	27c080e7          	jalr	636(ra) # 2c6 <atoi>
  52:	89aa                	mv	s3,a0
  barrier_id1 = barrier_alloc();
  54:	00000097          	auipc	ra,0x0
  58:	45a080e7          	jalr	1114(ra) # 4ae <barrier_alloc>
  5c:	8baa                	mv	s7,a0
  barrier_id2 = barrier_alloc();
  5e:	00000097          	auipc	ra,0x0
  62:	450080e7          	jalr	1104(ra) # 4ae <barrier_alloc>
  66:	8a2a                	mv	s4,a0
  fprintf(1, "%d: got barrier array ids %d, %d\n\n", getpid(), barrier_id1, barrier_id2);
  68:	00000097          	auipc	ra,0x0
  6c:	3de080e7          	jalr	990(ra) # 446 <getpid>
  70:	862a                	mv	a2,a0
  72:	8752                	mv	a4,s4
  74:	86de                	mv	a3,s7
  76:	00001597          	auipc	a1,0x1
  7a:	91258593          	addi	a1,a1,-1774 # 988 <malloc+0x128>
  7e:	4505                	li	a0,1
  80:	00000097          	auipc	ra,0x0
  84:	6f4080e7          	jalr	1780(ra) # 774 <fprintf>

  for (i=0; i<n-1; i++) {
  88:	fffc0b1b          	addiw	s6,s8,-1
  8c:	0b605f63          	blez	s6,14a <main+0x14a>
  90:	8ada                	mv	s5,s6
  92:	4901                	li	s2,0
     if (fork() == 0) {
  94:	00000097          	auipc	ra,0x0
  98:	32a080e7          	jalr	810(ra) # 3be <fork>
  9c:	84aa                	mv	s1,a0
  9e:	cd31                	beqz	a0,fa <main+0xfa>
  for (i=0; i<n-1; i++) {
  a0:	2905                	addiw	s2,s2,1
  a2:	ff5919e3          	bne	s2,s5,94 <main+0x94>
           }
        }
	exit(0);
     }
  }
  for (j=0; j<r; j++) {
  a6:	03305263          	blez	s3,ca <main+0xca>
     barrier(j, barrier_id2, n/2);
  aa:	4789                	li	a5,2
  ac:	02fc4c3b          	divw	s8,s8,a5
  for (j=0; j<r; j++) {
  b0:	4481                	li	s1,0
     barrier(j, barrier_id2, n/2);
  b2:	8662                	mv	a2,s8
  b4:	85d2                	mv	a1,s4
  b6:	8526                	mv	a0,s1
  b8:	00000097          	auipc	ra,0x0
  bc:	3fe080e7          	jalr	1022(ra) # 4b6 <barrier>
  for (j=0; j<r; j++) {
  c0:	2485                	addiw	s1,s1,1
  c2:	ff34c8e3          	blt	s1,s3,b2 <main+0xb2>
  }
  for (i=0; i<n-1; i++) wait(0);
  c6:	01605b63          	blez	s6,dc <main+0xdc>
  for (j=0; j<r; j++) {
  ca:	4481                	li	s1,0
  for (i=0; i<n-1; i++) wait(0);
  cc:	4501                	li	a0,0
  ce:	00000097          	auipc	ra,0x0
  d2:	300080e7          	jalr	768(ra) # 3ce <wait>
  d6:	2485                	addiw	s1,s1,1
  d8:	ff64cae3          	blt	s1,s6,cc <main+0xcc>
  barrier_free(barrier_id1);
  dc:	855e                	mv	a0,s7
  de:	00000097          	auipc	ra,0x0
  e2:	3e2080e7          	jalr	994(ra) # 4c0 <barrier_free>
  barrier_free(barrier_id2);
  e6:	8552                	mv	a0,s4
  e8:	00000097          	auipc	ra,0x0
  ec:	3d8080e7          	jalr	984(ra) # 4c0 <barrier_free>
  exit(0);
  f0:	4501                	li	a0,0
  f2:	00000097          	auipc	ra,0x0
  f6:	2d4080e7          	jalr	724(ra) # 3c6 <exit>
	if ((i%2) == 0) {
  fa:	00197913          	andi	s2,s2,1
  fe:	02090263          	beqz	s2,122 <main+0x122>
	   for (j=0; j<r; j++) {
 102:	03305f63          	blez	s3,140 <main+0x140>
              barrier(j, barrier_id2, n/2);
 106:	4789                	li	a5,2
 108:	02fc4c3b          	divw	s8,s8,a5
 10c:	8662                	mv	a2,s8
 10e:	85d2                	mv	a1,s4
 110:	8526                	mv	a0,s1
 112:	00000097          	auipc	ra,0x0
 116:	3a4080e7          	jalr	932(ra) # 4b6 <barrier>
	   for (j=0; j<r; j++) {
 11a:	2485                	addiw	s1,s1,1
 11c:	fe9998e3          	bne	s3,s1,10c <main+0x10c>
 120:	a005                	j	140 <main+0x140>
           for (j=0; j<r; j++) {
 122:	01305f63          	blez	s3,140 <main+0x140>
	      barrier(j, barrier_id1, n/2);
 126:	4789                	li	a5,2
 128:	02fc4c3b          	divw	s8,s8,a5
 12c:	8662                	mv	a2,s8
 12e:	85de                	mv	a1,s7
 130:	8526                	mv	a0,s1
 132:	00000097          	auipc	ra,0x0
 136:	384080e7          	jalr	900(ra) # 4b6 <barrier>
           for (j=0; j<r; j++) {
 13a:	2485                	addiw	s1,s1,1
 13c:	fe9998e3          	bne	s3,s1,12c <main+0x12c>
	exit(0);
 140:	4501                	li	a0,0
 142:	00000097          	auipc	ra,0x0
 146:	284080e7          	jalr	644(ra) # 3c6 <exit>
  for (j=0; j<r; j++) {
 14a:	f73040e3          	bgtz	s3,aa <main+0xaa>
 14e:	b779                	j	dc <main+0xdc>

0000000000000150 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 156:	87aa                	mv	a5,a0
 158:	0585                	addi	a1,a1,1
 15a:	0785                	addi	a5,a5,1
 15c:	fff5c703          	lbu	a4,-1(a1)
 160:	fee78fa3          	sb	a4,-1(a5)
 164:	fb75                	bnez	a4,158 <strcpy+0x8>
    ;
  return os;
}
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret

000000000000016c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 172:	00054783          	lbu	a5,0(a0)
 176:	cb91                	beqz	a5,18a <strcmp+0x1e>
 178:	0005c703          	lbu	a4,0(a1)
 17c:	00f71763          	bne	a4,a5,18a <strcmp+0x1e>
    p++, q++;
 180:	0505                	addi	a0,a0,1
 182:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 184:	00054783          	lbu	a5,0(a0)
 188:	fbe5                	bnez	a5,178 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 18a:	0005c503          	lbu	a0,0(a1)
}
 18e:	40a7853b          	subw	a0,a5,a0
 192:	6422                	ld	s0,8(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strlen>:

uint
strlen(const char *s)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	cf91                	beqz	a5,1be <strlen+0x26>
 1a4:	0505                	addi	a0,a0,1
 1a6:	87aa                	mv	a5,a0
 1a8:	4685                	li	a3,1
 1aa:	9e89                	subw	a3,a3,a0
 1ac:	00f6853b          	addw	a0,a3,a5
 1b0:	0785                	addi	a5,a5,1
 1b2:	fff7c703          	lbu	a4,-1(a5)
 1b6:	fb7d                	bnez	a4,1ac <strlen+0x14>
    ;
  return n;
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  for(n = 0; s[n]; n++)
 1be:	4501                	li	a0,0
 1c0:	bfe5                	j	1b8 <strlen+0x20>

00000000000001c2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c8:	ce09                	beqz	a2,1e2 <memset+0x20>
 1ca:	87aa                	mv	a5,a0
 1cc:	fff6071b          	addiw	a4,a2,-1
 1d0:	1702                	slli	a4,a4,0x20
 1d2:	9301                	srli	a4,a4,0x20
 1d4:	0705                	addi	a4,a4,1
 1d6:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1d8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1dc:	0785                	addi	a5,a5,1
 1de:	fee79de3          	bne	a5,a4,1d8 <memset+0x16>
  }
  return dst;
}
 1e2:	6422                	ld	s0,8(sp)
 1e4:	0141                	addi	sp,sp,16
 1e6:	8082                	ret

00000000000001e8 <strchr>:

char*
strchr(const char *s, char c)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	cb99                	beqz	a5,208 <strchr+0x20>
    if(*s == c)
 1f4:	00f58763          	beq	a1,a5,202 <strchr+0x1a>
  for(; *s; s++)
 1f8:	0505                	addi	a0,a0,1
 1fa:	00054783          	lbu	a5,0(a0)
 1fe:	fbfd                	bnez	a5,1f4 <strchr+0xc>
      return (char*)s;
  return 0;
 200:	4501                	li	a0,0
}
 202:	6422                	ld	s0,8(sp)
 204:	0141                	addi	sp,sp,16
 206:	8082                	ret
  return 0;
 208:	4501                	li	a0,0
 20a:	bfe5                	j	202 <strchr+0x1a>

000000000000020c <gets>:

char*
gets(char *buf, int max)
{
 20c:	711d                	addi	sp,sp,-96
 20e:	ec86                	sd	ra,88(sp)
 210:	e8a2                	sd	s0,80(sp)
 212:	e4a6                	sd	s1,72(sp)
 214:	e0ca                	sd	s2,64(sp)
 216:	fc4e                	sd	s3,56(sp)
 218:	f852                	sd	s4,48(sp)
 21a:	f456                	sd	s5,40(sp)
 21c:	f05a                	sd	s6,32(sp)
 21e:	ec5e                	sd	s7,24(sp)
 220:	1080                	addi	s0,sp,96
 222:	8baa                	mv	s7,a0
 224:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 226:	892a                	mv	s2,a0
 228:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 22a:	4aa9                	li	s5,10
 22c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 22e:	89a6                	mv	s3,s1
 230:	2485                	addiw	s1,s1,1
 232:	0344d863          	bge	s1,s4,262 <gets+0x56>
    cc = read(0, &c, 1);
 236:	4605                	li	a2,1
 238:	faf40593          	addi	a1,s0,-81
 23c:	4501                	li	a0,0
 23e:	00000097          	auipc	ra,0x0
 242:	1a0080e7          	jalr	416(ra) # 3de <read>
    if(cc < 1)
 246:	00a05e63          	blez	a0,262 <gets+0x56>
    buf[i++] = c;
 24a:	faf44783          	lbu	a5,-81(s0)
 24e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 252:	01578763          	beq	a5,s5,260 <gets+0x54>
 256:	0905                	addi	s2,s2,1
 258:	fd679be3          	bne	a5,s6,22e <gets+0x22>
  for(i=0; i+1 < max; ){
 25c:	89a6                	mv	s3,s1
 25e:	a011                	j	262 <gets+0x56>
 260:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 262:	99de                	add	s3,s3,s7
 264:	00098023          	sb	zero,0(s3)
  return buf;
}
 268:	855e                	mv	a0,s7
 26a:	60e6                	ld	ra,88(sp)
 26c:	6446                	ld	s0,80(sp)
 26e:	64a6                	ld	s1,72(sp)
 270:	6906                	ld	s2,64(sp)
 272:	79e2                	ld	s3,56(sp)
 274:	7a42                	ld	s4,48(sp)
 276:	7aa2                	ld	s5,40(sp)
 278:	7b02                	ld	s6,32(sp)
 27a:	6be2                	ld	s7,24(sp)
 27c:	6125                	addi	sp,sp,96
 27e:	8082                	ret

0000000000000280 <stat>:

int
stat(const char *n, struct stat *st)
{
 280:	1101                	addi	sp,sp,-32
 282:	ec06                	sd	ra,24(sp)
 284:	e822                	sd	s0,16(sp)
 286:	e426                	sd	s1,8(sp)
 288:	e04a                	sd	s2,0(sp)
 28a:	1000                	addi	s0,sp,32
 28c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28e:	4581                	li	a1,0
 290:	00000097          	auipc	ra,0x0
 294:	176080e7          	jalr	374(ra) # 406 <open>
  if(fd < 0)
 298:	02054563          	bltz	a0,2c2 <stat+0x42>
 29c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 29e:	85ca                	mv	a1,s2
 2a0:	00000097          	auipc	ra,0x0
 2a4:	17e080e7          	jalr	382(ra) # 41e <fstat>
 2a8:	892a                	mv	s2,a0
  close(fd);
 2aa:	8526                	mv	a0,s1
 2ac:	00000097          	auipc	ra,0x0
 2b0:	142080e7          	jalr	322(ra) # 3ee <close>
  return r;
}
 2b4:	854a                	mv	a0,s2
 2b6:	60e2                	ld	ra,24(sp)
 2b8:	6442                	ld	s0,16(sp)
 2ba:	64a2                	ld	s1,8(sp)
 2bc:	6902                	ld	s2,0(sp)
 2be:	6105                	addi	sp,sp,32
 2c0:	8082                	ret
    return -1;
 2c2:	597d                	li	s2,-1
 2c4:	bfc5                	j	2b4 <stat+0x34>

00000000000002c6 <atoi>:

int
atoi(const char *s)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2cc:	00054603          	lbu	a2,0(a0)
 2d0:	fd06079b          	addiw	a5,a2,-48
 2d4:	0ff7f793          	andi	a5,a5,255
 2d8:	4725                	li	a4,9
 2da:	02f76963          	bltu	a4,a5,30c <atoi+0x46>
 2de:	86aa                	mv	a3,a0
  n = 0;
 2e0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2e2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2e4:	0685                	addi	a3,a3,1
 2e6:	0025179b          	slliw	a5,a0,0x2
 2ea:	9fa9                	addw	a5,a5,a0
 2ec:	0017979b          	slliw	a5,a5,0x1
 2f0:	9fb1                	addw	a5,a5,a2
 2f2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f6:	0006c603          	lbu	a2,0(a3)
 2fa:	fd06071b          	addiw	a4,a2,-48
 2fe:	0ff77713          	andi	a4,a4,255
 302:	fee5f1e3          	bgeu	a1,a4,2e4 <atoi+0x1e>
  return n;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  n = 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <atoi+0x40>

0000000000000310 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 316:	02b57663          	bgeu	a0,a1,342 <memmove+0x32>
    while(n-- > 0)
 31a:	02c05163          	blez	a2,33c <memmove+0x2c>
 31e:	fff6079b          	addiw	a5,a2,-1
 322:	1782                	slli	a5,a5,0x20
 324:	9381                	srli	a5,a5,0x20
 326:	0785                	addi	a5,a5,1
 328:	97aa                	add	a5,a5,a0
  dst = vdst;
 32a:	872a                	mv	a4,a0
      *dst++ = *src++;
 32c:	0585                	addi	a1,a1,1
 32e:	0705                	addi	a4,a4,1
 330:	fff5c683          	lbu	a3,-1(a1)
 334:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 338:	fee79ae3          	bne	a5,a4,32c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
    dst += n;
 342:	00c50733          	add	a4,a0,a2
    src += n;
 346:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 348:	fec05ae3          	blez	a2,33c <memmove+0x2c>
 34c:	fff6079b          	addiw	a5,a2,-1
 350:	1782                	slli	a5,a5,0x20
 352:	9381                	srli	a5,a5,0x20
 354:	fff7c793          	not	a5,a5
 358:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35a:	15fd                	addi	a1,a1,-1
 35c:	177d                	addi	a4,a4,-1
 35e:	0005c683          	lbu	a3,0(a1)
 362:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 366:	fee79ae3          	bne	a5,a4,35a <memmove+0x4a>
 36a:	bfc9                	j	33c <memmove+0x2c>

000000000000036c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 372:	ca05                	beqz	a2,3a2 <memcmp+0x36>
 374:	fff6069b          	addiw	a3,a2,-1
 378:	1682                	slli	a3,a3,0x20
 37a:	9281                	srli	a3,a3,0x20
 37c:	0685                	addi	a3,a3,1
 37e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 380:	00054783          	lbu	a5,0(a0)
 384:	0005c703          	lbu	a4,0(a1)
 388:	00e79863          	bne	a5,a4,398 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38c:	0505                	addi	a0,a0,1
    p2++;
 38e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 390:	fed518e3          	bne	a0,a3,380 <memcmp+0x14>
  }
  return 0;
 394:	4501                	li	a0,0
 396:	a019                	j	39c <memcmp+0x30>
      return *p1 - *p2;
 398:	40e7853b          	subw	a0,a5,a4
}
 39c:	6422                	ld	s0,8(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret
  return 0;
 3a2:	4501                	li	a0,0
 3a4:	bfe5                	j	39c <memcmp+0x30>

00000000000003a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a6:	1141                	addi	sp,sp,-16
 3a8:	e406                	sd	ra,8(sp)
 3aa:	e022                	sd	s0,0(sp)
 3ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ae:	00000097          	auipc	ra,0x0
 3b2:	f62080e7          	jalr	-158(ra) # 310 <memmove>
}
 3b6:	60a2                	ld	ra,8(sp)
 3b8:	6402                	ld	s0,0(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret

00000000000003be <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3be:	4885                	li	a7,1
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c6:	4889                	li	a7,2
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ce:	488d                	li	a7,3
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d6:	4891                	li	a7,4
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <read>:
.global read
read:
 li a7, SYS_read
 3de:	4895                	li	a7,5
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <write>:
.global write
write:
 li a7, SYS_write
 3e6:	48c1                	li	a7,16
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <close>:
.global close
close:
 li a7, SYS_close
 3ee:	48d5                	li	a7,21
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f6:	4899                	li	a7,6
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <exec>:
.global exec
exec:
 li a7, SYS_exec
 3fe:	489d                	li	a7,7
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <open>:
.global open
open:
 li a7, SYS_open
 406:	48bd                	li	a7,15
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 40e:	48c5                	li	a7,17
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 416:	48c9                	li	a7,18
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 41e:	48a1                	li	a7,8
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <link>:
.global link
link:
 li a7, SYS_link
 426:	48cd                	li	a7,19
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 42e:	48d1                	li	a7,20
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 436:	48a5                	li	a7,9
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <dup>:
.global dup
dup:
 li a7, SYS_dup
 43e:	48a9                	li	a7,10
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 446:	48ad                	li	a7,11
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 44e:	48b1                	li	a7,12
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 456:	48b5                	li	a7,13
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 45e:	48b9                	li	a7,14
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 466:	48d9                	li	a7,22
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <yield>:
.global yield
yield:
 li a7, SYS_yield
 46e:	48dd                	li	a7,23
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 476:	48e1                	li	a7,24
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 47e:	48e5                	li	a7,25
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 486:	48e9                	li	a7,26
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <ps>:
.global ps
ps:
 li a7, SYS_ps
 48e:	48ed                	li	a7,27
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 496:	48f1                	li	a7,28
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 49e:	48f5                	li	a7,29
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 4a6:	48f9                	li	a7,30
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 4ae:	48fd                	li	a7,31
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 4b6:	02000893          	li	a7,32
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 4c0:	02100893          	li	a7,33
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ca:	1101                	addi	sp,sp,-32
 4cc:	ec06                	sd	ra,24(sp)
 4ce:	e822                	sd	s0,16(sp)
 4d0:	1000                	addi	s0,sp,32
 4d2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4d6:	4605                	li	a2,1
 4d8:	fef40593          	addi	a1,s0,-17
 4dc:	00000097          	auipc	ra,0x0
 4e0:	f0a080e7          	jalr	-246(ra) # 3e6 <write>
}
 4e4:	60e2                	ld	ra,24(sp)
 4e6:	6442                	ld	s0,16(sp)
 4e8:	6105                	addi	sp,sp,32
 4ea:	8082                	ret

00000000000004ec <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ec:	7139                	addi	sp,sp,-64
 4ee:	fc06                	sd	ra,56(sp)
 4f0:	f822                	sd	s0,48(sp)
 4f2:	f426                	sd	s1,40(sp)
 4f4:	f04a                	sd	s2,32(sp)
 4f6:	ec4e                	sd	s3,24(sp)
 4f8:	0080                	addi	s0,sp,64
 4fa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4fc:	c299                	beqz	a3,502 <printint+0x16>
 4fe:	0805c863          	bltz	a1,58e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 502:	2581                	sext.w	a1,a1
  neg = 0;
 504:	4881                	li	a7,0
 506:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 50a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 50c:	2601                	sext.w	a2,a2
 50e:	00000517          	auipc	a0,0x0
 512:	4aa50513          	addi	a0,a0,1194 # 9b8 <digits>
 516:	883a                	mv	a6,a4
 518:	2705                	addiw	a4,a4,1
 51a:	02c5f7bb          	remuw	a5,a1,a2
 51e:	1782                	slli	a5,a5,0x20
 520:	9381                	srli	a5,a5,0x20
 522:	97aa                	add	a5,a5,a0
 524:	0007c783          	lbu	a5,0(a5)
 528:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 52c:	0005879b          	sext.w	a5,a1
 530:	02c5d5bb          	divuw	a1,a1,a2
 534:	0685                	addi	a3,a3,1
 536:	fec7f0e3          	bgeu	a5,a2,516 <printint+0x2a>
  if(neg)
 53a:	00088b63          	beqz	a7,550 <printint+0x64>
    buf[i++] = '-';
 53e:	fd040793          	addi	a5,s0,-48
 542:	973e                	add	a4,a4,a5
 544:	02d00793          	li	a5,45
 548:	fef70823          	sb	a5,-16(a4)
 54c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 550:	02e05863          	blez	a4,580 <printint+0x94>
 554:	fc040793          	addi	a5,s0,-64
 558:	00e78933          	add	s2,a5,a4
 55c:	fff78993          	addi	s3,a5,-1
 560:	99ba                	add	s3,s3,a4
 562:	377d                	addiw	a4,a4,-1
 564:	1702                	slli	a4,a4,0x20
 566:	9301                	srli	a4,a4,0x20
 568:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 56c:	fff94583          	lbu	a1,-1(s2)
 570:	8526                	mv	a0,s1
 572:	00000097          	auipc	ra,0x0
 576:	f58080e7          	jalr	-168(ra) # 4ca <putc>
  while(--i >= 0)
 57a:	197d                	addi	s2,s2,-1
 57c:	ff3918e3          	bne	s2,s3,56c <printint+0x80>
}
 580:	70e2                	ld	ra,56(sp)
 582:	7442                	ld	s0,48(sp)
 584:	74a2                	ld	s1,40(sp)
 586:	7902                	ld	s2,32(sp)
 588:	69e2                	ld	s3,24(sp)
 58a:	6121                	addi	sp,sp,64
 58c:	8082                	ret
    x = -xx;
 58e:	40b005bb          	negw	a1,a1
    neg = 1;
 592:	4885                	li	a7,1
    x = -xx;
 594:	bf8d                	j	506 <printint+0x1a>

0000000000000596 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 596:	7119                	addi	sp,sp,-128
 598:	fc86                	sd	ra,120(sp)
 59a:	f8a2                	sd	s0,112(sp)
 59c:	f4a6                	sd	s1,104(sp)
 59e:	f0ca                	sd	s2,96(sp)
 5a0:	ecce                	sd	s3,88(sp)
 5a2:	e8d2                	sd	s4,80(sp)
 5a4:	e4d6                	sd	s5,72(sp)
 5a6:	e0da                	sd	s6,64(sp)
 5a8:	fc5e                	sd	s7,56(sp)
 5aa:	f862                	sd	s8,48(sp)
 5ac:	f466                	sd	s9,40(sp)
 5ae:	f06a                	sd	s10,32(sp)
 5b0:	ec6e                	sd	s11,24(sp)
 5b2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b4:	0005c903          	lbu	s2,0(a1)
 5b8:	18090f63          	beqz	s2,756 <vprintf+0x1c0>
 5bc:	8aaa                	mv	s5,a0
 5be:	8b32                	mv	s6,a2
 5c0:	00158493          	addi	s1,a1,1
  state = 0;
 5c4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5c6:	02500a13          	li	s4,37
      if(c == 'd'){
 5ca:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5ce:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5d2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5d6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5da:	00000b97          	auipc	s7,0x0
 5de:	3deb8b93          	addi	s7,s7,990 # 9b8 <digits>
 5e2:	a839                	j	600 <vprintf+0x6a>
        putc(fd, c);
 5e4:	85ca                	mv	a1,s2
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	ee2080e7          	jalr	-286(ra) # 4ca <putc>
 5f0:	a019                	j	5f6 <vprintf+0x60>
    } else if(state == '%'){
 5f2:	01498f63          	beq	s3,s4,610 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5f6:	0485                	addi	s1,s1,1
 5f8:	fff4c903          	lbu	s2,-1(s1)
 5fc:	14090d63          	beqz	s2,756 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 600:	0009079b          	sext.w	a5,s2
    if(state == 0){
 604:	fe0997e3          	bnez	s3,5f2 <vprintf+0x5c>
      if(c == '%'){
 608:	fd479ee3          	bne	a5,s4,5e4 <vprintf+0x4e>
        state = '%';
 60c:	89be                	mv	s3,a5
 60e:	b7e5                	j	5f6 <vprintf+0x60>
      if(c == 'd'){
 610:	05878063          	beq	a5,s8,650 <vprintf+0xba>
      } else if(c == 'l') {
 614:	05978c63          	beq	a5,s9,66c <vprintf+0xd6>
      } else if(c == 'x') {
 618:	07a78863          	beq	a5,s10,688 <vprintf+0xf2>
      } else if(c == 'p') {
 61c:	09b78463          	beq	a5,s11,6a4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 620:	07300713          	li	a4,115
 624:	0ce78663          	beq	a5,a4,6f0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 628:	06300713          	li	a4,99
 62c:	0ee78e63          	beq	a5,a4,728 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 630:	11478863          	beq	a5,s4,740 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 634:	85d2                	mv	a1,s4
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	e92080e7          	jalr	-366(ra) # 4ca <putc>
        putc(fd, c);
 640:	85ca                	mv	a1,s2
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e86080e7          	jalr	-378(ra) # 4ca <putc>
      }
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b765                	j	5f6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 650:	008b0913          	addi	s2,s6,8
 654:	4685                	li	a3,1
 656:	4629                	li	a2,10
 658:	000b2583          	lw	a1,0(s6)
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	e8e080e7          	jalr	-370(ra) # 4ec <printint>
 666:	8b4a                	mv	s6,s2
      state = 0;
 668:	4981                	li	s3,0
 66a:	b771                	j	5f6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66c:	008b0913          	addi	s2,s6,8
 670:	4681                	li	a3,0
 672:	4629                	li	a2,10
 674:	000b2583          	lw	a1,0(s6)
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	e72080e7          	jalr	-398(ra) # 4ec <printint>
 682:	8b4a                	mv	s6,s2
      state = 0;
 684:	4981                	li	s3,0
 686:	bf85                	j	5f6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 688:	008b0913          	addi	s2,s6,8
 68c:	4681                	li	a3,0
 68e:	4641                	li	a2,16
 690:	000b2583          	lw	a1,0(s6)
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e56080e7          	jalr	-426(ra) # 4ec <printint>
 69e:	8b4a                	mv	s6,s2
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bf91                	j	5f6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6a4:	008b0793          	addi	a5,s6,8
 6a8:	f8f43423          	sd	a5,-120(s0)
 6ac:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6b0:	03000593          	li	a1,48
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e14080e7          	jalr	-492(ra) # 4ca <putc>
  putc(fd, 'x');
 6be:	85ea                	mv	a1,s10
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e08080e7          	jalr	-504(ra) # 4ca <putc>
 6ca:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6cc:	03c9d793          	srli	a5,s3,0x3c
 6d0:	97de                	add	a5,a5,s7
 6d2:	0007c583          	lbu	a1,0(a5)
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	df2080e7          	jalr	-526(ra) # 4ca <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e0:	0992                	slli	s3,s3,0x4
 6e2:	397d                	addiw	s2,s2,-1
 6e4:	fe0914e3          	bnez	s2,6cc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6e8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b721                	j	5f6 <vprintf+0x60>
        s = va_arg(ap, char*);
 6f0:	008b0993          	addi	s3,s6,8
 6f4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6f8:	02090163          	beqz	s2,71a <vprintf+0x184>
        while(*s != 0){
 6fc:	00094583          	lbu	a1,0(s2)
 700:	c9a1                	beqz	a1,750 <vprintf+0x1ba>
          putc(fd, *s);
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	dc6080e7          	jalr	-570(ra) # 4ca <putc>
          s++;
 70c:	0905                	addi	s2,s2,1
        while(*s != 0){
 70e:	00094583          	lbu	a1,0(s2)
 712:	f9e5                	bnez	a1,702 <vprintf+0x16c>
        s = va_arg(ap, char*);
 714:	8b4e                	mv	s6,s3
      state = 0;
 716:	4981                	li	s3,0
 718:	bdf9                	j	5f6 <vprintf+0x60>
          s = "(null)";
 71a:	00000917          	auipc	s2,0x0
 71e:	29690913          	addi	s2,s2,662 # 9b0 <malloc+0x150>
        while(*s != 0){
 722:	02800593          	li	a1,40
 726:	bff1                	j	702 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 728:	008b0913          	addi	s2,s6,8
 72c:	000b4583          	lbu	a1,0(s6)
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	d98080e7          	jalr	-616(ra) # 4ca <putc>
 73a:	8b4a                	mv	s6,s2
      state = 0;
 73c:	4981                	li	s3,0
 73e:	bd65                	j	5f6 <vprintf+0x60>
        putc(fd, c);
 740:	85d2                	mv	a1,s4
 742:	8556                	mv	a0,s5
 744:	00000097          	auipc	ra,0x0
 748:	d86080e7          	jalr	-634(ra) # 4ca <putc>
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b565                	j	5f6 <vprintf+0x60>
        s = va_arg(ap, char*);
 750:	8b4e                	mv	s6,s3
      state = 0;
 752:	4981                	li	s3,0
 754:	b54d                	j	5f6 <vprintf+0x60>
    }
  }
}
 756:	70e6                	ld	ra,120(sp)
 758:	7446                	ld	s0,112(sp)
 75a:	74a6                	ld	s1,104(sp)
 75c:	7906                	ld	s2,96(sp)
 75e:	69e6                	ld	s3,88(sp)
 760:	6a46                	ld	s4,80(sp)
 762:	6aa6                	ld	s5,72(sp)
 764:	6b06                	ld	s6,64(sp)
 766:	7be2                	ld	s7,56(sp)
 768:	7c42                	ld	s8,48(sp)
 76a:	7ca2                	ld	s9,40(sp)
 76c:	7d02                	ld	s10,32(sp)
 76e:	6de2                	ld	s11,24(sp)
 770:	6109                	addi	sp,sp,128
 772:	8082                	ret

0000000000000774 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 774:	715d                	addi	sp,sp,-80
 776:	ec06                	sd	ra,24(sp)
 778:	e822                	sd	s0,16(sp)
 77a:	1000                	addi	s0,sp,32
 77c:	e010                	sd	a2,0(s0)
 77e:	e414                	sd	a3,8(s0)
 780:	e818                	sd	a4,16(s0)
 782:	ec1c                	sd	a5,24(s0)
 784:	03043023          	sd	a6,32(s0)
 788:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 78c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 790:	8622                	mv	a2,s0
 792:	00000097          	auipc	ra,0x0
 796:	e04080e7          	jalr	-508(ra) # 596 <vprintf>
}
 79a:	60e2                	ld	ra,24(sp)
 79c:	6442                	ld	s0,16(sp)
 79e:	6161                	addi	sp,sp,80
 7a0:	8082                	ret

00000000000007a2 <printf>:

void
printf(const char *fmt, ...)
{
 7a2:	711d                	addi	sp,sp,-96
 7a4:	ec06                	sd	ra,24(sp)
 7a6:	e822                	sd	s0,16(sp)
 7a8:	1000                	addi	s0,sp,32
 7aa:	e40c                	sd	a1,8(s0)
 7ac:	e810                	sd	a2,16(s0)
 7ae:	ec14                	sd	a3,24(s0)
 7b0:	f018                	sd	a4,32(s0)
 7b2:	f41c                	sd	a5,40(s0)
 7b4:	03043823          	sd	a6,48(s0)
 7b8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7bc:	00840613          	addi	a2,s0,8
 7c0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c4:	85aa                	mv	a1,a0
 7c6:	4505                	li	a0,1
 7c8:	00000097          	auipc	ra,0x0
 7cc:	dce080e7          	jalr	-562(ra) # 596 <vprintf>
}
 7d0:	60e2                	ld	ra,24(sp)
 7d2:	6442                	ld	s0,16(sp)
 7d4:	6125                	addi	sp,sp,96
 7d6:	8082                	ret

00000000000007d8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d8:	1141                	addi	sp,sp,-16
 7da:	e422                	sd	s0,8(sp)
 7dc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7de:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e2:	00000797          	auipc	a5,0x0
 7e6:	1ee7b783          	ld	a5,494(a5) # 9d0 <freep>
 7ea:	a805                	j	81a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ec:	4618                	lw	a4,8(a2)
 7ee:	9db9                	addw	a1,a1,a4
 7f0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f4:	6398                	ld	a4,0(a5)
 7f6:	6318                	ld	a4,0(a4)
 7f8:	fee53823          	sd	a4,-16(a0)
 7fc:	a091                	j	840 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7fe:	ff852703          	lw	a4,-8(a0)
 802:	9e39                	addw	a2,a2,a4
 804:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 806:	ff053703          	ld	a4,-16(a0)
 80a:	e398                	sd	a4,0(a5)
 80c:	a099                	j	852 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80e:	6398                	ld	a4,0(a5)
 810:	00e7e463          	bltu	a5,a4,818 <free+0x40>
 814:	00e6ea63          	bltu	a3,a4,828 <free+0x50>
{
 818:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81a:	fed7fae3          	bgeu	a5,a3,80e <free+0x36>
 81e:	6398                	ld	a4,0(a5)
 820:	00e6e463          	bltu	a3,a4,828 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 824:	fee7eae3          	bltu	a5,a4,818 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 828:	ff852583          	lw	a1,-8(a0)
 82c:	6390                	ld	a2,0(a5)
 82e:	02059713          	slli	a4,a1,0x20
 832:	9301                	srli	a4,a4,0x20
 834:	0712                	slli	a4,a4,0x4
 836:	9736                	add	a4,a4,a3
 838:	fae60ae3          	beq	a2,a4,7ec <free+0x14>
    bp->s.ptr = p->s.ptr;
 83c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 840:	4790                	lw	a2,8(a5)
 842:	02061713          	slli	a4,a2,0x20
 846:	9301                	srli	a4,a4,0x20
 848:	0712                	slli	a4,a4,0x4
 84a:	973e                	add	a4,a4,a5
 84c:	fae689e3          	beq	a3,a4,7fe <free+0x26>
  } else
    p->s.ptr = bp;
 850:	e394                	sd	a3,0(a5)
  freep = p;
 852:	00000717          	auipc	a4,0x0
 856:	16f73f23          	sd	a5,382(a4) # 9d0 <freep>
}
 85a:	6422                	ld	s0,8(sp)
 85c:	0141                	addi	sp,sp,16
 85e:	8082                	ret

0000000000000860 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 860:	7139                	addi	sp,sp,-64
 862:	fc06                	sd	ra,56(sp)
 864:	f822                	sd	s0,48(sp)
 866:	f426                	sd	s1,40(sp)
 868:	f04a                	sd	s2,32(sp)
 86a:	ec4e                	sd	s3,24(sp)
 86c:	e852                	sd	s4,16(sp)
 86e:	e456                	sd	s5,8(sp)
 870:	e05a                	sd	s6,0(sp)
 872:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 874:	02051493          	slli	s1,a0,0x20
 878:	9081                	srli	s1,s1,0x20
 87a:	04bd                	addi	s1,s1,15
 87c:	8091                	srli	s1,s1,0x4
 87e:	0014899b          	addiw	s3,s1,1
 882:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 884:	00000517          	auipc	a0,0x0
 888:	14c53503          	ld	a0,332(a0) # 9d0 <freep>
 88c:	c515                	beqz	a0,8b8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 890:	4798                	lw	a4,8(a5)
 892:	02977f63          	bgeu	a4,s1,8d0 <malloc+0x70>
 896:	8a4e                	mv	s4,s3
 898:	0009871b          	sext.w	a4,s3
 89c:	6685                	lui	a3,0x1
 89e:	00d77363          	bgeu	a4,a3,8a4 <malloc+0x44>
 8a2:	6a05                	lui	s4,0x1
 8a4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ac:	00000917          	auipc	s2,0x0
 8b0:	12490913          	addi	s2,s2,292 # 9d0 <freep>
  if(p == (char*)-1)
 8b4:	5afd                	li	s5,-1
 8b6:	a88d                	j	928 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8b8:	00000797          	auipc	a5,0x0
 8bc:	12078793          	addi	a5,a5,288 # 9d8 <base>
 8c0:	00000717          	auipc	a4,0x0
 8c4:	10f73823          	sd	a5,272(a4) # 9d0 <freep>
 8c8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ca:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ce:	b7e1                	j	896 <malloc+0x36>
      if(p->s.size == nunits)
 8d0:	02e48b63          	beq	s1,a4,906 <malloc+0xa6>
        p->s.size -= nunits;
 8d4:	4137073b          	subw	a4,a4,s3
 8d8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8da:	1702                	slli	a4,a4,0x20
 8dc:	9301                	srli	a4,a4,0x20
 8de:	0712                	slli	a4,a4,0x4
 8e0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8e6:	00000717          	auipc	a4,0x0
 8ea:	0ea73523          	sd	a0,234(a4) # 9d0 <freep>
      return (void*)(p + 1);
 8ee:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f2:	70e2                	ld	ra,56(sp)
 8f4:	7442                	ld	s0,48(sp)
 8f6:	74a2                	ld	s1,40(sp)
 8f8:	7902                	ld	s2,32(sp)
 8fa:	69e2                	ld	s3,24(sp)
 8fc:	6a42                	ld	s4,16(sp)
 8fe:	6aa2                	ld	s5,8(sp)
 900:	6b02                	ld	s6,0(sp)
 902:	6121                	addi	sp,sp,64
 904:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 906:	6398                	ld	a4,0(a5)
 908:	e118                	sd	a4,0(a0)
 90a:	bff1                	j	8e6 <malloc+0x86>
  hp->s.size = nu;
 90c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 910:	0541                	addi	a0,a0,16
 912:	00000097          	auipc	ra,0x0
 916:	ec6080e7          	jalr	-314(ra) # 7d8 <free>
  return freep;
 91a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 91e:	d971                	beqz	a0,8f2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 920:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 922:	4798                	lw	a4,8(a5)
 924:	fa9776e3          	bgeu	a4,s1,8d0 <malloc+0x70>
    if(p == freep)
 928:	00093703          	ld	a4,0(s2)
 92c:	853e                	mv	a0,a5
 92e:	fef719e3          	bne	a4,a5,920 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 932:	8552                	mv	a0,s4
 934:	00000097          	auipc	ra,0x0
 938:	b1a080e7          	jalr	-1254(ra) # 44e <sbrk>
  if(p == (char*)-1)
 93c:	fd5518e3          	bne	a0,s5,90c <malloc+0xac>
        return 0;
 940:	4501                	li	a0,0
 942:	bf45                	j	8f2 <malloc+0x92>
