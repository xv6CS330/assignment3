
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	30c080e7          	jalr	780(ra) # 31c <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	2e0080e7          	jalr	736(ra) # 31c <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	2be080e7          	jalr	702(ra) # 31c <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	afa98993          	addi	s3,s3,-1286 # b60 <buf.1136>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	41e080e7          	jalr	1054(ra) # 494 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	29c080e7          	jalr	668(ra) # 31c <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	28e080e7          	jalr	654(ra) # 31c <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	29e080e7          	jalr	670(ra) # 346 <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	d9010113          	addi	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	24913c23          	sd	s1,600(sp)
  c4:	25213823          	sd	s2,592(sp)
  c8:	25313423          	sd	s3,584(sp)
  cc:	25413023          	sd	s4,576(sp)
  d0:	23513c23          	sd	s5,568(sp)
  d4:	1c80                	addi	s0,sp,624
  d6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  d8:	4581                	li	a1,0
  da:	00000097          	auipc	ra,0x0
  de:	4b0080e7          	jalr	1200(ra) # 58a <open>
  e2:	06054f63          	bltz	a0,160 <ls+0xac>
  e6:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  e8:	d9840593          	addi	a1,s0,-616
  ec:	00000097          	auipc	ra,0x0
  f0:	4b6080e7          	jalr	1206(ra) # 5a2 <fstat>
  f4:	08054163          	bltz	a0,176 <ls+0xc2>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  f8:	da041783          	lh	a5,-608(s0)
  fc:	0007869b          	sext.w	a3,a5
 100:	4705                	li	a4,1
 102:	08e68a63          	beq	a3,a4,196 <ls+0xe2>
 106:	4709                	li	a4,2
 108:	02e69663          	bne	a3,a4,134 <ls+0x80>
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 10c:	854a                	mv	a0,s2
 10e:	00000097          	auipc	ra,0x0
 112:	ef2080e7          	jalr	-270(ra) # 0 <fmtname>
 116:	85aa                	mv	a1,a0
 118:	da843703          	ld	a4,-600(s0)
 11c:	d9c42683          	lw	a3,-612(s0)
 120:	da041603          	lh	a2,-608(s0)
 124:	00001517          	auipc	a0,0x1
 128:	9d450513          	addi	a0,a0,-1580 # af8 <malloc+0x114>
 12c:	00000097          	auipc	ra,0x0
 130:	7fa080e7          	jalr	2042(ra) # 926 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 134:	8526                	mv	a0,s1
 136:	00000097          	auipc	ra,0x0
 13a:	43c080e7          	jalr	1084(ra) # 572 <close>
}
 13e:	26813083          	ld	ra,616(sp)
 142:	26013403          	ld	s0,608(sp)
 146:	25813483          	ld	s1,600(sp)
 14a:	25013903          	ld	s2,592(sp)
 14e:	24813983          	ld	s3,584(sp)
 152:	24013a03          	ld	s4,576(sp)
 156:	23813a83          	ld	s5,568(sp)
 15a:	27010113          	addi	sp,sp,624
 15e:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 160:	864a                	mv	a2,s2
 162:	00001597          	auipc	a1,0x1
 166:	96658593          	addi	a1,a1,-1690 # ac8 <malloc+0xe4>
 16a:	4509                	li	a0,2
 16c:	00000097          	auipc	ra,0x0
 170:	78c080e7          	jalr	1932(ra) # 8f8 <fprintf>
    return;
 174:	b7e9                	j	13e <ls+0x8a>
    fprintf(2, "ls: cannot stat %s\n", path);
 176:	864a                	mv	a2,s2
 178:	00001597          	auipc	a1,0x1
 17c:	96858593          	addi	a1,a1,-1688 # ae0 <malloc+0xfc>
 180:	4509                	li	a0,2
 182:	00000097          	auipc	ra,0x0
 186:	776080e7          	jalr	1910(ra) # 8f8 <fprintf>
    close(fd);
 18a:	8526                	mv	a0,s1
 18c:	00000097          	auipc	ra,0x0
 190:	3e6080e7          	jalr	998(ra) # 572 <close>
    return;
 194:	b76d                	j	13e <ls+0x8a>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 196:	854a                	mv	a0,s2
 198:	00000097          	auipc	ra,0x0
 19c:	184080e7          	jalr	388(ra) # 31c <strlen>
 1a0:	2541                	addiw	a0,a0,16
 1a2:	20000793          	li	a5,512
 1a6:	00a7fb63          	bgeu	a5,a0,1bc <ls+0x108>
      printf("ls: path too long\n");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	95e50513          	addi	a0,a0,-1698 # b08 <malloc+0x124>
 1b2:	00000097          	auipc	ra,0x0
 1b6:	774080e7          	jalr	1908(ra) # 926 <printf>
      break;
 1ba:	bfad                	j	134 <ls+0x80>
    strcpy(buf, path);
 1bc:	85ca                	mv	a1,s2
 1be:	dc040513          	addi	a0,s0,-576
 1c2:	00000097          	auipc	ra,0x0
 1c6:	112080e7          	jalr	274(ra) # 2d4 <strcpy>
    p = buf+strlen(buf);
 1ca:	dc040513          	addi	a0,s0,-576
 1ce:	00000097          	auipc	ra,0x0
 1d2:	14e080e7          	jalr	334(ra) # 31c <strlen>
 1d6:	02051913          	slli	s2,a0,0x20
 1da:	02095913          	srli	s2,s2,0x20
 1de:	dc040793          	addi	a5,s0,-576
 1e2:	993e                	add	s2,s2,a5
    *p++ = '/';
 1e4:	00190993          	addi	s3,s2,1
 1e8:	02f00793          	li	a5,47
 1ec:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 1f0:	00001a17          	auipc	s4,0x1
 1f4:	930a0a13          	addi	s4,s4,-1744 # b20 <malloc+0x13c>
        printf("ls: cannot stat %s\n", buf);
 1f8:	00001a97          	auipc	s5,0x1
 1fc:	8e8a8a93          	addi	s5,s5,-1816 # ae0 <malloc+0xfc>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 200:	a801                	j	210 <ls+0x15c>
        printf("ls: cannot stat %s\n", buf);
 202:	dc040593          	addi	a1,s0,-576
 206:	8556                	mv	a0,s5
 208:	00000097          	auipc	ra,0x0
 20c:	71e080e7          	jalr	1822(ra) # 926 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 210:	4641                	li	a2,16
 212:	db040593          	addi	a1,s0,-592
 216:	8526                	mv	a0,s1
 218:	00000097          	auipc	ra,0x0
 21c:	34a080e7          	jalr	842(ra) # 562 <read>
 220:	47c1                	li	a5,16
 222:	f0f519e3          	bne	a0,a5,134 <ls+0x80>
      if(de.inum == 0)
 226:	db045783          	lhu	a5,-592(s0)
 22a:	d3fd                	beqz	a5,210 <ls+0x15c>
      memmove(p, de.name, DIRSIZ);
 22c:	4639                	li	a2,14
 22e:	db240593          	addi	a1,s0,-590
 232:	854e                	mv	a0,s3
 234:	00000097          	auipc	ra,0x0
 238:	260080e7          	jalr	608(ra) # 494 <memmove>
      p[DIRSIZ] = 0;
 23c:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 240:	d9840593          	addi	a1,s0,-616
 244:	dc040513          	addi	a0,s0,-576
 248:	00000097          	auipc	ra,0x0
 24c:	1bc080e7          	jalr	444(ra) # 404 <stat>
 250:	fa0549e3          	bltz	a0,202 <ls+0x14e>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 254:	dc040513          	addi	a0,s0,-576
 258:	00000097          	auipc	ra,0x0
 25c:	da8080e7          	jalr	-600(ra) # 0 <fmtname>
 260:	85aa                	mv	a1,a0
 262:	da843703          	ld	a4,-600(s0)
 266:	d9c42683          	lw	a3,-612(s0)
 26a:	da041603          	lh	a2,-608(s0)
 26e:	8552                	mv	a0,s4
 270:	00000097          	auipc	ra,0x0
 274:	6b6080e7          	jalr	1718(ra) # 926 <printf>
 278:	bf61                	j	210 <ls+0x15c>

000000000000027a <main>:

int
main(int argc, char *argv[])
{
 27a:	1101                	addi	sp,sp,-32
 27c:	ec06                	sd	ra,24(sp)
 27e:	e822                	sd	s0,16(sp)
 280:	e426                	sd	s1,8(sp)
 282:	e04a                	sd	s2,0(sp)
 284:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 286:	4785                	li	a5,1
 288:	02a7d963          	bge	a5,a0,2ba <main+0x40>
 28c:	00858493          	addi	s1,a1,8
 290:	ffe5091b          	addiw	s2,a0,-2
 294:	1902                	slli	s2,s2,0x20
 296:	02095913          	srli	s2,s2,0x20
 29a:	090e                	slli	s2,s2,0x3
 29c:	05c1                	addi	a1,a1,16
 29e:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 2a0:	6088                	ld	a0,0(s1)
 2a2:	00000097          	auipc	ra,0x0
 2a6:	e12080e7          	jalr	-494(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 2aa:	04a1                	addi	s1,s1,8
 2ac:	ff249ae3          	bne	s1,s2,2a0 <main+0x26>
  exit(0);
 2b0:	4501                	li	a0,0
 2b2:	00000097          	auipc	ra,0x0
 2b6:	298080e7          	jalr	664(ra) # 54a <exit>
    ls(".");
 2ba:	00001517          	auipc	a0,0x1
 2be:	87650513          	addi	a0,a0,-1930 # b30 <malloc+0x14c>
 2c2:	00000097          	auipc	ra,0x0
 2c6:	df2080e7          	jalr	-526(ra) # b4 <ls>
    exit(0);
 2ca:	4501                	li	a0,0
 2cc:	00000097          	auipc	ra,0x0
 2d0:	27e080e7          	jalr	638(ra) # 54a <exit>

00000000000002d4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2da:	87aa                	mv	a5,a0
 2dc:	0585                	addi	a1,a1,1
 2de:	0785                	addi	a5,a5,1
 2e0:	fff5c703          	lbu	a4,-1(a1)
 2e4:	fee78fa3          	sb	a4,-1(a5)
 2e8:	fb75                	bnez	a4,2dc <strcpy+0x8>
    ;
  return os;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e422                	sd	s0,8(sp)
 2f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2f6:	00054783          	lbu	a5,0(a0)
 2fa:	cb91                	beqz	a5,30e <strcmp+0x1e>
 2fc:	0005c703          	lbu	a4,0(a1)
 300:	00f71763          	bne	a4,a5,30e <strcmp+0x1e>
    p++, q++;
 304:	0505                	addi	a0,a0,1
 306:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 308:	00054783          	lbu	a5,0(a0)
 30c:	fbe5                	bnez	a5,2fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 30e:	0005c503          	lbu	a0,0(a1)
}
 312:	40a7853b          	subw	a0,a5,a0
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <strlen>:

uint
strlen(const char *s)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e422                	sd	s0,8(sp)
 320:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 322:	00054783          	lbu	a5,0(a0)
 326:	cf91                	beqz	a5,342 <strlen+0x26>
 328:	0505                	addi	a0,a0,1
 32a:	87aa                	mv	a5,a0
 32c:	4685                	li	a3,1
 32e:	9e89                	subw	a3,a3,a0
 330:	00f6853b          	addw	a0,a3,a5
 334:	0785                	addi	a5,a5,1
 336:	fff7c703          	lbu	a4,-1(a5)
 33a:	fb7d                	bnez	a4,330 <strlen+0x14>
    ;
  return n;
}
 33c:	6422                	ld	s0,8(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  for(n = 0; s[n]; n++)
 342:	4501                	li	a0,0
 344:	bfe5                	j	33c <strlen+0x20>

0000000000000346 <memset>:

void*
memset(void *dst, int c, uint n)
{
 346:	1141                	addi	sp,sp,-16
 348:	e422                	sd	s0,8(sp)
 34a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 34c:	ce09                	beqz	a2,366 <memset+0x20>
 34e:	87aa                	mv	a5,a0
 350:	fff6071b          	addiw	a4,a2,-1
 354:	1702                	slli	a4,a4,0x20
 356:	9301                	srli	a4,a4,0x20
 358:	0705                	addi	a4,a4,1
 35a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 35c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 360:	0785                	addi	a5,a5,1
 362:	fee79de3          	bne	a5,a4,35c <memset+0x16>
  }
  return dst;
}
 366:	6422                	ld	s0,8(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret

000000000000036c <strchr>:

char*
strchr(const char *s, char c)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  for(; *s; s++)
 372:	00054783          	lbu	a5,0(a0)
 376:	cb99                	beqz	a5,38c <strchr+0x20>
    if(*s == c)
 378:	00f58763          	beq	a1,a5,386 <strchr+0x1a>
  for(; *s; s++)
 37c:	0505                	addi	a0,a0,1
 37e:	00054783          	lbu	a5,0(a0)
 382:	fbfd                	bnez	a5,378 <strchr+0xc>
      return (char*)s;
  return 0;
 384:	4501                	li	a0,0
}
 386:	6422                	ld	s0,8(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret
  return 0;
 38c:	4501                	li	a0,0
 38e:	bfe5                	j	386 <strchr+0x1a>

0000000000000390 <gets>:

char*
gets(char *buf, int max)
{
 390:	711d                	addi	sp,sp,-96
 392:	ec86                	sd	ra,88(sp)
 394:	e8a2                	sd	s0,80(sp)
 396:	e4a6                	sd	s1,72(sp)
 398:	e0ca                	sd	s2,64(sp)
 39a:	fc4e                	sd	s3,56(sp)
 39c:	f852                	sd	s4,48(sp)
 39e:	f456                	sd	s5,40(sp)
 3a0:	f05a                	sd	s6,32(sp)
 3a2:	ec5e                	sd	s7,24(sp)
 3a4:	1080                	addi	s0,sp,96
 3a6:	8baa                	mv	s7,a0
 3a8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3aa:	892a                	mv	s2,a0
 3ac:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3ae:	4aa9                	li	s5,10
 3b0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3b2:	89a6                	mv	s3,s1
 3b4:	2485                	addiw	s1,s1,1
 3b6:	0344d863          	bge	s1,s4,3e6 <gets+0x56>
    cc = read(0, &c, 1);
 3ba:	4605                	li	a2,1
 3bc:	faf40593          	addi	a1,s0,-81
 3c0:	4501                	li	a0,0
 3c2:	00000097          	auipc	ra,0x0
 3c6:	1a0080e7          	jalr	416(ra) # 562 <read>
    if(cc < 1)
 3ca:	00a05e63          	blez	a0,3e6 <gets+0x56>
    buf[i++] = c;
 3ce:	faf44783          	lbu	a5,-81(s0)
 3d2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3d6:	01578763          	beq	a5,s5,3e4 <gets+0x54>
 3da:	0905                	addi	s2,s2,1
 3dc:	fd679be3          	bne	a5,s6,3b2 <gets+0x22>
  for(i=0; i+1 < max; ){
 3e0:	89a6                	mv	s3,s1
 3e2:	a011                	j	3e6 <gets+0x56>
 3e4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3e6:	99de                	add	s3,s3,s7
 3e8:	00098023          	sb	zero,0(s3)
  return buf;
}
 3ec:	855e                	mv	a0,s7
 3ee:	60e6                	ld	ra,88(sp)
 3f0:	6446                	ld	s0,80(sp)
 3f2:	64a6                	ld	s1,72(sp)
 3f4:	6906                	ld	s2,64(sp)
 3f6:	79e2                	ld	s3,56(sp)
 3f8:	7a42                	ld	s4,48(sp)
 3fa:	7aa2                	ld	s5,40(sp)
 3fc:	7b02                	ld	s6,32(sp)
 3fe:	6be2                	ld	s7,24(sp)
 400:	6125                	addi	sp,sp,96
 402:	8082                	ret

0000000000000404 <stat>:

int
stat(const char *n, struct stat *st)
{
 404:	1101                	addi	sp,sp,-32
 406:	ec06                	sd	ra,24(sp)
 408:	e822                	sd	s0,16(sp)
 40a:	e426                	sd	s1,8(sp)
 40c:	e04a                	sd	s2,0(sp)
 40e:	1000                	addi	s0,sp,32
 410:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 412:	4581                	li	a1,0
 414:	00000097          	auipc	ra,0x0
 418:	176080e7          	jalr	374(ra) # 58a <open>
  if(fd < 0)
 41c:	02054563          	bltz	a0,446 <stat+0x42>
 420:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 422:	85ca                	mv	a1,s2
 424:	00000097          	auipc	ra,0x0
 428:	17e080e7          	jalr	382(ra) # 5a2 <fstat>
 42c:	892a                	mv	s2,a0
  close(fd);
 42e:	8526                	mv	a0,s1
 430:	00000097          	auipc	ra,0x0
 434:	142080e7          	jalr	322(ra) # 572 <close>
  return r;
}
 438:	854a                	mv	a0,s2
 43a:	60e2                	ld	ra,24(sp)
 43c:	6442                	ld	s0,16(sp)
 43e:	64a2                	ld	s1,8(sp)
 440:	6902                	ld	s2,0(sp)
 442:	6105                	addi	sp,sp,32
 444:	8082                	ret
    return -1;
 446:	597d                	li	s2,-1
 448:	bfc5                	j	438 <stat+0x34>

000000000000044a <atoi>:

int
atoi(const char *s)
{
 44a:	1141                	addi	sp,sp,-16
 44c:	e422                	sd	s0,8(sp)
 44e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 450:	00054603          	lbu	a2,0(a0)
 454:	fd06079b          	addiw	a5,a2,-48
 458:	0ff7f793          	andi	a5,a5,255
 45c:	4725                	li	a4,9
 45e:	02f76963          	bltu	a4,a5,490 <atoi+0x46>
 462:	86aa                	mv	a3,a0
  n = 0;
 464:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 466:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 468:	0685                	addi	a3,a3,1
 46a:	0025179b          	slliw	a5,a0,0x2
 46e:	9fa9                	addw	a5,a5,a0
 470:	0017979b          	slliw	a5,a5,0x1
 474:	9fb1                	addw	a5,a5,a2
 476:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 47a:	0006c603          	lbu	a2,0(a3)
 47e:	fd06071b          	addiw	a4,a2,-48
 482:	0ff77713          	andi	a4,a4,255
 486:	fee5f1e3          	bgeu	a1,a4,468 <atoi+0x1e>
  return n;
}
 48a:	6422                	ld	s0,8(sp)
 48c:	0141                	addi	sp,sp,16
 48e:	8082                	ret
  n = 0;
 490:	4501                	li	a0,0
 492:	bfe5                	j	48a <atoi+0x40>

0000000000000494 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 494:	1141                	addi	sp,sp,-16
 496:	e422                	sd	s0,8(sp)
 498:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 49a:	02b57663          	bgeu	a0,a1,4c6 <memmove+0x32>
    while(n-- > 0)
 49e:	02c05163          	blez	a2,4c0 <memmove+0x2c>
 4a2:	fff6079b          	addiw	a5,a2,-1
 4a6:	1782                	slli	a5,a5,0x20
 4a8:	9381                	srli	a5,a5,0x20
 4aa:	0785                	addi	a5,a5,1
 4ac:	97aa                	add	a5,a5,a0
  dst = vdst;
 4ae:	872a                	mv	a4,a0
      *dst++ = *src++;
 4b0:	0585                	addi	a1,a1,1
 4b2:	0705                	addi	a4,a4,1
 4b4:	fff5c683          	lbu	a3,-1(a1)
 4b8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4bc:	fee79ae3          	bne	a5,a4,4b0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4c0:	6422                	ld	s0,8(sp)
 4c2:	0141                	addi	sp,sp,16
 4c4:	8082                	ret
    dst += n;
 4c6:	00c50733          	add	a4,a0,a2
    src += n;
 4ca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4cc:	fec05ae3          	blez	a2,4c0 <memmove+0x2c>
 4d0:	fff6079b          	addiw	a5,a2,-1
 4d4:	1782                	slli	a5,a5,0x20
 4d6:	9381                	srli	a5,a5,0x20
 4d8:	fff7c793          	not	a5,a5
 4dc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4de:	15fd                	addi	a1,a1,-1
 4e0:	177d                	addi	a4,a4,-1
 4e2:	0005c683          	lbu	a3,0(a1)
 4e6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4ea:	fee79ae3          	bne	a5,a4,4de <memmove+0x4a>
 4ee:	bfc9                	j	4c0 <memmove+0x2c>

00000000000004f0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4f0:	1141                	addi	sp,sp,-16
 4f2:	e422                	sd	s0,8(sp)
 4f4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4f6:	ca05                	beqz	a2,526 <memcmp+0x36>
 4f8:	fff6069b          	addiw	a3,a2,-1
 4fc:	1682                	slli	a3,a3,0x20
 4fe:	9281                	srli	a3,a3,0x20
 500:	0685                	addi	a3,a3,1
 502:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 504:	00054783          	lbu	a5,0(a0)
 508:	0005c703          	lbu	a4,0(a1)
 50c:	00e79863          	bne	a5,a4,51c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 510:	0505                	addi	a0,a0,1
    p2++;
 512:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 514:	fed518e3          	bne	a0,a3,504 <memcmp+0x14>
  }
  return 0;
 518:	4501                	li	a0,0
 51a:	a019                	j	520 <memcmp+0x30>
      return *p1 - *p2;
 51c:	40e7853b          	subw	a0,a5,a4
}
 520:	6422                	ld	s0,8(sp)
 522:	0141                	addi	sp,sp,16
 524:	8082                	ret
  return 0;
 526:	4501                	li	a0,0
 528:	bfe5                	j	520 <memcmp+0x30>

000000000000052a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 52a:	1141                	addi	sp,sp,-16
 52c:	e406                	sd	ra,8(sp)
 52e:	e022                	sd	s0,0(sp)
 530:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 532:	00000097          	auipc	ra,0x0
 536:	f62080e7          	jalr	-158(ra) # 494 <memmove>
}
 53a:	60a2                	ld	ra,8(sp)
 53c:	6402                	ld	s0,0(sp)
 53e:	0141                	addi	sp,sp,16
 540:	8082                	ret

0000000000000542 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 542:	4885                	li	a7,1
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <exit>:
.global exit
exit:
 li a7, SYS_exit
 54a:	4889                	li	a7,2
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <wait>:
.global wait
wait:
 li a7, SYS_wait
 552:	488d                	li	a7,3
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 55a:	4891                	li	a7,4
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <read>:
.global read
read:
 li a7, SYS_read
 562:	4895                	li	a7,5
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <write>:
.global write
write:
 li a7, SYS_write
 56a:	48c1                	li	a7,16
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <close>:
.global close
close:
 li a7, SYS_close
 572:	48d5                	li	a7,21
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <kill>:
.global kill
kill:
 li a7, SYS_kill
 57a:	4899                	li	a7,6
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <exec>:
.global exec
exec:
 li a7, SYS_exec
 582:	489d                	li	a7,7
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <open>:
.global open
open:
 li a7, SYS_open
 58a:	48bd                	li	a7,15
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 592:	48c5                	li	a7,17
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 59a:	48c9                	li	a7,18
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5a2:	48a1                	li	a7,8
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <link>:
.global link
link:
 li a7, SYS_link
 5aa:	48cd                	li	a7,19
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5b2:	48d1                	li	a7,20
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5ba:	48a5                	li	a7,9
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5c2:	48a9                	li	a7,10
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5ca:	48ad                	li	a7,11
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5d2:	48b1                	li	a7,12
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5da:	48b5                	li	a7,13
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5e2:	48b9                	li	a7,14
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 5ea:	48d9                	li	a7,22
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <yield>:
.global yield
yield:
 li a7, SYS_yield
 5f2:	48dd                	li	a7,23
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 5fa:	48e1                	li	a7,24
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 602:	48e5                	li	a7,25
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 60a:	48e9                	li	a7,26
 ecall
 60c:	00000073          	ecall
 ret
 610:	8082                	ret

0000000000000612 <ps>:
.global ps
ps:
 li a7, SYS_ps
 612:	48ed                	li	a7,27
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 61a:	48f1                	li	a7,28
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 622:	48f5                	li	a7,29
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 62a:	48f9                	li	a7,30
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 632:	48fd                	li	a7,31
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 63a:	02000893          	li	a7,32
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 644:	02100893          	li	a7,33
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 64e:	1101                	addi	sp,sp,-32
 650:	ec06                	sd	ra,24(sp)
 652:	e822                	sd	s0,16(sp)
 654:	1000                	addi	s0,sp,32
 656:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 65a:	4605                	li	a2,1
 65c:	fef40593          	addi	a1,s0,-17
 660:	00000097          	auipc	ra,0x0
 664:	f0a080e7          	jalr	-246(ra) # 56a <write>
}
 668:	60e2                	ld	ra,24(sp)
 66a:	6442                	ld	s0,16(sp)
 66c:	6105                	addi	sp,sp,32
 66e:	8082                	ret

0000000000000670 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 670:	7139                	addi	sp,sp,-64
 672:	fc06                	sd	ra,56(sp)
 674:	f822                	sd	s0,48(sp)
 676:	f426                	sd	s1,40(sp)
 678:	f04a                	sd	s2,32(sp)
 67a:	ec4e                	sd	s3,24(sp)
 67c:	0080                	addi	s0,sp,64
 67e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 680:	c299                	beqz	a3,686 <printint+0x16>
 682:	0805c863          	bltz	a1,712 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 686:	2581                	sext.w	a1,a1
  neg = 0;
 688:	4881                	li	a7,0
 68a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 68e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 690:	2601                	sext.w	a2,a2
 692:	00000517          	auipc	a0,0x0
 696:	4ae50513          	addi	a0,a0,1198 # b40 <digits>
 69a:	883a                	mv	a6,a4
 69c:	2705                	addiw	a4,a4,1
 69e:	02c5f7bb          	remuw	a5,a1,a2
 6a2:	1782                	slli	a5,a5,0x20
 6a4:	9381                	srli	a5,a5,0x20
 6a6:	97aa                	add	a5,a5,a0
 6a8:	0007c783          	lbu	a5,0(a5)
 6ac:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6b0:	0005879b          	sext.w	a5,a1
 6b4:	02c5d5bb          	divuw	a1,a1,a2
 6b8:	0685                	addi	a3,a3,1
 6ba:	fec7f0e3          	bgeu	a5,a2,69a <printint+0x2a>
  if(neg)
 6be:	00088b63          	beqz	a7,6d4 <printint+0x64>
    buf[i++] = '-';
 6c2:	fd040793          	addi	a5,s0,-48
 6c6:	973e                	add	a4,a4,a5
 6c8:	02d00793          	li	a5,45
 6cc:	fef70823          	sb	a5,-16(a4)
 6d0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6d4:	02e05863          	blez	a4,704 <printint+0x94>
 6d8:	fc040793          	addi	a5,s0,-64
 6dc:	00e78933          	add	s2,a5,a4
 6e0:	fff78993          	addi	s3,a5,-1
 6e4:	99ba                	add	s3,s3,a4
 6e6:	377d                	addiw	a4,a4,-1
 6e8:	1702                	slli	a4,a4,0x20
 6ea:	9301                	srli	a4,a4,0x20
 6ec:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6f0:	fff94583          	lbu	a1,-1(s2)
 6f4:	8526                	mv	a0,s1
 6f6:	00000097          	auipc	ra,0x0
 6fa:	f58080e7          	jalr	-168(ra) # 64e <putc>
  while(--i >= 0)
 6fe:	197d                	addi	s2,s2,-1
 700:	ff3918e3          	bne	s2,s3,6f0 <printint+0x80>
}
 704:	70e2                	ld	ra,56(sp)
 706:	7442                	ld	s0,48(sp)
 708:	74a2                	ld	s1,40(sp)
 70a:	7902                	ld	s2,32(sp)
 70c:	69e2                	ld	s3,24(sp)
 70e:	6121                	addi	sp,sp,64
 710:	8082                	ret
    x = -xx;
 712:	40b005bb          	negw	a1,a1
    neg = 1;
 716:	4885                	li	a7,1
    x = -xx;
 718:	bf8d                	j	68a <printint+0x1a>

000000000000071a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 71a:	7119                	addi	sp,sp,-128
 71c:	fc86                	sd	ra,120(sp)
 71e:	f8a2                	sd	s0,112(sp)
 720:	f4a6                	sd	s1,104(sp)
 722:	f0ca                	sd	s2,96(sp)
 724:	ecce                	sd	s3,88(sp)
 726:	e8d2                	sd	s4,80(sp)
 728:	e4d6                	sd	s5,72(sp)
 72a:	e0da                	sd	s6,64(sp)
 72c:	fc5e                	sd	s7,56(sp)
 72e:	f862                	sd	s8,48(sp)
 730:	f466                	sd	s9,40(sp)
 732:	f06a                	sd	s10,32(sp)
 734:	ec6e                	sd	s11,24(sp)
 736:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 738:	0005c903          	lbu	s2,0(a1)
 73c:	18090f63          	beqz	s2,8da <vprintf+0x1c0>
 740:	8aaa                	mv	s5,a0
 742:	8b32                	mv	s6,a2
 744:	00158493          	addi	s1,a1,1
  state = 0;
 748:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 74a:	02500a13          	li	s4,37
      if(c == 'd'){
 74e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 752:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 756:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 75a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 75e:	00000b97          	auipc	s7,0x0
 762:	3e2b8b93          	addi	s7,s7,994 # b40 <digits>
 766:	a839                	j	784 <vprintf+0x6a>
        putc(fd, c);
 768:	85ca                	mv	a1,s2
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	ee2080e7          	jalr	-286(ra) # 64e <putc>
 774:	a019                	j	77a <vprintf+0x60>
    } else if(state == '%'){
 776:	01498f63          	beq	s3,s4,794 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 77a:	0485                	addi	s1,s1,1
 77c:	fff4c903          	lbu	s2,-1(s1)
 780:	14090d63          	beqz	s2,8da <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 784:	0009079b          	sext.w	a5,s2
    if(state == 0){
 788:	fe0997e3          	bnez	s3,776 <vprintf+0x5c>
      if(c == '%'){
 78c:	fd479ee3          	bne	a5,s4,768 <vprintf+0x4e>
        state = '%';
 790:	89be                	mv	s3,a5
 792:	b7e5                	j	77a <vprintf+0x60>
      if(c == 'd'){
 794:	05878063          	beq	a5,s8,7d4 <vprintf+0xba>
      } else if(c == 'l') {
 798:	05978c63          	beq	a5,s9,7f0 <vprintf+0xd6>
      } else if(c == 'x') {
 79c:	07a78863          	beq	a5,s10,80c <vprintf+0xf2>
      } else if(c == 'p') {
 7a0:	09b78463          	beq	a5,s11,828 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7a4:	07300713          	li	a4,115
 7a8:	0ce78663          	beq	a5,a4,874 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7ac:	06300713          	li	a4,99
 7b0:	0ee78e63          	beq	a5,a4,8ac <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7b4:	11478863          	beq	a5,s4,8c4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7b8:	85d2                	mv	a1,s4
 7ba:	8556                	mv	a0,s5
 7bc:	00000097          	auipc	ra,0x0
 7c0:	e92080e7          	jalr	-366(ra) # 64e <putc>
        putc(fd, c);
 7c4:	85ca                	mv	a1,s2
 7c6:	8556                	mv	a0,s5
 7c8:	00000097          	auipc	ra,0x0
 7cc:	e86080e7          	jalr	-378(ra) # 64e <putc>
      }
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	b765                	j	77a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7d4:	008b0913          	addi	s2,s6,8
 7d8:	4685                	li	a3,1
 7da:	4629                	li	a2,10
 7dc:	000b2583          	lw	a1,0(s6)
 7e0:	8556                	mv	a0,s5
 7e2:	00000097          	auipc	ra,0x0
 7e6:	e8e080e7          	jalr	-370(ra) # 670 <printint>
 7ea:	8b4a                	mv	s6,s2
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	b771                	j	77a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f0:	008b0913          	addi	s2,s6,8
 7f4:	4681                	li	a3,0
 7f6:	4629                	li	a2,10
 7f8:	000b2583          	lw	a1,0(s6)
 7fc:	8556                	mv	a0,s5
 7fe:	00000097          	auipc	ra,0x0
 802:	e72080e7          	jalr	-398(ra) # 670 <printint>
 806:	8b4a                	mv	s6,s2
      state = 0;
 808:	4981                	li	s3,0
 80a:	bf85                	j	77a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 80c:	008b0913          	addi	s2,s6,8
 810:	4681                	li	a3,0
 812:	4641                	li	a2,16
 814:	000b2583          	lw	a1,0(s6)
 818:	8556                	mv	a0,s5
 81a:	00000097          	auipc	ra,0x0
 81e:	e56080e7          	jalr	-426(ra) # 670 <printint>
 822:	8b4a                	mv	s6,s2
      state = 0;
 824:	4981                	li	s3,0
 826:	bf91                	j	77a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 828:	008b0793          	addi	a5,s6,8
 82c:	f8f43423          	sd	a5,-120(s0)
 830:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 834:	03000593          	li	a1,48
 838:	8556                	mv	a0,s5
 83a:	00000097          	auipc	ra,0x0
 83e:	e14080e7          	jalr	-492(ra) # 64e <putc>
  putc(fd, 'x');
 842:	85ea                	mv	a1,s10
 844:	8556                	mv	a0,s5
 846:	00000097          	auipc	ra,0x0
 84a:	e08080e7          	jalr	-504(ra) # 64e <putc>
 84e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 850:	03c9d793          	srli	a5,s3,0x3c
 854:	97de                	add	a5,a5,s7
 856:	0007c583          	lbu	a1,0(a5)
 85a:	8556                	mv	a0,s5
 85c:	00000097          	auipc	ra,0x0
 860:	df2080e7          	jalr	-526(ra) # 64e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 864:	0992                	slli	s3,s3,0x4
 866:	397d                	addiw	s2,s2,-1
 868:	fe0914e3          	bnez	s2,850 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 86c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 870:	4981                	li	s3,0
 872:	b721                	j	77a <vprintf+0x60>
        s = va_arg(ap, char*);
 874:	008b0993          	addi	s3,s6,8
 878:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 87c:	02090163          	beqz	s2,89e <vprintf+0x184>
        while(*s != 0){
 880:	00094583          	lbu	a1,0(s2)
 884:	c9a1                	beqz	a1,8d4 <vprintf+0x1ba>
          putc(fd, *s);
 886:	8556                	mv	a0,s5
 888:	00000097          	auipc	ra,0x0
 88c:	dc6080e7          	jalr	-570(ra) # 64e <putc>
          s++;
 890:	0905                	addi	s2,s2,1
        while(*s != 0){
 892:	00094583          	lbu	a1,0(s2)
 896:	f9e5                	bnez	a1,886 <vprintf+0x16c>
        s = va_arg(ap, char*);
 898:	8b4e                	mv	s6,s3
      state = 0;
 89a:	4981                	li	s3,0
 89c:	bdf9                	j	77a <vprintf+0x60>
          s = "(null)";
 89e:	00000917          	auipc	s2,0x0
 8a2:	29a90913          	addi	s2,s2,666 # b38 <malloc+0x154>
        while(*s != 0){
 8a6:	02800593          	li	a1,40
 8aa:	bff1                	j	886 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8ac:	008b0913          	addi	s2,s6,8
 8b0:	000b4583          	lbu	a1,0(s6)
 8b4:	8556                	mv	a0,s5
 8b6:	00000097          	auipc	ra,0x0
 8ba:	d98080e7          	jalr	-616(ra) # 64e <putc>
 8be:	8b4a                	mv	s6,s2
      state = 0;
 8c0:	4981                	li	s3,0
 8c2:	bd65                	j	77a <vprintf+0x60>
        putc(fd, c);
 8c4:	85d2                	mv	a1,s4
 8c6:	8556                	mv	a0,s5
 8c8:	00000097          	auipc	ra,0x0
 8cc:	d86080e7          	jalr	-634(ra) # 64e <putc>
      state = 0;
 8d0:	4981                	li	s3,0
 8d2:	b565                	j	77a <vprintf+0x60>
        s = va_arg(ap, char*);
 8d4:	8b4e                	mv	s6,s3
      state = 0;
 8d6:	4981                	li	s3,0
 8d8:	b54d                	j	77a <vprintf+0x60>
    }
  }
}
 8da:	70e6                	ld	ra,120(sp)
 8dc:	7446                	ld	s0,112(sp)
 8de:	74a6                	ld	s1,104(sp)
 8e0:	7906                	ld	s2,96(sp)
 8e2:	69e6                	ld	s3,88(sp)
 8e4:	6a46                	ld	s4,80(sp)
 8e6:	6aa6                	ld	s5,72(sp)
 8e8:	6b06                	ld	s6,64(sp)
 8ea:	7be2                	ld	s7,56(sp)
 8ec:	7c42                	ld	s8,48(sp)
 8ee:	7ca2                	ld	s9,40(sp)
 8f0:	7d02                	ld	s10,32(sp)
 8f2:	6de2                	ld	s11,24(sp)
 8f4:	6109                	addi	sp,sp,128
 8f6:	8082                	ret

00000000000008f8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8f8:	715d                	addi	sp,sp,-80
 8fa:	ec06                	sd	ra,24(sp)
 8fc:	e822                	sd	s0,16(sp)
 8fe:	1000                	addi	s0,sp,32
 900:	e010                	sd	a2,0(s0)
 902:	e414                	sd	a3,8(s0)
 904:	e818                	sd	a4,16(s0)
 906:	ec1c                	sd	a5,24(s0)
 908:	03043023          	sd	a6,32(s0)
 90c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 910:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 914:	8622                	mv	a2,s0
 916:	00000097          	auipc	ra,0x0
 91a:	e04080e7          	jalr	-508(ra) # 71a <vprintf>
}
 91e:	60e2                	ld	ra,24(sp)
 920:	6442                	ld	s0,16(sp)
 922:	6161                	addi	sp,sp,80
 924:	8082                	ret

0000000000000926 <printf>:

void
printf(const char *fmt, ...)
{
 926:	711d                	addi	sp,sp,-96
 928:	ec06                	sd	ra,24(sp)
 92a:	e822                	sd	s0,16(sp)
 92c:	1000                	addi	s0,sp,32
 92e:	e40c                	sd	a1,8(s0)
 930:	e810                	sd	a2,16(s0)
 932:	ec14                	sd	a3,24(s0)
 934:	f018                	sd	a4,32(s0)
 936:	f41c                	sd	a5,40(s0)
 938:	03043823          	sd	a6,48(s0)
 93c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 940:	00840613          	addi	a2,s0,8
 944:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 948:	85aa                	mv	a1,a0
 94a:	4505                	li	a0,1
 94c:	00000097          	auipc	ra,0x0
 950:	dce080e7          	jalr	-562(ra) # 71a <vprintf>
}
 954:	60e2                	ld	ra,24(sp)
 956:	6442                	ld	s0,16(sp)
 958:	6125                	addi	sp,sp,96
 95a:	8082                	ret

000000000000095c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 95c:	1141                	addi	sp,sp,-16
 95e:	e422                	sd	s0,8(sp)
 960:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 962:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 966:	00000797          	auipc	a5,0x0
 96a:	1f27b783          	ld	a5,498(a5) # b58 <freep>
 96e:	a805                	j	99e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 970:	4618                	lw	a4,8(a2)
 972:	9db9                	addw	a1,a1,a4
 974:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 978:	6398                	ld	a4,0(a5)
 97a:	6318                	ld	a4,0(a4)
 97c:	fee53823          	sd	a4,-16(a0)
 980:	a091                	j	9c4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 982:	ff852703          	lw	a4,-8(a0)
 986:	9e39                	addw	a2,a2,a4
 988:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 98a:	ff053703          	ld	a4,-16(a0)
 98e:	e398                	sd	a4,0(a5)
 990:	a099                	j	9d6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 992:	6398                	ld	a4,0(a5)
 994:	00e7e463          	bltu	a5,a4,99c <free+0x40>
 998:	00e6ea63          	bltu	a3,a4,9ac <free+0x50>
{
 99c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99e:	fed7fae3          	bgeu	a5,a3,992 <free+0x36>
 9a2:	6398                	ld	a4,0(a5)
 9a4:	00e6e463          	bltu	a3,a4,9ac <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a8:	fee7eae3          	bltu	a5,a4,99c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9ac:	ff852583          	lw	a1,-8(a0)
 9b0:	6390                	ld	a2,0(a5)
 9b2:	02059713          	slli	a4,a1,0x20
 9b6:	9301                	srli	a4,a4,0x20
 9b8:	0712                	slli	a4,a4,0x4
 9ba:	9736                	add	a4,a4,a3
 9bc:	fae60ae3          	beq	a2,a4,970 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9c0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9c4:	4790                	lw	a2,8(a5)
 9c6:	02061713          	slli	a4,a2,0x20
 9ca:	9301                	srli	a4,a4,0x20
 9cc:	0712                	slli	a4,a4,0x4
 9ce:	973e                	add	a4,a4,a5
 9d0:	fae689e3          	beq	a3,a4,982 <free+0x26>
  } else
    p->s.ptr = bp;
 9d4:	e394                	sd	a3,0(a5)
  freep = p;
 9d6:	00000717          	auipc	a4,0x0
 9da:	18f73123          	sd	a5,386(a4) # b58 <freep>
}
 9de:	6422                	ld	s0,8(sp)
 9e0:	0141                	addi	sp,sp,16
 9e2:	8082                	ret

00000000000009e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9e4:	7139                	addi	sp,sp,-64
 9e6:	fc06                	sd	ra,56(sp)
 9e8:	f822                	sd	s0,48(sp)
 9ea:	f426                	sd	s1,40(sp)
 9ec:	f04a                	sd	s2,32(sp)
 9ee:	ec4e                	sd	s3,24(sp)
 9f0:	e852                	sd	s4,16(sp)
 9f2:	e456                	sd	s5,8(sp)
 9f4:	e05a                	sd	s6,0(sp)
 9f6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f8:	02051493          	slli	s1,a0,0x20
 9fc:	9081                	srli	s1,s1,0x20
 9fe:	04bd                	addi	s1,s1,15
 a00:	8091                	srli	s1,s1,0x4
 a02:	0014899b          	addiw	s3,s1,1
 a06:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a08:	00000517          	auipc	a0,0x0
 a0c:	15053503          	ld	a0,336(a0) # b58 <freep>
 a10:	c515                	beqz	a0,a3c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a12:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a14:	4798                	lw	a4,8(a5)
 a16:	02977f63          	bgeu	a4,s1,a54 <malloc+0x70>
 a1a:	8a4e                	mv	s4,s3
 a1c:	0009871b          	sext.w	a4,s3
 a20:	6685                	lui	a3,0x1
 a22:	00d77363          	bgeu	a4,a3,a28 <malloc+0x44>
 a26:	6a05                	lui	s4,0x1
 a28:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a2c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a30:	00000917          	auipc	s2,0x0
 a34:	12890913          	addi	s2,s2,296 # b58 <freep>
  if(p == (char*)-1)
 a38:	5afd                	li	s5,-1
 a3a:	a88d                	j	aac <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a3c:	00000797          	auipc	a5,0x0
 a40:	13478793          	addi	a5,a5,308 # b70 <base>
 a44:	00000717          	auipc	a4,0x0
 a48:	10f73a23          	sd	a5,276(a4) # b58 <freep>
 a4c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a4e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a52:	b7e1                	j	a1a <malloc+0x36>
      if(p->s.size == nunits)
 a54:	02e48b63          	beq	s1,a4,a8a <malloc+0xa6>
        p->s.size -= nunits;
 a58:	4137073b          	subw	a4,a4,s3
 a5c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a5e:	1702                	slli	a4,a4,0x20
 a60:	9301                	srli	a4,a4,0x20
 a62:	0712                	slli	a4,a4,0x4
 a64:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a66:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a6a:	00000717          	auipc	a4,0x0
 a6e:	0ea73723          	sd	a0,238(a4) # b58 <freep>
      return (void*)(p + 1);
 a72:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a76:	70e2                	ld	ra,56(sp)
 a78:	7442                	ld	s0,48(sp)
 a7a:	74a2                	ld	s1,40(sp)
 a7c:	7902                	ld	s2,32(sp)
 a7e:	69e2                	ld	s3,24(sp)
 a80:	6a42                	ld	s4,16(sp)
 a82:	6aa2                	ld	s5,8(sp)
 a84:	6b02                	ld	s6,0(sp)
 a86:	6121                	addi	sp,sp,64
 a88:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a8a:	6398                	ld	a4,0(a5)
 a8c:	e118                	sd	a4,0(a0)
 a8e:	bff1                	j	a6a <malloc+0x86>
  hp->s.size = nu;
 a90:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a94:	0541                	addi	a0,a0,16
 a96:	00000097          	auipc	ra,0x0
 a9a:	ec6080e7          	jalr	-314(ra) # 95c <free>
  return freep;
 a9e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 aa2:	d971                	beqz	a0,a76 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aa4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aa6:	4798                	lw	a4,8(a5)
 aa8:	fa9776e3          	bgeu	a4,s1,a54 <malloc+0x70>
    if(p == freep)
 aac:	00093703          	ld	a4,0(s2)
 ab0:	853e                	mv	a0,a5
 ab2:	fef719e3          	bne	a4,a5,aa4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 ab6:	8552                	mv	a0,s4
 ab8:	00000097          	auipc	ra,0x0
 abc:	b1a080e7          	jalr	-1254(ra) # 5d2 <sbrk>
  if(p == (char*)-1)
 ac0:	fd5518e3          	bne	a0,s5,a90 <malloc+0xac>
        return 0;
 ac4:	4501                	li	a0,0
 ac6:	bf45                	j	a76 <malloc+0x92>
