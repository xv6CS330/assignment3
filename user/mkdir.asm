
user/_mkdir:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  int i;

  if(argc < 2){
   e:	4785                	li	a5,1
  10:	02a7d763          	bge	a5,a0,3e <main+0x3e>
  14:	00858493          	addi	s1,a1,8
  18:	ffe5091b          	addiw	s2,a0,-2
  1c:	1902                	slli	s2,s2,0x20
  1e:	02095913          	srli	s2,s2,0x20
  22:	090e                	slli	s2,s2,0x3
  24:	05c1                	addi	a1,a1,16
  26:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: mkdir files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(mkdir(argv[i]) < 0){
  28:	6088                	ld	a0,0(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	32c080e7          	jalr	812(ra) # 356 <mkdir>
  32:	02054463          	bltz	a0,5a <main+0x5a>
  for(i = 1; i < argc; i++){
  36:	04a1                	addi	s1,s1,8
  38:	ff2498e3          	bne	s1,s2,28 <main+0x28>
  3c:	a80d                	j	6e <main+0x6e>
    fprintf(2, "Usage: mkdir files...\n");
  3e:	00001597          	auipc	a1,0x1
  42:	83258593          	addi	a1,a1,-1998 # 870 <malloc+0xe8>
  46:	4509                	li	a0,2
  48:	00000097          	auipc	ra,0x0
  4c:	654080e7          	jalr	1620(ra) # 69c <fprintf>
    exit(1);
  50:	4505                	li	a0,1
  52:	00000097          	auipc	ra,0x0
  56:	29c080e7          	jalr	668(ra) # 2ee <exit>
      fprintf(2, "mkdir: %s failed to create\n", argv[i]);
  5a:	6090                	ld	a2,0(s1)
  5c:	00001597          	auipc	a1,0x1
  60:	82c58593          	addi	a1,a1,-2004 # 888 <malloc+0x100>
  64:	4509                	li	a0,2
  66:	00000097          	auipc	ra,0x0
  6a:	636080e7          	jalr	1590(ra) # 69c <fprintf>
      break;
    }
  }

  exit(0);
  6e:	4501                	li	a0,0
  70:	00000097          	auipc	ra,0x0
  74:	27e080e7          	jalr	638(ra) # 2ee <exit>

0000000000000078 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e422                	sd	s0,8(sp)
  7c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7e:	87aa                	mv	a5,a0
  80:	0585                	addi	a1,a1,1
  82:	0785                	addi	a5,a5,1
  84:	fff5c703          	lbu	a4,-1(a1)
  88:	fee78fa3          	sb	a4,-1(a5)
  8c:	fb75                	bnez	a4,80 <strcpy+0x8>
    ;
  return os;
}
  8e:	6422                	ld	s0,8(sp)
  90:	0141                	addi	sp,sp,16
  92:	8082                	ret

0000000000000094 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  94:	1141                	addi	sp,sp,-16
  96:	e422                	sd	s0,8(sp)
  98:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  9a:	00054783          	lbu	a5,0(a0)
  9e:	cb91                	beqz	a5,b2 <strcmp+0x1e>
  a0:	0005c703          	lbu	a4,0(a1)
  a4:	00f71763          	bne	a4,a5,b2 <strcmp+0x1e>
    p++, q++;
  a8:	0505                	addi	a0,a0,1
  aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ac:	00054783          	lbu	a5,0(a0)
  b0:	fbe5                	bnez	a5,a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  b2:	0005c503          	lbu	a0,0(a1)
}
  b6:	40a7853b          	subw	a0,a5,a0
  ba:	6422                	ld	s0,8(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret

00000000000000c0 <strlen>:

uint
strlen(const char *s)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	cf91                	beqz	a5,e6 <strlen+0x26>
  cc:	0505                	addi	a0,a0,1
  ce:	87aa                	mv	a5,a0
  d0:	4685                	li	a3,1
  d2:	9e89                	subw	a3,a3,a0
  d4:	00f6853b          	addw	a0,a3,a5
  d8:	0785                	addi	a5,a5,1
  da:	fff7c703          	lbu	a4,-1(a5)
  de:	fb7d                	bnez	a4,d4 <strlen+0x14>
    ;
  return n;
}
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret
  for(n = 0; s[n]; n++)
  e6:	4501                	li	a0,0
  e8:	bfe5                	j	e0 <strlen+0x20>

00000000000000ea <memset>:

void*
memset(void *dst, int c, uint n)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e422                	sd	s0,8(sp)
  ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  f0:	ce09                	beqz	a2,10a <memset+0x20>
  f2:	87aa                	mv	a5,a0
  f4:	fff6071b          	addiw	a4,a2,-1
  f8:	1702                	slli	a4,a4,0x20
  fa:	9301                	srli	a4,a4,0x20
  fc:	0705                	addi	a4,a4,1
  fe:	972a                	add	a4,a4,a0
    cdst[i] = c;
 100:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 104:	0785                	addi	a5,a5,1
 106:	fee79de3          	bne	a5,a4,100 <memset+0x16>
  }
  return dst;
}
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret

0000000000000110 <strchr>:

char*
strchr(const char *s, char c)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  for(; *s; s++)
 116:	00054783          	lbu	a5,0(a0)
 11a:	cb99                	beqz	a5,130 <strchr+0x20>
    if(*s == c)
 11c:	00f58763          	beq	a1,a5,12a <strchr+0x1a>
  for(; *s; s++)
 120:	0505                	addi	a0,a0,1
 122:	00054783          	lbu	a5,0(a0)
 126:	fbfd                	bnez	a5,11c <strchr+0xc>
      return (char*)s;
  return 0;
 128:	4501                	li	a0,0
}
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret
  return 0;
 130:	4501                	li	a0,0
 132:	bfe5                	j	12a <strchr+0x1a>

0000000000000134 <gets>:

char*
gets(char *buf, int max)
{
 134:	711d                	addi	sp,sp,-96
 136:	ec86                	sd	ra,88(sp)
 138:	e8a2                	sd	s0,80(sp)
 13a:	e4a6                	sd	s1,72(sp)
 13c:	e0ca                	sd	s2,64(sp)
 13e:	fc4e                	sd	s3,56(sp)
 140:	f852                	sd	s4,48(sp)
 142:	f456                	sd	s5,40(sp)
 144:	f05a                	sd	s6,32(sp)
 146:	ec5e                	sd	s7,24(sp)
 148:	1080                	addi	s0,sp,96
 14a:	8baa                	mv	s7,a0
 14c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14e:	892a                	mv	s2,a0
 150:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 152:	4aa9                	li	s5,10
 154:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 156:	89a6                	mv	s3,s1
 158:	2485                	addiw	s1,s1,1
 15a:	0344d863          	bge	s1,s4,18a <gets+0x56>
    cc = read(0, &c, 1);
 15e:	4605                	li	a2,1
 160:	faf40593          	addi	a1,s0,-81
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	1a0080e7          	jalr	416(ra) # 306 <read>
    if(cc < 1)
 16e:	00a05e63          	blez	a0,18a <gets+0x56>
    buf[i++] = c;
 172:	faf44783          	lbu	a5,-81(s0)
 176:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 17a:	01578763          	beq	a5,s5,188 <gets+0x54>
 17e:	0905                	addi	s2,s2,1
 180:	fd679be3          	bne	a5,s6,156 <gets+0x22>
  for(i=0; i+1 < max; ){
 184:	89a6                	mv	s3,s1
 186:	a011                	j	18a <gets+0x56>
 188:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 18a:	99de                	add	s3,s3,s7
 18c:	00098023          	sb	zero,0(s3)
  return buf;
}
 190:	855e                	mv	a0,s7
 192:	60e6                	ld	ra,88(sp)
 194:	6446                	ld	s0,80(sp)
 196:	64a6                	ld	s1,72(sp)
 198:	6906                	ld	s2,64(sp)
 19a:	79e2                	ld	s3,56(sp)
 19c:	7a42                	ld	s4,48(sp)
 19e:	7aa2                	ld	s5,40(sp)
 1a0:	7b02                	ld	s6,32(sp)
 1a2:	6be2                	ld	s7,24(sp)
 1a4:	6125                	addi	sp,sp,96
 1a6:	8082                	ret

00000000000001a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1a8:	1101                	addi	sp,sp,-32
 1aa:	ec06                	sd	ra,24(sp)
 1ac:	e822                	sd	s0,16(sp)
 1ae:	e426                	sd	s1,8(sp)
 1b0:	e04a                	sd	s2,0(sp)
 1b2:	1000                	addi	s0,sp,32
 1b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b6:	4581                	li	a1,0
 1b8:	00000097          	auipc	ra,0x0
 1bc:	176080e7          	jalr	374(ra) # 32e <open>
  if(fd < 0)
 1c0:	02054563          	bltz	a0,1ea <stat+0x42>
 1c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c6:	85ca                	mv	a1,s2
 1c8:	00000097          	auipc	ra,0x0
 1cc:	17e080e7          	jalr	382(ra) # 346 <fstat>
 1d0:	892a                	mv	s2,a0
  close(fd);
 1d2:	8526                	mv	a0,s1
 1d4:	00000097          	auipc	ra,0x0
 1d8:	142080e7          	jalr	322(ra) # 316 <close>
  return r;
}
 1dc:	854a                	mv	a0,s2
 1de:	60e2                	ld	ra,24(sp)
 1e0:	6442                	ld	s0,16(sp)
 1e2:	64a2                	ld	s1,8(sp)
 1e4:	6902                	ld	s2,0(sp)
 1e6:	6105                	addi	sp,sp,32
 1e8:	8082                	ret
    return -1;
 1ea:	597d                	li	s2,-1
 1ec:	bfc5                	j	1dc <stat+0x34>

00000000000001ee <atoi>:

int
atoi(const char *s)
{
 1ee:	1141                	addi	sp,sp,-16
 1f0:	e422                	sd	s0,8(sp)
 1f2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f4:	00054603          	lbu	a2,0(a0)
 1f8:	fd06079b          	addiw	a5,a2,-48
 1fc:	0ff7f793          	andi	a5,a5,255
 200:	4725                	li	a4,9
 202:	02f76963          	bltu	a4,a5,234 <atoi+0x46>
 206:	86aa                	mv	a3,a0
  n = 0;
 208:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 20a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 20c:	0685                	addi	a3,a3,1
 20e:	0025179b          	slliw	a5,a0,0x2
 212:	9fa9                	addw	a5,a5,a0
 214:	0017979b          	slliw	a5,a5,0x1
 218:	9fb1                	addw	a5,a5,a2
 21a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21e:	0006c603          	lbu	a2,0(a3)
 222:	fd06071b          	addiw	a4,a2,-48
 226:	0ff77713          	andi	a4,a4,255
 22a:	fee5f1e3          	bgeu	a1,a4,20c <atoi+0x1e>
  return n;
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
  n = 0;
 234:	4501                	li	a0,0
 236:	bfe5                	j	22e <atoi+0x40>

0000000000000238 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23e:	02b57663          	bgeu	a0,a1,26a <memmove+0x32>
    while(n-- > 0)
 242:	02c05163          	blez	a2,264 <memmove+0x2c>
 246:	fff6079b          	addiw	a5,a2,-1
 24a:	1782                	slli	a5,a5,0x20
 24c:	9381                	srli	a5,a5,0x20
 24e:	0785                	addi	a5,a5,1
 250:	97aa                	add	a5,a5,a0
  dst = vdst;
 252:	872a                	mv	a4,a0
      *dst++ = *src++;
 254:	0585                	addi	a1,a1,1
 256:	0705                	addi	a4,a4,1
 258:	fff5c683          	lbu	a3,-1(a1)
 25c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 260:	fee79ae3          	bne	a5,a4,254 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret
    dst += n;
 26a:	00c50733          	add	a4,a0,a2
    src += n;
 26e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 270:	fec05ae3          	blez	a2,264 <memmove+0x2c>
 274:	fff6079b          	addiw	a5,a2,-1
 278:	1782                	slli	a5,a5,0x20
 27a:	9381                	srli	a5,a5,0x20
 27c:	fff7c793          	not	a5,a5
 280:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 282:	15fd                	addi	a1,a1,-1
 284:	177d                	addi	a4,a4,-1
 286:	0005c683          	lbu	a3,0(a1)
 28a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 28e:	fee79ae3          	bne	a5,a4,282 <memmove+0x4a>
 292:	bfc9                	j	264 <memmove+0x2c>

0000000000000294 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 29a:	ca05                	beqz	a2,2ca <memcmp+0x36>
 29c:	fff6069b          	addiw	a3,a2,-1
 2a0:	1682                	slli	a3,a3,0x20
 2a2:	9281                	srli	a3,a3,0x20
 2a4:	0685                	addi	a3,a3,1
 2a6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a8:	00054783          	lbu	a5,0(a0)
 2ac:	0005c703          	lbu	a4,0(a1)
 2b0:	00e79863          	bne	a5,a4,2c0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b4:	0505                	addi	a0,a0,1
    p2++;
 2b6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b8:	fed518e3          	bne	a0,a3,2a8 <memcmp+0x14>
  }
  return 0;
 2bc:	4501                	li	a0,0
 2be:	a019                	j	2c4 <memcmp+0x30>
      return *p1 - *p2;
 2c0:	40e7853b          	subw	a0,a5,a4
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret
  return 0;
 2ca:	4501                	li	a0,0
 2cc:	bfe5                	j	2c4 <memcmp+0x30>

00000000000002ce <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e406                	sd	ra,8(sp)
 2d2:	e022                	sd	s0,0(sp)
 2d4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d6:	00000097          	auipc	ra,0x0
 2da:	f62080e7          	jalr	-158(ra) # 238 <memmove>
}
 2de:	60a2                	ld	ra,8(sp)
 2e0:	6402                	ld	s0,0(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret

00000000000002e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e6:	4885                	li	a7,1
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ee:	4889                	li	a7,2
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f6:	488d                	li	a7,3
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fe:	4891                	li	a7,4
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <read>:
.global read
read:
 li a7, SYS_read
 306:	4895                	li	a7,5
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <write>:
.global write
write:
 li a7, SYS_write
 30e:	48c1                	li	a7,16
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <close>:
.global close
close:
 li a7, SYS_close
 316:	48d5                	li	a7,21
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <kill>:
.global kill
kill:
 li a7, SYS_kill
 31e:	4899                	li	a7,6
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <exec>:
.global exec
exec:
 li a7, SYS_exec
 326:	489d                	li	a7,7
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <open>:
.global open
open:
 li a7, SYS_open
 32e:	48bd                	li	a7,15
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 336:	48c5                	li	a7,17
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33e:	48c9                	li	a7,18
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 346:	48a1                	li	a7,8
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <link>:
.global link
link:
 li a7, SYS_link
 34e:	48cd                	li	a7,19
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 356:	48d1                	li	a7,20
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35e:	48a5                	li	a7,9
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <dup>:
.global dup
dup:
 li a7, SYS_dup
 366:	48a9                	li	a7,10
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36e:	48ad                	li	a7,11
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 376:	48b1                	li	a7,12
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 37e:	48b5                	li	a7,13
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 386:	48b9                	li	a7,14
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 38e:	48d9                	li	a7,22
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <yield>:
.global yield
yield:
 li a7, SYS_yield
 396:	48dd                	li	a7,23
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 39e:	48e1                	li	a7,24
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 3a6:	48e5                	li	a7,25
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3ae:	48e9                	li	a7,26
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <ps>:
.global ps
ps:
 li a7, SYS_ps
 3b6:	48ed                	li	a7,27
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 3be:	48f1                	li	a7,28
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 3c6:	48f5                	li	a7,29
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 3ce:	48f9                	li	a7,30
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 3d6:	48fd                	li	a7,31
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 3de:	02000893          	li	a7,32
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 3e8:	02100893          	li	a7,33
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f2:	1101                	addi	sp,sp,-32
 3f4:	ec06                	sd	ra,24(sp)
 3f6:	e822                	sd	s0,16(sp)
 3f8:	1000                	addi	s0,sp,32
 3fa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3fe:	4605                	li	a2,1
 400:	fef40593          	addi	a1,s0,-17
 404:	00000097          	auipc	ra,0x0
 408:	f0a080e7          	jalr	-246(ra) # 30e <write>
}
 40c:	60e2                	ld	ra,24(sp)
 40e:	6442                	ld	s0,16(sp)
 410:	6105                	addi	sp,sp,32
 412:	8082                	ret

0000000000000414 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 414:	7139                	addi	sp,sp,-64
 416:	fc06                	sd	ra,56(sp)
 418:	f822                	sd	s0,48(sp)
 41a:	f426                	sd	s1,40(sp)
 41c:	f04a                	sd	s2,32(sp)
 41e:	ec4e                	sd	s3,24(sp)
 420:	0080                	addi	s0,sp,64
 422:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 424:	c299                	beqz	a3,42a <printint+0x16>
 426:	0805c863          	bltz	a1,4b6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 42a:	2581                	sext.w	a1,a1
  neg = 0;
 42c:	4881                	li	a7,0
 42e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 432:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 434:	2601                	sext.w	a2,a2
 436:	00000517          	auipc	a0,0x0
 43a:	47a50513          	addi	a0,a0,1146 # 8b0 <digits>
 43e:	883a                	mv	a6,a4
 440:	2705                	addiw	a4,a4,1
 442:	02c5f7bb          	remuw	a5,a1,a2
 446:	1782                	slli	a5,a5,0x20
 448:	9381                	srli	a5,a5,0x20
 44a:	97aa                	add	a5,a5,a0
 44c:	0007c783          	lbu	a5,0(a5)
 450:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 454:	0005879b          	sext.w	a5,a1
 458:	02c5d5bb          	divuw	a1,a1,a2
 45c:	0685                	addi	a3,a3,1
 45e:	fec7f0e3          	bgeu	a5,a2,43e <printint+0x2a>
  if(neg)
 462:	00088b63          	beqz	a7,478 <printint+0x64>
    buf[i++] = '-';
 466:	fd040793          	addi	a5,s0,-48
 46a:	973e                	add	a4,a4,a5
 46c:	02d00793          	li	a5,45
 470:	fef70823          	sb	a5,-16(a4)
 474:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 478:	02e05863          	blez	a4,4a8 <printint+0x94>
 47c:	fc040793          	addi	a5,s0,-64
 480:	00e78933          	add	s2,a5,a4
 484:	fff78993          	addi	s3,a5,-1
 488:	99ba                	add	s3,s3,a4
 48a:	377d                	addiw	a4,a4,-1
 48c:	1702                	slli	a4,a4,0x20
 48e:	9301                	srli	a4,a4,0x20
 490:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 494:	fff94583          	lbu	a1,-1(s2)
 498:	8526                	mv	a0,s1
 49a:	00000097          	auipc	ra,0x0
 49e:	f58080e7          	jalr	-168(ra) # 3f2 <putc>
  while(--i >= 0)
 4a2:	197d                	addi	s2,s2,-1
 4a4:	ff3918e3          	bne	s2,s3,494 <printint+0x80>
}
 4a8:	70e2                	ld	ra,56(sp)
 4aa:	7442                	ld	s0,48(sp)
 4ac:	74a2                	ld	s1,40(sp)
 4ae:	7902                	ld	s2,32(sp)
 4b0:	69e2                	ld	s3,24(sp)
 4b2:	6121                	addi	sp,sp,64
 4b4:	8082                	ret
    x = -xx;
 4b6:	40b005bb          	negw	a1,a1
    neg = 1;
 4ba:	4885                	li	a7,1
    x = -xx;
 4bc:	bf8d                	j	42e <printint+0x1a>

00000000000004be <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4be:	7119                	addi	sp,sp,-128
 4c0:	fc86                	sd	ra,120(sp)
 4c2:	f8a2                	sd	s0,112(sp)
 4c4:	f4a6                	sd	s1,104(sp)
 4c6:	f0ca                	sd	s2,96(sp)
 4c8:	ecce                	sd	s3,88(sp)
 4ca:	e8d2                	sd	s4,80(sp)
 4cc:	e4d6                	sd	s5,72(sp)
 4ce:	e0da                	sd	s6,64(sp)
 4d0:	fc5e                	sd	s7,56(sp)
 4d2:	f862                	sd	s8,48(sp)
 4d4:	f466                	sd	s9,40(sp)
 4d6:	f06a                	sd	s10,32(sp)
 4d8:	ec6e                	sd	s11,24(sp)
 4da:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4dc:	0005c903          	lbu	s2,0(a1)
 4e0:	18090f63          	beqz	s2,67e <vprintf+0x1c0>
 4e4:	8aaa                	mv	s5,a0
 4e6:	8b32                	mv	s6,a2
 4e8:	00158493          	addi	s1,a1,1
  state = 0;
 4ec:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ee:	02500a13          	li	s4,37
      if(c == 'd'){
 4f2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4f6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4fa:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4fe:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 502:	00000b97          	auipc	s7,0x0
 506:	3aeb8b93          	addi	s7,s7,942 # 8b0 <digits>
 50a:	a839                	j	528 <vprintf+0x6a>
        putc(fd, c);
 50c:	85ca                	mv	a1,s2
 50e:	8556                	mv	a0,s5
 510:	00000097          	auipc	ra,0x0
 514:	ee2080e7          	jalr	-286(ra) # 3f2 <putc>
 518:	a019                	j	51e <vprintf+0x60>
    } else if(state == '%'){
 51a:	01498f63          	beq	s3,s4,538 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 51e:	0485                	addi	s1,s1,1
 520:	fff4c903          	lbu	s2,-1(s1)
 524:	14090d63          	beqz	s2,67e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 528:	0009079b          	sext.w	a5,s2
    if(state == 0){
 52c:	fe0997e3          	bnez	s3,51a <vprintf+0x5c>
      if(c == '%'){
 530:	fd479ee3          	bne	a5,s4,50c <vprintf+0x4e>
        state = '%';
 534:	89be                	mv	s3,a5
 536:	b7e5                	j	51e <vprintf+0x60>
      if(c == 'd'){
 538:	05878063          	beq	a5,s8,578 <vprintf+0xba>
      } else if(c == 'l') {
 53c:	05978c63          	beq	a5,s9,594 <vprintf+0xd6>
      } else if(c == 'x') {
 540:	07a78863          	beq	a5,s10,5b0 <vprintf+0xf2>
      } else if(c == 'p') {
 544:	09b78463          	beq	a5,s11,5cc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 548:	07300713          	li	a4,115
 54c:	0ce78663          	beq	a5,a4,618 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 550:	06300713          	li	a4,99
 554:	0ee78e63          	beq	a5,a4,650 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 558:	11478863          	beq	a5,s4,668 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 55c:	85d2                	mv	a1,s4
 55e:	8556                	mv	a0,s5
 560:	00000097          	auipc	ra,0x0
 564:	e92080e7          	jalr	-366(ra) # 3f2 <putc>
        putc(fd, c);
 568:	85ca                	mv	a1,s2
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	e86080e7          	jalr	-378(ra) # 3f2 <putc>
      }
      state = 0;
 574:	4981                	li	s3,0
 576:	b765                	j	51e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 578:	008b0913          	addi	s2,s6,8
 57c:	4685                	li	a3,1
 57e:	4629                	li	a2,10
 580:	000b2583          	lw	a1,0(s6)
 584:	8556                	mv	a0,s5
 586:	00000097          	auipc	ra,0x0
 58a:	e8e080e7          	jalr	-370(ra) # 414 <printint>
 58e:	8b4a                	mv	s6,s2
      state = 0;
 590:	4981                	li	s3,0
 592:	b771                	j	51e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 594:	008b0913          	addi	s2,s6,8
 598:	4681                	li	a3,0
 59a:	4629                	li	a2,10
 59c:	000b2583          	lw	a1,0(s6)
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e72080e7          	jalr	-398(ra) # 414 <printint>
 5aa:	8b4a                	mv	s6,s2
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	bf85                	j	51e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5b0:	008b0913          	addi	s2,s6,8
 5b4:	4681                	li	a3,0
 5b6:	4641                	li	a2,16
 5b8:	000b2583          	lw	a1,0(s6)
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e56080e7          	jalr	-426(ra) # 414 <printint>
 5c6:	8b4a                	mv	s6,s2
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	bf91                	j	51e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5cc:	008b0793          	addi	a5,s6,8
 5d0:	f8f43423          	sd	a5,-120(s0)
 5d4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5d8:	03000593          	li	a1,48
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	e14080e7          	jalr	-492(ra) # 3f2 <putc>
  putc(fd, 'x');
 5e6:	85ea                	mv	a1,s10
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	e08080e7          	jalr	-504(ra) # 3f2 <putc>
 5f2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f4:	03c9d793          	srli	a5,s3,0x3c
 5f8:	97de                	add	a5,a5,s7
 5fa:	0007c583          	lbu	a1,0(a5)
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	df2080e7          	jalr	-526(ra) # 3f2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 608:	0992                	slli	s3,s3,0x4
 60a:	397d                	addiw	s2,s2,-1
 60c:	fe0914e3          	bnez	s2,5f4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 610:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 614:	4981                	li	s3,0
 616:	b721                	j	51e <vprintf+0x60>
        s = va_arg(ap, char*);
 618:	008b0993          	addi	s3,s6,8
 61c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 620:	02090163          	beqz	s2,642 <vprintf+0x184>
        while(*s != 0){
 624:	00094583          	lbu	a1,0(s2)
 628:	c9a1                	beqz	a1,678 <vprintf+0x1ba>
          putc(fd, *s);
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	dc6080e7          	jalr	-570(ra) # 3f2 <putc>
          s++;
 634:	0905                	addi	s2,s2,1
        while(*s != 0){
 636:	00094583          	lbu	a1,0(s2)
 63a:	f9e5                	bnez	a1,62a <vprintf+0x16c>
        s = va_arg(ap, char*);
 63c:	8b4e                	mv	s6,s3
      state = 0;
 63e:	4981                	li	s3,0
 640:	bdf9                	j	51e <vprintf+0x60>
          s = "(null)";
 642:	00000917          	auipc	s2,0x0
 646:	26690913          	addi	s2,s2,614 # 8a8 <malloc+0x120>
        while(*s != 0){
 64a:	02800593          	li	a1,40
 64e:	bff1                	j	62a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 650:	008b0913          	addi	s2,s6,8
 654:	000b4583          	lbu	a1,0(s6)
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	d98080e7          	jalr	-616(ra) # 3f2 <putc>
 662:	8b4a                	mv	s6,s2
      state = 0;
 664:	4981                	li	s3,0
 666:	bd65                	j	51e <vprintf+0x60>
        putc(fd, c);
 668:	85d2                	mv	a1,s4
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	d86080e7          	jalr	-634(ra) # 3f2 <putc>
      state = 0;
 674:	4981                	li	s3,0
 676:	b565                	j	51e <vprintf+0x60>
        s = va_arg(ap, char*);
 678:	8b4e                	mv	s6,s3
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b54d                	j	51e <vprintf+0x60>
    }
  }
}
 67e:	70e6                	ld	ra,120(sp)
 680:	7446                	ld	s0,112(sp)
 682:	74a6                	ld	s1,104(sp)
 684:	7906                	ld	s2,96(sp)
 686:	69e6                	ld	s3,88(sp)
 688:	6a46                	ld	s4,80(sp)
 68a:	6aa6                	ld	s5,72(sp)
 68c:	6b06                	ld	s6,64(sp)
 68e:	7be2                	ld	s7,56(sp)
 690:	7c42                	ld	s8,48(sp)
 692:	7ca2                	ld	s9,40(sp)
 694:	7d02                	ld	s10,32(sp)
 696:	6de2                	ld	s11,24(sp)
 698:	6109                	addi	sp,sp,128
 69a:	8082                	ret

000000000000069c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 69c:	715d                	addi	sp,sp,-80
 69e:	ec06                	sd	ra,24(sp)
 6a0:	e822                	sd	s0,16(sp)
 6a2:	1000                	addi	s0,sp,32
 6a4:	e010                	sd	a2,0(s0)
 6a6:	e414                	sd	a3,8(s0)
 6a8:	e818                	sd	a4,16(s0)
 6aa:	ec1c                	sd	a5,24(s0)
 6ac:	03043023          	sd	a6,32(s0)
 6b0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6b4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b8:	8622                	mv	a2,s0
 6ba:	00000097          	auipc	ra,0x0
 6be:	e04080e7          	jalr	-508(ra) # 4be <vprintf>
}
 6c2:	60e2                	ld	ra,24(sp)
 6c4:	6442                	ld	s0,16(sp)
 6c6:	6161                	addi	sp,sp,80
 6c8:	8082                	ret

00000000000006ca <printf>:

void
printf(const char *fmt, ...)
{
 6ca:	711d                	addi	sp,sp,-96
 6cc:	ec06                	sd	ra,24(sp)
 6ce:	e822                	sd	s0,16(sp)
 6d0:	1000                	addi	s0,sp,32
 6d2:	e40c                	sd	a1,8(s0)
 6d4:	e810                	sd	a2,16(s0)
 6d6:	ec14                	sd	a3,24(s0)
 6d8:	f018                	sd	a4,32(s0)
 6da:	f41c                	sd	a5,40(s0)
 6dc:	03043823          	sd	a6,48(s0)
 6e0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6e4:	00840613          	addi	a2,s0,8
 6e8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6ec:	85aa                	mv	a1,a0
 6ee:	4505                	li	a0,1
 6f0:	00000097          	auipc	ra,0x0
 6f4:	dce080e7          	jalr	-562(ra) # 4be <vprintf>
}
 6f8:	60e2                	ld	ra,24(sp)
 6fa:	6442                	ld	s0,16(sp)
 6fc:	6125                	addi	sp,sp,96
 6fe:	8082                	ret

0000000000000700 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 700:	1141                	addi	sp,sp,-16
 702:	e422                	sd	s0,8(sp)
 704:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 706:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70a:	00000797          	auipc	a5,0x0
 70e:	1be7b783          	ld	a5,446(a5) # 8c8 <freep>
 712:	a805                	j	742 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 714:	4618                	lw	a4,8(a2)
 716:	9db9                	addw	a1,a1,a4
 718:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 71c:	6398                	ld	a4,0(a5)
 71e:	6318                	ld	a4,0(a4)
 720:	fee53823          	sd	a4,-16(a0)
 724:	a091                	j	768 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 726:	ff852703          	lw	a4,-8(a0)
 72a:	9e39                	addw	a2,a2,a4
 72c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 72e:	ff053703          	ld	a4,-16(a0)
 732:	e398                	sd	a4,0(a5)
 734:	a099                	j	77a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 736:	6398                	ld	a4,0(a5)
 738:	00e7e463          	bltu	a5,a4,740 <free+0x40>
 73c:	00e6ea63          	bltu	a3,a4,750 <free+0x50>
{
 740:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 742:	fed7fae3          	bgeu	a5,a3,736 <free+0x36>
 746:	6398                	ld	a4,0(a5)
 748:	00e6e463          	bltu	a3,a4,750 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74c:	fee7eae3          	bltu	a5,a4,740 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 750:	ff852583          	lw	a1,-8(a0)
 754:	6390                	ld	a2,0(a5)
 756:	02059713          	slli	a4,a1,0x20
 75a:	9301                	srli	a4,a4,0x20
 75c:	0712                	slli	a4,a4,0x4
 75e:	9736                	add	a4,a4,a3
 760:	fae60ae3          	beq	a2,a4,714 <free+0x14>
    bp->s.ptr = p->s.ptr;
 764:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 768:	4790                	lw	a2,8(a5)
 76a:	02061713          	slli	a4,a2,0x20
 76e:	9301                	srli	a4,a4,0x20
 770:	0712                	slli	a4,a4,0x4
 772:	973e                	add	a4,a4,a5
 774:	fae689e3          	beq	a3,a4,726 <free+0x26>
  } else
    p->s.ptr = bp;
 778:	e394                	sd	a3,0(a5)
  freep = p;
 77a:	00000717          	auipc	a4,0x0
 77e:	14f73723          	sd	a5,334(a4) # 8c8 <freep>
}
 782:	6422                	ld	s0,8(sp)
 784:	0141                	addi	sp,sp,16
 786:	8082                	ret

0000000000000788 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 788:	7139                	addi	sp,sp,-64
 78a:	fc06                	sd	ra,56(sp)
 78c:	f822                	sd	s0,48(sp)
 78e:	f426                	sd	s1,40(sp)
 790:	f04a                	sd	s2,32(sp)
 792:	ec4e                	sd	s3,24(sp)
 794:	e852                	sd	s4,16(sp)
 796:	e456                	sd	s5,8(sp)
 798:	e05a                	sd	s6,0(sp)
 79a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79c:	02051493          	slli	s1,a0,0x20
 7a0:	9081                	srli	s1,s1,0x20
 7a2:	04bd                	addi	s1,s1,15
 7a4:	8091                	srli	s1,s1,0x4
 7a6:	0014899b          	addiw	s3,s1,1
 7aa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7ac:	00000517          	auipc	a0,0x0
 7b0:	11c53503          	ld	a0,284(a0) # 8c8 <freep>
 7b4:	c515                	beqz	a0,7e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b8:	4798                	lw	a4,8(a5)
 7ba:	02977f63          	bgeu	a4,s1,7f8 <malloc+0x70>
 7be:	8a4e                	mv	s4,s3
 7c0:	0009871b          	sext.w	a4,s3
 7c4:	6685                	lui	a3,0x1
 7c6:	00d77363          	bgeu	a4,a3,7cc <malloc+0x44>
 7ca:	6a05                	lui	s4,0x1
 7cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d4:	00000917          	auipc	s2,0x0
 7d8:	0f490913          	addi	s2,s2,244 # 8c8 <freep>
  if(p == (char*)-1)
 7dc:	5afd                	li	s5,-1
 7de:	a88d                	j	850 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7e0:	00000797          	auipc	a5,0x0
 7e4:	0f078793          	addi	a5,a5,240 # 8d0 <base>
 7e8:	00000717          	auipc	a4,0x0
 7ec:	0ef73023          	sd	a5,224(a4) # 8c8 <freep>
 7f0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7f2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f6:	b7e1                	j	7be <malloc+0x36>
      if(p->s.size == nunits)
 7f8:	02e48b63          	beq	s1,a4,82e <malloc+0xa6>
        p->s.size -= nunits;
 7fc:	4137073b          	subw	a4,a4,s3
 800:	c798                	sw	a4,8(a5)
        p += p->s.size;
 802:	1702                	slli	a4,a4,0x20
 804:	9301                	srli	a4,a4,0x20
 806:	0712                	slli	a4,a4,0x4
 808:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 80a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 80e:	00000717          	auipc	a4,0x0
 812:	0aa73d23          	sd	a0,186(a4) # 8c8 <freep>
      return (void*)(p + 1);
 816:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 81a:	70e2                	ld	ra,56(sp)
 81c:	7442                	ld	s0,48(sp)
 81e:	74a2                	ld	s1,40(sp)
 820:	7902                	ld	s2,32(sp)
 822:	69e2                	ld	s3,24(sp)
 824:	6a42                	ld	s4,16(sp)
 826:	6aa2                	ld	s5,8(sp)
 828:	6b02                	ld	s6,0(sp)
 82a:	6121                	addi	sp,sp,64
 82c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 82e:	6398                	ld	a4,0(a5)
 830:	e118                	sd	a4,0(a0)
 832:	bff1                	j	80e <malloc+0x86>
  hp->s.size = nu;
 834:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 838:	0541                	addi	a0,a0,16
 83a:	00000097          	auipc	ra,0x0
 83e:	ec6080e7          	jalr	-314(ra) # 700 <free>
  return freep;
 842:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 846:	d971                	beqz	a0,81a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 848:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84a:	4798                	lw	a4,8(a5)
 84c:	fa9776e3          	bgeu	a4,s1,7f8 <malloc+0x70>
    if(p == freep)
 850:	00093703          	ld	a4,0(s2)
 854:	853e                	mv	a0,a5
 856:	fef719e3          	bne	a4,a5,848 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 85a:	8552                	mv	a0,s4
 85c:	00000097          	auipc	ra,0x0
 860:	b1a080e7          	jalr	-1254(ra) # 376 <sbrk>
  if(p == (char*)-1)
 864:	fd5518e3          	bne	a0,s5,834 <malloc+0xac>
        return 0;
 868:	4501                	li	a0,0
 86a:	bf45                	j	81a <malloc+0x92>
