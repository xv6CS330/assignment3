
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	bd013103          	ld	sp,-1072(sp) # 80009bd0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	074000ef          	jal	ra,8000008a <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = TIMER_INTERVAL; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	6661                	lui	a2,0x18
    8000003e:	6a060613          	addi	a2,a2,1696 # 186a0 <_entry-0x7ffe7960>
    80000042:	9732                	add	a4,a4,a2
    80000044:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000046:	00259693          	slli	a3,a1,0x2
    8000004a:	96ae                	add	a3,a3,a1
    8000004c:	068e                	slli	a3,a3,0x3
    8000004e:	0000a717          	auipc	a4,0xa
    80000052:	03270713          	addi	a4,a4,50 # 8000a080 <timer_scratch>
    80000056:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80000058:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005a:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005c:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000060:	00007797          	auipc	a5,0x7
    80000064:	49078793          	addi	a5,a5,1168 # 800074f0 <timervec>
    80000068:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000070:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000078:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007c:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000080:	30479073          	csrw	mie,a5
}
    80000084:	6422                	ld	s0,8(sp)
    80000086:	0141                	addi	sp,sp,16
    80000088:	8082                	ret

000000008000008a <start>:
{
    8000008a:	1141                	addi	sp,sp,-16
    8000008c:	e406                	sd	ra,8(sp)
    8000008e:	e022                	sd	s0,0(sp)
    80000090:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000092:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000096:	7779                	lui	a4,0xffffe
    80000098:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd67ff>
    8000009c:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009e:	6705                	lui	a4,0x1
    800000a0:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a6:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000aa:	00001797          	auipc	a5,0x1
    800000ae:	dc678793          	addi	a5,a5,-570 # 80000e70 <main>
    800000b2:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b6:	4781                	li	a5,0
    800000b8:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000bc:	67c1                	lui	a5,0x10
    800000be:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c0:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c4:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c8:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000cc:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d0:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d4:	57fd                	li	a5,-1
    800000d6:	83a9                	srli	a5,a5,0xa
    800000d8:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000dc:	47bd                	li	a5,15
    800000de:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e2:	00000097          	auipc	ra,0x0
    800000e6:	f3a080e7          	jalr	-198(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ea:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000ee:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f0:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f2:	30200073          	mret
}
    800000f6:	60a2                	ld	ra,8(sp)
    800000f8:	6402                	ld	s0,0(sp)
    800000fa:	0141                	addi	sp,sp,16
    800000fc:	8082                	ret

00000000800000fe <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000fe:	715d                	addi	sp,sp,-80
    80000100:	e486                	sd	ra,72(sp)
    80000102:	e0a2                	sd	s0,64(sp)
    80000104:	fc26                	sd	s1,56(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	f44e                	sd	s3,40(sp)
    8000010a:	f052                	sd	s4,32(sp)
    8000010c:	ec56                	sd	s5,24(sp)
    8000010e:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000110:	04c05763          	blez	a2,8000015e <consolewrite+0x60>
    80000114:	8a2a                	mv	s4,a0
    80000116:	84ae                	mv	s1,a1
    80000118:	89b2                	mv	s3,a2
    8000011a:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011c:	5afd                	li	s5,-1
    8000011e:	4685                	li	a3,1
    80000120:	8626                	mv	a2,s1
    80000122:	85d2                	mv	a1,s4
    80000124:	fbf40513          	addi	a0,s0,-65
    80000128:	00003097          	auipc	ra,0x3
    8000012c:	096080e7          	jalr	150(ra) # 800031be <either_copyin>
    80000130:	01550d63          	beq	a0,s5,8000014a <consolewrite+0x4c>
      break;
    uartputc(c);
    80000134:	fbf44503          	lbu	a0,-65(s0)
    80000138:	00000097          	auipc	ra,0x0
    8000013c:	77e080e7          	jalr	1918(ra) # 800008b6 <uartputc>
  for(i = 0; i < n; i++){
    80000140:	2905                	addiw	s2,s2,1
    80000142:	0485                	addi	s1,s1,1
    80000144:	fd299de3          	bne	s3,s2,8000011e <consolewrite+0x20>
    80000148:	894e                	mv	s2,s3
  }

  return i;
}
    8000014a:	854a                	mv	a0,s2
    8000014c:	60a6                	ld	ra,72(sp)
    8000014e:	6406                	ld	s0,64(sp)
    80000150:	74e2                	ld	s1,56(sp)
    80000152:	7942                	ld	s2,48(sp)
    80000154:	79a2                	ld	s3,40(sp)
    80000156:	7a02                	ld	s4,32(sp)
    80000158:	6ae2                	ld	s5,24(sp)
    8000015a:	6161                	addi	sp,sp,80
    8000015c:	8082                	ret
  for(i = 0; i < n; i++){
    8000015e:	4901                	li	s2,0
    80000160:	b7ed                	j	8000014a <consolewrite+0x4c>

0000000080000162 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000162:	7159                	addi	sp,sp,-112
    80000164:	f486                	sd	ra,104(sp)
    80000166:	f0a2                	sd	s0,96(sp)
    80000168:	eca6                	sd	s1,88(sp)
    8000016a:	e8ca                	sd	s2,80(sp)
    8000016c:	e4ce                	sd	s3,72(sp)
    8000016e:	e0d2                	sd	s4,64(sp)
    80000170:	fc56                	sd	s5,56(sp)
    80000172:	f85a                	sd	s6,48(sp)
    80000174:	f45e                	sd	s7,40(sp)
    80000176:	f062                	sd	s8,32(sp)
    80000178:	ec66                	sd	s9,24(sp)
    8000017a:	e86a                	sd	s10,16(sp)
    8000017c:	1880                	addi	s0,sp,112
    8000017e:	8aaa                	mv	s5,a0
    80000180:	8a2e                	mv	s4,a1
    80000182:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000184:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000188:	00012517          	auipc	a0,0x12
    8000018c:	03850513          	addi	a0,a0,56 # 800121c0 <cons>
    80000190:	00001097          	auipc	ra,0x1
    80000194:	a3e080e7          	jalr	-1474(ra) # 80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00012497          	auipc	s1,0x12
    8000019c:	02848493          	addi	s1,s1,40 # 800121c0 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00012917          	auipc	s2,0x12
    800001a4:	0b890913          	addi	s2,s2,184 # 80012258 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001a8:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001aa:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ac:	4ca9                	li	s9,10
  while(n > 0){
    800001ae:	07305863          	blez	s3,8000021e <consoleread+0xbc>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	02f71463          	bne	a4,a5,800001e2 <consoleread+0x80>
      if(myproc()->killed){
    800001be:	00001097          	auipc	ra,0x1
    800001c2:	7fc080e7          	jalr	2044(ra) # 800019ba <myproc>
    800001c6:	551c                	lw	a5,40(a0)
    800001c8:	e7b5                	bnez	a5,80000234 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001ca:	85a6                	mv	a1,s1
    800001cc:	854a                	mv	a0,s2
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	59e080e7          	jalr	1438(ra) # 8000276c <sleep>
    while(cons.r == cons.w){
    800001d6:	0984a783          	lw	a5,152(s1)
    800001da:	09c4a703          	lw	a4,156(s1)
    800001de:	fef700e3          	beq	a4,a5,800001be <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e2:	0017871b          	addiw	a4,a5,1
    800001e6:	08e4ac23          	sw	a4,152(s1)
    800001ea:	07f7f713          	andi	a4,a5,127
    800001ee:	9726                	add	a4,a4,s1
    800001f0:	01874703          	lbu	a4,24(a4)
    800001f4:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001f8:	077d0563          	beq	s10,s7,80000262 <consoleread+0x100>
    cbuf = c;
    800001fc:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	f9f40613          	addi	a2,s0,-97
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	00003097          	auipc	ra,0x3
    8000020e:	f5e080e7          	jalr	-162(ra) # 80003168 <either_copyout>
    80000212:	01850663          	beq	a0,s8,8000021e <consoleread+0xbc>
    dst++;
    80000216:	0a05                	addi	s4,s4,1
    --n;
    80000218:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000021a:	f99d1ae3          	bne	s10,s9,800001ae <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000021e:	00012517          	auipc	a0,0x12
    80000222:	fa250513          	addi	a0,a0,-94 # 800121c0 <cons>
    80000226:	00001097          	auipc	ra,0x1
    8000022a:	a5c080e7          	jalr	-1444(ra) # 80000c82 <release>

  return target - n;
    8000022e:	413b053b          	subw	a0,s6,s3
    80000232:	a811                	j	80000246 <consoleread+0xe4>
        release(&cons.lock);
    80000234:	00012517          	auipc	a0,0x12
    80000238:	f8c50513          	addi	a0,a0,-116 # 800121c0 <cons>
    8000023c:	00001097          	auipc	ra,0x1
    80000240:	a46080e7          	jalr	-1466(ra) # 80000c82 <release>
        return -1;
    80000244:	557d                	li	a0,-1
}
    80000246:	70a6                	ld	ra,104(sp)
    80000248:	7406                	ld	s0,96(sp)
    8000024a:	64e6                	ld	s1,88(sp)
    8000024c:	6946                	ld	s2,80(sp)
    8000024e:	69a6                	ld	s3,72(sp)
    80000250:	6a06                	ld	s4,64(sp)
    80000252:	7ae2                	ld	s5,56(sp)
    80000254:	7b42                	ld	s6,48(sp)
    80000256:	7ba2                	ld	s7,40(sp)
    80000258:	7c02                	ld	s8,32(sp)
    8000025a:	6ce2                	ld	s9,24(sp)
    8000025c:	6d42                	ld	s10,16(sp)
    8000025e:	6165                	addi	sp,sp,112
    80000260:	8082                	ret
      if(n < target){
    80000262:	0009871b          	sext.w	a4,s3
    80000266:	fb677ce3          	bgeu	a4,s6,8000021e <consoleread+0xbc>
        cons.r--;
    8000026a:	00012717          	auipc	a4,0x12
    8000026e:	fef72723          	sw	a5,-18(a4) # 80012258 <cons+0x98>
    80000272:	b775                	j	8000021e <consoleread+0xbc>

0000000080000274 <consputc>:
{
    80000274:	1141                	addi	sp,sp,-16
    80000276:	e406                	sd	ra,8(sp)
    80000278:	e022                	sd	s0,0(sp)
    8000027a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027c:	10000793          	li	a5,256
    80000280:	00f50a63          	beq	a0,a5,80000294 <consputc+0x20>
    uartputc_sync(c);
    80000284:	00000097          	auipc	ra,0x0
    80000288:	560080e7          	jalr	1376(ra) # 800007e4 <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	54e080e7          	jalr	1358(ra) # 800007e4 <uartputc_sync>
    8000029e:	02000513          	li	a0,32
    800002a2:	00000097          	auipc	ra,0x0
    800002a6:	542080e7          	jalr	1346(ra) # 800007e4 <uartputc_sync>
    800002aa:	4521                	li	a0,8
    800002ac:	00000097          	auipc	ra,0x0
    800002b0:	538080e7          	jalr	1336(ra) # 800007e4 <uartputc_sync>
    800002b4:	bfe1                	j	8000028c <consputc+0x18>

00000000800002b6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b6:	1101                	addi	sp,sp,-32
    800002b8:	ec06                	sd	ra,24(sp)
    800002ba:	e822                	sd	s0,16(sp)
    800002bc:	e426                	sd	s1,8(sp)
    800002be:	e04a                	sd	s2,0(sp)
    800002c0:	1000                	addi	s0,sp,32
    800002c2:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c4:	00012517          	auipc	a0,0x12
    800002c8:	efc50513          	addi	a0,a0,-260 # 800121c0 <cons>
    800002cc:	00001097          	auipc	ra,0x1
    800002d0:	902080e7          	jalr	-1790(ra) # 80000bce <acquire>

  switch(c){
    800002d4:	47d5                	li	a5,21
    800002d6:	0af48663          	beq	s1,a5,80000382 <consoleintr+0xcc>
    800002da:	0297ca63          	blt	a5,s1,8000030e <consoleintr+0x58>
    800002de:	47a1                	li	a5,8
    800002e0:	0ef48763          	beq	s1,a5,800003ce <consoleintr+0x118>
    800002e4:	47c1                	li	a5,16
    800002e6:	10f49a63          	bne	s1,a5,800003fa <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ea:	00003097          	auipc	ra,0x3
    800002ee:	f2a080e7          	jalr	-214(ra) # 80003214 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f2:	00012517          	auipc	a0,0x12
    800002f6:	ece50513          	addi	a0,a0,-306 # 800121c0 <cons>
    800002fa:	00001097          	auipc	ra,0x1
    800002fe:	988080e7          	jalr	-1656(ra) # 80000c82 <release>
}
    80000302:	60e2                	ld	ra,24(sp)
    80000304:	6442                	ld	s0,16(sp)
    80000306:	64a2                	ld	s1,8(sp)
    80000308:	6902                	ld	s2,0(sp)
    8000030a:	6105                	addi	sp,sp,32
    8000030c:	8082                	ret
  switch(c){
    8000030e:	07f00793          	li	a5,127
    80000312:	0af48e63          	beq	s1,a5,800003ce <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000316:	00012717          	auipc	a4,0x12
    8000031a:	eaa70713          	addi	a4,a4,-342 # 800121c0 <cons>
    8000031e:	0a072783          	lw	a5,160(a4)
    80000322:	09872703          	lw	a4,152(a4)
    80000326:	9f99                	subw	a5,a5,a4
    80000328:	07f00713          	li	a4,127
    8000032c:	fcf763e3          	bltu	a4,a5,800002f2 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000330:	47b5                	li	a5,13
    80000332:	0cf48763          	beq	s1,a5,80000400 <consoleintr+0x14a>
      consputc(c);
    80000336:	8526                	mv	a0,s1
    80000338:	00000097          	auipc	ra,0x0
    8000033c:	f3c080e7          	jalr	-196(ra) # 80000274 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000340:	00012797          	auipc	a5,0x12
    80000344:	e8078793          	addi	a5,a5,-384 # 800121c0 <cons>
    80000348:	0a07a703          	lw	a4,160(a5)
    8000034c:	0017069b          	addiw	a3,a4,1
    80000350:	0006861b          	sext.w	a2,a3
    80000354:	0ad7a023          	sw	a3,160(a5)
    80000358:	07f77713          	andi	a4,a4,127
    8000035c:	97ba                	add	a5,a5,a4
    8000035e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000362:	47a9                	li	a5,10
    80000364:	0cf48563          	beq	s1,a5,8000042e <consoleintr+0x178>
    80000368:	4791                	li	a5,4
    8000036a:	0cf48263          	beq	s1,a5,8000042e <consoleintr+0x178>
    8000036e:	00012797          	auipc	a5,0x12
    80000372:	eea7a783          	lw	a5,-278(a5) # 80012258 <cons+0x98>
    80000376:	0807879b          	addiw	a5,a5,128
    8000037a:	f6f61ce3          	bne	a2,a5,800002f2 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000037e:	863e                	mv	a2,a5
    80000380:	a07d                	j	8000042e <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000382:	00012717          	auipc	a4,0x12
    80000386:	e3e70713          	addi	a4,a4,-450 # 800121c0 <cons>
    8000038a:	0a072783          	lw	a5,160(a4)
    8000038e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000392:	00012497          	auipc	s1,0x12
    80000396:	e2e48493          	addi	s1,s1,-466 # 800121c0 <cons>
    while(cons.e != cons.w &&
    8000039a:	4929                	li	s2,10
    8000039c:	f4f70be3          	beq	a4,a5,800002f2 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a0:	37fd                	addiw	a5,a5,-1
    800003a2:	07f7f713          	andi	a4,a5,127
    800003a6:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003a8:	01874703          	lbu	a4,24(a4)
    800003ac:	f52703e3          	beq	a4,s2,800002f2 <consoleintr+0x3c>
      cons.e--;
    800003b0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b4:	10000513          	li	a0,256
    800003b8:	00000097          	auipc	ra,0x0
    800003bc:	ebc080e7          	jalr	-324(ra) # 80000274 <consputc>
    while(cons.e != cons.w &&
    800003c0:	0a04a783          	lw	a5,160(s1)
    800003c4:	09c4a703          	lw	a4,156(s1)
    800003c8:	fcf71ce3          	bne	a4,a5,800003a0 <consoleintr+0xea>
    800003cc:	b71d                	j	800002f2 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003ce:	00012717          	auipc	a4,0x12
    800003d2:	df270713          	addi	a4,a4,-526 # 800121c0 <cons>
    800003d6:	0a072783          	lw	a5,160(a4)
    800003da:	09c72703          	lw	a4,156(a4)
    800003de:	f0f70ae3          	beq	a4,a5,800002f2 <consoleintr+0x3c>
      cons.e--;
    800003e2:	37fd                	addiw	a5,a5,-1
    800003e4:	00012717          	auipc	a4,0x12
    800003e8:	e6f72e23          	sw	a5,-388(a4) # 80012260 <cons+0xa0>
      consputc(BACKSPACE);
    800003ec:	10000513          	li	a0,256
    800003f0:	00000097          	auipc	ra,0x0
    800003f4:	e84080e7          	jalr	-380(ra) # 80000274 <consputc>
    800003f8:	bded                	j	800002f2 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003fa:	ee048ce3          	beqz	s1,800002f2 <consoleintr+0x3c>
    800003fe:	bf21                	j	80000316 <consoleintr+0x60>
      consputc(c);
    80000400:	4529                	li	a0,10
    80000402:	00000097          	auipc	ra,0x0
    80000406:	e72080e7          	jalr	-398(ra) # 80000274 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000040a:	00012797          	auipc	a5,0x12
    8000040e:	db678793          	addi	a5,a5,-586 # 800121c0 <cons>
    80000412:	0a07a703          	lw	a4,160(a5)
    80000416:	0017069b          	addiw	a3,a4,1
    8000041a:	0006861b          	sext.w	a2,a3
    8000041e:	0ad7a023          	sw	a3,160(a5)
    80000422:	07f77713          	andi	a4,a4,127
    80000426:	97ba                	add	a5,a5,a4
    80000428:	4729                	li	a4,10
    8000042a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000042e:	00012797          	auipc	a5,0x12
    80000432:	e2c7a723          	sw	a2,-466(a5) # 8001225c <cons+0x9c>
        wakeup(&cons.r);
    80000436:	00012517          	auipc	a0,0x12
    8000043a:	e2250513          	addi	a0,a0,-478 # 80012258 <cons+0x98>
    8000043e:	00002097          	auipc	ra,0x2
    80000442:	732080e7          	jalr	1842(ra) # 80002b70 <wakeup>
    80000446:	b575                	j	800002f2 <consoleintr+0x3c>

0000000080000448 <consoleinit>:

void
consoleinit(void)
{
    80000448:	1141                	addi	sp,sp,-16
    8000044a:	e406                	sd	ra,8(sp)
    8000044c:	e022                	sd	s0,0(sp)
    8000044e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000450:	00009597          	auipc	a1,0x9
    80000454:	bc058593          	addi	a1,a1,-1088 # 80009010 <etext+0x10>
    80000458:	00012517          	auipc	a0,0x12
    8000045c:	d6850513          	addi	a0,a0,-664 # 800121c0 <cons>
    80000460:	00000097          	auipc	ra,0x0
    80000464:	6de080e7          	jalr	1758(ra) # 80000b3e <initlock>

  uartinit();
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	32c080e7          	jalr	812(ra) # 80000794 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000470:	00023797          	auipc	a5,0x23
    80000474:	24878793          	addi	a5,a5,584 # 800236b8 <devsw>
    80000478:	00000717          	auipc	a4,0x0
    8000047c:	cea70713          	addi	a4,a4,-790 # 80000162 <consoleread>
    80000480:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000482:	00000717          	auipc	a4,0x0
    80000486:	c7c70713          	addi	a4,a4,-900 # 800000fe <consolewrite>
    8000048a:	ef98                	sd	a4,24(a5)
}
    8000048c:	60a2                	ld	ra,8(sp)
    8000048e:	6402                	ld	s0,0(sp)
    80000490:	0141                	addi	sp,sp,16
    80000492:	8082                	ret

0000000080000494 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000494:	7179                	addi	sp,sp,-48
    80000496:	f406                	sd	ra,40(sp)
    80000498:	f022                	sd	s0,32(sp)
    8000049a:	ec26                	sd	s1,24(sp)
    8000049c:	e84a                	sd	s2,16(sp)
    8000049e:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a0:	c219                	beqz	a2,800004a6 <printint+0x12>
    800004a2:	08054763          	bltz	a0,80000530 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004a6:	2501                	sext.w	a0,a0
    800004a8:	4881                	li	a7,0
    800004aa:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004ae:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b0:	2581                	sext.w	a1,a1
    800004b2:	00009617          	auipc	a2,0x9
    800004b6:	b8e60613          	addi	a2,a2,-1138 # 80009040 <digits>
    800004ba:	883a                	mv	a6,a4
    800004bc:	2705                	addiw	a4,a4,1
    800004be:	02b577bb          	remuw	a5,a0,a1
    800004c2:	1782                	slli	a5,a5,0x20
    800004c4:	9381                	srli	a5,a5,0x20
    800004c6:	97b2                	add	a5,a5,a2
    800004c8:	0007c783          	lbu	a5,0(a5)
    800004cc:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d0:	0005079b          	sext.w	a5,a0
    800004d4:	02b5553b          	divuw	a0,a0,a1
    800004d8:	0685                	addi	a3,a3,1
    800004da:	feb7f0e3          	bgeu	a5,a1,800004ba <printint+0x26>

  if(sign)
    800004de:	00088c63          	beqz	a7,800004f6 <printint+0x62>
    buf[i++] = '-';
    800004e2:	fe070793          	addi	a5,a4,-32
    800004e6:	00878733          	add	a4,a5,s0
    800004ea:	02d00793          	li	a5,45
    800004ee:	fef70823          	sb	a5,-16(a4)
    800004f2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004f6:	02e05763          	blez	a4,80000524 <printint+0x90>
    800004fa:	fd040793          	addi	a5,s0,-48
    800004fe:	00e784b3          	add	s1,a5,a4
    80000502:	fff78913          	addi	s2,a5,-1
    80000506:	993a                	add	s2,s2,a4
    80000508:	377d                	addiw	a4,a4,-1
    8000050a:	1702                	slli	a4,a4,0x20
    8000050c:	9301                	srli	a4,a4,0x20
    8000050e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000512:	fff4c503          	lbu	a0,-1(s1)
    80000516:	00000097          	auipc	ra,0x0
    8000051a:	d5e080e7          	jalr	-674(ra) # 80000274 <consputc>
  while(--i >= 0)
    8000051e:	14fd                	addi	s1,s1,-1
    80000520:	ff2499e3          	bne	s1,s2,80000512 <printint+0x7e>
}
    80000524:	70a2                	ld	ra,40(sp)
    80000526:	7402                	ld	s0,32(sp)
    80000528:	64e2                	ld	s1,24(sp)
    8000052a:	6942                	ld	s2,16(sp)
    8000052c:	6145                	addi	sp,sp,48
    8000052e:	8082                	ret
    x = -xx;
    80000530:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000534:	4885                	li	a7,1
    x = -xx;
    80000536:	bf95                	j	800004aa <printint+0x16>

0000000080000538 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000538:	1101                	addi	sp,sp,-32
    8000053a:	ec06                	sd	ra,24(sp)
    8000053c:	e822                	sd	s0,16(sp)
    8000053e:	e426                	sd	s1,8(sp)
    80000540:	1000                	addi	s0,sp,32
    80000542:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000544:	00012797          	auipc	a5,0x12
    80000548:	d207ae23          	sw	zero,-708(a5) # 80012280 <pr+0x18>
  printf("panic: ");
    8000054c:	00009517          	auipc	a0,0x9
    80000550:	acc50513          	addi	a0,a0,-1332 # 80009018 <etext+0x18>
    80000554:	00000097          	auipc	ra,0x0
    80000558:	02e080e7          	jalr	46(ra) # 80000582 <printf>
  printf(s);
    8000055c:	8526                	mv	a0,s1
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	024080e7          	jalr	36(ra) # 80000582 <printf>
  printf("\n");
    80000566:	00009517          	auipc	a0,0x9
    8000056a:	22a50513          	addi	a0,a0,554 # 80009790 <syscalls+0x150>
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	014080e7          	jalr	20(ra) # 80000582 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000576:	4785                	li	a5,1
    80000578:	0000a717          	auipc	a4,0xa
    8000057c:	a8f72423          	sw	a5,-1400(a4) # 8000a000 <panicked>
  for(;;)
    80000580:	a001                	j	80000580 <panic+0x48>

0000000080000582 <printf>:
{
    80000582:	7131                	addi	sp,sp,-192
    80000584:	fc86                	sd	ra,120(sp)
    80000586:	f8a2                	sd	s0,112(sp)
    80000588:	f4a6                	sd	s1,104(sp)
    8000058a:	f0ca                	sd	s2,96(sp)
    8000058c:	ecce                	sd	s3,88(sp)
    8000058e:	e8d2                	sd	s4,80(sp)
    80000590:	e4d6                	sd	s5,72(sp)
    80000592:	e0da                	sd	s6,64(sp)
    80000594:	fc5e                	sd	s7,56(sp)
    80000596:	f862                	sd	s8,48(sp)
    80000598:	f466                	sd	s9,40(sp)
    8000059a:	f06a                	sd	s10,32(sp)
    8000059c:	ec6e                	sd	s11,24(sp)
    8000059e:	0100                	addi	s0,sp,128
    800005a0:	8a2a                	mv	s4,a0
    800005a2:	e40c                	sd	a1,8(s0)
    800005a4:	e810                	sd	a2,16(s0)
    800005a6:	ec14                	sd	a3,24(s0)
    800005a8:	f018                	sd	a4,32(s0)
    800005aa:	f41c                	sd	a5,40(s0)
    800005ac:	03043823          	sd	a6,48(s0)
    800005b0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b4:	00012d97          	auipc	s11,0x12
    800005b8:	cccdad83          	lw	s11,-820(s11) # 80012280 <pr+0x18>
  if(locking)
    800005bc:	020d9b63          	bnez	s11,800005f2 <printf+0x70>
  if (fmt == 0)
    800005c0:	040a0263          	beqz	s4,80000604 <printf+0x82>
  va_start(ap, fmt);
    800005c4:	00840793          	addi	a5,s0,8
    800005c8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005cc:	000a4503          	lbu	a0,0(s4)
    800005d0:	14050f63          	beqz	a0,8000072e <printf+0x1ac>
    800005d4:	4981                	li	s3,0
    if(c != '%'){
    800005d6:	02500a93          	li	s5,37
    switch(c){
    800005da:	07000b93          	li	s7,112
  consputc('x');
    800005de:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e0:	00009b17          	auipc	s6,0x9
    800005e4:	a60b0b13          	addi	s6,s6,-1440 # 80009040 <digits>
    switch(c){
    800005e8:	07300c93          	li	s9,115
    800005ec:	06400c13          	li	s8,100
    800005f0:	a82d                	j	8000062a <printf+0xa8>
    acquire(&pr.lock);
    800005f2:	00012517          	auipc	a0,0x12
    800005f6:	c7650513          	addi	a0,a0,-906 # 80012268 <pr>
    800005fa:	00000097          	auipc	ra,0x0
    800005fe:	5d4080e7          	jalr	1492(ra) # 80000bce <acquire>
    80000602:	bf7d                	j	800005c0 <printf+0x3e>
    panic("null fmt");
    80000604:	00009517          	auipc	a0,0x9
    80000608:	a2450513          	addi	a0,a0,-1500 # 80009028 <etext+0x28>
    8000060c:	00000097          	auipc	ra,0x0
    80000610:	f2c080e7          	jalr	-212(ra) # 80000538 <panic>
      consputc(c);
    80000614:	00000097          	auipc	ra,0x0
    80000618:	c60080e7          	jalr	-928(ra) # 80000274 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000061c:	2985                	addiw	s3,s3,1
    8000061e:	013a07b3          	add	a5,s4,s3
    80000622:	0007c503          	lbu	a0,0(a5)
    80000626:	10050463          	beqz	a0,8000072e <printf+0x1ac>
    if(c != '%'){
    8000062a:	ff5515e3          	bne	a0,s5,80000614 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000062e:	2985                	addiw	s3,s3,1
    80000630:	013a07b3          	add	a5,s4,s3
    80000634:	0007c783          	lbu	a5,0(a5)
    80000638:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000063c:	cbed                	beqz	a5,8000072e <printf+0x1ac>
    switch(c){
    8000063e:	05778a63          	beq	a5,s7,80000692 <printf+0x110>
    80000642:	02fbf663          	bgeu	s7,a5,8000066e <printf+0xec>
    80000646:	09978863          	beq	a5,s9,800006d6 <printf+0x154>
    8000064a:	07800713          	li	a4,120
    8000064e:	0ce79563          	bne	a5,a4,80000718 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4605                	li	a2,1
    80000660:	85ea                	mv	a1,s10
    80000662:	4388                	lw	a0,0(a5)
    80000664:	00000097          	auipc	ra,0x0
    80000668:	e30080e7          	jalr	-464(ra) # 80000494 <printint>
      break;
    8000066c:	bf45                	j	8000061c <printf+0x9a>
    switch(c){
    8000066e:	09578f63          	beq	a5,s5,8000070c <printf+0x18a>
    80000672:	0b879363          	bne	a5,s8,80000718 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000676:	f8843783          	ld	a5,-120(s0)
    8000067a:	00878713          	addi	a4,a5,8
    8000067e:	f8e43423          	sd	a4,-120(s0)
    80000682:	4605                	li	a2,1
    80000684:	45a9                	li	a1,10
    80000686:	4388                	lw	a0,0(a5)
    80000688:	00000097          	auipc	ra,0x0
    8000068c:	e0c080e7          	jalr	-500(ra) # 80000494 <printint>
      break;
    80000690:	b771                	j	8000061c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a2:	03000513          	li	a0,48
    800006a6:	00000097          	auipc	ra,0x0
    800006aa:	bce080e7          	jalr	-1074(ra) # 80000274 <consputc>
  consputc('x');
    800006ae:	07800513          	li	a0,120
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bc2080e7          	jalr	-1086(ra) # 80000274 <consputc>
    800006ba:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006bc:	03c95793          	srli	a5,s2,0x3c
    800006c0:	97da                	add	a5,a5,s6
    800006c2:	0007c503          	lbu	a0,0(a5)
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	bae080e7          	jalr	-1106(ra) # 80000274 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ce:	0912                	slli	s2,s2,0x4
    800006d0:	34fd                	addiw	s1,s1,-1
    800006d2:	f4ed                	bnez	s1,800006bc <printf+0x13a>
    800006d4:	b7a1                	j	8000061c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d6:	f8843783          	ld	a5,-120(s0)
    800006da:	00878713          	addi	a4,a5,8
    800006de:	f8e43423          	sd	a4,-120(s0)
    800006e2:	6384                	ld	s1,0(a5)
    800006e4:	cc89                	beqz	s1,800006fe <printf+0x17c>
      for(; *s; s++)
    800006e6:	0004c503          	lbu	a0,0(s1)
    800006ea:	d90d                	beqz	a0,8000061c <printf+0x9a>
        consputc(*s);
    800006ec:	00000097          	auipc	ra,0x0
    800006f0:	b88080e7          	jalr	-1144(ra) # 80000274 <consputc>
      for(; *s; s++)
    800006f4:	0485                	addi	s1,s1,1
    800006f6:	0004c503          	lbu	a0,0(s1)
    800006fa:	f96d                	bnez	a0,800006ec <printf+0x16a>
    800006fc:	b705                	j	8000061c <printf+0x9a>
        s = "(null)";
    800006fe:	00009497          	auipc	s1,0x9
    80000702:	92248493          	addi	s1,s1,-1758 # 80009020 <etext+0x20>
      for(; *s; s++)
    80000706:	02800513          	li	a0,40
    8000070a:	b7cd                	j	800006ec <printf+0x16a>
      consputc('%');
    8000070c:	8556                	mv	a0,s5
    8000070e:	00000097          	auipc	ra,0x0
    80000712:	b66080e7          	jalr	-1178(ra) # 80000274 <consputc>
      break;
    80000716:	b719                	j	8000061c <printf+0x9a>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b5a080e7          	jalr	-1190(ra) # 80000274 <consputc>
      consputc(c);
    80000722:	8526                	mv	a0,s1
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b50080e7          	jalr	-1200(ra) # 80000274 <consputc>
      break;
    8000072c:	bdc5                	j	8000061c <printf+0x9a>
  if(locking)
    8000072e:	020d9163          	bnez	s11,80000750 <printf+0x1ce>
}
    80000732:	70e6                	ld	ra,120(sp)
    80000734:	7446                	ld	s0,112(sp)
    80000736:	74a6                	ld	s1,104(sp)
    80000738:	7906                	ld	s2,96(sp)
    8000073a:	69e6                	ld	s3,88(sp)
    8000073c:	6a46                	ld	s4,80(sp)
    8000073e:	6aa6                	ld	s5,72(sp)
    80000740:	6b06                	ld	s6,64(sp)
    80000742:	7be2                	ld	s7,56(sp)
    80000744:	7c42                	ld	s8,48(sp)
    80000746:	7ca2                	ld	s9,40(sp)
    80000748:	7d02                	ld	s10,32(sp)
    8000074a:	6de2                	ld	s11,24(sp)
    8000074c:	6129                	addi	sp,sp,192
    8000074e:	8082                	ret
    release(&pr.lock);
    80000750:	00012517          	auipc	a0,0x12
    80000754:	b1850513          	addi	a0,a0,-1256 # 80012268 <pr>
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	52a080e7          	jalr	1322(ra) # 80000c82 <release>
}
    80000760:	bfc9                	j	80000732 <printf+0x1b0>

0000000080000762 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000762:	1101                	addi	sp,sp,-32
    80000764:	ec06                	sd	ra,24(sp)
    80000766:	e822                	sd	s0,16(sp)
    80000768:	e426                	sd	s1,8(sp)
    8000076a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076c:	00012497          	auipc	s1,0x12
    80000770:	afc48493          	addi	s1,s1,-1284 # 80012268 <pr>
    80000774:	00009597          	auipc	a1,0x9
    80000778:	8c458593          	addi	a1,a1,-1852 # 80009038 <etext+0x38>
    8000077c:	8526                	mv	a0,s1
    8000077e:	00000097          	auipc	ra,0x0
    80000782:	3c0080e7          	jalr	960(ra) # 80000b3e <initlock>
  pr.locking = 1;
    80000786:	4785                	li	a5,1
    80000788:	cc9c                	sw	a5,24(s1)
}
    8000078a:	60e2                	ld	ra,24(sp)
    8000078c:	6442                	ld	s0,16(sp)
    8000078e:	64a2                	ld	s1,8(sp)
    80000790:	6105                	addi	sp,sp,32
    80000792:	8082                	ret

0000000080000794 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000794:	1141                	addi	sp,sp,-16
    80000796:	e406                	sd	ra,8(sp)
    80000798:	e022                	sd	s0,0(sp)
    8000079a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079c:	100007b7          	lui	a5,0x10000
    800007a0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a4:	f8000713          	li	a4,-128
    800007a8:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ac:	470d                	li	a4,3
    800007ae:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b2:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b6:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ba:	469d                	li	a3,7
    800007bc:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c0:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c4:	00009597          	auipc	a1,0x9
    800007c8:	89458593          	addi	a1,a1,-1900 # 80009058 <digits+0x18>
    800007cc:	00012517          	auipc	a0,0x12
    800007d0:	abc50513          	addi	a0,a0,-1348 # 80012288 <uart_tx_lock>
    800007d4:	00000097          	auipc	ra,0x0
    800007d8:	36a080e7          	jalr	874(ra) # 80000b3e <initlock>
}
    800007dc:	60a2                	ld	ra,8(sp)
    800007de:	6402                	ld	s0,0(sp)
    800007e0:	0141                	addi	sp,sp,16
    800007e2:	8082                	ret

00000000800007e4 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e4:	1101                	addi	sp,sp,-32
    800007e6:	ec06                	sd	ra,24(sp)
    800007e8:	e822                	sd	s0,16(sp)
    800007ea:	e426                	sd	s1,8(sp)
    800007ec:	1000                	addi	s0,sp,32
    800007ee:	84aa                	mv	s1,a0
  push_off();
    800007f0:	00000097          	auipc	ra,0x0
    800007f4:	392080e7          	jalr	914(ra) # 80000b82 <push_off>

  if(panicked){
    800007f8:	0000a797          	auipc	a5,0xa
    800007fc:	8087a783          	lw	a5,-2040(a5) # 8000a000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000800:	10000737          	lui	a4,0x10000
  if(panicked){
    80000804:	c391                	beqz	a5,80000808 <uartputc_sync+0x24>
    for(;;)
    80000806:	a001                	j	80000806 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080c:	0207f793          	andi	a5,a5,32
    80000810:	dfe5                	beqz	a5,80000808 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000812:	0ff4f513          	zext.b	a0,s1
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000081e:	00000097          	auipc	ra,0x0
    80000822:	404080e7          	jalr	1028(ra) # 80000c22 <pop_off>
}
    80000826:	60e2                	ld	ra,24(sp)
    80000828:	6442                	ld	s0,16(sp)
    8000082a:	64a2                	ld	s1,8(sp)
    8000082c:	6105                	addi	sp,sp,32
    8000082e:	8082                	ret

0000000080000830 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000830:	00009797          	auipc	a5,0x9
    80000834:	7d87b783          	ld	a5,2008(a5) # 8000a008 <uart_tx_r>
    80000838:	00009717          	auipc	a4,0x9
    8000083c:	7d873703          	ld	a4,2008(a4) # 8000a010 <uart_tx_w>
    80000840:	06f70a63          	beq	a4,a5,800008b4 <uartstart+0x84>
{
    80000844:	7139                	addi	sp,sp,-64
    80000846:	fc06                	sd	ra,56(sp)
    80000848:	f822                	sd	s0,48(sp)
    8000084a:	f426                	sd	s1,40(sp)
    8000084c:	f04a                	sd	s2,32(sp)
    8000084e:	ec4e                	sd	s3,24(sp)
    80000850:	e852                	sd	s4,16(sp)
    80000852:	e456                	sd	s5,8(sp)
    80000854:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000856:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085a:	00012a17          	auipc	s4,0x12
    8000085e:	a2ea0a13          	addi	s4,s4,-1490 # 80012288 <uart_tx_lock>
    uart_tx_r += 1;
    80000862:	00009497          	auipc	s1,0x9
    80000866:	7a648493          	addi	s1,s1,1958 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086a:	00009997          	auipc	s3,0x9
    8000086e:	7a698993          	addi	s3,s3,1958 # 8000a010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000872:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000876:	02077713          	andi	a4,a4,32
    8000087a:	c705                	beqz	a4,800008a2 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000087c:	01f7f713          	andi	a4,a5,31
    80000880:	9752                	add	a4,a4,s4
    80000882:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000886:	0785                	addi	a5,a5,1
    80000888:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088a:	8526                	mv	a0,s1
    8000088c:	00002097          	auipc	ra,0x2
    80000890:	2e4080e7          	jalr	740(ra) # 80002b70 <wakeup>
    
    WriteReg(THR, c);
    80000894:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80000898:	609c                	ld	a5,0(s1)
    8000089a:	0009b703          	ld	a4,0(s3)
    8000089e:	fcf71ae3          	bne	a4,a5,80000872 <uartstart+0x42>
  }
}
    800008a2:	70e2                	ld	ra,56(sp)
    800008a4:	7442                	ld	s0,48(sp)
    800008a6:	74a2                	ld	s1,40(sp)
    800008a8:	7902                	ld	s2,32(sp)
    800008aa:	69e2                	ld	s3,24(sp)
    800008ac:	6a42                	ld	s4,16(sp)
    800008ae:	6aa2                	ld	s5,8(sp)
    800008b0:	6121                	addi	sp,sp,64
    800008b2:	8082                	ret
    800008b4:	8082                	ret

00000000800008b6 <uartputc>:
{
    800008b6:	7179                	addi	sp,sp,-48
    800008b8:	f406                	sd	ra,40(sp)
    800008ba:	f022                	sd	s0,32(sp)
    800008bc:	ec26                	sd	s1,24(sp)
    800008be:	e84a                	sd	s2,16(sp)
    800008c0:	e44e                	sd	s3,8(sp)
    800008c2:	e052                	sd	s4,0(sp)
    800008c4:	1800                	addi	s0,sp,48
    800008c6:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008c8:	00012517          	auipc	a0,0x12
    800008cc:	9c050513          	addi	a0,a0,-1600 # 80012288 <uart_tx_lock>
    800008d0:	00000097          	auipc	ra,0x0
    800008d4:	2fe080e7          	jalr	766(ra) # 80000bce <acquire>
  if(panicked){
    800008d8:	00009797          	auipc	a5,0x9
    800008dc:	7287a783          	lw	a5,1832(a5) # 8000a000 <panicked>
    800008e0:	c391                	beqz	a5,800008e4 <uartputc+0x2e>
    for(;;)
    800008e2:	a001                	j	800008e2 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e4:	00009717          	auipc	a4,0x9
    800008e8:	72c73703          	ld	a4,1836(a4) # 8000a010 <uart_tx_w>
    800008ec:	00009797          	auipc	a5,0x9
    800008f0:	71c7b783          	ld	a5,1820(a5) # 8000a008 <uart_tx_r>
    800008f4:	02078793          	addi	a5,a5,32
    800008f8:	02e79b63          	bne	a5,a4,8000092e <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00012997          	auipc	s3,0x12
    80000900:	98c98993          	addi	s3,s3,-1652 # 80012288 <uart_tx_lock>
    80000904:	00009497          	auipc	s1,0x9
    80000908:	70448493          	addi	s1,s1,1796 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00009917          	auipc	s2,0x9
    80000910:	70490913          	addi	s2,s2,1796 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000914:	85ce                	mv	a1,s3
    80000916:	8526                	mv	a0,s1
    80000918:	00002097          	auipc	ra,0x2
    8000091c:	e54080e7          	jalr	-428(ra) # 8000276c <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00093703          	ld	a4,0(s2)
    80000924:	609c                	ld	a5,0(s1)
    80000926:	02078793          	addi	a5,a5,32
    8000092a:	fee785e3          	beq	a5,a4,80000914 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000092e:	00012497          	auipc	s1,0x12
    80000932:	95a48493          	addi	s1,s1,-1702 # 80012288 <uart_tx_lock>
    80000936:	01f77793          	andi	a5,a4,31
    8000093a:	97a6                	add	a5,a5,s1
    8000093c:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000940:	0705                	addi	a4,a4,1
    80000942:	00009797          	auipc	a5,0x9
    80000946:	6ce7b723          	sd	a4,1742(a5) # 8000a010 <uart_tx_w>
      uartstart();
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	ee6080e7          	jalr	-282(ra) # 80000830 <uartstart>
      release(&uart_tx_lock);
    80000952:	8526                	mv	a0,s1
    80000954:	00000097          	auipc	ra,0x0
    80000958:	32e080e7          	jalr	814(ra) # 80000c82 <release>
}
    8000095c:	70a2                	ld	ra,40(sp)
    8000095e:	7402                	ld	s0,32(sp)
    80000960:	64e2                	ld	s1,24(sp)
    80000962:	6942                	ld	s2,16(sp)
    80000964:	69a2                	ld	s3,8(sp)
    80000966:	6a02                	ld	s4,0(sp)
    80000968:	6145                	addi	sp,sp,48
    8000096a:	8082                	ret

000000008000096c <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000096c:	1141                	addi	sp,sp,-16
    8000096e:	e422                	sd	s0,8(sp)
    80000970:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000972:	100007b7          	lui	a5,0x10000
    80000976:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097a:	8b85                	andi	a5,a5,1
    8000097c:	cb81                	beqz	a5,8000098c <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    8000097e:	100007b7          	lui	a5,0x10000
    80000982:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000986:	6422                	ld	s0,8(sp)
    80000988:	0141                	addi	sp,sp,16
    8000098a:	8082                	ret
    return -1;
    8000098c:	557d                	li	a0,-1
    8000098e:	bfe5                	j	80000986 <uartgetc+0x1a>

0000000080000990 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000990:	1101                	addi	sp,sp,-32
    80000992:	ec06                	sd	ra,24(sp)
    80000994:	e822                	sd	s0,16(sp)
    80000996:	e426                	sd	s1,8(sp)
    80000998:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099a:	54fd                	li	s1,-1
    8000099c:	a029                	j	800009a6 <uartintr+0x16>
      break;
    consoleintr(c);
    8000099e:	00000097          	auipc	ra,0x0
    800009a2:	918080e7          	jalr	-1768(ra) # 800002b6 <consoleintr>
    int c = uartgetc();
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	fc6080e7          	jalr	-58(ra) # 8000096c <uartgetc>
    if(c == -1)
    800009ae:	fe9518e3          	bne	a0,s1,8000099e <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b2:	00012497          	auipc	s1,0x12
    800009b6:	8d648493          	addi	s1,s1,-1834 # 80012288 <uart_tx_lock>
    800009ba:	8526                	mv	a0,s1
    800009bc:	00000097          	auipc	ra,0x0
    800009c0:	212080e7          	jalr	530(ra) # 80000bce <acquire>
  uartstart();
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	e6c080e7          	jalr	-404(ra) # 80000830 <uartstart>
  release(&uart_tx_lock);
    800009cc:	8526                	mv	a0,s1
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	2b4080e7          	jalr	692(ra) # 80000c82 <release>
}
    800009d6:	60e2                	ld	ra,24(sp)
    800009d8:	6442                	ld	s0,16(sp)
    800009da:	64a2                	ld	s1,8(sp)
    800009dc:	6105                	addi	sp,sp,32
    800009de:	8082                	ret

00000000800009e0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e0:	1101                	addi	sp,sp,-32
    800009e2:	ec06                	sd	ra,24(sp)
    800009e4:	e822                	sd	s0,16(sp)
    800009e6:	e426                	sd	s1,8(sp)
    800009e8:	e04a                	sd	s2,0(sp)
    800009ea:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009ec:	03451793          	slli	a5,a0,0x34
    800009f0:	ebb9                	bnez	a5,80000a46 <kfree+0x66>
    800009f2:	84aa                	mv	s1,a0
    800009f4:	00027797          	auipc	a5,0x27
    800009f8:	60c78793          	addi	a5,a5,1548 # 80028000 <end>
    800009fc:	04f56563          	bltu	a0,a5,80000a46 <kfree+0x66>
    80000a00:	47c5                	li	a5,17
    80000a02:	07ee                	slli	a5,a5,0x1b
    80000a04:	04f57163          	bgeu	a0,a5,80000a46 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a08:	6605                	lui	a2,0x1
    80000a0a:	4585                	li	a1,1
    80000a0c:	00000097          	auipc	ra,0x0
    80000a10:	2be080e7          	jalr	702(ra) # 80000cca <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a14:	00012917          	auipc	s2,0x12
    80000a18:	8ac90913          	addi	s2,s2,-1876 # 800122c0 <kmem>
    80000a1c:	854a                	mv	a0,s2
    80000a1e:	00000097          	auipc	ra,0x0
    80000a22:	1b0080e7          	jalr	432(ra) # 80000bce <acquire>
  r->next = kmem.freelist;
    80000a26:	01893783          	ld	a5,24(s2)
    80000a2a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a30:	854a                	mv	a0,s2
    80000a32:	00000097          	auipc	ra,0x0
    80000a36:	250080e7          	jalr	592(ra) # 80000c82 <release>
}
    80000a3a:	60e2                	ld	ra,24(sp)
    80000a3c:	6442                	ld	s0,16(sp)
    80000a3e:	64a2                	ld	s1,8(sp)
    80000a40:	6902                	ld	s2,0(sp)
    80000a42:	6105                	addi	sp,sp,32
    80000a44:	8082                	ret
    panic("kfree");
    80000a46:	00008517          	auipc	a0,0x8
    80000a4a:	61a50513          	addi	a0,a0,1562 # 80009060 <digits+0x20>
    80000a4e:	00000097          	auipc	ra,0x0
    80000a52:	aea080e7          	jalr	-1302(ra) # 80000538 <panic>

0000000080000a56 <freerange>:
{
    80000a56:	7179                	addi	sp,sp,-48
    80000a58:	f406                	sd	ra,40(sp)
    80000a5a:	f022                	sd	s0,32(sp)
    80000a5c:	ec26                	sd	s1,24(sp)
    80000a5e:	e84a                	sd	s2,16(sp)
    80000a60:	e44e                	sd	s3,8(sp)
    80000a62:	e052                	sd	s4,0(sp)
    80000a64:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a66:	6785                	lui	a5,0x1
    80000a68:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a6c:	00e504b3          	add	s1,a0,a4
    80000a70:	777d                	lui	a4,0xfffff
    80000a72:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a74:	94be                	add	s1,s1,a5
    80000a76:	0095ee63          	bltu	a1,s1,80000a92 <freerange+0x3c>
    80000a7a:	892e                	mv	s2,a1
    kfree(p);
    80000a7c:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7e:	6985                	lui	s3,0x1
    kfree(p);
    80000a80:	01448533          	add	a0,s1,s4
    80000a84:	00000097          	auipc	ra,0x0
    80000a88:	f5c080e7          	jalr	-164(ra) # 800009e0 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8c:	94ce                	add	s1,s1,s3
    80000a8e:	fe9979e3          	bgeu	s2,s1,80000a80 <freerange+0x2a>
}
    80000a92:	70a2                	ld	ra,40(sp)
    80000a94:	7402                	ld	s0,32(sp)
    80000a96:	64e2                	ld	s1,24(sp)
    80000a98:	6942                	ld	s2,16(sp)
    80000a9a:	69a2                	ld	s3,8(sp)
    80000a9c:	6a02                	ld	s4,0(sp)
    80000a9e:	6145                	addi	sp,sp,48
    80000aa0:	8082                	ret

0000000080000aa2 <kinit>:
{
    80000aa2:	1141                	addi	sp,sp,-16
    80000aa4:	e406                	sd	ra,8(sp)
    80000aa6:	e022                	sd	s0,0(sp)
    80000aa8:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aaa:	00008597          	auipc	a1,0x8
    80000aae:	5be58593          	addi	a1,a1,1470 # 80009068 <digits+0x28>
    80000ab2:	00012517          	auipc	a0,0x12
    80000ab6:	80e50513          	addi	a0,a0,-2034 # 800122c0 <kmem>
    80000aba:	00000097          	auipc	ra,0x0
    80000abe:	084080e7          	jalr	132(ra) # 80000b3e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac2:	45c5                	li	a1,17
    80000ac4:	05ee                	slli	a1,a1,0x1b
    80000ac6:	00027517          	auipc	a0,0x27
    80000aca:	53a50513          	addi	a0,a0,1338 # 80028000 <end>
    80000ace:	00000097          	auipc	ra,0x0
    80000ad2:	f88080e7          	jalr	-120(ra) # 80000a56 <freerange>
}
    80000ad6:	60a2                	ld	ra,8(sp)
    80000ad8:	6402                	ld	s0,0(sp)
    80000ada:	0141                	addi	sp,sp,16
    80000adc:	8082                	ret

0000000080000ade <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ade:	1101                	addi	sp,sp,-32
    80000ae0:	ec06                	sd	ra,24(sp)
    80000ae2:	e822                	sd	s0,16(sp)
    80000ae4:	e426                	sd	s1,8(sp)
    80000ae6:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ae8:	00011497          	auipc	s1,0x11
    80000aec:	7d848493          	addi	s1,s1,2008 # 800122c0 <kmem>
    80000af0:	8526                	mv	a0,s1
    80000af2:	00000097          	auipc	ra,0x0
    80000af6:	0dc080e7          	jalr	220(ra) # 80000bce <acquire>
  r = kmem.freelist;
    80000afa:	6c84                	ld	s1,24(s1)
  if(r)
    80000afc:	c885                	beqz	s1,80000b2c <kalloc+0x4e>
    kmem.freelist = r->next;
    80000afe:	609c                	ld	a5,0(s1)
    80000b00:	00011517          	auipc	a0,0x11
    80000b04:	7c050513          	addi	a0,a0,1984 # 800122c0 <kmem>
    80000b08:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0a:	00000097          	auipc	ra,0x0
    80000b0e:	178080e7          	jalr	376(ra) # 80000c82 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b12:	6605                	lui	a2,0x1
    80000b14:	4595                	li	a1,5
    80000b16:	8526                	mv	a0,s1
    80000b18:	00000097          	auipc	ra,0x0
    80000b1c:	1b2080e7          	jalr	434(ra) # 80000cca <memset>
  return (void*)r;
}
    80000b20:	8526                	mv	a0,s1
    80000b22:	60e2                	ld	ra,24(sp)
    80000b24:	6442                	ld	s0,16(sp)
    80000b26:	64a2                	ld	s1,8(sp)
    80000b28:	6105                	addi	sp,sp,32
    80000b2a:	8082                	ret
  release(&kmem.lock);
    80000b2c:	00011517          	auipc	a0,0x11
    80000b30:	79450513          	addi	a0,a0,1940 # 800122c0 <kmem>
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	14e080e7          	jalr	334(ra) # 80000c82 <release>
  if(r)
    80000b3c:	b7d5                	j	80000b20 <kalloc+0x42>

0000000080000b3e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b3e:	1141                	addi	sp,sp,-16
    80000b40:	e422                	sd	s0,8(sp)
    80000b42:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b44:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b46:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4a:	00053823          	sd	zero,16(a0)
}
    80000b4e:	6422                	ld	s0,8(sp)
    80000b50:	0141                	addi	sp,sp,16
    80000b52:	8082                	ret

0000000080000b54 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b54:	411c                	lw	a5,0(a0)
    80000b56:	e399                	bnez	a5,80000b5c <holding+0x8>
    80000b58:	4501                	li	a0,0
  return r;
}
    80000b5a:	8082                	ret
{
    80000b5c:	1101                	addi	sp,sp,-32
    80000b5e:	ec06                	sd	ra,24(sp)
    80000b60:	e822                	sd	s0,16(sp)
    80000b62:	e426                	sd	s1,8(sp)
    80000b64:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b66:	6904                	ld	s1,16(a0)
    80000b68:	00001097          	auipc	ra,0x1
    80000b6c:	e36080e7          	jalr	-458(ra) # 8000199e <mycpu>
    80000b70:	40a48533          	sub	a0,s1,a0
    80000b74:	00153513          	seqz	a0,a0
}
    80000b78:	60e2                	ld	ra,24(sp)
    80000b7a:	6442                	ld	s0,16(sp)
    80000b7c:	64a2                	ld	s1,8(sp)
    80000b7e:	6105                	addi	sp,sp,32
    80000b80:	8082                	ret

0000000080000b82 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b82:	1101                	addi	sp,sp,-32
    80000b84:	ec06                	sd	ra,24(sp)
    80000b86:	e822                	sd	s0,16(sp)
    80000b88:	e426                	sd	s1,8(sp)
    80000b8a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b8c:	100024f3          	csrr	s1,sstatus
    80000b90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b94:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b96:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	e04080e7          	jalr	-508(ra) # 8000199e <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	cf89                	beqz	a5,80000bbe <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba6:	00001097          	auipc	ra,0x1
    80000baa:	df8080e7          	jalr	-520(ra) # 8000199e <mycpu>
    80000bae:	5d3c                	lw	a5,120(a0)
    80000bb0:	2785                	addiw	a5,a5,1
    80000bb2:	dd3c                	sw	a5,120(a0)
}
    80000bb4:	60e2                	ld	ra,24(sp)
    80000bb6:	6442                	ld	s0,16(sp)
    80000bb8:	64a2                	ld	s1,8(sp)
    80000bba:	6105                	addi	sp,sp,32
    80000bbc:	8082                	ret
    mycpu()->intena = old;
    80000bbe:	00001097          	auipc	ra,0x1
    80000bc2:	de0080e7          	jalr	-544(ra) # 8000199e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	bfe9                	j	80000ba6 <push_off+0x24>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	00000097          	auipc	ra,0x0
    80000bde:	fa8080e7          	jalr	-88(ra) # 80000b82 <push_off>
  if(holding(lk))
    80000be2:	8526                	mv	a0,s1
    80000be4:	00000097          	auipc	ra,0x0
    80000be8:	f70080e7          	jalr	-144(ra) # 80000b54 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bec:	4705                	li	a4,1
  if(holding(lk))
    80000bee:	e115                	bnez	a0,80000c12 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	87ba                	mv	a5,a4
    80000bf2:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf6:	2781                	sext.w	a5,a5
    80000bf8:	ffe5                	bnez	a5,80000bf0 <acquire+0x22>
  __sync_synchronize();
    80000bfa:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bfe:	00001097          	auipc	ra,0x1
    80000c02:	da0080e7          	jalr	-608(ra) # 8000199e <mycpu>
    80000c06:	e888                	sd	a0,16(s1)
}
    80000c08:	60e2                	ld	ra,24(sp)
    80000c0a:	6442                	ld	s0,16(sp)
    80000c0c:	64a2                	ld	s1,8(sp)
    80000c0e:	6105                	addi	sp,sp,32
    80000c10:	8082                	ret
    panic("acquire");
    80000c12:	00008517          	auipc	a0,0x8
    80000c16:	45e50513          	addi	a0,a0,1118 # 80009070 <digits+0x30>
    80000c1a:	00000097          	auipc	ra,0x0
    80000c1e:	91e080e7          	jalr	-1762(ra) # 80000538 <panic>

0000000080000c22 <pop_off>:

void
pop_off(void)
{
    80000c22:	1141                	addi	sp,sp,-16
    80000c24:	e406                	sd	ra,8(sp)
    80000c26:	e022                	sd	s0,0(sp)
    80000c28:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2a:	00001097          	auipc	ra,0x1
    80000c2e:	d74080e7          	jalr	-652(ra) # 8000199e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c32:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c36:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c38:	e78d                	bnez	a5,80000c62 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3a:	5d3c                	lw	a5,120(a0)
    80000c3c:	02f05b63          	blez	a5,80000c72 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c40:	37fd                	addiw	a5,a5,-1
    80000c42:	0007871b          	sext.w	a4,a5
    80000c46:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c48:	eb09                	bnez	a4,80000c5a <pop_off+0x38>
    80000c4a:	5d7c                	lw	a5,124(a0)
    80000c4c:	c799                	beqz	a5,80000c5a <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c52:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c56:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5a:	60a2                	ld	ra,8(sp)
    80000c5c:	6402                	ld	s0,0(sp)
    80000c5e:	0141                	addi	sp,sp,16
    80000c60:	8082                	ret
    panic("pop_off - interruptible");
    80000c62:	00008517          	auipc	a0,0x8
    80000c66:	41650513          	addi	a0,a0,1046 # 80009078 <digits+0x38>
    80000c6a:	00000097          	auipc	ra,0x0
    80000c6e:	8ce080e7          	jalr	-1842(ra) # 80000538 <panic>
    panic("pop_off");
    80000c72:	00008517          	auipc	a0,0x8
    80000c76:	41e50513          	addi	a0,a0,1054 # 80009090 <digits+0x50>
    80000c7a:	00000097          	auipc	ra,0x0
    80000c7e:	8be080e7          	jalr	-1858(ra) # 80000538 <panic>

0000000080000c82 <release>:
{
    80000c82:	1101                	addi	sp,sp,-32
    80000c84:	ec06                	sd	ra,24(sp)
    80000c86:	e822                	sd	s0,16(sp)
    80000c88:	e426                	sd	s1,8(sp)
    80000c8a:	1000                	addi	s0,sp,32
    80000c8c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c8e:	00000097          	auipc	ra,0x0
    80000c92:	ec6080e7          	jalr	-314(ra) # 80000b54 <holding>
    80000c96:	c115                	beqz	a0,80000cba <release+0x38>
  lk->cpu = 0;
    80000c98:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c9c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca0:	0f50000f          	fence	iorw,ow
    80000ca4:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	f7a080e7          	jalr	-134(ra) # 80000c22 <pop_off>
}
    80000cb0:	60e2                	ld	ra,24(sp)
    80000cb2:	6442                	ld	s0,16(sp)
    80000cb4:	64a2                	ld	s1,8(sp)
    80000cb6:	6105                	addi	sp,sp,32
    80000cb8:	8082                	ret
    panic("release");
    80000cba:	00008517          	auipc	a0,0x8
    80000cbe:	3de50513          	addi	a0,a0,990 # 80009098 <digits+0x58>
    80000cc2:	00000097          	auipc	ra,0x0
    80000cc6:	876080e7          	jalr	-1930(ra) # 80000538 <panic>

0000000080000cca <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cca:	1141                	addi	sp,sp,-16
    80000ccc:	e422                	sd	s0,8(sp)
    80000cce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd0:	ca19                	beqz	a2,80000ce6 <memset+0x1c>
    80000cd2:	87aa                	mv	a5,a0
    80000cd4:	1602                	slli	a2,a2,0x20
    80000cd6:	9201                	srli	a2,a2,0x20
    80000cd8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cdc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce0:	0785                	addi	a5,a5,1
    80000ce2:	fee79de3          	bne	a5,a4,80000cdc <memset+0x12>
  }
  return dst;
}
    80000ce6:	6422                	ld	s0,8(sp)
    80000ce8:	0141                	addi	sp,sp,16
    80000cea:	8082                	ret

0000000080000cec <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cec:	1141                	addi	sp,sp,-16
    80000cee:	e422                	sd	s0,8(sp)
    80000cf0:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf2:	ca05                	beqz	a2,80000d22 <memcmp+0x36>
    80000cf4:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf8:	1682                	slli	a3,a3,0x20
    80000cfa:	9281                	srli	a3,a3,0x20
    80000cfc:	0685                	addi	a3,a3,1
    80000cfe:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d00:	00054783          	lbu	a5,0(a0)
    80000d04:	0005c703          	lbu	a4,0(a1)
    80000d08:	00e79863          	bne	a5,a4,80000d18 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0c:	0505                	addi	a0,a0,1
    80000d0e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d10:	fed518e3          	bne	a0,a3,80000d00 <memcmp+0x14>
  }

  return 0;
    80000d14:	4501                	li	a0,0
    80000d16:	a019                	j	80000d1c <memcmp+0x30>
      return *s1 - *s2;
    80000d18:	40e7853b          	subw	a0,a5,a4
}
    80000d1c:	6422                	ld	s0,8(sp)
    80000d1e:	0141                	addi	sp,sp,16
    80000d20:	8082                	ret
  return 0;
    80000d22:	4501                	li	a0,0
    80000d24:	bfe5                	j	80000d1c <memcmp+0x30>

0000000080000d26 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d26:	1141                	addi	sp,sp,-16
    80000d28:	e422                	sd	s0,8(sp)
    80000d2a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2c:	c205                	beqz	a2,80000d4c <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2e:	02a5e263          	bltu	a1,a0,80000d52 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d32:	1602                	slli	a2,a2,0x20
    80000d34:	9201                	srli	a2,a2,0x20
    80000d36:	00c587b3          	add	a5,a1,a2
{
    80000d3a:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3c:	0585                	addi	a1,a1,1
    80000d3e:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd7001>
    80000d40:	fff5c683          	lbu	a3,-1(a1)
    80000d44:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d48:	fef59ae3          	bne	a1,a5,80000d3c <memmove+0x16>

  return dst;
}
    80000d4c:	6422                	ld	s0,8(sp)
    80000d4e:	0141                	addi	sp,sp,16
    80000d50:	8082                	ret
  if(s < d && s + n > d){
    80000d52:	02061693          	slli	a3,a2,0x20
    80000d56:	9281                	srli	a3,a3,0x20
    80000d58:	00d58733          	add	a4,a1,a3
    80000d5c:	fce57be3          	bgeu	a0,a4,80000d32 <memmove+0xc>
    d += n;
    80000d60:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d62:	fff6079b          	addiw	a5,a2,-1
    80000d66:	1782                	slli	a5,a5,0x20
    80000d68:	9381                	srli	a5,a5,0x20
    80000d6a:	fff7c793          	not	a5,a5
    80000d6e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d70:	177d                	addi	a4,a4,-1
    80000d72:	16fd                	addi	a3,a3,-1
    80000d74:	00074603          	lbu	a2,0(a4)
    80000d78:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7c:	fee79ae3          	bne	a5,a4,80000d70 <memmove+0x4a>
    80000d80:	b7f1                	j	80000d4c <memmove+0x26>

0000000080000d82 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d82:	1141                	addi	sp,sp,-16
    80000d84:	e406                	sd	ra,8(sp)
    80000d86:	e022                	sd	s0,0(sp)
    80000d88:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8a:	00000097          	auipc	ra,0x0
    80000d8e:	f9c080e7          	jalr	-100(ra) # 80000d26 <memmove>
}
    80000d92:	60a2                	ld	ra,8(sp)
    80000d94:	6402                	ld	s0,0(sp)
    80000d96:	0141                	addi	sp,sp,16
    80000d98:	8082                	ret

0000000080000d9a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9a:	1141                	addi	sp,sp,-16
    80000d9c:	e422                	sd	s0,8(sp)
    80000d9e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da0:	ce11                	beqz	a2,80000dbc <strncmp+0x22>
    80000da2:	00054783          	lbu	a5,0(a0)
    80000da6:	cf89                	beqz	a5,80000dc0 <strncmp+0x26>
    80000da8:	0005c703          	lbu	a4,0(a1)
    80000dac:	00f71a63          	bne	a4,a5,80000dc0 <strncmp+0x26>
    n--, p++, q++;
    80000db0:	367d                	addiw	a2,a2,-1
    80000db2:	0505                	addi	a0,a0,1
    80000db4:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db6:	f675                	bnez	a2,80000da2 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db8:	4501                	li	a0,0
    80000dba:	a809                	j	80000dcc <strncmp+0x32>
    80000dbc:	4501                	li	a0,0
    80000dbe:	a039                	j	80000dcc <strncmp+0x32>
  if(n == 0)
    80000dc0:	ca09                	beqz	a2,80000dd2 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc2:	00054503          	lbu	a0,0(a0)
    80000dc6:	0005c783          	lbu	a5,0(a1)
    80000dca:	9d1d                	subw	a0,a0,a5
}
    80000dcc:	6422                	ld	s0,8(sp)
    80000dce:	0141                	addi	sp,sp,16
    80000dd0:	8082                	ret
    return 0;
    80000dd2:	4501                	li	a0,0
    80000dd4:	bfe5                	j	80000dcc <strncmp+0x32>

0000000080000dd6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd6:	1141                	addi	sp,sp,-16
    80000dd8:	e422                	sd	s0,8(sp)
    80000dda:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ddc:	872a                	mv	a4,a0
    80000dde:	8832                	mv	a6,a2
    80000de0:	367d                	addiw	a2,a2,-1
    80000de2:	01005963          	blez	a6,80000df4 <strncpy+0x1e>
    80000de6:	0705                	addi	a4,a4,1
    80000de8:	0005c783          	lbu	a5,0(a1)
    80000dec:	fef70fa3          	sb	a5,-1(a4)
    80000df0:	0585                	addi	a1,a1,1
    80000df2:	f7f5                	bnez	a5,80000dde <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df4:	86ba                	mv	a3,a4
    80000df6:	00c05c63          	blez	a2,80000e0e <strncpy+0x38>
    *s++ = 0;
    80000dfa:	0685                	addi	a3,a3,1
    80000dfc:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e00:	40d707bb          	subw	a5,a4,a3
    80000e04:	37fd                	addiw	a5,a5,-1
    80000e06:	010787bb          	addw	a5,a5,a6
    80000e0a:	fef048e3          	bgtz	a5,80000dfa <strncpy+0x24>
  return os;
}
    80000e0e:	6422                	ld	s0,8(sp)
    80000e10:	0141                	addi	sp,sp,16
    80000e12:	8082                	ret

0000000080000e14 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e14:	1141                	addi	sp,sp,-16
    80000e16:	e422                	sd	s0,8(sp)
    80000e18:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1a:	02c05363          	blez	a2,80000e40 <safestrcpy+0x2c>
    80000e1e:	fff6069b          	addiw	a3,a2,-1
    80000e22:	1682                	slli	a3,a3,0x20
    80000e24:	9281                	srli	a3,a3,0x20
    80000e26:	96ae                	add	a3,a3,a1
    80000e28:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2a:	00d58963          	beq	a1,a3,80000e3c <safestrcpy+0x28>
    80000e2e:	0585                	addi	a1,a1,1
    80000e30:	0785                	addi	a5,a5,1
    80000e32:	fff5c703          	lbu	a4,-1(a1)
    80000e36:	fee78fa3          	sb	a4,-1(a5)
    80000e3a:	fb65                	bnez	a4,80000e2a <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e40:	6422                	ld	s0,8(sp)
    80000e42:	0141                	addi	sp,sp,16
    80000e44:	8082                	ret

0000000080000e46 <strlen>:

int
strlen(const char *s)
{
    80000e46:	1141                	addi	sp,sp,-16
    80000e48:	e422                	sd	s0,8(sp)
    80000e4a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4c:	00054783          	lbu	a5,0(a0)
    80000e50:	cf91                	beqz	a5,80000e6c <strlen+0x26>
    80000e52:	0505                	addi	a0,a0,1
    80000e54:	87aa                	mv	a5,a0
    80000e56:	4685                	li	a3,1
    80000e58:	9e89                	subw	a3,a3,a0
    80000e5a:	00f6853b          	addw	a0,a3,a5
    80000e5e:	0785                	addi	a5,a5,1
    80000e60:	fff7c703          	lbu	a4,-1(a5)
    80000e64:	fb7d                	bnez	a4,80000e5a <strlen+0x14>
    ;
  return n;
}
    80000e66:	6422                	ld	s0,8(sp)
    80000e68:	0141                	addi	sp,sp,16
    80000e6a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6c:	4501                	li	a0,0
    80000e6e:	bfe5                	j	80000e66 <strlen+0x20>

0000000080000e70 <main>:
extern struct buff buff_arr[20];
extern int buff_arr_sem[20];
// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e70:	1141                	addi	sp,sp,-16
    80000e72:	e406                	sd	ra,8(sp)
    80000e74:	e022                	sd	s0,0(sp)
    80000e76:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e78:	00001097          	auipc	ra,0x1
    80000e7c:	b16080e7          	jalr	-1258(ra) # 8000198e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e80:	00009717          	auipc	a4,0x9
    80000e84:	19870713          	addi	a4,a4,408 # 8000a018 <started>
  if(cpuid() == 0){
    80000e88:	c535                	beqz	a0,80000ef4 <main+0x84>
    while(started == 0)
    80000e8a:	431c                	lw	a5,0(a4)
    80000e8c:	2781                	sext.w	a5,a5
    80000e8e:	dff5                	beqz	a5,80000e8a <main+0x1a>
      ;
    __sync_synchronize();
    80000e90:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e94:	00001097          	auipc	ra,0x1
    80000e98:	afa080e7          	jalr	-1286(ra) # 8000198e <cpuid>
    80000e9c:	85aa                	mv	a1,a0
    80000e9e:	00008517          	auipc	a0,0x8
    80000ea2:	21a50513          	addi	a0,a0,538 # 800090b8 <digits+0x78>
    80000ea6:	fffff097          	auipc	ra,0xfffff
    80000eaa:	6dc080e7          	jalr	1756(ra) # 80000582 <printf>
    kvminithart();    // turn on paging
    80000eae:	00000097          	auipc	ra,0x0
    80000eb2:	0fe080e7          	jalr	254(ra) # 80000fac <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb6:	00003097          	auipc	ra,0x3
    80000eba:	8a8080e7          	jalr	-1880(ra) # 8000375e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ebe:	00006097          	auipc	ra,0x6
    80000ec2:	672080e7          	jalr	1650(ra) # 80007530 <plicinithart>
  }

  sched_policy = SCHED_PREEMPT_RR;
    80000ec6:	4789                	li	a5,2
    80000ec8:	00009717          	auipc	a4,0x9
    80000ecc:	1af72023          	sw	a5,416(a4) # 8000a068 <sched_policy>

  for(int i=0; i<10; i++){
    80000ed0:	00018797          	auipc	a5,0x18
    80000ed4:	c5878793          	addi	a5,a5,-936 # 80018b28 <barrier_arr>
    80000ed8:	00018697          	auipc	a3,0x18
    80000edc:	ed068693          	addi	a3,a3,-304 # 80018da8 <lock_delete>
    barrier_arr[i].count = -1;
    80000ee0:	577d                	li	a4,-1
    80000ee2:	c398                	sw	a4,0(a5)
  for(int i=0; i<10; i++){
    80000ee4:	04078793          	addi	a5,a5,64
    80000ee8:	fed79de3          	bne	a5,a3,80000ee2 <main+0x72>
  }

  scheduler();        
    80000eec:	00001097          	auipc	ra,0x1
    80000ef0:	31e080e7          	jalr	798(ra) # 8000220a <scheduler>
    consoleinit();
    80000ef4:	fffff097          	auipc	ra,0xfffff
    80000ef8:	554080e7          	jalr	1364(ra) # 80000448 <consoleinit>
    printfinit();
    80000efc:	00000097          	auipc	ra,0x0
    80000f00:	866080e7          	jalr	-1946(ra) # 80000762 <printfinit>
    printf("\n");
    80000f04:	00009517          	auipc	a0,0x9
    80000f08:	88c50513          	addi	a0,a0,-1908 # 80009790 <syscalls+0x150>
    80000f0c:	fffff097          	auipc	ra,0xfffff
    80000f10:	676080e7          	jalr	1654(ra) # 80000582 <printf>
    printf("xv6 kernel is booting\n");
    80000f14:	00008517          	auipc	a0,0x8
    80000f18:	18c50513          	addi	a0,a0,396 # 800090a0 <digits+0x60>
    80000f1c:	fffff097          	auipc	ra,0xfffff
    80000f20:	666080e7          	jalr	1638(ra) # 80000582 <printf>
    printf("\n");
    80000f24:	00009517          	auipc	a0,0x9
    80000f28:	86c50513          	addi	a0,a0,-1940 # 80009790 <syscalls+0x150>
    80000f2c:	fffff097          	auipc	ra,0xfffff
    80000f30:	656080e7          	jalr	1622(ra) # 80000582 <printf>
    kinit();         // physical page allocator
    80000f34:	00000097          	auipc	ra,0x0
    80000f38:	b6e080e7          	jalr	-1170(ra) # 80000aa2 <kinit>
    kvminit();       // create kernel page table
    80000f3c:	00000097          	auipc	ra,0x0
    80000f40:	322080e7          	jalr	802(ra) # 8000125e <kvminit>
    kvminithart();   // turn on paging
    80000f44:	00000097          	auipc	ra,0x0
    80000f48:	068080e7          	jalr	104(ra) # 80000fac <kvminithart>
    procinit();      // process table
    80000f4c:	00001097          	auipc	ra,0x1
    80000f50:	992080e7          	jalr	-1646(ra) # 800018de <procinit>
    trapinit();      // trap vectors
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	7e2080e7          	jalr	2018(ra) # 80003736 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5c:	00003097          	auipc	ra,0x3
    80000f60:	802080e7          	jalr	-2046(ra) # 8000375e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f64:	00006097          	auipc	ra,0x6
    80000f68:	5b6080e7          	jalr	1462(ra) # 8000751a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6c:	00006097          	auipc	ra,0x6
    80000f70:	5c4080e7          	jalr	1476(ra) # 80007530 <plicinithart>
    binit();         // buffer cache
    80000f74:	00003097          	auipc	ra,0x3
    80000f78:	78a080e7          	jalr	1930(ra) # 800046fe <binit>
    iinit();         // inode table
    80000f7c:	00004097          	auipc	ra,0x4
    80000f80:	e18080e7          	jalr	-488(ra) # 80004d94 <iinit>
    fileinit();      // file table
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	dca080e7          	jalr	-566(ra) # 80005d4e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8c:	00006097          	auipc	ra,0x6
    80000f90:	6c4080e7          	jalr	1732(ra) # 80007650 <virtio_disk_init>
    userinit();      // first user process
    80000f94:	00001097          	auipc	ra,0x1
    80000f98:	d74080e7          	jalr	-652(ra) # 80001d08 <userinit>
    __sync_synchronize();
    80000f9c:	0ff0000f          	fence
    started = 1;
    80000fa0:	4785                	li	a5,1
    80000fa2:	00009717          	auipc	a4,0x9
    80000fa6:	06f72b23          	sw	a5,118(a4) # 8000a018 <started>
    80000faa:	bf31                	j	80000ec6 <main+0x56>

0000000080000fac <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fac:	1141                	addi	sp,sp,-16
    80000fae:	e422                	sd	s0,8(sp)
    80000fb0:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fb2:	00009797          	auipc	a5,0x9
    80000fb6:	06e7b783          	ld	a5,110(a5) # 8000a020 <kernel_pagetable>
    80000fba:	83b1                	srli	a5,a5,0xc
    80000fbc:	577d                	li	a4,-1
    80000fbe:	177e                	slli	a4,a4,0x3f
    80000fc0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fc2:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fc6:	12000073          	sfence.vma
  sfence_vma();
}
    80000fca:	6422                	ld	s0,8(sp)
    80000fcc:	0141                	addi	sp,sp,16
    80000fce:	8082                	ret

0000000080000fd0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fd0:	7139                	addi	sp,sp,-64
    80000fd2:	fc06                	sd	ra,56(sp)
    80000fd4:	f822                	sd	s0,48(sp)
    80000fd6:	f426                	sd	s1,40(sp)
    80000fd8:	f04a                	sd	s2,32(sp)
    80000fda:	ec4e                	sd	s3,24(sp)
    80000fdc:	e852                	sd	s4,16(sp)
    80000fde:	e456                	sd	s5,8(sp)
    80000fe0:	e05a                	sd	s6,0(sp)
    80000fe2:	0080                	addi	s0,sp,64
    80000fe4:	84aa                	mv	s1,a0
    80000fe6:	89ae                	mv	s3,a1
    80000fe8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fea:	57fd                	li	a5,-1
    80000fec:	83e9                	srli	a5,a5,0x1a
    80000fee:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ff0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ff2:	04b7f263          	bgeu	a5,a1,80001036 <walk+0x66>
    panic("walk");
    80000ff6:	00008517          	auipc	a0,0x8
    80000ffa:	0da50513          	addi	a0,a0,218 # 800090d0 <digits+0x90>
    80000ffe:	fffff097          	auipc	ra,0xfffff
    80001002:	53a080e7          	jalr	1338(ra) # 80000538 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001006:	060a8663          	beqz	s5,80001072 <walk+0xa2>
    8000100a:	00000097          	auipc	ra,0x0
    8000100e:	ad4080e7          	jalr	-1324(ra) # 80000ade <kalloc>
    80001012:	84aa                	mv	s1,a0
    80001014:	c529                	beqz	a0,8000105e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001016:	6605                	lui	a2,0x1
    80001018:	4581                	li	a1,0
    8000101a:	00000097          	auipc	ra,0x0
    8000101e:	cb0080e7          	jalr	-848(ra) # 80000cca <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001022:	00c4d793          	srli	a5,s1,0xc
    80001026:	07aa                	slli	a5,a5,0xa
    80001028:	0017e793          	ori	a5,a5,1
    8000102c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001030:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd6ff7>
    80001032:	036a0063          	beq	s4,s6,80001052 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001036:	0149d933          	srl	s2,s3,s4
    8000103a:	1ff97913          	andi	s2,s2,511
    8000103e:	090e                	slli	s2,s2,0x3
    80001040:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001042:	00093483          	ld	s1,0(s2)
    80001046:	0014f793          	andi	a5,s1,1
    8000104a:	dfd5                	beqz	a5,80001006 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000104c:	80a9                	srli	s1,s1,0xa
    8000104e:	04b2                	slli	s1,s1,0xc
    80001050:	b7c5                	j	80001030 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001052:	00c9d513          	srli	a0,s3,0xc
    80001056:	1ff57513          	andi	a0,a0,511
    8000105a:	050e                	slli	a0,a0,0x3
    8000105c:	9526                	add	a0,a0,s1
}
    8000105e:	70e2                	ld	ra,56(sp)
    80001060:	7442                	ld	s0,48(sp)
    80001062:	74a2                	ld	s1,40(sp)
    80001064:	7902                	ld	s2,32(sp)
    80001066:	69e2                	ld	s3,24(sp)
    80001068:	6a42                	ld	s4,16(sp)
    8000106a:	6aa2                	ld	s5,8(sp)
    8000106c:	6b02                	ld	s6,0(sp)
    8000106e:	6121                	addi	sp,sp,64
    80001070:	8082                	ret
        return 0;
    80001072:	4501                	li	a0,0
    80001074:	b7ed                	j	8000105e <walk+0x8e>

0000000080001076 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001076:	57fd                	li	a5,-1
    80001078:	83e9                	srli	a5,a5,0x1a
    8000107a:	00b7f463          	bgeu	a5,a1,80001082 <walkaddr+0xc>
    return 0;
    8000107e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001080:	8082                	ret
{
    80001082:	1141                	addi	sp,sp,-16
    80001084:	e406                	sd	ra,8(sp)
    80001086:	e022                	sd	s0,0(sp)
    80001088:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000108a:	4601                	li	a2,0
    8000108c:	00000097          	auipc	ra,0x0
    80001090:	f44080e7          	jalr	-188(ra) # 80000fd0 <walk>
  if(pte == 0)
    80001094:	c105                	beqz	a0,800010b4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001096:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001098:	0117f693          	andi	a3,a5,17
    8000109c:	4745                	li	a4,17
    return 0;
    8000109e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a0:	00e68663          	beq	a3,a4,800010ac <walkaddr+0x36>
}
    800010a4:	60a2                	ld	ra,8(sp)
    800010a6:	6402                	ld	s0,0(sp)
    800010a8:	0141                	addi	sp,sp,16
    800010aa:	8082                	ret
  pa = PTE2PA(*pte);
    800010ac:	83a9                	srli	a5,a5,0xa
    800010ae:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010b2:	bfcd                	j	800010a4 <walkaddr+0x2e>
    return 0;
    800010b4:	4501                	li	a0,0
    800010b6:	b7fd                	j	800010a4 <walkaddr+0x2e>

00000000800010b8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b8:	715d                	addi	sp,sp,-80
    800010ba:	e486                	sd	ra,72(sp)
    800010bc:	e0a2                	sd	s0,64(sp)
    800010be:	fc26                	sd	s1,56(sp)
    800010c0:	f84a                	sd	s2,48(sp)
    800010c2:	f44e                	sd	s3,40(sp)
    800010c4:	f052                	sd	s4,32(sp)
    800010c6:	ec56                	sd	s5,24(sp)
    800010c8:	e85a                	sd	s6,16(sp)
    800010ca:	e45e                	sd	s7,8(sp)
    800010cc:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ce:	c639                	beqz	a2,8000111c <mappages+0x64>
    800010d0:	8aaa                	mv	s5,a0
    800010d2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010d4:	777d                	lui	a4,0xfffff
    800010d6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010da:	fff58993          	addi	s3,a1,-1
    800010de:	99b2                	add	s3,s3,a2
    800010e0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010e4:	893e                	mv	s2,a5
    800010e6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ea:	6b85                	lui	s7,0x1
    800010ec:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010f0:	4605                	li	a2,1
    800010f2:	85ca                	mv	a1,s2
    800010f4:	8556                	mv	a0,s5
    800010f6:	00000097          	auipc	ra,0x0
    800010fa:	eda080e7          	jalr	-294(ra) # 80000fd0 <walk>
    800010fe:	cd1d                	beqz	a0,8000113c <mappages+0x84>
    if(*pte & PTE_V)
    80001100:	611c                	ld	a5,0(a0)
    80001102:	8b85                	andi	a5,a5,1
    80001104:	e785                	bnez	a5,8000112c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001106:	80b1                	srli	s1,s1,0xc
    80001108:	04aa                	slli	s1,s1,0xa
    8000110a:	0164e4b3          	or	s1,s1,s6
    8000110e:	0014e493          	ori	s1,s1,1
    80001112:	e104                	sd	s1,0(a0)
    if(a == last)
    80001114:	05390063          	beq	s2,s3,80001154 <mappages+0x9c>
    a += PGSIZE;
    80001118:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000111a:	bfc9                	j	800010ec <mappages+0x34>
    panic("mappages: size");
    8000111c:	00008517          	auipc	a0,0x8
    80001120:	fbc50513          	addi	a0,a0,-68 # 800090d8 <digits+0x98>
    80001124:	fffff097          	auipc	ra,0xfffff
    80001128:	414080e7          	jalr	1044(ra) # 80000538 <panic>
      panic("mappages: remap");
    8000112c:	00008517          	auipc	a0,0x8
    80001130:	fbc50513          	addi	a0,a0,-68 # 800090e8 <digits+0xa8>
    80001134:	fffff097          	auipc	ra,0xfffff
    80001138:	404080e7          	jalr	1028(ra) # 80000538 <panic>
      return -1;
    8000113c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000113e:	60a6                	ld	ra,72(sp)
    80001140:	6406                	ld	s0,64(sp)
    80001142:	74e2                	ld	s1,56(sp)
    80001144:	7942                	ld	s2,48(sp)
    80001146:	79a2                	ld	s3,40(sp)
    80001148:	7a02                	ld	s4,32(sp)
    8000114a:	6ae2                	ld	s5,24(sp)
    8000114c:	6b42                	ld	s6,16(sp)
    8000114e:	6ba2                	ld	s7,8(sp)
    80001150:	6161                	addi	sp,sp,80
    80001152:	8082                	ret
  return 0;
    80001154:	4501                	li	a0,0
    80001156:	b7e5                	j	8000113e <mappages+0x86>

0000000080001158 <kvmmap>:
{
    80001158:	1141                	addi	sp,sp,-16
    8000115a:	e406                	sd	ra,8(sp)
    8000115c:	e022                	sd	s0,0(sp)
    8000115e:	0800                	addi	s0,sp,16
    80001160:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001162:	86b2                	mv	a3,a2
    80001164:	863e                	mv	a2,a5
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	f52080e7          	jalr	-174(ra) # 800010b8 <mappages>
    8000116e:	e509                	bnez	a0,80001178 <kvmmap+0x20>
}
    80001170:	60a2                	ld	ra,8(sp)
    80001172:	6402                	ld	s0,0(sp)
    80001174:	0141                	addi	sp,sp,16
    80001176:	8082                	ret
    panic("kvmmap");
    80001178:	00008517          	auipc	a0,0x8
    8000117c:	f8050513          	addi	a0,a0,-128 # 800090f8 <digits+0xb8>
    80001180:	fffff097          	auipc	ra,0xfffff
    80001184:	3b8080e7          	jalr	952(ra) # 80000538 <panic>

0000000080001188 <kvmmake>:
{
    80001188:	1101                	addi	sp,sp,-32
    8000118a:	ec06                	sd	ra,24(sp)
    8000118c:	e822                	sd	s0,16(sp)
    8000118e:	e426                	sd	s1,8(sp)
    80001190:	e04a                	sd	s2,0(sp)
    80001192:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001194:	00000097          	auipc	ra,0x0
    80001198:	94a080e7          	jalr	-1718(ra) # 80000ade <kalloc>
    8000119c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000119e:	6605                	lui	a2,0x1
    800011a0:	4581                	li	a1,0
    800011a2:	00000097          	auipc	ra,0x0
    800011a6:	b28080e7          	jalr	-1240(ra) # 80000cca <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011aa:	4719                	li	a4,6
    800011ac:	6685                	lui	a3,0x1
    800011ae:	10000637          	lui	a2,0x10000
    800011b2:	100005b7          	lui	a1,0x10000
    800011b6:	8526                	mv	a0,s1
    800011b8:	00000097          	auipc	ra,0x0
    800011bc:	fa0080e7          	jalr	-96(ra) # 80001158 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011c0:	4719                	li	a4,6
    800011c2:	6685                	lui	a3,0x1
    800011c4:	10001637          	lui	a2,0x10001
    800011c8:	100015b7          	lui	a1,0x10001
    800011cc:	8526                	mv	a0,s1
    800011ce:	00000097          	auipc	ra,0x0
    800011d2:	f8a080e7          	jalr	-118(ra) # 80001158 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011d6:	4719                	li	a4,6
    800011d8:	004006b7          	lui	a3,0x400
    800011dc:	0c000637          	lui	a2,0xc000
    800011e0:	0c0005b7          	lui	a1,0xc000
    800011e4:	8526                	mv	a0,s1
    800011e6:	00000097          	auipc	ra,0x0
    800011ea:	f72080e7          	jalr	-142(ra) # 80001158 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ee:	00008917          	auipc	s2,0x8
    800011f2:	e1290913          	addi	s2,s2,-494 # 80009000 <etext>
    800011f6:	4729                	li	a4,10
    800011f8:	80008697          	auipc	a3,0x80008
    800011fc:	e0868693          	addi	a3,a3,-504 # 9000 <_entry-0x7fff7000>
    80001200:	4605                	li	a2,1
    80001202:	067e                	slli	a2,a2,0x1f
    80001204:	85b2                	mv	a1,a2
    80001206:	8526                	mv	a0,s1
    80001208:	00000097          	auipc	ra,0x0
    8000120c:	f50080e7          	jalr	-176(ra) # 80001158 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001210:	4719                	li	a4,6
    80001212:	46c5                	li	a3,17
    80001214:	06ee                	slli	a3,a3,0x1b
    80001216:	412686b3          	sub	a3,a3,s2
    8000121a:	864a                	mv	a2,s2
    8000121c:	85ca                	mv	a1,s2
    8000121e:	8526                	mv	a0,s1
    80001220:	00000097          	auipc	ra,0x0
    80001224:	f38080e7          	jalr	-200(ra) # 80001158 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001228:	4729                	li	a4,10
    8000122a:	6685                	lui	a3,0x1
    8000122c:	00007617          	auipc	a2,0x7
    80001230:	dd460613          	addi	a2,a2,-556 # 80008000 <_trampoline>
    80001234:	040005b7          	lui	a1,0x4000
    80001238:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000123a:	05b2                	slli	a1,a1,0xc
    8000123c:	8526                	mv	a0,s1
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	f1a080e7          	jalr	-230(ra) # 80001158 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	600080e7          	jalr	1536(ra) # 80001848 <proc_mapstacks>
}
    80001250:	8526                	mv	a0,s1
    80001252:	60e2                	ld	ra,24(sp)
    80001254:	6442                	ld	s0,16(sp)
    80001256:	64a2                	ld	s1,8(sp)
    80001258:	6902                	ld	s2,0(sp)
    8000125a:	6105                	addi	sp,sp,32
    8000125c:	8082                	ret

000000008000125e <kvminit>:
{
    8000125e:	1141                	addi	sp,sp,-16
    80001260:	e406                	sd	ra,8(sp)
    80001262:	e022                	sd	s0,0(sp)
    80001264:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001266:	00000097          	auipc	ra,0x0
    8000126a:	f22080e7          	jalr	-222(ra) # 80001188 <kvmmake>
    8000126e:	00009797          	auipc	a5,0x9
    80001272:	daa7b923          	sd	a0,-590(a5) # 8000a020 <kernel_pagetable>
}
    80001276:	60a2                	ld	ra,8(sp)
    80001278:	6402                	ld	s0,0(sp)
    8000127a:	0141                	addi	sp,sp,16
    8000127c:	8082                	ret

000000008000127e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000127e:	715d                	addi	sp,sp,-80
    80001280:	e486                	sd	ra,72(sp)
    80001282:	e0a2                	sd	s0,64(sp)
    80001284:	fc26                	sd	s1,56(sp)
    80001286:	f84a                	sd	s2,48(sp)
    80001288:	f44e                	sd	s3,40(sp)
    8000128a:	f052                	sd	s4,32(sp)
    8000128c:	ec56                	sd	s5,24(sp)
    8000128e:	e85a                	sd	s6,16(sp)
    80001290:	e45e                	sd	s7,8(sp)
    80001292:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001294:	03459793          	slli	a5,a1,0x34
    80001298:	e795                	bnez	a5,800012c4 <uvmunmap+0x46>
    8000129a:	8a2a                	mv	s4,a0
    8000129c:	892e                	mv	s2,a1
    8000129e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a0:	0632                	slli	a2,a2,0xc
    800012a2:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012a6:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a8:	6b05                	lui	s6,0x1
    800012aa:	0735e263          	bltu	a1,s3,8000130e <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012ae:	60a6                	ld	ra,72(sp)
    800012b0:	6406                	ld	s0,64(sp)
    800012b2:	74e2                	ld	s1,56(sp)
    800012b4:	7942                	ld	s2,48(sp)
    800012b6:	79a2                	ld	s3,40(sp)
    800012b8:	7a02                	ld	s4,32(sp)
    800012ba:	6ae2                	ld	s5,24(sp)
    800012bc:	6b42                	ld	s6,16(sp)
    800012be:	6ba2                	ld	s7,8(sp)
    800012c0:	6161                	addi	sp,sp,80
    800012c2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012c4:	00008517          	auipc	a0,0x8
    800012c8:	e3c50513          	addi	a0,a0,-452 # 80009100 <digits+0xc0>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	26c080e7          	jalr	620(ra) # 80000538 <panic>
      panic("uvmunmap: walk");
    800012d4:	00008517          	auipc	a0,0x8
    800012d8:	e4450513          	addi	a0,a0,-444 # 80009118 <digits+0xd8>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	25c080e7          	jalr	604(ra) # 80000538 <panic>
      panic("uvmunmap: not mapped");
    800012e4:	00008517          	auipc	a0,0x8
    800012e8:	e4450513          	addi	a0,a0,-444 # 80009128 <digits+0xe8>
    800012ec:	fffff097          	auipc	ra,0xfffff
    800012f0:	24c080e7          	jalr	588(ra) # 80000538 <panic>
      panic("uvmunmap: not a leaf");
    800012f4:	00008517          	auipc	a0,0x8
    800012f8:	e4c50513          	addi	a0,a0,-436 # 80009140 <digits+0x100>
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	23c080e7          	jalr	572(ra) # 80000538 <panic>
    *pte = 0;
    80001304:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001308:	995a                	add	s2,s2,s6
    8000130a:	fb3972e3          	bgeu	s2,s3,800012ae <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000130e:	4601                	li	a2,0
    80001310:	85ca                	mv	a1,s2
    80001312:	8552                	mv	a0,s4
    80001314:	00000097          	auipc	ra,0x0
    80001318:	cbc080e7          	jalr	-836(ra) # 80000fd0 <walk>
    8000131c:	84aa                	mv	s1,a0
    8000131e:	d95d                	beqz	a0,800012d4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001320:	6108                	ld	a0,0(a0)
    80001322:	00157793          	andi	a5,a0,1
    80001326:	dfdd                	beqz	a5,800012e4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001328:	3ff57793          	andi	a5,a0,1023
    8000132c:	fd7784e3          	beq	a5,s7,800012f4 <uvmunmap+0x76>
    if(do_free){
    80001330:	fc0a8ae3          	beqz	s5,80001304 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001334:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001336:	0532                	slli	a0,a0,0xc
    80001338:	fffff097          	auipc	ra,0xfffff
    8000133c:	6a8080e7          	jalr	1704(ra) # 800009e0 <kfree>
    80001340:	b7d1                	j	80001304 <uvmunmap+0x86>

0000000080001342 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001342:	1101                	addi	sp,sp,-32
    80001344:	ec06                	sd	ra,24(sp)
    80001346:	e822                	sd	s0,16(sp)
    80001348:	e426                	sd	s1,8(sp)
    8000134a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000134c:	fffff097          	auipc	ra,0xfffff
    80001350:	792080e7          	jalr	1938(ra) # 80000ade <kalloc>
    80001354:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001356:	c519                	beqz	a0,80001364 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001358:	6605                	lui	a2,0x1
    8000135a:	4581                	li	a1,0
    8000135c:	00000097          	auipc	ra,0x0
    80001360:	96e080e7          	jalr	-1682(ra) # 80000cca <memset>
  return pagetable;
}
    80001364:	8526                	mv	a0,s1
    80001366:	60e2                	ld	ra,24(sp)
    80001368:	6442                	ld	s0,16(sp)
    8000136a:	64a2                	ld	s1,8(sp)
    8000136c:	6105                	addi	sp,sp,32
    8000136e:	8082                	ret

0000000080001370 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001370:	7179                	addi	sp,sp,-48
    80001372:	f406                	sd	ra,40(sp)
    80001374:	f022                	sd	s0,32(sp)
    80001376:	ec26                	sd	s1,24(sp)
    80001378:	e84a                	sd	s2,16(sp)
    8000137a:	e44e                	sd	s3,8(sp)
    8000137c:	e052                	sd	s4,0(sp)
    8000137e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001380:	6785                	lui	a5,0x1
    80001382:	04f67863          	bgeu	a2,a5,800013d2 <uvminit+0x62>
    80001386:	8a2a                	mv	s4,a0
    80001388:	89ae                	mv	s3,a1
    8000138a:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000138c:	fffff097          	auipc	ra,0xfffff
    80001390:	752080e7          	jalr	1874(ra) # 80000ade <kalloc>
    80001394:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001396:	6605                	lui	a2,0x1
    80001398:	4581                	li	a1,0
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	930080e7          	jalr	-1744(ra) # 80000cca <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013a2:	4779                	li	a4,30
    800013a4:	86ca                	mv	a3,s2
    800013a6:	6605                	lui	a2,0x1
    800013a8:	4581                	li	a1,0
    800013aa:	8552                	mv	a0,s4
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	d0c080e7          	jalr	-756(ra) # 800010b8 <mappages>
  memmove(mem, src, sz);
    800013b4:	8626                	mv	a2,s1
    800013b6:	85ce                	mv	a1,s3
    800013b8:	854a                	mv	a0,s2
    800013ba:	00000097          	auipc	ra,0x0
    800013be:	96c080e7          	jalr	-1684(ra) # 80000d26 <memmove>
}
    800013c2:	70a2                	ld	ra,40(sp)
    800013c4:	7402                	ld	s0,32(sp)
    800013c6:	64e2                	ld	s1,24(sp)
    800013c8:	6942                	ld	s2,16(sp)
    800013ca:	69a2                	ld	s3,8(sp)
    800013cc:	6a02                	ld	s4,0(sp)
    800013ce:	6145                	addi	sp,sp,48
    800013d0:	8082                	ret
    panic("inituvm: more than a page");
    800013d2:	00008517          	auipc	a0,0x8
    800013d6:	d8650513          	addi	a0,a0,-634 # 80009158 <digits+0x118>
    800013da:	fffff097          	auipc	ra,0xfffff
    800013de:	15e080e7          	jalr	350(ra) # 80000538 <panic>

00000000800013e2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013e2:	1101                	addi	sp,sp,-32
    800013e4:	ec06                	sd	ra,24(sp)
    800013e6:	e822                	sd	s0,16(sp)
    800013e8:	e426                	sd	s1,8(sp)
    800013ea:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013ec:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ee:	00b67d63          	bgeu	a2,a1,80001408 <uvmdealloc+0x26>
    800013f2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013f4:	6785                	lui	a5,0x1
    800013f6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013f8:	00f60733          	add	a4,a2,a5
    800013fc:	76fd                	lui	a3,0xfffff
    800013fe:	8f75                	and	a4,a4,a3
    80001400:	97ae                	add	a5,a5,a1
    80001402:	8ff5                	and	a5,a5,a3
    80001404:	00f76863          	bltu	a4,a5,80001414 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001408:	8526                	mv	a0,s1
    8000140a:	60e2                	ld	ra,24(sp)
    8000140c:	6442                	ld	s0,16(sp)
    8000140e:	64a2                	ld	s1,8(sp)
    80001410:	6105                	addi	sp,sp,32
    80001412:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001414:	8f99                	sub	a5,a5,a4
    80001416:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001418:	4685                	li	a3,1
    8000141a:	0007861b          	sext.w	a2,a5
    8000141e:	85ba                	mv	a1,a4
    80001420:	00000097          	auipc	ra,0x0
    80001424:	e5e080e7          	jalr	-418(ra) # 8000127e <uvmunmap>
    80001428:	b7c5                	j	80001408 <uvmdealloc+0x26>

000000008000142a <uvmalloc>:
  if(newsz < oldsz)
    8000142a:	0ab66163          	bltu	a2,a1,800014cc <uvmalloc+0xa2>
{
    8000142e:	7139                	addi	sp,sp,-64
    80001430:	fc06                	sd	ra,56(sp)
    80001432:	f822                	sd	s0,48(sp)
    80001434:	f426                	sd	s1,40(sp)
    80001436:	f04a                	sd	s2,32(sp)
    80001438:	ec4e                	sd	s3,24(sp)
    8000143a:	e852                	sd	s4,16(sp)
    8000143c:	e456                	sd	s5,8(sp)
    8000143e:	0080                	addi	s0,sp,64
    80001440:	8aaa                	mv	s5,a0
    80001442:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001444:	6785                	lui	a5,0x1
    80001446:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001448:	95be                	add	a1,a1,a5
    8000144a:	77fd                	lui	a5,0xfffff
    8000144c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001450:	08c9f063          	bgeu	s3,a2,800014d0 <uvmalloc+0xa6>
    80001454:	894e                	mv	s2,s3
    mem = kalloc();
    80001456:	fffff097          	auipc	ra,0xfffff
    8000145a:	688080e7          	jalr	1672(ra) # 80000ade <kalloc>
    8000145e:	84aa                	mv	s1,a0
    if(mem == 0){
    80001460:	c51d                	beqz	a0,8000148e <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001462:	6605                	lui	a2,0x1
    80001464:	4581                	li	a1,0
    80001466:	00000097          	auipc	ra,0x0
    8000146a:	864080e7          	jalr	-1948(ra) # 80000cca <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000146e:	4779                	li	a4,30
    80001470:	86a6                	mv	a3,s1
    80001472:	6605                	lui	a2,0x1
    80001474:	85ca                	mv	a1,s2
    80001476:	8556                	mv	a0,s5
    80001478:	00000097          	auipc	ra,0x0
    8000147c:	c40080e7          	jalr	-960(ra) # 800010b8 <mappages>
    80001480:	e905                	bnez	a0,800014b0 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001482:	6785                	lui	a5,0x1
    80001484:	993e                	add	s2,s2,a5
    80001486:	fd4968e3          	bltu	s2,s4,80001456 <uvmalloc+0x2c>
  return newsz;
    8000148a:	8552                	mv	a0,s4
    8000148c:	a809                	j	8000149e <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000148e:	864e                	mv	a2,s3
    80001490:	85ca                	mv	a1,s2
    80001492:	8556                	mv	a0,s5
    80001494:	00000097          	auipc	ra,0x0
    80001498:	f4e080e7          	jalr	-178(ra) # 800013e2 <uvmdealloc>
      return 0;
    8000149c:	4501                	li	a0,0
}
    8000149e:	70e2                	ld	ra,56(sp)
    800014a0:	7442                	ld	s0,48(sp)
    800014a2:	74a2                	ld	s1,40(sp)
    800014a4:	7902                	ld	s2,32(sp)
    800014a6:	69e2                	ld	s3,24(sp)
    800014a8:	6a42                	ld	s4,16(sp)
    800014aa:	6aa2                	ld	s5,8(sp)
    800014ac:	6121                	addi	sp,sp,64
    800014ae:	8082                	ret
      kfree(mem);
    800014b0:	8526                	mv	a0,s1
    800014b2:	fffff097          	auipc	ra,0xfffff
    800014b6:	52e080e7          	jalr	1326(ra) # 800009e0 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014ba:	864e                	mv	a2,s3
    800014bc:	85ca                	mv	a1,s2
    800014be:	8556                	mv	a0,s5
    800014c0:	00000097          	auipc	ra,0x0
    800014c4:	f22080e7          	jalr	-222(ra) # 800013e2 <uvmdealloc>
      return 0;
    800014c8:	4501                	li	a0,0
    800014ca:	bfd1                	j	8000149e <uvmalloc+0x74>
    return oldsz;
    800014cc:	852e                	mv	a0,a1
}
    800014ce:	8082                	ret
  return newsz;
    800014d0:	8532                	mv	a0,a2
    800014d2:	b7f1                	j	8000149e <uvmalloc+0x74>

00000000800014d4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014d4:	7179                	addi	sp,sp,-48
    800014d6:	f406                	sd	ra,40(sp)
    800014d8:	f022                	sd	s0,32(sp)
    800014da:	ec26                	sd	s1,24(sp)
    800014dc:	e84a                	sd	s2,16(sp)
    800014de:	e44e                	sd	s3,8(sp)
    800014e0:	e052                	sd	s4,0(sp)
    800014e2:	1800                	addi	s0,sp,48
    800014e4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014e6:	84aa                	mv	s1,a0
    800014e8:	6905                	lui	s2,0x1
    800014ea:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ec:	4985                	li	s3,1
    800014ee:	a829                	j	80001508 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014f0:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014f2:	00c79513          	slli	a0,a5,0xc
    800014f6:	00000097          	auipc	ra,0x0
    800014fa:	fde080e7          	jalr	-34(ra) # 800014d4 <freewalk>
      pagetable[i] = 0;
    800014fe:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001502:	04a1                	addi	s1,s1,8
    80001504:	03248163          	beq	s1,s2,80001526 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001508:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000150a:	00f7f713          	andi	a4,a5,15
    8000150e:	ff3701e3          	beq	a4,s3,800014f0 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001512:	8b85                	andi	a5,a5,1
    80001514:	d7fd                	beqz	a5,80001502 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001516:	00008517          	auipc	a0,0x8
    8000151a:	c6250513          	addi	a0,a0,-926 # 80009178 <digits+0x138>
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	01a080e7          	jalr	26(ra) # 80000538 <panic>
    }
  }
  kfree((void*)pagetable);
    80001526:	8552                	mv	a0,s4
    80001528:	fffff097          	auipc	ra,0xfffff
    8000152c:	4b8080e7          	jalr	1208(ra) # 800009e0 <kfree>
}
    80001530:	70a2                	ld	ra,40(sp)
    80001532:	7402                	ld	s0,32(sp)
    80001534:	64e2                	ld	s1,24(sp)
    80001536:	6942                	ld	s2,16(sp)
    80001538:	69a2                	ld	s3,8(sp)
    8000153a:	6a02                	ld	s4,0(sp)
    8000153c:	6145                	addi	sp,sp,48
    8000153e:	8082                	ret

0000000080001540 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001540:	1101                	addi	sp,sp,-32
    80001542:	ec06                	sd	ra,24(sp)
    80001544:	e822                	sd	s0,16(sp)
    80001546:	e426                	sd	s1,8(sp)
    80001548:	1000                	addi	s0,sp,32
    8000154a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000154c:	e999                	bnez	a1,80001562 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000154e:	8526                	mv	a0,s1
    80001550:	00000097          	auipc	ra,0x0
    80001554:	f84080e7          	jalr	-124(ra) # 800014d4 <freewalk>
}
    80001558:	60e2                	ld	ra,24(sp)
    8000155a:	6442                	ld	s0,16(sp)
    8000155c:	64a2                	ld	s1,8(sp)
    8000155e:	6105                	addi	sp,sp,32
    80001560:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001562:	6785                	lui	a5,0x1
    80001564:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001566:	95be                	add	a1,a1,a5
    80001568:	4685                	li	a3,1
    8000156a:	00c5d613          	srli	a2,a1,0xc
    8000156e:	4581                	li	a1,0
    80001570:	00000097          	auipc	ra,0x0
    80001574:	d0e080e7          	jalr	-754(ra) # 8000127e <uvmunmap>
    80001578:	bfd9                	j	8000154e <uvmfree+0xe>

000000008000157a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000157a:	c679                	beqz	a2,80001648 <uvmcopy+0xce>
{
    8000157c:	715d                	addi	sp,sp,-80
    8000157e:	e486                	sd	ra,72(sp)
    80001580:	e0a2                	sd	s0,64(sp)
    80001582:	fc26                	sd	s1,56(sp)
    80001584:	f84a                	sd	s2,48(sp)
    80001586:	f44e                	sd	s3,40(sp)
    80001588:	f052                	sd	s4,32(sp)
    8000158a:	ec56                	sd	s5,24(sp)
    8000158c:	e85a                	sd	s6,16(sp)
    8000158e:	e45e                	sd	s7,8(sp)
    80001590:	0880                	addi	s0,sp,80
    80001592:	8b2a                	mv	s6,a0
    80001594:	8aae                	mv	s5,a1
    80001596:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001598:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000159a:	4601                	li	a2,0
    8000159c:	85ce                	mv	a1,s3
    8000159e:	855a                	mv	a0,s6
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	a30080e7          	jalr	-1488(ra) # 80000fd0 <walk>
    800015a8:	c531                	beqz	a0,800015f4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015aa:	6118                	ld	a4,0(a0)
    800015ac:	00177793          	andi	a5,a4,1
    800015b0:	cbb1                	beqz	a5,80001604 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015b2:	00a75593          	srli	a1,a4,0xa
    800015b6:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ba:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015be:	fffff097          	auipc	ra,0xfffff
    800015c2:	520080e7          	jalr	1312(ra) # 80000ade <kalloc>
    800015c6:	892a                	mv	s2,a0
    800015c8:	c939                	beqz	a0,8000161e <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015ca:	6605                	lui	a2,0x1
    800015cc:	85de                	mv	a1,s7
    800015ce:	fffff097          	auipc	ra,0xfffff
    800015d2:	758080e7          	jalr	1880(ra) # 80000d26 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015d6:	8726                	mv	a4,s1
    800015d8:	86ca                	mv	a3,s2
    800015da:	6605                	lui	a2,0x1
    800015dc:	85ce                	mv	a1,s3
    800015de:	8556                	mv	a0,s5
    800015e0:	00000097          	auipc	ra,0x0
    800015e4:	ad8080e7          	jalr	-1320(ra) # 800010b8 <mappages>
    800015e8:	e515                	bnez	a0,80001614 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015ea:	6785                	lui	a5,0x1
    800015ec:	99be                	add	s3,s3,a5
    800015ee:	fb49e6e3          	bltu	s3,s4,8000159a <uvmcopy+0x20>
    800015f2:	a081                	j	80001632 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015f4:	00008517          	auipc	a0,0x8
    800015f8:	b9450513          	addi	a0,a0,-1132 # 80009188 <digits+0x148>
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	f3c080e7          	jalr	-196(ra) # 80000538 <panic>
      panic("uvmcopy: page not present");
    80001604:	00008517          	auipc	a0,0x8
    80001608:	ba450513          	addi	a0,a0,-1116 # 800091a8 <digits+0x168>
    8000160c:	fffff097          	auipc	ra,0xfffff
    80001610:	f2c080e7          	jalr	-212(ra) # 80000538 <panic>
      kfree(mem);
    80001614:	854a                	mv	a0,s2
    80001616:	fffff097          	auipc	ra,0xfffff
    8000161a:	3ca080e7          	jalr	970(ra) # 800009e0 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000161e:	4685                	li	a3,1
    80001620:	00c9d613          	srli	a2,s3,0xc
    80001624:	4581                	li	a1,0
    80001626:	8556                	mv	a0,s5
    80001628:	00000097          	auipc	ra,0x0
    8000162c:	c56080e7          	jalr	-938(ra) # 8000127e <uvmunmap>
  return -1;
    80001630:	557d                	li	a0,-1
}
    80001632:	60a6                	ld	ra,72(sp)
    80001634:	6406                	ld	s0,64(sp)
    80001636:	74e2                	ld	s1,56(sp)
    80001638:	7942                	ld	s2,48(sp)
    8000163a:	79a2                	ld	s3,40(sp)
    8000163c:	7a02                	ld	s4,32(sp)
    8000163e:	6ae2                	ld	s5,24(sp)
    80001640:	6b42                	ld	s6,16(sp)
    80001642:	6ba2                	ld	s7,8(sp)
    80001644:	6161                	addi	sp,sp,80
    80001646:	8082                	ret
  return 0;
    80001648:	4501                	li	a0,0
}
    8000164a:	8082                	ret

000000008000164c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000164c:	1141                	addi	sp,sp,-16
    8000164e:	e406                	sd	ra,8(sp)
    80001650:	e022                	sd	s0,0(sp)
    80001652:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001654:	4601                	li	a2,0
    80001656:	00000097          	auipc	ra,0x0
    8000165a:	97a080e7          	jalr	-1670(ra) # 80000fd0 <walk>
  if(pte == 0)
    8000165e:	c901                	beqz	a0,8000166e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001660:	611c                	ld	a5,0(a0)
    80001662:	9bbd                	andi	a5,a5,-17
    80001664:	e11c                	sd	a5,0(a0)
}
    80001666:	60a2                	ld	ra,8(sp)
    80001668:	6402                	ld	s0,0(sp)
    8000166a:	0141                	addi	sp,sp,16
    8000166c:	8082                	ret
    panic("uvmclear");
    8000166e:	00008517          	auipc	a0,0x8
    80001672:	b5a50513          	addi	a0,a0,-1190 # 800091c8 <digits+0x188>
    80001676:	fffff097          	auipc	ra,0xfffff
    8000167a:	ec2080e7          	jalr	-318(ra) # 80000538 <panic>

000000008000167e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000167e:	c6bd                	beqz	a3,800016ec <copyout+0x6e>
{
    80001680:	715d                	addi	sp,sp,-80
    80001682:	e486                	sd	ra,72(sp)
    80001684:	e0a2                	sd	s0,64(sp)
    80001686:	fc26                	sd	s1,56(sp)
    80001688:	f84a                	sd	s2,48(sp)
    8000168a:	f44e                	sd	s3,40(sp)
    8000168c:	f052                	sd	s4,32(sp)
    8000168e:	ec56                	sd	s5,24(sp)
    80001690:	e85a                	sd	s6,16(sp)
    80001692:	e45e                	sd	s7,8(sp)
    80001694:	e062                	sd	s8,0(sp)
    80001696:	0880                	addi	s0,sp,80
    80001698:	8b2a                	mv	s6,a0
    8000169a:	8c2e                	mv	s8,a1
    8000169c:	8a32                	mv	s4,a2
    8000169e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016a0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016a2:	6a85                	lui	s5,0x1
    800016a4:	a015                	j	800016c8 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016a6:	9562                	add	a0,a0,s8
    800016a8:	0004861b          	sext.w	a2,s1
    800016ac:	85d2                	mv	a1,s4
    800016ae:	41250533          	sub	a0,a0,s2
    800016b2:	fffff097          	auipc	ra,0xfffff
    800016b6:	674080e7          	jalr	1652(ra) # 80000d26 <memmove>

    len -= n;
    800016ba:	409989b3          	sub	s3,s3,s1
    src += n;
    800016be:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016c0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016c4:	02098263          	beqz	s3,800016e8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016c8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016cc:	85ca                	mv	a1,s2
    800016ce:	855a                	mv	a0,s6
    800016d0:	00000097          	auipc	ra,0x0
    800016d4:	9a6080e7          	jalr	-1626(ra) # 80001076 <walkaddr>
    if(pa0 == 0)
    800016d8:	cd01                	beqz	a0,800016f0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016da:	418904b3          	sub	s1,s2,s8
    800016de:	94d6                	add	s1,s1,s5
    800016e0:	fc99f3e3          	bgeu	s3,s1,800016a6 <copyout+0x28>
    800016e4:	84ce                	mv	s1,s3
    800016e6:	b7c1                	j	800016a6 <copyout+0x28>
  }
  return 0;
    800016e8:	4501                	li	a0,0
    800016ea:	a021                	j	800016f2 <copyout+0x74>
    800016ec:	4501                	li	a0,0
}
    800016ee:	8082                	ret
      return -1;
    800016f0:	557d                	li	a0,-1
}
    800016f2:	60a6                	ld	ra,72(sp)
    800016f4:	6406                	ld	s0,64(sp)
    800016f6:	74e2                	ld	s1,56(sp)
    800016f8:	7942                	ld	s2,48(sp)
    800016fa:	79a2                	ld	s3,40(sp)
    800016fc:	7a02                	ld	s4,32(sp)
    800016fe:	6ae2                	ld	s5,24(sp)
    80001700:	6b42                	ld	s6,16(sp)
    80001702:	6ba2                	ld	s7,8(sp)
    80001704:	6c02                	ld	s8,0(sp)
    80001706:	6161                	addi	sp,sp,80
    80001708:	8082                	ret

000000008000170a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000170a:	caa5                	beqz	a3,8000177a <copyin+0x70>
{
    8000170c:	715d                	addi	sp,sp,-80
    8000170e:	e486                	sd	ra,72(sp)
    80001710:	e0a2                	sd	s0,64(sp)
    80001712:	fc26                	sd	s1,56(sp)
    80001714:	f84a                	sd	s2,48(sp)
    80001716:	f44e                	sd	s3,40(sp)
    80001718:	f052                	sd	s4,32(sp)
    8000171a:	ec56                	sd	s5,24(sp)
    8000171c:	e85a                	sd	s6,16(sp)
    8000171e:	e45e                	sd	s7,8(sp)
    80001720:	e062                	sd	s8,0(sp)
    80001722:	0880                	addi	s0,sp,80
    80001724:	8b2a                	mv	s6,a0
    80001726:	8a2e                	mv	s4,a1
    80001728:	8c32                	mv	s8,a2
    8000172a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000172c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000172e:	6a85                	lui	s5,0x1
    80001730:	a01d                	j	80001756 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001732:	018505b3          	add	a1,a0,s8
    80001736:	0004861b          	sext.w	a2,s1
    8000173a:	412585b3          	sub	a1,a1,s2
    8000173e:	8552                	mv	a0,s4
    80001740:	fffff097          	auipc	ra,0xfffff
    80001744:	5e6080e7          	jalr	1510(ra) # 80000d26 <memmove>

    len -= n;
    80001748:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000174c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000174e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001752:	02098263          	beqz	s3,80001776 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001756:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175a:	85ca                	mv	a1,s2
    8000175c:	855a                	mv	a0,s6
    8000175e:	00000097          	auipc	ra,0x0
    80001762:	918080e7          	jalr	-1768(ra) # 80001076 <walkaddr>
    if(pa0 == 0)
    80001766:	cd01                	beqz	a0,8000177e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001768:	418904b3          	sub	s1,s2,s8
    8000176c:	94d6                	add	s1,s1,s5
    8000176e:	fc99f2e3          	bgeu	s3,s1,80001732 <copyin+0x28>
    80001772:	84ce                	mv	s1,s3
    80001774:	bf7d                	j	80001732 <copyin+0x28>
  }
  return 0;
    80001776:	4501                	li	a0,0
    80001778:	a021                	j	80001780 <copyin+0x76>
    8000177a:	4501                	li	a0,0
}
    8000177c:	8082                	ret
      return -1;
    8000177e:	557d                	li	a0,-1
}
    80001780:	60a6                	ld	ra,72(sp)
    80001782:	6406                	ld	s0,64(sp)
    80001784:	74e2                	ld	s1,56(sp)
    80001786:	7942                	ld	s2,48(sp)
    80001788:	79a2                	ld	s3,40(sp)
    8000178a:	7a02                	ld	s4,32(sp)
    8000178c:	6ae2                	ld	s5,24(sp)
    8000178e:	6b42                	ld	s6,16(sp)
    80001790:	6ba2                	ld	s7,8(sp)
    80001792:	6c02                	ld	s8,0(sp)
    80001794:	6161                	addi	sp,sp,80
    80001796:	8082                	ret

0000000080001798 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001798:	c2dd                	beqz	a3,8000183e <copyinstr+0xa6>
{
    8000179a:	715d                	addi	sp,sp,-80
    8000179c:	e486                	sd	ra,72(sp)
    8000179e:	e0a2                	sd	s0,64(sp)
    800017a0:	fc26                	sd	s1,56(sp)
    800017a2:	f84a                	sd	s2,48(sp)
    800017a4:	f44e                	sd	s3,40(sp)
    800017a6:	f052                	sd	s4,32(sp)
    800017a8:	ec56                	sd	s5,24(sp)
    800017aa:	e85a                	sd	s6,16(sp)
    800017ac:	e45e                	sd	s7,8(sp)
    800017ae:	0880                	addi	s0,sp,80
    800017b0:	8a2a                	mv	s4,a0
    800017b2:	8b2e                	mv	s6,a1
    800017b4:	8bb2                	mv	s7,a2
    800017b6:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017b8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ba:	6985                	lui	s3,0x1
    800017bc:	a02d                	j	800017e6 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017be:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017c2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017c4:	37fd                	addiw	a5,a5,-1
    800017c6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017ca:	60a6                	ld	ra,72(sp)
    800017cc:	6406                	ld	s0,64(sp)
    800017ce:	74e2                	ld	s1,56(sp)
    800017d0:	7942                	ld	s2,48(sp)
    800017d2:	79a2                	ld	s3,40(sp)
    800017d4:	7a02                	ld	s4,32(sp)
    800017d6:	6ae2                	ld	s5,24(sp)
    800017d8:	6b42                	ld	s6,16(sp)
    800017da:	6ba2                	ld	s7,8(sp)
    800017dc:	6161                	addi	sp,sp,80
    800017de:	8082                	ret
    srcva = va0 + PGSIZE;
    800017e0:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017e4:	c8a9                	beqz	s1,80001836 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017e6:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ea:	85ca                	mv	a1,s2
    800017ec:	8552                	mv	a0,s4
    800017ee:	00000097          	auipc	ra,0x0
    800017f2:	888080e7          	jalr	-1912(ra) # 80001076 <walkaddr>
    if(pa0 == 0)
    800017f6:	c131                	beqz	a0,8000183a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017f8:	417906b3          	sub	a3,s2,s7
    800017fc:	96ce                	add	a3,a3,s3
    800017fe:	00d4f363          	bgeu	s1,a3,80001804 <copyinstr+0x6c>
    80001802:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001804:	955e                	add	a0,a0,s7
    80001806:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000180a:	daf9                	beqz	a3,800017e0 <copyinstr+0x48>
    8000180c:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000180e:	41650633          	sub	a2,a0,s6
    80001812:	fff48593          	addi	a1,s1,-1
    80001816:	95da                	add	a1,a1,s6
    while(n > 0){
    80001818:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    8000181a:	00f60733          	add	a4,a2,a5
    8000181e:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd7000>
    80001822:	df51                	beqz	a4,800017be <copyinstr+0x26>
        *dst = *p;
    80001824:	00e78023          	sb	a4,0(a5)
      --max;
    80001828:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000182c:	0785                	addi	a5,a5,1
    while(n > 0){
    8000182e:	fed796e3          	bne	a5,a3,8000181a <copyinstr+0x82>
      dst++;
    80001832:	8b3e                	mv	s6,a5
    80001834:	b775                	j	800017e0 <copyinstr+0x48>
    80001836:	4781                	li	a5,0
    80001838:	b771                	j	800017c4 <copyinstr+0x2c>
      return -1;
    8000183a:	557d                	li	a0,-1
    8000183c:	b779                	j	800017ca <copyinstr+0x32>
  int got_null = 0;
    8000183e:	4781                	li	a5,0
  if(got_null){
    80001840:	37fd                	addiw	a5,a5,-1
    80001842:	0007851b          	sext.w	a0,a5
}
    80001846:	8082                	ret

0000000080001848 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001848:	7139                	addi	sp,sp,-64
    8000184a:	fc06                	sd	ra,56(sp)
    8000184c:	f822                	sd	s0,48(sp)
    8000184e:	f426                	sd	s1,40(sp)
    80001850:	f04a                	sd	s2,32(sp)
    80001852:	ec4e                	sd	s3,24(sp)
    80001854:	e852                	sd	s4,16(sp)
    80001856:	e456                	sd	s5,8(sp)
    80001858:	e05a                	sd	s6,0(sp)
    8000185a:	0080                	addi	s0,sp,64
    8000185c:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185e:	00011497          	auipc	s1,0x11
    80001862:	eb248493          	addi	s1,s1,-334 # 80012710 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001866:	8b26                	mv	s6,s1
    80001868:	00007a97          	auipc	s5,0x7
    8000186c:	798a8a93          	addi	s5,s5,1944 # 80009000 <etext>
    80001870:	04000937          	lui	s2,0x4000
    80001874:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001876:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001878:	00017a17          	auipc	s4,0x17
    8000187c:	298a0a13          	addi	s4,s4,664 # 80018b10 <tickslock>
    char *pa = kalloc();
    80001880:	fffff097          	auipc	ra,0xfffff
    80001884:	25e080e7          	jalr	606(ra) # 80000ade <kalloc>
    80001888:	862a                	mv	a2,a0
    if(pa == 0)
    8000188a:	c131                	beqz	a0,800018ce <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000188c:	416485b3          	sub	a1,s1,s6
    80001890:	8591                	srai	a1,a1,0x4
    80001892:	000ab783          	ld	a5,0(s5)
    80001896:	02f585b3          	mul	a1,a1,a5
    8000189a:	2585                	addiw	a1,a1,1
    8000189c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018a0:	4719                	li	a4,6
    800018a2:	6685                	lui	a3,0x1
    800018a4:	40b905b3          	sub	a1,s2,a1
    800018a8:	854e                	mv	a0,s3
    800018aa:	00000097          	auipc	ra,0x0
    800018ae:	8ae080e7          	jalr	-1874(ra) # 80001158 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b2:	19048493          	addi	s1,s1,400
    800018b6:	fd4495e3          	bne	s1,s4,80001880 <proc_mapstacks+0x38>
  }
}
    800018ba:	70e2                	ld	ra,56(sp)
    800018bc:	7442                	ld	s0,48(sp)
    800018be:	74a2                	ld	s1,40(sp)
    800018c0:	7902                	ld	s2,32(sp)
    800018c2:	69e2                	ld	s3,24(sp)
    800018c4:	6a42                	ld	s4,16(sp)
    800018c6:	6aa2                	ld	s5,8(sp)
    800018c8:	6b02                	ld	s6,0(sp)
    800018ca:	6121                	addi	sp,sp,64
    800018cc:	8082                	ret
      panic("kalloc");
    800018ce:	00008517          	auipc	a0,0x8
    800018d2:	90a50513          	addi	a0,a0,-1782 # 800091d8 <digits+0x198>
    800018d6:	fffff097          	auipc	ra,0xfffff
    800018da:	c62080e7          	jalr	-926(ra) # 80000538 <panic>

00000000800018de <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018de:	7139                	addi	sp,sp,-64
    800018e0:	fc06                	sd	ra,56(sp)
    800018e2:	f822                	sd	s0,48(sp)
    800018e4:	f426                	sd	s1,40(sp)
    800018e6:	f04a                	sd	s2,32(sp)
    800018e8:	ec4e                	sd	s3,24(sp)
    800018ea:	e852                	sd	s4,16(sp)
    800018ec:	e456                	sd	s5,8(sp)
    800018ee:	e05a                	sd	s6,0(sp)
    800018f0:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018f2:	00008597          	auipc	a1,0x8
    800018f6:	8ee58593          	addi	a1,a1,-1810 # 800091e0 <digits+0x1a0>
    800018fa:	00011517          	auipc	a0,0x11
    800018fe:	9e650513          	addi	a0,a0,-1562 # 800122e0 <pid_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	23c080e7          	jalr	572(ra) # 80000b3e <initlock>
  initlock(&wait_lock, "wait_lock");
    8000190a:	00008597          	auipc	a1,0x8
    8000190e:	8de58593          	addi	a1,a1,-1826 # 800091e8 <digits+0x1a8>
    80001912:	00011517          	auipc	a0,0x11
    80001916:	9e650513          	addi	a0,a0,-1562 # 800122f8 <wait_lock>
    8000191a:	fffff097          	auipc	ra,0xfffff
    8000191e:	224080e7          	jalr	548(ra) # 80000b3e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001922:	00011497          	auipc	s1,0x11
    80001926:	dee48493          	addi	s1,s1,-530 # 80012710 <proc>
      initlock(&p->lock, "proc");
    8000192a:	00008b17          	auipc	s6,0x8
    8000192e:	8ceb0b13          	addi	s6,s6,-1842 # 800091f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    80001932:	8aa6                	mv	s5,s1
    80001934:	00007a17          	auipc	s4,0x7
    80001938:	6cca0a13          	addi	s4,s4,1740 # 80009000 <etext>
    8000193c:	04000937          	lui	s2,0x4000
    80001940:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001942:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001944:	00017997          	auipc	s3,0x17
    80001948:	1cc98993          	addi	s3,s3,460 # 80018b10 <tickslock>
      initlock(&p->lock, "proc");
    8000194c:	85da                	mv	a1,s6
    8000194e:	8526                	mv	a0,s1
    80001950:	fffff097          	auipc	ra,0xfffff
    80001954:	1ee080e7          	jalr	494(ra) # 80000b3e <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001958:	415487b3          	sub	a5,s1,s5
    8000195c:	8791                	srai	a5,a5,0x4
    8000195e:	000a3703          	ld	a4,0(s4)
    80001962:	02e787b3          	mul	a5,a5,a4
    80001966:	2785                	addiw	a5,a5,1
    80001968:	00d7979b          	slliw	a5,a5,0xd
    8000196c:	40f907b3          	sub	a5,s2,a5
    80001970:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001972:	19048493          	addi	s1,s1,400
    80001976:	fd349be3          	bne	s1,s3,8000194c <procinit+0x6e>
  }
}
    8000197a:	70e2                	ld	ra,56(sp)
    8000197c:	7442                	ld	s0,48(sp)
    8000197e:	74a2                	ld	s1,40(sp)
    80001980:	7902                	ld	s2,32(sp)
    80001982:	69e2                	ld	s3,24(sp)
    80001984:	6a42                	ld	s4,16(sp)
    80001986:	6aa2                	ld	s5,8(sp)
    80001988:	6b02                	ld	s6,0(sp)
    8000198a:	6121                	addi	sp,sp,64
    8000198c:	8082                	ret

000000008000198e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000198e:	1141                	addi	sp,sp,-16
    80001990:	e422                	sd	s0,8(sp)
    80001992:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001994:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001996:	2501                	sext.w	a0,a0
    80001998:	6422                	ld	s0,8(sp)
    8000199a:	0141                	addi	sp,sp,16
    8000199c:	8082                	ret

000000008000199e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    8000199e:	1141                	addi	sp,sp,-16
    800019a0:	e422                	sd	s0,8(sp)
    800019a2:	0800                	addi	s0,sp,16
    800019a4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019a6:	2781                	sext.w	a5,a5
    800019a8:	079e                	slli	a5,a5,0x7
  return c;
}
    800019aa:	00011517          	auipc	a0,0x11
    800019ae:	96650513          	addi	a0,a0,-1690 # 80012310 <cpus>
    800019b2:	953e                	add	a0,a0,a5
    800019b4:	6422                	ld	s0,8(sp)
    800019b6:	0141                	addi	sp,sp,16
    800019b8:	8082                	ret

00000000800019ba <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019ba:	1101                	addi	sp,sp,-32
    800019bc:	ec06                	sd	ra,24(sp)
    800019be:	e822                	sd	s0,16(sp)
    800019c0:	e426                	sd	s1,8(sp)
    800019c2:	1000                	addi	s0,sp,32
  push_off();
    800019c4:	fffff097          	auipc	ra,0xfffff
    800019c8:	1be080e7          	jalr	446(ra) # 80000b82 <push_off>
    800019cc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ce:	2781                	sext.w	a5,a5
    800019d0:	079e                	slli	a5,a5,0x7
    800019d2:	00011717          	auipc	a4,0x11
    800019d6:	90e70713          	addi	a4,a4,-1778 # 800122e0 <pid_lock>
    800019da:	97ba                	add	a5,a5,a4
    800019dc:	7b84                	ld	s1,48(a5)
  pop_off();
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	244080e7          	jalr	580(ra) # 80000c22 <pop_off>
  return p;
}
    800019e6:	8526                	mv	a0,s1
    800019e8:	60e2                	ld	ra,24(sp)
    800019ea:	6442                	ld	s0,16(sp)
    800019ec:	64a2                	ld	s1,8(sp)
    800019ee:	6105                	addi	sp,sp,32
    800019f0:	8082                	ret

00000000800019f2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019f2:	1101                	addi	sp,sp,-32
    800019f4:	ec06                	sd	ra,24(sp)
    800019f6:	e822                	sd	s0,16(sp)
    800019f8:	e426                	sd	s1,8(sp)
    800019fa:	1000                	addi	s0,sp,32
  static int first = 1;
  uint xticks;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019fc:	00000097          	auipc	ra,0x0
    80001a00:	fbe080e7          	jalr	-66(ra) # 800019ba <myproc>
    80001a04:	fffff097          	auipc	ra,0xfffff
    80001a08:	27e080e7          	jalr	638(ra) # 80000c82 <release>

  acquire(&tickslock);
    80001a0c:	00017517          	auipc	a0,0x17
    80001a10:	10450513          	addi	a0,a0,260 # 80018b10 <tickslock>
    80001a14:	fffff097          	auipc	ra,0xfffff
    80001a18:	1ba080e7          	jalr	442(ra) # 80000bce <acquire>
  xticks = ticks;
    80001a1c:	00008497          	auipc	s1,0x8
    80001a20:	6504a483          	lw	s1,1616(s1) # 8000a06c <ticks>
  release(&tickslock);
    80001a24:	00017517          	auipc	a0,0x17
    80001a28:	0ec50513          	addi	a0,a0,236 # 80018b10 <tickslock>
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	256080e7          	jalr	598(ra) # 80000c82 <release>

  myproc()->stime = xticks;
    80001a34:	00000097          	auipc	ra,0x0
    80001a38:	f86080e7          	jalr	-122(ra) # 800019ba <myproc>
    80001a3c:	16952a23          	sw	s1,372(a0)

  if (first) {
    80001a40:	00008797          	auipc	a5,0x8
    80001a44:	1307a783          	lw	a5,304(a5) # 80009b70 <first.3>
    80001a48:	eb91                	bnez	a5,80001a5c <forkret+0x6a>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a4a:	00002097          	auipc	ra,0x2
    80001a4e:	d2c080e7          	jalr	-724(ra) # 80003776 <usertrapret>
}
    80001a52:	60e2                	ld	ra,24(sp)
    80001a54:	6442                	ld	s0,16(sp)
    80001a56:	64a2                	ld	s1,8(sp)
    80001a58:	6105                	addi	sp,sp,32
    80001a5a:	8082                	ret
    first = 0;
    80001a5c:	00008797          	auipc	a5,0x8
    80001a60:	1007aa23          	sw	zero,276(a5) # 80009b70 <first.3>
    fsinit(ROOTDEV);
    80001a64:	4505                	li	a0,1
    80001a66:	00003097          	auipc	ra,0x3
    80001a6a:	2ae080e7          	jalr	686(ra) # 80004d14 <fsinit>
    80001a6e:	bff1                	j	80001a4a <forkret+0x58>

0000000080001a70 <allocpid>:
allocpid() {
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a7c:	00011917          	auipc	s2,0x11
    80001a80:	86490913          	addi	s2,s2,-1948 # 800122e0 <pid_lock>
    80001a84:	854a                	mv	a0,s2
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	148080e7          	jalr	328(ra) # 80000bce <acquire>
  pid = nextpid;
    80001a8e:	00008797          	auipc	a5,0x8
    80001a92:	0f678793          	addi	a5,a5,246 # 80009b84 <nextpid>
    80001a96:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a98:	0014871b          	addiw	a4,s1,1
    80001a9c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a9e:	854a                	mv	a0,s2
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	1e2080e7          	jalr	482(ra) # 80000c82 <release>
}
    80001aa8:	8526                	mv	a0,s1
    80001aaa:	60e2                	ld	ra,24(sp)
    80001aac:	6442                	ld	s0,16(sp)
    80001aae:	64a2                	ld	s1,8(sp)
    80001ab0:	6902                	ld	s2,0(sp)
    80001ab2:	6105                	addi	sp,sp,32
    80001ab4:	8082                	ret

0000000080001ab6 <proc_pagetable>:
{
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	e426                	sd	s1,8(sp)
    80001abe:	e04a                	sd	s2,0(sp)
    80001ac0:	1000                	addi	s0,sp,32
    80001ac2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ac4:	00000097          	auipc	ra,0x0
    80001ac8:	87e080e7          	jalr	-1922(ra) # 80001342 <uvmcreate>
    80001acc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ace:	c121                	beqz	a0,80001b0e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ad0:	4729                	li	a4,10
    80001ad2:	00006697          	auipc	a3,0x6
    80001ad6:	52e68693          	addi	a3,a3,1326 # 80008000 <_trampoline>
    80001ada:	6605                	lui	a2,0x1
    80001adc:	040005b7          	lui	a1,0x4000
    80001ae0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ae2:	05b2                	slli	a1,a1,0xc
    80001ae4:	fffff097          	auipc	ra,0xfffff
    80001ae8:	5d4080e7          	jalr	1492(ra) # 800010b8 <mappages>
    80001aec:	02054863          	bltz	a0,80001b1c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001af0:	4719                	li	a4,6
    80001af2:	06093683          	ld	a3,96(s2)
    80001af6:	6605                	lui	a2,0x1
    80001af8:	020005b7          	lui	a1,0x2000
    80001afc:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001afe:	05b6                	slli	a1,a1,0xd
    80001b00:	8526                	mv	a0,s1
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	5b6080e7          	jalr	1462(ra) # 800010b8 <mappages>
    80001b0a:	02054163          	bltz	a0,80001b2c <proc_pagetable+0x76>
}
    80001b0e:	8526                	mv	a0,s1
    80001b10:	60e2                	ld	ra,24(sp)
    80001b12:	6442                	ld	s0,16(sp)
    80001b14:	64a2                	ld	s1,8(sp)
    80001b16:	6902                	ld	s2,0(sp)
    80001b18:	6105                	addi	sp,sp,32
    80001b1a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b1c:	4581                	li	a1,0
    80001b1e:	8526                	mv	a0,s1
    80001b20:	00000097          	auipc	ra,0x0
    80001b24:	a20080e7          	jalr	-1504(ra) # 80001540 <uvmfree>
    return 0;
    80001b28:	4481                	li	s1,0
    80001b2a:	b7d5                	j	80001b0e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b2c:	4681                	li	a3,0
    80001b2e:	4605                	li	a2,1
    80001b30:	040005b7          	lui	a1,0x4000
    80001b34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b36:	05b2                	slli	a1,a1,0xc
    80001b38:	8526                	mv	a0,s1
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	744080e7          	jalr	1860(ra) # 8000127e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b42:	4581                	li	a1,0
    80001b44:	8526                	mv	a0,s1
    80001b46:	00000097          	auipc	ra,0x0
    80001b4a:	9fa080e7          	jalr	-1542(ra) # 80001540 <uvmfree>
    return 0;
    80001b4e:	4481                	li	s1,0
    80001b50:	bf7d                	j	80001b0e <proc_pagetable+0x58>

0000000080001b52 <proc_freepagetable>:
{
    80001b52:	1101                	addi	sp,sp,-32
    80001b54:	ec06                	sd	ra,24(sp)
    80001b56:	e822                	sd	s0,16(sp)
    80001b58:	e426                	sd	s1,8(sp)
    80001b5a:	e04a                	sd	s2,0(sp)
    80001b5c:	1000                	addi	s0,sp,32
    80001b5e:	84aa                	mv	s1,a0
    80001b60:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b62:	4681                	li	a3,0
    80001b64:	4605                	li	a2,1
    80001b66:	040005b7          	lui	a1,0x4000
    80001b6a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b6c:	05b2                	slli	a1,a1,0xc
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	710080e7          	jalr	1808(ra) # 8000127e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b76:	4681                	li	a3,0
    80001b78:	4605                	li	a2,1
    80001b7a:	020005b7          	lui	a1,0x2000
    80001b7e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b80:	05b6                	slli	a1,a1,0xd
    80001b82:	8526                	mv	a0,s1
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	6fa080e7          	jalr	1786(ra) # 8000127e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b8c:	85ca                	mv	a1,s2
    80001b8e:	8526                	mv	a0,s1
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	9b0080e7          	jalr	-1616(ra) # 80001540 <uvmfree>
}
    80001b98:	60e2                	ld	ra,24(sp)
    80001b9a:	6442                	ld	s0,16(sp)
    80001b9c:	64a2                	ld	s1,8(sp)
    80001b9e:	6902                	ld	s2,0(sp)
    80001ba0:	6105                	addi	sp,sp,32
    80001ba2:	8082                	ret

0000000080001ba4 <freeproc>:
{
    80001ba4:	1101                	addi	sp,sp,-32
    80001ba6:	ec06                	sd	ra,24(sp)
    80001ba8:	e822                	sd	s0,16(sp)
    80001baa:	e426                	sd	s1,8(sp)
    80001bac:	1000                	addi	s0,sp,32
    80001bae:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bb0:	7128                	ld	a0,96(a0)
    80001bb2:	c509                	beqz	a0,80001bbc <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bb4:	fffff097          	auipc	ra,0xfffff
    80001bb8:	e2c080e7          	jalr	-468(ra) # 800009e0 <kfree>
  p->trapframe = 0;
    80001bbc:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001bc0:	6ca8                	ld	a0,88(s1)
    80001bc2:	c511                	beqz	a0,80001bce <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bc4:	68ac                	ld	a1,80(s1)
    80001bc6:	00000097          	auipc	ra,0x0
    80001bca:	f8c080e7          	jalr	-116(ra) # 80001b52 <proc_freepagetable>
  p->pagetable = 0;
    80001bce:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001bd2:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001bd6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bda:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001bde:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001be2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001be6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bea:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bee:	0004ac23          	sw	zero,24(s1)
}
    80001bf2:	60e2                	ld	ra,24(sp)
    80001bf4:	6442                	ld	s0,16(sp)
    80001bf6:	64a2                	ld	s1,8(sp)
    80001bf8:	6105                	addi	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <allocproc>:
{
    80001bfc:	1101                	addi	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	e04a                	sd	s2,0(sp)
    80001c06:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c08:	00011497          	auipc	s1,0x11
    80001c0c:	b0848493          	addi	s1,s1,-1272 # 80012710 <proc>
    80001c10:	00017917          	auipc	s2,0x17
    80001c14:	f0090913          	addi	s2,s2,-256 # 80018b10 <tickslock>
    acquire(&p->lock);
    80001c18:	8526                	mv	a0,s1
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	fb4080e7          	jalr	-76(ra) # 80000bce <acquire>
    if(p->state == UNUSED) {
    80001c22:	4c9c                	lw	a5,24(s1)
    80001c24:	cf81                	beqz	a5,80001c3c <allocproc+0x40>
      release(&p->lock);
    80001c26:	8526                	mv	a0,s1
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	05a080e7          	jalr	90(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c30:	19048493          	addi	s1,s1,400
    80001c34:	ff2492e3          	bne	s1,s2,80001c18 <allocproc+0x1c>
  return 0;
    80001c38:	4481                	li	s1,0
    80001c3a:	a841                	j	80001cca <allocproc+0xce>
  p->pid = allocpid();
    80001c3c:	00000097          	auipc	ra,0x0
    80001c40:	e34080e7          	jalr	-460(ra) # 80001a70 <allocpid>
    80001c44:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c46:	4785                	li	a5,1
    80001c48:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	e94080e7          	jalr	-364(ra) # 80000ade <kalloc>
    80001c52:	892a                	mv	s2,a0
    80001c54:	f0a8                	sd	a0,96(s1)
    80001c56:	c149                	beqz	a0,80001cd8 <allocproc+0xdc>
  p->pagetable = proc_pagetable(p);
    80001c58:	8526                	mv	a0,s1
    80001c5a:	00000097          	auipc	ra,0x0
    80001c5e:	e5c080e7          	jalr	-420(ra) # 80001ab6 <proc_pagetable>
    80001c62:	892a                	mv	s2,a0
    80001c64:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001c66:	c549                	beqz	a0,80001cf0 <allocproc+0xf4>
  memset(&p->context, 0, sizeof(p->context));
    80001c68:	07000613          	li	a2,112
    80001c6c:	4581                	li	a1,0
    80001c6e:	06848513          	addi	a0,s1,104
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	058080e7          	jalr	88(ra) # 80000cca <memset>
  p->context.ra = (uint64)forkret;
    80001c7a:	00000797          	auipc	a5,0x0
    80001c7e:	d7878793          	addi	a5,a5,-648 # 800019f2 <forkret>
    80001c82:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c84:	64bc                	ld	a5,72(s1)
    80001c86:	6705                	lui	a4,0x1
    80001c88:	97ba                	add	a5,a5,a4
    80001c8a:	f8bc                	sd	a5,112(s1)
  acquire(&tickslock);
    80001c8c:	00017517          	auipc	a0,0x17
    80001c90:	e8450513          	addi	a0,a0,-380 # 80018b10 <tickslock>
    80001c94:	fffff097          	auipc	ra,0xfffff
    80001c98:	f3a080e7          	jalr	-198(ra) # 80000bce <acquire>
  xticks = ticks;
    80001c9c:	00008917          	auipc	s2,0x8
    80001ca0:	3d092903          	lw	s2,976(s2) # 8000a06c <ticks>
  release(&tickslock);
    80001ca4:	00017517          	auipc	a0,0x17
    80001ca8:	e6c50513          	addi	a0,a0,-404 # 80018b10 <tickslock>
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	fd6080e7          	jalr	-42(ra) # 80000c82 <release>
  p->ctime = xticks;
    80001cb4:	1724a823          	sw	s2,368(s1)
  p->stime = -1;
    80001cb8:	57fd                	li	a5,-1
    80001cba:	16f4aa23          	sw	a5,372(s1)
  p->endtime = -1;
    80001cbe:	16f4ac23          	sw	a5,376(s1)
  p->is_batchproc = 0;
    80001cc2:	0204ae23          	sw	zero,60(s1)
  p->cpu_usage = 0;
    80001cc6:	1804a623          	sw	zero,396(s1)
}
    80001cca:	8526                	mv	a0,s1
    80001ccc:	60e2                	ld	ra,24(sp)
    80001cce:	6442                	ld	s0,16(sp)
    80001cd0:	64a2                	ld	s1,8(sp)
    80001cd2:	6902                	ld	s2,0(sp)
    80001cd4:	6105                	addi	sp,sp,32
    80001cd6:	8082                	ret
    freeproc(p);
    80001cd8:	8526                	mv	a0,s1
    80001cda:	00000097          	auipc	ra,0x0
    80001cde:	eca080e7          	jalr	-310(ra) # 80001ba4 <freeproc>
    release(&p->lock);
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	f9e080e7          	jalr	-98(ra) # 80000c82 <release>
    return 0;
    80001cec:	84ca                	mv	s1,s2
    80001cee:	bff1                	j	80001cca <allocproc+0xce>
    freeproc(p);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	00000097          	auipc	ra,0x0
    80001cf6:	eb2080e7          	jalr	-334(ra) # 80001ba4 <freeproc>
    release(&p->lock);
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	f86080e7          	jalr	-122(ra) # 80000c82 <release>
    return 0;
    80001d04:	84ca                	mv	s1,s2
    80001d06:	b7d1                	j	80001cca <allocproc+0xce>

0000000080001d08 <userinit>:
{
    80001d08:	1101                	addi	sp,sp,-32
    80001d0a:	ec06                	sd	ra,24(sp)
    80001d0c:	e822                	sd	s0,16(sp)
    80001d0e:	e426                	sd	s1,8(sp)
    80001d10:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d12:	00000097          	auipc	ra,0x0
    80001d16:	eea080e7          	jalr	-278(ra) # 80001bfc <allocproc>
    80001d1a:	84aa                	mv	s1,a0
  initproc = p;
    80001d1c:	00008797          	auipc	a5,0x8
    80001d20:	34a7b223          	sd	a0,836(a5) # 8000a060 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d24:	03400613          	li	a2,52
    80001d28:	00008597          	auipc	a1,0x8
    80001d2c:	e6858593          	addi	a1,a1,-408 # 80009b90 <initcode>
    80001d30:	6d28                	ld	a0,88(a0)
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	63e080e7          	jalr	1598(ra) # 80001370 <uvminit>
  p->sz = PGSIZE;
    80001d3a:	6785                	lui	a5,0x1
    80001d3c:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d3e:	70b8                	ld	a4,96(s1)
    80001d40:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d44:	70b8                	ld	a4,96(s1)
    80001d46:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d48:	4641                	li	a2,16
    80001d4a:	00007597          	auipc	a1,0x7
    80001d4e:	4b658593          	addi	a1,a1,1206 # 80009200 <digits+0x1c0>
    80001d52:	16048513          	addi	a0,s1,352
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	0be080e7          	jalr	190(ra) # 80000e14 <safestrcpy>
  p->cwd = namei("/");
    80001d5e:	00007517          	auipc	a0,0x7
    80001d62:	4b250513          	addi	a0,a0,1202 # 80009210 <digits+0x1d0>
    80001d66:	00004097          	auipc	ra,0x4
    80001d6a:	9e4080e7          	jalr	-1564(ra) # 8000574a <namei>
    80001d6e:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d72:	478d                	li	a5,3
    80001d74:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d76:	8526                	mv	a0,s1
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	f0a080e7          	jalr	-246(ra) # 80000c82 <release>
}
    80001d80:	60e2                	ld	ra,24(sp)
    80001d82:	6442                	ld	s0,16(sp)
    80001d84:	64a2                	ld	s1,8(sp)
    80001d86:	6105                	addi	sp,sp,32
    80001d88:	8082                	ret

0000000080001d8a <growproc>:
{
    80001d8a:	1101                	addi	sp,sp,-32
    80001d8c:	ec06                	sd	ra,24(sp)
    80001d8e:	e822                	sd	s0,16(sp)
    80001d90:	e426                	sd	s1,8(sp)
    80001d92:	e04a                	sd	s2,0(sp)
    80001d94:	1000                	addi	s0,sp,32
    80001d96:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	c22080e7          	jalr	-990(ra) # 800019ba <myproc>
    80001da0:	892a                	mv	s2,a0
  sz = p->sz;
    80001da2:	692c                	ld	a1,80(a0)
    80001da4:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001da8:	00904f63          	bgtz	s1,80001dc6 <growproc+0x3c>
  } else if(n < 0){
    80001dac:	0204cd63          	bltz	s1,80001de6 <growproc+0x5c>
  p->sz = sz;
    80001db0:	1782                	slli	a5,a5,0x20
    80001db2:	9381                	srli	a5,a5,0x20
    80001db4:	04f93823          	sd	a5,80(s2)
  return 0;
    80001db8:	4501                	li	a0,0
}
    80001dba:	60e2                	ld	ra,24(sp)
    80001dbc:	6442                	ld	s0,16(sp)
    80001dbe:	64a2                	ld	s1,8(sp)
    80001dc0:	6902                	ld	s2,0(sp)
    80001dc2:	6105                	addi	sp,sp,32
    80001dc4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dc6:	00f4863b          	addw	a2,s1,a5
    80001dca:	1602                	slli	a2,a2,0x20
    80001dcc:	9201                	srli	a2,a2,0x20
    80001dce:	1582                	slli	a1,a1,0x20
    80001dd0:	9181                	srli	a1,a1,0x20
    80001dd2:	6d28                	ld	a0,88(a0)
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	656080e7          	jalr	1622(ra) # 8000142a <uvmalloc>
    80001ddc:	0005079b          	sext.w	a5,a0
    80001de0:	fbe1                	bnez	a5,80001db0 <growproc+0x26>
      return -1;
    80001de2:	557d                	li	a0,-1
    80001de4:	bfd9                	j	80001dba <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001de6:	00f4863b          	addw	a2,s1,a5
    80001dea:	1602                	slli	a2,a2,0x20
    80001dec:	9201                	srli	a2,a2,0x20
    80001dee:	1582                	slli	a1,a1,0x20
    80001df0:	9181                	srli	a1,a1,0x20
    80001df2:	6d28                	ld	a0,88(a0)
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	5ee080e7          	jalr	1518(ra) # 800013e2 <uvmdealloc>
    80001dfc:	0005079b          	sext.w	a5,a0
    80001e00:	bf45                	j	80001db0 <growproc+0x26>

0000000080001e02 <fork>:
{
    80001e02:	7139                	addi	sp,sp,-64
    80001e04:	fc06                	sd	ra,56(sp)
    80001e06:	f822                	sd	s0,48(sp)
    80001e08:	f426                	sd	s1,40(sp)
    80001e0a:	f04a                	sd	s2,32(sp)
    80001e0c:	ec4e                	sd	s3,24(sp)
    80001e0e:	e852                	sd	s4,16(sp)
    80001e10:	e456                	sd	s5,8(sp)
    80001e12:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	ba6080e7          	jalr	-1114(ra) # 800019ba <myproc>
    80001e1c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e1e:	00000097          	auipc	ra,0x0
    80001e22:	dde080e7          	jalr	-546(ra) # 80001bfc <allocproc>
    80001e26:	10050c63          	beqz	a0,80001f3e <fork+0x13c>
    80001e2a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e2c:	050ab603          	ld	a2,80(s5)
    80001e30:	6d2c                	ld	a1,88(a0)
    80001e32:	058ab503          	ld	a0,88(s5)
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	744080e7          	jalr	1860(ra) # 8000157a <uvmcopy>
    80001e3e:	04054863          	bltz	a0,80001e8e <fork+0x8c>
  np->sz = p->sz;
    80001e42:	050ab783          	ld	a5,80(s5)
    80001e46:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e4a:	060ab683          	ld	a3,96(s5)
    80001e4e:	87b6                	mv	a5,a3
    80001e50:	060a3703          	ld	a4,96(s4)
    80001e54:	12068693          	addi	a3,a3,288
    80001e58:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5c:	6788                	ld	a0,8(a5)
    80001e5e:	6b8c                	ld	a1,16(a5)
    80001e60:	6f90                	ld	a2,24(a5)
    80001e62:	01073023          	sd	a6,0(a4)
    80001e66:	e708                	sd	a0,8(a4)
    80001e68:	eb0c                	sd	a1,16(a4)
    80001e6a:	ef10                	sd	a2,24(a4)
    80001e6c:	02078793          	addi	a5,a5,32
    80001e70:	02070713          	addi	a4,a4,32
    80001e74:	fed792e3          	bne	a5,a3,80001e58 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e78:	060a3783          	ld	a5,96(s4)
    80001e7c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e80:	0d8a8493          	addi	s1,s5,216
    80001e84:	0d8a0913          	addi	s2,s4,216
    80001e88:	158a8993          	addi	s3,s5,344
    80001e8c:	a00d                	j	80001eae <fork+0xac>
    freeproc(np);
    80001e8e:	8552                	mv	a0,s4
    80001e90:	00000097          	auipc	ra,0x0
    80001e94:	d14080e7          	jalr	-748(ra) # 80001ba4 <freeproc>
    release(&np->lock);
    80001e98:	8552                	mv	a0,s4
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	de8080e7          	jalr	-536(ra) # 80000c82 <release>
    return -1;
    80001ea2:	597d                	li	s2,-1
    80001ea4:	a059                	j	80001f2a <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001ea6:	04a1                	addi	s1,s1,8
    80001ea8:	0921                	addi	s2,s2,8
    80001eaa:	01348b63          	beq	s1,s3,80001ec0 <fork+0xbe>
    if(p->ofile[i])
    80001eae:	6088                	ld	a0,0(s1)
    80001eb0:	d97d                	beqz	a0,80001ea6 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb2:	00004097          	auipc	ra,0x4
    80001eb6:	f2e080e7          	jalr	-210(ra) # 80005de0 <filedup>
    80001eba:	00a93023          	sd	a0,0(s2)
    80001ebe:	b7e5                	j	80001ea6 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ec0:	158ab503          	ld	a0,344(s5)
    80001ec4:	00003097          	auipc	ra,0x3
    80001ec8:	08c080e7          	jalr	140(ra) # 80004f50 <idup>
    80001ecc:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed0:	4641                	li	a2,16
    80001ed2:	160a8593          	addi	a1,s5,352
    80001ed6:	160a0513          	addi	a0,s4,352
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f3a080e7          	jalr	-198(ra) # 80000e14 <safestrcpy>
  pid = np->pid;
    80001ee2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ee6:	8552                	mv	a0,s4
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	d9a080e7          	jalr	-614(ra) # 80000c82 <release>
  acquire(&wait_lock);
    80001ef0:	00010497          	auipc	s1,0x10
    80001ef4:	40848493          	addi	s1,s1,1032 # 800122f8 <wait_lock>
    80001ef8:	8526                	mv	a0,s1
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	cd4080e7          	jalr	-812(ra) # 80000bce <acquire>
  np->parent = p;
    80001f02:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001f06:	8526                	mv	a0,s1
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	d7a080e7          	jalr	-646(ra) # 80000c82 <release>
  acquire(&np->lock);
    80001f10:	8552                	mv	a0,s4
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	cbc080e7          	jalr	-836(ra) # 80000bce <acquire>
  np->state = RUNNABLE;
    80001f1a:	478d                	li	a5,3
    80001f1c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f20:	8552                	mv	a0,s4
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	d60080e7          	jalr	-672(ra) # 80000c82 <release>
}
    80001f2a:	854a                	mv	a0,s2
    80001f2c:	70e2                	ld	ra,56(sp)
    80001f2e:	7442                	ld	s0,48(sp)
    80001f30:	74a2                	ld	s1,40(sp)
    80001f32:	7902                	ld	s2,32(sp)
    80001f34:	69e2                	ld	s3,24(sp)
    80001f36:	6a42                	ld	s4,16(sp)
    80001f38:	6aa2                	ld	s5,8(sp)
    80001f3a:	6121                	addi	sp,sp,64
    80001f3c:	8082                	ret
    return -1;
    80001f3e:	597d                	li	s2,-1
    80001f40:	b7ed                	j	80001f2a <fork+0x128>

0000000080001f42 <forkf>:
{
    80001f42:	7139                	addi	sp,sp,-64
    80001f44:	fc06                	sd	ra,56(sp)
    80001f46:	f822                	sd	s0,48(sp)
    80001f48:	f426                	sd	s1,40(sp)
    80001f4a:	f04a                	sd	s2,32(sp)
    80001f4c:	ec4e                	sd	s3,24(sp)
    80001f4e:	e852                	sd	s4,16(sp)
    80001f50:	e456                	sd	s5,8(sp)
    80001f52:	0080                	addi	s0,sp,64
    80001f54:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f56:	00000097          	auipc	ra,0x0
    80001f5a:	a64080e7          	jalr	-1436(ra) # 800019ba <myproc>
    80001f5e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f60:	00000097          	auipc	ra,0x0
    80001f64:	c9c080e7          	jalr	-868(ra) # 80001bfc <allocproc>
    80001f68:	12050163          	beqz	a0,8000208a <forkf+0x148>
    80001f6c:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f6e:	050ab603          	ld	a2,80(s5)
    80001f72:	6d2c                	ld	a1,88(a0)
    80001f74:	058ab503          	ld	a0,88(s5)
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	602080e7          	jalr	1538(ra) # 8000157a <uvmcopy>
    80001f80:	04054d63          	bltz	a0,80001fda <forkf+0x98>
  np->sz = p->sz;
    80001f84:	050ab783          	ld	a5,80(s5)
    80001f88:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f8c:	060ab683          	ld	a3,96(s5)
    80001f90:	87b6                	mv	a5,a3
    80001f92:	0609b703          	ld	a4,96(s3)
    80001f96:	12068693          	addi	a3,a3,288
    80001f9a:	0007b883          	ld	a7,0(a5)
    80001f9e:	0087b803          	ld	a6,8(a5)
    80001fa2:	6b8c                	ld	a1,16(a5)
    80001fa4:	6f90                	ld	a2,24(a5)
    80001fa6:	01173023          	sd	a7,0(a4)
    80001faa:	01073423          	sd	a6,8(a4)
    80001fae:	eb0c                	sd	a1,16(a4)
    80001fb0:	ef10                	sd	a2,24(a4)
    80001fb2:	02078793          	addi	a5,a5,32
    80001fb6:	02070713          	addi	a4,a4,32
    80001fba:	fed790e3          	bne	a5,a3,80001f9a <forkf+0x58>
  np->trapframe->a0 = 0;
    80001fbe:	0609b783          	ld	a5,96(s3)
    80001fc2:	0607b823          	sd	zero,112(a5)
  np->trapframe->epc = faddr;
    80001fc6:	0609b783          	ld	a5,96(s3)
    80001fca:	ef84                	sd	s1,24(a5)
  for(i = 0; i < NOFILE; i++)
    80001fcc:	0d8a8493          	addi	s1,s5,216
    80001fd0:	0d898913          	addi	s2,s3,216
    80001fd4:	158a8a13          	addi	s4,s5,344
    80001fd8:	a00d                	j	80001ffa <forkf+0xb8>
    freeproc(np);
    80001fda:	854e                	mv	a0,s3
    80001fdc:	00000097          	auipc	ra,0x0
    80001fe0:	bc8080e7          	jalr	-1080(ra) # 80001ba4 <freeproc>
    release(&np->lock);
    80001fe4:	854e                	mv	a0,s3
    80001fe6:	fffff097          	auipc	ra,0xfffff
    80001fea:	c9c080e7          	jalr	-868(ra) # 80000c82 <release>
    return -1;
    80001fee:	597d                	li	s2,-1
    80001ff0:	a059                	j	80002076 <forkf+0x134>
  for(i = 0; i < NOFILE; i++)
    80001ff2:	04a1                	addi	s1,s1,8
    80001ff4:	0921                	addi	s2,s2,8
    80001ff6:	01448b63          	beq	s1,s4,8000200c <forkf+0xca>
    if(p->ofile[i])
    80001ffa:	6088                	ld	a0,0(s1)
    80001ffc:	d97d                	beqz	a0,80001ff2 <forkf+0xb0>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ffe:	00004097          	auipc	ra,0x4
    80002002:	de2080e7          	jalr	-542(ra) # 80005de0 <filedup>
    80002006:	00a93023          	sd	a0,0(s2)
    8000200a:	b7e5                	j	80001ff2 <forkf+0xb0>
  np->cwd = idup(p->cwd);
    8000200c:	158ab503          	ld	a0,344(s5)
    80002010:	00003097          	auipc	ra,0x3
    80002014:	f40080e7          	jalr	-192(ra) # 80004f50 <idup>
    80002018:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000201c:	4641                	li	a2,16
    8000201e:	160a8593          	addi	a1,s5,352
    80002022:	16098513          	addi	a0,s3,352
    80002026:	fffff097          	auipc	ra,0xfffff
    8000202a:	dee080e7          	jalr	-530(ra) # 80000e14 <safestrcpy>
  pid = np->pid;
    8000202e:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002032:	854e                	mv	a0,s3
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	c4e080e7          	jalr	-946(ra) # 80000c82 <release>
  acquire(&wait_lock);
    8000203c:	00010497          	auipc	s1,0x10
    80002040:	2bc48493          	addi	s1,s1,700 # 800122f8 <wait_lock>
    80002044:	8526                	mv	a0,s1
    80002046:	fffff097          	auipc	ra,0xfffff
    8000204a:	b88080e7          	jalr	-1144(ra) # 80000bce <acquire>
  np->parent = p;
    8000204e:	0559b023          	sd	s5,64(s3)
  release(&wait_lock);
    80002052:	8526                	mv	a0,s1
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	c2e080e7          	jalr	-978(ra) # 80000c82 <release>
  acquire(&np->lock);
    8000205c:	854e                	mv	a0,s3
    8000205e:	fffff097          	auipc	ra,0xfffff
    80002062:	b70080e7          	jalr	-1168(ra) # 80000bce <acquire>
  np->state = RUNNABLE;
    80002066:	478d                	li	a5,3
    80002068:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000206c:	854e                	mv	a0,s3
    8000206e:	fffff097          	auipc	ra,0xfffff
    80002072:	c14080e7          	jalr	-1004(ra) # 80000c82 <release>
}
    80002076:	854a                	mv	a0,s2
    80002078:	70e2                	ld	ra,56(sp)
    8000207a:	7442                	ld	s0,48(sp)
    8000207c:	74a2                	ld	s1,40(sp)
    8000207e:	7902                	ld	s2,32(sp)
    80002080:	69e2                	ld	s3,24(sp)
    80002082:	6a42                	ld	s4,16(sp)
    80002084:	6aa2                	ld	s5,8(sp)
    80002086:	6121                	addi	sp,sp,64
    80002088:	8082                	ret
    return -1;
    8000208a:	597d                	li	s2,-1
    8000208c:	b7ed                	j	80002076 <forkf+0x134>

000000008000208e <forkp>:
{
    8000208e:	7139                	addi	sp,sp,-64
    80002090:	fc06                	sd	ra,56(sp)
    80002092:	f822                	sd	s0,48(sp)
    80002094:	f426                	sd	s1,40(sp)
    80002096:	f04a                	sd	s2,32(sp)
    80002098:	ec4e                	sd	s3,24(sp)
    8000209a:	e852                	sd	s4,16(sp)
    8000209c:	e456                	sd	s5,8(sp)
    8000209e:	e05a                	sd	s6,0(sp)
    800020a0:	0080                	addi	s0,sp,64
    800020a2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	916080e7          	jalr	-1770(ra) # 800019ba <myproc>
    800020ac:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800020ae:	00000097          	auipc	ra,0x0
    800020b2:	b4e080e7          	jalr	-1202(ra) # 80001bfc <allocproc>
    800020b6:	14050863          	beqz	a0,80002206 <forkp+0x178>
    800020ba:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020bc:	050ab603          	ld	a2,80(s5)
    800020c0:	6d2c                	ld	a1,88(a0)
    800020c2:	058ab503          	ld	a0,88(s5)
    800020c6:	fffff097          	auipc	ra,0xfffff
    800020ca:	4b4080e7          	jalr	1204(ra) # 8000157a <uvmcopy>
    800020ce:	04054863          	bltz	a0,8000211e <forkp+0x90>
  np->sz = p->sz;
    800020d2:	050ab783          	ld	a5,80(s5)
    800020d6:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    800020da:	060ab683          	ld	a3,96(s5)
    800020de:	87b6                	mv	a5,a3
    800020e0:	0609b703          	ld	a4,96(s3)
    800020e4:	12068693          	addi	a3,a3,288
    800020e8:	0007b803          	ld	a6,0(a5)
    800020ec:	6788                	ld	a0,8(a5)
    800020ee:	6b8c                	ld	a1,16(a5)
    800020f0:	6f90                	ld	a2,24(a5)
    800020f2:	01073023          	sd	a6,0(a4)
    800020f6:	e708                	sd	a0,8(a4)
    800020f8:	eb0c                	sd	a1,16(a4)
    800020fa:	ef10                	sd	a2,24(a4)
    800020fc:	02078793          	addi	a5,a5,32
    80002100:	02070713          	addi	a4,a4,32
    80002104:	fed792e3          	bne	a5,a3,800020e8 <forkp+0x5a>
  np->trapframe->a0 = 0;
    80002108:	0609b783          	ld	a5,96(s3)
    8000210c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80002110:	0d8a8493          	addi	s1,s5,216
    80002114:	0d898913          	addi	s2,s3,216
    80002118:	158a8a13          	addi	s4,s5,344
    8000211c:	a00d                	j	8000213e <forkp+0xb0>
    freeproc(np);
    8000211e:	854e                	mv	a0,s3
    80002120:	00000097          	auipc	ra,0x0
    80002124:	a84080e7          	jalr	-1404(ra) # 80001ba4 <freeproc>
    release(&np->lock);
    80002128:	854e                	mv	a0,s3
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	b58080e7          	jalr	-1192(ra) # 80000c82 <release>
    return -1;
    80002132:	597d                	li	s2,-1
    80002134:	a875                	j	800021f0 <forkp+0x162>
  for(i = 0; i < NOFILE; i++)
    80002136:	04a1                	addi	s1,s1,8
    80002138:	0921                	addi	s2,s2,8
    8000213a:	01448b63          	beq	s1,s4,80002150 <forkp+0xc2>
    if(p->ofile[i])
    8000213e:	6088                	ld	a0,0(s1)
    80002140:	d97d                	beqz	a0,80002136 <forkp+0xa8>
      np->ofile[i] = filedup(p->ofile[i]);
    80002142:	00004097          	auipc	ra,0x4
    80002146:	c9e080e7          	jalr	-866(ra) # 80005de0 <filedup>
    8000214a:	00a93023          	sd	a0,0(s2)
    8000214e:	b7e5                	j	80002136 <forkp+0xa8>
  np->cwd = idup(p->cwd);
    80002150:	158ab503          	ld	a0,344(s5)
    80002154:	00003097          	auipc	ra,0x3
    80002158:	dfc080e7          	jalr	-516(ra) # 80004f50 <idup>
    8000215c:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002160:	4641                	li	a2,16
    80002162:	160a8593          	addi	a1,s5,352
    80002166:	16098513          	addi	a0,s3,352
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	caa080e7          	jalr	-854(ra) # 80000e14 <safestrcpy>
  pid = np->pid;
    80002172:	0309a903          	lw	s2,48(s3)
  np->base_priority = priority;
    80002176:	0369aa23          	sw	s6,52(s3)
  np->is_batchproc = 1;
    8000217a:	4785                	li	a5,1
    8000217c:	02f9ae23          	sw	a5,60(s3)
  np->nextburst_estimate = 0;
    80002180:	1809a423          	sw	zero,392(s3)
  np->waittime = 0;
    80002184:	1609ae23          	sw	zero,380(s3)
  release(&np->lock);
    80002188:	854e                	mv	a0,s3
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	af8080e7          	jalr	-1288(ra) # 80000c82 <release>
  batchsize++;
    80002192:	00008717          	auipc	a4,0x8
    80002196:	eca70713          	addi	a4,a4,-310 # 8000a05c <batchsize>
    8000219a:	431c                	lw	a5,0(a4)
    8000219c:	2785                	addiw	a5,a5,1
    8000219e:	c31c                	sw	a5,0(a4)
  batchsize2++;
    800021a0:	00008717          	auipc	a4,0x8
    800021a4:	eb870713          	addi	a4,a4,-328 # 8000a058 <batchsize2>
    800021a8:	431c                	lw	a5,0(a4)
    800021aa:	2785                	addiw	a5,a5,1
    800021ac:	c31c                	sw	a5,0(a4)
  acquire(&wait_lock);
    800021ae:	00010497          	auipc	s1,0x10
    800021b2:	14a48493          	addi	s1,s1,330 # 800122f8 <wait_lock>
    800021b6:	8526                	mv	a0,s1
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	a16080e7          	jalr	-1514(ra) # 80000bce <acquire>
  np->parent = p;
    800021c0:	0559b023          	sd	s5,64(s3)
  release(&wait_lock);
    800021c4:	8526                	mv	a0,s1
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	abc080e7          	jalr	-1348(ra) # 80000c82 <release>
  acquire(&np->lock);
    800021ce:	854e                	mv	a0,s3
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	9fe080e7          	jalr	-1538(ra) # 80000bce <acquire>
  np->state = RUNNABLE;
    800021d8:	478d                	li	a5,3
    800021da:	00f9ac23          	sw	a5,24(s3)
  np->waitstart = np->ctime;
    800021de:	1709a783          	lw	a5,368(s3)
    800021e2:	18f9a023          	sw	a5,384(s3)
  release(&np->lock);
    800021e6:	854e                	mv	a0,s3
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	a9a080e7          	jalr	-1382(ra) # 80000c82 <release>
}
    800021f0:	854a                	mv	a0,s2
    800021f2:	70e2                	ld	ra,56(sp)
    800021f4:	7442                	ld	s0,48(sp)
    800021f6:	74a2                	ld	s1,40(sp)
    800021f8:	7902                	ld	s2,32(sp)
    800021fa:	69e2                	ld	s3,24(sp)
    800021fc:	6a42                	ld	s4,16(sp)
    800021fe:	6aa2                	ld	s5,8(sp)
    80002200:	6b02                	ld	s6,0(sp)
    80002202:	6121                	addi	sp,sp,64
    80002204:	8082                	ret
    return -1;
    80002206:	597d                	li	s2,-1
    80002208:	b7e5                	j	800021f0 <forkp+0x162>

000000008000220a <scheduler>:
{
    8000220a:	711d                	addi	sp,sp,-96
    8000220c:	ec86                	sd	ra,88(sp)
    8000220e:	e8a2                	sd	s0,80(sp)
    80002210:	e4a6                	sd	s1,72(sp)
    80002212:	e0ca                	sd	s2,64(sp)
    80002214:	fc4e                	sd	s3,56(sp)
    80002216:	f852                	sd	s4,48(sp)
    80002218:	f456                	sd	s5,40(sp)
    8000221a:	f05a                	sd	s6,32(sp)
    8000221c:	ec5e                	sd	s7,24(sp)
    8000221e:	e862                	sd	s8,16(sp)
    80002220:	e466                	sd	s9,8(sp)
    80002222:	e06a                	sd	s10,0(sp)
    80002224:	1080                	addi	s0,sp,96
    80002226:	8792                	mv	a5,tp
  int id = r_tp();
    80002228:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000222a:	00779a93          	slli	s5,a5,0x7
    8000222e:	00010717          	auipc	a4,0x10
    80002232:	0b270713          	addi	a4,a4,178 # 800122e0 <pid_lock>
    80002236:	9756                	add	a4,a4,s5
    80002238:	02073823          	sd	zero,48(a4)
            swtch(&c->context, &p->context);
    8000223c:	00010717          	auipc	a4,0x10
    80002240:	0dc70713          	addi	a4,a4,220 # 80012318 <cpus+0x8>
    80002244:	9aba                	add	s5,s5,a4
          xticks = ticks;
    80002246:	00008997          	auipc	s3,0x8
    8000224a:	e2698993          	addi	s3,s3,-474 # 8000a06c <ticks>
            c->proc = p;
    8000224e:	079e                	slli	a5,a5,0x7
    80002250:	00010a17          	auipc	s4,0x10
    80002254:	090a0a13          	addi	s4,s4,144 # 800122e0 <pid_lock>
    80002258:	9a3e                	add	s4,s4,a5
       for(p = proc; p < &proc[NPROC]; p++) {
    8000225a:	00017917          	auipc	s2,0x17
    8000225e:	8b690913          	addi	s2,s2,-1866 # 80018b10 <tickslock>
    80002262:	aca9                	j	800024bc <scheduler+0x2b2>
       acquire(&tickslock);
    80002264:	00017517          	auipc	a0,0x17
    80002268:	8ac50513          	addi	a0,a0,-1876 # 80018b10 <tickslock>
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	962080e7          	jalr	-1694(ra) # 80000bce <acquire>
       xticks = ticks;
    80002274:	0009ad03          	lw	s10,0(s3)
       release(&tickslock);
    80002278:	00017517          	auipc	a0,0x17
    8000227c:	89850513          	addi	a0,a0,-1896 # 80018b10 <tickslock>
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	a02080e7          	jalr	-1534(ra) # 80000c82 <release>
       min_burst = 0x7FFFFFFF;
    80002288:	80000c37          	lui	s8,0x80000
    8000228c:	fffc4c13          	not	s8,s8
       q = 0;
    80002290:	4c81                	li	s9,0
       for(p = proc; p < &proc[NPROC]; p++) {
    80002292:	00010497          	auipc	s1,0x10
    80002296:	47e48493          	addi	s1,s1,1150 # 80012710 <proc>
	  if(p->state == RUNNABLE) {
    8000229a:	4b8d                	li	s7,3
    8000229c:	a0ad                	j	80002306 <scheduler+0xfc>
                if (q) release(&q->lock);
    8000229e:	000c8763          	beqz	s9,800022ac <scheduler+0xa2>
    800022a2:	8566                	mv	a0,s9
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	9de080e7          	jalr	-1570(ra) # 80000c82 <release>
          q->state = RUNNING;
    800022ac:	4791                	li	a5,4
    800022ae:	cc9c                	sw	a5,24(s1)
          q->waittime += (xticks - q->waitstart);
    800022b0:	17c4a783          	lw	a5,380(s1)
    800022b4:	01a787bb          	addw	a5,a5,s10
    800022b8:	1804a703          	lw	a4,384(s1)
    800022bc:	9f99                	subw	a5,a5,a4
    800022be:	16f4ae23          	sw	a5,380(s1)
          q->burst_start = xticks;
    800022c2:	19a4a223          	sw	s10,388(s1)
          c->proc = q;
    800022c6:	029a3823          	sd	s1,48(s4)
          swtch(&c->context, &q->context);
    800022ca:	06848593          	addi	a1,s1,104
    800022ce:	8556                	mv	a0,s5
    800022d0:	00001097          	auipc	ra,0x1
    800022d4:	3fc080e7          	jalr	1020(ra) # 800036cc <swtch>
          c->proc = 0;
    800022d8:	020a3823          	sd	zero,48(s4)
	  release(&q->lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	9a4080e7          	jalr	-1628(ra) # 80000c82 <release>
    800022e6:	aad9                	j	800024bc <scheduler+0x2b2>
             else release(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	998080e7          	jalr	-1640(ra) # 80000c82 <release>
    800022f2:	a031                	j	800022fe <scheduler+0xf4>
	  else release(&p->lock);
    800022f4:	8526                	mv	a0,s1
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	98c080e7          	jalr	-1652(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    800022fe:	19048493          	addi	s1,s1,400
    80002302:	03248d63          	beq	s1,s2,8000233c <scheduler+0x132>
          acquire(&p->lock);
    80002306:	8526                	mv	a0,s1
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	8c6080e7          	jalr	-1850(ra) # 80000bce <acquire>
	  if(p->state == RUNNABLE) {
    80002310:	4c9c                	lw	a5,24(s1)
    80002312:	ff7791e3          	bne	a5,s7,800022f4 <scheduler+0xea>
	     if (!p->is_batchproc) {
    80002316:	5cdc                	lw	a5,60(s1)
    80002318:	d3d9                	beqz	a5,8000229e <scheduler+0x94>
             else if (p->nextburst_estimate < min_burst) {
    8000231a:	1884ab03          	lw	s6,392(s1)
    8000231e:	fd8b55e3          	bge	s6,s8,800022e8 <scheduler+0xde>
		if (q) release(&q->lock);
    80002322:	000c8a63          	beqz	s9,80002336 <scheduler+0x12c>
    80002326:	8566                	mv	a0,s9
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	95a080e7          	jalr	-1702(ra) # 80000c82 <release>
	        min_burst = p->nextburst_estimate;
    80002330:	8c5a                	mv	s8,s6
		if (q) release(&q->lock);
    80002332:	8ca6                	mv	s9,s1
    80002334:	b7e9                	j	800022fe <scheduler+0xf4>
	        min_burst = p->nextburst_estimate;
    80002336:	8c5a                	mv	s8,s6
    80002338:	8ca6                	mv	s9,s1
    8000233a:	b7d1                	j	800022fe <scheduler+0xf4>
       if (q) {
    8000233c:	180c8063          	beqz	s9,800024bc <scheduler+0x2b2>
    80002340:	84e6                	mv	s1,s9
    80002342:	b7ad                	j	800022ac <scheduler+0xa2>
       acquire(&tickslock);
    80002344:	00016517          	auipc	a0,0x16
    80002348:	7cc50513          	addi	a0,a0,1996 # 80018b10 <tickslock>
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	882080e7          	jalr	-1918(ra) # 80000bce <acquire>
       xticks = ticks;
    80002354:	0009ab83          	lw	s7,0(s3)
       release(&tickslock);
    80002358:	00016517          	auipc	a0,0x16
    8000235c:	7b850513          	addi	a0,a0,1976 # 80018b10 <tickslock>
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	922080e7          	jalr	-1758(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002368:	00010497          	auipc	s1,0x10
    8000236c:	3a848493          	addi	s1,s1,936 # 80012710 <proc>
	  if(p->state == RUNNABLE) {
    80002370:	4b0d                	li	s6,3
    80002372:	a811                	j	80002386 <scheduler+0x17c>
	  release(&p->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	90c080e7          	jalr	-1780(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    8000237e:	19048493          	addi	s1,s1,400
    80002382:	03248e63          	beq	s1,s2,800023be <scheduler+0x1b4>
          acquire(&p->lock);
    80002386:	8526                	mv	a0,s1
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	846080e7          	jalr	-1978(ra) # 80000bce <acquire>
	  if(p->state == RUNNABLE) {
    80002390:	4c9c                	lw	a5,24(s1)
    80002392:	ff6791e3          	bne	a5,s6,80002374 <scheduler+0x16a>
	     p->cpu_usage = p->cpu_usage/2;
    80002396:	18c4a703          	lw	a4,396(s1)
    8000239a:	01f7579b          	srliw	a5,a4,0x1f
    8000239e:	9fb9                	addw	a5,a5,a4
    800023a0:	4017d79b          	sraiw	a5,a5,0x1
    800023a4:	18f4a623          	sw	a5,396(s1)
	     p->priority = p->base_priority + (p->cpu_usage/2);
    800023a8:	41f7579b          	sraiw	a5,a4,0x1f
    800023ac:	01e7d79b          	srliw	a5,a5,0x1e
    800023b0:	9fb9                	addw	a5,a5,a4
    800023b2:	4027d79b          	sraiw	a5,a5,0x2
    800023b6:	58d8                	lw	a4,52(s1)
    800023b8:	9fb9                	addw	a5,a5,a4
    800023ba:	dc9c                	sw	a5,56(s1)
    800023bc:	bf65                	j	80002374 <scheduler+0x16a>
       min_prio = 0x7FFFFFFF;
    800023be:	80000cb7          	lui	s9,0x80000
    800023c2:	fffccc93          	not	s9,s9
       q = 0;
    800023c6:	4d01                	li	s10,0
       for(p = proc; p < &proc[NPROC]; p++) {
    800023c8:	00010497          	auipc	s1,0x10
    800023cc:	34848493          	addi	s1,s1,840 # 80012710 <proc>
          if(p->state == RUNNABLE) {
    800023d0:	4c0d                	li	s8,3
    800023d2:	a0ad                	j	8000243c <scheduler+0x232>
                if (q) release(&q->lock);
    800023d4:	000d0763          	beqz	s10,800023e2 <scheduler+0x1d8>
    800023d8:	856a                	mv	a0,s10
    800023da:	fffff097          	auipc	ra,0xfffff
    800023de:	8a8080e7          	jalr	-1880(ra) # 80000c82 <release>
          q->state = RUNNING;
    800023e2:	4791                	li	a5,4
    800023e4:	cc9c                	sw	a5,24(s1)
          q->waittime += (xticks - q->waitstart);
    800023e6:	17c4a783          	lw	a5,380(s1)
    800023ea:	017787bb          	addw	a5,a5,s7
    800023ee:	1804a703          	lw	a4,384(s1)
    800023f2:	9f99                	subw	a5,a5,a4
    800023f4:	16f4ae23          	sw	a5,380(s1)
          q->burst_start = xticks;
    800023f8:	1974a223          	sw	s7,388(s1)
          c->proc = q;
    800023fc:	029a3823          	sd	s1,48(s4)
          swtch(&c->context, &q->context);
    80002400:	06848593          	addi	a1,s1,104
    80002404:	8556                	mv	a0,s5
    80002406:	00001097          	auipc	ra,0x1
    8000240a:	2c6080e7          	jalr	710(ra) # 800036cc <swtch>
          c->proc = 0;
    8000240e:	020a3823          	sd	zero,48(s4)
          release(&q->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	86e080e7          	jalr	-1938(ra) # 80000c82 <release>
    8000241c:	a045                	j	800024bc <scheduler+0x2b2>
             else release(&p->lock);
    8000241e:	8526                	mv	a0,s1
    80002420:	fffff097          	auipc	ra,0xfffff
    80002424:	862080e7          	jalr	-1950(ra) # 80000c82 <release>
    80002428:	a031                	j	80002434 <scheduler+0x22a>
          else release(&p->lock);
    8000242a:	8526                	mv	a0,s1
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	856080e7          	jalr	-1962(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002434:	19048493          	addi	s1,s1,400
    80002438:	03248d63          	beq	s1,s2,80002472 <scheduler+0x268>
          acquire(&p->lock);
    8000243c:	8526                	mv	a0,s1
    8000243e:	ffffe097          	auipc	ra,0xffffe
    80002442:	790080e7          	jalr	1936(ra) # 80000bce <acquire>
          if(p->state == RUNNABLE) {
    80002446:	4c9c                	lw	a5,24(s1)
    80002448:	ff8791e3          	bne	a5,s8,8000242a <scheduler+0x220>
             if (!p->is_batchproc) {
    8000244c:	5cdc                	lw	a5,60(s1)
    8000244e:	d3d9                	beqz	a5,800023d4 <scheduler+0x1ca>
             else if (p->priority < min_prio) {
    80002450:	0384ab03          	lw	s6,56(s1)
    80002454:	fd9b55e3          	bge	s6,s9,8000241e <scheduler+0x214>
                if (q) release(&q->lock);
    80002458:	000d0a63          	beqz	s10,8000246c <scheduler+0x262>
    8000245c:	856a                	mv	a0,s10
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	824080e7          	jalr	-2012(ra) # 80000c82 <release>
                min_prio = p->priority;
    80002466:	8cda                	mv	s9,s6
                if (q) release(&q->lock);
    80002468:	8d26                	mv	s10,s1
    8000246a:	b7e9                	j	80002434 <scheduler+0x22a>
                min_prio = p->priority;
    8000246c:	8cda                	mv	s9,s6
    8000246e:	8d26                	mv	s10,s1
    80002470:	b7d1                	j	80002434 <scheduler+0x22a>
       if (q) {
    80002472:	040d0563          	beqz	s10,800024bc <scheduler+0x2b2>
    80002476:	84ea                	mv	s1,s10
    80002478:	b7ad                	j	800023e2 <scheduler+0x1d8>
          acquire(&tickslock);
    8000247a:	855a                	mv	a0,s6
    8000247c:	ffffe097          	auipc	ra,0xffffe
    80002480:	752080e7          	jalr	1874(ra) # 80000bce <acquire>
          xticks = ticks;
    80002484:	0009ac83          	lw	s9,0(s3)
          release(&tickslock);
    80002488:	855a                	mv	a0,s6
    8000248a:	ffffe097          	auipc	ra,0xffffe
    8000248e:	7f8080e7          	jalr	2040(ra) # 80000c82 <release>
          acquire(&p->lock);
    80002492:	8526                	mv	a0,s1
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	73a080e7          	jalr	1850(ra) # 80000bce <acquire>
          if(p->state == RUNNABLE) {
    8000249c:	4c9c                	lw	a5,24(s1)
    8000249e:	05878d63          	beq	a5,s8,800024f8 <scheduler+0x2ee>
          release(&p->lock);
    800024a2:	8526                	mv	a0,s1
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	7de080e7          	jalr	2014(ra) # 80000c82 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    800024ac:	19048493          	addi	s1,s1,400
    800024b0:	01248663          	beq	s1,s2,800024bc <scheduler+0x2b2>
          if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_PREEMPT_RR)) break;
    800024b4:	000ba783          	lw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffd7000>
    800024b8:	9bf5                	andi	a5,a5,-3
    800024ba:	d3e1                	beqz	a5,8000247a <scheduler+0x270>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024bc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024c0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024c4:	10079073          	csrw	sstatus,a5
    if (sched_policy == SCHED_NPREEMPT_SJF) {
    800024c8:	00008797          	auipc	a5,0x8
    800024cc:	ba07a783          	lw	a5,-1120(a5) # 8000a068 <sched_policy>
    800024d0:	4705                	li	a4,1
    800024d2:	d8e789e3          	beq	a5,a4,80002264 <scheduler+0x5a>
    else if (sched_policy == SCHED_PREEMPT_UNIX) {
    800024d6:	470d                	li	a4,3
       for(p = proc; p < &proc[NPROC]; p++) {
    800024d8:	00010497          	auipc	s1,0x10
    800024dc:	23848493          	addi	s1,s1,568 # 80012710 <proc>
    else if (sched_policy == SCHED_PREEMPT_UNIX) {
    800024e0:	e6e782e3          	beq	a5,a4,80002344 <scheduler+0x13a>
          if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_PREEMPT_RR)) break;
    800024e4:	00008b97          	auipc	s7,0x8
    800024e8:	b84b8b93          	addi	s7,s7,-1148 # 8000a068 <sched_policy>
          acquire(&tickslock);
    800024ec:	00016b17          	auipc	s6,0x16
    800024f0:	624b0b13          	addi	s6,s6,1572 # 80018b10 <tickslock>
          if(p->state == RUNNABLE) {
    800024f4:	4c0d                	li	s8,3
    800024f6:	bf7d                	j	800024b4 <scheduler+0x2aa>
            p->state = RUNNING;
    800024f8:	4791                	li	a5,4
    800024fa:	cc9c                	sw	a5,24(s1)
	    p->waittime += (xticks - p->waitstart);
    800024fc:	17c4a783          	lw	a5,380(s1)
    80002500:	019787bb          	addw	a5,a5,s9
    80002504:	1804a703          	lw	a4,384(s1)
    80002508:	9f99                	subw	a5,a5,a4
    8000250a:	16f4ae23          	sw	a5,380(s1)
	    p->burst_start = xticks;
    8000250e:	1994a223          	sw	s9,388(s1)
            c->proc = p;
    80002512:	029a3823          	sd	s1,48(s4)
            swtch(&c->context, &p->context);
    80002516:	06848593          	addi	a1,s1,104
    8000251a:	8556                	mv	a0,s5
    8000251c:	00001097          	auipc	ra,0x1
    80002520:	1b0080e7          	jalr	432(ra) # 800036cc <swtch>
            c->proc = 0;
    80002524:	020a3823          	sd	zero,48(s4)
    80002528:	bfad                	j	800024a2 <scheduler+0x298>

000000008000252a <sched>:
{
    8000252a:	7179                	addi	sp,sp,-48
    8000252c:	f406                	sd	ra,40(sp)
    8000252e:	f022                	sd	s0,32(sp)
    80002530:	ec26                	sd	s1,24(sp)
    80002532:	e84a                	sd	s2,16(sp)
    80002534:	e44e                	sd	s3,8(sp)
    80002536:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002538:	fffff097          	auipc	ra,0xfffff
    8000253c:	482080e7          	jalr	1154(ra) # 800019ba <myproc>
    80002540:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002542:	ffffe097          	auipc	ra,0xffffe
    80002546:	612080e7          	jalr	1554(ra) # 80000b54 <holding>
    8000254a:	c93d                	beqz	a0,800025c0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000254c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000254e:	2781                	sext.w	a5,a5
    80002550:	079e                	slli	a5,a5,0x7
    80002552:	00010717          	auipc	a4,0x10
    80002556:	d8e70713          	addi	a4,a4,-626 # 800122e0 <pid_lock>
    8000255a:	97ba                	add	a5,a5,a4
    8000255c:	0a87a703          	lw	a4,168(a5)
    80002560:	4785                	li	a5,1
    80002562:	06f71763          	bne	a4,a5,800025d0 <sched+0xa6>
  if(p->state == RUNNING)
    80002566:	4c98                	lw	a4,24(s1)
    80002568:	4791                	li	a5,4
    8000256a:	06f70b63          	beq	a4,a5,800025e0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000256e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002572:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002574:	efb5                	bnez	a5,800025f0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002576:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002578:	00010917          	auipc	s2,0x10
    8000257c:	d6890913          	addi	s2,s2,-664 # 800122e0 <pid_lock>
    80002580:	2781                	sext.w	a5,a5
    80002582:	079e                	slli	a5,a5,0x7
    80002584:	97ca                	add	a5,a5,s2
    80002586:	0ac7a983          	lw	s3,172(a5)
    8000258a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000258c:	2781                	sext.w	a5,a5
    8000258e:	079e                	slli	a5,a5,0x7
    80002590:	00010597          	auipc	a1,0x10
    80002594:	d8858593          	addi	a1,a1,-632 # 80012318 <cpus+0x8>
    80002598:	95be                	add	a1,a1,a5
    8000259a:	06848513          	addi	a0,s1,104
    8000259e:	00001097          	auipc	ra,0x1
    800025a2:	12e080e7          	jalr	302(ra) # 800036cc <swtch>
    800025a6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800025a8:	2781                	sext.w	a5,a5
    800025aa:	079e                	slli	a5,a5,0x7
    800025ac:	993e                	add	s2,s2,a5
    800025ae:	0b392623          	sw	s3,172(s2)
}
    800025b2:	70a2                	ld	ra,40(sp)
    800025b4:	7402                	ld	s0,32(sp)
    800025b6:	64e2                	ld	s1,24(sp)
    800025b8:	6942                	ld	s2,16(sp)
    800025ba:	69a2                	ld	s3,8(sp)
    800025bc:	6145                	addi	sp,sp,48
    800025be:	8082                	ret
    panic("sched p->lock");
    800025c0:	00007517          	auipc	a0,0x7
    800025c4:	c5850513          	addi	a0,a0,-936 # 80009218 <digits+0x1d8>
    800025c8:	ffffe097          	auipc	ra,0xffffe
    800025cc:	f70080e7          	jalr	-144(ra) # 80000538 <panic>
    panic("sched locks");
    800025d0:	00007517          	auipc	a0,0x7
    800025d4:	c5850513          	addi	a0,a0,-936 # 80009228 <digits+0x1e8>
    800025d8:	ffffe097          	auipc	ra,0xffffe
    800025dc:	f60080e7          	jalr	-160(ra) # 80000538 <panic>
    panic("sched running");
    800025e0:	00007517          	auipc	a0,0x7
    800025e4:	c5850513          	addi	a0,a0,-936 # 80009238 <digits+0x1f8>
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	f50080e7          	jalr	-176(ra) # 80000538 <panic>
    panic("sched interruptible");
    800025f0:	00007517          	auipc	a0,0x7
    800025f4:	c5850513          	addi	a0,a0,-936 # 80009248 <digits+0x208>
    800025f8:	ffffe097          	auipc	ra,0xffffe
    800025fc:	f40080e7          	jalr	-192(ra) # 80000538 <panic>

0000000080002600 <yield>:
{
    80002600:	1101                	addi	sp,sp,-32
    80002602:	ec06                	sd	ra,24(sp)
    80002604:	e822                	sd	s0,16(sp)
    80002606:	e426                	sd	s1,8(sp)
    80002608:	e04a                	sd	s2,0(sp)
    8000260a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000260c:	fffff097          	auipc	ra,0xfffff
    80002610:	3ae080e7          	jalr	942(ra) # 800019ba <myproc>
    80002614:	84aa                	mv	s1,a0
  acquire(&tickslock);
    80002616:	00016517          	auipc	a0,0x16
    8000261a:	4fa50513          	addi	a0,a0,1274 # 80018b10 <tickslock>
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	5b0080e7          	jalr	1456(ra) # 80000bce <acquire>
  xticks = ticks;
    80002626:	00008917          	auipc	s2,0x8
    8000262a:	a4692903          	lw	s2,-1466(s2) # 8000a06c <ticks>
  release(&tickslock);
    8000262e:	00016517          	auipc	a0,0x16
    80002632:	4e250513          	addi	a0,a0,1250 # 80018b10 <tickslock>
    80002636:	ffffe097          	auipc	ra,0xffffe
    8000263a:	64c080e7          	jalr	1612(ra) # 80000c82 <release>
  acquire(&p->lock);
    8000263e:	8526                	mv	a0,s1
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	58e080e7          	jalr	1422(ra) # 80000bce <acquire>
  p->state = RUNNABLE;
    80002648:	478d                	li	a5,3
    8000264a:	cc9c                	sw	a5,24(s1)
  p->waitstart = xticks;
    8000264c:	1924a023          	sw	s2,384(s1)
  p->cpu_usage += SCHED_PARAM_CPU_USAGE;
    80002650:	18c4a783          	lw	a5,396(s1)
    80002654:	0c87879b          	addiw	a5,a5,200
    80002658:	18f4a623          	sw	a5,396(s1)
  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    8000265c:	5cdc                	lw	a5,60(s1)
    8000265e:	c7ed                	beqz	a5,80002748 <yield+0x148>
    80002660:	1844a783          	lw	a5,388(s1)
    80002664:	0f278263          	beq	a5,s2,80002748 <yield+0x148>
     num_cpubursts++;
    80002668:	00008697          	auipc	a3,0x8
    8000266c:	9dc68693          	addi	a3,a3,-1572 # 8000a044 <num_cpubursts>
    80002670:	4298                	lw	a4,0(a3)
    80002672:	2705                	addiw	a4,a4,1
    80002674:	c298                	sw	a4,0(a3)
     cpubursts_tot += (xticks - p->burst_start);
    80002676:	40f9073b          	subw	a4,s2,a5
    8000267a:	0007061b          	sext.w	a2,a4
    8000267e:	00008597          	auipc	a1,0x8
    80002682:	9c258593          	addi	a1,a1,-1598 # 8000a040 <cpubursts_tot>
    80002686:	4194                	lw	a3,0(a1)
    80002688:	9eb9                	addw	a3,a3,a4
    8000268a:	c194                	sw	a3,0(a1)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    8000268c:	00008697          	auipc	a3,0x8
    80002690:	9b06a683          	lw	a3,-1616(a3) # 8000a03c <cpubursts_max>
    80002694:	00c6f663          	bgeu	a3,a2,800026a0 <yield+0xa0>
    80002698:	00008697          	auipc	a3,0x8
    8000269c:	9ae6a223          	sw	a4,-1628(a3) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    800026a0:	00007697          	auipc	a3,0x7
    800026a4:	4d86a683          	lw	a3,1240(a3) # 80009b78 <cpubursts_min>
    800026a8:	00d67663          	bgeu	a2,a3,800026b4 <yield+0xb4>
    800026ac:	00007697          	auipc	a3,0x7
    800026b0:	4ce6a623          	sw	a4,1228(a3) # 80009b78 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    800026b4:	1884a683          	lw	a3,392(s1)
    800026b8:	02d05763          	blez	a3,800026e6 <yield+0xe6>
        estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    800026bc:	0006859b          	sext.w	a1,a3
    800026c0:	0ac5e363          	bltu	a1,a2,80002766 <yield+0x166>
    800026c4:	9fad                	addw	a5,a5,a1
    800026c6:	412785bb          	subw	a1,a5,s2
    800026ca:	00008617          	auipc	a2,0x8
    800026ce:	96260613          	addi	a2,a2,-1694 # 8000a02c <estimation_error>
    800026d2:	421c                	lw	a5,0(a2)
    800026d4:	9fad                	addw	a5,a5,a1
    800026d6:	c21c                	sw	a5,0(a2)
	estimation_error_instance++;
    800026d8:	00008617          	auipc	a2,0x8
    800026dc:	95060613          	addi	a2,a2,-1712 # 8000a028 <estimation_error_instance>
    800026e0:	421c                	lw	a5,0(a2)
    800026e2:	2785                	addiw	a5,a5,1
    800026e4:	c21c                	sw	a5,0(a2)
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    800026e6:	01f6d79b          	srliw	a5,a3,0x1f
    800026ea:	9fb5                	addw	a5,a5,a3
    800026ec:	4017d79b          	sraiw	a5,a5,0x1
    800026f0:	9fb9                	addw	a5,a5,a4
    800026f2:	0017571b          	srliw	a4,a4,0x1
    800026f6:	9f99                	subw	a5,a5,a4
    800026f8:	0007871b          	sext.w	a4,a5
    800026fc:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    80002700:	04e05463          	blez	a4,80002748 <yield+0x148>
        num_cpubursts_est++;
    80002704:	00008617          	auipc	a2,0x8
    80002708:	93460613          	addi	a2,a2,-1740 # 8000a038 <num_cpubursts_est>
    8000270c:	4214                	lw	a3,0(a2)
    8000270e:	2685                	addiw	a3,a3,1
    80002710:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    80002712:	00008617          	auipc	a2,0x8
    80002716:	92260613          	addi	a2,a2,-1758 # 8000a034 <cpubursts_est_tot>
    8000271a:	4214                	lw	a3,0(a2)
    8000271c:	9ebd                	addw	a3,a3,a5
    8000271e:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002720:	00008697          	auipc	a3,0x8
    80002724:	9106a683          	lw	a3,-1776(a3) # 8000a030 <cpubursts_est_max>
    80002728:	00e6d663          	bge	a3,a4,80002734 <yield+0x134>
    8000272c:	00008697          	auipc	a3,0x8
    80002730:	90f6a223          	sw	a5,-1788(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    80002734:	00007697          	auipc	a3,0x7
    80002738:	4406a683          	lw	a3,1088(a3) # 80009b74 <cpubursts_est_min>
    8000273c:	00d75663          	bge	a4,a3,80002748 <yield+0x148>
    80002740:	00007717          	auipc	a4,0x7
    80002744:	42f72a23          	sw	a5,1076(a4) # 80009b74 <cpubursts_est_min>
  sched();
    80002748:	00000097          	auipc	ra,0x0
    8000274c:	de2080e7          	jalr	-542(ra) # 8000252a <sched>
  release(&p->lock);
    80002750:	8526                	mv	a0,s1
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	530080e7          	jalr	1328(ra) # 80000c82 <release>
}
    8000275a:	60e2                	ld	ra,24(sp)
    8000275c:	6442                	ld	s0,16(sp)
    8000275e:	64a2                	ld	s1,8(sp)
    80002760:	6902                	ld	s2,0(sp)
    80002762:	6105                	addi	sp,sp,32
    80002764:	8082                	ret
        estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002766:	40b705bb          	subw	a1,a4,a1
    8000276a:	b785                	j	800026ca <yield+0xca>

000000008000276c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000276c:	7179                	addi	sp,sp,-48
    8000276e:	f406                	sd	ra,40(sp)
    80002770:	f022                	sd	s0,32(sp)
    80002772:	ec26                	sd	s1,24(sp)
    80002774:	e84a                	sd	s2,16(sp)
    80002776:	e44e                	sd	s3,8(sp)
    80002778:	e052                	sd	s4,0(sp)
    8000277a:	1800                	addi	s0,sp,48
    8000277c:	89aa                	mv	s3,a0
    8000277e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002780:	fffff097          	auipc	ra,0xfffff
    80002784:	23a080e7          	jalr	570(ra) # 800019ba <myproc>
    80002788:	84aa                	mv	s1,a0
  uint xticks;

  if (!holding(&tickslock)) {
    8000278a:	00016517          	auipc	a0,0x16
    8000278e:	38650513          	addi	a0,a0,902 # 80018b10 <tickslock>
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	3c2080e7          	jalr	962(ra) # 80000b54 <holding>
    8000279a:	14050863          	beqz	a0,800028ea <sleep+0x17e>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    8000279e:	00008a17          	auipc	s4,0x8
    800027a2:	8cea2a03          	lw	s4,-1842(s4) # 8000a06c <ticks>
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800027a6:	8526                	mv	a0,s1
    800027a8:	ffffe097          	auipc	ra,0xffffe
    800027ac:	426080e7          	jalr	1062(ra) # 80000bce <acquire>
  release(lk);
    800027b0:	854a                	mv	a0,s2
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	4d0080e7          	jalr	1232(ra) # 80000c82 <release>

  // Go to sleep.
  p->chan = chan;
    800027ba:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800027be:	4789                	li	a5,2
    800027c0:	cc9c                	sw	a5,24(s1)

  p->cpu_usage += (SCHED_PARAM_CPU_USAGE/2);
    800027c2:	18c4a783          	lw	a5,396(s1)
    800027c6:	0647879b          	addiw	a5,a5,100
    800027ca:	18f4a623          	sw	a5,396(s1)

  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    800027ce:	5cdc                	lw	a5,60(s1)
    800027d0:	c7ed                	beqz	a5,800028ba <sleep+0x14e>
    800027d2:	1844a783          	lw	a5,388(s1)
    800027d6:	0f478263          	beq	a5,s4,800028ba <sleep+0x14e>
     num_cpubursts++;
    800027da:	00008697          	auipc	a3,0x8
    800027de:	86a68693          	addi	a3,a3,-1942 # 8000a044 <num_cpubursts>
    800027e2:	4298                	lw	a4,0(a3)
    800027e4:	2705                	addiw	a4,a4,1
    800027e6:	c298                	sw	a4,0(a3)
     cpubursts_tot += (xticks - p->burst_start);
    800027e8:	40fa073b          	subw	a4,s4,a5
    800027ec:	0007061b          	sext.w	a2,a4
    800027f0:	00008597          	auipc	a1,0x8
    800027f4:	85058593          	addi	a1,a1,-1968 # 8000a040 <cpubursts_tot>
    800027f8:	4194                	lw	a3,0(a1)
    800027fa:	9eb9                	addw	a3,a3,a4
    800027fc:	c194                	sw	a3,0(a1)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    800027fe:	00008697          	auipc	a3,0x8
    80002802:	83e6a683          	lw	a3,-1986(a3) # 8000a03c <cpubursts_max>
    80002806:	00c6f663          	bgeu	a3,a2,80002812 <sleep+0xa6>
    8000280a:	00008697          	auipc	a3,0x8
    8000280e:	82e6a923          	sw	a4,-1998(a3) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002812:	00007697          	auipc	a3,0x7
    80002816:	3666a683          	lw	a3,870(a3) # 80009b78 <cpubursts_min>
    8000281a:	00d67663          	bgeu	a2,a3,80002826 <sleep+0xba>
    8000281e:	00007697          	auipc	a3,0x7
    80002822:	34e6ad23          	sw	a4,858(a3) # 80009b78 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    80002826:	1884a683          	lw	a3,392(s1)
    8000282a:	02d05763          	blez	a3,80002858 <sleep+0xec>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    8000282e:	0006859b          	sext.w	a1,a3
    80002832:	0ec5e163          	bltu	a1,a2,80002914 <sleep+0x1a8>
    80002836:	9fad                	addw	a5,a5,a1
    80002838:	414785bb          	subw	a1,a5,s4
    8000283c:	00007617          	auipc	a2,0x7
    80002840:	7f060613          	addi	a2,a2,2032 # 8000a02c <estimation_error>
    80002844:	421c                	lw	a5,0(a2)
    80002846:	9fad                	addw	a5,a5,a1
    80002848:	c21c                	sw	a5,0(a2)
        estimation_error_instance++;
    8000284a:	00007617          	auipc	a2,0x7
    8000284e:	7de60613          	addi	a2,a2,2014 # 8000a028 <estimation_error_instance>
    80002852:	421c                	lw	a5,0(a2)
    80002854:	2785                	addiw	a5,a5,1
    80002856:	c21c                	sw	a5,0(a2)
     }
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    80002858:	01f6d79b          	srliw	a5,a3,0x1f
    8000285c:	9fb5                	addw	a5,a5,a3
    8000285e:	4017d79b          	sraiw	a5,a5,0x1
    80002862:	9fb9                	addw	a5,a5,a4
    80002864:	0017571b          	srliw	a4,a4,0x1
    80002868:	9f99                	subw	a5,a5,a4
    8000286a:	0007871b          	sext.w	a4,a5
    8000286e:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    80002872:	04e05463          	blez	a4,800028ba <sleep+0x14e>
        num_cpubursts_est++;
    80002876:	00007617          	auipc	a2,0x7
    8000287a:	7c260613          	addi	a2,a2,1986 # 8000a038 <num_cpubursts_est>
    8000287e:	4214                	lw	a3,0(a2)
    80002880:	2685                	addiw	a3,a3,1
    80002882:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    80002884:	00007617          	auipc	a2,0x7
    80002888:	7b060613          	addi	a2,a2,1968 # 8000a034 <cpubursts_est_tot>
    8000288c:	4214                	lw	a3,0(a2)
    8000288e:	9ebd                	addw	a3,a3,a5
    80002890:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002892:	00007697          	auipc	a3,0x7
    80002896:	79e6a683          	lw	a3,1950(a3) # 8000a030 <cpubursts_est_max>
    8000289a:	00e6d663          	bge	a3,a4,800028a6 <sleep+0x13a>
    8000289e:	00007697          	auipc	a3,0x7
    800028a2:	78f6a923          	sw	a5,1938(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    800028a6:	00007697          	auipc	a3,0x7
    800028aa:	2ce6a683          	lw	a3,718(a3) # 80009b74 <cpubursts_est_min>
    800028ae:	00d75663          	bge	a4,a3,800028ba <sleep+0x14e>
    800028b2:	00007717          	auipc	a4,0x7
    800028b6:	2cf72123          	sw	a5,706(a4) # 80009b74 <cpubursts_est_min>
     }
  }

  sched();
    800028ba:	00000097          	auipc	ra,0x0
    800028be:	c70080e7          	jalr	-912(ra) # 8000252a <sched>

  // Tidy up.
  p->chan = 0;
    800028c2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800028c6:	8526                	mv	a0,s1
    800028c8:	ffffe097          	auipc	ra,0xffffe
    800028cc:	3ba080e7          	jalr	954(ra) # 80000c82 <release>
  acquire(lk);
    800028d0:	854a                	mv	a0,s2
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	2fc080e7          	jalr	764(ra) # 80000bce <acquire>
}
    800028da:	70a2                	ld	ra,40(sp)
    800028dc:	7402                	ld	s0,32(sp)
    800028de:	64e2                	ld	s1,24(sp)
    800028e0:	6942                	ld	s2,16(sp)
    800028e2:	69a2                	ld	s3,8(sp)
    800028e4:	6a02                	ld	s4,0(sp)
    800028e6:	6145                	addi	sp,sp,48
    800028e8:	8082                	ret
     acquire(&tickslock);
    800028ea:	00016517          	auipc	a0,0x16
    800028ee:	22650513          	addi	a0,a0,550 # 80018b10 <tickslock>
    800028f2:	ffffe097          	auipc	ra,0xffffe
    800028f6:	2dc080e7          	jalr	732(ra) # 80000bce <acquire>
     xticks = ticks;
    800028fa:	00007a17          	auipc	s4,0x7
    800028fe:	772a2a03          	lw	s4,1906(s4) # 8000a06c <ticks>
     release(&tickslock);
    80002902:	00016517          	auipc	a0,0x16
    80002906:	20e50513          	addi	a0,a0,526 # 80018b10 <tickslock>
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	378080e7          	jalr	888(ra) # 80000c82 <release>
    80002912:	bd51                	j	800027a6 <sleep+0x3a>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002914:	40b705bb          	subw	a1,a4,a1
    80002918:	b715                	j	8000283c <sleep+0xd0>

000000008000291a <wait>:
{
    8000291a:	715d                	addi	sp,sp,-80
    8000291c:	e486                	sd	ra,72(sp)
    8000291e:	e0a2                	sd	s0,64(sp)
    80002920:	fc26                	sd	s1,56(sp)
    80002922:	f84a                	sd	s2,48(sp)
    80002924:	f44e                	sd	s3,40(sp)
    80002926:	f052                	sd	s4,32(sp)
    80002928:	ec56                	sd	s5,24(sp)
    8000292a:	e85a                	sd	s6,16(sp)
    8000292c:	e45e                	sd	s7,8(sp)
    8000292e:	e062                	sd	s8,0(sp)
    80002930:	0880                	addi	s0,sp,80
    80002932:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002934:	fffff097          	auipc	ra,0xfffff
    80002938:	086080e7          	jalr	134(ra) # 800019ba <myproc>
    8000293c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000293e:	00010517          	auipc	a0,0x10
    80002942:	9ba50513          	addi	a0,a0,-1606 # 800122f8 <wait_lock>
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	288080e7          	jalr	648(ra) # 80000bce <acquire>
    havekids = 0;
    8000294e:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002950:	4a15                	li	s4,5
        havekids = 1;
    80002952:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002954:	00016997          	auipc	s3,0x16
    80002958:	1bc98993          	addi	s3,s3,444 # 80018b10 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000295c:	00010c17          	auipc	s8,0x10
    80002960:	99cc0c13          	addi	s8,s8,-1636 # 800122f8 <wait_lock>
    havekids = 0;
    80002964:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002966:	00010497          	auipc	s1,0x10
    8000296a:	daa48493          	addi	s1,s1,-598 # 80012710 <proc>
    8000296e:	a0bd                	j	800029dc <wait+0xc2>
          pid = np->pid;
    80002970:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002974:	000b0e63          	beqz	s6,80002990 <wait+0x76>
    80002978:	4691                	li	a3,4
    8000297a:	02c48613          	addi	a2,s1,44
    8000297e:	85da                	mv	a1,s6
    80002980:	05893503          	ld	a0,88(s2)
    80002984:	fffff097          	auipc	ra,0xfffff
    80002988:	cfa080e7          	jalr	-774(ra) # 8000167e <copyout>
    8000298c:	02054563          	bltz	a0,800029b6 <wait+0x9c>
          freeproc(np);
    80002990:	8526                	mv	a0,s1
    80002992:	fffff097          	auipc	ra,0xfffff
    80002996:	212080e7          	jalr	530(ra) # 80001ba4 <freeproc>
          release(&np->lock);
    8000299a:	8526                	mv	a0,s1
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	2e6080e7          	jalr	742(ra) # 80000c82 <release>
          release(&wait_lock);
    800029a4:	00010517          	auipc	a0,0x10
    800029a8:	95450513          	addi	a0,a0,-1708 # 800122f8 <wait_lock>
    800029ac:	ffffe097          	auipc	ra,0xffffe
    800029b0:	2d6080e7          	jalr	726(ra) # 80000c82 <release>
          return pid;
    800029b4:	a09d                	j	80002a1a <wait+0x100>
            release(&np->lock);
    800029b6:	8526                	mv	a0,s1
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	2ca080e7          	jalr	714(ra) # 80000c82 <release>
            release(&wait_lock);
    800029c0:	00010517          	auipc	a0,0x10
    800029c4:	93850513          	addi	a0,a0,-1736 # 800122f8 <wait_lock>
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	2ba080e7          	jalr	698(ra) # 80000c82 <release>
            return -1;
    800029d0:	59fd                	li	s3,-1
    800029d2:	a0a1                	j	80002a1a <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800029d4:	19048493          	addi	s1,s1,400
    800029d8:	03348463          	beq	s1,s3,80002a00 <wait+0xe6>
      if(np->parent == p){
    800029dc:	60bc                	ld	a5,64(s1)
    800029de:	ff279be3          	bne	a5,s2,800029d4 <wait+0xba>
        acquire(&np->lock);
    800029e2:	8526                	mv	a0,s1
    800029e4:	ffffe097          	auipc	ra,0xffffe
    800029e8:	1ea080e7          	jalr	490(ra) # 80000bce <acquire>
        if(np->state == ZOMBIE){
    800029ec:	4c9c                	lw	a5,24(s1)
    800029ee:	f94781e3          	beq	a5,s4,80002970 <wait+0x56>
        release(&np->lock);
    800029f2:	8526                	mv	a0,s1
    800029f4:	ffffe097          	auipc	ra,0xffffe
    800029f8:	28e080e7          	jalr	654(ra) # 80000c82 <release>
        havekids = 1;
    800029fc:	8756                	mv	a4,s5
    800029fe:	bfd9                	j	800029d4 <wait+0xba>
    if(!havekids || p->killed){
    80002a00:	c701                	beqz	a4,80002a08 <wait+0xee>
    80002a02:	02892783          	lw	a5,40(s2)
    80002a06:	c79d                	beqz	a5,80002a34 <wait+0x11a>
      release(&wait_lock);
    80002a08:	00010517          	auipc	a0,0x10
    80002a0c:	8f050513          	addi	a0,a0,-1808 # 800122f8 <wait_lock>
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	272080e7          	jalr	626(ra) # 80000c82 <release>
      return -1;
    80002a18:	59fd                	li	s3,-1
}
    80002a1a:	854e                	mv	a0,s3
    80002a1c:	60a6                	ld	ra,72(sp)
    80002a1e:	6406                	ld	s0,64(sp)
    80002a20:	74e2                	ld	s1,56(sp)
    80002a22:	7942                	ld	s2,48(sp)
    80002a24:	79a2                	ld	s3,40(sp)
    80002a26:	7a02                	ld	s4,32(sp)
    80002a28:	6ae2                	ld	s5,24(sp)
    80002a2a:	6b42                	ld	s6,16(sp)
    80002a2c:	6ba2                	ld	s7,8(sp)
    80002a2e:	6c02                	ld	s8,0(sp)
    80002a30:	6161                	addi	sp,sp,80
    80002a32:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a34:	85e2                	mv	a1,s8
    80002a36:	854a                	mv	a0,s2
    80002a38:	00000097          	auipc	ra,0x0
    80002a3c:	d34080e7          	jalr	-716(ra) # 8000276c <sleep>
    havekids = 0;
    80002a40:	b715                	j	80002964 <wait+0x4a>

0000000080002a42 <waitpid>:
{
    80002a42:	711d                	addi	sp,sp,-96
    80002a44:	ec86                	sd	ra,88(sp)
    80002a46:	e8a2                	sd	s0,80(sp)
    80002a48:	e4a6                	sd	s1,72(sp)
    80002a4a:	e0ca                	sd	s2,64(sp)
    80002a4c:	fc4e                	sd	s3,56(sp)
    80002a4e:	f852                	sd	s4,48(sp)
    80002a50:	f456                	sd	s5,40(sp)
    80002a52:	f05a                	sd	s6,32(sp)
    80002a54:	ec5e                	sd	s7,24(sp)
    80002a56:	e862                	sd	s8,16(sp)
    80002a58:	e466                	sd	s9,8(sp)
    80002a5a:	1080                	addi	s0,sp,96
    80002a5c:	8a2a                	mv	s4,a0
    80002a5e:	8c2e                	mv	s8,a1
  struct proc *p = myproc();
    80002a60:	fffff097          	auipc	ra,0xfffff
    80002a64:	f5a080e7          	jalr	-166(ra) # 800019ba <myproc>
    80002a68:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002a6a:	00010517          	auipc	a0,0x10
    80002a6e:	88e50513          	addi	a0,a0,-1906 # 800122f8 <wait_lock>
    80002a72:	ffffe097          	auipc	ra,0xffffe
    80002a76:	15c080e7          	jalr	348(ra) # 80000bce <acquire>
  int found=0;
    80002a7a:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    80002a7c:	4a95                	li	s5,5
	found = 1;
    80002a7e:	4b05                	li	s6,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002a80:	00016997          	auipc	s3,0x16
    80002a84:	09098993          	addi	s3,s3,144 # 80018b10 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a88:	00010b97          	auipc	s7,0x10
    80002a8c:	870b8b93          	addi	s7,s7,-1936 # 800122f8 <wait_lock>
    80002a90:	a0c9                	j	80002b52 <waitpid+0x110>
             release(&np->lock);
    80002a92:	8526                	mv	a0,s1
    80002a94:	ffffe097          	auipc	ra,0xffffe
    80002a98:	1ee080e7          	jalr	494(ra) # 80000c82 <release>
             release(&wait_lock);
    80002a9c:	00010517          	auipc	a0,0x10
    80002aa0:	85c50513          	addi	a0,a0,-1956 # 800122f8 <wait_lock>
    80002aa4:	ffffe097          	auipc	ra,0xffffe
    80002aa8:	1de080e7          	jalr	478(ra) # 80000c82 <release>
             return -1;
    80002aac:	557d                	li	a0,-1
    80002aae:	a895                	j	80002b22 <waitpid+0xe0>
        release(&np->lock);
    80002ab0:	8526                	mv	a0,s1
    80002ab2:	ffffe097          	auipc	ra,0xffffe
    80002ab6:	1d0080e7          	jalr	464(ra) # 80000c82 <release>
	found = 1;
    80002aba:	8cda                	mv	s9,s6
    for(np = proc; np < &proc[NPROC]; np++){
    80002abc:	19048493          	addi	s1,s1,400
    80002ac0:	07348e63          	beq	s1,s3,80002b3c <waitpid+0xfa>
      if((np->parent == p) && (np->pid == pid)){
    80002ac4:	60bc                	ld	a5,64(s1)
    80002ac6:	ff279be3          	bne	a5,s2,80002abc <waitpid+0x7a>
    80002aca:	589c                	lw	a5,48(s1)
    80002acc:	ff4798e3          	bne	a5,s4,80002abc <waitpid+0x7a>
        acquire(&np->lock);
    80002ad0:	8526                	mv	a0,s1
    80002ad2:	ffffe097          	auipc	ra,0xffffe
    80002ad6:	0fc080e7          	jalr	252(ra) # 80000bce <acquire>
        if(np->state == ZOMBIE){
    80002ada:	4c9c                	lw	a5,24(s1)
    80002adc:	fd579ae3          	bne	a5,s5,80002ab0 <waitpid+0x6e>
           if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002ae0:	000c0e63          	beqz	s8,80002afc <waitpid+0xba>
    80002ae4:	4691                	li	a3,4
    80002ae6:	02c48613          	addi	a2,s1,44
    80002aea:	85e2                	mv	a1,s8
    80002aec:	05893503          	ld	a0,88(s2)
    80002af0:	fffff097          	auipc	ra,0xfffff
    80002af4:	b8e080e7          	jalr	-1138(ra) # 8000167e <copyout>
    80002af8:	f8054de3          	bltz	a0,80002a92 <waitpid+0x50>
           freeproc(np);
    80002afc:	8526                	mv	a0,s1
    80002afe:	fffff097          	auipc	ra,0xfffff
    80002b02:	0a6080e7          	jalr	166(ra) # 80001ba4 <freeproc>
           release(&np->lock);
    80002b06:	8526                	mv	a0,s1
    80002b08:	ffffe097          	auipc	ra,0xffffe
    80002b0c:	17a080e7          	jalr	378(ra) # 80000c82 <release>
           release(&wait_lock);
    80002b10:	0000f517          	auipc	a0,0xf
    80002b14:	7e850513          	addi	a0,a0,2024 # 800122f8 <wait_lock>
    80002b18:	ffffe097          	auipc	ra,0xffffe
    80002b1c:	16a080e7          	jalr	362(ra) # 80000c82 <release>
           return pid;
    80002b20:	8552                	mv	a0,s4
}
    80002b22:	60e6                	ld	ra,88(sp)
    80002b24:	6446                	ld	s0,80(sp)
    80002b26:	64a6                	ld	s1,72(sp)
    80002b28:	6906                	ld	s2,64(sp)
    80002b2a:	79e2                	ld	s3,56(sp)
    80002b2c:	7a42                	ld	s4,48(sp)
    80002b2e:	7aa2                	ld	s5,40(sp)
    80002b30:	7b02                	ld	s6,32(sp)
    80002b32:	6be2                	ld	s7,24(sp)
    80002b34:	6c42                	ld	s8,16(sp)
    80002b36:	6ca2                	ld	s9,8(sp)
    80002b38:	6125                	addi	sp,sp,96
    80002b3a:	8082                	ret
    if(!found || p->killed){
    80002b3c:	020c8063          	beqz	s9,80002b5c <waitpid+0x11a>
    80002b40:	02892783          	lw	a5,40(s2)
    80002b44:	ef81                	bnez	a5,80002b5c <waitpid+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002b46:	85de                	mv	a1,s7
    80002b48:	854a                	mv	a0,s2
    80002b4a:	00000097          	auipc	ra,0x0
    80002b4e:	c22080e7          	jalr	-990(ra) # 8000276c <sleep>
    for(np = proc; np < &proc[NPROC]; np++){
    80002b52:	00010497          	auipc	s1,0x10
    80002b56:	bbe48493          	addi	s1,s1,-1090 # 80012710 <proc>
    80002b5a:	b7ad                	j	80002ac4 <waitpid+0x82>
      release(&wait_lock);
    80002b5c:	0000f517          	auipc	a0,0xf
    80002b60:	79c50513          	addi	a0,a0,1948 # 800122f8 <wait_lock>
    80002b64:	ffffe097          	auipc	ra,0xffffe
    80002b68:	11e080e7          	jalr	286(ra) # 80000c82 <release>
      return -1;
    80002b6c:	557d                	li	a0,-1
    80002b6e:	bf55                	j	80002b22 <waitpid+0xe0>

0000000080002b70 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002b70:	7139                	addi	sp,sp,-64
    80002b72:	fc06                	sd	ra,56(sp)
    80002b74:	f822                	sd	s0,48(sp)
    80002b76:	f426                	sd	s1,40(sp)
    80002b78:	f04a                	sd	s2,32(sp)
    80002b7a:	ec4e                	sd	s3,24(sp)
    80002b7c:	e852                	sd	s4,16(sp)
    80002b7e:	e456                	sd	s5,8(sp)
    80002b80:	e05a                	sd	s6,0(sp)
    80002b82:	0080                	addi	s0,sp,64
    80002b84:	8a2a                	mv	s4,a0
  struct proc *p;
  uint xticks;

  if (!holding(&tickslock)) {
    80002b86:	00016517          	auipc	a0,0x16
    80002b8a:	f8a50513          	addi	a0,a0,-118 # 80018b10 <tickslock>
    80002b8e:	ffffe097          	auipc	ra,0xffffe
    80002b92:	fc6080e7          	jalr	-58(ra) # 80000b54 <holding>
    80002b96:	c105                	beqz	a0,80002bb6 <wakeup+0x46>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    80002b98:	00007b17          	auipc	s6,0x7
    80002b9c:	4d4b2b03          	lw	s6,1236(s6) # 8000a06c <ticks>

  for(p = proc; p < &proc[NPROC]; p++) {
    80002ba0:	00010497          	auipc	s1,0x10
    80002ba4:	b7048493          	addi	s1,s1,-1168 # 80012710 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002ba8:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002baa:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002bac:	00016917          	auipc	s2,0x16
    80002bb0:	f6490913          	addi	s2,s2,-156 # 80018b10 <tickslock>
    80002bb4:	a83d                	j	80002bf2 <wakeup+0x82>
     acquire(&tickslock);
    80002bb6:	00016517          	auipc	a0,0x16
    80002bba:	f5a50513          	addi	a0,a0,-166 # 80018b10 <tickslock>
    80002bbe:	ffffe097          	auipc	ra,0xffffe
    80002bc2:	010080e7          	jalr	16(ra) # 80000bce <acquire>
     xticks = ticks;
    80002bc6:	00007b17          	auipc	s6,0x7
    80002bca:	4a6b2b03          	lw	s6,1190(s6) # 8000a06c <ticks>
     release(&tickslock);
    80002bce:	00016517          	auipc	a0,0x16
    80002bd2:	f4250513          	addi	a0,a0,-190 # 80018b10 <tickslock>
    80002bd6:	ffffe097          	auipc	ra,0xffffe
    80002bda:	0ac080e7          	jalr	172(ra) # 80000c82 <release>
    80002bde:	b7c9                	j	80002ba0 <wakeup+0x30>
	p->waitstart = xticks;
      }
      release(&p->lock);
    80002be0:	8526                	mv	a0,s1
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	0a0080e7          	jalr	160(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002bea:	19048493          	addi	s1,s1,400
    80002bee:	03248863          	beq	s1,s2,80002c1e <wakeup+0xae>
    if(p != myproc()){
    80002bf2:	fffff097          	auipc	ra,0xfffff
    80002bf6:	dc8080e7          	jalr	-568(ra) # 800019ba <myproc>
    80002bfa:	fea488e3          	beq	s1,a0,80002bea <wakeup+0x7a>
      acquire(&p->lock);
    80002bfe:	8526                	mv	a0,s1
    80002c00:	ffffe097          	auipc	ra,0xffffe
    80002c04:	fce080e7          	jalr	-50(ra) # 80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002c08:	4c9c                	lw	a5,24(s1)
    80002c0a:	fd379be3          	bne	a5,s3,80002be0 <wakeup+0x70>
    80002c0e:	709c                	ld	a5,32(s1)
    80002c10:	fd4798e3          	bne	a5,s4,80002be0 <wakeup+0x70>
        p->state = RUNNABLE;
    80002c14:	0154ac23          	sw	s5,24(s1)
	p->waitstart = xticks;
    80002c18:	1964a023          	sw	s6,384(s1)
    80002c1c:	b7d1                	j	80002be0 <wakeup+0x70>
    }
  }
}
    80002c1e:	70e2                	ld	ra,56(sp)
    80002c20:	7442                	ld	s0,48(sp)
    80002c22:	74a2                	ld	s1,40(sp)
    80002c24:	7902                	ld	s2,32(sp)
    80002c26:	69e2                	ld	s3,24(sp)
    80002c28:	6a42                	ld	s4,16(sp)
    80002c2a:	6aa2                	ld	s5,8(sp)
    80002c2c:	6b02                	ld	s6,0(sp)
    80002c2e:	6121                	addi	sp,sp,64
    80002c30:	8082                	ret

0000000080002c32 <reparent>:
{
    80002c32:	7179                	addi	sp,sp,-48
    80002c34:	f406                	sd	ra,40(sp)
    80002c36:	f022                	sd	s0,32(sp)
    80002c38:	ec26                	sd	s1,24(sp)
    80002c3a:	e84a                	sd	s2,16(sp)
    80002c3c:	e44e                	sd	s3,8(sp)
    80002c3e:	e052                	sd	s4,0(sp)
    80002c40:	1800                	addi	s0,sp,48
    80002c42:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002c44:	00010497          	auipc	s1,0x10
    80002c48:	acc48493          	addi	s1,s1,-1332 # 80012710 <proc>
      pp->parent = initproc;
    80002c4c:	00007a17          	auipc	s4,0x7
    80002c50:	414a0a13          	addi	s4,s4,1044 # 8000a060 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002c54:	00016997          	auipc	s3,0x16
    80002c58:	ebc98993          	addi	s3,s3,-324 # 80018b10 <tickslock>
    80002c5c:	a029                	j	80002c66 <reparent+0x34>
    80002c5e:	19048493          	addi	s1,s1,400
    80002c62:	01348d63          	beq	s1,s3,80002c7c <reparent+0x4a>
    if(pp->parent == p){
    80002c66:	60bc                	ld	a5,64(s1)
    80002c68:	ff279be3          	bne	a5,s2,80002c5e <reparent+0x2c>
      pp->parent = initproc;
    80002c6c:	000a3503          	ld	a0,0(s4)
    80002c70:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002c72:	00000097          	auipc	ra,0x0
    80002c76:	efe080e7          	jalr	-258(ra) # 80002b70 <wakeup>
    80002c7a:	b7d5                	j	80002c5e <reparent+0x2c>
}
    80002c7c:	70a2                	ld	ra,40(sp)
    80002c7e:	7402                	ld	s0,32(sp)
    80002c80:	64e2                	ld	s1,24(sp)
    80002c82:	6942                	ld	s2,16(sp)
    80002c84:	69a2                	ld	s3,8(sp)
    80002c86:	6a02                	ld	s4,0(sp)
    80002c88:	6145                	addi	sp,sp,48
    80002c8a:	8082                	ret

0000000080002c8c <exit>:
{
    80002c8c:	7179                	addi	sp,sp,-48
    80002c8e:	f406                	sd	ra,40(sp)
    80002c90:	f022                	sd	s0,32(sp)
    80002c92:	ec26                	sd	s1,24(sp)
    80002c94:	e84a                	sd	s2,16(sp)
    80002c96:	e44e                	sd	s3,8(sp)
    80002c98:	e052                	sd	s4,0(sp)
    80002c9a:	1800                	addi	s0,sp,48
    80002c9c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	d1c080e7          	jalr	-740(ra) # 800019ba <myproc>
    80002ca6:	892a                	mv	s2,a0
  if(p == initproc)
    80002ca8:	00007797          	auipc	a5,0x7
    80002cac:	3b87b783          	ld	a5,952(a5) # 8000a060 <initproc>
    80002cb0:	0d850493          	addi	s1,a0,216
    80002cb4:	15850993          	addi	s3,a0,344
    80002cb8:	02a79363          	bne	a5,a0,80002cde <exit+0x52>
    panic("init exiting");
    80002cbc:	00006517          	auipc	a0,0x6
    80002cc0:	5a450513          	addi	a0,a0,1444 # 80009260 <digits+0x220>
    80002cc4:	ffffe097          	auipc	ra,0xffffe
    80002cc8:	874080e7          	jalr	-1932(ra) # 80000538 <panic>
      fileclose(f);
    80002ccc:	00003097          	auipc	ra,0x3
    80002cd0:	166080e7          	jalr	358(ra) # 80005e32 <fileclose>
      p->ofile[fd] = 0;
    80002cd4:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002cd8:	04a1                	addi	s1,s1,8
    80002cda:	01348563          	beq	s1,s3,80002ce4 <exit+0x58>
    if(p->ofile[fd]){
    80002cde:	6088                	ld	a0,0(s1)
    80002ce0:	f575                	bnez	a0,80002ccc <exit+0x40>
    80002ce2:	bfdd                	j	80002cd8 <exit+0x4c>
  begin_op();
    80002ce4:	00003097          	auipc	ra,0x3
    80002ce8:	c86080e7          	jalr	-890(ra) # 8000596a <begin_op>
  iput(p->cwd);
    80002cec:	15893503          	ld	a0,344(s2)
    80002cf0:	00002097          	auipc	ra,0x2
    80002cf4:	458080e7          	jalr	1112(ra) # 80005148 <iput>
  end_op();
    80002cf8:	00003097          	auipc	ra,0x3
    80002cfc:	cf0080e7          	jalr	-784(ra) # 800059e8 <end_op>
  p->cwd = 0;
    80002d00:	14093c23          	sd	zero,344(s2)
  acquire(&wait_lock);
    80002d04:	0000f497          	auipc	s1,0xf
    80002d08:	5f448493          	addi	s1,s1,1524 # 800122f8 <wait_lock>
    80002d0c:	8526                	mv	a0,s1
    80002d0e:	ffffe097          	auipc	ra,0xffffe
    80002d12:	ec0080e7          	jalr	-320(ra) # 80000bce <acquire>
  reparent(p);
    80002d16:	854a                	mv	a0,s2
    80002d18:	00000097          	auipc	ra,0x0
    80002d1c:	f1a080e7          	jalr	-230(ra) # 80002c32 <reparent>
  wakeup(p->parent);
    80002d20:	04093503          	ld	a0,64(s2)
    80002d24:	00000097          	auipc	ra,0x0
    80002d28:	e4c080e7          	jalr	-436(ra) # 80002b70 <wakeup>
  acquire(&p->lock);
    80002d2c:	854a                	mv	a0,s2
    80002d2e:	ffffe097          	auipc	ra,0xffffe
    80002d32:	ea0080e7          	jalr	-352(ra) # 80000bce <acquire>
  p->xstate = status;
    80002d36:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    80002d3a:	4795                	li	a5,5
    80002d3c:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    80002d40:	8526                	mv	a0,s1
    80002d42:	ffffe097          	auipc	ra,0xffffe
    80002d46:	f40080e7          	jalr	-192(ra) # 80000c82 <release>
  acquire(&tickslock);
    80002d4a:	00016517          	auipc	a0,0x16
    80002d4e:	dc650513          	addi	a0,a0,-570 # 80018b10 <tickslock>
    80002d52:	ffffe097          	auipc	ra,0xffffe
    80002d56:	e7c080e7          	jalr	-388(ra) # 80000bce <acquire>
  xticks = ticks;
    80002d5a:	00007497          	auipc	s1,0x7
    80002d5e:	3124a483          	lw	s1,786(s1) # 8000a06c <ticks>
  release(&tickslock);
    80002d62:	00016517          	auipc	a0,0x16
    80002d66:	dae50513          	addi	a0,a0,-594 # 80018b10 <tickslock>
    80002d6a:	ffffe097          	auipc	ra,0xffffe
    80002d6e:	f18080e7          	jalr	-232(ra) # 80000c82 <release>
  p->endtime = xticks;
    80002d72:	0004879b          	sext.w	a5,s1
    80002d76:	16f92c23          	sw	a5,376(s2)
  if (p->is_batchproc) {
    80002d7a:	03c92703          	lw	a4,60(s2)
    80002d7e:	16070763          	beqz	a4,80002eec <exit+0x260>
     if ((xticks - p->burst_start) > 0) {
    80002d82:	18492603          	lw	a2,388(s2)
    80002d86:	0e960063          	beq	a2,s1,80002e66 <exit+0x1da>
        num_cpubursts++;
    80002d8a:	00007697          	auipc	a3,0x7
    80002d8e:	2ba68693          	addi	a3,a3,698 # 8000a044 <num_cpubursts>
    80002d92:	4298                	lw	a4,0(a3)
    80002d94:	2705                	addiw	a4,a4,1
    80002d96:	c298                	sw	a4,0(a3)
        cpubursts_tot += (xticks - p->burst_start);
    80002d98:	40c486bb          	subw	a3,s1,a2
    80002d9c:	0006859b          	sext.w	a1,a3
    80002da0:	00007517          	auipc	a0,0x7
    80002da4:	2a050513          	addi	a0,a0,672 # 8000a040 <cpubursts_tot>
    80002da8:	4118                	lw	a4,0(a0)
    80002daa:	9f35                	addw	a4,a4,a3
    80002dac:	c118                	sw	a4,0(a0)
        if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002dae:	00007717          	auipc	a4,0x7
    80002db2:	28e72703          	lw	a4,654(a4) # 8000a03c <cpubursts_max>
    80002db6:	00b77663          	bgeu	a4,a1,80002dc2 <exit+0x136>
    80002dba:	00007717          	auipc	a4,0x7
    80002dbe:	28d72123          	sw	a3,642(a4) # 8000a03c <cpubursts_max>
        if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002dc2:	00007717          	auipc	a4,0x7
    80002dc6:	db672703          	lw	a4,-586(a4) # 80009b78 <cpubursts_min>
    80002dca:	00e5f663          	bgeu	a1,a4,80002dd6 <exit+0x14a>
    80002dce:	00007717          	auipc	a4,0x7
    80002dd2:	dad72523          	sw	a3,-598(a4) # 80009b78 <cpubursts_min>
        if (p->nextburst_estimate > 0) {
    80002dd6:	18892703          	lw	a4,392(s2)
    80002dda:	02e05763          	blez	a4,80002e08 <exit+0x17c>
           estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002dde:	0007051b          	sext.w	a0,a4
    80002de2:	12b56163          	bltu	a0,a1,80002f04 <exit+0x278>
    80002de6:	9e29                	addw	a2,a2,a0
    80002de8:	4096053b          	subw	a0,a2,s1
    80002dec:	00007597          	auipc	a1,0x7
    80002df0:	24058593          	addi	a1,a1,576 # 8000a02c <estimation_error>
    80002df4:	4190                	lw	a2,0(a1)
    80002df6:	9e29                	addw	a2,a2,a0
    80002df8:	c190                	sw	a2,0(a1)
           estimation_error_instance++;
    80002dfa:	00007597          	auipc	a1,0x7
    80002dfe:	22e58593          	addi	a1,a1,558 # 8000a028 <estimation_error_instance>
    80002e02:	4190                	lw	a2,0(a1)
    80002e04:	2605                	addiw	a2,a2,1
    80002e06:	c190                	sw	a2,0(a1)
        p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    80002e08:	4609                	li	a2,2
    80002e0a:	02c7473b          	divw	a4,a4,a2
    80002e0e:	9f35                	addw	a4,a4,a3
    80002e10:	0016d69b          	srliw	a3,a3,0x1
    80002e14:	9f15                	subw	a4,a4,a3
    80002e16:	0007069b          	sext.w	a3,a4
    80002e1a:	18e92423          	sw	a4,392(s2)
        if (p->nextburst_estimate > 0) {
    80002e1e:	04d05463          	blez	a3,80002e66 <exit+0x1da>
           num_cpubursts_est++;
    80002e22:	00007597          	auipc	a1,0x7
    80002e26:	21658593          	addi	a1,a1,534 # 8000a038 <num_cpubursts_est>
    80002e2a:	4190                	lw	a2,0(a1)
    80002e2c:	2605                	addiw	a2,a2,1
    80002e2e:	c190                	sw	a2,0(a1)
           cpubursts_est_tot += p->nextburst_estimate;
    80002e30:	00007597          	auipc	a1,0x7
    80002e34:	20458593          	addi	a1,a1,516 # 8000a034 <cpubursts_est_tot>
    80002e38:	4190                	lw	a2,0(a1)
    80002e3a:	9e39                	addw	a2,a2,a4
    80002e3c:	c190                	sw	a2,0(a1)
           if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002e3e:	00007617          	auipc	a2,0x7
    80002e42:	1f262603          	lw	a2,498(a2) # 8000a030 <cpubursts_est_max>
    80002e46:	00d65663          	bge	a2,a3,80002e52 <exit+0x1c6>
    80002e4a:	00007617          	auipc	a2,0x7
    80002e4e:	1ee62323          	sw	a4,486(a2) # 8000a030 <cpubursts_est_max>
           if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    80002e52:	00007617          	auipc	a2,0x7
    80002e56:	d2262603          	lw	a2,-734(a2) # 80009b74 <cpubursts_est_min>
    80002e5a:	00c6d663          	bge	a3,a2,80002e66 <exit+0x1da>
    80002e5e:	00007697          	auipc	a3,0x7
    80002e62:	d0e6ab23          	sw	a4,-746(a3) # 80009b74 <cpubursts_est_min>
     if (p->stime < batch_start) batch_start = p->stime;
    80002e66:	17492703          	lw	a4,372(s2)
    80002e6a:	00007697          	auipc	a3,0x7
    80002e6e:	d166a683          	lw	a3,-746(a3) # 80009b80 <batch_start>
    80002e72:	00d75663          	bge	a4,a3,80002e7e <exit+0x1f2>
    80002e76:	00007697          	auipc	a3,0x7
    80002e7a:	d0e6a523          	sw	a4,-758(a3) # 80009b80 <batch_start>
     batchsize--;
    80002e7e:	00007617          	auipc	a2,0x7
    80002e82:	1de60613          	addi	a2,a2,478 # 8000a05c <batchsize>
    80002e86:	4214                	lw	a3,0(a2)
    80002e88:	36fd                	addiw	a3,a3,-1
    80002e8a:	0006859b          	sext.w	a1,a3
    80002e8e:	c214                	sw	a3,0(a2)
     turnaround += (p->endtime - p->stime);
    80002e90:	00007697          	auipc	a3,0x7
    80002e94:	1c468693          	addi	a3,a3,452 # 8000a054 <turnaround>
    80002e98:	40e7873b          	subw	a4,a5,a4
    80002e9c:	4290                	lw	a2,0(a3)
    80002e9e:	9f31                	addw	a4,a4,a2
    80002ea0:	c298                	sw	a4,0(a3)
     waiting_tot += p->waittime;
    80002ea2:	00007697          	auipc	a3,0x7
    80002ea6:	1aa68693          	addi	a3,a3,426 # 8000a04c <waiting_tot>
    80002eaa:	17c92603          	lw	a2,380(s2)
    80002eae:	4298                	lw	a4,0(a3)
    80002eb0:	9f31                	addw	a4,a4,a2
    80002eb2:	c298                	sw	a4,0(a3)
     completion_tot += p->endtime;
    80002eb4:	00007697          	auipc	a3,0x7
    80002eb8:	19c68693          	addi	a3,a3,412 # 8000a050 <completion_tot>
    80002ebc:	4298                	lw	a4,0(a3)
    80002ebe:	9f3d                	addw	a4,a4,a5
    80002ec0:	c298                	sw	a4,0(a3)
     if (p->endtime > completion_max) completion_max = p->endtime;
    80002ec2:	00007717          	auipc	a4,0x7
    80002ec6:	18672703          	lw	a4,390(a4) # 8000a048 <completion_max>
    80002eca:	00f75663          	bge	a4,a5,80002ed6 <exit+0x24a>
    80002ece:	00007717          	auipc	a4,0x7
    80002ed2:	16f72d23          	sw	a5,378(a4) # 8000a048 <completion_max>
     if (p->endtime < completion_min) completion_min = p->endtime;
    80002ed6:	00007717          	auipc	a4,0x7
    80002eda:	ca672703          	lw	a4,-858(a4) # 80009b7c <completion_min>
    80002ede:	00e7d663          	bge	a5,a4,80002eea <exit+0x25e>
    80002ee2:	00007717          	auipc	a4,0x7
    80002ee6:	c8f72d23          	sw	a5,-870(a4) # 80009b7c <completion_min>
     if (batchsize == 0) {
    80002eea:	c185                	beqz	a1,80002f0a <exit+0x27e>
  sched();
    80002eec:	fffff097          	auipc	ra,0xfffff
    80002ef0:	63e080e7          	jalr	1598(ra) # 8000252a <sched>
  panic("zombie exit");
    80002ef4:	00006517          	auipc	a0,0x6
    80002ef8:	4b450513          	addi	a0,a0,1204 # 800093a8 <digits+0x368>
    80002efc:	ffffd097          	auipc	ra,0xffffd
    80002f00:	63c080e7          	jalr	1596(ra) # 80000538 <panic>
           estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002f04:	40a6853b          	subw	a0,a3,a0
    80002f08:	b5d5                	j	80002dec <exit+0x160>
        printf("\nBatch execution time: %d\n", p->endtime - batch_start);
    80002f0a:	00007597          	auipc	a1,0x7
    80002f0e:	c765a583          	lw	a1,-906(a1) # 80009b80 <batch_start>
    80002f12:	40b785bb          	subw	a1,a5,a1
    80002f16:	00006517          	auipc	a0,0x6
    80002f1a:	35a50513          	addi	a0,a0,858 # 80009270 <digits+0x230>
    80002f1e:	ffffd097          	auipc	ra,0xffffd
    80002f22:	664080e7          	jalr	1636(ra) # 80000582 <printf>
	printf("Average turn-around time: %d\n", turnaround/batchsize2);
    80002f26:	00007497          	auipc	s1,0x7
    80002f2a:	13248493          	addi	s1,s1,306 # 8000a058 <batchsize2>
    80002f2e:	00007597          	auipc	a1,0x7
    80002f32:	1265a583          	lw	a1,294(a1) # 8000a054 <turnaround>
    80002f36:	409c                	lw	a5,0(s1)
    80002f38:	02f5c5bb          	divw	a1,a1,a5
    80002f3c:	00006517          	auipc	a0,0x6
    80002f40:	35450513          	addi	a0,a0,852 # 80009290 <digits+0x250>
    80002f44:	ffffd097          	auipc	ra,0xffffd
    80002f48:	63e080e7          	jalr	1598(ra) # 80000582 <printf>
	printf("Average waiting time: %d\n", waiting_tot/batchsize2);
    80002f4c:	00007597          	auipc	a1,0x7
    80002f50:	1005a583          	lw	a1,256(a1) # 8000a04c <waiting_tot>
    80002f54:	409c                	lw	a5,0(s1)
    80002f56:	02f5c5bb          	divw	a1,a1,a5
    80002f5a:	00006517          	auipc	a0,0x6
    80002f5e:	35650513          	addi	a0,a0,854 # 800092b0 <digits+0x270>
    80002f62:	ffffd097          	auipc	ra,0xffffd
    80002f66:	620080e7          	jalr	1568(ra) # 80000582 <printf>
	printf("Completion time: avg: %d, max: %d, min: %d\n", completion_tot/batchsize2, completion_max, completion_min);
    80002f6a:	00007597          	auipc	a1,0x7
    80002f6e:	0e65a583          	lw	a1,230(a1) # 8000a050 <completion_tot>
    80002f72:	409c                	lw	a5,0(s1)
    80002f74:	00007697          	auipc	a3,0x7
    80002f78:	c086a683          	lw	a3,-1016(a3) # 80009b7c <completion_min>
    80002f7c:	00007617          	auipc	a2,0x7
    80002f80:	0cc62603          	lw	a2,204(a2) # 8000a048 <completion_max>
    80002f84:	02f5c5bb          	divw	a1,a1,a5
    80002f88:	00006517          	auipc	a0,0x6
    80002f8c:	34850513          	addi	a0,a0,840 # 800092d0 <digits+0x290>
    80002f90:	ffffd097          	auipc	ra,0xffffd
    80002f94:	5f2080e7          	jalr	1522(ra) # 80000582 <printf>
	if ((sched_policy == SCHED_NPREEMPT_FCFS) || (sched_policy == SCHED_NPREEMPT_SJF)) {
    80002f98:	00007717          	auipc	a4,0x7
    80002f9c:	0d072703          	lw	a4,208(a4) # 8000a068 <sched_policy>
    80002fa0:	4785                	li	a5,1
    80002fa2:	08e7fb63          	bgeu	a5,a4,80003038 <exit+0x3ac>
	batchsize2 = 0;
    80002fa6:	00007797          	auipc	a5,0x7
    80002faa:	0a07a923          	sw	zero,178(a5) # 8000a058 <batchsize2>
	batch_start = 0x7FFFFFFF;
    80002fae:	800007b7          	lui	a5,0x80000
    80002fb2:	fff7c793          	not	a5,a5
    80002fb6:	00007717          	auipc	a4,0x7
    80002fba:	bcf72523          	sw	a5,-1078(a4) # 80009b80 <batch_start>
	turnaround = 0;
    80002fbe:	00007717          	auipc	a4,0x7
    80002fc2:	08072b23          	sw	zero,150(a4) # 8000a054 <turnaround>
	waiting_tot = 0;
    80002fc6:	00007717          	auipc	a4,0x7
    80002fca:	08072323          	sw	zero,134(a4) # 8000a04c <waiting_tot>
	completion_tot = 0;
    80002fce:	00007717          	auipc	a4,0x7
    80002fd2:	08072123          	sw	zero,130(a4) # 8000a050 <completion_tot>
	completion_max = 0;
    80002fd6:	00007717          	auipc	a4,0x7
    80002fda:	06072923          	sw	zero,114(a4) # 8000a048 <completion_max>
	completion_min = 0x7FFFFFFF;
    80002fde:	00007717          	auipc	a4,0x7
    80002fe2:	b8f72f23          	sw	a5,-1122(a4) # 80009b7c <completion_min>
	num_cpubursts = 0;
    80002fe6:	00007717          	auipc	a4,0x7
    80002fea:	04072f23          	sw	zero,94(a4) # 8000a044 <num_cpubursts>
        cpubursts_tot = 0;
    80002fee:	00007717          	auipc	a4,0x7
    80002ff2:	04072923          	sw	zero,82(a4) # 8000a040 <cpubursts_tot>
        cpubursts_max = 0;
    80002ff6:	00007717          	auipc	a4,0x7
    80002ffa:	04072323          	sw	zero,70(a4) # 8000a03c <cpubursts_max>
        cpubursts_min = 0x7FFFFFFF;
    80002ffe:	00007717          	auipc	a4,0x7
    80003002:	b6f72d23          	sw	a5,-1158(a4) # 80009b78 <cpubursts_min>
	num_cpubursts_est = 0;
    80003006:	00007717          	auipc	a4,0x7
    8000300a:	02072923          	sw	zero,50(a4) # 8000a038 <num_cpubursts_est>
        cpubursts_est_tot = 0;
    8000300e:	00007717          	auipc	a4,0x7
    80003012:	02072323          	sw	zero,38(a4) # 8000a034 <cpubursts_est_tot>
        cpubursts_est_max = 0;
    80003016:	00007717          	auipc	a4,0x7
    8000301a:	00072d23          	sw	zero,26(a4) # 8000a030 <cpubursts_est_max>
        cpubursts_est_min = 0x7FFFFFFF;
    8000301e:	00007717          	auipc	a4,0x7
    80003022:	b4f72b23          	sw	a5,-1194(a4) # 80009b74 <cpubursts_est_min>
	estimation_error = 0;
    80003026:	00007797          	auipc	a5,0x7
    8000302a:	0007a323          	sw	zero,6(a5) # 8000a02c <estimation_error>
        estimation_error_instance = 0;
    8000302e:	00007797          	auipc	a5,0x7
    80003032:	fe07ad23          	sw	zero,-6(a5) # 8000a028 <estimation_error_instance>
    80003036:	bd5d                	j	80002eec <exit+0x260>
	   printf("CPU bursts: count: %d, avg: %d, max: %d, min: %d\n", num_cpubursts, cpubursts_tot/num_cpubursts, cpubursts_max, cpubursts_min);
    80003038:	00007597          	auipc	a1,0x7
    8000303c:	00c5a583          	lw	a1,12(a1) # 8000a044 <num_cpubursts>
    80003040:	00007617          	auipc	a2,0x7
    80003044:	00062603          	lw	a2,0(a2) # 8000a040 <cpubursts_tot>
    80003048:	00007717          	auipc	a4,0x7
    8000304c:	b3072703          	lw	a4,-1232(a4) # 80009b78 <cpubursts_min>
    80003050:	00007697          	auipc	a3,0x7
    80003054:	fec6a683          	lw	a3,-20(a3) # 8000a03c <cpubursts_max>
    80003058:	02b6463b          	divw	a2,a2,a1
    8000305c:	00006517          	auipc	a0,0x6
    80003060:	2a450513          	addi	a0,a0,676 # 80009300 <digits+0x2c0>
    80003064:	ffffd097          	auipc	ra,0xffffd
    80003068:	51e080e7          	jalr	1310(ra) # 80000582 <printf>
	   printf("CPU burst estimates: count: %d, avg: %d, max: %d, min: %d\n", num_cpubursts_est, cpubursts_est_tot/num_cpubursts_est, cpubursts_est_max, cpubursts_est_min);
    8000306c:	00007597          	auipc	a1,0x7
    80003070:	fcc5a583          	lw	a1,-52(a1) # 8000a038 <num_cpubursts_est>
    80003074:	00007617          	auipc	a2,0x7
    80003078:	fc062603          	lw	a2,-64(a2) # 8000a034 <cpubursts_est_tot>
    8000307c:	00007717          	auipc	a4,0x7
    80003080:	af872703          	lw	a4,-1288(a4) # 80009b74 <cpubursts_est_min>
    80003084:	00007697          	auipc	a3,0x7
    80003088:	fac6a683          	lw	a3,-84(a3) # 8000a030 <cpubursts_est_max>
    8000308c:	02b6463b          	divw	a2,a2,a1
    80003090:	00006517          	auipc	a0,0x6
    80003094:	2a850513          	addi	a0,a0,680 # 80009338 <digits+0x2f8>
    80003098:	ffffd097          	auipc	ra,0xffffd
    8000309c:	4ea080e7          	jalr	1258(ra) # 80000582 <printf>
	   printf("CPU burst estimation error: count: %d, avg: %d\n", estimation_error_instance, estimation_error/estimation_error_instance);
    800030a0:	00007597          	auipc	a1,0x7
    800030a4:	f885a583          	lw	a1,-120(a1) # 8000a028 <estimation_error_instance>
    800030a8:	00007617          	auipc	a2,0x7
    800030ac:	f8462603          	lw	a2,-124(a2) # 8000a02c <estimation_error>
    800030b0:	02b6463b          	divw	a2,a2,a1
    800030b4:	00006517          	auipc	a0,0x6
    800030b8:	2c450513          	addi	a0,a0,708 # 80009378 <digits+0x338>
    800030bc:	ffffd097          	auipc	ra,0xffffd
    800030c0:	4c6080e7          	jalr	1222(ra) # 80000582 <printf>
    800030c4:	b5cd                	j	80002fa6 <exit+0x31a>

00000000800030c6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800030c6:	7179                	addi	sp,sp,-48
    800030c8:	f406                	sd	ra,40(sp)
    800030ca:	f022                	sd	s0,32(sp)
    800030cc:	ec26                	sd	s1,24(sp)
    800030ce:	e84a                	sd	s2,16(sp)
    800030d0:	e44e                	sd	s3,8(sp)
    800030d2:	e052                	sd	s4,0(sp)
    800030d4:	1800                	addi	s0,sp,48
    800030d6:	892a                	mv	s2,a0
  struct proc *p;
  uint xticks;

  acquire(&tickslock);
    800030d8:	00016517          	auipc	a0,0x16
    800030dc:	a3850513          	addi	a0,a0,-1480 # 80018b10 <tickslock>
    800030e0:	ffffe097          	auipc	ra,0xffffe
    800030e4:	aee080e7          	jalr	-1298(ra) # 80000bce <acquire>
  xticks = ticks;
    800030e8:	00007a17          	auipc	s4,0x7
    800030ec:	f84a2a03          	lw	s4,-124(s4) # 8000a06c <ticks>
  release(&tickslock);
    800030f0:	00016517          	auipc	a0,0x16
    800030f4:	a2050513          	addi	a0,a0,-1504 # 80018b10 <tickslock>
    800030f8:	ffffe097          	auipc	ra,0xffffe
    800030fc:	b8a080e7          	jalr	-1142(ra) # 80000c82 <release>

  for(p = proc; p < &proc[NPROC]; p++){
    80003100:	0000f497          	auipc	s1,0xf
    80003104:	61048493          	addi	s1,s1,1552 # 80012710 <proc>
    80003108:	00016997          	auipc	s3,0x16
    8000310c:	a0898993          	addi	s3,s3,-1528 # 80018b10 <tickslock>
    acquire(&p->lock);
    80003110:	8526                	mv	a0,s1
    80003112:	ffffe097          	auipc	ra,0xffffe
    80003116:	abc080e7          	jalr	-1348(ra) # 80000bce <acquire>
    if(p->pid == pid){
    8000311a:	589c                	lw	a5,48(s1)
    8000311c:	01278d63          	beq	a5,s2,80003136 <kill+0x70>
	p->waitstart = xticks;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80003120:	8526                	mv	a0,s1
    80003122:	ffffe097          	auipc	ra,0xffffe
    80003126:	b60080e7          	jalr	-1184(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000312a:	19048493          	addi	s1,s1,400
    8000312e:	ff3491e3          	bne	s1,s3,80003110 <kill+0x4a>
  }
  return -1;
    80003132:	557d                	li	a0,-1
    80003134:	a829                	j	8000314e <kill+0x88>
      p->killed = 1;
    80003136:	4785                	li	a5,1
    80003138:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000313a:	4c98                	lw	a4,24(s1)
    8000313c:	4789                	li	a5,2
    8000313e:	02f70063          	beq	a4,a5,8000315e <kill+0x98>
      release(&p->lock);
    80003142:	8526                	mv	a0,s1
    80003144:	ffffe097          	auipc	ra,0xffffe
    80003148:	b3e080e7          	jalr	-1218(ra) # 80000c82 <release>
      return 0;
    8000314c:	4501                	li	a0,0
}
    8000314e:	70a2                	ld	ra,40(sp)
    80003150:	7402                	ld	s0,32(sp)
    80003152:	64e2                	ld	s1,24(sp)
    80003154:	6942                	ld	s2,16(sp)
    80003156:	69a2                	ld	s3,8(sp)
    80003158:	6a02                	ld	s4,0(sp)
    8000315a:	6145                	addi	sp,sp,48
    8000315c:	8082                	ret
        p->state = RUNNABLE;
    8000315e:	478d                	li	a5,3
    80003160:	cc9c                	sw	a5,24(s1)
	p->waitstart = xticks;
    80003162:	1944a023          	sw	s4,384(s1)
    80003166:	bff1                	j	80003142 <kill+0x7c>

0000000080003168 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80003168:	7179                	addi	sp,sp,-48
    8000316a:	f406                	sd	ra,40(sp)
    8000316c:	f022                	sd	s0,32(sp)
    8000316e:	ec26                	sd	s1,24(sp)
    80003170:	e84a                	sd	s2,16(sp)
    80003172:	e44e                	sd	s3,8(sp)
    80003174:	e052                	sd	s4,0(sp)
    80003176:	1800                	addi	s0,sp,48
    80003178:	84aa                	mv	s1,a0
    8000317a:	892e                	mv	s2,a1
    8000317c:	89b2                	mv	s3,a2
    8000317e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80003180:	fffff097          	auipc	ra,0xfffff
    80003184:	83a080e7          	jalr	-1990(ra) # 800019ba <myproc>
  if(user_dst){
    80003188:	c08d                	beqz	s1,800031aa <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000318a:	86d2                	mv	a3,s4
    8000318c:	864e                	mv	a2,s3
    8000318e:	85ca                	mv	a1,s2
    80003190:	6d28                	ld	a0,88(a0)
    80003192:	ffffe097          	auipc	ra,0xffffe
    80003196:	4ec080e7          	jalr	1260(ra) # 8000167e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000319a:	70a2                	ld	ra,40(sp)
    8000319c:	7402                	ld	s0,32(sp)
    8000319e:	64e2                	ld	s1,24(sp)
    800031a0:	6942                	ld	s2,16(sp)
    800031a2:	69a2                	ld	s3,8(sp)
    800031a4:	6a02                	ld	s4,0(sp)
    800031a6:	6145                	addi	sp,sp,48
    800031a8:	8082                	ret
    memmove((char *)dst, src, len);
    800031aa:	000a061b          	sext.w	a2,s4
    800031ae:	85ce                	mv	a1,s3
    800031b0:	854a                	mv	a0,s2
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	b74080e7          	jalr	-1164(ra) # 80000d26 <memmove>
    return 0;
    800031ba:	8526                	mv	a0,s1
    800031bc:	bff9                	j	8000319a <either_copyout+0x32>

00000000800031be <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800031be:	7179                	addi	sp,sp,-48
    800031c0:	f406                	sd	ra,40(sp)
    800031c2:	f022                	sd	s0,32(sp)
    800031c4:	ec26                	sd	s1,24(sp)
    800031c6:	e84a                	sd	s2,16(sp)
    800031c8:	e44e                	sd	s3,8(sp)
    800031ca:	e052                	sd	s4,0(sp)
    800031cc:	1800                	addi	s0,sp,48
    800031ce:	892a                	mv	s2,a0
    800031d0:	84ae                	mv	s1,a1
    800031d2:	89b2                	mv	s3,a2
    800031d4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	7e4080e7          	jalr	2020(ra) # 800019ba <myproc>
  if(user_src){
    800031de:	c08d                	beqz	s1,80003200 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800031e0:	86d2                	mv	a3,s4
    800031e2:	864e                	mv	a2,s3
    800031e4:	85ca                	mv	a1,s2
    800031e6:	6d28                	ld	a0,88(a0)
    800031e8:	ffffe097          	auipc	ra,0xffffe
    800031ec:	522080e7          	jalr	1314(ra) # 8000170a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800031f0:	70a2                	ld	ra,40(sp)
    800031f2:	7402                	ld	s0,32(sp)
    800031f4:	64e2                	ld	s1,24(sp)
    800031f6:	6942                	ld	s2,16(sp)
    800031f8:	69a2                	ld	s3,8(sp)
    800031fa:	6a02                	ld	s4,0(sp)
    800031fc:	6145                	addi	sp,sp,48
    800031fe:	8082                	ret
    memmove(dst, (char*)src, len);
    80003200:	000a061b          	sext.w	a2,s4
    80003204:	85ce                	mv	a1,s3
    80003206:	854a                	mv	a0,s2
    80003208:	ffffe097          	auipc	ra,0xffffe
    8000320c:	b1e080e7          	jalr	-1250(ra) # 80000d26 <memmove>
    return 0;
    80003210:	8526                	mv	a0,s1
    80003212:	bff9                	j	800031f0 <either_copyin+0x32>

0000000080003214 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80003214:	715d                	addi	sp,sp,-80
    80003216:	e486                	sd	ra,72(sp)
    80003218:	e0a2                	sd	s0,64(sp)
    8000321a:	fc26                	sd	s1,56(sp)
    8000321c:	f84a                	sd	s2,48(sp)
    8000321e:	f44e                	sd	s3,40(sp)
    80003220:	f052                	sd	s4,32(sp)
    80003222:	ec56                	sd	s5,24(sp)
    80003224:	e85a                	sd	s6,16(sp)
    80003226:	e45e                	sd	s7,8(sp)
    80003228:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000322a:	00006517          	auipc	a0,0x6
    8000322e:	56650513          	addi	a0,a0,1382 # 80009790 <syscalls+0x150>
    80003232:	ffffd097          	auipc	ra,0xffffd
    80003236:	350080e7          	jalr	848(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000323a:	0000f497          	auipc	s1,0xf
    8000323e:	63648493          	addi	s1,s1,1590 # 80012870 <proc+0x160>
    80003242:	00016917          	auipc	s2,0x16
    80003246:	a2e90913          	addi	s2,s2,-1490 # 80018c70 <barrier_arr+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000324a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000324c:	00006997          	auipc	s3,0x6
    80003250:	16c98993          	addi	s3,s3,364 # 800093b8 <digits+0x378>
    printf("%d %s %s", p->pid, state, p->name);
    80003254:	00006a97          	auipc	s5,0x6
    80003258:	16ca8a93          	addi	s5,s5,364 # 800093c0 <digits+0x380>
    printf("\n");
    8000325c:	00006a17          	auipc	s4,0x6
    80003260:	534a0a13          	addi	s4,s4,1332 # 80009790 <syscalls+0x150>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003264:	00006b97          	auipc	s7,0x6
    80003268:	1f4b8b93          	addi	s7,s7,500 # 80009458 <states.2>
    8000326c:	a00d                	j	8000328e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000326e:	ed06a583          	lw	a1,-304(a3)
    80003272:	8556                	mv	a0,s5
    80003274:	ffffd097          	auipc	ra,0xffffd
    80003278:	30e080e7          	jalr	782(ra) # 80000582 <printf>
    printf("\n");
    8000327c:	8552                	mv	a0,s4
    8000327e:	ffffd097          	auipc	ra,0xffffd
    80003282:	304080e7          	jalr	772(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80003286:	19048493          	addi	s1,s1,400
    8000328a:	03248263          	beq	s1,s2,800032ae <procdump+0x9a>
    if(p->state == UNUSED)
    8000328e:	86a6                	mv	a3,s1
    80003290:	eb84a783          	lw	a5,-328(s1)
    80003294:	dbed                	beqz	a5,80003286 <procdump+0x72>
      state = "???";
    80003296:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003298:	fcfb6be3          	bltu	s6,a5,8000326e <procdump+0x5a>
    8000329c:	02079713          	slli	a4,a5,0x20
    800032a0:	01d75793          	srli	a5,a4,0x1d
    800032a4:	97de                	add	a5,a5,s7
    800032a6:	6390                	ld	a2,0(a5)
    800032a8:	f279                	bnez	a2,8000326e <procdump+0x5a>
      state = "???";
    800032aa:	864e                	mv	a2,s3
    800032ac:	b7c9                	j	8000326e <procdump+0x5a>
  }
}
    800032ae:	60a6                	ld	ra,72(sp)
    800032b0:	6406                	ld	s0,64(sp)
    800032b2:	74e2                	ld	s1,56(sp)
    800032b4:	7942                	ld	s2,48(sp)
    800032b6:	79a2                	ld	s3,40(sp)
    800032b8:	7a02                	ld	s4,32(sp)
    800032ba:	6ae2                	ld	s5,24(sp)
    800032bc:	6b42                	ld	s6,16(sp)
    800032be:	6ba2                	ld	s7,8(sp)
    800032c0:	6161                	addi	sp,sp,80
    800032c2:	8082                	ret

00000000800032c4 <ps>:

// Print a process listing to console with proper locks held.
// Caution: don't invoke too often; can slow down the machine.
int
ps(void)
{
    800032c4:	7119                	addi	sp,sp,-128
    800032c6:	fc86                	sd	ra,120(sp)
    800032c8:	f8a2                	sd	s0,112(sp)
    800032ca:	f4a6                	sd	s1,104(sp)
    800032cc:	f0ca                	sd	s2,96(sp)
    800032ce:	ecce                	sd	s3,88(sp)
    800032d0:	e8d2                	sd	s4,80(sp)
    800032d2:	e4d6                	sd	s5,72(sp)
    800032d4:	e0da                	sd	s6,64(sp)
    800032d6:	fc5e                	sd	s7,56(sp)
    800032d8:	f862                	sd	s8,48(sp)
    800032da:	f466                	sd	s9,40(sp)
    800032dc:	f06a                	sd	s10,32(sp)
    800032de:	ec6e                	sd	s11,24(sp)
    800032e0:	0100                	addi	s0,sp,128
  struct proc *p;
  char *state;
  int ppid, pid;
  uint xticks;

  printf("\n");
    800032e2:	00006517          	auipc	a0,0x6
    800032e6:	4ae50513          	addi	a0,a0,1198 # 80009790 <syscalls+0x150>
    800032ea:	ffffd097          	auipc	ra,0xffffd
    800032ee:	298080e7          	jalr	664(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800032f2:	0000f497          	auipc	s1,0xf
    800032f6:	41e48493          	addi	s1,s1,1054 # 80012710 <proc>
    acquire(&p->lock);
    if(p->state == UNUSED) {
      release(&p->lock);
      continue;
    }
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800032fa:	4d95                	li	s11,5
    else
      state = "???";

    pid = p->pid;
    release(&p->lock);
    acquire(&wait_lock);
    800032fc:	0000fb97          	auipc	s7,0xf
    80003300:	ffcb8b93          	addi	s7,s7,-4 # 800122f8 <wait_lock>
    if (p->parent) {
       acquire(&p->parent->lock);
       ppid = p->parent->pid;
       release(&p->parent->lock);
    }
    else ppid = -1;
    80003304:	5b7d                	li	s6,-1
    release(&wait_lock);

    acquire(&tickslock);
    80003306:	00016a97          	auipc	s5,0x16
    8000330a:	80aa8a93          	addi	s5,s5,-2038 # 80018b10 <tickslock>
  for(p = proc; p < &proc[NPROC]; p++){
    8000330e:	00016d17          	auipc	s10,0x16
    80003312:	802d0d13          	addi	s10,s10,-2046 # 80018b10 <tickslock>
    80003316:	a85d                	j	800033cc <ps+0x108>
      release(&p->lock);
    80003318:	8526                	mv	a0,s1
    8000331a:	ffffe097          	auipc	ra,0xffffe
    8000331e:	968080e7          	jalr	-1688(ra) # 80000c82 <release>
      continue;
    80003322:	a04d                	j	800033c4 <ps+0x100>
    pid = p->pid;
    80003324:	0304ac03          	lw	s8,48(s1)
    release(&p->lock);
    80003328:	8526                	mv	a0,s1
    8000332a:	ffffe097          	auipc	ra,0xffffe
    8000332e:	958080e7          	jalr	-1704(ra) # 80000c82 <release>
    acquire(&wait_lock);
    80003332:	855e                	mv	a0,s7
    80003334:	ffffe097          	auipc	ra,0xffffe
    80003338:	89a080e7          	jalr	-1894(ra) # 80000bce <acquire>
    if (p->parent) {
    8000333c:	60a8                	ld	a0,64(s1)
    else ppid = -1;
    8000333e:	8a5a                	mv	s4,s6
    if (p->parent) {
    80003340:	cd01                	beqz	a0,80003358 <ps+0x94>
       acquire(&p->parent->lock);
    80003342:	ffffe097          	auipc	ra,0xffffe
    80003346:	88c080e7          	jalr	-1908(ra) # 80000bce <acquire>
       ppid = p->parent->pid;
    8000334a:	60a8                	ld	a0,64(s1)
    8000334c:	03052a03          	lw	s4,48(a0)
       release(&p->parent->lock);
    80003350:	ffffe097          	auipc	ra,0xffffe
    80003354:	932080e7          	jalr	-1742(ra) # 80000c82 <release>
    release(&wait_lock);
    80003358:	855e                	mv	a0,s7
    8000335a:	ffffe097          	auipc	ra,0xffffe
    8000335e:	928080e7          	jalr	-1752(ra) # 80000c82 <release>
    acquire(&tickslock);
    80003362:	8556                	mv	a0,s5
    80003364:	ffffe097          	auipc	ra,0xffffe
    80003368:	86a080e7          	jalr	-1942(ra) # 80000bce <acquire>
    xticks = ticks;
    8000336c:	00007797          	auipc	a5,0x7
    80003370:	d0078793          	addi	a5,a5,-768 # 8000a06c <ticks>
    80003374:	0007ac83          	lw	s9,0(a5)
    release(&tickslock);
    80003378:	8556                	mv	a0,s5
    8000337a:	ffffe097          	auipc	ra,0xffffe
    8000337e:	908080e7          	jalr	-1784(ra) # 80000c82 <release>

    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    80003382:	16090713          	addi	a4,s2,352
    80003386:	1704a783          	lw	a5,368(s1)
    8000338a:	1744a803          	lw	a6,372(s1)
    8000338e:	1784a683          	lw	a3,376(s1)
    80003392:	410688bb          	subw	a7,a3,a6
    80003396:	07668b63          	beq	a3,s6,8000340c <ps+0x148>
    8000339a:	68b4                	ld	a3,80(s1)
    8000339c:	e036                	sd	a3,0(sp)
    8000339e:	86ce                	mv	a3,s3
    800033a0:	8652                	mv	a2,s4
    800033a2:	85e2                	mv	a1,s8
    800033a4:	00006517          	auipc	a0,0x6
    800033a8:	02c50513          	addi	a0,a0,44 # 800093d0 <digits+0x390>
    800033ac:	ffffd097          	auipc	ra,0xffffd
    800033b0:	1d6080e7          	jalr	470(ra) # 80000582 <printf>
    printf("\n");
    800033b4:	00006517          	auipc	a0,0x6
    800033b8:	3dc50513          	addi	a0,a0,988 # 80009790 <syscalls+0x150>
    800033bc:	ffffd097          	auipc	ra,0xffffd
    800033c0:	1c6080e7          	jalr	454(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800033c4:	19048493          	addi	s1,s1,400
    800033c8:	05a48563          	beq	s1,s10,80003412 <ps+0x14e>
    acquire(&p->lock);
    800033cc:	8926                	mv	s2,s1
    800033ce:	8526                	mv	a0,s1
    800033d0:	ffffd097          	auipc	ra,0xffffd
    800033d4:	7fe080e7          	jalr	2046(ra) # 80000bce <acquire>
    if(p->state == UNUSED) {
    800033d8:	4c9c                	lw	a5,24(s1)
    800033da:	df9d                	beqz	a5,80003318 <ps+0x54>
      state = "???";
    800033dc:	00006997          	auipc	s3,0x6
    800033e0:	fdc98993          	addi	s3,s3,-36 # 800093b8 <digits+0x378>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800033e4:	f4fde0e3          	bltu	s11,a5,80003324 <ps+0x60>
    800033e8:	02079713          	slli	a4,a5,0x20
    800033ec:	01d75793          	srli	a5,a4,0x1d
    800033f0:	00006717          	auipc	a4,0x6
    800033f4:	06870713          	addi	a4,a4,104 # 80009458 <states.2>
    800033f8:	97ba                	add	a5,a5,a4
    800033fa:	0307b983          	ld	s3,48(a5)
    800033fe:	f20993e3          	bnez	s3,80003324 <ps+0x60>
      state = "???";
    80003402:	00006997          	auipc	s3,0x6
    80003406:	fb698993          	addi	s3,s3,-74 # 800093b8 <digits+0x378>
    8000340a:	bf29                	j	80003324 <ps+0x60>
    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    8000340c:	410c88bb          	subw	a7,s9,a6
    80003410:	b769                	j	8000339a <ps+0xd6>
  }
  return 0;
}
    80003412:	4501                	li	a0,0
    80003414:	70e6                	ld	ra,120(sp)
    80003416:	7446                	ld	s0,112(sp)
    80003418:	74a6                	ld	s1,104(sp)
    8000341a:	7906                	ld	s2,96(sp)
    8000341c:	69e6                	ld	s3,88(sp)
    8000341e:	6a46                	ld	s4,80(sp)
    80003420:	6aa6                	ld	s5,72(sp)
    80003422:	6b06                	ld	s6,64(sp)
    80003424:	7be2                	ld	s7,56(sp)
    80003426:	7c42                	ld	s8,48(sp)
    80003428:	7ca2                	ld	s9,40(sp)
    8000342a:	7d02                	ld	s10,32(sp)
    8000342c:	6de2                	ld	s11,24(sp)
    8000342e:	6109                	addi	sp,sp,128
    80003430:	8082                	ret

0000000080003432 <pinfo>:

int
pinfo(int pid, uint64 addr)
{
    80003432:	7159                	addi	sp,sp,-112
    80003434:	f486                	sd	ra,104(sp)
    80003436:	f0a2                	sd	s0,96(sp)
    80003438:	eca6                	sd	s1,88(sp)
    8000343a:	e8ca                	sd	s2,80(sp)
    8000343c:	e4ce                	sd	s3,72(sp)
    8000343e:	e0d2                	sd	s4,64(sp)
    80003440:	1880                	addi	s0,sp,112
    80003442:	892a                	mv	s2,a0
    80003444:	89ae                	mv	s3,a1
  struct proc *p;
  char *state;
  uint xticks;
  int found=0;

  if (pid == -1) {
    80003446:	57fd                	li	a5,-1
     p = myproc();
     acquire(&p->lock);
     found=1;
  }
  else {
     for(p = proc; p < &proc[NPROC]; p++){
    80003448:	0000f497          	auipc	s1,0xf
    8000344c:	2c848493          	addi	s1,s1,712 # 80012710 <proc>
    80003450:	00015a17          	auipc	s4,0x15
    80003454:	6c0a0a13          	addi	s4,s4,1728 # 80018b10 <tickslock>
  if (pid == -1) {
    80003458:	02f51563          	bne	a0,a5,80003482 <pinfo+0x50>
     p = myproc();
    8000345c:	ffffe097          	auipc	ra,0xffffe
    80003460:	55e080e7          	jalr	1374(ra) # 800019ba <myproc>
    80003464:	84aa                	mv	s1,a0
     acquire(&p->lock);
    80003466:	ffffd097          	auipc	ra,0xffffd
    8000346a:	768080e7          	jalr	1896(ra) # 80000bce <acquire>
         found=1;
         break;
       }
     }
  }
  if (found) {
    8000346e:	a025                	j	80003496 <pinfo+0x64>
         release(&p->lock);
    80003470:	8526                	mv	a0,s1
    80003472:	ffffe097          	auipc	ra,0xffffe
    80003476:	810080e7          	jalr	-2032(ra) # 80000c82 <release>
     for(p = proc; p < &proc[NPROC]; p++){
    8000347a:	19048493          	addi	s1,s1,400
    8000347e:	13448e63          	beq	s1,s4,800035ba <pinfo+0x188>
       acquire(&p->lock);
    80003482:	8526                	mv	a0,s1
    80003484:	ffffd097          	auipc	ra,0xffffd
    80003488:	74a080e7          	jalr	1866(ra) # 80000bce <acquire>
       if((p->state == UNUSED) || (p->pid != pid)) {
    8000348c:	4c9c                	lw	a5,24(s1)
    8000348e:	d3ed                	beqz	a5,80003470 <pinfo+0x3e>
    80003490:	589c                	lw	a5,48(s1)
    80003492:	fd279fe3          	bne	a5,s2,80003470 <pinfo+0x3e>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003496:	4c9c                	lw	a5,24(s1)
    80003498:	4715                	li	a4,5
         state = states[p->state];
     else
         state = "???";
    8000349a:	00006917          	auipc	s2,0x6
    8000349e:	f1e90913          	addi	s2,s2,-226 # 800093b8 <digits+0x378>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800034a2:	00f76f63          	bltu	a4,a5,800034c0 <pinfo+0x8e>
    800034a6:	02079713          	slli	a4,a5,0x20
    800034aa:	01d75793          	srli	a5,a4,0x1d
    800034ae:	00006717          	auipc	a4,0x6
    800034b2:	faa70713          	addi	a4,a4,-86 # 80009458 <states.2>
    800034b6:	97ba                	add	a5,a5,a4
    800034b8:	0607b903          	ld	s2,96(a5)
    800034bc:	10090163          	beqz	s2,800035be <pinfo+0x18c>

     pstat.pid = p->pid;
    800034c0:	589c                	lw	a5,48(s1)
    800034c2:	f8f42c23          	sw	a5,-104(s0)
     release(&p->lock);
    800034c6:	8526                	mv	a0,s1
    800034c8:	ffffd097          	auipc	ra,0xffffd
    800034cc:	7ba080e7          	jalr	1978(ra) # 80000c82 <release>
     acquire(&wait_lock);
    800034d0:	0000f517          	auipc	a0,0xf
    800034d4:	e2850513          	addi	a0,a0,-472 # 800122f8 <wait_lock>
    800034d8:	ffffd097          	auipc	ra,0xffffd
    800034dc:	6f6080e7          	jalr	1782(ra) # 80000bce <acquire>
     if (p->parent) {
    800034e0:	60a8                	ld	a0,64(s1)
    800034e2:	c17d                	beqz	a0,800035c8 <pinfo+0x196>
        acquire(&p->parent->lock);
    800034e4:	ffffd097          	auipc	ra,0xffffd
    800034e8:	6ea080e7          	jalr	1770(ra) # 80000bce <acquire>
        pstat.ppid = p->parent->pid;
    800034ec:	60a8                	ld	a0,64(s1)
    800034ee:	591c                	lw	a5,48(a0)
    800034f0:	f8f42e23          	sw	a5,-100(s0)
        release(&p->parent->lock);
    800034f4:	ffffd097          	auipc	ra,0xffffd
    800034f8:	78e080e7          	jalr	1934(ra) # 80000c82 <release>
     }
     else pstat.ppid = -1;
     release(&wait_lock);
    800034fc:	0000f517          	auipc	a0,0xf
    80003500:	dfc50513          	addi	a0,a0,-516 # 800122f8 <wait_lock>
    80003504:	ffffd097          	auipc	ra,0xffffd
    80003508:	77e080e7          	jalr	1918(ra) # 80000c82 <release>

     acquire(&tickslock);
    8000350c:	00015517          	auipc	a0,0x15
    80003510:	60450513          	addi	a0,a0,1540 # 80018b10 <tickslock>
    80003514:	ffffd097          	auipc	ra,0xffffd
    80003518:	6ba080e7          	jalr	1722(ra) # 80000bce <acquire>
     xticks = ticks;
    8000351c:	00007a17          	auipc	s4,0x7
    80003520:	b50a2a03          	lw	s4,-1200(s4) # 8000a06c <ticks>
     release(&tickslock);
    80003524:	00015517          	auipc	a0,0x15
    80003528:	5ec50513          	addi	a0,a0,1516 # 80018b10 <tickslock>
    8000352c:	ffffd097          	auipc	ra,0xffffd
    80003530:	756080e7          	jalr	1878(ra) # 80000c82 <release>

     safestrcpy(&pstat.state[0], state, strlen(state)+1);
    80003534:	854a                	mv	a0,s2
    80003536:	ffffe097          	auipc	ra,0xffffe
    8000353a:	910080e7          	jalr	-1776(ra) # 80000e46 <strlen>
    8000353e:	0015061b          	addiw	a2,a0,1
    80003542:	85ca                	mv	a1,s2
    80003544:	fa040513          	addi	a0,s0,-96
    80003548:	ffffe097          	auipc	ra,0xffffe
    8000354c:	8cc080e7          	jalr	-1844(ra) # 80000e14 <safestrcpy>
     safestrcpy(&pstat.command[0], &p->name[0], sizeof(p->name));
    80003550:	4641                	li	a2,16
    80003552:	16048593          	addi	a1,s1,352
    80003556:	fa840513          	addi	a0,s0,-88
    8000355a:	ffffe097          	auipc	ra,0xffffe
    8000355e:	8ba080e7          	jalr	-1862(ra) # 80000e14 <safestrcpy>
     pstat.ctime = p->ctime;
    80003562:	1704a783          	lw	a5,368(s1)
    80003566:	faf42c23          	sw	a5,-72(s0)
     pstat.stime = p->stime;
    8000356a:	1744a783          	lw	a5,372(s1)
    8000356e:	faf42e23          	sw	a5,-68(s0)
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    80003572:	1784a703          	lw	a4,376(s1)
    80003576:	567d                	li	a2,-1
    80003578:	40f706bb          	subw	a3,a4,a5
    8000357c:	04c70a63          	beq	a4,a2,800035d0 <pinfo+0x19e>
    80003580:	fcd42023          	sw	a3,-64(s0)
     pstat.size = p->sz;
    80003584:	68bc                	ld	a5,80(s1)
    80003586:	fcf43423          	sd	a5,-56(s0)
     if(copyout(myproc()->pagetable, addr, (char *)&pstat, sizeof(pstat)) < 0) return -1;
    8000358a:	ffffe097          	auipc	ra,0xffffe
    8000358e:	430080e7          	jalr	1072(ra) # 800019ba <myproc>
    80003592:	03800693          	li	a3,56
    80003596:	f9840613          	addi	a2,s0,-104
    8000359a:	85ce                	mv	a1,s3
    8000359c:	6d28                	ld	a0,88(a0)
    8000359e:	ffffe097          	auipc	ra,0xffffe
    800035a2:	0e0080e7          	jalr	224(ra) # 8000167e <copyout>
    800035a6:	41f5551b          	sraiw	a0,a0,0x1f
     return 0;
  }
  else return -1;
}
    800035aa:	70a6                	ld	ra,104(sp)
    800035ac:	7406                	ld	s0,96(sp)
    800035ae:	64e6                	ld	s1,88(sp)
    800035b0:	6946                	ld	s2,80(sp)
    800035b2:	69a6                	ld	s3,72(sp)
    800035b4:	6a06                	ld	s4,64(sp)
    800035b6:	6165                	addi	sp,sp,112
    800035b8:	8082                	ret
  else return -1;
    800035ba:	557d                	li	a0,-1
    800035bc:	b7fd                	j	800035aa <pinfo+0x178>
         state = "???";
    800035be:	00006917          	auipc	s2,0x6
    800035c2:	dfa90913          	addi	s2,s2,-518 # 800093b8 <digits+0x378>
    800035c6:	bded                	j	800034c0 <pinfo+0x8e>
     else pstat.ppid = -1;
    800035c8:	57fd                	li	a5,-1
    800035ca:	f8f42e23          	sw	a5,-100(s0)
    800035ce:	b73d                	j	800034fc <pinfo+0xca>
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    800035d0:	40fa06bb          	subw	a3,s4,a5
    800035d4:	b775                	j	80003580 <pinfo+0x14e>

00000000800035d6 <schedpolicy>:

int
schedpolicy(int x)
{
    800035d6:	1141                	addi	sp,sp,-16
    800035d8:	e422                	sd	s0,8(sp)
    800035da:	0800                	addi	s0,sp,16
   int y = sched_policy;
    800035dc:	00007797          	auipc	a5,0x7
    800035e0:	a8c78793          	addi	a5,a5,-1396 # 8000a068 <sched_policy>
    800035e4:	4398                	lw	a4,0(a5)
   sched_policy = x;
    800035e6:	c388                	sw	a0,0(a5)
   return y;
}
    800035e8:	853a                	mv	a0,a4
    800035ea:	6422                	ld	s0,8(sp)
    800035ec:	0141                	addi	sp,sp,16
    800035ee:	8082                	ret

00000000800035f0 <condsleep>:

void
condsleep(struct cond_t *chan, struct sleeplock *lk)
{
    800035f0:	7179                	addi	sp,sp,-48
    800035f2:	f406                	sd	ra,40(sp)
    800035f4:	f022                	sd	s0,32(sp)
    800035f6:	ec26                	sd	s1,24(sp)
    800035f8:	e84a                	sd	s2,16(sp)
    800035fa:	e44e                	sd	s3,8(sp)
    800035fc:	1800                	addi	s0,sp,48
    800035fe:	89aa                	mv	s3,a0
    80003600:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003602:	ffffe097          	auipc	ra,0xffffe
    80003606:	3b8080e7          	jalr	952(ra) # 800019ba <myproc>
    8000360a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000360c:	ffffd097          	auipc	ra,0xffffd
    80003610:	5c2080e7          	jalr	1474(ra) # 80000bce <acquire>
  releasesleep(lk);
    80003614:	854a                	mv	a0,s2
    80003616:	00002097          	auipc	ra,0x2
    8000361a:	69e080e7          	jalr	1694(ra) # 80005cb4 <releasesleep>

  // Go to sleep.
  p->chan = chan;
    8000361e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80003622:	4789                	li	a5,2
    80003624:	cc9c                	sw	a5,24(s1)

  sched();
    80003626:	fffff097          	auipc	ra,0xfffff
    8000362a:	f04080e7          	jalr	-252(ra) # 8000252a <sched>

  // Tidy up.
  p->chan = 0;
    8000362e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80003632:	8526                	mv	a0,s1
    80003634:	ffffd097          	auipc	ra,0xffffd
    80003638:	64e080e7          	jalr	1614(ra) # 80000c82 <release>
  acquiresleep(lk);
    8000363c:	854a                	mv	a0,s2
    8000363e:	00002097          	auipc	ra,0x2
    80003642:	620080e7          	jalr	1568(ra) # 80005c5e <acquiresleep>
}
    80003646:	70a2                	ld	ra,40(sp)
    80003648:	7402                	ld	s0,32(sp)
    8000364a:	64e2                	ld	s1,24(sp)
    8000364c:	6942                	ld	s2,16(sp)
    8000364e:	69a2                	ld	s3,8(sp)
    80003650:	6145                	addi	sp,sp,48
    80003652:	8082                	ret

0000000080003654 <wakeupone>:

void
wakeupone(struct cond_t *chan)
{
    80003654:	7179                	addi	sp,sp,-48
    80003656:	f406                	sd	ra,40(sp)
    80003658:	f022                	sd	s0,32(sp)
    8000365a:	ec26                	sd	s1,24(sp)
    8000365c:	e84a                	sd	s2,16(sp)
    8000365e:	e44e                	sd	s3,8(sp)
    80003660:	e052                	sd	s4,0(sp)
    80003662:	1800                	addi	s0,sp,48
    80003664:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80003666:	0000f497          	auipc	s1,0xf
    8000366a:	0aa48493          	addi	s1,s1,170 # 80012710 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000366e:	4989                	li	s3,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80003670:	00015917          	auipc	s2,0x15
    80003674:	4a090913          	addi	s2,s2,1184 # 80018b10 <tickslock>
    80003678:	a811                	j	8000368c <wakeupone+0x38>
        p->state = RUNNABLE;
        release(&p->lock);
        break;
      }
      release(&p->lock);
    8000367a:	8526                	mv	a0,s1
    8000367c:	ffffd097          	auipc	ra,0xffffd
    80003680:	606080e7          	jalr	1542(ra) # 80000c82 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80003684:	19048493          	addi	s1,s1,400
    80003688:	03248a63          	beq	s1,s2,800036bc <wakeupone+0x68>
    if(p != myproc()){
    8000368c:	ffffe097          	auipc	ra,0xffffe
    80003690:	32e080e7          	jalr	814(ra) # 800019ba <myproc>
    80003694:	fea488e3          	beq	s1,a0,80003684 <wakeupone+0x30>
      acquire(&p->lock);
    80003698:	8526                	mv	a0,s1
    8000369a:	ffffd097          	auipc	ra,0xffffd
    8000369e:	534080e7          	jalr	1332(ra) # 80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800036a2:	4c9c                	lw	a5,24(s1)
    800036a4:	fd379be3          	bne	a5,s3,8000367a <wakeupone+0x26>
    800036a8:	709c                	ld	a5,32(s1)
    800036aa:	fd4798e3          	bne	a5,s4,8000367a <wakeupone+0x26>
        p->state = RUNNABLE;
    800036ae:	478d                	li	a5,3
    800036b0:	cc9c                	sw	a5,24(s1)
        release(&p->lock);
    800036b2:	8526                	mv	a0,s1
    800036b4:	ffffd097          	auipc	ra,0xffffd
    800036b8:	5ce080e7          	jalr	1486(ra) # 80000c82 <release>
    }
  }
    800036bc:	70a2                	ld	ra,40(sp)
    800036be:	7402                	ld	s0,32(sp)
    800036c0:	64e2                	ld	s1,24(sp)
    800036c2:	6942                	ld	s2,16(sp)
    800036c4:	69a2                	ld	s3,8(sp)
    800036c6:	6a02                	ld	s4,0(sp)
    800036c8:	6145                	addi	sp,sp,48
    800036ca:	8082                	ret

00000000800036cc <swtch>:
    800036cc:	00153023          	sd	ra,0(a0)
    800036d0:	00253423          	sd	sp,8(a0)
    800036d4:	e900                	sd	s0,16(a0)
    800036d6:	ed04                	sd	s1,24(a0)
    800036d8:	03253023          	sd	s2,32(a0)
    800036dc:	03353423          	sd	s3,40(a0)
    800036e0:	03453823          	sd	s4,48(a0)
    800036e4:	03553c23          	sd	s5,56(a0)
    800036e8:	05653023          	sd	s6,64(a0)
    800036ec:	05753423          	sd	s7,72(a0)
    800036f0:	05853823          	sd	s8,80(a0)
    800036f4:	05953c23          	sd	s9,88(a0)
    800036f8:	07a53023          	sd	s10,96(a0)
    800036fc:	07b53423          	sd	s11,104(a0)
    80003700:	0005b083          	ld	ra,0(a1)
    80003704:	0085b103          	ld	sp,8(a1)
    80003708:	6980                	ld	s0,16(a1)
    8000370a:	6d84                	ld	s1,24(a1)
    8000370c:	0205b903          	ld	s2,32(a1)
    80003710:	0285b983          	ld	s3,40(a1)
    80003714:	0305ba03          	ld	s4,48(a1)
    80003718:	0385ba83          	ld	s5,56(a1)
    8000371c:	0405bb03          	ld	s6,64(a1)
    80003720:	0485bb83          	ld	s7,72(a1)
    80003724:	0505bc03          	ld	s8,80(a1)
    80003728:	0585bc83          	ld	s9,88(a1)
    8000372c:	0605bd03          	ld	s10,96(a1)
    80003730:	0685bd83          	ld	s11,104(a1)
    80003734:	8082                	ret

0000000080003736 <trapinit>:

extern int sched_policy;

void
trapinit(void)
{
    80003736:	1141                	addi	sp,sp,-16
    80003738:	e406                	sd	ra,8(sp)
    8000373a:	e022                	sd	s0,0(sp)
    8000373c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000373e:	00006597          	auipc	a1,0x6
    80003742:	daa58593          	addi	a1,a1,-598 # 800094e8 <states.0+0x30>
    80003746:	00015517          	auipc	a0,0x15
    8000374a:	3ca50513          	addi	a0,a0,970 # 80018b10 <tickslock>
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	3f0080e7          	jalr	1008(ra) # 80000b3e <initlock>
}
    80003756:	60a2                	ld	ra,8(sp)
    80003758:	6402                	ld	s0,0(sp)
    8000375a:	0141                	addi	sp,sp,16
    8000375c:	8082                	ret

000000008000375e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000375e:	1141                	addi	sp,sp,-16
    80003760:	e422                	sd	s0,8(sp)
    80003762:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003764:	00004797          	auipc	a5,0x4
    80003768:	cfc78793          	addi	a5,a5,-772 # 80007460 <kernelvec>
    8000376c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003770:	6422                	ld	s0,8(sp)
    80003772:	0141                	addi	sp,sp,16
    80003774:	8082                	ret

0000000080003776 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80003776:	1141                	addi	sp,sp,-16
    80003778:	e406                	sd	ra,8(sp)
    8000377a:	e022                	sd	s0,0(sp)
    8000377c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000377e:	ffffe097          	auipc	ra,0xffffe
    80003782:	23c080e7          	jalr	572(ra) # 800019ba <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003786:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000378a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000378c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003790:	00005697          	auipc	a3,0x5
    80003794:	87068693          	addi	a3,a3,-1936 # 80008000 <_trampoline>
    80003798:	00005717          	auipc	a4,0x5
    8000379c:	86870713          	addi	a4,a4,-1944 # 80008000 <_trampoline>
    800037a0:	8f15                	sub	a4,a4,a3
    800037a2:	040007b7          	lui	a5,0x4000
    800037a6:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800037a8:	07b2                	slli	a5,a5,0xc
    800037aa:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800037ac:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800037b0:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800037b2:	18002673          	csrr	a2,satp
    800037b6:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800037b8:	7130                	ld	a2,96(a0)
    800037ba:	6538                	ld	a4,72(a0)
    800037bc:	6585                	lui	a1,0x1
    800037be:	972e                	add	a4,a4,a1
    800037c0:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800037c2:	7138                	ld	a4,96(a0)
    800037c4:	00000617          	auipc	a2,0x0
    800037c8:	13860613          	addi	a2,a2,312 # 800038fc <usertrap>
    800037cc:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800037ce:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800037d0:	8612                	mv	a2,tp
    800037d2:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800037d4:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800037d8:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800037dc:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800037e0:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800037e4:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800037e6:	6f18                	ld	a4,24(a4)
    800037e8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800037ec:	6d2c                	ld	a1,88(a0)
    800037ee:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800037f0:	00005717          	auipc	a4,0x5
    800037f4:	8a070713          	addi	a4,a4,-1888 # 80008090 <userret>
    800037f8:	8f15                	sub	a4,a4,a3
    800037fa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800037fc:	577d                	li	a4,-1
    800037fe:	177e                	slli	a4,a4,0x3f
    80003800:	8dd9                	or	a1,a1,a4
    80003802:	02000537          	lui	a0,0x2000
    80003806:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80003808:	0536                	slli	a0,a0,0xd
    8000380a:	9782                	jalr	a5
}
    8000380c:	60a2                	ld	ra,8(sp)
    8000380e:	6402                	ld	s0,0(sp)
    80003810:	0141                	addi	sp,sp,16
    80003812:	8082                	ret

0000000080003814 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80003814:	1101                	addi	sp,sp,-32
    80003816:	ec06                	sd	ra,24(sp)
    80003818:	e822                	sd	s0,16(sp)
    8000381a:	e426                	sd	s1,8(sp)
    8000381c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000381e:	00015497          	auipc	s1,0x15
    80003822:	2f248493          	addi	s1,s1,754 # 80018b10 <tickslock>
    80003826:	8526                	mv	a0,s1
    80003828:	ffffd097          	auipc	ra,0xffffd
    8000382c:	3a6080e7          	jalr	934(ra) # 80000bce <acquire>
  ticks++;
    80003830:	00007517          	auipc	a0,0x7
    80003834:	83c50513          	addi	a0,a0,-1988 # 8000a06c <ticks>
    80003838:	411c                	lw	a5,0(a0)
    8000383a:	2785                	addiw	a5,a5,1
    8000383c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000383e:	fffff097          	auipc	ra,0xfffff
    80003842:	332080e7          	jalr	818(ra) # 80002b70 <wakeup>
  release(&tickslock);
    80003846:	8526                	mv	a0,s1
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	43a080e7          	jalr	1082(ra) # 80000c82 <release>
}
    80003850:	60e2                	ld	ra,24(sp)
    80003852:	6442                	ld	s0,16(sp)
    80003854:	64a2                	ld	s1,8(sp)
    80003856:	6105                	addi	sp,sp,32
    80003858:	8082                	ret

000000008000385a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000385a:	1101                	addi	sp,sp,-32
    8000385c:	ec06                	sd	ra,24(sp)
    8000385e:	e822                	sd	s0,16(sp)
    80003860:	e426                	sd	s1,8(sp)
    80003862:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003864:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80003868:	00074d63          	bltz	a4,80003882 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000386c:	57fd                	li	a5,-1
    8000386e:	17fe                	slli	a5,a5,0x3f
    80003870:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80003872:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80003874:	06f70363          	beq	a4,a5,800038da <devintr+0x80>
  }
}
    80003878:	60e2                	ld	ra,24(sp)
    8000387a:	6442                	ld	s0,16(sp)
    8000387c:	64a2                	ld	s1,8(sp)
    8000387e:	6105                	addi	sp,sp,32
    80003880:	8082                	ret
     (scause & 0xff) == 9){
    80003882:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80003886:	46a5                	li	a3,9
    80003888:	fed792e3          	bne	a5,a3,8000386c <devintr+0x12>
    int irq = plic_claim();
    8000388c:	00004097          	auipc	ra,0x4
    80003890:	cdc080e7          	jalr	-804(ra) # 80007568 <plic_claim>
    80003894:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003896:	47a9                	li	a5,10
    80003898:	02f50763          	beq	a0,a5,800038c6 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000389c:	4785                	li	a5,1
    8000389e:	02f50963          	beq	a0,a5,800038d0 <devintr+0x76>
    return 1;
    800038a2:	4505                	li	a0,1
    } else if(irq){
    800038a4:	d8f1                	beqz	s1,80003878 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800038a6:	85a6                	mv	a1,s1
    800038a8:	00006517          	auipc	a0,0x6
    800038ac:	c4850513          	addi	a0,a0,-952 # 800094f0 <states.0+0x38>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	cd2080e7          	jalr	-814(ra) # 80000582 <printf>
      plic_complete(irq);
    800038b8:	8526                	mv	a0,s1
    800038ba:	00004097          	auipc	ra,0x4
    800038be:	cd2080e7          	jalr	-814(ra) # 8000758c <plic_complete>
    return 1;
    800038c2:	4505                	li	a0,1
    800038c4:	bf55                	j	80003878 <devintr+0x1e>
      uartintr();
    800038c6:	ffffd097          	auipc	ra,0xffffd
    800038ca:	0ca080e7          	jalr	202(ra) # 80000990 <uartintr>
    800038ce:	b7ed                	j	800038b8 <devintr+0x5e>
      virtio_disk_intr();
    800038d0:	00004097          	auipc	ra,0x4
    800038d4:	148080e7          	jalr	328(ra) # 80007a18 <virtio_disk_intr>
    800038d8:	b7c5                	j	800038b8 <devintr+0x5e>
    if(cpuid() == 0){
    800038da:	ffffe097          	auipc	ra,0xffffe
    800038de:	0b4080e7          	jalr	180(ra) # 8000198e <cpuid>
    800038e2:	c901                	beqz	a0,800038f2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800038e4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800038e8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800038ea:	14479073          	csrw	sip,a5
    return 2;
    800038ee:	4509                	li	a0,2
    800038f0:	b761                	j	80003878 <devintr+0x1e>
      clockintr();
    800038f2:	00000097          	auipc	ra,0x0
    800038f6:	f22080e7          	jalr	-222(ra) # 80003814 <clockintr>
    800038fa:	b7ed                	j	800038e4 <devintr+0x8a>

00000000800038fc <usertrap>:
{
    800038fc:	1101                	addi	sp,sp,-32
    800038fe:	ec06                	sd	ra,24(sp)
    80003900:	e822                	sd	s0,16(sp)
    80003902:	e426                	sd	s1,8(sp)
    80003904:	e04a                	sd	s2,0(sp)
    80003906:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003908:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000390c:	1007f793          	andi	a5,a5,256
    80003910:	e3ad                	bnez	a5,80003972 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003912:	00004797          	auipc	a5,0x4
    80003916:	b4e78793          	addi	a5,a5,-1202 # 80007460 <kernelvec>
    8000391a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000391e:	ffffe097          	auipc	ra,0xffffe
    80003922:	09c080e7          	jalr	156(ra) # 800019ba <myproc>
    80003926:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003928:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000392a:	14102773          	csrr	a4,sepc
    8000392e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003930:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003934:	47a1                	li	a5,8
    80003936:	04f71c63          	bne	a4,a5,8000398e <usertrap+0x92>
    if(p->killed)
    8000393a:	551c                	lw	a5,40(a0)
    8000393c:	e3b9                	bnez	a5,80003982 <usertrap+0x86>
    p->trapframe->epc += 4;
    8000393e:	70b8                	ld	a4,96(s1)
    80003940:	6f1c                	ld	a5,24(a4)
    80003942:	0791                	addi	a5,a5,4
    80003944:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003946:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000394a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000394e:	10079073          	csrw	sstatus,a5
    syscall();
    80003952:	00000097          	auipc	ra,0x0
    80003956:	2fc080e7          	jalr	764(ra) # 80003c4e <syscall>
  if(p->killed)
    8000395a:	549c                	lw	a5,40(s1)
    8000395c:	efd9                	bnez	a5,800039fa <usertrap+0xfe>
  usertrapret();
    8000395e:	00000097          	auipc	ra,0x0
    80003962:	e18080e7          	jalr	-488(ra) # 80003776 <usertrapret>
}
    80003966:	60e2                	ld	ra,24(sp)
    80003968:	6442                	ld	s0,16(sp)
    8000396a:	64a2                	ld	s1,8(sp)
    8000396c:	6902                	ld	s2,0(sp)
    8000396e:	6105                	addi	sp,sp,32
    80003970:	8082                	ret
    panic("usertrap: not from user mode");
    80003972:	00006517          	auipc	a0,0x6
    80003976:	b9e50513          	addi	a0,a0,-1122 # 80009510 <states.0+0x58>
    8000397a:	ffffd097          	auipc	ra,0xffffd
    8000397e:	bbe080e7          	jalr	-1090(ra) # 80000538 <panic>
      exit(-1);
    80003982:	557d                	li	a0,-1
    80003984:	fffff097          	auipc	ra,0xfffff
    80003988:	308080e7          	jalr	776(ra) # 80002c8c <exit>
    8000398c:	bf4d                	j	8000393e <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    8000398e:	00000097          	auipc	ra,0x0
    80003992:	ecc080e7          	jalr	-308(ra) # 8000385a <devintr>
    80003996:	892a                	mv	s2,a0
    80003998:	c501                	beqz	a0,800039a0 <usertrap+0xa4>
  if(p->killed)
    8000399a:	549c                	lw	a5,40(s1)
    8000399c:	c3a1                	beqz	a5,800039dc <usertrap+0xe0>
    8000399e:	a815                	j	800039d2 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800039a0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800039a4:	5890                	lw	a2,48(s1)
    800039a6:	00006517          	auipc	a0,0x6
    800039aa:	b8a50513          	addi	a0,a0,-1142 # 80009530 <states.0+0x78>
    800039ae:	ffffd097          	auipc	ra,0xffffd
    800039b2:	bd4080e7          	jalr	-1068(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800039b6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800039ba:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800039be:	00006517          	auipc	a0,0x6
    800039c2:	ba250513          	addi	a0,a0,-1118 # 80009560 <states.0+0xa8>
    800039c6:	ffffd097          	auipc	ra,0xffffd
    800039ca:	bbc080e7          	jalr	-1092(ra) # 80000582 <printf>
    p->killed = 1;
    800039ce:	4785                	li	a5,1
    800039d0:	d49c                	sw	a5,40(s1)
    exit(-1);
    800039d2:	557d                	li	a0,-1
    800039d4:	fffff097          	auipc	ra,0xfffff
    800039d8:	2b8080e7          	jalr	696(ra) # 80002c8c <exit>
  if(which_dev == 2) {
    800039dc:	4789                	li	a5,2
    800039de:	f8f910e3          	bne	s2,a5,8000395e <usertrap+0x62>
    if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_NPREEMPT_SJF)) yield();
    800039e2:	00006717          	auipc	a4,0x6
    800039e6:	68672703          	lw	a4,1670(a4) # 8000a068 <sched_policy>
    800039ea:	4785                	li	a5,1
    800039ec:	f6e7f9e3          	bgeu	a5,a4,8000395e <usertrap+0x62>
    800039f0:	fffff097          	auipc	ra,0xfffff
    800039f4:	c10080e7          	jalr	-1008(ra) # 80002600 <yield>
    800039f8:	b79d                	j	8000395e <usertrap+0x62>
  int which_dev = 0;
    800039fa:	4901                	li	s2,0
    800039fc:	bfd9                	j	800039d2 <usertrap+0xd6>

00000000800039fe <kerneltrap>:
{
    800039fe:	7179                	addi	sp,sp,-48
    80003a00:	f406                	sd	ra,40(sp)
    80003a02:	f022                	sd	s0,32(sp)
    80003a04:	ec26                	sd	s1,24(sp)
    80003a06:	e84a                	sd	s2,16(sp)
    80003a08:	e44e                	sd	s3,8(sp)
    80003a0a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003a0c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003a10:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003a14:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003a18:	1004f793          	andi	a5,s1,256
    80003a1c:	cb85                	beqz	a5,80003a4c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003a1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003a22:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003a24:	ef85                	bnez	a5,80003a5c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003a26:	00000097          	auipc	ra,0x0
    80003a2a:	e34080e7          	jalr	-460(ra) # 8000385a <devintr>
    80003a2e:	cd1d                	beqz	a0,80003a6c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80003a30:	4789                	li	a5,2
    80003a32:	06f50a63          	beq	a0,a5,80003aa6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003a36:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003a3a:	10049073          	csrw	sstatus,s1
}
    80003a3e:	70a2                	ld	ra,40(sp)
    80003a40:	7402                	ld	s0,32(sp)
    80003a42:	64e2                	ld	s1,24(sp)
    80003a44:	6942                	ld	s2,16(sp)
    80003a46:	69a2                	ld	s3,8(sp)
    80003a48:	6145                	addi	sp,sp,48
    80003a4a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003a4c:	00006517          	auipc	a0,0x6
    80003a50:	b3450513          	addi	a0,a0,-1228 # 80009580 <states.0+0xc8>
    80003a54:	ffffd097          	auipc	ra,0xffffd
    80003a58:	ae4080e7          	jalr	-1308(ra) # 80000538 <panic>
    panic("kerneltrap: interrupts enabled");
    80003a5c:	00006517          	auipc	a0,0x6
    80003a60:	b4c50513          	addi	a0,a0,-1204 # 800095a8 <states.0+0xf0>
    80003a64:	ffffd097          	auipc	ra,0xffffd
    80003a68:	ad4080e7          	jalr	-1324(ra) # 80000538 <panic>
    printf("scause %p\n", scause);
    80003a6c:	85ce                	mv	a1,s3
    80003a6e:	00006517          	auipc	a0,0x6
    80003a72:	b5a50513          	addi	a0,a0,-1190 # 800095c8 <states.0+0x110>
    80003a76:	ffffd097          	auipc	ra,0xffffd
    80003a7a:	b0c080e7          	jalr	-1268(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003a7e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003a82:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003a86:	00006517          	auipc	a0,0x6
    80003a8a:	b5250513          	addi	a0,a0,-1198 # 800095d8 <states.0+0x120>
    80003a8e:	ffffd097          	auipc	ra,0xffffd
    80003a92:	af4080e7          	jalr	-1292(ra) # 80000582 <printf>
    panic("kerneltrap");
    80003a96:	00006517          	auipc	a0,0x6
    80003a9a:	b5a50513          	addi	a0,a0,-1190 # 800095f0 <states.0+0x138>
    80003a9e:	ffffd097          	auipc	ra,0xffffd
    80003aa2:	a9a080e7          	jalr	-1382(ra) # 80000538 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80003aa6:	ffffe097          	auipc	ra,0xffffe
    80003aaa:	f14080e7          	jalr	-236(ra) # 800019ba <myproc>
    80003aae:	d541                	beqz	a0,80003a36 <kerneltrap+0x38>
    80003ab0:	ffffe097          	auipc	ra,0xffffe
    80003ab4:	f0a080e7          	jalr	-246(ra) # 800019ba <myproc>
    80003ab8:	4d18                	lw	a4,24(a0)
    80003aba:	4791                	li	a5,4
    80003abc:	f6f71de3          	bne	a4,a5,80003a36 <kerneltrap+0x38>
     if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_NPREEMPT_SJF)) yield();
    80003ac0:	00006717          	auipc	a4,0x6
    80003ac4:	5a872703          	lw	a4,1448(a4) # 8000a068 <sched_policy>
    80003ac8:	4785                	li	a5,1
    80003aca:	f6e7f6e3          	bgeu	a5,a4,80003a36 <kerneltrap+0x38>
    80003ace:	fffff097          	auipc	ra,0xfffff
    80003ad2:	b32080e7          	jalr	-1230(ra) # 80002600 <yield>
    80003ad6:	b785                	j	80003a36 <kerneltrap+0x38>

0000000080003ad8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003ad8:	1101                	addi	sp,sp,-32
    80003ada:	ec06                	sd	ra,24(sp)
    80003adc:	e822                	sd	s0,16(sp)
    80003ade:	e426                	sd	s1,8(sp)
    80003ae0:	1000                	addi	s0,sp,32
    80003ae2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003ae4:	ffffe097          	auipc	ra,0xffffe
    80003ae8:	ed6080e7          	jalr	-298(ra) # 800019ba <myproc>
  switch (n) {
    80003aec:	4795                	li	a5,5
    80003aee:	0497e163          	bltu	a5,s1,80003b30 <argraw+0x58>
    80003af2:	048a                	slli	s1,s1,0x2
    80003af4:	00006717          	auipc	a4,0x6
    80003af8:	b3470713          	addi	a4,a4,-1228 # 80009628 <states.0+0x170>
    80003afc:	94ba                	add	s1,s1,a4
    80003afe:	409c                	lw	a5,0(s1)
    80003b00:	97ba                	add	a5,a5,a4
    80003b02:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003b04:	713c                	ld	a5,96(a0)
    80003b06:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003b08:	60e2                	ld	ra,24(sp)
    80003b0a:	6442                	ld	s0,16(sp)
    80003b0c:	64a2                	ld	s1,8(sp)
    80003b0e:	6105                	addi	sp,sp,32
    80003b10:	8082                	ret
    return p->trapframe->a1;
    80003b12:	713c                	ld	a5,96(a0)
    80003b14:	7fa8                	ld	a0,120(a5)
    80003b16:	bfcd                	j	80003b08 <argraw+0x30>
    return p->trapframe->a2;
    80003b18:	713c                	ld	a5,96(a0)
    80003b1a:	63c8                	ld	a0,128(a5)
    80003b1c:	b7f5                	j	80003b08 <argraw+0x30>
    return p->trapframe->a3;
    80003b1e:	713c                	ld	a5,96(a0)
    80003b20:	67c8                	ld	a0,136(a5)
    80003b22:	b7dd                	j	80003b08 <argraw+0x30>
    return p->trapframe->a4;
    80003b24:	713c                	ld	a5,96(a0)
    80003b26:	6bc8                	ld	a0,144(a5)
    80003b28:	b7c5                	j	80003b08 <argraw+0x30>
    return p->trapframe->a5;
    80003b2a:	713c                	ld	a5,96(a0)
    80003b2c:	6fc8                	ld	a0,152(a5)
    80003b2e:	bfe9                	j	80003b08 <argraw+0x30>
  panic("argraw");
    80003b30:	00006517          	auipc	a0,0x6
    80003b34:	ad050513          	addi	a0,a0,-1328 # 80009600 <states.0+0x148>
    80003b38:	ffffd097          	auipc	ra,0xffffd
    80003b3c:	a00080e7          	jalr	-1536(ra) # 80000538 <panic>

0000000080003b40 <fetchaddr>:
{
    80003b40:	1101                	addi	sp,sp,-32
    80003b42:	ec06                	sd	ra,24(sp)
    80003b44:	e822                	sd	s0,16(sp)
    80003b46:	e426                	sd	s1,8(sp)
    80003b48:	e04a                	sd	s2,0(sp)
    80003b4a:	1000                	addi	s0,sp,32
    80003b4c:	84aa                	mv	s1,a0
    80003b4e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003b50:	ffffe097          	auipc	ra,0xffffe
    80003b54:	e6a080e7          	jalr	-406(ra) # 800019ba <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003b58:	693c                	ld	a5,80(a0)
    80003b5a:	02f4f863          	bgeu	s1,a5,80003b8a <fetchaddr+0x4a>
    80003b5e:	00848713          	addi	a4,s1,8
    80003b62:	02e7e663          	bltu	a5,a4,80003b8e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003b66:	46a1                	li	a3,8
    80003b68:	8626                	mv	a2,s1
    80003b6a:	85ca                	mv	a1,s2
    80003b6c:	6d28                	ld	a0,88(a0)
    80003b6e:	ffffe097          	auipc	ra,0xffffe
    80003b72:	b9c080e7          	jalr	-1124(ra) # 8000170a <copyin>
    80003b76:	00a03533          	snez	a0,a0
    80003b7a:	40a00533          	neg	a0,a0
}
    80003b7e:	60e2                	ld	ra,24(sp)
    80003b80:	6442                	ld	s0,16(sp)
    80003b82:	64a2                	ld	s1,8(sp)
    80003b84:	6902                	ld	s2,0(sp)
    80003b86:	6105                	addi	sp,sp,32
    80003b88:	8082                	ret
    return -1;
    80003b8a:	557d                	li	a0,-1
    80003b8c:	bfcd                	j	80003b7e <fetchaddr+0x3e>
    80003b8e:	557d                	li	a0,-1
    80003b90:	b7fd                	j	80003b7e <fetchaddr+0x3e>

0000000080003b92 <fetchstr>:
{
    80003b92:	7179                	addi	sp,sp,-48
    80003b94:	f406                	sd	ra,40(sp)
    80003b96:	f022                	sd	s0,32(sp)
    80003b98:	ec26                	sd	s1,24(sp)
    80003b9a:	e84a                	sd	s2,16(sp)
    80003b9c:	e44e                	sd	s3,8(sp)
    80003b9e:	1800                	addi	s0,sp,48
    80003ba0:	892a                	mv	s2,a0
    80003ba2:	84ae                	mv	s1,a1
    80003ba4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003ba6:	ffffe097          	auipc	ra,0xffffe
    80003baa:	e14080e7          	jalr	-492(ra) # 800019ba <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003bae:	86ce                	mv	a3,s3
    80003bb0:	864a                	mv	a2,s2
    80003bb2:	85a6                	mv	a1,s1
    80003bb4:	6d28                	ld	a0,88(a0)
    80003bb6:	ffffe097          	auipc	ra,0xffffe
    80003bba:	be2080e7          	jalr	-1054(ra) # 80001798 <copyinstr>
  if(err < 0)
    80003bbe:	00054763          	bltz	a0,80003bcc <fetchstr+0x3a>
  return strlen(buf);
    80003bc2:	8526                	mv	a0,s1
    80003bc4:	ffffd097          	auipc	ra,0xffffd
    80003bc8:	282080e7          	jalr	642(ra) # 80000e46 <strlen>
}
    80003bcc:	70a2                	ld	ra,40(sp)
    80003bce:	7402                	ld	s0,32(sp)
    80003bd0:	64e2                	ld	s1,24(sp)
    80003bd2:	6942                	ld	s2,16(sp)
    80003bd4:	69a2                	ld	s3,8(sp)
    80003bd6:	6145                	addi	sp,sp,48
    80003bd8:	8082                	ret

0000000080003bda <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003bda:	1101                	addi	sp,sp,-32
    80003bdc:	ec06                	sd	ra,24(sp)
    80003bde:	e822                	sd	s0,16(sp)
    80003be0:	e426                	sd	s1,8(sp)
    80003be2:	1000                	addi	s0,sp,32
    80003be4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003be6:	00000097          	auipc	ra,0x0
    80003bea:	ef2080e7          	jalr	-270(ra) # 80003ad8 <argraw>
    80003bee:	c088                	sw	a0,0(s1)
  return 0;
}
    80003bf0:	4501                	li	a0,0
    80003bf2:	60e2                	ld	ra,24(sp)
    80003bf4:	6442                	ld	s0,16(sp)
    80003bf6:	64a2                	ld	s1,8(sp)
    80003bf8:	6105                	addi	sp,sp,32
    80003bfa:	8082                	ret

0000000080003bfc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003bfc:	1101                	addi	sp,sp,-32
    80003bfe:	ec06                	sd	ra,24(sp)
    80003c00:	e822                	sd	s0,16(sp)
    80003c02:	e426                	sd	s1,8(sp)
    80003c04:	1000                	addi	s0,sp,32
    80003c06:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	ed0080e7          	jalr	-304(ra) # 80003ad8 <argraw>
    80003c10:	e088                	sd	a0,0(s1)
  return 0;
}
    80003c12:	4501                	li	a0,0
    80003c14:	60e2                	ld	ra,24(sp)
    80003c16:	6442                	ld	s0,16(sp)
    80003c18:	64a2                	ld	s1,8(sp)
    80003c1a:	6105                	addi	sp,sp,32
    80003c1c:	8082                	ret

0000000080003c1e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003c1e:	1101                	addi	sp,sp,-32
    80003c20:	ec06                	sd	ra,24(sp)
    80003c22:	e822                	sd	s0,16(sp)
    80003c24:	e426                	sd	s1,8(sp)
    80003c26:	e04a                	sd	s2,0(sp)
    80003c28:	1000                	addi	s0,sp,32
    80003c2a:	84ae                	mv	s1,a1
    80003c2c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003c2e:	00000097          	auipc	ra,0x0
    80003c32:	eaa080e7          	jalr	-342(ra) # 80003ad8 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003c36:	864a                	mv	a2,s2
    80003c38:	85a6                	mv	a1,s1
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	f58080e7          	jalr	-168(ra) # 80003b92 <fetchstr>
}
    80003c42:	60e2                	ld	ra,24(sp)
    80003c44:	6442                	ld	s0,16(sp)
    80003c46:	64a2                	ld	s1,8(sp)
    80003c48:	6902                	ld	s2,0(sp)
    80003c4a:	6105                	addi	sp,sp,32
    80003c4c:	8082                	ret

0000000080003c4e <syscall>:
[SYS_sem_consume] sys_sem_consume,
};

void
syscall(void)
{
    80003c4e:	1101                	addi	sp,sp,-32
    80003c50:	ec06                	sd	ra,24(sp)
    80003c52:	e822                	sd	s0,16(sp)
    80003c54:	e426                	sd	s1,8(sp)
    80003c56:	e04a                	sd	s2,0(sp)
    80003c58:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003c5a:	ffffe097          	auipc	ra,0xffffe
    80003c5e:	d60080e7          	jalr	-672(ra) # 800019ba <myproc>
    80003c62:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003c64:	06053903          	ld	s2,96(a0)
    80003c68:	0a893783          	ld	a5,168(s2)
    80003c6c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003c70:	37fd                	addiw	a5,a5,-1
    80003c72:	02600713          	li	a4,38
    80003c76:	00f76f63          	bltu	a4,a5,80003c94 <syscall+0x46>
    80003c7a:	00369713          	slli	a4,a3,0x3
    80003c7e:	00006797          	auipc	a5,0x6
    80003c82:	9c278793          	addi	a5,a5,-1598 # 80009640 <syscalls>
    80003c86:	97ba                	add	a5,a5,a4
    80003c88:	639c                	ld	a5,0(a5)
    80003c8a:	c789                	beqz	a5,80003c94 <syscall+0x46>
    p->trapframe->a0 = syscalls[num]();
    80003c8c:	9782                	jalr	a5
    80003c8e:	06a93823          	sd	a0,112(s2)
    80003c92:	a839                	j	80003cb0 <syscall+0x62>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003c94:	16048613          	addi	a2,s1,352
    80003c98:	588c                	lw	a1,48(s1)
    80003c9a:	00006517          	auipc	a0,0x6
    80003c9e:	96e50513          	addi	a0,a0,-1682 # 80009608 <states.0+0x150>
    80003ca2:	ffffd097          	auipc	ra,0xffffd
    80003ca6:	8e0080e7          	jalr	-1824(ra) # 80000582 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003caa:	70bc                	ld	a5,96(s1)
    80003cac:	577d                	li	a4,-1
    80003cae:	fbb8                	sd	a4,112(a5)
  }
}
    80003cb0:	60e2                	ld	ra,24(sp)
    80003cb2:	6442                	ld	s0,16(sp)
    80003cb4:	64a2                	ld	s1,8(sp)
    80003cb6:	6902                	ld	s2,0(sp)
    80003cb8:	6105                	addi	sp,sp,32
    80003cba:	8082                	ret

0000000080003cbc <sys_exit>:
int nextp;
int nextc;

uint64
sys_exit(void)
{
    80003cbc:	1101                	addi	sp,sp,-32
    80003cbe:	ec06                	sd	ra,24(sp)
    80003cc0:	e822                	sd	s0,16(sp)
    80003cc2:	1000                	addi	s0,sp,32
  int n;
  if (argint(0, &n) < 0)
    80003cc4:	fec40593          	addi	a1,s0,-20
    80003cc8:	4501                	li	a0,0
    80003cca:	00000097          	auipc	ra,0x0
    80003cce:	f10080e7          	jalr	-240(ra) # 80003bda <argint>
    return -1;
    80003cd2:	57fd                	li	a5,-1
  if (argint(0, &n) < 0)
    80003cd4:	00054963          	bltz	a0,80003ce6 <sys_exit+0x2a>
  exit(n);
    80003cd8:	fec42503          	lw	a0,-20(s0)
    80003cdc:	fffff097          	auipc	ra,0xfffff
    80003ce0:	fb0080e7          	jalr	-80(ra) # 80002c8c <exit>
  return 0; // not reached
    80003ce4:	4781                	li	a5,0
}
    80003ce6:	853e                	mv	a0,a5
    80003ce8:	60e2                	ld	ra,24(sp)
    80003cea:	6442                	ld	s0,16(sp)
    80003cec:	6105                	addi	sp,sp,32
    80003cee:	8082                	ret

0000000080003cf0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003cf0:	1141                	addi	sp,sp,-16
    80003cf2:	e406                	sd	ra,8(sp)
    80003cf4:	e022                	sd	s0,0(sp)
    80003cf6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003cf8:	ffffe097          	auipc	ra,0xffffe
    80003cfc:	cc2080e7          	jalr	-830(ra) # 800019ba <myproc>
}
    80003d00:	5908                	lw	a0,48(a0)
    80003d02:	60a2                	ld	ra,8(sp)
    80003d04:	6402                	ld	s0,0(sp)
    80003d06:	0141                	addi	sp,sp,16
    80003d08:	8082                	ret

0000000080003d0a <sys_fork>:

uint64
sys_fork(void)
{
    80003d0a:	1141                	addi	sp,sp,-16
    80003d0c:	e406                	sd	ra,8(sp)
    80003d0e:	e022                	sd	s0,0(sp)
    80003d10:	0800                	addi	s0,sp,16
  return fork();
    80003d12:	ffffe097          	auipc	ra,0xffffe
    80003d16:	0f0080e7          	jalr	240(ra) # 80001e02 <fork>
}
    80003d1a:	60a2                	ld	ra,8(sp)
    80003d1c:	6402                	ld	s0,0(sp)
    80003d1e:	0141                	addi	sp,sp,16
    80003d20:	8082                	ret

0000000080003d22 <sys_wait>:

uint64
sys_wait(void)
{
    80003d22:	1101                	addi	sp,sp,-32
    80003d24:	ec06                	sd	ra,24(sp)
    80003d26:	e822                	sd	s0,16(sp)
    80003d28:	1000                	addi	s0,sp,32
  uint64 p;
  if (argaddr(0, &p) < 0)
    80003d2a:	fe840593          	addi	a1,s0,-24
    80003d2e:	4501                	li	a0,0
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	ecc080e7          	jalr	-308(ra) # 80003bfc <argaddr>
    80003d38:	87aa                	mv	a5,a0
    return -1;
    80003d3a:	557d                	li	a0,-1
  if (argaddr(0, &p) < 0)
    80003d3c:	0007c863          	bltz	a5,80003d4c <sys_wait+0x2a>
  return wait(p);
    80003d40:	fe843503          	ld	a0,-24(s0)
    80003d44:	fffff097          	auipc	ra,0xfffff
    80003d48:	bd6080e7          	jalr	-1066(ra) # 8000291a <wait>
}
    80003d4c:	60e2                	ld	ra,24(sp)
    80003d4e:	6442                	ld	s0,16(sp)
    80003d50:	6105                	addi	sp,sp,32
    80003d52:	8082                	ret

0000000080003d54 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003d54:	7179                	addi	sp,sp,-48
    80003d56:	f406                	sd	ra,40(sp)
    80003d58:	f022                	sd	s0,32(sp)
    80003d5a:	ec26                	sd	s1,24(sp)
    80003d5c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if (argint(0, &n) < 0)
    80003d5e:	fdc40593          	addi	a1,s0,-36
    80003d62:	4501                	li	a0,0
    80003d64:	00000097          	auipc	ra,0x0
    80003d68:	e76080e7          	jalr	-394(ra) # 80003bda <argint>
    80003d6c:	87aa                	mv	a5,a0
    return -1;
    80003d6e:	557d                	li	a0,-1
  if (argint(0, &n) < 0)
    80003d70:	0207c063          	bltz	a5,80003d90 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80003d74:	ffffe097          	auipc	ra,0xffffe
    80003d78:	c46080e7          	jalr	-954(ra) # 800019ba <myproc>
    80003d7c:	4924                	lw	s1,80(a0)
  if (growproc(n) < 0)
    80003d7e:	fdc42503          	lw	a0,-36(s0)
    80003d82:	ffffe097          	auipc	ra,0xffffe
    80003d86:	008080e7          	jalr	8(ra) # 80001d8a <growproc>
    80003d8a:	00054863          	bltz	a0,80003d9a <sys_sbrk+0x46>
    return -1;
  return addr;
    80003d8e:	8526                	mv	a0,s1
}
    80003d90:	70a2                	ld	ra,40(sp)
    80003d92:	7402                	ld	s0,32(sp)
    80003d94:	64e2                	ld	s1,24(sp)
    80003d96:	6145                	addi	sp,sp,48
    80003d98:	8082                	ret
    return -1;
    80003d9a:	557d                	li	a0,-1
    80003d9c:	bfd5                	j	80003d90 <sys_sbrk+0x3c>

0000000080003d9e <sys_sleep>:

uint64
sys_sleep(void)
{
    80003d9e:	7139                	addi	sp,sp,-64
    80003da0:	fc06                	sd	ra,56(sp)
    80003da2:	f822                	sd	s0,48(sp)
    80003da4:	f426                	sd	s1,40(sp)
    80003da6:	f04a                	sd	s2,32(sp)
    80003da8:	ec4e                	sd	s3,24(sp)
    80003daa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if (argint(0, &n) < 0)
    80003dac:	fcc40593          	addi	a1,s0,-52
    80003db0:	4501                	li	a0,0
    80003db2:	00000097          	auipc	ra,0x0
    80003db6:	e28080e7          	jalr	-472(ra) # 80003bda <argint>
    return -1;
    80003dba:	57fd                	li	a5,-1
  if (argint(0, &n) < 0)
    80003dbc:	06054563          	bltz	a0,80003e26 <sys_sleep+0x88>
  acquire(&tickslock);
    80003dc0:	00015517          	auipc	a0,0x15
    80003dc4:	d5050513          	addi	a0,a0,-688 # 80018b10 <tickslock>
    80003dc8:	ffffd097          	auipc	ra,0xffffd
    80003dcc:	e06080e7          	jalr	-506(ra) # 80000bce <acquire>
  ticks0 = ticks;
    80003dd0:	00006917          	auipc	s2,0x6
    80003dd4:	29c92903          	lw	s2,668(s2) # 8000a06c <ticks>
  while (ticks - ticks0 < n)
    80003dd8:	fcc42783          	lw	a5,-52(s0)
    80003ddc:	cf85                	beqz	a5,80003e14 <sys_sleep+0x76>
    if (myproc()->killed)
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003dde:	00015997          	auipc	s3,0x15
    80003de2:	d3298993          	addi	s3,s3,-718 # 80018b10 <tickslock>
    80003de6:	00006497          	auipc	s1,0x6
    80003dea:	28648493          	addi	s1,s1,646 # 8000a06c <ticks>
    if (myproc()->killed)
    80003dee:	ffffe097          	auipc	ra,0xffffe
    80003df2:	bcc080e7          	jalr	-1076(ra) # 800019ba <myproc>
    80003df6:	551c                	lw	a5,40(a0)
    80003df8:	ef9d                	bnez	a5,80003e36 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003dfa:	85ce                	mv	a1,s3
    80003dfc:	8526                	mv	a0,s1
    80003dfe:	fffff097          	auipc	ra,0xfffff
    80003e02:	96e080e7          	jalr	-1682(ra) # 8000276c <sleep>
  while (ticks - ticks0 < n)
    80003e06:	409c                	lw	a5,0(s1)
    80003e08:	412787bb          	subw	a5,a5,s2
    80003e0c:	fcc42703          	lw	a4,-52(s0)
    80003e10:	fce7efe3          	bltu	a5,a4,80003dee <sys_sleep+0x50>
  }
  release(&tickslock);
    80003e14:	00015517          	auipc	a0,0x15
    80003e18:	cfc50513          	addi	a0,a0,-772 # 80018b10 <tickslock>
    80003e1c:	ffffd097          	auipc	ra,0xffffd
    80003e20:	e66080e7          	jalr	-410(ra) # 80000c82 <release>
  return 0;
    80003e24:	4781                	li	a5,0
}
    80003e26:	853e                	mv	a0,a5
    80003e28:	70e2                	ld	ra,56(sp)
    80003e2a:	7442                	ld	s0,48(sp)
    80003e2c:	74a2                	ld	s1,40(sp)
    80003e2e:	7902                	ld	s2,32(sp)
    80003e30:	69e2                	ld	s3,24(sp)
    80003e32:	6121                	addi	sp,sp,64
    80003e34:	8082                	ret
      release(&tickslock);
    80003e36:	00015517          	auipc	a0,0x15
    80003e3a:	cda50513          	addi	a0,a0,-806 # 80018b10 <tickslock>
    80003e3e:	ffffd097          	auipc	ra,0xffffd
    80003e42:	e44080e7          	jalr	-444(ra) # 80000c82 <release>
      return -1;
    80003e46:	57fd                	li	a5,-1
    80003e48:	bff9                	j	80003e26 <sys_sleep+0x88>

0000000080003e4a <sys_kill>:

uint64
sys_kill(void)
{
    80003e4a:	1101                	addi	sp,sp,-32
    80003e4c:	ec06                	sd	ra,24(sp)
    80003e4e:	e822                	sd	s0,16(sp)
    80003e50:	1000                	addi	s0,sp,32
  int pid;

  if (argint(0, &pid) < 0)
    80003e52:	fec40593          	addi	a1,s0,-20
    80003e56:	4501                	li	a0,0
    80003e58:	00000097          	auipc	ra,0x0
    80003e5c:	d82080e7          	jalr	-638(ra) # 80003bda <argint>
    80003e60:	87aa                	mv	a5,a0
    return -1;
    80003e62:	557d                	li	a0,-1
  if (argint(0, &pid) < 0)
    80003e64:	0007c863          	bltz	a5,80003e74 <sys_kill+0x2a>
  return kill(pid);
    80003e68:	fec42503          	lw	a0,-20(s0)
    80003e6c:	fffff097          	auipc	ra,0xfffff
    80003e70:	25a080e7          	jalr	602(ra) # 800030c6 <kill>
}
    80003e74:	60e2                	ld	ra,24(sp)
    80003e76:	6442                	ld	s0,16(sp)
    80003e78:	6105                	addi	sp,sp,32
    80003e7a:	8082                	ret

0000000080003e7c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003e7c:	1101                	addi	sp,sp,-32
    80003e7e:	ec06                	sd	ra,24(sp)
    80003e80:	e822                	sd	s0,16(sp)
    80003e82:	e426                	sd	s1,8(sp)
    80003e84:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003e86:	00015517          	auipc	a0,0x15
    80003e8a:	c8a50513          	addi	a0,a0,-886 # 80018b10 <tickslock>
    80003e8e:	ffffd097          	auipc	ra,0xffffd
    80003e92:	d40080e7          	jalr	-704(ra) # 80000bce <acquire>
  xticks = ticks;
    80003e96:	00006497          	auipc	s1,0x6
    80003e9a:	1d64a483          	lw	s1,470(s1) # 8000a06c <ticks>
  release(&tickslock);
    80003e9e:	00015517          	auipc	a0,0x15
    80003ea2:	c7250513          	addi	a0,a0,-910 # 80018b10 <tickslock>
    80003ea6:	ffffd097          	auipc	ra,0xffffd
    80003eaa:	ddc080e7          	jalr	-548(ra) # 80000c82 <release>
  return xticks;
}
    80003eae:	02049513          	slli	a0,s1,0x20
    80003eb2:	9101                	srli	a0,a0,0x20
    80003eb4:	60e2                	ld	ra,24(sp)
    80003eb6:	6442                	ld	s0,16(sp)
    80003eb8:	64a2                	ld	s1,8(sp)
    80003eba:	6105                	addi	sp,sp,32
    80003ebc:	8082                	ret

0000000080003ebe <sys_getppid>:

uint64
sys_getppid(void)
{
    80003ebe:	1141                	addi	sp,sp,-16
    80003ec0:	e406                	sd	ra,8(sp)
    80003ec2:	e022                	sd	s0,0(sp)
    80003ec4:	0800                	addi	s0,sp,16
  if (myproc()->parent)
    80003ec6:	ffffe097          	auipc	ra,0xffffe
    80003eca:	af4080e7          	jalr	-1292(ra) # 800019ba <myproc>
    80003ece:	613c                	ld	a5,64(a0)
    80003ed0:	cb99                	beqz	a5,80003ee6 <sys_getppid+0x28>
    return myproc()->parent->pid;
    80003ed2:	ffffe097          	auipc	ra,0xffffe
    80003ed6:	ae8080e7          	jalr	-1304(ra) # 800019ba <myproc>
    80003eda:	613c                	ld	a5,64(a0)
    80003edc:	5b88                	lw	a0,48(a5)
  else
  {
    printf("No parent found.\n");
    return 0;
  }
}
    80003ede:	60a2                	ld	ra,8(sp)
    80003ee0:	6402                	ld	s0,0(sp)
    80003ee2:	0141                	addi	sp,sp,16
    80003ee4:	8082                	ret
    printf("No parent found.\n");
    80003ee6:	00006517          	auipc	a0,0x6
    80003eea:	89a50513          	addi	a0,a0,-1894 # 80009780 <syscalls+0x140>
    80003eee:	ffffc097          	auipc	ra,0xffffc
    80003ef2:	694080e7          	jalr	1684(ra) # 80000582 <printf>
    return 0;
    80003ef6:	4501                	li	a0,0
    80003ef8:	b7dd                	j	80003ede <sys_getppid+0x20>

0000000080003efa <sys_yield>:

uint64
sys_yield(void)
{
    80003efa:	1141                	addi	sp,sp,-16
    80003efc:	e406                	sd	ra,8(sp)
    80003efe:	e022                	sd	s0,0(sp)
    80003f00:	0800                	addi	s0,sp,16
  yield();
    80003f02:	ffffe097          	auipc	ra,0xffffe
    80003f06:	6fe080e7          	jalr	1790(ra) # 80002600 <yield>
  return 0;
}
    80003f0a:	4501                	li	a0,0
    80003f0c:	60a2                	ld	ra,8(sp)
    80003f0e:	6402                	ld	s0,0(sp)
    80003f10:	0141                	addi	sp,sp,16
    80003f12:	8082                	ret

0000000080003f14 <sys_getpa>:

uint64
sys_getpa(void)
{
    80003f14:	1101                	addi	sp,sp,-32
    80003f16:	ec06                	sd	ra,24(sp)
    80003f18:	e822                	sd	s0,16(sp)
    80003f1a:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0)
    80003f1c:	fe840593          	addi	a1,s0,-24
    80003f20:	4501                	li	a0,0
    80003f22:	00000097          	auipc	ra,0x0
    80003f26:	cda080e7          	jalr	-806(ra) # 80003bfc <argaddr>
    80003f2a:	87aa                	mv	a5,a0
    return -1;
    80003f2c:	557d                	li	a0,-1
  if (argaddr(0, &x) < 0)
    80003f2e:	0207c263          	bltz	a5,80003f52 <sys_getpa+0x3e>
  return walkaddr(myproc()->pagetable, x) + (x & (PGSIZE - 1));
    80003f32:	ffffe097          	auipc	ra,0xffffe
    80003f36:	a88080e7          	jalr	-1400(ra) # 800019ba <myproc>
    80003f3a:	fe843583          	ld	a1,-24(s0)
    80003f3e:	6d28                	ld	a0,88(a0)
    80003f40:	ffffd097          	auipc	ra,0xffffd
    80003f44:	136080e7          	jalr	310(ra) # 80001076 <walkaddr>
    80003f48:	fe843783          	ld	a5,-24(s0)
    80003f4c:	17d2                	slli	a5,a5,0x34
    80003f4e:	93d1                	srli	a5,a5,0x34
    80003f50:	953e                	add	a0,a0,a5
}
    80003f52:	60e2                	ld	ra,24(sp)
    80003f54:	6442                	ld	s0,16(sp)
    80003f56:	6105                	addi	sp,sp,32
    80003f58:	8082                	ret

0000000080003f5a <sys_forkf>:

uint64
sys_forkf(void)
{
    80003f5a:	1101                	addi	sp,sp,-32
    80003f5c:	ec06                	sd	ra,24(sp)
    80003f5e:	e822                	sd	s0,16(sp)
    80003f60:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0)
    80003f62:	fe840593          	addi	a1,s0,-24
    80003f66:	4501                	li	a0,0
    80003f68:	00000097          	auipc	ra,0x0
    80003f6c:	c94080e7          	jalr	-876(ra) # 80003bfc <argaddr>
    80003f70:	87aa                	mv	a5,a0
    return -1;
    80003f72:	557d                	li	a0,-1
  if (argaddr(0, &x) < 0)
    80003f74:	0007c863          	bltz	a5,80003f84 <sys_forkf+0x2a>
  return forkf(x);
    80003f78:	fe843503          	ld	a0,-24(s0)
    80003f7c:	ffffe097          	auipc	ra,0xffffe
    80003f80:	fc6080e7          	jalr	-58(ra) # 80001f42 <forkf>
}
    80003f84:	60e2                	ld	ra,24(sp)
    80003f86:	6442                	ld	s0,16(sp)
    80003f88:	6105                	addi	sp,sp,32
    80003f8a:	8082                	ret

0000000080003f8c <sys_waitpid>:

uint64
sys_waitpid(void)
{
    80003f8c:	1101                	addi	sp,sp,-32
    80003f8e:	ec06                	sd	ra,24(sp)
    80003f90:	e822                	sd	s0,16(sp)
    80003f92:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if (argint(0, &x) < 0)
    80003f94:	fe440593          	addi	a1,s0,-28
    80003f98:	4501                	li	a0,0
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	c40080e7          	jalr	-960(ra) # 80003bda <argint>
    return -1;
    80003fa2:	57fd                	li	a5,-1
  if (argint(0, &x) < 0)
    80003fa4:	02054c63          	bltz	a0,80003fdc <sys_waitpid+0x50>
  if (argaddr(1, &p) < 0)
    80003fa8:	fe840593          	addi	a1,s0,-24
    80003fac:	4505                	li	a0,1
    80003fae:	00000097          	auipc	ra,0x0
    80003fb2:	c4e080e7          	jalr	-946(ra) # 80003bfc <argaddr>
    80003fb6:	04054063          	bltz	a0,80003ff6 <sys_waitpid+0x6a>
    return -1;

  if (x == -1)
    80003fba:	fe442503          	lw	a0,-28(s0)
    80003fbe:	57fd                	li	a5,-1
    80003fc0:	02f50363          	beq	a0,a5,80003fe6 <sys_waitpid+0x5a>
    return wait(p);
  if ((x == 0) || (x < -1))
    return -1;
    80003fc4:	57fd                	li	a5,-1
  if ((x == 0) || (x < -1))
    80003fc6:	c919                	beqz	a0,80003fdc <sys_waitpid+0x50>
    80003fc8:	577d                	li	a4,-1
    80003fca:	00e54963          	blt	a0,a4,80003fdc <sys_waitpid+0x50>
  return waitpid(x, p);
    80003fce:	fe843583          	ld	a1,-24(s0)
    80003fd2:	fffff097          	auipc	ra,0xfffff
    80003fd6:	a70080e7          	jalr	-1424(ra) # 80002a42 <waitpid>
    80003fda:	87aa                	mv	a5,a0
}
    80003fdc:	853e                	mv	a0,a5
    80003fde:	60e2                	ld	ra,24(sp)
    80003fe0:	6442                	ld	s0,16(sp)
    80003fe2:	6105                	addi	sp,sp,32
    80003fe4:	8082                	ret
    return wait(p);
    80003fe6:	fe843503          	ld	a0,-24(s0)
    80003fea:	fffff097          	auipc	ra,0xfffff
    80003fee:	930080e7          	jalr	-1744(ra) # 8000291a <wait>
    80003ff2:	87aa                	mv	a5,a0
    80003ff4:	b7e5                	j	80003fdc <sys_waitpid+0x50>
    return -1;
    80003ff6:	57fd                	li	a5,-1
    80003ff8:	b7d5                	j	80003fdc <sys_waitpid+0x50>

0000000080003ffa <sys_ps>:

uint64
sys_ps(void)
{
    80003ffa:	1141                	addi	sp,sp,-16
    80003ffc:	e406                	sd	ra,8(sp)
    80003ffe:	e022                	sd	s0,0(sp)
    80004000:	0800                	addi	s0,sp,16
  return ps();
    80004002:	fffff097          	auipc	ra,0xfffff
    80004006:	2c2080e7          	jalr	706(ra) # 800032c4 <ps>
}
    8000400a:	60a2                	ld	ra,8(sp)
    8000400c:	6402                	ld	s0,0(sp)
    8000400e:	0141                	addi	sp,sp,16
    80004010:	8082                	ret

0000000080004012 <sys_pinfo>:

uint64
sys_pinfo(void)
{
    80004012:	1101                	addi	sp,sp,-32
    80004014:	ec06                	sd	ra,24(sp)
    80004016:	e822                	sd	s0,16(sp)
    80004018:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if (argint(0, &x) < 0)
    8000401a:	fe440593          	addi	a1,s0,-28
    8000401e:	4501                	li	a0,0
    80004020:	00000097          	auipc	ra,0x0
    80004024:	bba080e7          	jalr	-1094(ra) # 80003bda <argint>
    return -1;
    80004028:	57fd                	li	a5,-1
  if (argint(0, &x) < 0)
    8000402a:	02054963          	bltz	a0,8000405c <sys_pinfo+0x4a>
  if (argaddr(1, &p) < 0)
    8000402e:	fe840593          	addi	a1,s0,-24
    80004032:	4505                	li	a0,1
    80004034:	00000097          	auipc	ra,0x0
    80004038:	bc8080e7          	jalr	-1080(ra) # 80003bfc <argaddr>
    8000403c:	02054563          	bltz	a0,80004066 <sys_pinfo+0x54>
    return -1;

  if ((x == 0) || (x < -1) || (p == 0))
    80004040:	fe442503          	lw	a0,-28(s0)
    return -1;
    80004044:	57fd                	li	a5,-1
  if ((x == 0) || (x < -1) || (p == 0))
    80004046:	c919                	beqz	a0,8000405c <sys_pinfo+0x4a>
    80004048:	02f54163          	blt	a0,a5,8000406a <sys_pinfo+0x58>
    8000404c:	fe843583          	ld	a1,-24(s0)
    80004050:	c591                	beqz	a1,8000405c <sys_pinfo+0x4a>
  return pinfo(x, p);
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	3e0080e7          	jalr	992(ra) # 80003432 <pinfo>
    8000405a:	87aa                	mv	a5,a0
}
    8000405c:	853e                	mv	a0,a5
    8000405e:	60e2                	ld	ra,24(sp)
    80004060:	6442                	ld	s0,16(sp)
    80004062:	6105                	addi	sp,sp,32
    80004064:	8082                	ret
    return -1;
    80004066:	57fd                	li	a5,-1
    80004068:	bfd5                	j	8000405c <sys_pinfo+0x4a>
    return -1;
    8000406a:	57fd                	li	a5,-1
    8000406c:	bfc5                	j	8000405c <sys_pinfo+0x4a>

000000008000406e <sys_forkp>:

uint64
sys_forkp(void)
{
    8000406e:	1101                	addi	sp,sp,-32
    80004070:	ec06                	sd	ra,24(sp)
    80004072:	e822                	sd	s0,16(sp)
    80004074:	1000                	addi	s0,sp,32
  int x;
  if (argint(0, &x) < 0)
    80004076:	fec40593          	addi	a1,s0,-20
    8000407a:	4501                	li	a0,0
    8000407c:	00000097          	auipc	ra,0x0
    80004080:	b5e080e7          	jalr	-1186(ra) # 80003bda <argint>
    80004084:	87aa                	mv	a5,a0
    return -1;
    80004086:	557d                	li	a0,-1
  if (argint(0, &x) < 0)
    80004088:	0007c863          	bltz	a5,80004098 <sys_forkp+0x2a>
  return forkp(x);
    8000408c:	fec42503          	lw	a0,-20(s0)
    80004090:	ffffe097          	auipc	ra,0xffffe
    80004094:	ffe080e7          	jalr	-2(ra) # 8000208e <forkp>
}
    80004098:	60e2                	ld	ra,24(sp)
    8000409a:	6442                	ld	s0,16(sp)
    8000409c:	6105                	addi	sp,sp,32
    8000409e:	8082                	ret

00000000800040a0 <sys_schedpolicy>:

uint64
sys_schedpolicy(void)
{
    800040a0:	1101                	addi	sp,sp,-32
    800040a2:	ec06                	sd	ra,24(sp)
    800040a4:	e822                	sd	s0,16(sp)
    800040a6:	1000                	addi	s0,sp,32
  int x;
  if (argint(0, &x) < 0)
    800040a8:	fec40593          	addi	a1,s0,-20
    800040ac:	4501                	li	a0,0
    800040ae:	00000097          	auipc	ra,0x0
    800040b2:	b2c080e7          	jalr	-1236(ra) # 80003bda <argint>
    800040b6:	87aa                	mv	a5,a0
    return -1;
    800040b8:	557d                	li	a0,-1
  if (argint(0, &x) < 0)
    800040ba:	0007c863          	bltz	a5,800040ca <sys_schedpolicy+0x2a>
  return schedpolicy(x);
    800040be:	fec42503          	lw	a0,-20(s0)
    800040c2:	fffff097          	auipc	ra,0xfffff
    800040c6:	514080e7          	jalr	1300(ra) # 800035d6 <schedpolicy>
}
    800040ca:	60e2                	ld	ra,24(sp)
    800040cc:	6442                	ld	s0,16(sp)
    800040ce:	6105                	addi	sp,sp,32
    800040d0:	8082                	ret

00000000800040d2 <sys_barrier_alloc>:

uint64
sys_barrier_alloc(void)
{
    800040d2:	1101                	addi	sp,sp,-32
    800040d4:	ec06                	sd	ra,24(sp)
    800040d6:	e822                	sd	s0,16(sp)
    800040d8:	e426                	sd	s1,8(sp)
    800040da:	e04a                	sd	s2,0(sp)
    800040dc:	1000                	addi	s0,sp,32
  for (int i = 0; i < 10; i++)
    800040de:	00015797          	auipc	a5,0x15
    800040e2:	a4a78793          	addi	a5,a5,-1462 # 80018b28 <barrier_arr>
    800040e6:	4501                	li	a0,0
  {
    if (barrier_arr[i].count == -1)
    800040e8:	56fd                	li	a3,-1
  for (int i = 0; i < 10; i++)
    800040ea:	4629                	li	a2,10
    if (barrier_arr[i].count == -1)
    800040ec:	4398                	lw	a4,0(a5)
    800040ee:	00d70f63          	beq	a4,a3,8000410c <sys_barrier_alloc+0x3a>
  for (int i = 0; i < 10; i++)
    800040f2:	2505                	addiw	a0,a0,1
    800040f4:	04078793          	addi	a5,a5,64
    800040f8:	fec51ae3          	bne	a0,a2,800040ec <sys_barrier_alloc+0x1a>
      (barrier_arr[i].cv).cond = 0;
      return i;
    }
  }

  return -1;
    800040fc:	54fd                	li	s1,-1
}
    800040fe:	8526                	mv	a0,s1
    80004100:	60e2                	ld	ra,24(sp)
    80004102:	6442                	ld	s0,16(sp)
    80004104:	64a2                	ld	s1,8(sp)
    80004106:	6902                	ld	s2,0(sp)
    80004108:	6105                	addi	sp,sp,32
    8000410a:	8082                	ret
      barrier_arr[i].count = 0;
    8000410c:	00015717          	auipc	a4,0x15
    80004110:	a1c70713          	addi	a4,a4,-1508 # 80018b28 <barrier_arr>
    80004114:	00651793          	slli	a5,a0,0x6
    80004118:	00f70933          	add	s2,a4,a5
    8000411c:	00092023          	sw	zero,0(s2)
      initsleeplock(&(barrier_arr[i].barr_lock), "barrier_lock");
    80004120:	84aa                	mv	s1,a0
    80004122:	07a1                	addi	a5,a5,8
    80004124:	00005597          	auipc	a1,0x5
    80004128:	67458593          	addi	a1,a1,1652 # 80009798 <syscalls+0x158>
    8000412c:	00f70533          	add	a0,a4,a5
    80004130:	00002097          	auipc	ra,0x2
    80004134:	af4080e7          	jalr	-1292(ra) # 80005c24 <initsleeplock>
      (barrier_arr[i].cv).cond = 0;
    80004138:	02092c23          	sw	zero,56(s2)
      return i;
    8000413c:	b7c9                	j	800040fe <sys_barrier_alloc+0x2c>

000000008000413e <sys_barrier>:

uint64
sys_barrier(void)
{
    8000413e:	7179                	addi	sp,sp,-48
    80004140:	f406                	sd	ra,40(sp)
    80004142:	f022                	sd	s0,32(sp)
    80004144:	ec26                	sd	s1,24(sp)
    80004146:	1800                	addi	s0,sp,48
  int barr_inst_no, barr_id, proc_nu;
  if (argint(0, &barr_inst_no) < 0)
    80004148:	fdc40593          	addi	a1,s0,-36
    8000414c:	4501                	li	a0,0
    8000414e:	00000097          	auipc	ra,0x0
    80004152:	a8c080e7          	jalr	-1396(ra) # 80003bda <argint>
    return -1;
    80004156:	57fd                	li	a5,-1
  if (argint(0, &barr_inst_no) < 0)
    80004158:	0c054f63          	bltz	a0,80004236 <sys_barrier+0xf8>
  if (argint(1, &barr_id) < 0)
    8000415c:	fd840593          	addi	a1,s0,-40
    80004160:	4505                	li	a0,1
    80004162:	00000097          	auipc	ra,0x0
    80004166:	a78080e7          	jalr	-1416(ra) # 80003bda <argint>
    return -1;
    8000416a:	57fd                	li	a5,-1
  if (argint(1, &barr_id) < 0)
    8000416c:	0c054563          	bltz	a0,80004236 <sys_barrier+0xf8>
  if (argint(2, &proc_nu) < 0)
    80004170:	fd440593          	addi	a1,s0,-44
    80004174:	4509                	li	a0,2
    80004176:	00000097          	auipc	ra,0x0
    8000417a:	a64080e7          	jalr	-1436(ra) # 80003bda <argint>
    return -1;
    8000417e:	57fd                	li	a5,-1
  if (argint(2, &proc_nu) < 0)
    80004180:	0a054b63          	bltz	a0,80004236 <sys_barrier+0xf8>

  acquiresleep(&(barrier_arr[barr_id].barr_lock));
    80004184:	00015497          	auipc	s1,0x15
    80004188:	9a448493          	addi	s1,s1,-1628 # 80018b28 <barrier_arr>
    8000418c:	fd842503          	lw	a0,-40(s0)
    80004190:	051a                	slli	a0,a0,0x6
    80004192:	0521                	addi	a0,a0,8
    80004194:	9526                	add	a0,a0,s1
    80004196:	00002097          	auipc	ra,0x2
    8000419a:	ac8080e7          	jalr	-1336(ra) # 80005c5e <acquiresleep>

  printf("%d: Entered barrier#%d for barrier array id %d\n", myproc()->pid, barr_inst_no, barr_id);
    8000419e:	ffffe097          	auipc	ra,0xffffe
    800041a2:	81c080e7          	jalr	-2020(ra) # 800019ba <myproc>
    800041a6:	fd842683          	lw	a3,-40(s0)
    800041aa:	fdc42603          	lw	a2,-36(s0)
    800041ae:	590c                	lw	a1,48(a0)
    800041b0:	00005517          	auipc	a0,0x5
    800041b4:	5f850513          	addi	a0,a0,1528 # 800097a8 <syscalls+0x168>
    800041b8:	ffffc097          	auipc	ra,0xffffc
    800041bc:	3ca080e7          	jalr	970(ra) # 80000582 <printf>

  barrier_arr[barr_id].count++;
    800041c0:	fd842783          	lw	a5,-40(s0)
    800041c4:	00679713          	slli	a4,a5,0x6
    800041c8:	94ba                	add	s1,s1,a4
    800041ca:	4098                	lw	a4,0(s1)
    800041cc:	2705                	addiw	a4,a4,1
    800041ce:	0007069b          	sext.w	a3,a4
    800041d2:	c098                	sw	a4,0(s1)
  if (barrier_arr[barr_id].count == proc_nu)
    800041d4:	fd442703          	lw	a4,-44(s0)
    800041d8:	06d70563          	beq	a4,a3,80004242 <sys_barrier+0x104>
  {
    barrier_arr[barr_id].count = 0;
    cond_broadcast(&(barrier_arr[barr_id].cv));
  }
  else
    cond_wait(&(barrier_arr[barr_id].cv), &(barrier_arr[barr_id].barr_lock));
    800041dc:	079a                	slli	a5,a5,0x6
    800041de:	00015517          	auipc	a0,0x15
    800041e2:	94a50513          	addi	a0,a0,-1718 # 80018b28 <barrier_arr>
    800041e6:	00878593          	addi	a1,a5,8
    800041ea:	03878793          	addi	a5,a5,56
    800041ee:	95aa                	add	a1,a1,a0
    800041f0:	953e                	add	a0,a0,a5
    800041f2:	00004097          	auipc	ra,0x4
    800041f6:	8f0080e7          	jalr	-1808(ra) # 80007ae2 <cond_wait>

  printf("%d: Finished barrier#%d for barrier array id %d\n", myproc()->pid, barr_inst_no, barr_id);
    800041fa:	ffffd097          	auipc	ra,0xffffd
    800041fe:	7c0080e7          	jalr	1984(ra) # 800019ba <myproc>
    80004202:	fd842683          	lw	a3,-40(s0)
    80004206:	fdc42603          	lw	a2,-36(s0)
    8000420a:	590c                	lw	a1,48(a0)
    8000420c:	00005517          	auipc	a0,0x5
    80004210:	5cc50513          	addi	a0,a0,1484 # 800097d8 <syscalls+0x198>
    80004214:	ffffc097          	auipc	ra,0xffffc
    80004218:	36e080e7          	jalr	878(ra) # 80000582 <printf>

  releasesleep(&(barrier_arr[barr_id].barr_lock));
    8000421c:	fd842783          	lw	a5,-40(s0)
    80004220:	079a                	slli	a5,a5,0x6
    80004222:	00015517          	auipc	a0,0x15
    80004226:	90e50513          	addi	a0,a0,-1778 # 80018b30 <barrier_arr+0x8>
    8000422a:	953e                	add	a0,a0,a5
    8000422c:	00002097          	auipc	ra,0x2
    80004230:	a88080e7          	jalr	-1400(ra) # 80005cb4 <releasesleep>

  return 1;
    80004234:	4785                	li	a5,1
}
    80004236:	853e                	mv	a0,a5
    80004238:	70a2                	ld	ra,40(sp)
    8000423a:	7402                	ld	s0,32(sp)
    8000423c:	64e2                	ld	s1,24(sp)
    8000423e:	6145                	addi	sp,sp,48
    80004240:	8082                	ret
    barrier_arr[barr_id].count = 0;
    80004242:	00015517          	auipc	a0,0x15
    80004246:	8e650513          	addi	a0,a0,-1818 # 80018b28 <barrier_arr>
    8000424a:	079a                	slli	a5,a5,0x6
    8000424c:	0004a023          	sw	zero,0(s1)
    cond_broadcast(&(barrier_arr[barr_id].cv));
    80004250:	03878793          	addi	a5,a5,56
    80004254:	953e                	add	a0,a0,a5
    80004256:	00004097          	auipc	ra,0x4
    8000425a:	8bc080e7          	jalr	-1860(ra) # 80007b12 <cond_broadcast>
    8000425e:	bf71                	j	800041fa <sys_barrier+0xbc>

0000000080004260 <sys_barrier_free>:

uint64
sys_barrier_free(void)
{
    80004260:	1101                	addi	sp,sp,-32
    80004262:	ec06                	sd	ra,24(sp)
    80004264:	e822                	sd	s0,16(sp)
    80004266:	1000                	addi	s0,sp,32
  int i;
  if (argint(0, &i) < 0)
    80004268:	fec40593          	addi	a1,s0,-20
    8000426c:	4501                	li	a0,0
    8000426e:	00000097          	auipc	ra,0x0
    80004272:	96c080e7          	jalr	-1684(ra) # 80003bda <argint>
    80004276:	02054163          	bltz	a0,80004298 <sys_barrier_free+0x38>
    return -1;

  barrier_arr[i].count = -1;
    8000427a:	fec42703          	lw	a4,-20(s0)
    8000427e:	071a                	slli	a4,a4,0x6
    80004280:	00015797          	auipc	a5,0x15
    80004284:	8a878793          	addi	a5,a5,-1880 # 80018b28 <barrier_arr>
    80004288:	97ba                	add	a5,a5,a4
    8000428a:	577d                	li	a4,-1
    8000428c:	c398                	sw	a4,0(a5)
  return 1;
    8000428e:	4505                	li	a0,1
}
    80004290:	60e2                	ld	ra,24(sp)
    80004292:	6442                	ld	s0,16(sp)
    80004294:	6105                	addi	sp,sp,32
    80004296:	8082                	ret
    return -1;
    80004298:	557d                	li	a0,-1
    8000429a:	bfdd                	j	80004290 <sys_barrier_free+0x30>

000000008000429c <sys_buffer_cond_init>:

uint64
sys_buffer_cond_init(void)
{
    8000429c:	7179                	addi	sp,sp,-48
    8000429e:	f406                	sd	ra,40(sp)
    800042a0:	f022                	sd	s0,32(sp)
    800042a2:	ec26                	sd	s1,24(sp)
    800042a4:	e84a                	sd	s2,16(sp)
    800042a6:	e44e                	sd	s3,8(sp)
    800042a8:	e052                	sd	s4,0(sp)
    800042aa:	1800                	addi	s0,sp,48
  initsleeplock(&(lock_delete), "del");
    800042ac:	00005597          	auipc	a1,0x5
    800042b0:	56458593          	addi	a1,a1,1380 # 80009810 <syscalls+0x1d0>
    800042b4:	00015517          	auipc	a0,0x15
    800042b8:	af450513          	addi	a0,a0,-1292 # 80018da8 <lock_delete>
    800042bc:	00002097          	auipc	ra,0x2
    800042c0:	968080e7          	jalr	-1688(ra) # 80005c24 <initsleeplock>
  initsleeplock(&(lock_insert), "ins");
    800042c4:	00005597          	auipc	a1,0x5
    800042c8:	55458593          	addi	a1,a1,1364 # 80009818 <syscalls+0x1d8>
    800042cc:	00015517          	auipc	a0,0x15
    800042d0:	b0c50513          	addi	a0,a0,-1268 # 80018dd8 <lock_insert>
    800042d4:	00002097          	auipc	ra,0x2
    800042d8:	950080e7          	jalr	-1712(ra) # 80005c24 <initsleeplock>
  initsleeplock(&(lock_print), "pri");
    800042dc:	00005597          	auipc	a1,0x5
    800042e0:	54458593          	addi	a1,a1,1348 # 80009820 <syscalls+0x1e0>
    800042e4:	00015517          	auipc	a0,0x15
    800042e8:	b2450513          	addi	a0,a0,-1244 # 80018e08 <lock_print>
    800042ec:	00002097          	auipc	ra,0x2
    800042f0:	938080e7          	jalr	-1736(ra) # 80005c24 <initsleeplock>
  for (int i = 0; i < 20; i++)
    800042f4:	00015497          	auipc	s1,0x15
    800042f8:	b4c48493          	addi	s1,s1,-1204 # 80018e40 <buff_arr+0x8>
    800042fc:	00015a17          	auipc	s4,0x15
    80004300:	044a0a13          	addi	s4,s4,68 # 80019340 <empty+0x8>
  {
    buff_arr[i].x = -1;
    80004304:	59fd                	li	s3,-1
    buff_arr[i].full = 0;
    initsleeplock(&(buff_arr[i].buff_lock), "buff_lock");
    80004306:	00005917          	auipc	s2,0x5
    8000430a:	52290913          	addi	s2,s2,1314 # 80009828 <syscalls+0x1e8>
    buff_arr[i].x = -1;
    8000430e:	ff34ac23          	sw	s3,-8(s1)
    buff_arr[i].full = 0;
    80004312:	fe04ae23          	sw	zero,-4(s1)
    initsleeplock(&(buff_arr[i].buff_lock), "buff_lock");
    80004316:	85ca                	mv	a1,s2
    80004318:	8526                	mv	a0,s1
    8000431a:	00002097          	auipc	ra,0x2
    8000431e:	90a080e7          	jalr	-1782(ra) # 80005c24 <initsleeplock>
    buff_arr[i].inserted.cond = 0;
    80004322:	0204a823          	sw	zero,48(s1)
    buff_arr[i].deleted.cond = 0;
    80004326:	0204aa23          	sw	zero,52(s1)
  for (int i = 0; i < 20; i++)
    8000432a:	04048493          	addi	s1,s1,64
    8000432e:	ff4490e3          	bne	s1,s4,8000430e <sys_buffer_cond_init+0x72>
  }
  return 1;
}
    80004332:	4505                	li	a0,1
    80004334:	70a2                	ld	ra,40(sp)
    80004336:	7402                	ld	s0,32(sp)
    80004338:	64e2                	ld	s1,24(sp)
    8000433a:	6942                	ld	s2,16(sp)
    8000433c:	69a2                	ld	s3,8(sp)
    8000433e:	6a02                	ld	s4,0(sp)
    80004340:	6145                	addi	sp,sp,48
    80004342:	8082                	ret

0000000080004344 <sys_cond_produce>:

uint64
sys_cond_produce(void)
{
    80004344:	715d                	addi	sp,sp,-80
    80004346:	e486                	sd	ra,72(sp)
    80004348:	e0a2                	sd	s0,64(sp)
    8000434a:	fc26                	sd	s1,56(sp)
    8000434c:	f84a                	sd	s2,48(sp)
    8000434e:	f44e                	sd	s3,40(sp)
    80004350:	f052                	sd	s4,32(sp)
    80004352:	ec56                	sd	s5,24(sp)
    80004354:	0880                	addi	s0,sp,80
  int prod;
  int index_prod;
  if (argint(0, &prod) < 0)
    80004356:	fbc40593          	addi	a1,s0,-68
    8000435a:	4501                	li	a0,0
    8000435c:	00000097          	auipc	ra,0x0
    80004360:	87e080e7          	jalr	-1922(ra) # 80003bda <argint>
    return -1;
    80004364:	57fd                	li	a5,-1
  if (argint(0, &prod) < 0)
    80004366:	0a054f63          	bltz	a0,80004424 <sys_cond_produce+0xe0>

  acquiresleep(&(lock_insert));
    8000436a:	00015497          	auipc	s1,0x15
    8000436e:	a6e48493          	addi	s1,s1,-1426 # 80018dd8 <lock_insert>
    80004372:	8526                	mv	a0,s1
    80004374:	00002097          	auipc	ra,0x2
    80004378:	8ea080e7          	jalr	-1814(ra) # 80005c5e <acquiresleep>
  index_prod = tail;
    8000437c:	00006717          	auipc	a4,0x6
    80004380:	d0070713          	addi	a4,a4,-768 # 8000a07c <tail>
    80004384:	00072a03          	lw	s4,0(a4)
  tail = (tail + 1) % 20;
    80004388:	001a079b          	addiw	a5,s4,1
    8000438c:	46d1                	li	a3,20
    8000438e:	02d7e7bb          	remw	a5,a5,a3
    80004392:	c31c                	sw	a5,0(a4)
  releasesleep(&lock_insert);
    80004394:	8526                	mv	a0,s1
    80004396:	00002097          	auipc	ra,0x2
    8000439a:	91e080e7          	jalr	-1762(ra) # 80005cb4 <releasesleep>
  acquiresleep(&(buff_arr[index_prod].buff_lock));
    8000439e:	006a1a93          	slli	s5,s4,0x6
    800043a2:	00015497          	auipc	s1,0x15
    800043a6:	a9e48493          	addi	s1,s1,-1378 # 80018e40 <buff_arr+0x8>
    800043aa:	94d6                	add	s1,s1,s5
    800043ac:	8526                	mv	a0,s1
    800043ae:	00002097          	auipc	ra,0x2
    800043b2:	8b0080e7          	jalr	-1872(ra) # 80005c5e <acquiresleep>
  while (buff_arr[index_prod].full)
    800043b6:	00014797          	auipc	a5,0x14
    800043ba:	77278793          	addi	a5,a5,1906 # 80018b28 <barrier_arr>
    800043be:	97d6                	add	a5,a5,s5
    800043c0:	3147a783          	lw	a5,788(a5)
    800043c4:	c785                	beqz	a5,800043ec <sys_cond_produce+0xa8>
  {
    cond_wait(&(buff_arr[index_prod].deleted), &(buff_arr[index_prod].buff_lock));
    800043c6:	00015997          	auipc	s3,0x15
    800043ca:	aae98993          	addi	s3,s3,-1362 # 80018e74 <buff_arr+0x3c>
    800043ce:	99d6                	add	s3,s3,s5
  while (buff_arr[index_prod].full)
    800043d0:	00014917          	auipc	s2,0x14
    800043d4:	75890913          	addi	s2,s2,1880 # 80018b28 <barrier_arr>
    800043d8:	9956                	add	s2,s2,s5
    cond_wait(&(buff_arr[index_prod].deleted), &(buff_arr[index_prod].buff_lock));
    800043da:	85a6                	mv	a1,s1
    800043dc:	854e                	mv	a0,s3
    800043de:	00003097          	auipc	ra,0x3
    800043e2:	704080e7          	jalr	1796(ra) # 80007ae2 <cond_wait>
  while (buff_arr[index_prod].full)
    800043e6:	31492783          	lw	a5,788(s2)
    800043ea:	fbe5                	bnez	a5,800043da <sys_cond_produce+0x96>
  }
  buff_arr[index_prod].x = prod;
    800043ec:	0a1a                	slli	s4,s4,0x6
    800043ee:	00014797          	auipc	a5,0x14
    800043f2:	73a78793          	addi	a5,a5,1850 # 80018b28 <barrier_arr>
    800043f6:	97d2                	add	a5,a5,s4
    800043f8:	fbc42703          	lw	a4,-68(s0)
    800043fc:	30e7a823          	sw	a4,784(a5)
  buff_arr[index_prod].full = 1;
    80004400:	4705                	li	a4,1
    80004402:	30e7aa23          	sw	a4,788(a5)
  cond_signal(&(buff_arr[index_prod].inserted));
    80004406:	00015517          	auipc	a0,0x15
    8000440a:	a6a50513          	addi	a0,a0,-1430 # 80018e70 <buff_arr+0x38>
    8000440e:	9556                	add	a0,a0,s5
    80004410:	00003097          	auipc	ra,0x3
    80004414:	6ea080e7          	jalr	1770(ra) # 80007afa <cond_signal>
  releasesleep(&(buff_arr[index_prod].buff_lock));
    80004418:	8526                	mv	a0,s1
    8000441a:	00002097          	auipc	ra,0x2
    8000441e:	89a080e7          	jalr	-1894(ra) # 80005cb4 <releasesleep>

  return 1;
    80004422:	4785                	li	a5,1
}
    80004424:	853e                	mv	a0,a5
    80004426:	60a6                	ld	ra,72(sp)
    80004428:	6406                	ld	s0,64(sp)
    8000442a:	74e2                	ld	s1,56(sp)
    8000442c:	7942                	ld	s2,48(sp)
    8000442e:	79a2                	ld	s3,40(sp)
    80004430:	7a02                	ld	s4,32(sp)
    80004432:	6ae2                	ld	s5,24(sp)
    80004434:	6161                	addi	sp,sp,80
    80004436:	8082                	ret

0000000080004438 <sys_cond_consume>:

uint64
sys_cond_consume(void)
{
    80004438:	7139                	addi	sp,sp,-64
    8000443a:	fc06                	sd	ra,56(sp)
    8000443c:	f822                	sd	s0,48(sp)
    8000443e:	f426                	sd	s1,40(sp)
    80004440:	f04a                	sd	s2,32(sp)
    80004442:	ec4e                	sd	s3,24(sp)
    80004444:	e852                	sd	s4,16(sp)
    80004446:	e456                	sd	s5,8(sp)
    80004448:	0080                	addi	s0,sp,64
  int index_cons, v;
  acquiresleep(&(lock_delete));
    8000444a:	00015497          	auipc	s1,0x15
    8000444e:	95e48493          	addi	s1,s1,-1698 # 80018da8 <lock_delete>
    80004452:	8526                	mv	a0,s1
    80004454:	00002097          	auipc	ra,0x2
    80004458:	80a080e7          	jalr	-2038(ra) # 80005c5e <acquiresleep>
  index_cons = head;
    8000445c:	00006717          	auipc	a4,0x6
    80004460:	c1c70713          	addi	a4,a4,-996 # 8000a078 <head>
    80004464:	00072a03          	lw	s4,0(a4)
  head = (head + 1) % 20;
    80004468:	001a079b          	addiw	a5,s4,1
    8000446c:	46d1                	li	a3,20
    8000446e:	02d7e7bb          	remw	a5,a5,a3
    80004472:	c31c                	sw	a5,0(a4)
  releasesleep(&(lock_delete));
    80004474:	8526                	mv	a0,s1
    80004476:	00002097          	auipc	ra,0x2
    8000447a:	83e080e7          	jalr	-1986(ra) # 80005cb4 <releasesleep>
  acquiresleep(&(buff_arr[index_cons].buff_lock));
    8000447e:	006a1a93          	slli	s5,s4,0x6
    80004482:	00015497          	auipc	s1,0x15
    80004486:	9be48493          	addi	s1,s1,-1602 # 80018e40 <buff_arr+0x8>
    8000448a:	94d6                	add	s1,s1,s5
    8000448c:	8526                	mv	a0,s1
    8000448e:	00001097          	auipc	ra,0x1
    80004492:	7d0080e7          	jalr	2000(ra) # 80005c5e <acquiresleep>
  while (!buff_arr[index_cons].full)
    80004496:	00014797          	auipc	a5,0x14
    8000449a:	69278793          	addi	a5,a5,1682 # 80018b28 <barrier_arr>
    8000449e:	97d6                	add	a5,a5,s5
    800044a0:	3147a783          	lw	a5,788(a5)
    800044a4:	e785                	bnez	a5,800044cc <sys_cond_consume+0x94>
  {
    cond_wait(&(buff_arr[index_cons].inserted), &(buff_arr[index_cons].buff_lock));
    800044a6:	00015997          	auipc	s3,0x15
    800044aa:	9ca98993          	addi	s3,s3,-1590 # 80018e70 <buff_arr+0x38>
    800044ae:	99d6                	add	s3,s3,s5
  while (!buff_arr[index_cons].full)
    800044b0:	00014917          	auipc	s2,0x14
    800044b4:	67890913          	addi	s2,s2,1656 # 80018b28 <barrier_arr>
    800044b8:	9956                	add	s2,s2,s5
    cond_wait(&(buff_arr[index_cons].inserted), &(buff_arr[index_cons].buff_lock));
    800044ba:	85a6                	mv	a1,s1
    800044bc:	854e                	mv	a0,s3
    800044be:	00003097          	auipc	ra,0x3
    800044c2:	624080e7          	jalr	1572(ra) # 80007ae2 <cond_wait>
  while (!buff_arr[index_cons].full)
    800044c6:	31492783          	lw	a5,788(s2)
    800044ca:	dbe5                	beqz	a5,800044ba <sys_cond_consume+0x82>
  }
  v = buff_arr[index_cons].x;
    800044cc:	0a1a                	slli	s4,s4,0x6
    800044ce:	00014797          	auipc	a5,0x14
    800044d2:	65a78793          	addi	a5,a5,1626 # 80018b28 <barrier_arr>
    800044d6:	97d2                	add	a5,a5,s4
    800044d8:	3107a903          	lw	s2,784(a5)
  buff_arr[index_cons].full = 0;
    800044dc:	3007aa23          	sw	zero,788(a5)
  cond_signal(&(buff_arr[index_cons].deleted));
    800044e0:	00015517          	auipc	a0,0x15
    800044e4:	99450513          	addi	a0,a0,-1644 # 80018e74 <buff_arr+0x3c>
    800044e8:	9556                	add	a0,a0,s5
    800044ea:	00003097          	auipc	ra,0x3
    800044ee:	610080e7          	jalr	1552(ra) # 80007afa <cond_signal>
  releasesleep(&(buff_arr[index_cons].buff_lock));
    800044f2:	8526                	mv	a0,s1
    800044f4:	00001097          	auipc	ra,0x1
    800044f8:	7c0080e7          	jalr	1984(ra) # 80005cb4 <releasesleep>
  acquiresleep(&(lock_print));
    800044fc:	00015497          	auipc	s1,0x15
    80004500:	90c48493          	addi	s1,s1,-1780 # 80018e08 <lock_print>
    80004504:	8526                	mv	a0,s1
    80004506:	00001097          	auipc	ra,0x1
    8000450a:	758080e7          	jalr	1880(ra) # 80005c5e <acquiresleep>
  printf("%d ", v);
    8000450e:	85ca                	mv	a1,s2
    80004510:	00005517          	auipc	a0,0x5
    80004514:	32850513          	addi	a0,a0,808 # 80009838 <syscalls+0x1f8>
    80004518:	ffffc097          	auipc	ra,0xffffc
    8000451c:	06a080e7          	jalr	106(ra) # 80000582 <printf>
  releasesleep(&(lock_print));
    80004520:	8526                	mv	a0,s1
    80004522:	00001097          	auipc	ra,0x1
    80004526:	792080e7          	jalr	1938(ra) # 80005cb4 <releasesleep>

  return 1;
}
    8000452a:	4505                	li	a0,1
    8000452c:	70e2                	ld	ra,56(sp)
    8000452e:	7442                	ld	s0,48(sp)
    80004530:	74a2                	ld	s1,40(sp)
    80004532:	7902                	ld	s2,32(sp)
    80004534:	69e2                	ld	s3,24(sp)
    80004536:	6a42                	ld	s4,16(sp)
    80004538:	6aa2                	ld	s5,8(sp)
    8000453a:	6121                	addi	sp,sp,64
    8000453c:	8082                	ret

000000008000453e <sys_buffer_sem_init>:

uint64
sys_buffer_sem_init(void)
{
    8000453e:	1141                	addi	sp,sp,-16
    80004540:	e406                	sd	ra,8(sp)
    80004542:	e022                	sd	s0,0(sp)
    80004544:	0800                	addi	s0,sp,16
  nextp = nextc = 0;
    80004546:	00006797          	auipc	a5,0x6
    8000454a:	b207a523          	sw	zero,-1238(a5) # 8000a070 <nextc>
    8000454e:	00006797          	auipc	a5,0x6
    80004552:	b207a323          	sw	zero,-1242(a5) # 8000a074 <nextp>
  sem_init(&(empty), 20);
    80004556:	45d1                	li	a1,20
    80004558:	00015517          	auipc	a0,0x15
    8000455c:	de050513          	addi	a0,a0,-544 # 80019338 <empty>
    80004560:	00003097          	auipc	ra,0x3
    80004564:	5ca080e7          	jalr	1482(ra) # 80007b2a <sem_init>
  sem_init(&(full), 0);
    80004568:	4581                	li	a1,0
    8000456a:	00015517          	auipc	a0,0x15
    8000456e:	e0e50513          	addi	a0,a0,-498 # 80019378 <full>
    80004572:	00003097          	auipc	ra,0x3
    80004576:	5b8080e7          	jalr	1464(ra) # 80007b2a <sem_init>
  sem_init(&pro, 1);
    8000457a:	4585                	li	a1,1
    8000457c:	00015517          	auipc	a0,0x15
    80004580:	e3c50513          	addi	a0,a0,-452 # 800193b8 <pro>
    80004584:	00003097          	auipc	ra,0x3
    80004588:	5a6080e7          	jalr	1446(ra) # 80007b2a <sem_init>
  sem_init(&con, 1);
    8000458c:	4585                	li	a1,1
    8000458e:	00015517          	auipc	a0,0x15
    80004592:	e6a50513          	addi	a0,a0,-406 # 800193f8 <con>
    80004596:	00003097          	auipc	ra,0x3
    8000459a:	594080e7          	jalr	1428(ra) # 80007b2a <sem_init>
  for (int i = 0; i < 20; i++)
    8000459e:	00015797          	auipc	a5,0x15
    800045a2:	e9a78793          	addi	a5,a5,-358 # 80019438 <buff_arr_sem>
    800045a6:	00015697          	auipc	a3,0x15
    800045aa:	ee268693          	addi	a3,a3,-286 # 80019488 <bcache>
  {
    buff_arr_sem[i] = -1;
    800045ae:	577d                	li	a4,-1
    800045b0:	c398                	sw	a4,0(a5)
  for (int i = 0; i < 20; i++)
    800045b2:	0791                	addi	a5,a5,4
    800045b4:	fed79ee3          	bne	a5,a3,800045b0 <sys_buffer_sem_init+0x72>
  }
  return 1;
}
    800045b8:	4505                	li	a0,1
    800045ba:	60a2                	ld	ra,8(sp)
    800045bc:	6402                	ld	s0,0(sp)
    800045be:	0141                	addi	sp,sp,16
    800045c0:	8082                	ret

00000000800045c2 <sys_sem_produce>:

uint64
sys_sem_produce(void)
{
    800045c2:	7179                	addi	sp,sp,-48
    800045c4:	f406                	sd	ra,40(sp)
    800045c6:	f022                	sd	s0,32(sp)
    800045c8:	ec26                	sd	s1,24(sp)
    800045ca:	1800                	addi	s0,sp,48
  int item;
  if (argint(0, &item) < 0)
    800045cc:	fdc40593          	addi	a1,s0,-36
    800045d0:	4501                	li	a0,0
    800045d2:	fffff097          	auipc	ra,0xfffff
    800045d6:	608080e7          	jalr	1544(ra) # 80003bda <argint>
    return -1;
    800045da:	57fd                	li	a5,-1
  if (argint(0, &item) < 0)
    800045dc:	06054663          	bltz	a0,80004648 <sys_sem_produce+0x86>
  sem_wait(&empty);
    800045e0:	00015517          	auipc	a0,0x15
    800045e4:	d5850513          	addi	a0,a0,-680 # 80019338 <empty>
    800045e8:	00003097          	auipc	ra,0x3
    800045ec:	56a080e7          	jalr	1386(ra) # 80007b52 <sem_wait>
  sem_wait(&pro);
    800045f0:	00015497          	auipc	s1,0x15
    800045f4:	dc848493          	addi	s1,s1,-568 # 800193b8 <pro>
    800045f8:	8526                	mv	a0,s1
    800045fa:	00003097          	auipc	ra,0x3
    800045fe:	558080e7          	jalr	1368(ra) # 80007b52 <sem_wait>
  buff_arr_sem[nextp] = item;
    80004602:	00006697          	auipc	a3,0x6
    80004606:	a7268693          	addi	a3,a3,-1422 # 8000a074 <nextp>
    8000460a:	429c                	lw	a5,0(a3)
    8000460c:	00279613          	slli	a2,a5,0x2
    80004610:	00015717          	auipc	a4,0x15
    80004614:	51870713          	addi	a4,a4,1304 # 80019b28 <bcache+0x6a0>
    80004618:	9732                	add	a4,a4,a2
    8000461a:	fdc42603          	lw	a2,-36(s0)
    8000461e:	90c72823          	sw	a2,-1776(a4)
  nextp = (nextp + 1) % 20;
    80004622:	2785                	addiw	a5,a5,1
    80004624:	4751                	li	a4,20
    80004626:	02e7e7bb          	remw	a5,a5,a4
    8000462a:	c29c                	sw	a5,0(a3)
  sem_post(&pro);
    8000462c:	8526                	mv	a0,s1
    8000462e:	00003097          	auipc	ra,0x3
    80004632:	57a080e7          	jalr	1402(ra) # 80007ba8 <sem_post>
  sem_post(&full);
    80004636:	00015517          	auipc	a0,0x15
    8000463a:	d4250513          	addi	a0,a0,-702 # 80019378 <full>
    8000463e:	00003097          	auipc	ra,0x3
    80004642:	56a080e7          	jalr	1386(ra) # 80007ba8 <sem_post>
  return 1;
    80004646:	4785                	li	a5,1
}
    80004648:	853e                	mv	a0,a5
    8000464a:	70a2                	ld	ra,40(sp)
    8000464c:	7402                	ld	s0,32(sp)
    8000464e:	64e2                	ld	s1,24(sp)
    80004650:	6145                	addi	sp,sp,48
    80004652:	8082                	ret

0000000080004654 <sys_sem_consume>:

uint64
sys_sem_consume(void)
{
    80004654:	1101                	addi	sp,sp,-32
    80004656:	ec06                	sd	ra,24(sp)
    80004658:	e822                	sd	s0,16(sp)
    8000465a:	e426                	sd	s1,8(sp)
    8000465c:	e04a                	sd	s2,0(sp)
    8000465e:	1000                	addi	s0,sp,32
  sem_wait(&full);
    80004660:	00015517          	auipc	a0,0x15
    80004664:	d1850513          	addi	a0,a0,-744 # 80019378 <full>
    80004668:	00003097          	auipc	ra,0x3
    8000466c:	4ea080e7          	jalr	1258(ra) # 80007b52 <sem_wait>
  sem_wait(&con);
    80004670:	00015497          	auipc	s1,0x15
    80004674:	d8848493          	addi	s1,s1,-632 # 800193f8 <con>
    80004678:	8526                	mv	a0,s1
    8000467a:	00003097          	auipc	ra,0x3
    8000467e:	4d8080e7          	jalr	1240(ra) # 80007b52 <sem_wait>
  int item = buff_arr_sem[nextc];
    80004682:	00006697          	auipc	a3,0x6
    80004686:	9ee68693          	addi	a3,a3,-1554 # 8000a070 <nextc>
    8000468a:	429c                	lw	a5,0(a3)
    8000468c:	00279613          	slli	a2,a5,0x2
    80004690:	00015717          	auipc	a4,0x15
    80004694:	49870713          	addi	a4,a4,1176 # 80019b28 <bcache+0x6a0>
    80004698:	9732                	add	a4,a4,a2
    8000469a:	91072903          	lw	s2,-1776(a4)
  nextc = (nextc + 1) % 20;
    8000469e:	2785                	addiw	a5,a5,1
    800046a0:	4751                	li	a4,20
    800046a2:	02e7e7bb          	remw	a5,a5,a4
    800046a6:	c29c                	sw	a5,0(a3)
  sem_post(&con);
    800046a8:	8526                	mv	a0,s1
    800046aa:	00003097          	auipc	ra,0x3
    800046ae:	4fe080e7          	jalr	1278(ra) # 80007ba8 <sem_post>
  sem_post(&empty);
    800046b2:	00015517          	auipc	a0,0x15
    800046b6:	c8650513          	addi	a0,a0,-890 # 80019338 <empty>
    800046ba:	00003097          	auipc	ra,0x3
    800046be:	4ee080e7          	jalr	1262(ra) # 80007ba8 <sem_post>
  acquiresleep(&(lock_print));
    800046c2:	00014497          	auipc	s1,0x14
    800046c6:	74648493          	addi	s1,s1,1862 # 80018e08 <lock_print>
    800046ca:	8526                	mv	a0,s1
    800046cc:	00001097          	auipc	ra,0x1
    800046d0:	592080e7          	jalr	1426(ra) # 80005c5e <acquiresleep>
  printf("%d ", item);
    800046d4:	85ca                	mv	a1,s2
    800046d6:	00005517          	auipc	a0,0x5
    800046da:	16250513          	addi	a0,a0,354 # 80009838 <syscalls+0x1f8>
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	ea4080e7          	jalr	-348(ra) # 80000582 <printf>
  releasesleep(&(lock_print));
    800046e6:	8526                	mv	a0,s1
    800046e8:	00001097          	auipc	ra,0x1
    800046ec:	5cc080e7          	jalr	1484(ra) # 80005cb4 <releasesleep>
  return 1;
    800046f0:	4505                	li	a0,1
    800046f2:	60e2                	ld	ra,24(sp)
    800046f4:	6442                	ld	s0,16(sp)
    800046f6:	64a2                	ld	s1,8(sp)
    800046f8:	6902                	ld	s2,0(sp)
    800046fa:	6105                	addi	sp,sp,32
    800046fc:	8082                	ret

00000000800046fe <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800046fe:	7179                	addi	sp,sp,-48
    80004700:	f406                	sd	ra,40(sp)
    80004702:	f022                	sd	s0,32(sp)
    80004704:	ec26                	sd	s1,24(sp)
    80004706:	e84a                	sd	s2,16(sp)
    80004708:	e44e                	sd	s3,8(sp)
    8000470a:	e052                	sd	s4,0(sp)
    8000470c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000470e:	00005597          	auipc	a1,0x5
    80004712:	13258593          	addi	a1,a1,306 # 80009840 <syscalls+0x200>
    80004716:	00015517          	auipc	a0,0x15
    8000471a:	d7250513          	addi	a0,a0,-654 # 80019488 <bcache>
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	420080e7          	jalr	1056(ra) # 80000b3e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80004726:	0001d797          	auipc	a5,0x1d
    8000472a:	d6278793          	addi	a5,a5,-670 # 80021488 <bcache+0x8000>
    8000472e:	0001d717          	auipc	a4,0x1d
    80004732:	fc270713          	addi	a4,a4,-62 # 800216f0 <bcache+0x8268>
    80004736:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000473a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000473e:	00015497          	auipc	s1,0x15
    80004742:	d6248493          	addi	s1,s1,-670 # 800194a0 <bcache+0x18>
    b->next = bcache.head.next;
    80004746:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80004748:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000474a:	00005a17          	auipc	s4,0x5
    8000474e:	0fea0a13          	addi	s4,s4,254 # 80009848 <syscalls+0x208>
    b->next = bcache.head.next;
    80004752:	2b893783          	ld	a5,696(s2)
    80004756:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80004758:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000475c:	85d2                	mv	a1,s4
    8000475e:	01048513          	addi	a0,s1,16
    80004762:	00001097          	auipc	ra,0x1
    80004766:	4c2080e7          	jalr	1218(ra) # 80005c24 <initsleeplock>
    bcache.head.next->prev = b;
    8000476a:	2b893783          	ld	a5,696(s2)
    8000476e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80004770:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004774:	45848493          	addi	s1,s1,1112
    80004778:	fd349de3          	bne	s1,s3,80004752 <binit+0x54>
  }
}
    8000477c:	70a2                	ld	ra,40(sp)
    8000477e:	7402                	ld	s0,32(sp)
    80004780:	64e2                	ld	s1,24(sp)
    80004782:	6942                	ld	s2,16(sp)
    80004784:	69a2                	ld	s3,8(sp)
    80004786:	6a02                	ld	s4,0(sp)
    80004788:	6145                	addi	sp,sp,48
    8000478a:	8082                	ret

000000008000478c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000478c:	7179                	addi	sp,sp,-48
    8000478e:	f406                	sd	ra,40(sp)
    80004790:	f022                	sd	s0,32(sp)
    80004792:	ec26                	sd	s1,24(sp)
    80004794:	e84a                	sd	s2,16(sp)
    80004796:	e44e                	sd	s3,8(sp)
    80004798:	1800                	addi	s0,sp,48
    8000479a:	892a                	mv	s2,a0
    8000479c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000479e:	00015517          	auipc	a0,0x15
    800047a2:	cea50513          	addi	a0,a0,-790 # 80019488 <bcache>
    800047a6:	ffffc097          	auipc	ra,0xffffc
    800047aa:	428080e7          	jalr	1064(ra) # 80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800047ae:	0001d497          	auipc	s1,0x1d
    800047b2:	f924b483          	ld	s1,-110(s1) # 80021740 <bcache+0x82b8>
    800047b6:	0001d797          	auipc	a5,0x1d
    800047ba:	f3a78793          	addi	a5,a5,-198 # 800216f0 <bcache+0x8268>
    800047be:	02f48f63          	beq	s1,a5,800047fc <bread+0x70>
    800047c2:	873e                	mv	a4,a5
    800047c4:	a021                	j	800047cc <bread+0x40>
    800047c6:	68a4                	ld	s1,80(s1)
    800047c8:	02e48a63          	beq	s1,a4,800047fc <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800047cc:	449c                	lw	a5,8(s1)
    800047ce:	ff279ce3          	bne	a5,s2,800047c6 <bread+0x3a>
    800047d2:	44dc                	lw	a5,12(s1)
    800047d4:	ff3799e3          	bne	a5,s3,800047c6 <bread+0x3a>
      b->refcnt++;
    800047d8:	40bc                	lw	a5,64(s1)
    800047da:	2785                	addiw	a5,a5,1
    800047dc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800047de:	00015517          	auipc	a0,0x15
    800047e2:	caa50513          	addi	a0,a0,-854 # 80019488 <bcache>
    800047e6:	ffffc097          	auipc	ra,0xffffc
    800047ea:	49c080e7          	jalr	1180(ra) # 80000c82 <release>
      acquiresleep(&b->lock);
    800047ee:	01048513          	addi	a0,s1,16
    800047f2:	00001097          	auipc	ra,0x1
    800047f6:	46c080e7          	jalr	1132(ra) # 80005c5e <acquiresleep>
      return b;
    800047fa:	a8b9                	j	80004858 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800047fc:	0001d497          	auipc	s1,0x1d
    80004800:	f3c4b483          	ld	s1,-196(s1) # 80021738 <bcache+0x82b0>
    80004804:	0001d797          	auipc	a5,0x1d
    80004808:	eec78793          	addi	a5,a5,-276 # 800216f0 <bcache+0x8268>
    8000480c:	00f48863          	beq	s1,a5,8000481c <bread+0x90>
    80004810:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80004812:	40bc                	lw	a5,64(s1)
    80004814:	cf81                	beqz	a5,8000482c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004816:	64a4                	ld	s1,72(s1)
    80004818:	fee49de3          	bne	s1,a4,80004812 <bread+0x86>
  panic("bget: no buffers");
    8000481c:	00005517          	auipc	a0,0x5
    80004820:	03450513          	addi	a0,a0,52 # 80009850 <syscalls+0x210>
    80004824:	ffffc097          	auipc	ra,0xffffc
    80004828:	d14080e7          	jalr	-748(ra) # 80000538 <panic>
      b->dev = dev;
    8000482c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80004830:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80004834:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80004838:	4785                	li	a5,1
    8000483a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000483c:	00015517          	auipc	a0,0x15
    80004840:	c4c50513          	addi	a0,a0,-948 # 80019488 <bcache>
    80004844:	ffffc097          	auipc	ra,0xffffc
    80004848:	43e080e7          	jalr	1086(ra) # 80000c82 <release>
      acquiresleep(&b->lock);
    8000484c:	01048513          	addi	a0,s1,16
    80004850:	00001097          	auipc	ra,0x1
    80004854:	40e080e7          	jalr	1038(ra) # 80005c5e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80004858:	409c                	lw	a5,0(s1)
    8000485a:	cb89                	beqz	a5,8000486c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000485c:	8526                	mv	a0,s1
    8000485e:	70a2                	ld	ra,40(sp)
    80004860:	7402                	ld	s0,32(sp)
    80004862:	64e2                	ld	s1,24(sp)
    80004864:	6942                	ld	s2,16(sp)
    80004866:	69a2                	ld	s3,8(sp)
    80004868:	6145                	addi	sp,sp,48
    8000486a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000486c:	4581                	li	a1,0
    8000486e:	8526                	mv	a0,s1
    80004870:	00003097          	auipc	ra,0x3
    80004874:	f22080e7          	jalr	-222(ra) # 80007792 <virtio_disk_rw>
    b->valid = 1;
    80004878:	4785                	li	a5,1
    8000487a:	c09c                	sw	a5,0(s1)
  return b;
    8000487c:	b7c5                	j	8000485c <bread+0xd0>

000000008000487e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000487e:	1101                	addi	sp,sp,-32
    80004880:	ec06                	sd	ra,24(sp)
    80004882:	e822                	sd	s0,16(sp)
    80004884:	e426                	sd	s1,8(sp)
    80004886:	1000                	addi	s0,sp,32
    80004888:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000488a:	0541                	addi	a0,a0,16
    8000488c:	00001097          	auipc	ra,0x1
    80004890:	46c080e7          	jalr	1132(ra) # 80005cf8 <holdingsleep>
    80004894:	cd01                	beqz	a0,800048ac <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80004896:	4585                	li	a1,1
    80004898:	8526                	mv	a0,s1
    8000489a:	00003097          	auipc	ra,0x3
    8000489e:	ef8080e7          	jalr	-264(ra) # 80007792 <virtio_disk_rw>
}
    800048a2:	60e2                	ld	ra,24(sp)
    800048a4:	6442                	ld	s0,16(sp)
    800048a6:	64a2                	ld	s1,8(sp)
    800048a8:	6105                	addi	sp,sp,32
    800048aa:	8082                	ret
    panic("bwrite");
    800048ac:	00005517          	auipc	a0,0x5
    800048b0:	fbc50513          	addi	a0,a0,-68 # 80009868 <syscalls+0x228>
    800048b4:	ffffc097          	auipc	ra,0xffffc
    800048b8:	c84080e7          	jalr	-892(ra) # 80000538 <panic>

00000000800048bc <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800048bc:	1101                	addi	sp,sp,-32
    800048be:	ec06                	sd	ra,24(sp)
    800048c0:	e822                	sd	s0,16(sp)
    800048c2:	e426                	sd	s1,8(sp)
    800048c4:	e04a                	sd	s2,0(sp)
    800048c6:	1000                	addi	s0,sp,32
    800048c8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800048ca:	01050913          	addi	s2,a0,16
    800048ce:	854a                	mv	a0,s2
    800048d0:	00001097          	auipc	ra,0x1
    800048d4:	428080e7          	jalr	1064(ra) # 80005cf8 <holdingsleep>
    800048d8:	c92d                	beqz	a0,8000494a <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800048da:	854a                	mv	a0,s2
    800048dc:	00001097          	auipc	ra,0x1
    800048e0:	3d8080e7          	jalr	984(ra) # 80005cb4 <releasesleep>

  acquire(&bcache.lock);
    800048e4:	00015517          	auipc	a0,0x15
    800048e8:	ba450513          	addi	a0,a0,-1116 # 80019488 <bcache>
    800048ec:	ffffc097          	auipc	ra,0xffffc
    800048f0:	2e2080e7          	jalr	738(ra) # 80000bce <acquire>
  b->refcnt--;
    800048f4:	40bc                	lw	a5,64(s1)
    800048f6:	37fd                	addiw	a5,a5,-1
    800048f8:	0007871b          	sext.w	a4,a5
    800048fc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800048fe:	eb05                	bnez	a4,8000492e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80004900:	68bc                	ld	a5,80(s1)
    80004902:	64b8                	ld	a4,72(s1)
    80004904:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80004906:	64bc                	ld	a5,72(s1)
    80004908:	68b8                	ld	a4,80(s1)
    8000490a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000490c:	0001d797          	auipc	a5,0x1d
    80004910:	b7c78793          	addi	a5,a5,-1156 # 80021488 <bcache+0x8000>
    80004914:	2b87b703          	ld	a4,696(a5)
    80004918:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000491a:	0001d717          	auipc	a4,0x1d
    8000491e:	dd670713          	addi	a4,a4,-554 # 800216f0 <bcache+0x8268>
    80004922:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80004924:	2b87b703          	ld	a4,696(a5)
    80004928:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000492a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000492e:	00015517          	auipc	a0,0x15
    80004932:	b5a50513          	addi	a0,a0,-1190 # 80019488 <bcache>
    80004936:	ffffc097          	auipc	ra,0xffffc
    8000493a:	34c080e7          	jalr	844(ra) # 80000c82 <release>
}
    8000493e:	60e2                	ld	ra,24(sp)
    80004940:	6442                	ld	s0,16(sp)
    80004942:	64a2                	ld	s1,8(sp)
    80004944:	6902                	ld	s2,0(sp)
    80004946:	6105                	addi	sp,sp,32
    80004948:	8082                	ret
    panic("brelse");
    8000494a:	00005517          	auipc	a0,0x5
    8000494e:	f2650513          	addi	a0,a0,-218 # 80009870 <syscalls+0x230>
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	be6080e7          	jalr	-1050(ra) # 80000538 <panic>

000000008000495a <bpin>:

void
bpin(struct buf *b) {
    8000495a:	1101                	addi	sp,sp,-32
    8000495c:	ec06                	sd	ra,24(sp)
    8000495e:	e822                	sd	s0,16(sp)
    80004960:	e426                	sd	s1,8(sp)
    80004962:	1000                	addi	s0,sp,32
    80004964:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004966:	00015517          	auipc	a0,0x15
    8000496a:	b2250513          	addi	a0,a0,-1246 # 80019488 <bcache>
    8000496e:	ffffc097          	auipc	ra,0xffffc
    80004972:	260080e7          	jalr	608(ra) # 80000bce <acquire>
  b->refcnt++;
    80004976:	40bc                	lw	a5,64(s1)
    80004978:	2785                	addiw	a5,a5,1
    8000497a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000497c:	00015517          	auipc	a0,0x15
    80004980:	b0c50513          	addi	a0,a0,-1268 # 80019488 <bcache>
    80004984:	ffffc097          	auipc	ra,0xffffc
    80004988:	2fe080e7          	jalr	766(ra) # 80000c82 <release>
}
    8000498c:	60e2                	ld	ra,24(sp)
    8000498e:	6442                	ld	s0,16(sp)
    80004990:	64a2                	ld	s1,8(sp)
    80004992:	6105                	addi	sp,sp,32
    80004994:	8082                	ret

0000000080004996 <bunpin>:

void
bunpin(struct buf *b) {
    80004996:	1101                	addi	sp,sp,-32
    80004998:	ec06                	sd	ra,24(sp)
    8000499a:	e822                	sd	s0,16(sp)
    8000499c:	e426                	sd	s1,8(sp)
    8000499e:	1000                	addi	s0,sp,32
    800049a0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800049a2:	00015517          	auipc	a0,0x15
    800049a6:	ae650513          	addi	a0,a0,-1306 # 80019488 <bcache>
    800049aa:	ffffc097          	auipc	ra,0xffffc
    800049ae:	224080e7          	jalr	548(ra) # 80000bce <acquire>
  b->refcnt--;
    800049b2:	40bc                	lw	a5,64(s1)
    800049b4:	37fd                	addiw	a5,a5,-1
    800049b6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800049b8:	00015517          	auipc	a0,0x15
    800049bc:	ad050513          	addi	a0,a0,-1328 # 80019488 <bcache>
    800049c0:	ffffc097          	auipc	ra,0xffffc
    800049c4:	2c2080e7          	jalr	706(ra) # 80000c82 <release>
}
    800049c8:	60e2                	ld	ra,24(sp)
    800049ca:	6442                	ld	s0,16(sp)
    800049cc:	64a2                	ld	s1,8(sp)
    800049ce:	6105                	addi	sp,sp,32
    800049d0:	8082                	ret

00000000800049d2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800049d2:	1101                	addi	sp,sp,-32
    800049d4:	ec06                	sd	ra,24(sp)
    800049d6:	e822                	sd	s0,16(sp)
    800049d8:	e426                	sd	s1,8(sp)
    800049da:	e04a                	sd	s2,0(sp)
    800049dc:	1000                	addi	s0,sp,32
    800049de:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800049e0:	00d5d59b          	srliw	a1,a1,0xd
    800049e4:	0001d797          	auipc	a5,0x1d
    800049e8:	1807a783          	lw	a5,384(a5) # 80021b64 <sb+0x1c>
    800049ec:	9dbd                	addw	a1,a1,a5
    800049ee:	00000097          	auipc	ra,0x0
    800049f2:	d9e080e7          	jalr	-610(ra) # 8000478c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800049f6:	0074f713          	andi	a4,s1,7
    800049fa:	4785                	li	a5,1
    800049fc:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80004a00:	14ce                	slli	s1,s1,0x33
    80004a02:	90d9                	srli	s1,s1,0x36
    80004a04:	00950733          	add	a4,a0,s1
    80004a08:	05874703          	lbu	a4,88(a4)
    80004a0c:	00e7f6b3          	and	a3,a5,a4
    80004a10:	c69d                	beqz	a3,80004a3e <bfree+0x6c>
    80004a12:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80004a14:	94aa                	add	s1,s1,a0
    80004a16:	fff7c793          	not	a5,a5
    80004a1a:	8f7d                	and	a4,a4,a5
    80004a1c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80004a20:	00001097          	auipc	ra,0x1
    80004a24:	120080e7          	jalr	288(ra) # 80005b40 <log_write>
  brelse(bp);
    80004a28:	854a                	mv	a0,s2
    80004a2a:	00000097          	auipc	ra,0x0
    80004a2e:	e92080e7          	jalr	-366(ra) # 800048bc <brelse>
}
    80004a32:	60e2                	ld	ra,24(sp)
    80004a34:	6442                	ld	s0,16(sp)
    80004a36:	64a2                	ld	s1,8(sp)
    80004a38:	6902                	ld	s2,0(sp)
    80004a3a:	6105                	addi	sp,sp,32
    80004a3c:	8082                	ret
    panic("freeing free block");
    80004a3e:	00005517          	auipc	a0,0x5
    80004a42:	e3a50513          	addi	a0,a0,-454 # 80009878 <syscalls+0x238>
    80004a46:	ffffc097          	auipc	ra,0xffffc
    80004a4a:	af2080e7          	jalr	-1294(ra) # 80000538 <panic>

0000000080004a4e <balloc>:
{
    80004a4e:	711d                	addi	sp,sp,-96
    80004a50:	ec86                	sd	ra,88(sp)
    80004a52:	e8a2                	sd	s0,80(sp)
    80004a54:	e4a6                	sd	s1,72(sp)
    80004a56:	e0ca                	sd	s2,64(sp)
    80004a58:	fc4e                	sd	s3,56(sp)
    80004a5a:	f852                	sd	s4,48(sp)
    80004a5c:	f456                	sd	s5,40(sp)
    80004a5e:	f05a                	sd	s6,32(sp)
    80004a60:	ec5e                	sd	s7,24(sp)
    80004a62:	e862                	sd	s8,16(sp)
    80004a64:	e466                	sd	s9,8(sp)
    80004a66:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80004a68:	0001d797          	auipc	a5,0x1d
    80004a6c:	0e47a783          	lw	a5,228(a5) # 80021b4c <sb+0x4>
    80004a70:	cbc1                	beqz	a5,80004b00 <balloc+0xb2>
    80004a72:	8baa                	mv	s7,a0
    80004a74:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004a76:	0001db17          	auipc	s6,0x1d
    80004a7a:	0d2b0b13          	addi	s6,s6,210 # 80021b48 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004a7e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80004a80:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004a82:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004a84:	6c89                	lui	s9,0x2
    80004a86:	a831                	j	80004aa2 <balloc+0x54>
    brelse(bp);
    80004a88:	854a                	mv	a0,s2
    80004a8a:	00000097          	auipc	ra,0x0
    80004a8e:	e32080e7          	jalr	-462(ra) # 800048bc <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004a92:	015c87bb          	addw	a5,s9,s5
    80004a96:	00078a9b          	sext.w	s5,a5
    80004a9a:	004b2703          	lw	a4,4(s6)
    80004a9e:	06eaf163          	bgeu	s5,a4,80004b00 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    80004aa2:	41fad79b          	sraiw	a5,s5,0x1f
    80004aa6:	0137d79b          	srliw	a5,a5,0x13
    80004aaa:	015787bb          	addw	a5,a5,s5
    80004aae:	40d7d79b          	sraiw	a5,a5,0xd
    80004ab2:	01cb2583          	lw	a1,28(s6)
    80004ab6:	9dbd                	addw	a1,a1,a5
    80004ab8:	855e                	mv	a0,s7
    80004aba:	00000097          	auipc	ra,0x0
    80004abe:	cd2080e7          	jalr	-814(ra) # 8000478c <bread>
    80004ac2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004ac4:	004b2503          	lw	a0,4(s6)
    80004ac8:	000a849b          	sext.w	s1,s5
    80004acc:	8762                	mv	a4,s8
    80004ace:	faa4fde3          	bgeu	s1,a0,80004a88 <balloc+0x3a>
      m = 1 << (bi % 8);
    80004ad2:	00777693          	andi	a3,a4,7
    80004ad6:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004ada:	41f7579b          	sraiw	a5,a4,0x1f
    80004ade:	01d7d79b          	srliw	a5,a5,0x1d
    80004ae2:	9fb9                	addw	a5,a5,a4
    80004ae4:	4037d79b          	sraiw	a5,a5,0x3
    80004ae8:	00f90633          	add	a2,s2,a5
    80004aec:	05864603          	lbu	a2,88(a2)
    80004af0:	00c6f5b3          	and	a1,a3,a2
    80004af4:	cd91                	beqz	a1,80004b10 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004af6:	2705                	addiw	a4,a4,1
    80004af8:	2485                	addiw	s1,s1,1
    80004afa:	fd471ae3          	bne	a4,s4,80004ace <balloc+0x80>
    80004afe:	b769                	j	80004a88 <balloc+0x3a>
  panic("balloc: out of blocks");
    80004b00:	00005517          	auipc	a0,0x5
    80004b04:	d9050513          	addi	a0,a0,-624 # 80009890 <syscalls+0x250>
    80004b08:	ffffc097          	auipc	ra,0xffffc
    80004b0c:	a30080e7          	jalr	-1488(ra) # 80000538 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80004b10:	97ca                	add	a5,a5,s2
    80004b12:	8e55                	or	a2,a2,a3
    80004b14:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80004b18:	854a                	mv	a0,s2
    80004b1a:	00001097          	auipc	ra,0x1
    80004b1e:	026080e7          	jalr	38(ra) # 80005b40 <log_write>
        brelse(bp);
    80004b22:	854a                	mv	a0,s2
    80004b24:	00000097          	auipc	ra,0x0
    80004b28:	d98080e7          	jalr	-616(ra) # 800048bc <brelse>
  bp = bread(dev, bno);
    80004b2c:	85a6                	mv	a1,s1
    80004b2e:	855e                	mv	a0,s7
    80004b30:	00000097          	auipc	ra,0x0
    80004b34:	c5c080e7          	jalr	-932(ra) # 8000478c <bread>
    80004b38:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004b3a:	40000613          	li	a2,1024
    80004b3e:	4581                	li	a1,0
    80004b40:	05850513          	addi	a0,a0,88
    80004b44:	ffffc097          	auipc	ra,0xffffc
    80004b48:	186080e7          	jalr	390(ra) # 80000cca <memset>
  log_write(bp);
    80004b4c:	854a                	mv	a0,s2
    80004b4e:	00001097          	auipc	ra,0x1
    80004b52:	ff2080e7          	jalr	-14(ra) # 80005b40 <log_write>
  brelse(bp);
    80004b56:	854a                	mv	a0,s2
    80004b58:	00000097          	auipc	ra,0x0
    80004b5c:	d64080e7          	jalr	-668(ra) # 800048bc <brelse>
}
    80004b60:	8526                	mv	a0,s1
    80004b62:	60e6                	ld	ra,88(sp)
    80004b64:	6446                	ld	s0,80(sp)
    80004b66:	64a6                	ld	s1,72(sp)
    80004b68:	6906                	ld	s2,64(sp)
    80004b6a:	79e2                	ld	s3,56(sp)
    80004b6c:	7a42                	ld	s4,48(sp)
    80004b6e:	7aa2                	ld	s5,40(sp)
    80004b70:	7b02                	ld	s6,32(sp)
    80004b72:	6be2                	ld	s7,24(sp)
    80004b74:	6c42                	ld	s8,16(sp)
    80004b76:	6ca2                	ld	s9,8(sp)
    80004b78:	6125                	addi	sp,sp,96
    80004b7a:	8082                	ret

0000000080004b7c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004b7c:	7179                	addi	sp,sp,-48
    80004b7e:	f406                	sd	ra,40(sp)
    80004b80:	f022                	sd	s0,32(sp)
    80004b82:	ec26                	sd	s1,24(sp)
    80004b84:	e84a                	sd	s2,16(sp)
    80004b86:	e44e                	sd	s3,8(sp)
    80004b88:	e052                	sd	s4,0(sp)
    80004b8a:	1800                	addi	s0,sp,48
    80004b8c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004b8e:	47ad                	li	a5,11
    80004b90:	04b7fe63          	bgeu	a5,a1,80004bec <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80004b94:	ff45849b          	addiw	s1,a1,-12
    80004b98:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004b9c:	0ff00793          	li	a5,255
    80004ba0:	0ae7e463          	bltu	a5,a4,80004c48 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80004ba4:	08052583          	lw	a1,128(a0)
    80004ba8:	c5b5                	beqz	a1,80004c14 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004baa:	00092503          	lw	a0,0(s2)
    80004bae:	00000097          	auipc	ra,0x0
    80004bb2:	bde080e7          	jalr	-1058(ra) # 8000478c <bread>
    80004bb6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004bb8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004bbc:	02049713          	slli	a4,s1,0x20
    80004bc0:	01e75593          	srli	a1,a4,0x1e
    80004bc4:	00b784b3          	add	s1,a5,a1
    80004bc8:	0004a983          	lw	s3,0(s1)
    80004bcc:	04098e63          	beqz	s3,80004c28 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004bd0:	8552                	mv	a0,s4
    80004bd2:	00000097          	auipc	ra,0x0
    80004bd6:	cea080e7          	jalr	-790(ra) # 800048bc <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004bda:	854e                	mv	a0,s3
    80004bdc:	70a2                	ld	ra,40(sp)
    80004bde:	7402                	ld	s0,32(sp)
    80004be0:	64e2                	ld	s1,24(sp)
    80004be2:	6942                	ld	s2,16(sp)
    80004be4:	69a2                	ld	s3,8(sp)
    80004be6:	6a02                	ld	s4,0(sp)
    80004be8:	6145                	addi	sp,sp,48
    80004bea:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004bec:	02059793          	slli	a5,a1,0x20
    80004bf0:	01e7d593          	srli	a1,a5,0x1e
    80004bf4:	00b504b3          	add	s1,a0,a1
    80004bf8:	0504a983          	lw	s3,80(s1)
    80004bfc:	fc099fe3          	bnez	s3,80004bda <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80004c00:	4108                	lw	a0,0(a0)
    80004c02:	00000097          	auipc	ra,0x0
    80004c06:	e4c080e7          	jalr	-436(ra) # 80004a4e <balloc>
    80004c0a:	0005099b          	sext.w	s3,a0
    80004c0e:	0534a823          	sw	s3,80(s1)
    80004c12:	b7e1                	j	80004bda <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80004c14:	4108                	lw	a0,0(a0)
    80004c16:	00000097          	auipc	ra,0x0
    80004c1a:	e38080e7          	jalr	-456(ra) # 80004a4e <balloc>
    80004c1e:	0005059b          	sext.w	a1,a0
    80004c22:	08b92023          	sw	a1,128(s2)
    80004c26:	b751                	j	80004baa <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80004c28:	00092503          	lw	a0,0(s2)
    80004c2c:	00000097          	auipc	ra,0x0
    80004c30:	e22080e7          	jalr	-478(ra) # 80004a4e <balloc>
    80004c34:	0005099b          	sext.w	s3,a0
    80004c38:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80004c3c:	8552                	mv	a0,s4
    80004c3e:	00001097          	auipc	ra,0x1
    80004c42:	f02080e7          	jalr	-254(ra) # 80005b40 <log_write>
    80004c46:	b769                	j	80004bd0 <bmap+0x54>
  panic("bmap: out of range");
    80004c48:	00005517          	auipc	a0,0x5
    80004c4c:	c6050513          	addi	a0,a0,-928 # 800098a8 <syscalls+0x268>
    80004c50:	ffffc097          	auipc	ra,0xffffc
    80004c54:	8e8080e7          	jalr	-1816(ra) # 80000538 <panic>

0000000080004c58 <iget>:
{
    80004c58:	7179                	addi	sp,sp,-48
    80004c5a:	f406                	sd	ra,40(sp)
    80004c5c:	f022                	sd	s0,32(sp)
    80004c5e:	ec26                	sd	s1,24(sp)
    80004c60:	e84a                	sd	s2,16(sp)
    80004c62:	e44e                	sd	s3,8(sp)
    80004c64:	e052                	sd	s4,0(sp)
    80004c66:	1800                	addi	s0,sp,48
    80004c68:	89aa                	mv	s3,a0
    80004c6a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80004c6c:	0001d517          	auipc	a0,0x1d
    80004c70:	efc50513          	addi	a0,a0,-260 # 80021b68 <itable>
    80004c74:	ffffc097          	auipc	ra,0xffffc
    80004c78:	f5a080e7          	jalr	-166(ra) # 80000bce <acquire>
  empty = 0;
    80004c7c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004c7e:	0001d497          	auipc	s1,0x1d
    80004c82:	f0248493          	addi	s1,s1,-254 # 80021b80 <itable+0x18>
    80004c86:	0001f697          	auipc	a3,0x1f
    80004c8a:	98a68693          	addi	a3,a3,-1654 # 80023610 <log>
    80004c8e:	a039                	j	80004c9c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004c90:	02090b63          	beqz	s2,80004cc6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004c94:	08848493          	addi	s1,s1,136
    80004c98:	02d48a63          	beq	s1,a3,80004ccc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004c9c:	449c                	lw	a5,8(s1)
    80004c9e:	fef059e3          	blez	a5,80004c90 <iget+0x38>
    80004ca2:	4098                	lw	a4,0(s1)
    80004ca4:	ff3716e3          	bne	a4,s3,80004c90 <iget+0x38>
    80004ca8:	40d8                	lw	a4,4(s1)
    80004caa:	ff4713e3          	bne	a4,s4,80004c90 <iget+0x38>
      ip->ref++;
    80004cae:	2785                	addiw	a5,a5,1
    80004cb0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004cb2:	0001d517          	auipc	a0,0x1d
    80004cb6:	eb650513          	addi	a0,a0,-330 # 80021b68 <itable>
    80004cba:	ffffc097          	auipc	ra,0xffffc
    80004cbe:	fc8080e7          	jalr	-56(ra) # 80000c82 <release>
      return ip;
    80004cc2:	8926                	mv	s2,s1
    80004cc4:	a03d                	j	80004cf2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004cc6:	f7f9                	bnez	a5,80004c94 <iget+0x3c>
    80004cc8:	8926                	mv	s2,s1
    80004cca:	b7e9                	j	80004c94 <iget+0x3c>
  if(empty == 0)
    80004ccc:	02090c63          	beqz	s2,80004d04 <iget+0xac>
  ip->dev = dev;
    80004cd0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004cd4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004cd8:	4785                	li	a5,1
    80004cda:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004cde:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004ce2:	0001d517          	auipc	a0,0x1d
    80004ce6:	e8650513          	addi	a0,a0,-378 # 80021b68 <itable>
    80004cea:	ffffc097          	auipc	ra,0xffffc
    80004cee:	f98080e7          	jalr	-104(ra) # 80000c82 <release>
}
    80004cf2:	854a                	mv	a0,s2
    80004cf4:	70a2                	ld	ra,40(sp)
    80004cf6:	7402                	ld	s0,32(sp)
    80004cf8:	64e2                	ld	s1,24(sp)
    80004cfa:	6942                	ld	s2,16(sp)
    80004cfc:	69a2                	ld	s3,8(sp)
    80004cfe:	6a02                	ld	s4,0(sp)
    80004d00:	6145                	addi	sp,sp,48
    80004d02:	8082                	ret
    panic("iget: no inodes");
    80004d04:	00005517          	auipc	a0,0x5
    80004d08:	bbc50513          	addi	a0,a0,-1092 # 800098c0 <syscalls+0x280>
    80004d0c:	ffffc097          	auipc	ra,0xffffc
    80004d10:	82c080e7          	jalr	-2004(ra) # 80000538 <panic>

0000000080004d14 <fsinit>:
fsinit(int dev) {
    80004d14:	7179                	addi	sp,sp,-48
    80004d16:	f406                	sd	ra,40(sp)
    80004d18:	f022                	sd	s0,32(sp)
    80004d1a:	ec26                	sd	s1,24(sp)
    80004d1c:	e84a                	sd	s2,16(sp)
    80004d1e:	e44e                	sd	s3,8(sp)
    80004d20:	1800                	addi	s0,sp,48
    80004d22:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80004d24:	4585                	li	a1,1
    80004d26:	00000097          	auipc	ra,0x0
    80004d2a:	a66080e7          	jalr	-1434(ra) # 8000478c <bread>
    80004d2e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80004d30:	0001d997          	auipc	s3,0x1d
    80004d34:	e1898993          	addi	s3,s3,-488 # 80021b48 <sb>
    80004d38:	02000613          	li	a2,32
    80004d3c:	05850593          	addi	a1,a0,88
    80004d40:	854e                	mv	a0,s3
    80004d42:	ffffc097          	auipc	ra,0xffffc
    80004d46:	fe4080e7          	jalr	-28(ra) # 80000d26 <memmove>
  brelse(bp);
    80004d4a:	8526                	mv	a0,s1
    80004d4c:	00000097          	auipc	ra,0x0
    80004d50:	b70080e7          	jalr	-1168(ra) # 800048bc <brelse>
  if(sb.magic != FSMAGIC)
    80004d54:	0009a703          	lw	a4,0(s3)
    80004d58:	102037b7          	lui	a5,0x10203
    80004d5c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004d60:	02f71263          	bne	a4,a5,80004d84 <fsinit+0x70>
  initlog(dev, &sb);
    80004d64:	0001d597          	auipc	a1,0x1d
    80004d68:	de458593          	addi	a1,a1,-540 # 80021b48 <sb>
    80004d6c:	854a                	mv	a0,s2
    80004d6e:	00001097          	auipc	ra,0x1
    80004d72:	b56080e7          	jalr	-1194(ra) # 800058c4 <initlog>
}
    80004d76:	70a2                	ld	ra,40(sp)
    80004d78:	7402                	ld	s0,32(sp)
    80004d7a:	64e2                	ld	s1,24(sp)
    80004d7c:	6942                	ld	s2,16(sp)
    80004d7e:	69a2                	ld	s3,8(sp)
    80004d80:	6145                	addi	sp,sp,48
    80004d82:	8082                	ret
    panic("invalid file system");
    80004d84:	00005517          	auipc	a0,0x5
    80004d88:	b4c50513          	addi	a0,a0,-1204 # 800098d0 <syscalls+0x290>
    80004d8c:	ffffb097          	auipc	ra,0xffffb
    80004d90:	7ac080e7          	jalr	1964(ra) # 80000538 <panic>

0000000080004d94 <iinit>:
{
    80004d94:	7179                	addi	sp,sp,-48
    80004d96:	f406                	sd	ra,40(sp)
    80004d98:	f022                	sd	s0,32(sp)
    80004d9a:	ec26                	sd	s1,24(sp)
    80004d9c:	e84a                	sd	s2,16(sp)
    80004d9e:	e44e                	sd	s3,8(sp)
    80004da0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004da2:	00005597          	auipc	a1,0x5
    80004da6:	b4658593          	addi	a1,a1,-1210 # 800098e8 <syscalls+0x2a8>
    80004daa:	0001d517          	auipc	a0,0x1d
    80004dae:	dbe50513          	addi	a0,a0,-578 # 80021b68 <itable>
    80004db2:	ffffc097          	auipc	ra,0xffffc
    80004db6:	d8c080e7          	jalr	-628(ra) # 80000b3e <initlock>
  for(i = 0; i < NINODE; i++) {
    80004dba:	0001d497          	auipc	s1,0x1d
    80004dbe:	dd648493          	addi	s1,s1,-554 # 80021b90 <itable+0x28>
    80004dc2:	0001f997          	auipc	s3,0x1f
    80004dc6:	85e98993          	addi	s3,s3,-1954 # 80023620 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004dca:	00005917          	auipc	s2,0x5
    80004dce:	b2690913          	addi	s2,s2,-1242 # 800098f0 <syscalls+0x2b0>
    80004dd2:	85ca                	mv	a1,s2
    80004dd4:	8526                	mv	a0,s1
    80004dd6:	00001097          	auipc	ra,0x1
    80004dda:	e4e080e7          	jalr	-434(ra) # 80005c24 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004dde:	08848493          	addi	s1,s1,136
    80004de2:	ff3498e3          	bne	s1,s3,80004dd2 <iinit+0x3e>
}
    80004de6:	70a2                	ld	ra,40(sp)
    80004de8:	7402                	ld	s0,32(sp)
    80004dea:	64e2                	ld	s1,24(sp)
    80004dec:	6942                	ld	s2,16(sp)
    80004dee:	69a2                	ld	s3,8(sp)
    80004df0:	6145                	addi	sp,sp,48
    80004df2:	8082                	ret

0000000080004df4 <ialloc>:
{
    80004df4:	715d                	addi	sp,sp,-80
    80004df6:	e486                	sd	ra,72(sp)
    80004df8:	e0a2                	sd	s0,64(sp)
    80004dfa:	fc26                	sd	s1,56(sp)
    80004dfc:	f84a                	sd	s2,48(sp)
    80004dfe:	f44e                	sd	s3,40(sp)
    80004e00:	f052                	sd	s4,32(sp)
    80004e02:	ec56                	sd	s5,24(sp)
    80004e04:	e85a                	sd	s6,16(sp)
    80004e06:	e45e                	sd	s7,8(sp)
    80004e08:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80004e0a:	0001d717          	auipc	a4,0x1d
    80004e0e:	d4a72703          	lw	a4,-694(a4) # 80021b54 <sb+0xc>
    80004e12:	4785                	li	a5,1
    80004e14:	04e7fa63          	bgeu	a5,a4,80004e68 <ialloc+0x74>
    80004e18:	8aaa                	mv	s5,a0
    80004e1a:	8bae                	mv	s7,a1
    80004e1c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004e1e:	0001da17          	auipc	s4,0x1d
    80004e22:	d2aa0a13          	addi	s4,s4,-726 # 80021b48 <sb>
    80004e26:	00048b1b          	sext.w	s6,s1
    80004e2a:	0044d593          	srli	a1,s1,0x4
    80004e2e:	018a2783          	lw	a5,24(s4)
    80004e32:	9dbd                	addw	a1,a1,a5
    80004e34:	8556                	mv	a0,s5
    80004e36:	00000097          	auipc	ra,0x0
    80004e3a:	956080e7          	jalr	-1706(ra) # 8000478c <bread>
    80004e3e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80004e40:	05850993          	addi	s3,a0,88
    80004e44:	00f4f793          	andi	a5,s1,15
    80004e48:	079a                	slli	a5,a5,0x6
    80004e4a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004e4c:	00099783          	lh	a5,0(s3)
    80004e50:	c785                	beqz	a5,80004e78 <ialloc+0x84>
    brelse(bp);
    80004e52:	00000097          	auipc	ra,0x0
    80004e56:	a6a080e7          	jalr	-1430(ra) # 800048bc <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004e5a:	0485                	addi	s1,s1,1
    80004e5c:	00ca2703          	lw	a4,12(s4)
    80004e60:	0004879b          	sext.w	a5,s1
    80004e64:	fce7e1e3          	bltu	a5,a4,80004e26 <ialloc+0x32>
  panic("ialloc: no inodes");
    80004e68:	00005517          	auipc	a0,0x5
    80004e6c:	a9050513          	addi	a0,a0,-1392 # 800098f8 <syscalls+0x2b8>
    80004e70:	ffffb097          	auipc	ra,0xffffb
    80004e74:	6c8080e7          	jalr	1736(ra) # 80000538 <panic>
      memset(dip, 0, sizeof(*dip));
    80004e78:	04000613          	li	a2,64
    80004e7c:	4581                	li	a1,0
    80004e7e:	854e                	mv	a0,s3
    80004e80:	ffffc097          	auipc	ra,0xffffc
    80004e84:	e4a080e7          	jalr	-438(ra) # 80000cca <memset>
      dip->type = type;
    80004e88:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004e8c:	854a                	mv	a0,s2
    80004e8e:	00001097          	auipc	ra,0x1
    80004e92:	cb2080e7          	jalr	-846(ra) # 80005b40 <log_write>
      brelse(bp);
    80004e96:	854a                	mv	a0,s2
    80004e98:	00000097          	auipc	ra,0x0
    80004e9c:	a24080e7          	jalr	-1500(ra) # 800048bc <brelse>
      return iget(dev, inum);
    80004ea0:	85da                	mv	a1,s6
    80004ea2:	8556                	mv	a0,s5
    80004ea4:	00000097          	auipc	ra,0x0
    80004ea8:	db4080e7          	jalr	-588(ra) # 80004c58 <iget>
}
    80004eac:	60a6                	ld	ra,72(sp)
    80004eae:	6406                	ld	s0,64(sp)
    80004eb0:	74e2                	ld	s1,56(sp)
    80004eb2:	7942                	ld	s2,48(sp)
    80004eb4:	79a2                	ld	s3,40(sp)
    80004eb6:	7a02                	ld	s4,32(sp)
    80004eb8:	6ae2                	ld	s5,24(sp)
    80004eba:	6b42                	ld	s6,16(sp)
    80004ebc:	6ba2                	ld	s7,8(sp)
    80004ebe:	6161                	addi	sp,sp,80
    80004ec0:	8082                	ret

0000000080004ec2 <iupdate>:
{
    80004ec2:	1101                	addi	sp,sp,-32
    80004ec4:	ec06                	sd	ra,24(sp)
    80004ec6:	e822                	sd	s0,16(sp)
    80004ec8:	e426                	sd	s1,8(sp)
    80004eca:	e04a                	sd	s2,0(sp)
    80004ecc:	1000                	addi	s0,sp,32
    80004ece:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004ed0:	415c                	lw	a5,4(a0)
    80004ed2:	0047d79b          	srliw	a5,a5,0x4
    80004ed6:	0001d597          	auipc	a1,0x1d
    80004eda:	c8a5a583          	lw	a1,-886(a1) # 80021b60 <sb+0x18>
    80004ede:	9dbd                	addw	a1,a1,a5
    80004ee0:	4108                	lw	a0,0(a0)
    80004ee2:	00000097          	auipc	ra,0x0
    80004ee6:	8aa080e7          	jalr	-1878(ra) # 8000478c <bread>
    80004eea:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004eec:	05850793          	addi	a5,a0,88
    80004ef0:	40d8                	lw	a4,4(s1)
    80004ef2:	8b3d                	andi	a4,a4,15
    80004ef4:	071a                	slli	a4,a4,0x6
    80004ef6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80004ef8:	04449703          	lh	a4,68(s1)
    80004efc:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80004f00:	04649703          	lh	a4,70(s1)
    80004f04:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80004f08:	04849703          	lh	a4,72(s1)
    80004f0c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80004f10:	04a49703          	lh	a4,74(s1)
    80004f14:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80004f18:	44f8                	lw	a4,76(s1)
    80004f1a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004f1c:	03400613          	li	a2,52
    80004f20:	05048593          	addi	a1,s1,80
    80004f24:	00c78513          	addi	a0,a5,12
    80004f28:	ffffc097          	auipc	ra,0xffffc
    80004f2c:	dfe080e7          	jalr	-514(ra) # 80000d26 <memmove>
  log_write(bp);
    80004f30:	854a                	mv	a0,s2
    80004f32:	00001097          	auipc	ra,0x1
    80004f36:	c0e080e7          	jalr	-1010(ra) # 80005b40 <log_write>
  brelse(bp);
    80004f3a:	854a                	mv	a0,s2
    80004f3c:	00000097          	auipc	ra,0x0
    80004f40:	980080e7          	jalr	-1664(ra) # 800048bc <brelse>
}
    80004f44:	60e2                	ld	ra,24(sp)
    80004f46:	6442                	ld	s0,16(sp)
    80004f48:	64a2                	ld	s1,8(sp)
    80004f4a:	6902                	ld	s2,0(sp)
    80004f4c:	6105                	addi	sp,sp,32
    80004f4e:	8082                	ret

0000000080004f50 <idup>:
{
    80004f50:	1101                	addi	sp,sp,-32
    80004f52:	ec06                	sd	ra,24(sp)
    80004f54:	e822                	sd	s0,16(sp)
    80004f56:	e426                	sd	s1,8(sp)
    80004f58:	1000                	addi	s0,sp,32
    80004f5a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004f5c:	0001d517          	auipc	a0,0x1d
    80004f60:	c0c50513          	addi	a0,a0,-1012 # 80021b68 <itable>
    80004f64:	ffffc097          	auipc	ra,0xffffc
    80004f68:	c6a080e7          	jalr	-918(ra) # 80000bce <acquire>
  ip->ref++;
    80004f6c:	449c                	lw	a5,8(s1)
    80004f6e:	2785                	addiw	a5,a5,1
    80004f70:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004f72:	0001d517          	auipc	a0,0x1d
    80004f76:	bf650513          	addi	a0,a0,-1034 # 80021b68 <itable>
    80004f7a:	ffffc097          	auipc	ra,0xffffc
    80004f7e:	d08080e7          	jalr	-760(ra) # 80000c82 <release>
}
    80004f82:	8526                	mv	a0,s1
    80004f84:	60e2                	ld	ra,24(sp)
    80004f86:	6442                	ld	s0,16(sp)
    80004f88:	64a2                	ld	s1,8(sp)
    80004f8a:	6105                	addi	sp,sp,32
    80004f8c:	8082                	ret

0000000080004f8e <ilock>:
{
    80004f8e:	1101                	addi	sp,sp,-32
    80004f90:	ec06                	sd	ra,24(sp)
    80004f92:	e822                	sd	s0,16(sp)
    80004f94:	e426                	sd	s1,8(sp)
    80004f96:	e04a                	sd	s2,0(sp)
    80004f98:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004f9a:	c115                	beqz	a0,80004fbe <ilock+0x30>
    80004f9c:	84aa                	mv	s1,a0
    80004f9e:	451c                	lw	a5,8(a0)
    80004fa0:	00f05f63          	blez	a5,80004fbe <ilock+0x30>
  acquiresleep(&ip->lock);
    80004fa4:	0541                	addi	a0,a0,16
    80004fa6:	00001097          	auipc	ra,0x1
    80004faa:	cb8080e7          	jalr	-840(ra) # 80005c5e <acquiresleep>
  if(ip->valid == 0){
    80004fae:	40bc                	lw	a5,64(s1)
    80004fb0:	cf99                	beqz	a5,80004fce <ilock+0x40>
}
    80004fb2:	60e2                	ld	ra,24(sp)
    80004fb4:	6442                	ld	s0,16(sp)
    80004fb6:	64a2                	ld	s1,8(sp)
    80004fb8:	6902                	ld	s2,0(sp)
    80004fba:	6105                	addi	sp,sp,32
    80004fbc:	8082                	ret
    panic("ilock");
    80004fbe:	00005517          	auipc	a0,0x5
    80004fc2:	95250513          	addi	a0,a0,-1710 # 80009910 <syscalls+0x2d0>
    80004fc6:	ffffb097          	auipc	ra,0xffffb
    80004fca:	572080e7          	jalr	1394(ra) # 80000538 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004fce:	40dc                	lw	a5,4(s1)
    80004fd0:	0047d79b          	srliw	a5,a5,0x4
    80004fd4:	0001d597          	auipc	a1,0x1d
    80004fd8:	b8c5a583          	lw	a1,-1140(a1) # 80021b60 <sb+0x18>
    80004fdc:	9dbd                	addw	a1,a1,a5
    80004fde:	4088                	lw	a0,0(s1)
    80004fe0:	fffff097          	auipc	ra,0xfffff
    80004fe4:	7ac080e7          	jalr	1964(ra) # 8000478c <bread>
    80004fe8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004fea:	05850593          	addi	a1,a0,88
    80004fee:	40dc                	lw	a5,4(s1)
    80004ff0:	8bbd                	andi	a5,a5,15
    80004ff2:	079a                	slli	a5,a5,0x6
    80004ff4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004ff6:	00059783          	lh	a5,0(a1)
    80004ffa:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004ffe:	00259783          	lh	a5,2(a1)
    80005002:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80005006:	00459783          	lh	a5,4(a1)
    8000500a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000500e:	00659783          	lh	a5,6(a1)
    80005012:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80005016:	459c                	lw	a5,8(a1)
    80005018:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000501a:	03400613          	li	a2,52
    8000501e:	05b1                	addi	a1,a1,12
    80005020:	05048513          	addi	a0,s1,80
    80005024:	ffffc097          	auipc	ra,0xffffc
    80005028:	d02080e7          	jalr	-766(ra) # 80000d26 <memmove>
    brelse(bp);
    8000502c:	854a                	mv	a0,s2
    8000502e:	00000097          	auipc	ra,0x0
    80005032:	88e080e7          	jalr	-1906(ra) # 800048bc <brelse>
    ip->valid = 1;
    80005036:	4785                	li	a5,1
    80005038:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000503a:	04449783          	lh	a5,68(s1)
    8000503e:	fbb5                	bnez	a5,80004fb2 <ilock+0x24>
      panic("ilock: no type");
    80005040:	00005517          	auipc	a0,0x5
    80005044:	8d850513          	addi	a0,a0,-1832 # 80009918 <syscalls+0x2d8>
    80005048:	ffffb097          	auipc	ra,0xffffb
    8000504c:	4f0080e7          	jalr	1264(ra) # 80000538 <panic>

0000000080005050 <iunlock>:
{
    80005050:	1101                	addi	sp,sp,-32
    80005052:	ec06                	sd	ra,24(sp)
    80005054:	e822                	sd	s0,16(sp)
    80005056:	e426                	sd	s1,8(sp)
    80005058:	e04a                	sd	s2,0(sp)
    8000505a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000505c:	c905                	beqz	a0,8000508c <iunlock+0x3c>
    8000505e:	84aa                	mv	s1,a0
    80005060:	01050913          	addi	s2,a0,16
    80005064:	854a                	mv	a0,s2
    80005066:	00001097          	auipc	ra,0x1
    8000506a:	c92080e7          	jalr	-878(ra) # 80005cf8 <holdingsleep>
    8000506e:	cd19                	beqz	a0,8000508c <iunlock+0x3c>
    80005070:	449c                	lw	a5,8(s1)
    80005072:	00f05d63          	blez	a5,8000508c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80005076:	854a                	mv	a0,s2
    80005078:	00001097          	auipc	ra,0x1
    8000507c:	c3c080e7          	jalr	-964(ra) # 80005cb4 <releasesleep>
}
    80005080:	60e2                	ld	ra,24(sp)
    80005082:	6442                	ld	s0,16(sp)
    80005084:	64a2                	ld	s1,8(sp)
    80005086:	6902                	ld	s2,0(sp)
    80005088:	6105                	addi	sp,sp,32
    8000508a:	8082                	ret
    panic("iunlock");
    8000508c:	00005517          	auipc	a0,0x5
    80005090:	89c50513          	addi	a0,a0,-1892 # 80009928 <syscalls+0x2e8>
    80005094:	ffffb097          	auipc	ra,0xffffb
    80005098:	4a4080e7          	jalr	1188(ra) # 80000538 <panic>

000000008000509c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000509c:	7179                	addi	sp,sp,-48
    8000509e:	f406                	sd	ra,40(sp)
    800050a0:	f022                	sd	s0,32(sp)
    800050a2:	ec26                	sd	s1,24(sp)
    800050a4:	e84a                	sd	s2,16(sp)
    800050a6:	e44e                	sd	s3,8(sp)
    800050a8:	e052                	sd	s4,0(sp)
    800050aa:	1800                	addi	s0,sp,48
    800050ac:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800050ae:	05050493          	addi	s1,a0,80
    800050b2:	08050913          	addi	s2,a0,128
    800050b6:	a021                	j	800050be <itrunc+0x22>
    800050b8:	0491                	addi	s1,s1,4
    800050ba:	01248d63          	beq	s1,s2,800050d4 <itrunc+0x38>
    if(ip->addrs[i]){
    800050be:	408c                	lw	a1,0(s1)
    800050c0:	dde5                	beqz	a1,800050b8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800050c2:	0009a503          	lw	a0,0(s3)
    800050c6:	00000097          	auipc	ra,0x0
    800050ca:	90c080e7          	jalr	-1780(ra) # 800049d2 <bfree>
      ip->addrs[i] = 0;
    800050ce:	0004a023          	sw	zero,0(s1)
    800050d2:	b7dd                	j	800050b8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800050d4:	0809a583          	lw	a1,128(s3)
    800050d8:	e185                	bnez	a1,800050f8 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800050da:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800050de:	854e                	mv	a0,s3
    800050e0:	00000097          	auipc	ra,0x0
    800050e4:	de2080e7          	jalr	-542(ra) # 80004ec2 <iupdate>
}
    800050e8:	70a2                	ld	ra,40(sp)
    800050ea:	7402                	ld	s0,32(sp)
    800050ec:	64e2                	ld	s1,24(sp)
    800050ee:	6942                	ld	s2,16(sp)
    800050f0:	69a2                	ld	s3,8(sp)
    800050f2:	6a02                	ld	s4,0(sp)
    800050f4:	6145                	addi	sp,sp,48
    800050f6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800050f8:	0009a503          	lw	a0,0(s3)
    800050fc:	fffff097          	auipc	ra,0xfffff
    80005100:	690080e7          	jalr	1680(ra) # 8000478c <bread>
    80005104:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80005106:	05850493          	addi	s1,a0,88
    8000510a:	45850913          	addi	s2,a0,1112
    8000510e:	a021                	j	80005116 <itrunc+0x7a>
    80005110:	0491                	addi	s1,s1,4
    80005112:	01248b63          	beq	s1,s2,80005128 <itrunc+0x8c>
      if(a[j])
    80005116:	408c                	lw	a1,0(s1)
    80005118:	dde5                	beqz	a1,80005110 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000511a:	0009a503          	lw	a0,0(s3)
    8000511e:	00000097          	auipc	ra,0x0
    80005122:	8b4080e7          	jalr	-1868(ra) # 800049d2 <bfree>
    80005126:	b7ed                	j	80005110 <itrunc+0x74>
    brelse(bp);
    80005128:	8552                	mv	a0,s4
    8000512a:	fffff097          	auipc	ra,0xfffff
    8000512e:	792080e7          	jalr	1938(ra) # 800048bc <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80005132:	0809a583          	lw	a1,128(s3)
    80005136:	0009a503          	lw	a0,0(s3)
    8000513a:	00000097          	auipc	ra,0x0
    8000513e:	898080e7          	jalr	-1896(ra) # 800049d2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80005142:	0809a023          	sw	zero,128(s3)
    80005146:	bf51                	j	800050da <itrunc+0x3e>

0000000080005148 <iput>:
{
    80005148:	1101                	addi	sp,sp,-32
    8000514a:	ec06                	sd	ra,24(sp)
    8000514c:	e822                	sd	s0,16(sp)
    8000514e:	e426                	sd	s1,8(sp)
    80005150:	e04a                	sd	s2,0(sp)
    80005152:	1000                	addi	s0,sp,32
    80005154:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80005156:	0001d517          	auipc	a0,0x1d
    8000515a:	a1250513          	addi	a0,a0,-1518 # 80021b68 <itable>
    8000515e:	ffffc097          	auipc	ra,0xffffc
    80005162:	a70080e7          	jalr	-1424(ra) # 80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80005166:	4498                	lw	a4,8(s1)
    80005168:	4785                	li	a5,1
    8000516a:	02f70363          	beq	a4,a5,80005190 <iput+0x48>
  ip->ref--;
    8000516e:	449c                	lw	a5,8(s1)
    80005170:	37fd                	addiw	a5,a5,-1
    80005172:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80005174:	0001d517          	auipc	a0,0x1d
    80005178:	9f450513          	addi	a0,a0,-1548 # 80021b68 <itable>
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	b06080e7          	jalr	-1274(ra) # 80000c82 <release>
}
    80005184:	60e2                	ld	ra,24(sp)
    80005186:	6442                	ld	s0,16(sp)
    80005188:	64a2                	ld	s1,8(sp)
    8000518a:	6902                	ld	s2,0(sp)
    8000518c:	6105                	addi	sp,sp,32
    8000518e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80005190:	40bc                	lw	a5,64(s1)
    80005192:	dff1                	beqz	a5,8000516e <iput+0x26>
    80005194:	04a49783          	lh	a5,74(s1)
    80005198:	fbf9                	bnez	a5,8000516e <iput+0x26>
    acquiresleep(&ip->lock);
    8000519a:	01048913          	addi	s2,s1,16
    8000519e:	854a                	mv	a0,s2
    800051a0:	00001097          	auipc	ra,0x1
    800051a4:	abe080e7          	jalr	-1346(ra) # 80005c5e <acquiresleep>
    release(&itable.lock);
    800051a8:	0001d517          	auipc	a0,0x1d
    800051ac:	9c050513          	addi	a0,a0,-1600 # 80021b68 <itable>
    800051b0:	ffffc097          	auipc	ra,0xffffc
    800051b4:	ad2080e7          	jalr	-1326(ra) # 80000c82 <release>
    itrunc(ip);
    800051b8:	8526                	mv	a0,s1
    800051ba:	00000097          	auipc	ra,0x0
    800051be:	ee2080e7          	jalr	-286(ra) # 8000509c <itrunc>
    ip->type = 0;
    800051c2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800051c6:	8526                	mv	a0,s1
    800051c8:	00000097          	auipc	ra,0x0
    800051cc:	cfa080e7          	jalr	-774(ra) # 80004ec2 <iupdate>
    ip->valid = 0;
    800051d0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800051d4:	854a                	mv	a0,s2
    800051d6:	00001097          	auipc	ra,0x1
    800051da:	ade080e7          	jalr	-1314(ra) # 80005cb4 <releasesleep>
    acquire(&itable.lock);
    800051de:	0001d517          	auipc	a0,0x1d
    800051e2:	98a50513          	addi	a0,a0,-1654 # 80021b68 <itable>
    800051e6:	ffffc097          	auipc	ra,0xffffc
    800051ea:	9e8080e7          	jalr	-1560(ra) # 80000bce <acquire>
    800051ee:	b741                	j	8000516e <iput+0x26>

00000000800051f0 <iunlockput>:
{
    800051f0:	1101                	addi	sp,sp,-32
    800051f2:	ec06                	sd	ra,24(sp)
    800051f4:	e822                	sd	s0,16(sp)
    800051f6:	e426                	sd	s1,8(sp)
    800051f8:	1000                	addi	s0,sp,32
    800051fa:	84aa                	mv	s1,a0
  iunlock(ip);
    800051fc:	00000097          	auipc	ra,0x0
    80005200:	e54080e7          	jalr	-428(ra) # 80005050 <iunlock>
  iput(ip);
    80005204:	8526                	mv	a0,s1
    80005206:	00000097          	auipc	ra,0x0
    8000520a:	f42080e7          	jalr	-190(ra) # 80005148 <iput>
}
    8000520e:	60e2                	ld	ra,24(sp)
    80005210:	6442                	ld	s0,16(sp)
    80005212:	64a2                	ld	s1,8(sp)
    80005214:	6105                	addi	sp,sp,32
    80005216:	8082                	ret

0000000080005218 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80005218:	1141                	addi	sp,sp,-16
    8000521a:	e422                	sd	s0,8(sp)
    8000521c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000521e:	411c                	lw	a5,0(a0)
    80005220:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80005222:	415c                	lw	a5,4(a0)
    80005224:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80005226:	04451783          	lh	a5,68(a0)
    8000522a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000522e:	04a51783          	lh	a5,74(a0)
    80005232:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80005236:	04c56783          	lwu	a5,76(a0)
    8000523a:	e99c                	sd	a5,16(a1)
}
    8000523c:	6422                	ld	s0,8(sp)
    8000523e:	0141                	addi	sp,sp,16
    80005240:	8082                	ret

0000000080005242 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80005242:	457c                	lw	a5,76(a0)
    80005244:	0ed7e963          	bltu	a5,a3,80005336 <readi+0xf4>
{
    80005248:	7159                	addi	sp,sp,-112
    8000524a:	f486                	sd	ra,104(sp)
    8000524c:	f0a2                	sd	s0,96(sp)
    8000524e:	eca6                	sd	s1,88(sp)
    80005250:	e8ca                	sd	s2,80(sp)
    80005252:	e4ce                	sd	s3,72(sp)
    80005254:	e0d2                	sd	s4,64(sp)
    80005256:	fc56                	sd	s5,56(sp)
    80005258:	f85a                	sd	s6,48(sp)
    8000525a:	f45e                	sd	s7,40(sp)
    8000525c:	f062                	sd	s8,32(sp)
    8000525e:	ec66                	sd	s9,24(sp)
    80005260:	e86a                	sd	s10,16(sp)
    80005262:	e46e                	sd	s11,8(sp)
    80005264:	1880                	addi	s0,sp,112
    80005266:	8baa                	mv	s7,a0
    80005268:	8c2e                	mv	s8,a1
    8000526a:	8ab2                	mv	s5,a2
    8000526c:	84b6                	mv	s1,a3
    8000526e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80005270:	9f35                	addw	a4,a4,a3
    return 0;
    80005272:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80005274:	0ad76063          	bltu	a4,a3,80005314 <readi+0xd2>
  if(off + n > ip->size)
    80005278:	00e7f463          	bgeu	a5,a4,80005280 <readi+0x3e>
    n = ip->size - off;
    8000527c:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80005280:	0a0b0963          	beqz	s6,80005332 <readi+0xf0>
    80005284:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80005286:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000528a:	5cfd                	li	s9,-1
    8000528c:	a82d                	j	800052c6 <readi+0x84>
    8000528e:	020a1d93          	slli	s11,s4,0x20
    80005292:	020ddd93          	srli	s11,s11,0x20
    80005296:	05890613          	addi	a2,s2,88
    8000529a:	86ee                	mv	a3,s11
    8000529c:	963a                	add	a2,a2,a4
    8000529e:	85d6                	mv	a1,s5
    800052a0:	8562                	mv	a0,s8
    800052a2:	ffffe097          	auipc	ra,0xffffe
    800052a6:	ec6080e7          	jalr	-314(ra) # 80003168 <either_copyout>
    800052aa:	05950d63          	beq	a0,s9,80005304 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800052ae:	854a                	mv	a0,s2
    800052b0:	fffff097          	auipc	ra,0xfffff
    800052b4:	60c080e7          	jalr	1548(ra) # 800048bc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800052b8:	013a09bb          	addw	s3,s4,s3
    800052bc:	009a04bb          	addw	s1,s4,s1
    800052c0:	9aee                	add	s5,s5,s11
    800052c2:	0569f763          	bgeu	s3,s6,80005310 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800052c6:	000ba903          	lw	s2,0(s7)
    800052ca:	00a4d59b          	srliw	a1,s1,0xa
    800052ce:	855e                	mv	a0,s7
    800052d0:	00000097          	auipc	ra,0x0
    800052d4:	8ac080e7          	jalr	-1876(ra) # 80004b7c <bmap>
    800052d8:	0005059b          	sext.w	a1,a0
    800052dc:	854a                	mv	a0,s2
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	4ae080e7          	jalr	1198(ra) # 8000478c <bread>
    800052e6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800052e8:	3ff4f713          	andi	a4,s1,1023
    800052ec:	40ed07bb          	subw	a5,s10,a4
    800052f0:	413b06bb          	subw	a3,s6,s3
    800052f4:	8a3e                	mv	s4,a5
    800052f6:	2781                	sext.w	a5,a5
    800052f8:	0006861b          	sext.w	a2,a3
    800052fc:	f8f679e3          	bgeu	a2,a5,8000528e <readi+0x4c>
    80005300:	8a36                	mv	s4,a3
    80005302:	b771                	j	8000528e <readi+0x4c>
      brelse(bp);
    80005304:	854a                	mv	a0,s2
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	5b6080e7          	jalr	1462(ra) # 800048bc <brelse>
      tot = -1;
    8000530e:	59fd                	li	s3,-1
  }
  return tot;
    80005310:	0009851b          	sext.w	a0,s3
}
    80005314:	70a6                	ld	ra,104(sp)
    80005316:	7406                	ld	s0,96(sp)
    80005318:	64e6                	ld	s1,88(sp)
    8000531a:	6946                	ld	s2,80(sp)
    8000531c:	69a6                	ld	s3,72(sp)
    8000531e:	6a06                	ld	s4,64(sp)
    80005320:	7ae2                	ld	s5,56(sp)
    80005322:	7b42                	ld	s6,48(sp)
    80005324:	7ba2                	ld	s7,40(sp)
    80005326:	7c02                	ld	s8,32(sp)
    80005328:	6ce2                	ld	s9,24(sp)
    8000532a:	6d42                	ld	s10,16(sp)
    8000532c:	6da2                	ld	s11,8(sp)
    8000532e:	6165                	addi	sp,sp,112
    80005330:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80005332:	89da                	mv	s3,s6
    80005334:	bff1                	j	80005310 <readi+0xce>
    return 0;
    80005336:	4501                	li	a0,0
}
    80005338:	8082                	ret

000000008000533a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000533a:	457c                	lw	a5,76(a0)
    8000533c:	10d7e863          	bltu	a5,a3,8000544c <writei+0x112>
{
    80005340:	7159                	addi	sp,sp,-112
    80005342:	f486                	sd	ra,104(sp)
    80005344:	f0a2                	sd	s0,96(sp)
    80005346:	eca6                	sd	s1,88(sp)
    80005348:	e8ca                	sd	s2,80(sp)
    8000534a:	e4ce                	sd	s3,72(sp)
    8000534c:	e0d2                	sd	s4,64(sp)
    8000534e:	fc56                	sd	s5,56(sp)
    80005350:	f85a                	sd	s6,48(sp)
    80005352:	f45e                	sd	s7,40(sp)
    80005354:	f062                	sd	s8,32(sp)
    80005356:	ec66                	sd	s9,24(sp)
    80005358:	e86a                	sd	s10,16(sp)
    8000535a:	e46e                	sd	s11,8(sp)
    8000535c:	1880                	addi	s0,sp,112
    8000535e:	8b2a                	mv	s6,a0
    80005360:	8c2e                	mv	s8,a1
    80005362:	8ab2                	mv	s5,a2
    80005364:	8936                	mv	s2,a3
    80005366:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80005368:	00e687bb          	addw	a5,a3,a4
    8000536c:	0ed7e263          	bltu	a5,a3,80005450 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80005370:	00043737          	lui	a4,0x43
    80005374:	0ef76063          	bltu	a4,a5,80005454 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80005378:	0c0b8863          	beqz	s7,80005448 <writei+0x10e>
    8000537c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000537e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80005382:	5cfd                	li	s9,-1
    80005384:	a091                	j	800053c8 <writei+0x8e>
    80005386:	02099d93          	slli	s11,s3,0x20
    8000538a:	020ddd93          	srli	s11,s11,0x20
    8000538e:	05848513          	addi	a0,s1,88
    80005392:	86ee                	mv	a3,s11
    80005394:	8656                	mv	a2,s5
    80005396:	85e2                	mv	a1,s8
    80005398:	953a                	add	a0,a0,a4
    8000539a:	ffffe097          	auipc	ra,0xffffe
    8000539e:	e24080e7          	jalr	-476(ra) # 800031be <either_copyin>
    800053a2:	07950263          	beq	a0,s9,80005406 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800053a6:	8526                	mv	a0,s1
    800053a8:	00000097          	auipc	ra,0x0
    800053ac:	798080e7          	jalr	1944(ra) # 80005b40 <log_write>
    brelse(bp);
    800053b0:	8526                	mv	a0,s1
    800053b2:	fffff097          	auipc	ra,0xfffff
    800053b6:	50a080e7          	jalr	1290(ra) # 800048bc <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800053ba:	01498a3b          	addw	s4,s3,s4
    800053be:	0129893b          	addw	s2,s3,s2
    800053c2:	9aee                	add	s5,s5,s11
    800053c4:	057a7663          	bgeu	s4,s7,80005410 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800053c8:	000b2483          	lw	s1,0(s6)
    800053cc:	00a9559b          	srliw	a1,s2,0xa
    800053d0:	855a                	mv	a0,s6
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	7aa080e7          	jalr	1962(ra) # 80004b7c <bmap>
    800053da:	0005059b          	sext.w	a1,a0
    800053de:	8526                	mv	a0,s1
    800053e0:	fffff097          	auipc	ra,0xfffff
    800053e4:	3ac080e7          	jalr	940(ra) # 8000478c <bread>
    800053e8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800053ea:	3ff97713          	andi	a4,s2,1023
    800053ee:	40ed07bb          	subw	a5,s10,a4
    800053f2:	414b86bb          	subw	a3,s7,s4
    800053f6:	89be                	mv	s3,a5
    800053f8:	2781                	sext.w	a5,a5
    800053fa:	0006861b          	sext.w	a2,a3
    800053fe:	f8f674e3          	bgeu	a2,a5,80005386 <writei+0x4c>
    80005402:	89b6                	mv	s3,a3
    80005404:	b749                	j	80005386 <writei+0x4c>
      brelse(bp);
    80005406:	8526                	mv	a0,s1
    80005408:	fffff097          	auipc	ra,0xfffff
    8000540c:	4b4080e7          	jalr	1204(ra) # 800048bc <brelse>
  }

  if(off > ip->size)
    80005410:	04cb2783          	lw	a5,76(s6)
    80005414:	0127f463          	bgeu	a5,s2,8000541c <writei+0xe2>
    ip->size = off;
    80005418:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000541c:	855a                	mv	a0,s6
    8000541e:	00000097          	auipc	ra,0x0
    80005422:	aa4080e7          	jalr	-1372(ra) # 80004ec2 <iupdate>

  return tot;
    80005426:	000a051b          	sext.w	a0,s4
}
    8000542a:	70a6                	ld	ra,104(sp)
    8000542c:	7406                	ld	s0,96(sp)
    8000542e:	64e6                	ld	s1,88(sp)
    80005430:	6946                	ld	s2,80(sp)
    80005432:	69a6                	ld	s3,72(sp)
    80005434:	6a06                	ld	s4,64(sp)
    80005436:	7ae2                	ld	s5,56(sp)
    80005438:	7b42                	ld	s6,48(sp)
    8000543a:	7ba2                	ld	s7,40(sp)
    8000543c:	7c02                	ld	s8,32(sp)
    8000543e:	6ce2                	ld	s9,24(sp)
    80005440:	6d42                	ld	s10,16(sp)
    80005442:	6da2                	ld	s11,8(sp)
    80005444:	6165                	addi	sp,sp,112
    80005446:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80005448:	8a5e                	mv	s4,s7
    8000544a:	bfc9                	j	8000541c <writei+0xe2>
    return -1;
    8000544c:	557d                	li	a0,-1
}
    8000544e:	8082                	ret
    return -1;
    80005450:	557d                	li	a0,-1
    80005452:	bfe1                	j	8000542a <writei+0xf0>
    return -1;
    80005454:	557d                	li	a0,-1
    80005456:	bfd1                	j	8000542a <writei+0xf0>

0000000080005458 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80005458:	1141                	addi	sp,sp,-16
    8000545a:	e406                	sd	ra,8(sp)
    8000545c:	e022                	sd	s0,0(sp)
    8000545e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80005460:	4639                	li	a2,14
    80005462:	ffffc097          	auipc	ra,0xffffc
    80005466:	938080e7          	jalr	-1736(ra) # 80000d9a <strncmp>
}
    8000546a:	60a2                	ld	ra,8(sp)
    8000546c:	6402                	ld	s0,0(sp)
    8000546e:	0141                	addi	sp,sp,16
    80005470:	8082                	ret

0000000080005472 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80005472:	7139                	addi	sp,sp,-64
    80005474:	fc06                	sd	ra,56(sp)
    80005476:	f822                	sd	s0,48(sp)
    80005478:	f426                	sd	s1,40(sp)
    8000547a:	f04a                	sd	s2,32(sp)
    8000547c:	ec4e                	sd	s3,24(sp)
    8000547e:	e852                	sd	s4,16(sp)
    80005480:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80005482:	04451703          	lh	a4,68(a0)
    80005486:	4785                	li	a5,1
    80005488:	00f71a63          	bne	a4,a5,8000549c <dirlookup+0x2a>
    8000548c:	892a                	mv	s2,a0
    8000548e:	89ae                	mv	s3,a1
    80005490:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80005492:	457c                	lw	a5,76(a0)
    80005494:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80005496:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005498:	e79d                	bnez	a5,800054c6 <dirlookup+0x54>
    8000549a:	a8a5                	j	80005512 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000549c:	00004517          	auipc	a0,0x4
    800054a0:	49450513          	addi	a0,a0,1172 # 80009930 <syscalls+0x2f0>
    800054a4:	ffffb097          	auipc	ra,0xffffb
    800054a8:	094080e7          	jalr	148(ra) # 80000538 <panic>
      panic("dirlookup read");
    800054ac:	00004517          	auipc	a0,0x4
    800054b0:	49c50513          	addi	a0,a0,1180 # 80009948 <syscalls+0x308>
    800054b4:	ffffb097          	auipc	ra,0xffffb
    800054b8:	084080e7          	jalr	132(ra) # 80000538 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800054bc:	24c1                	addiw	s1,s1,16
    800054be:	04c92783          	lw	a5,76(s2)
    800054c2:	04f4f763          	bgeu	s1,a5,80005510 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054c6:	4741                	li	a4,16
    800054c8:	86a6                	mv	a3,s1
    800054ca:	fc040613          	addi	a2,s0,-64
    800054ce:	4581                	li	a1,0
    800054d0:	854a                	mv	a0,s2
    800054d2:	00000097          	auipc	ra,0x0
    800054d6:	d70080e7          	jalr	-656(ra) # 80005242 <readi>
    800054da:	47c1                	li	a5,16
    800054dc:	fcf518e3          	bne	a0,a5,800054ac <dirlookup+0x3a>
    if(de.inum == 0)
    800054e0:	fc045783          	lhu	a5,-64(s0)
    800054e4:	dfe1                	beqz	a5,800054bc <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800054e6:	fc240593          	addi	a1,s0,-62
    800054ea:	854e                	mv	a0,s3
    800054ec:	00000097          	auipc	ra,0x0
    800054f0:	f6c080e7          	jalr	-148(ra) # 80005458 <namecmp>
    800054f4:	f561                	bnez	a0,800054bc <dirlookup+0x4a>
      if(poff)
    800054f6:	000a0463          	beqz	s4,800054fe <dirlookup+0x8c>
        *poff = off;
    800054fa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800054fe:	fc045583          	lhu	a1,-64(s0)
    80005502:	00092503          	lw	a0,0(s2)
    80005506:	fffff097          	auipc	ra,0xfffff
    8000550a:	752080e7          	jalr	1874(ra) # 80004c58 <iget>
    8000550e:	a011                	j	80005512 <dirlookup+0xa0>
  return 0;
    80005510:	4501                	li	a0,0
}
    80005512:	70e2                	ld	ra,56(sp)
    80005514:	7442                	ld	s0,48(sp)
    80005516:	74a2                	ld	s1,40(sp)
    80005518:	7902                	ld	s2,32(sp)
    8000551a:	69e2                	ld	s3,24(sp)
    8000551c:	6a42                	ld	s4,16(sp)
    8000551e:	6121                	addi	sp,sp,64
    80005520:	8082                	ret

0000000080005522 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80005522:	711d                	addi	sp,sp,-96
    80005524:	ec86                	sd	ra,88(sp)
    80005526:	e8a2                	sd	s0,80(sp)
    80005528:	e4a6                	sd	s1,72(sp)
    8000552a:	e0ca                	sd	s2,64(sp)
    8000552c:	fc4e                	sd	s3,56(sp)
    8000552e:	f852                	sd	s4,48(sp)
    80005530:	f456                	sd	s5,40(sp)
    80005532:	f05a                	sd	s6,32(sp)
    80005534:	ec5e                	sd	s7,24(sp)
    80005536:	e862                	sd	s8,16(sp)
    80005538:	e466                	sd	s9,8(sp)
    8000553a:	e06a                	sd	s10,0(sp)
    8000553c:	1080                	addi	s0,sp,96
    8000553e:	84aa                	mv	s1,a0
    80005540:	8b2e                	mv	s6,a1
    80005542:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80005544:	00054703          	lbu	a4,0(a0)
    80005548:	02f00793          	li	a5,47
    8000554c:	02f70363          	beq	a4,a5,80005572 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80005550:	ffffc097          	auipc	ra,0xffffc
    80005554:	46a080e7          	jalr	1130(ra) # 800019ba <myproc>
    80005558:	15853503          	ld	a0,344(a0)
    8000555c:	00000097          	auipc	ra,0x0
    80005560:	9f4080e7          	jalr	-1548(ra) # 80004f50 <idup>
    80005564:	8a2a                	mv	s4,a0
  while(*path == '/')
    80005566:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000556a:	4cb5                	li	s9,13
  len = path - s;
    8000556c:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000556e:	4c05                	li	s8,1
    80005570:	a87d                	j	8000562e <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80005572:	4585                	li	a1,1
    80005574:	4505                	li	a0,1
    80005576:	fffff097          	auipc	ra,0xfffff
    8000557a:	6e2080e7          	jalr	1762(ra) # 80004c58 <iget>
    8000557e:	8a2a                	mv	s4,a0
    80005580:	b7dd                	j	80005566 <namex+0x44>
      iunlockput(ip);
    80005582:	8552                	mv	a0,s4
    80005584:	00000097          	auipc	ra,0x0
    80005588:	c6c080e7          	jalr	-916(ra) # 800051f0 <iunlockput>
      return 0;
    8000558c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000558e:	8552                	mv	a0,s4
    80005590:	60e6                	ld	ra,88(sp)
    80005592:	6446                	ld	s0,80(sp)
    80005594:	64a6                	ld	s1,72(sp)
    80005596:	6906                	ld	s2,64(sp)
    80005598:	79e2                	ld	s3,56(sp)
    8000559a:	7a42                	ld	s4,48(sp)
    8000559c:	7aa2                	ld	s5,40(sp)
    8000559e:	7b02                	ld	s6,32(sp)
    800055a0:	6be2                	ld	s7,24(sp)
    800055a2:	6c42                	ld	s8,16(sp)
    800055a4:	6ca2                	ld	s9,8(sp)
    800055a6:	6d02                	ld	s10,0(sp)
    800055a8:	6125                	addi	sp,sp,96
    800055aa:	8082                	ret
      iunlock(ip);
    800055ac:	8552                	mv	a0,s4
    800055ae:	00000097          	auipc	ra,0x0
    800055b2:	aa2080e7          	jalr	-1374(ra) # 80005050 <iunlock>
      return ip;
    800055b6:	bfe1                	j	8000558e <namex+0x6c>
      iunlockput(ip);
    800055b8:	8552                	mv	a0,s4
    800055ba:	00000097          	auipc	ra,0x0
    800055be:	c36080e7          	jalr	-970(ra) # 800051f0 <iunlockput>
      return 0;
    800055c2:	8a4e                	mv	s4,s3
    800055c4:	b7e9                	j	8000558e <namex+0x6c>
  len = path - s;
    800055c6:	40998633          	sub	a2,s3,s1
    800055ca:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800055ce:	09acd863          	bge	s9,s10,8000565e <namex+0x13c>
    memmove(name, s, DIRSIZ);
    800055d2:	4639                	li	a2,14
    800055d4:	85a6                	mv	a1,s1
    800055d6:	8556                	mv	a0,s5
    800055d8:	ffffb097          	auipc	ra,0xffffb
    800055dc:	74e080e7          	jalr	1870(ra) # 80000d26 <memmove>
    800055e0:	84ce                	mv	s1,s3
  while(*path == '/')
    800055e2:	0004c783          	lbu	a5,0(s1)
    800055e6:	01279763          	bne	a5,s2,800055f4 <namex+0xd2>
    path++;
    800055ea:	0485                	addi	s1,s1,1
  while(*path == '/')
    800055ec:	0004c783          	lbu	a5,0(s1)
    800055f0:	ff278de3          	beq	a5,s2,800055ea <namex+0xc8>
    ilock(ip);
    800055f4:	8552                	mv	a0,s4
    800055f6:	00000097          	auipc	ra,0x0
    800055fa:	998080e7          	jalr	-1640(ra) # 80004f8e <ilock>
    if(ip->type != T_DIR){
    800055fe:	044a1783          	lh	a5,68(s4)
    80005602:	f98790e3          	bne	a5,s8,80005582 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80005606:	000b0563          	beqz	s6,80005610 <namex+0xee>
    8000560a:	0004c783          	lbu	a5,0(s1)
    8000560e:	dfd9                	beqz	a5,800055ac <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80005610:	865e                	mv	a2,s7
    80005612:	85d6                	mv	a1,s5
    80005614:	8552                	mv	a0,s4
    80005616:	00000097          	auipc	ra,0x0
    8000561a:	e5c080e7          	jalr	-420(ra) # 80005472 <dirlookup>
    8000561e:	89aa                	mv	s3,a0
    80005620:	dd41                	beqz	a0,800055b8 <namex+0x96>
    iunlockput(ip);
    80005622:	8552                	mv	a0,s4
    80005624:	00000097          	auipc	ra,0x0
    80005628:	bcc080e7          	jalr	-1076(ra) # 800051f0 <iunlockput>
    ip = next;
    8000562c:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000562e:	0004c783          	lbu	a5,0(s1)
    80005632:	01279763          	bne	a5,s2,80005640 <namex+0x11e>
    path++;
    80005636:	0485                	addi	s1,s1,1
  while(*path == '/')
    80005638:	0004c783          	lbu	a5,0(s1)
    8000563c:	ff278de3          	beq	a5,s2,80005636 <namex+0x114>
  if(*path == 0)
    80005640:	cb9d                	beqz	a5,80005676 <namex+0x154>
  while(*path != '/' && *path != 0)
    80005642:	0004c783          	lbu	a5,0(s1)
    80005646:	89a6                	mv	s3,s1
  len = path - s;
    80005648:	8d5e                	mv	s10,s7
    8000564a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000564c:	01278963          	beq	a5,s2,8000565e <namex+0x13c>
    80005650:	dbbd                	beqz	a5,800055c6 <namex+0xa4>
    path++;
    80005652:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80005654:	0009c783          	lbu	a5,0(s3)
    80005658:	ff279ce3          	bne	a5,s2,80005650 <namex+0x12e>
    8000565c:	b7ad                	j	800055c6 <namex+0xa4>
    memmove(name, s, len);
    8000565e:	2601                	sext.w	a2,a2
    80005660:	85a6                	mv	a1,s1
    80005662:	8556                	mv	a0,s5
    80005664:	ffffb097          	auipc	ra,0xffffb
    80005668:	6c2080e7          	jalr	1730(ra) # 80000d26 <memmove>
    name[len] = 0;
    8000566c:	9d56                	add	s10,s10,s5
    8000566e:	000d0023          	sb	zero,0(s10)
    80005672:	84ce                	mv	s1,s3
    80005674:	b7bd                	j	800055e2 <namex+0xc0>
  if(nameiparent){
    80005676:	f00b0ce3          	beqz	s6,8000558e <namex+0x6c>
    iput(ip);
    8000567a:	8552                	mv	a0,s4
    8000567c:	00000097          	auipc	ra,0x0
    80005680:	acc080e7          	jalr	-1332(ra) # 80005148 <iput>
    return 0;
    80005684:	4a01                	li	s4,0
    80005686:	b721                	j	8000558e <namex+0x6c>

0000000080005688 <dirlink>:
{
    80005688:	7139                	addi	sp,sp,-64
    8000568a:	fc06                	sd	ra,56(sp)
    8000568c:	f822                	sd	s0,48(sp)
    8000568e:	f426                	sd	s1,40(sp)
    80005690:	f04a                	sd	s2,32(sp)
    80005692:	ec4e                	sd	s3,24(sp)
    80005694:	e852                	sd	s4,16(sp)
    80005696:	0080                	addi	s0,sp,64
    80005698:	892a                	mv	s2,a0
    8000569a:	8a2e                	mv	s4,a1
    8000569c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000569e:	4601                	li	a2,0
    800056a0:	00000097          	auipc	ra,0x0
    800056a4:	dd2080e7          	jalr	-558(ra) # 80005472 <dirlookup>
    800056a8:	e93d                	bnez	a0,8000571e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800056aa:	04c92483          	lw	s1,76(s2)
    800056ae:	c49d                	beqz	s1,800056dc <dirlink+0x54>
    800056b0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056b2:	4741                	li	a4,16
    800056b4:	86a6                	mv	a3,s1
    800056b6:	fc040613          	addi	a2,s0,-64
    800056ba:	4581                	li	a1,0
    800056bc:	854a                	mv	a0,s2
    800056be:	00000097          	auipc	ra,0x0
    800056c2:	b84080e7          	jalr	-1148(ra) # 80005242 <readi>
    800056c6:	47c1                	li	a5,16
    800056c8:	06f51163          	bne	a0,a5,8000572a <dirlink+0xa2>
    if(de.inum == 0)
    800056cc:	fc045783          	lhu	a5,-64(s0)
    800056d0:	c791                	beqz	a5,800056dc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800056d2:	24c1                	addiw	s1,s1,16
    800056d4:	04c92783          	lw	a5,76(s2)
    800056d8:	fcf4ede3          	bltu	s1,a5,800056b2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800056dc:	4639                	li	a2,14
    800056de:	85d2                	mv	a1,s4
    800056e0:	fc240513          	addi	a0,s0,-62
    800056e4:	ffffb097          	auipc	ra,0xffffb
    800056e8:	6f2080e7          	jalr	1778(ra) # 80000dd6 <strncpy>
  de.inum = inum;
    800056ec:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056f0:	4741                	li	a4,16
    800056f2:	86a6                	mv	a3,s1
    800056f4:	fc040613          	addi	a2,s0,-64
    800056f8:	4581                	li	a1,0
    800056fa:	854a                	mv	a0,s2
    800056fc:	00000097          	auipc	ra,0x0
    80005700:	c3e080e7          	jalr	-962(ra) # 8000533a <writei>
    80005704:	872a                	mv	a4,a0
    80005706:	47c1                	li	a5,16
  return 0;
    80005708:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000570a:	02f71863          	bne	a4,a5,8000573a <dirlink+0xb2>
}
    8000570e:	70e2                	ld	ra,56(sp)
    80005710:	7442                	ld	s0,48(sp)
    80005712:	74a2                	ld	s1,40(sp)
    80005714:	7902                	ld	s2,32(sp)
    80005716:	69e2                	ld	s3,24(sp)
    80005718:	6a42                	ld	s4,16(sp)
    8000571a:	6121                	addi	sp,sp,64
    8000571c:	8082                	ret
    iput(ip);
    8000571e:	00000097          	auipc	ra,0x0
    80005722:	a2a080e7          	jalr	-1494(ra) # 80005148 <iput>
    return -1;
    80005726:	557d                	li	a0,-1
    80005728:	b7dd                	j	8000570e <dirlink+0x86>
      panic("dirlink read");
    8000572a:	00004517          	auipc	a0,0x4
    8000572e:	22e50513          	addi	a0,a0,558 # 80009958 <syscalls+0x318>
    80005732:	ffffb097          	auipc	ra,0xffffb
    80005736:	e06080e7          	jalr	-506(ra) # 80000538 <panic>
    panic("dirlink");
    8000573a:	00004517          	auipc	a0,0x4
    8000573e:	32e50513          	addi	a0,a0,814 # 80009a68 <syscalls+0x428>
    80005742:	ffffb097          	auipc	ra,0xffffb
    80005746:	df6080e7          	jalr	-522(ra) # 80000538 <panic>

000000008000574a <namei>:

struct inode*
namei(char *path)
{
    8000574a:	1101                	addi	sp,sp,-32
    8000574c:	ec06                	sd	ra,24(sp)
    8000574e:	e822                	sd	s0,16(sp)
    80005750:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80005752:	fe040613          	addi	a2,s0,-32
    80005756:	4581                	li	a1,0
    80005758:	00000097          	auipc	ra,0x0
    8000575c:	dca080e7          	jalr	-566(ra) # 80005522 <namex>
}
    80005760:	60e2                	ld	ra,24(sp)
    80005762:	6442                	ld	s0,16(sp)
    80005764:	6105                	addi	sp,sp,32
    80005766:	8082                	ret

0000000080005768 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80005768:	1141                	addi	sp,sp,-16
    8000576a:	e406                	sd	ra,8(sp)
    8000576c:	e022                	sd	s0,0(sp)
    8000576e:	0800                	addi	s0,sp,16
    80005770:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80005772:	4585                	li	a1,1
    80005774:	00000097          	auipc	ra,0x0
    80005778:	dae080e7          	jalr	-594(ra) # 80005522 <namex>
}
    8000577c:	60a2                	ld	ra,8(sp)
    8000577e:	6402                	ld	s0,0(sp)
    80005780:	0141                	addi	sp,sp,16
    80005782:	8082                	ret

0000000080005784 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80005784:	1101                	addi	sp,sp,-32
    80005786:	ec06                	sd	ra,24(sp)
    80005788:	e822                	sd	s0,16(sp)
    8000578a:	e426                	sd	s1,8(sp)
    8000578c:	e04a                	sd	s2,0(sp)
    8000578e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80005790:	0001e917          	auipc	s2,0x1e
    80005794:	e8090913          	addi	s2,s2,-384 # 80023610 <log>
    80005798:	01892583          	lw	a1,24(s2)
    8000579c:	02892503          	lw	a0,40(s2)
    800057a0:	fffff097          	auipc	ra,0xfffff
    800057a4:	fec080e7          	jalr	-20(ra) # 8000478c <bread>
    800057a8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800057aa:	02c92683          	lw	a3,44(s2)
    800057ae:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800057b0:	02d05863          	blez	a3,800057e0 <write_head+0x5c>
    800057b4:	0001e797          	auipc	a5,0x1e
    800057b8:	e8c78793          	addi	a5,a5,-372 # 80023640 <log+0x30>
    800057bc:	05c50713          	addi	a4,a0,92
    800057c0:	36fd                	addiw	a3,a3,-1
    800057c2:	02069613          	slli	a2,a3,0x20
    800057c6:	01e65693          	srli	a3,a2,0x1e
    800057ca:	0001e617          	auipc	a2,0x1e
    800057ce:	e7a60613          	addi	a2,a2,-390 # 80023644 <log+0x34>
    800057d2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800057d4:	4390                	lw	a2,0(a5)
    800057d6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800057d8:	0791                	addi	a5,a5,4
    800057da:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800057dc:	fed79ce3          	bne	a5,a3,800057d4 <write_head+0x50>
  }
  bwrite(buf);
    800057e0:	8526                	mv	a0,s1
    800057e2:	fffff097          	auipc	ra,0xfffff
    800057e6:	09c080e7          	jalr	156(ra) # 8000487e <bwrite>
  brelse(buf);
    800057ea:	8526                	mv	a0,s1
    800057ec:	fffff097          	auipc	ra,0xfffff
    800057f0:	0d0080e7          	jalr	208(ra) # 800048bc <brelse>
}
    800057f4:	60e2                	ld	ra,24(sp)
    800057f6:	6442                	ld	s0,16(sp)
    800057f8:	64a2                	ld	s1,8(sp)
    800057fa:	6902                	ld	s2,0(sp)
    800057fc:	6105                	addi	sp,sp,32
    800057fe:	8082                	ret

0000000080005800 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80005800:	0001e797          	auipc	a5,0x1e
    80005804:	e3c7a783          	lw	a5,-452(a5) # 8002363c <log+0x2c>
    80005808:	0af05d63          	blez	a5,800058c2 <install_trans+0xc2>
{
    8000580c:	7139                	addi	sp,sp,-64
    8000580e:	fc06                	sd	ra,56(sp)
    80005810:	f822                	sd	s0,48(sp)
    80005812:	f426                	sd	s1,40(sp)
    80005814:	f04a                	sd	s2,32(sp)
    80005816:	ec4e                	sd	s3,24(sp)
    80005818:	e852                	sd	s4,16(sp)
    8000581a:	e456                	sd	s5,8(sp)
    8000581c:	e05a                	sd	s6,0(sp)
    8000581e:	0080                	addi	s0,sp,64
    80005820:	8b2a                	mv	s6,a0
    80005822:	0001ea97          	auipc	s5,0x1e
    80005826:	e1ea8a93          	addi	s5,s5,-482 # 80023640 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000582a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000582c:	0001e997          	auipc	s3,0x1e
    80005830:	de498993          	addi	s3,s3,-540 # 80023610 <log>
    80005834:	a00d                	j	80005856 <install_trans+0x56>
    brelse(lbuf);
    80005836:	854a                	mv	a0,s2
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	084080e7          	jalr	132(ra) # 800048bc <brelse>
    brelse(dbuf);
    80005840:	8526                	mv	a0,s1
    80005842:	fffff097          	auipc	ra,0xfffff
    80005846:	07a080e7          	jalr	122(ra) # 800048bc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000584a:	2a05                	addiw	s4,s4,1
    8000584c:	0a91                	addi	s5,s5,4
    8000584e:	02c9a783          	lw	a5,44(s3)
    80005852:	04fa5e63          	bge	s4,a5,800058ae <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005856:	0189a583          	lw	a1,24(s3)
    8000585a:	014585bb          	addw	a1,a1,s4
    8000585e:	2585                	addiw	a1,a1,1
    80005860:	0289a503          	lw	a0,40(s3)
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	f28080e7          	jalr	-216(ra) # 8000478c <bread>
    8000586c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000586e:	000aa583          	lw	a1,0(s5)
    80005872:	0289a503          	lw	a0,40(s3)
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	f16080e7          	jalr	-234(ra) # 8000478c <bread>
    8000587e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005880:	40000613          	li	a2,1024
    80005884:	05890593          	addi	a1,s2,88
    80005888:	05850513          	addi	a0,a0,88
    8000588c:	ffffb097          	auipc	ra,0xffffb
    80005890:	49a080e7          	jalr	1178(ra) # 80000d26 <memmove>
    bwrite(dbuf);  // write dst to disk
    80005894:	8526                	mv	a0,s1
    80005896:	fffff097          	auipc	ra,0xfffff
    8000589a:	fe8080e7          	jalr	-24(ra) # 8000487e <bwrite>
    if(recovering == 0)
    8000589e:	f80b1ce3          	bnez	s6,80005836 <install_trans+0x36>
      bunpin(dbuf);
    800058a2:	8526                	mv	a0,s1
    800058a4:	fffff097          	auipc	ra,0xfffff
    800058a8:	0f2080e7          	jalr	242(ra) # 80004996 <bunpin>
    800058ac:	b769                	j	80005836 <install_trans+0x36>
}
    800058ae:	70e2                	ld	ra,56(sp)
    800058b0:	7442                	ld	s0,48(sp)
    800058b2:	74a2                	ld	s1,40(sp)
    800058b4:	7902                	ld	s2,32(sp)
    800058b6:	69e2                	ld	s3,24(sp)
    800058b8:	6a42                	ld	s4,16(sp)
    800058ba:	6aa2                	ld	s5,8(sp)
    800058bc:	6b02                	ld	s6,0(sp)
    800058be:	6121                	addi	sp,sp,64
    800058c0:	8082                	ret
    800058c2:	8082                	ret

00000000800058c4 <initlog>:
{
    800058c4:	7179                	addi	sp,sp,-48
    800058c6:	f406                	sd	ra,40(sp)
    800058c8:	f022                	sd	s0,32(sp)
    800058ca:	ec26                	sd	s1,24(sp)
    800058cc:	e84a                	sd	s2,16(sp)
    800058ce:	e44e                	sd	s3,8(sp)
    800058d0:	1800                	addi	s0,sp,48
    800058d2:	892a                	mv	s2,a0
    800058d4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800058d6:	0001e497          	auipc	s1,0x1e
    800058da:	d3a48493          	addi	s1,s1,-710 # 80023610 <log>
    800058de:	00004597          	auipc	a1,0x4
    800058e2:	08a58593          	addi	a1,a1,138 # 80009968 <syscalls+0x328>
    800058e6:	8526                	mv	a0,s1
    800058e8:	ffffb097          	auipc	ra,0xffffb
    800058ec:	256080e7          	jalr	598(ra) # 80000b3e <initlock>
  log.start = sb->logstart;
    800058f0:	0149a583          	lw	a1,20(s3)
    800058f4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800058f6:	0109a783          	lw	a5,16(s3)
    800058fa:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800058fc:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80005900:	854a                	mv	a0,s2
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	e8a080e7          	jalr	-374(ra) # 8000478c <bread>
  log.lh.n = lh->n;
    8000590a:	4d34                	lw	a3,88(a0)
    8000590c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000590e:	02d05663          	blez	a3,8000593a <initlog+0x76>
    80005912:	05c50793          	addi	a5,a0,92
    80005916:	0001e717          	auipc	a4,0x1e
    8000591a:	d2a70713          	addi	a4,a4,-726 # 80023640 <log+0x30>
    8000591e:	36fd                	addiw	a3,a3,-1
    80005920:	02069613          	slli	a2,a3,0x20
    80005924:	01e65693          	srli	a3,a2,0x1e
    80005928:	06050613          	addi	a2,a0,96
    8000592c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000592e:	4390                	lw	a2,0(a5)
    80005930:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005932:	0791                	addi	a5,a5,4
    80005934:	0711                	addi	a4,a4,4
    80005936:	fed79ce3          	bne	a5,a3,8000592e <initlog+0x6a>
  brelse(buf);
    8000593a:	fffff097          	auipc	ra,0xfffff
    8000593e:	f82080e7          	jalr	-126(ra) # 800048bc <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005942:	4505                	li	a0,1
    80005944:	00000097          	auipc	ra,0x0
    80005948:	ebc080e7          	jalr	-324(ra) # 80005800 <install_trans>
  log.lh.n = 0;
    8000594c:	0001e797          	auipc	a5,0x1e
    80005950:	ce07a823          	sw	zero,-784(a5) # 8002363c <log+0x2c>
  write_head(); // clear the log
    80005954:	00000097          	auipc	ra,0x0
    80005958:	e30080e7          	jalr	-464(ra) # 80005784 <write_head>
}
    8000595c:	70a2                	ld	ra,40(sp)
    8000595e:	7402                	ld	s0,32(sp)
    80005960:	64e2                	ld	s1,24(sp)
    80005962:	6942                	ld	s2,16(sp)
    80005964:	69a2                	ld	s3,8(sp)
    80005966:	6145                	addi	sp,sp,48
    80005968:	8082                	ret

000000008000596a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000596a:	1101                	addi	sp,sp,-32
    8000596c:	ec06                	sd	ra,24(sp)
    8000596e:	e822                	sd	s0,16(sp)
    80005970:	e426                	sd	s1,8(sp)
    80005972:	e04a                	sd	s2,0(sp)
    80005974:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80005976:	0001e517          	auipc	a0,0x1e
    8000597a:	c9a50513          	addi	a0,a0,-870 # 80023610 <log>
    8000597e:	ffffb097          	auipc	ra,0xffffb
    80005982:	250080e7          	jalr	592(ra) # 80000bce <acquire>
  while(1){
    if(log.committing){
    80005986:	0001e497          	auipc	s1,0x1e
    8000598a:	c8a48493          	addi	s1,s1,-886 # 80023610 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000598e:	4979                	li	s2,30
    80005990:	a039                	j	8000599e <begin_op+0x34>
      sleep(&log, &log.lock);
    80005992:	85a6                	mv	a1,s1
    80005994:	8526                	mv	a0,s1
    80005996:	ffffd097          	auipc	ra,0xffffd
    8000599a:	dd6080e7          	jalr	-554(ra) # 8000276c <sleep>
    if(log.committing){
    8000599e:	50dc                	lw	a5,36(s1)
    800059a0:	fbed                	bnez	a5,80005992 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800059a2:	5098                	lw	a4,32(s1)
    800059a4:	2705                	addiw	a4,a4,1
    800059a6:	0007069b          	sext.w	a3,a4
    800059aa:	0027179b          	slliw	a5,a4,0x2
    800059ae:	9fb9                	addw	a5,a5,a4
    800059b0:	0017979b          	slliw	a5,a5,0x1
    800059b4:	54d8                	lw	a4,44(s1)
    800059b6:	9fb9                	addw	a5,a5,a4
    800059b8:	00f95963          	bge	s2,a5,800059ca <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800059bc:	85a6                	mv	a1,s1
    800059be:	8526                	mv	a0,s1
    800059c0:	ffffd097          	auipc	ra,0xffffd
    800059c4:	dac080e7          	jalr	-596(ra) # 8000276c <sleep>
    800059c8:	bfd9                	j	8000599e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800059ca:	0001e517          	auipc	a0,0x1e
    800059ce:	c4650513          	addi	a0,a0,-954 # 80023610 <log>
    800059d2:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800059d4:	ffffb097          	auipc	ra,0xffffb
    800059d8:	2ae080e7          	jalr	686(ra) # 80000c82 <release>
      break;
    }
  }
}
    800059dc:	60e2                	ld	ra,24(sp)
    800059de:	6442                	ld	s0,16(sp)
    800059e0:	64a2                	ld	s1,8(sp)
    800059e2:	6902                	ld	s2,0(sp)
    800059e4:	6105                	addi	sp,sp,32
    800059e6:	8082                	ret

00000000800059e8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800059e8:	7139                	addi	sp,sp,-64
    800059ea:	fc06                	sd	ra,56(sp)
    800059ec:	f822                	sd	s0,48(sp)
    800059ee:	f426                	sd	s1,40(sp)
    800059f0:	f04a                	sd	s2,32(sp)
    800059f2:	ec4e                	sd	s3,24(sp)
    800059f4:	e852                	sd	s4,16(sp)
    800059f6:	e456                	sd	s5,8(sp)
    800059f8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800059fa:	0001e497          	auipc	s1,0x1e
    800059fe:	c1648493          	addi	s1,s1,-1002 # 80023610 <log>
    80005a02:	8526                	mv	a0,s1
    80005a04:	ffffb097          	auipc	ra,0xffffb
    80005a08:	1ca080e7          	jalr	458(ra) # 80000bce <acquire>
  log.outstanding -= 1;
    80005a0c:	509c                	lw	a5,32(s1)
    80005a0e:	37fd                	addiw	a5,a5,-1
    80005a10:	0007891b          	sext.w	s2,a5
    80005a14:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80005a16:	50dc                	lw	a5,36(s1)
    80005a18:	e7b9                	bnez	a5,80005a66 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80005a1a:	04091e63          	bnez	s2,80005a76 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80005a1e:	0001e497          	auipc	s1,0x1e
    80005a22:	bf248493          	addi	s1,s1,-1038 # 80023610 <log>
    80005a26:	4785                	li	a5,1
    80005a28:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80005a2a:	8526                	mv	a0,s1
    80005a2c:	ffffb097          	auipc	ra,0xffffb
    80005a30:	256080e7          	jalr	598(ra) # 80000c82 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80005a34:	54dc                	lw	a5,44(s1)
    80005a36:	06f04763          	bgtz	a5,80005aa4 <end_op+0xbc>
    acquire(&log.lock);
    80005a3a:	0001e497          	auipc	s1,0x1e
    80005a3e:	bd648493          	addi	s1,s1,-1066 # 80023610 <log>
    80005a42:	8526                	mv	a0,s1
    80005a44:	ffffb097          	auipc	ra,0xffffb
    80005a48:	18a080e7          	jalr	394(ra) # 80000bce <acquire>
    log.committing = 0;
    80005a4c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80005a50:	8526                	mv	a0,s1
    80005a52:	ffffd097          	auipc	ra,0xffffd
    80005a56:	11e080e7          	jalr	286(ra) # 80002b70 <wakeup>
    release(&log.lock);
    80005a5a:	8526                	mv	a0,s1
    80005a5c:	ffffb097          	auipc	ra,0xffffb
    80005a60:	226080e7          	jalr	550(ra) # 80000c82 <release>
}
    80005a64:	a03d                	j	80005a92 <end_op+0xaa>
    panic("log.committing");
    80005a66:	00004517          	auipc	a0,0x4
    80005a6a:	f0a50513          	addi	a0,a0,-246 # 80009970 <syscalls+0x330>
    80005a6e:	ffffb097          	auipc	ra,0xffffb
    80005a72:	aca080e7          	jalr	-1334(ra) # 80000538 <panic>
    wakeup(&log);
    80005a76:	0001e497          	auipc	s1,0x1e
    80005a7a:	b9a48493          	addi	s1,s1,-1126 # 80023610 <log>
    80005a7e:	8526                	mv	a0,s1
    80005a80:	ffffd097          	auipc	ra,0xffffd
    80005a84:	0f0080e7          	jalr	240(ra) # 80002b70 <wakeup>
  release(&log.lock);
    80005a88:	8526                	mv	a0,s1
    80005a8a:	ffffb097          	auipc	ra,0xffffb
    80005a8e:	1f8080e7          	jalr	504(ra) # 80000c82 <release>
}
    80005a92:	70e2                	ld	ra,56(sp)
    80005a94:	7442                	ld	s0,48(sp)
    80005a96:	74a2                	ld	s1,40(sp)
    80005a98:	7902                	ld	s2,32(sp)
    80005a9a:	69e2                	ld	s3,24(sp)
    80005a9c:	6a42                	ld	s4,16(sp)
    80005a9e:	6aa2                	ld	s5,8(sp)
    80005aa0:	6121                	addi	sp,sp,64
    80005aa2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80005aa4:	0001ea97          	auipc	s5,0x1e
    80005aa8:	b9ca8a93          	addi	s5,s5,-1124 # 80023640 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005aac:	0001ea17          	auipc	s4,0x1e
    80005ab0:	b64a0a13          	addi	s4,s4,-1180 # 80023610 <log>
    80005ab4:	018a2583          	lw	a1,24(s4)
    80005ab8:	012585bb          	addw	a1,a1,s2
    80005abc:	2585                	addiw	a1,a1,1
    80005abe:	028a2503          	lw	a0,40(s4)
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	cca080e7          	jalr	-822(ra) # 8000478c <bread>
    80005aca:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005acc:	000aa583          	lw	a1,0(s5)
    80005ad0:	028a2503          	lw	a0,40(s4)
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	cb8080e7          	jalr	-840(ra) # 8000478c <bread>
    80005adc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005ade:	40000613          	li	a2,1024
    80005ae2:	05850593          	addi	a1,a0,88
    80005ae6:	05848513          	addi	a0,s1,88
    80005aea:	ffffb097          	auipc	ra,0xffffb
    80005aee:	23c080e7          	jalr	572(ra) # 80000d26 <memmove>
    bwrite(to);  // write the log
    80005af2:	8526                	mv	a0,s1
    80005af4:	fffff097          	auipc	ra,0xfffff
    80005af8:	d8a080e7          	jalr	-630(ra) # 8000487e <bwrite>
    brelse(from);
    80005afc:	854e                	mv	a0,s3
    80005afe:	fffff097          	auipc	ra,0xfffff
    80005b02:	dbe080e7          	jalr	-578(ra) # 800048bc <brelse>
    brelse(to);
    80005b06:	8526                	mv	a0,s1
    80005b08:	fffff097          	auipc	ra,0xfffff
    80005b0c:	db4080e7          	jalr	-588(ra) # 800048bc <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005b10:	2905                	addiw	s2,s2,1
    80005b12:	0a91                	addi	s5,s5,4
    80005b14:	02ca2783          	lw	a5,44(s4)
    80005b18:	f8f94ee3          	blt	s2,a5,80005ab4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80005b1c:	00000097          	auipc	ra,0x0
    80005b20:	c68080e7          	jalr	-920(ra) # 80005784 <write_head>
    install_trans(0); // Now install writes to home locations
    80005b24:	4501                	li	a0,0
    80005b26:	00000097          	auipc	ra,0x0
    80005b2a:	cda080e7          	jalr	-806(ra) # 80005800 <install_trans>
    log.lh.n = 0;
    80005b2e:	0001e797          	auipc	a5,0x1e
    80005b32:	b007a723          	sw	zero,-1266(a5) # 8002363c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80005b36:	00000097          	auipc	ra,0x0
    80005b3a:	c4e080e7          	jalr	-946(ra) # 80005784 <write_head>
    80005b3e:	bdf5                	j	80005a3a <end_op+0x52>

0000000080005b40 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80005b40:	1101                	addi	sp,sp,-32
    80005b42:	ec06                	sd	ra,24(sp)
    80005b44:	e822                	sd	s0,16(sp)
    80005b46:	e426                	sd	s1,8(sp)
    80005b48:	e04a                	sd	s2,0(sp)
    80005b4a:	1000                	addi	s0,sp,32
    80005b4c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80005b4e:	0001e917          	auipc	s2,0x1e
    80005b52:	ac290913          	addi	s2,s2,-1342 # 80023610 <log>
    80005b56:	854a                	mv	a0,s2
    80005b58:	ffffb097          	auipc	ra,0xffffb
    80005b5c:	076080e7          	jalr	118(ra) # 80000bce <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80005b60:	02c92603          	lw	a2,44(s2)
    80005b64:	47f5                	li	a5,29
    80005b66:	06c7c563          	blt	a5,a2,80005bd0 <log_write+0x90>
    80005b6a:	0001e797          	auipc	a5,0x1e
    80005b6e:	ac27a783          	lw	a5,-1342(a5) # 8002362c <log+0x1c>
    80005b72:	37fd                	addiw	a5,a5,-1
    80005b74:	04f65e63          	bge	a2,a5,80005bd0 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005b78:	0001e797          	auipc	a5,0x1e
    80005b7c:	ab87a783          	lw	a5,-1352(a5) # 80023630 <log+0x20>
    80005b80:	06f05063          	blez	a5,80005be0 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005b84:	4781                	li	a5,0
    80005b86:	06c05563          	blez	a2,80005bf0 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005b8a:	44cc                	lw	a1,12(s1)
    80005b8c:	0001e717          	auipc	a4,0x1e
    80005b90:	ab470713          	addi	a4,a4,-1356 # 80023640 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005b94:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005b96:	4314                	lw	a3,0(a4)
    80005b98:	04b68c63          	beq	a3,a1,80005bf0 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005b9c:	2785                	addiw	a5,a5,1
    80005b9e:	0711                	addi	a4,a4,4
    80005ba0:	fef61be3          	bne	a2,a5,80005b96 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005ba4:	0621                	addi	a2,a2,8
    80005ba6:	060a                	slli	a2,a2,0x2
    80005ba8:	0001e797          	auipc	a5,0x1e
    80005bac:	a6878793          	addi	a5,a5,-1432 # 80023610 <log>
    80005bb0:	97b2                	add	a5,a5,a2
    80005bb2:	44d8                	lw	a4,12(s1)
    80005bb4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005bb6:	8526                	mv	a0,s1
    80005bb8:	fffff097          	auipc	ra,0xfffff
    80005bbc:	da2080e7          	jalr	-606(ra) # 8000495a <bpin>
    log.lh.n++;
    80005bc0:	0001e717          	auipc	a4,0x1e
    80005bc4:	a5070713          	addi	a4,a4,-1456 # 80023610 <log>
    80005bc8:	575c                	lw	a5,44(a4)
    80005bca:	2785                	addiw	a5,a5,1
    80005bcc:	d75c                	sw	a5,44(a4)
    80005bce:	a82d                	j	80005c08 <log_write+0xc8>
    panic("too big a transaction");
    80005bd0:	00004517          	auipc	a0,0x4
    80005bd4:	db050513          	addi	a0,a0,-592 # 80009980 <syscalls+0x340>
    80005bd8:	ffffb097          	auipc	ra,0xffffb
    80005bdc:	960080e7          	jalr	-1696(ra) # 80000538 <panic>
    panic("log_write outside of trans");
    80005be0:	00004517          	auipc	a0,0x4
    80005be4:	db850513          	addi	a0,a0,-584 # 80009998 <syscalls+0x358>
    80005be8:	ffffb097          	auipc	ra,0xffffb
    80005bec:	950080e7          	jalr	-1712(ra) # 80000538 <panic>
  log.lh.block[i] = b->blockno;
    80005bf0:	00878693          	addi	a3,a5,8
    80005bf4:	068a                	slli	a3,a3,0x2
    80005bf6:	0001e717          	auipc	a4,0x1e
    80005bfa:	a1a70713          	addi	a4,a4,-1510 # 80023610 <log>
    80005bfe:	9736                	add	a4,a4,a3
    80005c00:	44d4                	lw	a3,12(s1)
    80005c02:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005c04:	faf609e3          	beq	a2,a5,80005bb6 <log_write+0x76>
  }
  release(&log.lock);
    80005c08:	0001e517          	auipc	a0,0x1e
    80005c0c:	a0850513          	addi	a0,a0,-1528 # 80023610 <log>
    80005c10:	ffffb097          	auipc	ra,0xffffb
    80005c14:	072080e7          	jalr	114(ra) # 80000c82 <release>
}
    80005c18:	60e2                	ld	ra,24(sp)
    80005c1a:	6442                	ld	s0,16(sp)
    80005c1c:	64a2                	ld	s1,8(sp)
    80005c1e:	6902                	ld	s2,0(sp)
    80005c20:	6105                	addi	sp,sp,32
    80005c22:	8082                	ret

0000000080005c24 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80005c24:	1101                	addi	sp,sp,-32
    80005c26:	ec06                	sd	ra,24(sp)
    80005c28:	e822                	sd	s0,16(sp)
    80005c2a:	e426                	sd	s1,8(sp)
    80005c2c:	e04a                	sd	s2,0(sp)
    80005c2e:	1000                	addi	s0,sp,32
    80005c30:	84aa                	mv	s1,a0
    80005c32:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80005c34:	00004597          	auipc	a1,0x4
    80005c38:	d8458593          	addi	a1,a1,-636 # 800099b8 <syscalls+0x378>
    80005c3c:	0521                	addi	a0,a0,8
    80005c3e:	ffffb097          	auipc	ra,0xffffb
    80005c42:	f00080e7          	jalr	-256(ra) # 80000b3e <initlock>
  lk->name = name;
    80005c46:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80005c4a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005c4e:	0204a423          	sw	zero,40(s1)
}
    80005c52:	60e2                	ld	ra,24(sp)
    80005c54:	6442                	ld	s0,16(sp)
    80005c56:	64a2                	ld	s1,8(sp)
    80005c58:	6902                	ld	s2,0(sp)
    80005c5a:	6105                	addi	sp,sp,32
    80005c5c:	8082                	ret

0000000080005c5e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005c5e:	1101                	addi	sp,sp,-32
    80005c60:	ec06                	sd	ra,24(sp)
    80005c62:	e822                	sd	s0,16(sp)
    80005c64:	e426                	sd	s1,8(sp)
    80005c66:	e04a                	sd	s2,0(sp)
    80005c68:	1000                	addi	s0,sp,32
    80005c6a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005c6c:	00850913          	addi	s2,a0,8
    80005c70:	854a                	mv	a0,s2
    80005c72:	ffffb097          	auipc	ra,0xffffb
    80005c76:	f5c080e7          	jalr	-164(ra) # 80000bce <acquire>
  while (lk->locked) {
    80005c7a:	409c                	lw	a5,0(s1)
    80005c7c:	cb89                	beqz	a5,80005c8e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005c7e:	85ca                	mv	a1,s2
    80005c80:	8526                	mv	a0,s1
    80005c82:	ffffd097          	auipc	ra,0xffffd
    80005c86:	aea080e7          	jalr	-1302(ra) # 8000276c <sleep>
  while (lk->locked) {
    80005c8a:	409c                	lw	a5,0(s1)
    80005c8c:	fbed                	bnez	a5,80005c7e <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005c8e:	4785                	li	a5,1
    80005c90:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005c92:	ffffc097          	auipc	ra,0xffffc
    80005c96:	d28080e7          	jalr	-728(ra) # 800019ba <myproc>
    80005c9a:	591c                	lw	a5,48(a0)
    80005c9c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005c9e:	854a                	mv	a0,s2
    80005ca0:	ffffb097          	auipc	ra,0xffffb
    80005ca4:	fe2080e7          	jalr	-30(ra) # 80000c82 <release>
}
    80005ca8:	60e2                	ld	ra,24(sp)
    80005caa:	6442                	ld	s0,16(sp)
    80005cac:	64a2                	ld	s1,8(sp)
    80005cae:	6902                	ld	s2,0(sp)
    80005cb0:	6105                	addi	sp,sp,32
    80005cb2:	8082                	ret

0000000080005cb4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005cb4:	1101                	addi	sp,sp,-32
    80005cb6:	ec06                	sd	ra,24(sp)
    80005cb8:	e822                	sd	s0,16(sp)
    80005cba:	e426                	sd	s1,8(sp)
    80005cbc:	e04a                	sd	s2,0(sp)
    80005cbe:	1000                	addi	s0,sp,32
    80005cc0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005cc2:	00850913          	addi	s2,a0,8
    80005cc6:	854a                	mv	a0,s2
    80005cc8:	ffffb097          	auipc	ra,0xffffb
    80005ccc:	f06080e7          	jalr	-250(ra) # 80000bce <acquire>
  lk->locked = 0;
    80005cd0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005cd4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005cd8:	8526                	mv	a0,s1
    80005cda:	ffffd097          	auipc	ra,0xffffd
    80005cde:	e96080e7          	jalr	-362(ra) # 80002b70 <wakeup>
  release(&lk->lk);
    80005ce2:	854a                	mv	a0,s2
    80005ce4:	ffffb097          	auipc	ra,0xffffb
    80005ce8:	f9e080e7          	jalr	-98(ra) # 80000c82 <release>
}
    80005cec:	60e2                	ld	ra,24(sp)
    80005cee:	6442                	ld	s0,16(sp)
    80005cf0:	64a2                	ld	s1,8(sp)
    80005cf2:	6902                	ld	s2,0(sp)
    80005cf4:	6105                	addi	sp,sp,32
    80005cf6:	8082                	ret

0000000080005cf8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005cf8:	7179                	addi	sp,sp,-48
    80005cfa:	f406                	sd	ra,40(sp)
    80005cfc:	f022                	sd	s0,32(sp)
    80005cfe:	ec26                	sd	s1,24(sp)
    80005d00:	e84a                	sd	s2,16(sp)
    80005d02:	e44e                	sd	s3,8(sp)
    80005d04:	1800                	addi	s0,sp,48
    80005d06:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005d08:	00850913          	addi	s2,a0,8
    80005d0c:	854a                	mv	a0,s2
    80005d0e:	ffffb097          	auipc	ra,0xffffb
    80005d12:	ec0080e7          	jalr	-320(ra) # 80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80005d16:	409c                	lw	a5,0(s1)
    80005d18:	ef99                	bnez	a5,80005d36 <holdingsleep+0x3e>
    80005d1a:	4481                	li	s1,0
  release(&lk->lk);
    80005d1c:	854a                	mv	a0,s2
    80005d1e:	ffffb097          	auipc	ra,0xffffb
    80005d22:	f64080e7          	jalr	-156(ra) # 80000c82 <release>
  return r;
}
    80005d26:	8526                	mv	a0,s1
    80005d28:	70a2                	ld	ra,40(sp)
    80005d2a:	7402                	ld	s0,32(sp)
    80005d2c:	64e2                	ld	s1,24(sp)
    80005d2e:	6942                	ld	s2,16(sp)
    80005d30:	69a2                	ld	s3,8(sp)
    80005d32:	6145                	addi	sp,sp,48
    80005d34:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80005d36:	0284a983          	lw	s3,40(s1)
    80005d3a:	ffffc097          	auipc	ra,0xffffc
    80005d3e:	c80080e7          	jalr	-896(ra) # 800019ba <myproc>
    80005d42:	5904                	lw	s1,48(a0)
    80005d44:	413484b3          	sub	s1,s1,s3
    80005d48:	0014b493          	seqz	s1,s1
    80005d4c:	bfc1                	j	80005d1c <holdingsleep+0x24>

0000000080005d4e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005d4e:	1141                	addi	sp,sp,-16
    80005d50:	e406                	sd	ra,8(sp)
    80005d52:	e022                	sd	s0,0(sp)
    80005d54:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80005d56:	00004597          	auipc	a1,0x4
    80005d5a:	c7258593          	addi	a1,a1,-910 # 800099c8 <syscalls+0x388>
    80005d5e:	0001e517          	auipc	a0,0x1e
    80005d62:	9fa50513          	addi	a0,a0,-1542 # 80023758 <ftable>
    80005d66:	ffffb097          	auipc	ra,0xffffb
    80005d6a:	dd8080e7          	jalr	-552(ra) # 80000b3e <initlock>
}
    80005d6e:	60a2                	ld	ra,8(sp)
    80005d70:	6402                	ld	s0,0(sp)
    80005d72:	0141                	addi	sp,sp,16
    80005d74:	8082                	ret

0000000080005d76 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005d76:	1101                	addi	sp,sp,-32
    80005d78:	ec06                	sd	ra,24(sp)
    80005d7a:	e822                	sd	s0,16(sp)
    80005d7c:	e426                	sd	s1,8(sp)
    80005d7e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005d80:	0001e517          	auipc	a0,0x1e
    80005d84:	9d850513          	addi	a0,a0,-1576 # 80023758 <ftable>
    80005d88:	ffffb097          	auipc	ra,0xffffb
    80005d8c:	e46080e7          	jalr	-442(ra) # 80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005d90:	0001e497          	auipc	s1,0x1e
    80005d94:	9e048493          	addi	s1,s1,-1568 # 80023770 <ftable+0x18>
    80005d98:	0001f717          	auipc	a4,0x1f
    80005d9c:	97870713          	addi	a4,a4,-1672 # 80024710 <ftable+0xfb8>
    if(f->ref == 0){
    80005da0:	40dc                	lw	a5,4(s1)
    80005da2:	cf99                	beqz	a5,80005dc0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005da4:	02848493          	addi	s1,s1,40
    80005da8:	fee49ce3          	bne	s1,a4,80005da0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005dac:	0001e517          	auipc	a0,0x1e
    80005db0:	9ac50513          	addi	a0,a0,-1620 # 80023758 <ftable>
    80005db4:	ffffb097          	auipc	ra,0xffffb
    80005db8:	ece080e7          	jalr	-306(ra) # 80000c82 <release>
  return 0;
    80005dbc:	4481                	li	s1,0
    80005dbe:	a819                	j	80005dd4 <filealloc+0x5e>
      f->ref = 1;
    80005dc0:	4785                	li	a5,1
    80005dc2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005dc4:	0001e517          	auipc	a0,0x1e
    80005dc8:	99450513          	addi	a0,a0,-1644 # 80023758 <ftable>
    80005dcc:	ffffb097          	auipc	ra,0xffffb
    80005dd0:	eb6080e7          	jalr	-330(ra) # 80000c82 <release>
}
    80005dd4:	8526                	mv	a0,s1
    80005dd6:	60e2                	ld	ra,24(sp)
    80005dd8:	6442                	ld	s0,16(sp)
    80005dda:	64a2                	ld	s1,8(sp)
    80005ddc:	6105                	addi	sp,sp,32
    80005dde:	8082                	ret

0000000080005de0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80005de0:	1101                	addi	sp,sp,-32
    80005de2:	ec06                	sd	ra,24(sp)
    80005de4:	e822                	sd	s0,16(sp)
    80005de6:	e426                	sd	s1,8(sp)
    80005de8:	1000                	addi	s0,sp,32
    80005dea:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005dec:	0001e517          	auipc	a0,0x1e
    80005df0:	96c50513          	addi	a0,a0,-1684 # 80023758 <ftable>
    80005df4:	ffffb097          	auipc	ra,0xffffb
    80005df8:	dda080e7          	jalr	-550(ra) # 80000bce <acquire>
  if(f->ref < 1)
    80005dfc:	40dc                	lw	a5,4(s1)
    80005dfe:	02f05263          	blez	a5,80005e22 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005e02:	2785                	addiw	a5,a5,1
    80005e04:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005e06:	0001e517          	auipc	a0,0x1e
    80005e0a:	95250513          	addi	a0,a0,-1710 # 80023758 <ftable>
    80005e0e:	ffffb097          	auipc	ra,0xffffb
    80005e12:	e74080e7          	jalr	-396(ra) # 80000c82 <release>
  return f;
}
    80005e16:	8526                	mv	a0,s1
    80005e18:	60e2                	ld	ra,24(sp)
    80005e1a:	6442                	ld	s0,16(sp)
    80005e1c:	64a2                	ld	s1,8(sp)
    80005e1e:	6105                	addi	sp,sp,32
    80005e20:	8082                	ret
    panic("filedup");
    80005e22:	00004517          	auipc	a0,0x4
    80005e26:	bae50513          	addi	a0,a0,-1106 # 800099d0 <syscalls+0x390>
    80005e2a:	ffffa097          	auipc	ra,0xffffa
    80005e2e:	70e080e7          	jalr	1806(ra) # 80000538 <panic>

0000000080005e32 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005e32:	7139                	addi	sp,sp,-64
    80005e34:	fc06                	sd	ra,56(sp)
    80005e36:	f822                	sd	s0,48(sp)
    80005e38:	f426                	sd	s1,40(sp)
    80005e3a:	f04a                	sd	s2,32(sp)
    80005e3c:	ec4e                	sd	s3,24(sp)
    80005e3e:	e852                	sd	s4,16(sp)
    80005e40:	e456                	sd	s5,8(sp)
    80005e42:	0080                	addi	s0,sp,64
    80005e44:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80005e46:	0001e517          	auipc	a0,0x1e
    80005e4a:	91250513          	addi	a0,a0,-1774 # 80023758 <ftable>
    80005e4e:	ffffb097          	auipc	ra,0xffffb
    80005e52:	d80080e7          	jalr	-640(ra) # 80000bce <acquire>
  if(f->ref < 1)
    80005e56:	40dc                	lw	a5,4(s1)
    80005e58:	06f05163          	blez	a5,80005eba <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005e5c:	37fd                	addiw	a5,a5,-1
    80005e5e:	0007871b          	sext.w	a4,a5
    80005e62:	c0dc                	sw	a5,4(s1)
    80005e64:	06e04363          	bgtz	a4,80005eca <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005e68:	0004a903          	lw	s2,0(s1)
    80005e6c:	0094ca83          	lbu	s5,9(s1)
    80005e70:	0104ba03          	ld	s4,16(s1)
    80005e74:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005e78:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005e7c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005e80:	0001e517          	auipc	a0,0x1e
    80005e84:	8d850513          	addi	a0,a0,-1832 # 80023758 <ftable>
    80005e88:	ffffb097          	auipc	ra,0xffffb
    80005e8c:	dfa080e7          	jalr	-518(ra) # 80000c82 <release>

  if(ff.type == FD_PIPE){
    80005e90:	4785                	li	a5,1
    80005e92:	04f90d63          	beq	s2,a5,80005eec <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005e96:	3979                	addiw	s2,s2,-2
    80005e98:	4785                	li	a5,1
    80005e9a:	0527e063          	bltu	a5,s2,80005eda <fileclose+0xa8>
    begin_op();
    80005e9e:	00000097          	auipc	ra,0x0
    80005ea2:	acc080e7          	jalr	-1332(ra) # 8000596a <begin_op>
    iput(ff.ip);
    80005ea6:	854e                	mv	a0,s3
    80005ea8:	fffff097          	auipc	ra,0xfffff
    80005eac:	2a0080e7          	jalr	672(ra) # 80005148 <iput>
    end_op();
    80005eb0:	00000097          	auipc	ra,0x0
    80005eb4:	b38080e7          	jalr	-1224(ra) # 800059e8 <end_op>
    80005eb8:	a00d                	j	80005eda <fileclose+0xa8>
    panic("fileclose");
    80005eba:	00004517          	auipc	a0,0x4
    80005ebe:	b1e50513          	addi	a0,a0,-1250 # 800099d8 <syscalls+0x398>
    80005ec2:	ffffa097          	auipc	ra,0xffffa
    80005ec6:	676080e7          	jalr	1654(ra) # 80000538 <panic>
    release(&ftable.lock);
    80005eca:	0001e517          	auipc	a0,0x1e
    80005ece:	88e50513          	addi	a0,a0,-1906 # 80023758 <ftable>
    80005ed2:	ffffb097          	auipc	ra,0xffffb
    80005ed6:	db0080e7          	jalr	-592(ra) # 80000c82 <release>
  }
}
    80005eda:	70e2                	ld	ra,56(sp)
    80005edc:	7442                	ld	s0,48(sp)
    80005ede:	74a2                	ld	s1,40(sp)
    80005ee0:	7902                	ld	s2,32(sp)
    80005ee2:	69e2                	ld	s3,24(sp)
    80005ee4:	6a42                	ld	s4,16(sp)
    80005ee6:	6aa2                	ld	s5,8(sp)
    80005ee8:	6121                	addi	sp,sp,64
    80005eea:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005eec:	85d6                	mv	a1,s5
    80005eee:	8552                	mv	a0,s4
    80005ef0:	00000097          	auipc	ra,0x0
    80005ef4:	34c080e7          	jalr	844(ra) # 8000623c <pipeclose>
    80005ef8:	b7cd                	j	80005eda <fileclose+0xa8>

0000000080005efa <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005efa:	715d                	addi	sp,sp,-80
    80005efc:	e486                	sd	ra,72(sp)
    80005efe:	e0a2                	sd	s0,64(sp)
    80005f00:	fc26                	sd	s1,56(sp)
    80005f02:	f84a                	sd	s2,48(sp)
    80005f04:	f44e                	sd	s3,40(sp)
    80005f06:	0880                	addi	s0,sp,80
    80005f08:	84aa                	mv	s1,a0
    80005f0a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005f0c:	ffffc097          	auipc	ra,0xffffc
    80005f10:	aae080e7          	jalr	-1362(ra) # 800019ba <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005f14:	409c                	lw	a5,0(s1)
    80005f16:	37f9                	addiw	a5,a5,-2
    80005f18:	4705                	li	a4,1
    80005f1a:	04f76763          	bltu	a4,a5,80005f68 <filestat+0x6e>
    80005f1e:	892a                	mv	s2,a0
    ilock(f->ip);
    80005f20:	6c88                	ld	a0,24(s1)
    80005f22:	fffff097          	auipc	ra,0xfffff
    80005f26:	06c080e7          	jalr	108(ra) # 80004f8e <ilock>
    stati(f->ip, &st);
    80005f2a:	fb840593          	addi	a1,s0,-72
    80005f2e:	6c88                	ld	a0,24(s1)
    80005f30:	fffff097          	auipc	ra,0xfffff
    80005f34:	2e8080e7          	jalr	744(ra) # 80005218 <stati>
    iunlock(f->ip);
    80005f38:	6c88                	ld	a0,24(s1)
    80005f3a:	fffff097          	auipc	ra,0xfffff
    80005f3e:	116080e7          	jalr	278(ra) # 80005050 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005f42:	46e1                	li	a3,24
    80005f44:	fb840613          	addi	a2,s0,-72
    80005f48:	85ce                	mv	a1,s3
    80005f4a:	05893503          	ld	a0,88(s2)
    80005f4e:	ffffb097          	auipc	ra,0xffffb
    80005f52:	730080e7          	jalr	1840(ra) # 8000167e <copyout>
    80005f56:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005f5a:	60a6                	ld	ra,72(sp)
    80005f5c:	6406                	ld	s0,64(sp)
    80005f5e:	74e2                	ld	s1,56(sp)
    80005f60:	7942                	ld	s2,48(sp)
    80005f62:	79a2                	ld	s3,40(sp)
    80005f64:	6161                	addi	sp,sp,80
    80005f66:	8082                	ret
  return -1;
    80005f68:	557d                	li	a0,-1
    80005f6a:	bfc5                	j	80005f5a <filestat+0x60>

0000000080005f6c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005f6c:	7179                	addi	sp,sp,-48
    80005f6e:	f406                	sd	ra,40(sp)
    80005f70:	f022                	sd	s0,32(sp)
    80005f72:	ec26                	sd	s1,24(sp)
    80005f74:	e84a                	sd	s2,16(sp)
    80005f76:	e44e                	sd	s3,8(sp)
    80005f78:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005f7a:	00854783          	lbu	a5,8(a0)
    80005f7e:	c3d5                	beqz	a5,80006022 <fileread+0xb6>
    80005f80:	84aa                	mv	s1,a0
    80005f82:	89ae                	mv	s3,a1
    80005f84:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005f86:	411c                	lw	a5,0(a0)
    80005f88:	4705                	li	a4,1
    80005f8a:	04e78963          	beq	a5,a4,80005fdc <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005f8e:	470d                	li	a4,3
    80005f90:	04e78d63          	beq	a5,a4,80005fea <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005f94:	4709                	li	a4,2
    80005f96:	06e79e63          	bne	a5,a4,80006012 <fileread+0xa6>
    ilock(f->ip);
    80005f9a:	6d08                	ld	a0,24(a0)
    80005f9c:	fffff097          	auipc	ra,0xfffff
    80005fa0:	ff2080e7          	jalr	-14(ra) # 80004f8e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005fa4:	874a                	mv	a4,s2
    80005fa6:	5094                	lw	a3,32(s1)
    80005fa8:	864e                	mv	a2,s3
    80005faa:	4585                	li	a1,1
    80005fac:	6c88                	ld	a0,24(s1)
    80005fae:	fffff097          	auipc	ra,0xfffff
    80005fb2:	294080e7          	jalr	660(ra) # 80005242 <readi>
    80005fb6:	892a                	mv	s2,a0
    80005fb8:	00a05563          	blez	a0,80005fc2 <fileread+0x56>
      f->off += r;
    80005fbc:	509c                	lw	a5,32(s1)
    80005fbe:	9fa9                	addw	a5,a5,a0
    80005fc0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005fc2:	6c88                	ld	a0,24(s1)
    80005fc4:	fffff097          	auipc	ra,0xfffff
    80005fc8:	08c080e7          	jalr	140(ra) # 80005050 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005fcc:	854a                	mv	a0,s2
    80005fce:	70a2                	ld	ra,40(sp)
    80005fd0:	7402                	ld	s0,32(sp)
    80005fd2:	64e2                	ld	s1,24(sp)
    80005fd4:	6942                	ld	s2,16(sp)
    80005fd6:	69a2                	ld	s3,8(sp)
    80005fd8:	6145                	addi	sp,sp,48
    80005fda:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005fdc:	6908                	ld	a0,16(a0)
    80005fde:	00000097          	auipc	ra,0x0
    80005fe2:	3c0080e7          	jalr	960(ra) # 8000639e <piperead>
    80005fe6:	892a                	mv	s2,a0
    80005fe8:	b7d5                	j	80005fcc <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005fea:	02451783          	lh	a5,36(a0)
    80005fee:	03079693          	slli	a3,a5,0x30
    80005ff2:	92c1                	srli	a3,a3,0x30
    80005ff4:	4725                	li	a4,9
    80005ff6:	02d76863          	bltu	a4,a3,80006026 <fileread+0xba>
    80005ffa:	0792                	slli	a5,a5,0x4
    80005ffc:	0001d717          	auipc	a4,0x1d
    80006000:	6bc70713          	addi	a4,a4,1724 # 800236b8 <devsw>
    80006004:	97ba                	add	a5,a5,a4
    80006006:	639c                	ld	a5,0(a5)
    80006008:	c38d                	beqz	a5,8000602a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000600a:	4505                	li	a0,1
    8000600c:	9782                	jalr	a5
    8000600e:	892a                	mv	s2,a0
    80006010:	bf75                	j	80005fcc <fileread+0x60>
    panic("fileread");
    80006012:	00004517          	auipc	a0,0x4
    80006016:	9d650513          	addi	a0,a0,-1578 # 800099e8 <syscalls+0x3a8>
    8000601a:	ffffa097          	auipc	ra,0xffffa
    8000601e:	51e080e7          	jalr	1310(ra) # 80000538 <panic>
    return -1;
    80006022:	597d                	li	s2,-1
    80006024:	b765                	j	80005fcc <fileread+0x60>
      return -1;
    80006026:	597d                	li	s2,-1
    80006028:	b755                	j	80005fcc <fileread+0x60>
    8000602a:	597d                	li	s2,-1
    8000602c:	b745                	j	80005fcc <fileread+0x60>

000000008000602e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000602e:	715d                	addi	sp,sp,-80
    80006030:	e486                	sd	ra,72(sp)
    80006032:	e0a2                	sd	s0,64(sp)
    80006034:	fc26                	sd	s1,56(sp)
    80006036:	f84a                	sd	s2,48(sp)
    80006038:	f44e                	sd	s3,40(sp)
    8000603a:	f052                	sd	s4,32(sp)
    8000603c:	ec56                	sd	s5,24(sp)
    8000603e:	e85a                	sd	s6,16(sp)
    80006040:	e45e                	sd	s7,8(sp)
    80006042:	e062                	sd	s8,0(sp)
    80006044:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80006046:	00954783          	lbu	a5,9(a0)
    8000604a:	10078663          	beqz	a5,80006156 <filewrite+0x128>
    8000604e:	892a                	mv	s2,a0
    80006050:	8b2e                	mv	s6,a1
    80006052:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80006054:	411c                	lw	a5,0(a0)
    80006056:	4705                	li	a4,1
    80006058:	02e78263          	beq	a5,a4,8000607c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000605c:	470d                	li	a4,3
    8000605e:	02e78663          	beq	a5,a4,8000608a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80006062:	4709                	li	a4,2
    80006064:	0ee79163          	bne	a5,a4,80006146 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80006068:	0ac05d63          	blez	a2,80006122 <filewrite+0xf4>
    int i = 0;
    8000606c:	4981                	li	s3,0
    8000606e:	6b85                	lui	s7,0x1
    80006070:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80006074:	6c05                	lui	s8,0x1
    80006076:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000607a:	a861                	j	80006112 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000607c:	6908                	ld	a0,16(a0)
    8000607e:	00000097          	auipc	ra,0x0
    80006082:	22e080e7          	jalr	558(ra) # 800062ac <pipewrite>
    80006086:	8a2a                	mv	s4,a0
    80006088:	a045                	j	80006128 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000608a:	02451783          	lh	a5,36(a0)
    8000608e:	03079693          	slli	a3,a5,0x30
    80006092:	92c1                	srli	a3,a3,0x30
    80006094:	4725                	li	a4,9
    80006096:	0cd76263          	bltu	a4,a3,8000615a <filewrite+0x12c>
    8000609a:	0792                	slli	a5,a5,0x4
    8000609c:	0001d717          	auipc	a4,0x1d
    800060a0:	61c70713          	addi	a4,a4,1564 # 800236b8 <devsw>
    800060a4:	97ba                	add	a5,a5,a4
    800060a6:	679c                	ld	a5,8(a5)
    800060a8:	cbdd                	beqz	a5,8000615e <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800060aa:	4505                	li	a0,1
    800060ac:	9782                	jalr	a5
    800060ae:	8a2a                	mv	s4,a0
    800060b0:	a8a5                	j	80006128 <filewrite+0xfa>
    800060b2:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800060b6:	00000097          	auipc	ra,0x0
    800060ba:	8b4080e7          	jalr	-1868(ra) # 8000596a <begin_op>
      ilock(f->ip);
    800060be:	01893503          	ld	a0,24(s2)
    800060c2:	fffff097          	auipc	ra,0xfffff
    800060c6:	ecc080e7          	jalr	-308(ra) # 80004f8e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800060ca:	8756                	mv	a4,s5
    800060cc:	02092683          	lw	a3,32(s2)
    800060d0:	01698633          	add	a2,s3,s6
    800060d4:	4585                	li	a1,1
    800060d6:	01893503          	ld	a0,24(s2)
    800060da:	fffff097          	auipc	ra,0xfffff
    800060de:	260080e7          	jalr	608(ra) # 8000533a <writei>
    800060e2:	84aa                	mv	s1,a0
    800060e4:	00a05763          	blez	a0,800060f2 <filewrite+0xc4>
        f->off += r;
    800060e8:	02092783          	lw	a5,32(s2)
    800060ec:	9fa9                	addw	a5,a5,a0
    800060ee:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800060f2:	01893503          	ld	a0,24(s2)
    800060f6:	fffff097          	auipc	ra,0xfffff
    800060fa:	f5a080e7          	jalr	-166(ra) # 80005050 <iunlock>
      end_op();
    800060fe:	00000097          	auipc	ra,0x0
    80006102:	8ea080e7          	jalr	-1814(ra) # 800059e8 <end_op>

      if(r != n1){
    80006106:	009a9f63          	bne	s5,s1,80006124 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000610a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000610e:	0149db63          	bge	s3,s4,80006124 <filewrite+0xf6>
      int n1 = n - i;
    80006112:	413a04bb          	subw	s1,s4,s3
    80006116:	0004879b          	sext.w	a5,s1
    8000611a:	f8fbdce3          	bge	s7,a5,800060b2 <filewrite+0x84>
    8000611e:	84e2                	mv	s1,s8
    80006120:	bf49                	j	800060b2 <filewrite+0x84>
    int i = 0;
    80006122:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80006124:	013a1f63          	bne	s4,s3,80006142 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80006128:	8552                	mv	a0,s4
    8000612a:	60a6                	ld	ra,72(sp)
    8000612c:	6406                	ld	s0,64(sp)
    8000612e:	74e2                	ld	s1,56(sp)
    80006130:	7942                	ld	s2,48(sp)
    80006132:	79a2                	ld	s3,40(sp)
    80006134:	7a02                	ld	s4,32(sp)
    80006136:	6ae2                	ld	s5,24(sp)
    80006138:	6b42                	ld	s6,16(sp)
    8000613a:	6ba2                	ld	s7,8(sp)
    8000613c:	6c02                	ld	s8,0(sp)
    8000613e:	6161                	addi	sp,sp,80
    80006140:	8082                	ret
    ret = (i == n ? n : -1);
    80006142:	5a7d                	li	s4,-1
    80006144:	b7d5                	j	80006128 <filewrite+0xfa>
    panic("filewrite");
    80006146:	00004517          	auipc	a0,0x4
    8000614a:	8b250513          	addi	a0,a0,-1870 # 800099f8 <syscalls+0x3b8>
    8000614e:	ffffa097          	auipc	ra,0xffffa
    80006152:	3ea080e7          	jalr	1002(ra) # 80000538 <panic>
    return -1;
    80006156:	5a7d                	li	s4,-1
    80006158:	bfc1                	j	80006128 <filewrite+0xfa>
      return -1;
    8000615a:	5a7d                	li	s4,-1
    8000615c:	b7f1                	j	80006128 <filewrite+0xfa>
    8000615e:	5a7d                	li	s4,-1
    80006160:	b7e1                	j	80006128 <filewrite+0xfa>

0000000080006162 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80006162:	7179                	addi	sp,sp,-48
    80006164:	f406                	sd	ra,40(sp)
    80006166:	f022                	sd	s0,32(sp)
    80006168:	ec26                	sd	s1,24(sp)
    8000616a:	e84a                	sd	s2,16(sp)
    8000616c:	e44e                	sd	s3,8(sp)
    8000616e:	e052                	sd	s4,0(sp)
    80006170:	1800                	addi	s0,sp,48
    80006172:	84aa                	mv	s1,a0
    80006174:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80006176:	0005b023          	sd	zero,0(a1)
    8000617a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000617e:	00000097          	auipc	ra,0x0
    80006182:	bf8080e7          	jalr	-1032(ra) # 80005d76 <filealloc>
    80006186:	e088                	sd	a0,0(s1)
    80006188:	c551                	beqz	a0,80006214 <pipealloc+0xb2>
    8000618a:	00000097          	auipc	ra,0x0
    8000618e:	bec080e7          	jalr	-1044(ra) # 80005d76 <filealloc>
    80006192:	00aa3023          	sd	a0,0(s4)
    80006196:	c92d                	beqz	a0,80006208 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80006198:	ffffb097          	auipc	ra,0xffffb
    8000619c:	946080e7          	jalr	-1722(ra) # 80000ade <kalloc>
    800061a0:	892a                	mv	s2,a0
    800061a2:	c125                	beqz	a0,80006202 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800061a4:	4985                	li	s3,1
    800061a6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800061aa:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800061ae:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800061b2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800061b6:	00004597          	auipc	a1,0x4
    800061ba:	85258593          	addi	a1,a1,-1966 # 80009a08 <syscalls+0x3c8>
    800061be:	ffffb097          	auipc	ra,0xffffb
    800061c2:	980080e7          	jalr	-1664(ra) # 80000b3e <initlock>
  (*f0)->type = FD_PIPE;
    800061c6:	609c                	ld	a5,0(s1)
    800061c8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800061cc:	609c                	ld	a5,0(s1)
    800061ce:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800061d2:	609c                	ld	a5,0(s1)
    800061d4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800061d8:	609c                	ld	a5,0(s1)
    800061da:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800061de:	000a3783          	ld	a5,0(s4)
    800061e2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800061e6:	000a3783          	ld	a5,0(s4)
    800061ea:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800061ee:	000a3783          	ld	a5,0(s4)
    800061f2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800061f6:	000a3783          	ld	a5,0(s4)
    800061fa:	0127b823          	sd	s2,16(a5)
  return 0;
    800061fe:	4501                	li	a0,0
    80006200:	a025                	j	80006228 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80006202:	6088                	ld	a0,0(s1)
    80006204:	e501                	bnez	a0,8000620c <pipealloc+0xaa>
    80006206:	a039                	j	80006214 <pipealloc+0xb2>
    80006208:	6088                	ld	a0,0(s1)
    8000620a:	c51d                	beqz	a0,80006238 <pipealloc+0xd6>
    fileclose(*f0);
    8000620c:	00000097          	auipc	ra,0x0
    80006210:	c26080e7          	jalr	-986(ra) # 80005e32 <fileclose>
  if(*f1)
    80006214:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80006218:	557d                	li	a0,-1
  if(*f1)
    8000621a:	c799                	beqz	a5,80006228 <pipealloc+0xc6>
    fileclose(*f1);
    8000621c:	853e                	mv	a0,a5
    8000621e:	00000097          	auipc	ra,0x0
    80006222:	c14080e7          	jalr	-1004(ra) # 80005e32 <fileclose>
  return -1;
    80006226:	557d                	li	a0,-1
}
    80006228:	70a2                	ld	ra,40(sp)
    8000622a:	7402                	ld	s0,32(sp)
    8000622c:	64e2                	ld	s1,24(sp)
    8000622e:	6942                	ld	s2,16(sp)
    80006230:	69a2                	ld	s3,8(sp)
    80006232:	6a02                	ld	s4,0(sp)
    80006234:	6145                	addi	sp,sp,48
    80006236:	8082                	ret
  return -1;
    80006238:	557d                	li	a0,-1
    8000623a:	b7fd                	j	80006228 <pipealloc+0xc6>

000000008000623c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000623c:	1101                	addi	sp,sp,-32
    8000623e:	ec06                	sd	ra,24(sp)
    80006240:	e822                	sd	s0,16(sp)
    80006242:	e426                	sd	s1,8(sp)
    80006244:	e04a                	sd	s2,0(sp)
    80006246:	1000                	addi	s0,sp,32
    80006248:	84aa                	mv	s1,a0
    8000624a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000624c:	ffffb097          	auipc	ra,0xffffb
    80006250:	982080e7          	jalr	-1662(ra) # 80000bce <acquire>
  if(writable){
    80006254:	02090d63          	beqz	s2,8000628e <pipeclose+0x52>
    pi->writeopen = 0;
    80006258:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000625c:	21848513          	addi	a0,s1,536
    80006260:	ffffd097          	auipc	ra,0xffffd
    80006264:	910080e7          	jalr	-1776(ra) # 80002b70 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80006268:	2204b783          	ld	a5,544(s1)
    8000626c:	eb95                	bnez	a5,800062a0 <pipeclose+0x64>
    release(&pi->lock);
    8000626e:	8526                	mv	a0,s1
    80006270:	ffffb097          	auipc	ra,0xffffb
    80006274:	a12080e7          	jalr	-1518(ra) # 80000c82 <release>
    kfree((char*)pi);
    80006278:	8526                	mv	a0,s1
    8000627a:	ffffa097          	auipc	ra,0xffffa
    8000627e:	766080e7          	jalr	1894(ra) # 800009e0 <kfree>
  } else
    release(&pi->lock);
}
    80006282:	60e2                	ld	ra,24(sp)
    80006284:	6442                	ld	s0,16(sp)
    80006286:	64a2                	ld	s1,8(sp)
    80006288:	6902                	ld	s2,0(sp)
    8000628a:	6105                	addi	sp,sp,32
    8000628c:	8082                	ret
    pi->readopen = 0;
    8000628e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80006292:	21c48513          	addi	a0,s1,540
    80006296:	ffffd097          	auipc	ra,0xffffd
    8000629a:	8da080e7          	jalr	-1830(ra) # 80002b70 <wakeup>
    8000629e:	b7e9                	j	80006268 <pipeclose+0x2c>
    release(&pi->lock);
    800062a0:	8526                	mv	a0,s1
    800062a2:	ffffb097          	auipc	ra,0xffffb
    800062a6:	9e0080e7          	jalr	-1568(ra) # 80000c82 <release>
}
    800062aa:	bfe1                	j	80006282 <pipeclose+0x46>

00000000800062ac <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800062ac:	711d                	addi	sp,sp,-96
    800062ae:	ec86                	sd	ra,88(sp)
    800062b0:	e8a2                	sd	s0,80(sp)
    800062b2:	e4a6                	sd	s1,72(sp)
    800062b4:	e0ca                	sd	s2,64(sp)
    800062b6:	fc4e                	sd	s3,56(sp)
    800062b8:	f852                	sd	s4,48(sp)
    800062ba:	f456                	sd	s5,40(sp)
    800062bc:	f05a                	sd	s6,32(sp)
    800062be:	ec5e                	sd	s7,24(sp)
    800062c0:	e862                	sd	s8,16(sp)
    800062c2:	1080                	addi	s0,sp,96
    800062c4:	84aa                	mv	s1,a0
    800062c6:	8aae                	mv	s5,a1
    800062c8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800062ca:	ffffb097          	auipc	ra,0xffffb
    800062ce:	6f0080e7          	jalr	1776(ra) # 800019ba <myproc>
    800062d2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800062d4:	8526                	mv	a0,s1
    800062d6:	ffffb097          	auipc	ra,0xffffb
    800062da:	8f8080e7          	jalr	-1800(ra) # 80000bce <acquire>
  while(i < n){
    800062de:	0b405363          	blez	s4,80006384 <pipewrite+0xd8>
  int i = 0;
    800062e2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800062e4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800062e6:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800062ea:	21c48b93          	addi	s7,s1,540
    800062ee:	a089                	j	80006330 <pipewrite+0x84>
      release(&pi->lock);
    800062f0:	8526                	mv	a0,s1
    800062f2:	ffffb097          	auipc	ra,0xffffb
    800062f6:	990080e7          	jalr	-1648(ra) # 80000c82 <release>
      return -1;
    800062fa:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800062fc:	854a                	mv	a0,s2
    800062fe:	60e6                	ld	ra,88(sp)
    80006300:	6446                	ld	s0,80(sp)
    80006302:	64a6                	ld	s1,72(sp)
    80006304:	6906                	ld	s2,64(sp)
    80006306:	79e2                	ld	s3,56(sp)
    80006308:	7a42                	ld	s4,48(sp)
    8000630a:	7aa2                	ld	s5,40(sp)
    8000630c:	7b02                	ld	s6,32(sp)
    8000630e:	6be2                	ld	s7,24(sp)
    80006310:	6c42                	ld	s8,16(sp)
    80006312:	6125                	addi	sp,sp,96
    80006314:	8082                	ret
      wakeup(&pi->nread);
    80006316:	8562                	mv	a0,s8
    80006318:	ffffd097          	auipc	ra,0xffffd
    8000631c:	858080e7          	jalr	-1960(ra) # 80002b70 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80006320:	85a6                	mv	a1,s1
    80006322:	855e                	mv	a0,s7
    80006324:	ffffc097          	auipc	ra,0xffffc
    80006328:	448080e7          	jalr	1096(ra) # 8000276c <sleep>
  while(i < n){
    8000632c:	05495d63          	bge	s2,s4,80006386 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80006330:	2204a783          	lw	a5,544(s1)
    80006334:	dfd5                	beqz	a5,800062f0 <pipewrite+0x44>
    80006336:	0289a783          	lw	a5,40(s3)
    8000633a:	fbdd                	bnez	a5,800062f0 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000633c:	2184a783          	lw	a5,536(s1)
    80006340:	21c4a703          	lw	a4,540(s1)
    80006344:	2007879b          	addiw	a5,a5,512
    80006348:	fcf707e3          	beq	a4,a5,80006316 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000634c:	4685                	li	a3,1
    8000634e:	01590633          	add	a2,s2,s5
    80006352:	faf40593          	addi	a1,s0,-81
    80006356:	0589b503          	ld	a0,88(s3)
    8000635a:	ffffb097          	auipc	ra,0xffffb
    8000635e:	3b0080e7          	jalr	944(ra) # 8000170a <copyin>
    80006362:	03650263          	beq	a0,s6,80006386 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80006366:	21c4a783          	lw	a5,540(s1)
    8000636a:	0017871b          	addiw	a4,a5,1
    8000636e:	20e4ae23          	sw	a4,540(s1)
    80006372:	1ff7f793          	andi	a5,a5,511
    80006376:	97a6                	add	a5,a5,s1
    80006378:	faf44703          	lbu	a4,-81(s0)
    8000637c:	00e78c23          	sb	a4,24(a5)
      i++;
    80006380:	2905                	addiw	s2,s2,1
    80006382:	b76d                	j	8000632c <pipewrite+0x80>
  int i = 0;
    80006384:	4901                	li	s2,0
  wakeup(&pi->nread);
    80006386:	21848513          	addi	a0,s1,536
    8000638a:	ffffc097          	auipc	ra,0xffffc
    8000638e:	7e6080e7          	jalr	2022(ra) # 80002b70 <wakeup>
  release(&pi->lock);
    80006392:	8526                	mv	a0,s1
    80006394:	ffffb097          	auipc	ra,0xffffb
    80006398:	8ee080e7          	jalr	-1810(ra) # 80000c82 <release>
  return i;
    8000639c:	b785                	j	800062fc <pipewrite+0x50>

000000008000639e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000639e:	715d                	addi	sp,sp,-80
    800063a0:	e486                	sd	ra,72(sp)
    800063a2:	e0a2                	sd	s0,64(sp)
    800063a4:	fc26                	sd	s1,56(sp)
    800063a6:	f84a                	sd	s2,48(sp)
    800063a8:	f44e                	sd	s3,40(sp)
    800063aa:	f052                	sd	s4,32(sp)
    800063ac:	ec56                	sd	s5,24(sp)
    800063ae:	e85a                	sd	s6,16(sp)
    800063b0:	0880                	addi	s0,sp,80
    800063b2:	84aa                	mv	s1,a0
    800063b4:	892e                	mv	s2,a1
    800063b6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800063b8:	ffffb097          	auipc	ra,0xffffb
    800063bc:	602080e7          	jalr	1538(ra) # 800019ba <myproc>
    800063c0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800063c2:	8526                	mv	a0,s1
    800063c4:	ffffb097          	auipc	ra,0xffffb
    800063c8:	80a080e7          	jalr	-2038(ra) # 80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800063cc:	2184a703          	lw	a4,536(s1)
    800063d0:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800063d4:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800063d8:	02f71463          	bne	a4,a5,80006400 <piperead+0x62>
    800063dc:	2244a783          	lw	a5,548(s1)
    800063e0:	c385                	beqz	a5,80006400 <piperead+0x62>
    if(pr->killed){
    800063e2:	028a2783          	lw	a5,40(s4)
    800063e6:	ebc9                	bnez	a5,80006478 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800063e8:	85a6                	mv	a1,s1
    800063ea:	854e                	mv	a0,s3
    800063ec:	ffffc097          	auipc	ra,0xffffc
    800063f0:	380080e7          	jalr	896(ra) # 8000276c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800063f4:	2184a703          	lw	a4,536(s1)
    800063f8:	21c4a783          	lw	a5,540(s1)
    800063fc:	fef700e3          	beq	a4,a5,800063dc <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006400:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80006402:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006404:	05505463          	blez	s5,8000644c <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80006408:	2184a783          	lw	a5,536(s1)
    8000640c:	21c4a703          	lw	a4,540(s1)
    80006410:	02f70e63          	beq	a4,a5,8000644c <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80006414:	0017871b          	addiw	a4,a5,1
    80006418:	20e4ac23          	sw	a4,536(s1)
    8000641c:	1ff7f793          	andi	a5,a5,511
    80006420:	97a6                	add	a5,a5,s1
    80006422:	0187c783          	lbu	a5,24(a5)
    80006426:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000642a:	4685                	li	a3,1
    8000642c:	fbf40613          	addi	a2,s0,-65
    80006430:	85ca                	mv	a1,s2
    80006432:	058a3503          	ld	a0,88(s4)
    80006436:	ffffb097          	auipc	ra,0xffffb
    8000643a:	248080e7          	jalr	584(ra) # 8000167e <copyout>
    8000643e:	01650763          	beq	a0,s6,8000644c <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80006442:	2985                	addiw	s3,s3,1
    80006444:	0905                	addi	s2,s2,1
    80006446:	fd3a91e3          	bne	s5,s3,80006408 <piperead+0x6a>
    8000644a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000644c:	21c48513          	addi	a0,s1,540
    80006450:	ffffc097          	auipc	ra,0xffffc
    80006454:	720080e7          	jalr	1824(ra) # 80002b70 <wakeup>
  release(&pi->lock);
    80006458:	8526                	mv	a0,s1
    8000645a:	ffffb097          	auipc	ra,0xffffb
    8000645e:	828080e7          	jalr	-2008(ra) # 80000c82 <release>
  return i;
}
    80006462:	854e                	mv	a0,s3
    80006464:	60a6                	ld	ra,72(sp)
    80006466:	6406                	ld	s0,64(sp)
    80006468:	74e2                	ld	s1,56(sp)
    8000646a:	7942                	ld	s2,48(sp)
    8000646c:	79a2                	ld	s3,40(sp)
    8000646e:	7a02                	ld	s4,32(sp)
    80006470:	6ae2                	ld	s5,24(sp)
    80006472:	6b42                	ld	s6,16(sp)
    80006474:	6161                	addi	sp,sp,80
    80006476:	8082                	ret
      release(&pi->lock);
    80006478:	8526                	mv	a0,s1
    8000647a:	ffffb097          	auipc	ra,0xffffb
    8000647e:	808080e7          	jalr	-2040(ra) # 80000c82 <release>
      return -1;
    80006482:	59fd                	li	s3,-1
    80006484:	bff9                	j	80006462 <piperead+0xc4>

0000000080006486 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80006486:	de010113          	addi	sp,sp,-544
    8000648a:	20113c23          	sd	ra,536(sp)
    8000648e:	20813823          	sd	s0,528(sp)
    80006492:	20913423          	sd	s1,520(sp)
    80006496:	21213023          	sd	s2,512(sp)
    8000649a:	ffce                	sd	s3,504(sp)
    8000649c:	fbd2                	sd	s4,496(sp)
    8000649e:	f7d6                	sd	s5,488(sp)
    800064a0:	f3da                	sd	s6,480(sp)
    800064a2:	efde                	sd	s7,472(sp)
    800064a4:	ebe2                	sd	s8,464(sp)
    800064a6:	e7e6                	sd	s9,456(sp)
    800064a8:	e3ea                	sd	s10,448(sp)
    800064aa:	ff6e                	sd	s11,440(sp)
    800064ac:	1400                	addi	s0,sp,544
    800064ae:	892a                	mv	s2,a0
    800064b0:	dea43423          	sd	a0,-536(s0)
    800064b4:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800064b8:	ffffb097          	auipc	ra,0xffffb
    800064bc:	502080e7          	jalr	1282(ra) # 800019ba <myproc>
    800064c0:	84aa                	mv	s1,a0

  begin_op();
    800064c2:	fffff097          	auipc	ra,0xfffff
    800064c6:	4a8080e7          	jalr	1192(ra) # 8000596a <begin_op>

  if((ip = namei(path)) == 0){
    800064ca:	854a                	mv	a0,s2
    800064cc:	fffff097          	auipc	ra,0xfffff
    800064d0:	27e080e7          	jalr	638(ra) # 8000574a <namei>
    800064d4:	c93d                	beqz	a0,8000654a <exec+0xc4>
    800064d6:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800064d8:	fffff097          	auipc	ra,0xfffff
    800064dc:	ab6080e7          	jalr	-1354(ra) # 80004f8e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800064e0:	04000713          	li	a4,64
    800064e4:	4681                	li	a3,0
    800064e6:	e5040613          	addi	a2,s0,-432
    800064ea:	4581                	li	a1,0
    800064ec:	8556                	mv	a0,s5
    800064ee:	fffff097          	auipc	ra,0xfffff
    800064f2:	d54080e7          	jalr	-684(ra) # 80005242 <readi>
    800064f6:	04000793          	li	a5,64
    800064fa:	00f51a63          	bne	a0,a5,8000650e <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800064fe:	e5042703          	lw	a4,-432(s0)
    80006502:	464c47b7          	lui	a5,0x464c4
    80006506:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000650a:	04f70663          	beq	a4,a5,80006556 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000650e:	8556                	mv	a0,s5
    80006510:	fffff097          	auipc	ra,0xfffff
    80006514:	ce0080e7          	jalr	-800(ra) # 800051f0 <iunlockput>
    end_op();
    80006518:	fffff097          	auipc	ra,0xfffff
    8000651c:	4d0080e7          	jalr	1232(ra) # 800059e8 <end_op>
  }
  return -1;
    80006520:	557d                	li	a0,-1
}
    80006522:	21813083          	ld	ra,536(sp)
    80006526:	21013403          	ld	s0,528(sp)
    8000652a:	20813483          	ld	s1,520(sp)
    8000652e:	20013903          	ld	s2,512(sp)
    80006532:	79fe                	ld	s3,504(sp)
    80006534:	7a5e                	ld	s4,496(sp)
    80006536:	7abe                	ld	s5,488(sp)
    80006538:	7b1e                	ld	s6,480(sp)
    8000653a:	6bfe                	ld	s7,472(sp)
    8000653c:	6c5e                	ld	s8,464(sp)
    8000653e:	6cbe                	ld	s9,456(sp)
    80006540:	6d1e                	ld	s10,448(sp)
    80006542:	7dfa                	ld	s11,440(sp)
    80006544:	22010113          	addi	sp,sp,544
    80006548:	8082                	ret
    end_op();
    8000654a:	fffff097          	auipc	ra,0xfffff
    8000654e:	49e080e7          	jalr	1182(ra) # 800059e8 <end_op>
    return -1;
    80006552:	557d                	li	a0,-1
    80006554:	b7f9                	j	80006522 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80006556:	8526                	mv	a0,s1
    80006558:	ffffb097          	auipc	ra,0xffffb
    8000655c:	55e080e7          	jalr	1374(ra) # 80001ab6 <proc_pagetable>
    80006560:	8b2a                	mv	s6,a0
    80006562:	d555                	beqz	a0,8000650e <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006564:	e7042783          	lw	a5,-400(s0)
    80006568:	e8845703          	lhu	a4,-376(s0)
    8000656c:	c735                	beqz	a4,800065d8 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000656e:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006570:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80006574:	6a05                	lui	s4,0x1
    80006576:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000657a:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000657e:	6d85                	lui	s11,0x1
    80006580:	7d7d                	lui	s10,0xfffff
    80006582:	ac1d                	j	800067b8 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80006584:	00003517          	auipc	a0,0x3
    80006588:	48c50513          	addi	a0,a0,1164 # 80009a10 <syscalls+0x3d0>
    8000658c:	ffffa097          	auipc	ra,0xffffa
    80006590:	fac080e7          	jalr	-84(ra) # 80000538 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80006594:	874a                	mv	a4,s2
    80006596:	009c86bb          	addw	a3,s9,s1
    8000659a:	4581                	li	a1,0
    8000659c:	8556                	mv	a0,s5
    8000659e:	fffff097          	auipc	ra,0xfffff
    800065a2:	ca4080e7          	jalr	-860(ra) # 80005242 <readi>
    800065a6:	2501                	sext.w	a0,a0
    800065a8:	1aa91863          	bne	s2,a0,80006758 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    800065ac:	009d84bb          	addw	s1,s11,s1
    800065b0:	013d09bb          	addw	s3,s10,s3
    800065b4:	1f74f263          	bgeu	s1,s7,80006798 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    800065b8:	02049593          	slli	a1,s1,0x20
    800065bc:	9181                	srli	a1,a1,0x20
    800065be:	95e2                	add	a1,a1,s8
    800065c0:	855a                	mv	a0,s6
    800065c2:	ffffb097          	auipc	ra,0xffffb
    800065c6:	ab4080e7          	jalr	-1356(ra) # 80001076 <walkaddr>
    800065ca:	862a                	mv	a2,a0
    if(pa == 0)
    800065cc:	dd45                	beqz	a0,80006584 <exec+0xfe>
      n = PGSIZE;
    800065ce:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800065d0:	fd49f2e3          	bgeu	s3,s4,80006594 <exec+0x10e>
      n = sz - i;
    800065d4:	894e                	mv	s2,s3
    800065d6:	bf7d                	j	80006594 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800065d8:	4481                	li	s1,0
  iunlockput(ip);
    800065da:	8556                	mv	a0,s5
    800065dc:	fffff097          	auipc	ra,0xfffff
    800065e0:	c14080e7          	jalr	-1004(ra) # 800051f0 <iunlockput>
  end_op();
    800065e4:	fffff097          	auipc	ra,0xfffff
    800065e8:	404080e7          	jalr	1028(ra) # 800059e8 <end_op>
  p = myproc();
    800065ec:	ffffb097          	auipc	ra,0xffffb
    800065f0:	3ce080e7          	jalr	974(ra) # 800019ba <myproc>
    800065f4:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800065f6:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800065fa:	6785                	lui	a5,0x1
    800065fc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800065fe:	97a6                	add	a5,a5,s1
    80006600:	777d                	lui	a4,0xfffff
    80006602:	8ff9                	and	a5,a5,a4
    80006604:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80006608:	6609                	lui	a2,0x2
    8000660a:	963e                	add	a2,a2,a5
    8000660c:	85be                	mv	a1,a5
    8000660e:	855a                	mv	a0,s6
    80006610:	ffffb097          	auipc	ra,0xffffb
    80006614:	e1a080e7          	jalr	-486(ra) # 8000142a <uvmalloc>
    80006618:	8c2a                	mv	s8,a0
  ip = 0;
    8000661a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000661c:	12050e63          	beqz	a0,80006758 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80006620:	75f9                	lui	a1,0xffffe
    80006622:	95aa                	add	a1,a1,a0
    80006624:	855a                	mv	a0,s6
    80006626:	ffffb097          	auipc	ra,0xffffb
    8000662a:	026080e7          	jalr	38(ra) # 8000164c <uvmclear>
  stackbase = sp - PGSIZE;
    8000662e:	7afd                	lui	s5,0xfffff
    80006630:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80006632:	df043783          	ld	a5,-528(s0)
    80006636:	6388                	ld	a0,0(a5)
    80006638:	c925                	beqz	a0,800066a8 <exec+0x222>
    8000663a:	e9040993          	addi	s3,s0,-368
    8000663e:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80006642:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80006644:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80006646:	ffffb097          	auipc	ra,0xffffb
    8000664a:	800080e7          	jalr	-2048(ra) # 80000e46 <strlen>
    8000664e:	0015079b          	addiw	a5,a0,1
    80006652:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80006656:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000665a:	13596363          	bltu	s2,s5,80006780 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000665e:	df043d83          	ld	s11,-528(s0)
    80006662:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80006666:	8552                	mv	a0,s4
    80006668:	ffffa097          	auipc	ra,0xffffa
    8000666c:	7de080e7          	jalr	2014(ra) # 80000e46 <strlen>
    80006670:	0015069b          	addiw	a3,a0,1
    80006674:	8652                	mv	a2,s4
    80006676:	85ca                	mv	a1,s2
    80006678:	855a                	mv	a0,s6
    8000667a:	ffffb097          	auipc	ra,0xffffb
    8000667e:	004080e7          	jalr	4(ra) # 8000167e <copyout>
    80006682:	10054363          	bltz	a0,80006788 <exec+0x302>
    ustack[argc] = sp;
    80006686:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000668a:	0485                	addi	s1,s1,1
    8000668c:	008d8793          	addi	a5,s11,8
    80006690:	def43823          	sd	a5,-528(s0)
    80006694:	008db503          	ld	a0,8(s11)
    80006698:	c911                	beqz	a0,800066ac <exec+0x226>
    if(argc >= MAXARG)
    8000669a:	09a1                	addi	s3,s3,8
    8000669c:	fb3c95e3          	bne	s9,s3,80006646 <exec+0x1c0>
  sz = sz1;
    800066a0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800066a4:	4a81                	li	s5,0
    800066a6:	a84d                	j	80006758 <exec+0x2d2>
  sp = sz;
    800066a8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800066aa:	4481                	li	s1,0
  ustack[argc] = 0;
    800066ac:	00349793          	slli	a5,s1,0x3
    800066b0:	f9078793          	addi	a5,a5,-112
    800066b4:	97a2                	add	a5,a5,s0
    800066b6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800066ba:	00148693          	addi	a3,s1,1
    800066be:	068e                	slli	a3,a3,0x3
    800066c0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800066c4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800066c8:	01597663          	bgeu	s2,s5,800066d4 <exec+0x24e>
  sz = sz1;
    800066cc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800066d0:	4a81                	li	s5,0
    800066d2:	a059                	j	80006758 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800066d4:	e9040613          	addi	a2,s0,-368
    800066d8:	85ca                	mv	a1,s2
    800066da:	855a                	mv	a0,s6
    800066dc:	ffffb097          	auipc	ra,0xffffb
    800066e0:	fa2080e7          	jalr	-94(ra) # 8000167e <copyout>
    800066e4:	0a054663          	bltz	a0,80006790 <exec+0x30a>
  p->trapframe->a1 = sp;
    800066e8:	060bb783          	ld	a5,96(s7)
    800066ec:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800066f0:	de843783          	ld	a5,-536(s0)
    800066f4:	0007c703          	lbu	a4,0(a5)
    800066f8:	cf11                	beqz	a4,80006714 <exec+0x28e>
    800066fa:	0785                	addi	a5,a5,1
    if(*s == '/')
    800066fc:	02f00693          	li	a3,47
    80006700:	a039                	j	8000670e <exec+0x288>
      last = s+1;
    80006702:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80006706:	0785                	addi	a5,a5,1
    80006708:	fff7c703          	lbu	a4,-1(a5)
    8000670c:	c701                	beqz	a4,80006714 <exec+0x28e>
    if(*s == '/')
    8000670e:	fed71ce3          	bne	a4,a3,80006706 <exec+0x280>
    80006712:	bfc5                	j	80006702 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80006714:	4641                	li	a2,16
    80006716:	de843583          	ld	a1,-536(s0)
    8000671a:	160b8513          	addi	a0,s7,352
    8000671e:	ffffa097          	auipc	ra,0xffffa
    80006722:	6f6080e7          	jalr	1782(ra) # 80000e14 <safestrcpy>
  oldpagetable = p->pagetable;
    80006726:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    8000672a:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    8000672e:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80006732:	060bb783          	ld	a5,96(s7)
    80006736:	e6843703          	ld	a4,-408(s0)
    8000673a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000673c:	060bb783          	ld	a5,96(s7)
    80006740:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80006744:	85ea                	mv	a1,s10
    80006746:	ffffb097          	auipc	ra,0xffffb
    8000674a:	40c080e7          	jalr	1036(ra) # 80001b52 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000674e:	0004851b          	sext.w	a0,s1
    80006752:	bbc1                	j	80006522 <exec+0x9c>
    80006754:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80006758:	df843583          	ld	a1,-520(s0)
    8000675c:	855a                	mv	a0,s6
    8000675e:	ffffb097          	auipc	ra,0xffffb
    80006762:	3f4080e7          	jalr	1012(ra) # 80001b52 <proc_freepagetable>
  if(ip){
    80006766:	da0a94e3          	bnez	s5,8000650e <exec+0x88>
  return -1;
    8000676a:	557d                	li	a0,-1
    8000676c:	bb5d                	j	80006522 <exec+0x9c>
    8000676e:	de943c23          	sd	s1,-520(s0)
    80006772:	b7dd                	j	80006758 <exec+0x2d2>
    80006774:	de943c23          	sd	s1,-520(s0)
    80006778:	b7c5                	j	80006758 <exec+0x2d2>
    8000677a:	de943c23          	sd	s1,-520(s0)
    8000677e:	bfe9                	j	80006758 <exec+0x2d2>
  sz = sz1;
    80006780:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80006784:	4a81                	li	s5,0
    80006786:	bfc9                	j	80006758 <exec+0x2d2>
  sz = sz1;
    80006788:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000678c:	4a81                	li	s5,0
    8000678e:	b7e9                	j	80006758 <exec+0x2d2>
  sz = sz1;
    80006790:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80006794:	4a81                	li	s5,0
    80006796:	b7c9                	j	80006758 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006798:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000679c:	e0843783          	ld	a5,-504(s0)
    800067a0:	0017869b          	addiw	a3,a5,1
    800067a4:	e0d43423          	sd	a3,-504(s0)
    800067a8:	e0043783          	ld	a5,-512(s0)
    800067ac:	0387879b          	addiw	a5,a5,56
    800067b0:	e8845703          	lhu	a4,-376(s0)
    800067b4:	e2e6d3e3          	bge	a3,a4,800065da <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800067b8:	2781                	sext.w	a5,a5
    800067ba:	e0f43023          	sd	a5,-512(s0)
    800067be:	03800713          	li	a4,56
    800067c2:	86be                	mv	a3,a5
    800067c4:	e1840613          	addi	a2,s0,-488
    800067c8:	4581                	li	a1,0
    800067ca:	8556                	mv	a0,s5
    800067cc:	fffff097          	auipc	ra,0xfffff
    800067d0:	a76080e7          	jalr	-1418(ra) # 80005242 <readi>
    800067d4:	03800793          	li	a5,56
    800067d8:	f6f51ee3          	bne	a0,a5,80006754 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800067dc:	e1842783          	lw	a5,-488(s0)
    800067e0:	4705                	li	a4,1
    800067e2:	fae79de3          	bne	a5,a4,8000679c <exec+0x316>
    if(ph.memsz < ph.filesz)
    800067e6:	e4043603          	ld	a2,-448(s0)
    800067ea:	e3843783          	ld	a5,-456(s0)
    800067ee:	f8f660e3          	bltu	a2,a5,8000676e <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800067f2:	e2843783          	ld	a5,-472(s0)
    800067f6:	963e                	add	a2,a2,a5
    800067f8:	f6f66ee3          	bltu	a2,a5,80006774 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800067fc:	85a6                	mv	a1,s1
    800067fe:	855a                	mv	a0,s6
    80006800:	ffffb097          	auipc	ra,0xffffb
    80006804:	c2a080e7          	jalr	-982(ra) # 8000142a <uvmalloc>
    80006808:	dea43c23          	sd	a0,-520(s0)
    8000680c:	d53d                	beqz	a0,8000677a <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    8000680e:	e2843c03          	ld	s8,-472(s0)
    80006812:	de043783          	ld	a5,-544(s0)
    80006816:	00fc77b3          	and	a5,s8,a5
    8000681a:	ff9d                	bnez	a5,80006758 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000681c:	e2042c83          	lw	s9,-480(s0)
    80006820:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80006824:	f60b8ae3          	beqz	s7,80006798 <exec+0x312>
    80006828:	89de                	mv	s3,s7
    8000682a:	4481                	li	s1,0
    8000682c:	b371                	j	800065b8 <exec+0x132>

000000008000682e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000682e:	7179                	addi	sp,sp,-48
    80006830:	f406                	sd	ra,40(sp)
    80006832:	f022                	sd	s0,32(sp)
    80006834:	ec26                	sd	s1,24(sp)
    80006836:	e84a                	sd	s2,16(sp)
    80006838:	1800                	addi	s0,sp,48
    8000683a:	892e                	mv	s2,a1
    8000683c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000683e:	fdc40593          	addi	a1,s0,-36
    80006842:	ffffd097          	auipc	ra,0xffffd
    80006846:	398080e7          	jalr	920(ra) # 80003bda <argint>
    8000684a:	04054063          	bltz	a0,8000688a <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000684e:	fdc42703          	lw	a4,-36(s0)
    80006852:	47bd                	li	a5,15
    80006854:	02e7ed63          	bltu	a5,a4,8000688e <argfd+0x60>
    80006858:	ffffb097          	auipc	ra,0xffffb
    8000685c:	162080e7          	jalr	354(ra) # 800019ba <myproc>
    80006860:	fdc42703          	lw	a4,-36(s0)
    80006864:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd701a>
    80006868:	078e                	slli	a5,a5,0x3
    8000686a:	953e                	add	a0,a0,a5
    8000686c:	651c                	ld	a5,8(a0)
    8000686e:	c395                	beqz	a5,80006892 <argfd+0x64>
    return -1;
  if(pfd)
    80006870:	00090463          	beqz	s2,80006878 <argfd+0x4a>
    *pfd = fd;
    80006874:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80006878:	4501                	li	a0,0
  if(pf)
    8000687a:	c091                	beqz	s1,8000687e <argfd+0x50>
    *pf = f;
    8000687c:	e09c                	sd	a5,0(s1)
}
    8000687e:	70a2                	ld	ra,40(sp)
    80006880:	7402                	ld	s0,32(sp)
    80006882:	64e2                	ld	s1,24(sp)
    80006884:	6942                	ld	s2,16(sp)
    80006886:	6145                	addi	sp,sp,48
    80006888:	8082                	ret
    return -1;
    8000688a:	557d                	li	a0,-1
    8000688c:	bfcd                	j	8000687e <argfd+0x50>
    return -1;
    8000688e:	557d                	li	a0,-1
    80006890:	b7fd                	j	8000687e <argfd+0x50>
    80006892:	557d                	li	a0,-1
    80006894:	b7ed                	j	8000687e <argfd+0x50>

0000000080006896 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006896:	1101                	addi	sp,sp,-32
    80006898:	ec06                	sd	ra,24(sp)
    8000689a:	e822                	sd	s0,16(sp)
    8000689c:	e426                	sd	s1,8(sp)
    8000689e:	1000                	addi	s0,sp,32
    800068a0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800068a2:	ffffb097          	auipc	ra,0xffffb
    800068a6:	118080e7          	jalr	280(ra) # 800019ba <myproc>
    800068aa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800068ac:	0d850793          	addi	a5,a0,216
    800068b0:	4501                	li	a0,0
    800068b2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800068b4:	6398                	ld	a4,0(a5)
    800068b6:	cb19                	beqz	a4,800068cc <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800068b8:	2505                	addiw	a0,a0,1
    800068ba:	07a1                	addi	a5,a5,8
    800068bc:	fed51ce3          	bne	a0,a3,800068b4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800068c0:	557d                	li	a0,-1
}
    800068c2:	60e2                	ld	ra,24(sp)
    800068c4:	6442                	ld	s0,16(sp)
    800068c6:	64a2                	ld	s1,8(sp)
    800068c8:	6105                	addi	sp,sp,32
    800068ca:	8082                	ret
      p->ofile[fd] = f;
    800068cc:	01a50793          	addi	a5,a0,26
    800068d0:	078e                	slli	a5,a5,0x3
    800068d2:	963e                	add	a2,a2,a5
    800068d4:	e604                	sd	s1,8(a2)
      return fd;
    800068d6:	b7f5                	j	800068c2 <fdalloc+0x2c>

00000000800068d8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800068d8:	715d                	addi	sp,sp,-80
    800068da:	e486                	sd	ra,72(sp)
    800068dc:	e0a2                	sd	s0,64(sp)
    800068de:	fc26                	sd	s1,56(sp)
    800068e0:	f84a                	sd	s2,48(sp)
    800068e2:	f44e                	sd	s3,40(sp)
    800068e4:	f052                	sd	s4,32(sp)
    800068e6:	ec56                	sd	s5,24(sp)
    800068e8:	0880                	addi	s0,sp,80
    800068ea:	89ae                	mv	s3,a1
    800068ec:	8ab2                	mv	s5,a2
    800068ee:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800068f0:	fb040593          	addi	a1,s0,-80
    800068f4:	fffff097          	auipc	ra,0xfffff
    800068f8:	e74080e7          	jalr	-396(ra) # 80005768 <nameiparent>
    800068fc:	892a                	mv	s2,a0
    800068fe:	12050e63          	beqz	a0,80006a3a <create+0x162>
    return 0;

  ilock(dp);
    80006902:	ffffe097          	auipc	ra,0xffffe
    80006906:	68c080e7          	jalr	1676(ra) # 80004f8e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000690a:	4601                	li	a2,0
    8000690c:	fb040593          	addi	a1,s0,-80
    80006910:	854a                	mv	a0,s2
    80006912:	fffff097          	auipc	ra,0xfffff
    80006916:	b60080e7          	jalr	-1184(ra) # 80005472 <dirlookup>
    8000691a:	84aa                	mv	s1,a0
    8000691c:	c921                	beqz	a0,8000696c <create+0x94>
    iunlockput(dp);
    8000691e:	854a                	mv	a0,s2
    80006920:	fffff097          	auipc	ra,0xfffff
    80006924:	8d0080e7          	jalr	-1840(ra) # 800051f0 <iunlockput>
    ilock(ip);
    80006928:	8526                	mv	a0,s1
    8000692a:	ffffe097          	auipc	ra,0xffffe
    8000692e:	664080e7          	jalr	1636(ra) # 80004f8e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006932:	2981                	sext.w	s3,s3
    80006934:	4789                	li	a5,2
    80006936:	02f99463          	bne	s3,a5,8000695e <create+0x86>
    8000693a:	0444d783          	lhu	a5,68(s1)
    8000693e:	37f9                	addiw	a5,a5,-2
    80006940:	17c2                	slli	a5,a5,0x30
    80006942:	93c1                	srli	a5,a5,0x30
    80006944:	4705                	li	a4,1
    80006946:	00f76c63          	bltu	a4,a5,8000695e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000694a:	8526                	mv	a0,s1
    8000694c:	60a6                	ld	ra,72(sp)
    8000694e:	6406                	ld	s0,64(sp)
    80006950:	74e2                	ld	s1,56(sp)
    80006952:	7942                	ld	s2,48(sp)
    80006954:	79a2                	ld	s3,40(sp)
    80006956:	7a02                	ld	s4,32(sp)
    80006958:	6ae2                	ld	s5,24(sp)
    8000695a:	6161                	addi	sp,sp,80
    8000695c:	8082                	ret
    iunlockput(ip);
    8000695e:	8526                	mv	a0,s1
    80006960:	fffff097          	auipc	ra,0xfffff
    80006964:	890080e7          	jalr	-1904(ra) # 800051f0 <iunlockput>
    return 0;
    80006968:	4481                	li	s1,0
    8000696a:	b7c5                	j	8000694a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000696c:	85ce                	mv	a1,s3
    8000696e:	00092503          	lw	a0,0(s2)
    80006972:	ffffe097          	auipc	ra,0xffffe
    80006976:	482080e7          	jalr	1154(ra) # 80004df4 <ialloc>
    8000697a:	84aa                	mv	s1,a0
    8000697c:	c521                	beqz	a0,800069c4 <create+0xec>
  ilock(ip);
    8000697e:	ffffe097          	auipc	ra,0xffffe
    80006982:	610080e7          	jalr	1552(ra) # 80004f8e <ilock>
  ip->major = major;
    80006986:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000698a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000698e:	4a05                	li	s4,1
    80006990:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80006994:	8526                	mv	a0,s1
    80006996:	ffffe097          	auipc	ra,0xffffe
    8000699a:	52c080e7          	jalr	1324(ra) # 80004ec2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000699e:	2981                	sext.w	s3,s3
    800069a0:	03498a63          	beq	s3,s4,800069d4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800069a4:	40d0                	lw	a2,4(s1)
    800069a6:	fb040593          	addi	a1,s0,-80
    800069aa:	854a                	mv	a0,s2
    800069ac:	fffff097          	auipc	ra,0xfffff
    800069b0:	cdc080e7          	jalr	-804(ra) # 80005688 <dirlink>
    800069b4:	06054b63          	bltz	a0,80006a2a <create+0x152>
  iunlockput(dp);
    800069b8:	854a                	mv	a0,s2
    800069ba:	fffff097          	auipc	ra,0xfffff
    800069be:	836080e7          	jalr	-1994(ra) # 800051f0 <iunlockput>
  return ip;
    800069c2:	b761                	j	8000694a <create+0x72>
    panic("create: ialloc");
    800069c4:	00003517          	auipc	a0,0x3
    800069c8:	06c50513          	addi	a0,a0,108 # 80009a30 <syscalls+0x3f0>
    800069cc:	ffffa097          	auipc	ra,0xffffa
    800069d0:	b6c080e7          	jalr	-1172(ra) # 80000538 <panic>
    dp->nlink++;  // for ".."
    800069d4:	04a95783          	lhu	a5,74(s2)
    800069d8:	2785                	addiw	a5,a5,1
    800069da:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800069de:	854a                	mv	a0,s2
    800069e0:	ffffe097          	auipc	ra,0xffffe
    800069e4:	4e2080e7          	jalr	1250(ra) # 80004ec2 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800069e8:	40d0                	lw	a2,4(s1)
    800069ea:	00003597          	auipc	a1,0x3
    800069ee:	05658593          	addi	a1,a1,86 # 80009a40 <syscalls+0x400>
    800069f2:	8526                	mv	a0,s1
    800069f4:	fffff097          	auipc	ra,0xfffff
    800069f8:	c94080e7          	jalr	-876(ra) # 80005688 <dirlink>
    800069fc:	00054f63          	bltz	a0,80006a1a <create+0x142>
    80006a00:	00492603          	lw	a2,4(s2)
    80006a04:	00003597          	auipc	a1,0x3
    80006a08:	04458593          	addi	a1,a1,68 # 80009a48 <syscalls+0x408>
    80006a0c:	8526                	mv	a0,s1
    80006a0e:	fffff097          	auipc	ra,0xfffff
    80006a12:	c7a080e7          	jalr	-902(ra) # 80005688 <dirlink>
    80006a16:	f80557e3          	bgez	a0,800069a4 <create+0xcc>
      panic("create dots");
    80006a1a:	00003517          	auipc	a0,0x3
    80006a1e:	03650513          	addi	a0,a0,54 # 80009a50 <syscalls+0x410>
    80006a22:	ffffa097          	auipc	ra,0xffffa
    80006a26:	b16080e7          	jalr	-1258(ra) # 80000538 <panic>
    panic("create: dirlink");
    80006a2a:	00003517          	auipc	a0,0x3
    80006a2e:	03650513          	addi	a0,a0,54 # 80009a60 <syscalls+0x420>
    80006a32:	ffffa097          	auipc	ra,0xffffa
    80006a36:	b06080e7          	jalr	-1274(ra) # 80000538 <panic>
    return 0;
    80006a3a:	84aa                	mv	s1,a0
    80006a3c:	b739                	j	8000694a <create+0x72>

0000000080006a3e <sys_dup>:
{
    80006a3e:	7179                	addi	sp,sp,-48
    80006a40:	f406                	sd	ra,40(sp)
    80006a42:	f022                	sd	s0,32(sp)
    80006a44:	ec26                	sd	s1,24(sp)
    80006a46:	e84a                	sd	s2,16(sp)
    80006a48:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80006a4a:	fd840613          	addi	a2,s0,-40
    80006a4e:	4581                	li	a1,0
    80006a50:	4501                	li	a0,0
    80006a52:	00000097          	auipc	ra,0x0
    80006a56:	ddc080e7          	jalr	-548(ra) # 8000682e <argfd>
    return -1;
    80006a5a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80006a5c:	02054363          	bltz	a0,80006a82 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80006a60:	fd843903          	ld	s2,-40(s0)
    80006a64:	854a                	mv	a0,s2
    80006a66:	00000097          	auipc	ra,0x0
    80006a6a:	e30080e7          	jalr	-464(ra) # 80006896 <fdalloc>
    80006a6e:	84aa                	mv	s1,a0
    return -1;
    80006a70:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80006a72:	00054863          	bltz	a0,80006a82 <sys_dup+0x44>
  filedup(f);
    80006a76:	854a                	mv	a0,s2
    80006a78:	fffff097          	auipc	ra,0xfffff
    80006a7c:	368080e7          	jalr	872(ra) # 80005de0 <filedup>
  return fd;
    80006a80:	87a6                	mv	a5,s1
}
    80006a82:	853e                	mv	a0,a5
    80006a84:	70a2                	ld	ra,40(sp)
    80006a86:	7402                	ld	s0,32(sp)
    80006a88:	64e2                	ld	s1,24(sp)
    80006a8a:	6942                	ld	s2,16(sp)
    80006a8c:	6145                	addi	sp,sp,48
    80006a8e:	8082                	ret

0000000080006a90 <sys_read>:
{
    80006a90:	7179                	addi	sp,sp,-48
    80006a92:	f406                	sd	ra,40(sp)
    80006a94:	f022                	sd	s0,32(sp)
    80006a96:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006a98:	fe840613          	addi	a2,s0,-24
    80006a9c:	4581                	li	a1,0
    80006a9e:	4501                	li	a0,0
    80006aa0:	00000097          	auipc	ra,0x0
    80006aa4:	d8e080e7          	jalr	-626(ra) # 8000682e <argfd>
    return -1;
    80006aa8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006aaa:	04054163          	bltz	a0,80006aec <sys_read+0x5c>
    80006aae:	fe440593          	addi	a1,s0,-28
    80006ab2:	4509                	li	a0,2
    80006ab4:	ffffd097          	auipc	ra,0xffffd
    80006ab8:	126080e7          	jalr	294(ra) # 80003bda <argint>
    return -1;
    80006abc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006abe:	02054763          	bltz	a0,80006aec <sys_read+0x5c>
    80006ac2:	fd840593          	addi	a1,s0,-40
    80006ac6:	4505                	li	a0,1
    80006ac8:	ffffd097          	auipc	ra,0xffffd
    80006acc:	134080e7          	jalr	308(ra) # 80003bfc <argaddr>
    return -1;
    80006ad0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006ad2:	00054d63          	bltz	a0,80006aec <sys_read+0x5c>
  return fileread(f, p, n);
    80006ad6:	fe442603          	lw	a2,-28(s0)
    80006ada:	fd843583          	ld	a1,-40(s0)
    80006ade:	fe843503          	ld	a0,-24(s0)
    80006ae2:	fffff097          	auipc	ra,0xfffff
    80006ae6:	48a080e7          	jalr	1162(ra) # 80005f6c <fileread>
    80006aea:	87aa                	mv	a5,a0
}
    80006aec:	853e                	mv	a0,a5
    80006aee:	70a2                	ld	ra,40(sp)
    80006af0:	7402                	ld	s0,32(sp)
    80006af2:	6145                	addi	sp,sp,48
    80006af4:	8082                	ret

0000000080006af6 <sys_write>:
{
    80006af6:	7179                	addi	sp,sp,-48
    80006af8:	f406                	sd	ra,40(sp)
    80006afa:	f022                	sd	s0,32(sp)
    80006afc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006afe:	fe840613          	addi	a2,s0,-24
    80006b02:	4581                	li	a1,0
    80006b04:	4501                	li	a0,0
    80006b06:	00000097          	auipc	ra,0x0
    80006b0a:	d28080e7          	jalr	-728(ra) # 8000682e <argfd>
    return -1;
    80006b0e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006b10:	04054163          	bltz	a0,80006b52 <sys_write+0x5c>
    80006b14:	fe440593          	addi	a1,s0,-28
    80006b18:	4509                	li	a0,2
    80006b1a:	ffffd097          	auipc	ra,0xffffd
    80006b1e:	0c0080e7          	jalr	192(ra) # 80003bda <argint>
    return -1;
    80006b22:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006b24:	02054763          	bltz	a0,80006b52 <sys_write+0x5c>
    80006b28:	fd840593          	addi	a1,s0,-40
    80006b2c:	4505                	li	a0,1
    80006b2e:	ffffd097          	auipc	ra,0xffffd
    80006b32:	0ce080e7          	jalr	206(ra) # 80003bfc <argaddr>
    return -1;
    80006b36:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006b38:	00054d63          	bltz	a0,80006b52 <sys_write+0x5c>
  return filewrite(f, p, n);
    80006b3c:	fe442603          	lw	a2,-28(s0)
    80006b40:	fd843583          	ld	a1,-40(s0)
    80006b44:	fe843503          	ld	a0,-24(s0)
    80006b48:	fffff097          	auipc	ra,0xfffff
    80006b4c:	4e6080e7          	jalr	1254(ra) # 8000602e <filewrite>
    80006b50:	87aa                	mv	a5,a0
}
    80006b52:	853e                	mv	a0,a5
    80006b54:	70a2                	ld	ra,40(sp)
    80006b56:	7402                	ld	s0,32(sp)
    80006b58:	6145                	addi	sp,sp,48
    80006b5a:	8082                	ret

0000000080006b5c <sys_close>:
{
    80006b5c:	1101                	addi	sp,sp,-32
    80006b5e:	ec06                	sd	ra,24(sp)
    80006b60:	e822                	sd	s0,16(sp)
    80006b62:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80006b64:	fe040613          	addi	a2,s0,-32
    80006b68:	fec40593          	addi	a1,s0,-20
    80006b6c:	4501                	li	a0,0
    80006b6e:	00000097          	auipc	ra,0x0
    80006b72:	cc0080e7          	jalr	-832(ra) # 8000682e <argfd>
    return -1;
    80006b76:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006b78:	02054463          	bltz	a0,80006ba0 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80006b7c:	ffffb097          	auipc	ra,0xffffb
    80006b80:	e3e080e7          	jalr	-450(ra) # 800019ba <myproc>
    80006b84:	fec42783          	lw	a5,-20(s0)
    80006b88:	07e9                	addi	a5,a5,26
    80006b8a:	078e                	slli	a5,a5,0x3
    80006b8c:	953e                	add	a0,a0,a5
    80006b8e:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80006b92:	fe043503          	ld	a0,-32(s0)
    80006b96:	fffff097          	auipc	ra,0xfffff
    80006b9a:	29c080e7          	jalr	668(ra) # 80005e32 <fileclose>
  return 0;
    80006b9e:	4781                	li	a5,0
}
    80006ba0:	853e                	mv	a0,a5
    80006ba2:	60e2                	ld	ra,24(sp)
    80006ba4:	6442                	ld	s0,16(sp)
    80006ba6:	6105                	addi	sp,sp,32
    80006ba8:	8082                	ret

0000000080006baa <sys_fstat>:
{
    80006baa:	1101                	addi	sp,sp,-32
    80006bac:	ec06                	sd	ra,24(sp)
    80006bae:	e822                	sd	s0,16(sp)
    80006bb0:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006bb2:	fe840613          	addi	a2,s0,-24
    80006bb6:	4581                	li	a1,0
    80006bb8:	4501                	li	a0,0
    80006bba:	00000097          	auipc	ra,0x0
    80006bbe:	c74080e7          	jalr	-908(ra) # 8000682e <argfd>
    return -1;
    80006bc2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006bc4:	02054563          	bltz	a0,80006bee <sys_fstat+0x44>
    80006bc8:	fe040593          	addi	a1,s0,-32
    80006bcc:	4505                	li	a0,1
    80006bce:	ffffd097          	auipc	ra,0xffffd
    80006bd2:	02e080e7          	jalr	46(ra) # 80003bfc <argaddr>
    return -1;
    80006bd6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006bd8:	00054b63          	bltz	a0,80006bee <sys_fstat+0x44>
  return filestat(f, st);
    80006bdc:	fe043583          	ld	a1,-32(s0)
    80006be0:	fe843503          	ld	a0,-24(s0)
    80006be4:	fffff097          	auipc	ra,0xfffff
    80006be8:	316080e7          	jalr	790(ra) # 80005efa <filestat>
    80006bec:	87aa                	mv	a5,a0
}
    80006bee:	853e                	mv	a0,a5
    80006bf0:	60e2                	ld	ra,24(sp)
    80006bf2:	6442                	ld	s0,16(sp)
    80006bf4:	6105                	addi	sp,sp,32
    80006bf6:	8082                	ret

0000000080006bf8 <sys_link>:
{
    80006bf8:	7169                	addi	sp,sp,-304
    80006bfa:	f606                	sd	ra,296(sp)
    80006bfc:	f222                	sd	s0,288(sp)
    80006bfe:	ee26                	sd	s1,280(sp)
    80006c00:	ea4a                	sd	s2,272(sp)
    80006c02:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006c04:	08000613          	li	a2,128
    80006c08:	ed040593          	addi	a1,s0,-304
    80006c0c:	4501                	li	a0,0
    80006c0e:	ffffd097          	auipc	ra,0xffffd
    80006c12:	010080e7          	jalr	16(ra) # 80003c1e <argstr>
    return -1;
    80006c16:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006c18:	10054e63          	bltz	a0,80006d34 <sys_link+0x13c>
    80006c1c:	08000613          	li	a2,128
    80006c20:	f5040593          	addi	a1,s0,-176
    80006c24:	4505                	li	a0,1
    80006c26:	ffffd097          	auipc	ra,0xffffd
    80006c2a:	ff8080e7          	jalr	-8(ra) # 80003c1e <argstr>
    return -1;
    80006c2e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006c30:	10054263          	bltz	a0,80006d34 <sys_link+0x13c>
  begin_op();
    80006c34:	fffff097          	auipc	ra,0xfffff
    80006c38:	d36080e7          	jalr	-714(ra) # 8000596a <begin_op>
  if((ip = namei(old)) == 0){
    80006c3c:	ed040513          	addi	a0,s0,-304
    80006c40:	fffff097          	auipc	ra,0xfffff
    80006c44:	b0a080e7          	jalr	-1270(ra) # 8000574a <namei>
    80006c48:	84aa                	mv	s1,a0
    80006c4a:	c551                	beqz	a0,80006cd6 <sys_link+0xde>
  ilock(ip);
    80006c4c:	ffffe097          	auipc	ra,0xffffe
    80006c50:	342080e7          	jalr	834(ra) # 80004f8e <ilock>
  if(ip->type == T_DIR){
    80006c54:	04449703          	lh	a4,68(s1)
    80006c58:	4785                	li	a5,1
    80006c5a:	08f70463          	beq	a4,a5,80006ce2 <sys_link+0xea>
  ip->nlink++;
    80006c5e:	04a4d783          	lhu	a5,74(s1)
    80006c62:	2785                	addiw	a5,a5,1
    80006c64:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006c68:	8526                	mv	a0,s1
    80006c6a:	ffffe097          	auipc	ra,0xffffe
    80006c6e:	258080e7          	jalr	600(ra) # 80004ec2 <iupdate>
  iunlock(ip);
    80006c72:	8526                	mv	a0,s1
    80006c74:	ffffe097          	auipc	ra,0xffffe
    80006c78:	3dc080e7          	jalr	988(ra) # 80005050 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80006c7c:	fd040593          	addi	a1,s0,-48
    80006c80:	f5040513          	addi	a0,s0,-176
    80006c84:	fffff097          	auipc	ra,0xfffff
    80006c88:	ae4080e7          	jalr	-1308(ra) # 80005768 <nameiparent>
    80006c8c:	892a                	mv	s2,a0
    80006c8e:	c935                	beqz	a0,80006d02 <sys_link+0x10a>
  ilock(dp);
    80006c90:	ffffe097          	auipc	ra,0xffffe
    80006c94:	2fe080e7          	jalr	766(ra) # 80004f8e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006c98:	00092703          	lw	a4,0(s2)
    80006c9c:	409c                	lw	a5,0(s1)
    80006c9e:	04f71d63          	bne	a4,a5,80006cf8 <sys_link+0x100>
    80006ca2:	40d0                	lw	a2,4(s1)
    80006ca4:	fd040593          	addi	a1,s0,-48
    80006ca8:	854a                	mv	a0,s2
    80006caa:	fffff097          	auipc	ra,0xfffff
    80006cae:	9de080e7          	jalr	-1570(ra) # 80005688 <dirlink>
    80006cb2:	04054363          	bltz	a0,80006cf8 <sys_link+0x100>
  iunlockput(dp);
    80006cb6:	854a                	mv	a0,s2
    80006cb8:	ffffe097          	auipc	ra,0xffffe
    80006cbc:	538080e7          	jalr	1336(ra) # 800051f0 <iunlockput>
  iput(ip);
    80006cc0:	8526                	mv	a0,s1
    80006cc2:	ffffe097          	auipc	ra,0xffffe
    80006cc6:	486080e7          	jalr	1158(ra) # 80005148 <iput>
  end_op();
    80006cca:	fffff097          	auipc	ra,0xfffff
    80006cce:	d1e080e7          	jalr	-738(ra) # 800059e8 <end_op>
  return 0;
    80006cd2:	4781                	li	a5,0
    80006cd4:	a085                	j	80006d34 <sys_link+0x13c>
    end_op();
    80006cd6:	fffff097          	auipc	ra,0xfffff
    80006cda:	d12080e7          	jalr	-750(ra) # 800059e8 <end_op>
    return -1;
    80006cde:	57fd                	li	a5,-1
    80006ce0:	a891                	j	80006d34 <sys_link+0x13c>
    iunlockput(ip);
    80006ce2:	8526                	mv	a0,s1
    80006ce4:	ffffe097          	auipc	ra,0xffffe
    80006ce8:	50c080e7          	jalr	1292(ra) # 800051f0 <iunlockput>
    end_op();
    80006cec:	fffff097          	auipc	ra,0xfffff
    80006cf0:	cfc080e7          	jalr	-772(ra) # 800059e8 <end_op>
    return -1;
    80006cf4:	57fd                	li	a5,-1
    80006cf6:	a83d                	j	80006d34 <sys_link+0x13c>
    iunlockput(dp);
    80006cf8:	854a                	mv	a0,s2
    80006cfa:	ffffe097          	auipc	ra,0xffffe
    80006cfe:	4f6080e7          	jalr	1270(ra) # 800051f0 <iunlockput>
  ilock(ip);
    80006d02:	8526                	mv	a0,s1
    80006d04:	ffffe097          	auipc	ra,0xffffe
    80006d08:	28a080e7          	jalr	650(ra) # 80004f8e <ilock>
  ip->nlink--;
    80006d0c:	04a4d783          	lhu	a5,74(s1)
    80006d10:	37fd                	addiw	a5,a5,-1
    80006d12:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006d16:	8526                	mv	a0,s1
    80006d18:	ffffe097          	auipc	ra,0xffffe
    80006d1c:	1aa080e7          	jalr	426(ra) # 80004ec2 <iupdate>
  iunlockput(ip);
    80006d20:	8526                	mv	a0,s1
    80006d22:	ffffe097          	auipc	ra,0xffffe
    80006d26:	4ce080e7          	jalr	1230(ra) # 800051f0 <iunlockput>
  end_op();
    80006d2a:	fffff097          	auipc	ra,0xfffff
    80006d2e:	cbe080e7          	jalr	-834(ra) # 800059e8 <end_op>
  return -1;
    80006d32:	57fd                	li	a5,-1
}
    80006d34:	853e                	mv	a0,a5
    80006d36:	70b2                	ld	ra,296(sp)
    80006d38:	7412                	ld	s0,288(sp)
    80006d3a:	64f2                	ld	s1,280(sp)
    80006d3c:	6952                	ld	s2,272(sp)
    80006d3e:	6155                	addi	sp,sp,304
    80006d40:	8082                	ret

0000000080006d42 <sys_unlink>:
{
    80006d42:	7151                	addi	sp,sp,-240
    80006d44:	f586                	sd	ra,232(sp)
    80006d46:	f1a2                	sd	s0,224(sp)
    80006d48:	eda6                	sd	s1,216(sp)
    80006d4a:	e9ca                	sd	s2,208(sp)
    80006d4c:	e5ce                	sd	s3,200(sp)
    80006d4e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80006d50:	08000613          	li	a2,128
    80006d54:	f3040593          	addi	a1,s0,-208
    80006d58:	4501                	li	a0,0
    80006d5a:	ffffd097          	auipc	ra,0xffffd
    80006d5e:	ec4080e7          	jalr	-316(ra) # 80003c1e <argstr>
    80006d62:	18054163          	bltz	a0,80006ee4 <sys_unlink+0x1a2>
  begin_op();
    80006d66:	fffff097          	auipc	ra,0xfffff
    80006d6a:	c04080e7          	jalr	-1020(ra) # 8000596a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80006d6e:	fb040593          	addi	a1,s0,-80
    80006d72:	f3040513          	addi	a0,s0,-208
    80006d76:	fffff097          	auipc	ra,0xfffff
    80006d7a:	9f2080e7          	jalr	-1550(ra) # 80005768 <nameiparent>
    80006d7e:	84aa                	mv	s1,a0
    80006d80:	c979                	beqz	a0,80006e56 <sys_unlink+0x114>
  ilock(dp);
    80006d82:	ffffe097          	auipc	ra,0xffffe
    80006d86:	20c080e7          	jalr	524(ra) # 80004f8e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006d8a:	00003597          	auipc	a1,0x3
    80006d8e:	cb658593          	addi	a1,a1,-842 # 80009a40 <syscalls+0x400>
    80006d92:	fb040513          	addi	a0,s0,-80
    80006d96:	ffffe097          	auipc	ra,0xffffe
    80006d9a:	6c2080e7          	jalr	1730(ra) # 80005458 <namecmp>
    80006d9e:	14050a63          	beqz	a0,80006ef2 <sys_unlink+0x1b0>
    80006da2:	00003597          	auipc	a1,0x3
    80006da6:	ca658593          	addi	a1,a1,-858 # 80009a48 <syscalls+0x408>
    80006daa:	fb040513          	addi	a0,s0,-80
    80006dae:	ffffe097          	auipc	ra,0xffffe
    80006db2:	6aa080e7          	jalr	1706(ra) # 80005458 <namecmp>
    80006db6:	12050e63          	beqz	a0,80006ef2 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80006dba:	f2c40613          	addi	a2,s0,-212
    80006dbe:	fb040593          	addi	a1,s0,-80
    80006dc2:	8526                	mv	a0,s1
    80006dc4:	ffffe097          	auipc	ra,0xffffe
    80006dc8:	6ae080e7          	jalr	1710(ra) # 80005472 <dirlookup>
    80006dcc:	892a                	mv	s2,a0
    80006dce:	12050263          	beqz	a0,80006ef2 <sys_unlink+0x1b0>
  ilock(ip);
    80006dd2:	ffffe097          	auipc	ra,0xffffe
    80006dd6:	1bc080e7          	jalr	444(ra) # 80004f8e <ilock>
  if(ip->nlink < 1)
    80006dda:	04a91783          	lh	a5,74(s2)
    80006dde:	08f05263          	blez	a5,80006e62 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006de2:	04491703          	lh	a4,68(s2)
    80006de6:	4785                	li	a5,1
    80006de8:	08f70563          	beq	a4,a5,80006e72 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006dec:	4641                	li	a2,16
    80006dee:	4581                	li	a1,0
    80006df0:	fc040513          	addi	a0,s0,-64
    80006df4:	ffffa097          	auipc	ra,0xffffa
    80006df8:	ed6080e7          	jalr	-298(ra) # 80000cca <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006dfc:	4741                	li	a4,16
    80006dfe:	f2c42683          	lw	a3,-212(s0)
    80006e02:	fc040613          	addi	a2,s0,-64
    80006e06:	4581                	li	a1,0
    80006e08:	8526                	mv	a0,s1
    80006e0a:	ffffe097          	auipc	ra,0xffffe
    80006e0e:	530080e7          	jalr	1328(ra) # 8000533a <writei>
    80006e12:	47c1                	li	a5,16
    80006e14:	0af51563          	bne	a0,a5,80006ebe <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80006e18:	04491703          	lh	a4,68(s2)
    80006e1c:	4785                	li	a5,1
    80006e1e:	0af70863          	beq	a4,a5,80006ece <sys_unlink+0x18c>
  iunlockput(dp);
    80006e22:	8526                	mv	a0,s1
    80006e24:	ffffe097          	auipc	ra,0xffffe
    80006e28:	3cc080e7          	jalr	972(ra) # 800051f0 <iunlockput>
  ip->nlink--;
    80006e2c:	04a95783          	lhu	a5,74(s2)
    80006e30:	37fd                	addiw	a5,a5,-1
    80006e32:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006e36:	854a                	mv	a0,s2
    80006e38:	ffffe097          	auipc	ra,0xffffe
    80006e3c:	08a080e7          	jalr	138(ra) # 80004ec2 <iupdate>
  iunlockput(ip);
    80006e40:	854a                	mv	a0,s2
    80006e42:	ffffe097          	auipc	ra,0xffffe
    80006e46:	3ae080e7          	jalr	942(ra) # 800051f0 <iunlockput>
  end_op();
    80006e4a:	fffff097          	auipc	ra,0xfffff
    80006e4e:	b9e080e7          	jalr	-1122(ra) # 800059e8 <end_op>
  return 0;
    80006e52:	4501                	li	a0,0
    80006e54:	a84d                	j	80006f06 <sys_unlink+0x1c4>
    end_op();
    80006e56:	fffff097          	auipc	ra,0xfffff
    80006e5a:	b92080e7          	jalr	-1134(ra) # 800059e8 <end_op>
    return -1;
    80006e5e:	557d                	li	a0,-1
    80006e60:	a05d                	j	80006f06 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80006e62:	00003517          	auipc	a0,0x3
    80006e66:	c0e50513          	addi	a0,a0,-1010 # 80009a70 <syscalls+0x430>
    80006e6a:	ffff9097          	auipc	ra,0xffff9
    80006e6e:	6ce080e7          	jalr	1742(ra) # 80000538 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006e72:	04c92703          	lw	a4,76(s2)
    80006e76:	02000793          	li	a5,32
    80006e7a:	f6e7f9e3          	bgeu	a5,a4,80006dec <sys_unlink+0xaa>
    80006e7e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006e82:	4741                	li	a4,16
    80006e84:	86ce                	mv	a3,s3
    80006e86:	f1840613          	addi	a2,s0,-232
    80006e8a:	4581                	li	a1,0
    80006e8c:	854a                	mv	a0,s2
    80006e8e:	ffffe097          	auipc	ra,0xffffe
    80006e92:	3b4080e7          	jalr	948(ra) # 80005242 <readi>
    80006e96:	47c1                	li	a5,16
    80006e98:	00f51b63          	bne	a0,a5,80006eae <sys_unlink+0x16c>
    if(de.inum != 0)
    80006e9c:	f1845783          	lhu	a5,-232(s0)
    80006ea0:	e7a1                	bnez	a5,80006ee8 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006ea2:	29c1                	addiw	s3,s3,16
    80006ea4:	04c92783          	lw	a5,76(s2)
    80006ea8:	fcf9ede3          	bltu	s3,a5,80006e82 <sys_unlink+0x140>
    80006eac:	b781                	j	80006dec <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006eae:	00003517          	auipc	a0,0x3
    80006eb2:	bda50513          	addi	a0,a0,-1062 # 80009a88 <syscalls+0x448>
    80006eb6:	ffff9097          	auipc	ra,0xffff9
    80006eba:	682080e7          	jalr	1666(ra) # 80000538 <panic>
    panic("unlink: writei");
    80006ebe:	00003517          	auipc	a0,0x3
    80006ec2:	be250513          	addi	a0,a0,-1054 # 80009aa0 <syscalls+0x460>
    80006ec6:	ffff9097          	auipc	ra,0xffff9
    80006eca:	672080e7          	jalr	1650(ra) # 80000538 <panic>
    dp->nlink--;
    80006ece:	04a4d783          	lhu	a5,74(s1)
    80006ed2:	37fd                	addiw	a5,a5,-1
    80006ed4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006ed8:	8526                	mv	a0,s1
    80006eda:	ffffe097          	auipc	ra,0xffffe
    80006ede:	fe8080e7          	jalr	-24(ra) # 80004ec2 <iupdate>
    80006ee2:	b781                	j	80006e22 <sys_unlink+0xe0>
    return -1;
    80006ee4:	557d                	li	a0,-1
    80006ee6:	a005                	j	80006f06 <sys_unlink+0x1c4>
    iunlockput(ip);
    80006ee8:	854a                	mv	a0,s2
    80006eea:	ffffe097          	auipc	ra,0xffffe
    80006eee:	306080e7          	jalr	774(ra) # 800051f0 <iunlockput>
  iunlockput(dp);
    80006ef2:	8526                	mv	a0,s1
    80006ef4:	ffffe097          	auipc	ra,0xffffe
    80006ef8:	2fc080e7          	jalr	764(ra) # 800051f0 <iunlockput>
  end_op();
    80006efc:	fffff097          	auipc	ra,0xfffff
    80006f00:	aec080e7          	jalr	-1300(ra) # 800059e8 <end_op>
  return -1;
    80006f04:	557d                	li	a0,-1
}
    80006f06:	70ae                	ld	ra,232(sp)
    80006f08:	740e                	ld	s0,224(sp)
    80006f0a:	64ee                	ld	s1,216(sp)
    80006f0c:	694e                	ld	s2,208(sp)
    80006f0e:	69ae                	ld	s3,200(sp)
    80006f10:	616d                	addi	sp,sp,240
    80006f12:	8082                	ret

0000000080006f14 <sys_open>:

uint64
sys_open(void)
{
    80006f14:	7131                	addi	sp,sp,-192
    80006f16:	fd06                	sd	ra,184(sp)
    80006f18:	f922                	sd	s0,176(sp)
    80006f1a:	f526                	sd	s1,168(sp)
    80006f1c:	f14a                	sd	s2,160(sp)
    80006f1e:	ed4e                	sd	s3,152(sp)
    80006f20:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006f22:	08000613          	li	a2,128
    80006f26:	f5040593          	addi	a1,s0,-176
    80006f2a:	4501                	li	a0,0
    80006f2c:	ffffd097          	auipc	ra,0xffffd
    80006f30:	cf2080e7          	jalr	-782(ra) # 80003c1e <argstr>
    return -1;
    80006f34:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006f36:	0c054163          	bltz	a0,80006ff8 <sys_open+0xe4>
    80006f3a:	f4c40593          	addi	a1,s0,-180
    80006f3e:	4505                	li	a0,1
    80006f40:	ffffd097          	auipc	ra,0xffffd
    80006f44:	c9a080e7          	jalr	-870(ra) # 80003bda <argint>
    80006f48:	0a054863          	bltz	a0,80006ff8 <sys_open+0xe4>

  begin_op();
    80006f4c:	fffff097          	auipc	ra,0xfffff
    80006f50:	a1e080e7          	jalr	-1506(ra) # 8000596a <begin_op>

  if(omode & O_CREATE){
    80006f54:	f4c42783          	lw	a5,-180(s0)
    80006f58:	2007f793          	andi	a5,a5,512
    80006f5c:	cbdd                	beqz	a5,80007012 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006f5e:	4681                	li	a3,0
    80006f60:	4601                	li	a2,0
    80006f62:	4589                	li	a1,2
    80006f64:	f5040513          	addi	a0,s0,-176
    80006f68:	00000097          	auipc	ra,0x0
    80006f6c:	970080e7          	jalr	-1680(ra) # 800068d8 <create>
    80006f70:	892a                	mv	s2,a0
    if(ip == 0){
    80006f72:	c959                	beqz	a0,80007008 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006f74:	04491703          	lh	a4,68(s2)
    80006f78:	478d                	li	a5,3
    80006f7a:	00f71763          	bne	a4,a5,80006f88 <sys_open+0x74>
    80006f7e:	04695703          	lhu	a4,70(s2)
    80006f82:	47a5                	li	a5,9
    80006f84:	0ce7ec63          	bltu	a5,a4,8000705c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006f88:	fffff097          	auipc	ra,0xfffff
    80006f8c:	dee080e7          	jalr	-530(ra) # 80005d76 <filealloc>
    80006f90:	89aa                	mv	s3,a0
    80006f92:	10050263          	beqz	a0,80007096 <sys_open+0x182>
    80006f96:	00000097          	auipc	ra,0x0
    80006f9a:	900080e7          	jalr	-1792(ra) # 80006896 <fdalloc>
    80006f9e:	84aa                	mv	s1,a0
    80006fa0:	0e054663          	bltz	a0,8000708c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006fa4:	04491703          	lh	a4,68(s2)
    80006fa8:	478d                	li	a5,3
    80006faa:	0cf70463          	beq	a4,a5,80007072 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006fae:	4789                	li	a5,2
    80006fb0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006fb4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006fb8:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006fbc:	f4c42783          	lw	a5,-180(s0)
    80006fc0:	0017c713          	xori	a4,a5,1
    80006fc4:	8b05                	andi	a4,a4,1
    80006fc6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006fca:	0037f713          	andi	a4,a5,3
    80006fce:	00e03733          	snez	a4,a4
    80006fd2:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006fd6:	4007f793          	andi	a5,a5,1024
    80006fda:	c791                	beqz	a5,80006fe6 <sys_open+0xd2>
    80006fdc:	04491703          	lh	a4,68(s2)
    80006fe0:	4789                	li	a5,2
    80006fe2:	08f70f63          	beq	a4,a5,80007080 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006fe6:	854a                	mv	a0,s2
    80006fe8:	ffffe097          	auipc	ra,0xffffe
    80006fec:	068080e7          	jalr	104(ra) # 80005050 <iunlock>
  end_op();
    80006ff0:	fffff097          	auipc	ra,0xfffff
    80006ff4:	9f8080e7          	jalr	-1544(ra) # 800059e8 <end_op>

  return fd;
}
    80006ff8:	8526                	mv	a0,s1
    80006ffa:	70ea                	ld	ra,184(sp)
    80006ffc:	744a                	ld	s0,176(sp)
    80006ffe:	74aa                	ld	s1,168(sp)
    80007000:	790a                	ld	s2,160(sp)
    80007002:	69ea                	ld	s3,152(sp)
    80007004:	6129                	addi	sp,sp,192
    80007006:	8082                	ret
      end_op();
    80007008:	fffff097          	auipc	ra,0xfffff
    8000700c:	9e0080e7          	jalr	-1568(ra) # 800059e8 <end_op>
      return -1;
    80007010:	b7e5                	j	80006ff8 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80007012:	f5040513          	addi	a0,s0,-176
    80007016:	ffffe097          	auipc	ra,0xffffe
    8000701a:	734080e7          	jalr	1844(ra) # 8000574a <namei>
    8000701e:	892a                	mv	s2,a0
    80007020:	c905                	beqz	a0,80007050 <sys_open+0x13c>
    ilock(ip);
    80007022:	ffffe097          	auipc	ra,0xffffe
    80007026:	f6c080e7          	jalr	-148(ra) # 80004f8e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000702a:	04491703          	lh	a4,68(s2)
    8000702e:	4785                	li	a5,1
    80007030:	f4f712e3          	bne	a4,a5,80006f74 <sys_open+0x60>
    80007034:	f4c42783          	lw	a5,-180(s0)
    80007038:	dba1                	beqz	a5,80006f88 <sys_open+0x74>
      iunlockput(ip);
    8000703a:	854a                	mv	a0,s2
    8000703c:	ffffe097          	auipc	ra,0xffffe
    80007040:	1b4080e7          	jalr	436(ra) # 800051f0 <iunlockput>
      end_op();
    80007044:	fffff097          	auipc	ra,0xfffff
    80007048:	9a4080e7          	jalr	-1628(ra) # 800059e8 <end_op>
      return -1;
    8000704c:	54fd                	li	s1,-1
    8000704e:	b76d                	j	80006ff8 <sys_open+0xe4>
      end_op();
    80007050:	fffff097          	auipc	ra,0xfffff
    80007054:	998080e7          	jalr	-1640(ra) # 800059e8 <end_op>
      return -1;
    80007058:	54fd                	li	s1,-1
    8000705a:	bf79                	j	80006ff8 <sys_open+0xe4>
    iunlockput(ip);
    8000705c:	854a                	mv	a0,s2
    8000705e:	ffffe097          	auipc	ra,0xffffe
    80007062:	192080e7          	jalr	402(ra) # 800051f0 <iunlockput>
    end_op();
    80007066:	fffff097          	auipc	ra,0xfffff
    8000706a:	982080e7          	jalr	-1662(ra) # 800059e8 <end_op>
    return -1;
    8000706e:	54fd                	li	s1,-1
    80007070:	b761                	j	80006ff8 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80007072:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80007076:	04691783          	lh	a5,70(s2)
    8000707a:	02f99223          	sh	a5,36(s3)
    8000707e:	bf2d                	j	80006fb8 <sys_open+0xa4>
    itrunc(ip);
    80007080:	854a                	mv	a0,s2
    80007082:	ffffe097          	auipc	ra,0xffffe
    80007086:	01a080e7          	jalr	26(ra) # 8000509c <itrunc>
    8000708a:	bfb1                	j	80006fe6 <sys_open+0xd2>
      fileclose(f);
    8000708c:	854e                	mv	a0,s3
    8000708e:	fffff097          	auipc	ra,0xfffff
    80007092:	da4080e7          	jalr	-604(ra) # 80005e32 <fileclose>
    iunlockput(ip);
    80007096:	854a                	mv	a0,s2
    80007098:	ffffe097          	auipc	ra,0xffffe
    8000709c:	158080e7          	jalr	344(ra) # 800051f0 <iunlockput>
    end_op();
    800070a0:	fffff097          	auipc	ra,0xfffff
    800070a4:	948080e7          	jalr	-1720(ra) # 800059e8 <end_op>
    return -1;
    800070a8:	54fd                	li	s1,-1
    800070aa:	b7b9                	j	80006ff8 <sys_open+0xe4>

00000000800070ac <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800070ac:	7175                	addi	sp,sp,-144
    800070ae:	e506                	sd	ra,136(sp)
    800070b0:	e122                	sd	s0,128(sp)
    800070b2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800070b4:	fffff097          	auipc	ra,0xfffff
    800070b8:	8b6080e7          	jalr	-1866(ra) # 8000596a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800070bc:	08000613          	li	a2,128
    800070c0:	f7040593          	addi	a1,s0,-144
    800070c4:	4501                	li	a0,0
    800070c6:	ffffd097          	auipc	ra,0xffffd
    800070ca:	b58080e7          	jalr	-1192(ra) # 80003c1e <argstr>
    800070ce:	02054963          	bltz	a0,80007100 <sys_mkdir+0x54>
    800070d2:	4681                	li	a3,0
    800070d4:	4601                	li	a2,0
    800070d6:	4585                	li	a1,1
    800070d8:	f7040513          	addi	a0,s0,-144
    800070dc:	fffff097          	auipc	ra,0xfffff
    800070e0:	7fc080e7          	jalr	2044(ra) # 800068d8 <create>
    800070e4:	cd11                	beqz	a0,80007100 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800070e6:	ffffe097          	auipc	ra,0xffffe
    800070ea:	10a080e7          	jalr	266(ra) # 800051f0 <iunlockput>
  end_op();
    800070ee:	fffff097          	auipc	ra,0xfffff
    800070f2:	8fa080e7          	jalr	-1798(ra) # 800059e8 <end_op>
  return 0;
    800070f6:	4501                	li	a0,0
}
    800070f8:	60aa                	ld	ra,136(sp)
    800070fa:	640a                	ld	s0,128(sp)
    800070fc:	6149                	addi	sp,sp,144
    800070fe:	8082                	ret
    end_op();
    80007100:	fffff097          	auipc	ra,0xfffff
    80007104:	8e8080e7          	jalr	-1816(ra) # 800059e8 <end_op>
    return -1;
    80007108:	557d                	li	a0,-1
    8000710a:	b7fd                	j	800070f8 <sys_mkdir+0x4c>

000000008000710c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000710c:	7135                	addi	sp,sp,-160
    8000710e:	ed06                	sd	ra,152(sp)
    80007110:	e922                	sd	s0,144(sp)
    80007112:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80007114:	fffff097          	auipc	ra,0xfffff
    80007118:	856080e7          	jalr	-1962(ra) # 8000596a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000711c:	08000613          	li	a2,128
    80007120:	f7040593          	addi	a1,s0,-144
    80007124:	4501                	li	a0,0
    80007126:	ffffd097          	auipc	ra,0xffffd
    8000712a:	af8080e7          	jalr	-1288(ra) # 80003c1e <argstr>
    8000712e:	04054a63          	bltz	a0,80007182 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80007132:	f6c40593          	addi	a1,s0,-148
    80007136:	4505                	li	a0,1
    80007138:	ffffd097          	auipc	ra,0xffffd
    8000713c:	aa2080e7          	jalr	-1374(ra) # 80003bda <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80007140:	04054163          	bltz	a0,80007182 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80007144:	f6840593          	addi	a1,s0,-152
    80007148:	4509                	li	a0,2
    8000714a:	ffffd097          	auipc	ra,0xffffd
    8000714e:	a90080e7          	jalr	-1392(ra) # 80003bda <argint>
     argint(1, &major) < 0 ||
    80007152:	02054863          	bltz	a0,80007182 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80007156:	f6841683          	lh	a3,-152(s0)
    8000715a:	f6c41603          	lh	a2,-148(s0)
    8000715e:	458d                	li	a1,3
    80007160:	f7040513          	addi	a0,s0,-144
    80007164:	fffff097          	auipc	ra,0xfffff
    80007168:	774080e7          	jalr	1908(ra) # 800068d8 <create>
     argint(2, &minor) < 0 ||
    8000716c:	c919                	beqz	a0,80007182 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000716e:	ffffe097          	auipc	ra,0xffffe
    80007172:	082080e7          	jalr	130(ra) # 800051f0 <iunlockput>
  end_op();
    80007176:	fffff097          	auipc	ra,0xfffff
    8000717a:	872080e7          	jalr	-1934(ra) # 800059e8 <end_op>
  return 0;
    8000717e:	4501                	li	a0,0
    80007180:	a031                	j	8000718c <sys_mknod+0x80>
    end_op();
    80007182:	fffff097          	auipc	ra,0xfffff
    80007186:	866080e7          	jalr	-1946(ra) # 800059e8 <end_op>
    return -1;
    8000718a:	557d                	li	a0,-1
}
    8000718c:	60ea                	ld	ra,152(sp)
    8000718e:	644a                	ld	s0,144(sp)
    80007190:	610d                	addi	sp,sp,160
    80007192:	8082                	ret

0000000080007194 <sys_chdir>:

uint64
sys_chdir(void)
{
    80007194:	7135                	addi	sp,sp,-160
    80007196:	ed06                	sd	ra,152(sp)
    80007198:	e922                	sd	s0,144(sp)
    8000719a:	e526                	sd	s1,136(sp)
    8000719c:	e14a                	sd	s2,128(sp)
    8000719e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800071a0:	ffffb097          	auipc	ra,0xffffb
    800071a4:	81a080e7          	jalr	-2022(ra) # 800019ba <myproc>
    800071a8:	892a                	mv	s2,a0
  
  begin_op();
    800071aa:	ffffe097          	auipc	ra,0xffffe
    800071ae:	7c0080e7          	jalr	1984(ra) # 8000596a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800071b2:	08000613          	li	a2,128
    800071b6:	f6040593          	addi	a1,s0,-160
    800071ba:	4501                	li	a0,0
    800071bc:	ffffd097          	auipc	ra,0xffffd
    800071c0:	a62080e7          	jalr	-1438(ra) # 80003c1e <argstr>
    800071c4:	04054b63          	bltz	a0,8000721a <sys_chdir+0x86>
    800071c8:	f6040513          	addi	a0,s0,-160
    800071cc:	ffffe097          	auipc	ra,0xffffe
    800071d0:	57e080e7          	jalr	1406(ra) # 8000574a <namei>
    800071d4:	84aa                	mv	s1,a0
    800071d6:	c131                	beqz	a0,8000721a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800071d8:	ffffe097          	auipc	ra,0xffffe
    800071dc:	db6080e7          	jalr	-586(ra) # 80004f8e <ilock>
  if(ip->type != T_DIR){
    800071e0:	04449703          	lh	a4,68(s1)
    800071e4:	4785                	li	a5,1
    800071e6:	04f71063          	bne	a4,a5,80007226 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800071ea:	8526                	mv	a0,s1
    800071ec:	ffffe097          	auipc	ra,0xffffe
    800071f0:	e64080e7          	jalr	-412(ra) # 80005050 <iunlock>
  iput(p->cwd);
    800071f4:	15893503          	ld	a0,344(s2)
    800071f8:	ffffe097          	auipc	ra,0xffffe
    800071fc:	f50080e7          	jalr	-176(ra) # 80005148 <iput>
  end_op();
    80007200:	ffffe097          	auipc	ra,0xffffe
    80007204:	7e8080e7          	jalr	2024(ra) # 800059e8 <end_op>
  p->cwd = ip;
    80007208:	14993c23          	sd	s1,344(s2)
  return 0;
    8000720c:	4501                	li	a0,0
}
    8000720e:	60ea                	ld	ra,152(sp)
    80007210:	644a                	ld	s0,144(sp)
    80007212:	64aa                	ld	s1,136(sp)
    80007214:	690a                	ld	s2,128(sp)
    80007216:	610d                	addi	sp,sp,160
    80007218:	8082                	ret
    end_op();
    8000721a:	ffffe097          	auipc	ra,0xffffe
    8000721e:	7ce080e7          	jalr	1998(ra) # 800059e8 <end_op>
    return -1;
    80007222:	557d                	li	a0,-1
    80007224:	b7ed                	j	8000720e <sys_chdir+0x7a>
    iunlockput(ip);
    80007226:	8526                	mv	a0,s1
    80007228:	ffffe097          	auipc	ra,0xffffe
    8000722c:	fc8080e7          	jalr	-56(ra) # 800051f0 <iunlockput>
    end_op();
    80007230:	ffffe097          	auipc	ra,0xffffe
    80007234:	7b8080e7          	jalr	1976(ra) # 800059e8 <end_op>
    return -1;
    80007238:	557d                	li	a0,-1
    8000723a:	bfd1                	j	8000720e <sys_chdir+0x7a>

000000008000723c <sys_exec>:

uint64
sys_exec(void)
{
    8000723c:	7145                	addi	sp,sp,-464
    8000723e:	e786                	sd	ra,456(sp)
    80007240:	e3a2                	sd	s0,448(sp)
    80007242:	ff26                	sd	s1,440(sp)
    80007244:	fb4a                	sd	s2,432(sp)
    80007246:	f74e                	sd	s3,424(sp)
    80007248:	f352                	sd	s4,416(sp)
    8000724a:	ef56                	sd	s5,408(sp)
    8000724c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000724e:	08000613          	li	a2,128
    80007252:	f4040593          	addi	a1,s0,-192
    80007256:	4501                	li	a0,0
    80007258:	ffffd097          	auipc	ra,0xffffd
    8000725c:	9c6080e7          	jalr	-1594(ra) # 80003c1e <argstr>
    return -1;
    80007260:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80007262:	0c054b63          	bltz	a0,80007338 <sys_exec+0xfc>
    80007266:	e3840593          	addi	a1,s0,-456
    8000726a:	4505                	li	a0,1
    8000726c:	ffffd097          	auipc	ra,0xffffd
    80007270:	990080e7          	jalr	-1648(ra) # 80003bfc <argaddr>
    80007274:	0c054263          	bltz	a0,80007338 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80007278:	10000613          	li	a2,256
    8000727c:	4581                	li	a1,0
    8000727e:	e4040513          	addi	a0,s0,-448
    80007282:	ffffa097          	auipc	ra,0xffffa
    80007286:	a48080e7          	jalr	-1464(ra) # 80000cca <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000728a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000728e:	89a6                	mv	s3,s1
    80007290:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80007292:	02000a13          	li	s4,32
    80007296:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000729a:	00391513          	slli	a0,s2,0x3
    8000729e:	e3040593          	addi	a1,s0,-464
    800072a2:	e3843783          	ld	a5,-456(s0)
    800072a6:	953e                	add	a0,a0,a5
    800072a8:	ffffd097          	auipc	ra,0xffffd
    800072ac:	898080e7          	jalr	-1896(ra) # 80003b40 <fetchaddr>
    800072b0:	02054a63          	bltz	a0,800072e4 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800072b4:	e3043783          	ld	a5,-464(s0)
    800072b8:	c3b9                	beqz	a5,800072fe <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800072ba:	ffffa097          	auipc	ra,0xffffa
    800072be:	824080e7          	jalr	-2012(ra) # 80000ade <kalloc>
    800072c2:	85aa                	mv	a1,a0
    800072c4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800072c8:	cd11                	beqz	a0,800072e4 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800072ca:	6605                	lui	a2,0x1
    800072cc:	e3043503          	ld	a0,-464(s0)
    800072d0:	ffffd097          	auipc	ra,0xffffd
    800072d4:	8c2080e7          	jalr	-1854(ra) # 80003b92 <fetchstr>
    800072d8:	00054663          	bltz	a0,800072e4 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800072dc:	0905                	addi	s2,s2,1
    800072de:	09a1                	addi	s3,s3,8
    800072e0:	fb491be3          	bne	s2,s4,80007296 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800072e4:	f4040913          	addi	s2,s0,-192
    800072e8:	6088                	ld	a0,0(s1)
    800072ea:	c531                	beqz	a0,80007336 <sys_exec+0xfa>
    kfree(argv[i]);
    800072ec:	ffff9097          	auipc	ra,0xffff9
    800072f0:	6f4080e7          	jalr	1780(ra) # 800009e0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800072f4:	04a1                	addi	s1,s1,8
    800072f6:	ff2499e3          	bne	s1,s2,800072e8 <sys_exec+0xac>
  return -1;
    800072fa:	597d                	li	s2,-1
    800072fc:	a835                	j	80007338 <sys_exec+0xfc>
      argv[i] = 0;
    800072fe:	0a8e                	slli	s5,s5,0x3
    80007300:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd6fc0>
    80007304:	00878ab3          	add	s5,a5,s0
    80007308:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000730c:	e4040593          	addi	a1,s0,-448
    80007310:	f4040513          	addi	a0,s0,-192
    80007314:	fffff097          	auipc	ra,0xfffff
    80007318:	172080e7          	jalr	370(ra) # 80006486 <exec>
    8000731c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000731e:	f4040993          	addi	s3,s0,-192
    80007322:	6088                	ld	a0,0(s1)
    80007324:	c911                	beqz	a0,80007338 <sys_exec+0xfc>
    kfree(argv[i]);
    80007326:	ffff9097          	auipc	ra,0xffff9
    8000732a:	6ba080e7          	jalr	1722(ra) # 800009e0 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000732e:	04a1                	addi	s1,s1,8
    80007330:	ff3499e3          	bne	s1,s3,80007322 <sys_exec+0xe6>
    80007334:	a011                	j	80007338 <sys_exec+0xfc>
  return -1;
    80007336:	597d                	li	s2,-1
}
    80007338:	854a                	mv	a0,s2
    8000733a:	60be                	ld	ra,456(sp)
    8000733c:	641e                	ld	s0,448(sp)
    8000733e:	74fa                	ld	s1,440(sp)
    80007340:	795a                	ld	s2,432(sp)
    80007342:	79ba                	ld	s3,424(sp)
    80007344:	7a1a                	ld	s4,416(sp)
    80007346:	6afa                	ld	s5,408(sp)
    80007348:	6179                	addi	sp,sp,464
    8000734a:	8082                	ret

000000008000734c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000734c:	7139                	addi	sp,sp,-64
    8000734e:	fc06                	sd	ra,56(sp)
    80007350:	f822                	sd	s0,48(sp)
    80007352:	f426                	sd	s1,40(sp)
    80007354:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80007356:	ffffa097          	auipc	ra,0xffffa
    8000735a:	664080e7          	jalr	1636(ra) # 800019ba <myproc>
    8000735e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80007360:	fd840593          	addi	a1,s0,-40
    80007364:	4501                	li	a0,0
    80007366:	ffffd097          	auipc	ra,0xffffd
    8000736a:	896080e7          	jalr	-1898(ra) # 80003bfc <argaddr>
    return -1;
    8000736e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80007370:	0e054063          	bltz	a0,80007450 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80007374:	fc840593          	addi	a1,s0,-56
    80007378:	fd040513          	addi	a0,s0,-48
    8000737c:	fffff097          	auipc	ra,0xfffff
    80007380:	de6080e7          	jalr	-538(ra) # 80006162 <pipealloc>
    return -1;
    80007384:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80007386:	0c054563          	bltz	a0,80007450 <sys_pipe+0x104>
  fd0 = -1;
    8000738a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000738e:	fd043503          	ld	a0,-48(s0)
    80007392:	fffff097          	auipc	ra,0xfffff
    80007396:	504080e7          	jalr	1284(ra) # 80006896 <fdalloc>
    8000739a:	fca42223          	sw	a0,-60(s0)
    8000739e:	08054c63          	bltz	a0,80007436 <sys_pipe+0xea>
    800073a2:	fc843503          	ld	a0,-56(s0)
    800073a6:	fffff097          	auipc	ra,0xfffff
    800073aa:	4f0080e7          	jalr	1264(ra) # 80006896 <fdalloc>
    800073ae:	fca42023          	sw	a0,-64(s0)
    800073b2:	06054963          	bltz	a0,80007424 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800073b6:	4691                	li	a3,4
    800073b8:	fc440613          	addi	a2,s0,-60
    800073bc:	fd843583          	ld	a1,-40(s0)
    800073c0:	6ca8                	ld	a0,88(s1)
    800073c2:	ffffa097          	auipc	ra,0xffffa
    800073c6:	2bc080e7          	jalr	700(ra) # 8000167e <copyout>
    800073ca:	02054063          	bltz	a0,800073ea <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800073ce:	4691                	li	a3,4
    800073d0:	fc040613          	addi	a2,s0,-64
    800073d4:	fd843583          	ld	a1,-40(s0)
    800073d8:	0591                	addi	a1,a1,4
    800073da:	6ca8                	ld	a0,88(s1)
    800073dc:	ffffa097          	auipc	ra,0xffffa
    800073e0:	2a2080e7          	jalr	674(ra) # 8000167e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800073e4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800073e6:	06055563          	bgez	a0,80007450 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800073ea:	fc442783          	lw	a5,-60(s0)
    800073ee:	07e9                	addi	a5,a5,26
    800073f0:	078e                	slli	a5,a5,0x3
    800073f2:	97a6                	add	a5,a5,s1
    800073f4:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800073f8:	fc042783          	lw	a5,-64(s0)
    800073fc:	07e9                	addi	a5,a5,26
    800073fe:	078e                	slli	a5,a5,0x3
    80007400:	00f48533          	add	a0,s1,a5
    80007404:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80007408:	fd043503          	ld	a0,-48(s0)
    8000740c:	fffff097          	auipc	ra,0xfffff
    80007410:	a26080e7          	jalr	-1498(ra) # 80005e32 <fileclose>
    fileclose(wf);
    80007414:	fc843503          	ld	a0,-56(s0)
    80007418:	fffff097          	auipc	ra,0xfffff
    8000741c:	a1a080e7          	jalr	-1510(ra) # 80005e32 <fileclose>
    return -1;
    80007420:	57fd                	li	a5,-1
    80007422:	a03d                	j	80007450 <sys_pipe+0x104>
    if(fd0 >= 0)
    80007424:	fc442783          	lw	a5,-60(s0)
    80007428:	0007c763          	bltz	a5,80007436 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    8000742c:	07e9                	addi	a5,a5,26
    8000742e:	078e                	slli	a5,a5,0x3
    80007430:	97a6                	add	a5,a5,s1
    80007432:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80007436:	fd043503          	ld	a0,-48(s0)
    8000743a:	fffff097          	auipc	ra,0xfffff
    8000743e:	9f8080e7          	jalr	-1544(ra) # 80005e32 <fileclose>
    fileclose(wf);
    80007442:	fc843503          	ld	a0,-56(s0)
    80007446:	fffff097          	auipc	ra,0xfffff
    8000744a:	9ec080e7          	jalr	-1556(ra) # 80005e32 <fileclose>
    return -1;
    8000744e:	57fd                	li	a5,-1
}
    80007450:	853e                	mv	a0,a5
    80007452:	70e2                	ld	ra,56(sp)
    80007454:	7442                	ld	s0,48(sp)
    80007456:	74a2                	ld	s1,40(sp)
    80007458:	6121                	addi	sp,sp,64
    8000745a:	8082                	ret
    8000745c:	0000                	unimp
	...

0000000080007460 <kernelvec>:
    80007460:	7111                	addi	sp,sp,-256
    80007462:	e006                	sd	ra,0(sp)
    80007464:	e40a                	sd	sp,8(sp)
    80007466:	e80e                	sd	gp,16(sp)
    80007468:	ec12                	sd	tp,24(sp)
    8000746a:	f016                	sd	t0,32(sp)
    8000746c:	f41a                	sd	t1,40(sp)
    8000746e:	f81e                	sd	t2,48(sp)
    80007470:	fc22                	sd	s0,56(sp)
    80007472:	e0a6                	sd	s1,64(sp)
    80007474:	e4aa                	sd	a0,72(sp)
    80007476:	e8ae                	sd	a1,80(sp)
    80007478:	ecb2                	sd	a2,88(sp)
    8000747a:	f0b6                	sd	a3,96(sp)
    8000747c:	f4ba                	sd	a4,104(sp)
    8000747e:	f8be                	sd	a5,112(sp)
    80007480:	fcc2                	sd	a6,120(sp)
    80007482:	e146                	sd	a7,128(sp)
    80007484:	e54a                	sd	s2,136(sp)
    80007486:	e94e                	sd	s3,144(sp)
    80007488:	ed52                	sd	s4,152(sp)
    8000748a:	f156                	sd	s5,160(sp)
    8000748c:	f55a                	sd	s6,168(sp)
    8000748e:	f95e                	sd	s7,176(sp)
    80007490:	fd62                	sd	s8,184(sp)
    80007492:	e1e6                	sd	s9,192(sp)
    80007494:	e5ea                	sd	s10,200(sp)
    80007496:	e9ee                	sd	s11,208(sp)
    80007498:	edf2                	sd	t3,216(sp)
    8000749a:	f1f6                	sd	t4,224(sp)
    8000749c:	f5fa                	sd	t5,232(sp)
    8000749e:	f9fe                	sd	t6,240(sp)
    800074a0:	d5efc0ef          	jal	ra,800039fe <kerneltrap>
    800074a4:	6082                	ld	ra,0(sp)
    800074a6:	6122                	ld	sp,8(sp)
    800074a8:	61c2                	ld	gp,16(sp)
    800074aa:	7282                	ld	t0,32(sp)
    800074ac:	7322                	ld	t1,40(sp)
    800074ae:	73c2                	ld	t2,48(sp)
    800074b0:	7462                	ld	s0,56(sp)
    800074b2:	6486                	ld	s1,64(sp)
    800074b4:	6526                	ld	a0,72(sp)
    800074b6:	65c6                	ld	a1,80(sp)
    800074b8:	6666                	ld	a2,88(sp)
    800074ba:	7686                	ld	a3,96(sp)
    800074bc:	7726                	ld	a4,104(sp)
    800074be:	77c6                	ld	a5,112(sp)
    800074c0:	7866                	ld	a6,120(sp)
    800074c2:	688a                	ld	a7,128(sp)
    800074c4:	692a                	ld	s2,136(sp)
    800074c6:	69ca                	ld	s3,144(sp)
    800074c8:	6a6a                	ld	s4,152(sp)
    800074ca:	7a8a                	ld	s5,160(sp)
    800074cc:	7b2a                	ld	s6,168(sp)
    800074ce:	7bca                	ld	s7,176(sp)
    800074d0:	7c6a                	ld	s8,184(sp)
    800074d2:	6c8e                	ld	s9,192(sp)
    800074d4:	6d2e                	ld	s10,200(sp)
    800074d6:	6dce                	ld	s11,208(sp)
    800074d8:	6e6e                	ld	t3,216(sp)
    800074da:	7e8e                	ld	t4,224(sp)
    800074dc:	7f2e                	ld	t5,232(sp)
    800074de:	7fce                	ld	t6,240(sp)
    800074e0:	6111                	addi	sp,sp,256
    800074e2:	10200073          	sret
    800074e6:	00000013          	nop
    800074ea:	00000013          	nop
    800074ee:	0001                	nop

00000000800074f0 <timervec>:
    800074f0:	34051573          	csrrw	a0,mscratch,a0
    800074f4:	e10c                	sd	a1,0(a0)
    800074f6:	e510                	sd	a2,8(a0)
    800074f8:	e914                	sd	a3,16(a0)
    800074fa:	6d0c                	ld	a1,24(a0)
    800074fc:	7110                	ld	a2,32(a0)
    800074fe:	6194                	ld	a3,0(a1)
    80007500:	96b2                	add	a3,a3,a2
    80007502:	e194                	sd	a3,0(a1)
    80007504:	4589                	li	a1,2
    80007506:	14459073          	csrw	sip,a1
    8000750a:	6914                	ld	a3,16(a0)
    8000750c:	6510                	ld	a2,8(a0)
    8000750e:	610c                	ld	a1,0(a0)
    80007510:	34051573          	csrrw	a0,mscratch,a0
    80007514:	30200073          	mret
	...

000000008000751a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000751a:	1141                	addi	sp,sp,-16
    8000751c:	e422                	sd	s0,8(sp)
    8000751e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80007520:	0c0007b7          	lui	a5,0xc000
    80007524:	4705                	li	a4,1
    80007526:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80007528:	c3d8                	sw	a4,4(a5)
}
    8000752a:	6422                	ld	s0,8(sp)
    8000752c:	0141                	addi	sp,sp,16
    8000752e:	8082                	ret

0000000080007530 <plicinithart>:

void
plicinithart(void)
{
    80007530:	1141                	addi	sp,sp,-16
    80007532:	e406                	sd	ra,8(sp)
    80007534:	e022                	sd	s0,0(sp)
    80007536:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80007538:	ffffa097          	auipc	ra,0xffffa
    8000753c:	456080e7          	jalr	1110(ra) # 8000198e <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80007540:	0085171b          	slliw	a4,a0,0x8
    80007544:	0c0027b7          	lui	a5,0xc002
    80007548:	97ba                	add	a5,a5,a4
    8000754a:	40200713          	li	a4,1026
    8000754e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80007552:	00d5151b          	slliw	a0,a0,0xd
    80007556:	0c2017b7          	lui	a5,0xc201
    8000755a:	97aa                	add	a5,a5,a0
    8000755c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80007560:	60a2                	ld	ra,8(sp)
    80007562:	6402                	ld	s0,0(sp)
    80007564:	0141                	addi	sp,sp,16
    80007566:	8082                	ret

0000000080007568 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80007568:	1141                	addi	sp,sp,-16
    8000756a:	e406                	sd	ra,8(sp)
    8000756c:	e022                	sd	s0,0(sp)
    8000756e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80007570:	ffffa097          	auipc	ra,0xffffa
    80007574:	41e080e7          	jalr	1054(ra) # 8000198e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80007578:	00d5151b          	slliw	a0,a0,0xd
    8000757c:	0c2017b7          	lui	a5,0xc201
    80007580:	97aa                	add	a5,a5,a0
  return irq;
}
    80007582:	43c8                	lw	a0,4(a5)
    80007584:	60a2                	ld	ra,8(sp)
    80007586:	6402                	ld	s0,0(sp)
    80007588:	0141                	addi	sp,sp,16
    8000758a:	8082                	ret

000000008000758c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000758c:	1101                	addi	sp,sp,-32
    8000758e:	ec06                	sd	ra,24(sp)
    80007590:	e822                	sd	s0,16(sp)
    80007592:	e426                	sd	s1,8(sp)
    80007594:	1000                	addi	s0,sp,32
    80007596:	84aa                	mv	s1,a0
  int hart = cpuid();
    80007598:	ffffa097          	auipc	ra,0xffffa
    8000759c:	3f6080e7          	jalr	1014(ra) # 8000198e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800075a0:	00d5151b          	slliw	a0,a0,0xd
    800075a4:	0c2017b7          	lui	a5,0xc201
    800075a8:	97aa                	add	a5,a5,a0
    800075aa:	c3c4                	sw	s1,4(a5)
}
    800075ac:	60e2                	ld	ra,24(sp)
    800075ae:	6442                	ld	s0,16(sp)
    800075b0:	64a2                	ld	s1,8(sp)
    800075b2:	6105                	addi	sp,sp,32
    800075b4:	8082                	ret

00000000800075b6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800075b6:	1141                	addi	sp,sp,-16
    800075b8:	e406                	sd	ra,8(sp)
    800075ba:	e022                	sd	s0,0(sp)
    800075bc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800075be:	479d                	li	a5,7
    800075c0:	06a7c863          	blt	a5,a0,80007630 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    800075c4:	0001e717          	auipc	a4,0x1e
    800075c8:	a3c70713          	addi	a4,a4,-1476 # 80025000 <disk>
    800075cc:	972a                	add	a4,a4,a0
    800075ce:	6789                	lui	a5,0x2
    800075d0:	97ba                	add	a5,a5,a4
    800075d2:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800075d6:	e7ad                	bnez	a5,80007640 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800075d8:	00451793          	slli	a5,a0,0x4
    800075dc:	00020717          	auipc	a4,0x20
    800075e0:	a2470713          	addi	a4,a4,-1500 # 80027000 <disk+0x2000>
    800075e4:	6314                	ld	a3,0(a4)
    800075e6:	96be                	add	a3,a3,a5
    800075e8:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800075ec:	6314                	ld	a3,0(a4)
    800075ee:	96be                	add	a3,a3,a5
    800075f0:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800075f4:	6314                	ld	a3,0(a4)
    800075f6:	96be                	add	a3,a3,a5
    800075f8:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800075fc:	6318                	ld	a4,0(a4)
    800075fe:	97ba                	add	a5,a5,a4
    80007600:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80007604:	0001e717          	auipc	a4,0x1e
    80007608:	9fc70713          	addi	a4,a4,-1540 # 80025000 <disk>
    8000760c:	972a                	add	a4,a4,a0
    8000760e:	6789                	lui	a5,0x2
    80007610:	97ba                	add	a5,a5,a4
    80007612:	4705                	li	a4,1
    80007614:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80007618:	00020517          	auipc	a0,0x20
    8000761c:	a0050513          	addi	a0,a0,-1536 # 80027018 <disk+0x2018>
    80007620:	ffffb097          	auipc	ra,0xffffb
    80007624:	550080e7          	jalr	1360(ra) # 80002b70 <wakeup>
}
    80007628:	60a2                	ld	ra,8(sp)
    8000762a:	6402                	ld	s0,0(sp)
    8000762c:	0141                	addi	sp,sp,16
    8000762e:	8082                	ret
    panic("free_desc 1");
    80007630:	00002517          	auipc	a0,0x2
    80007634:	48050513          	addi	a0,a0,1152 # 80009ab0 <syscalls+0x470>
    80007638:	ffff9097          	auipc	ra,0xffff9
    8000763c:	f00080e7          	jalr	-256(ra) # 80000538 <panic>
    panic("free_desc 2");
    80007640:	00002517          	auipc	a0,0x2
    80007644:	48050513          	addi	a0,a0,1152 # 80009ac0 <syscalls+0x480>
    80007648:	ffff9097          	auipc	ra,0xffff9
    8000764c:	ef0080e7          	jalr	-272(ra) # 80000538 <panic>

0000000080007650 <virtio_disk_init>:
{
    80007650:	1101                	addi	sp,sp,-32
    80007652:	ec06                	sd	ra,24(sp)
    80007654:	e822                	sd	s0,16(sp)
    80007656:	e426                	sd	s1,8(sp)
    80007658:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000765a:	00002597          	auipc	a1,0x2
    8000765e:	47658593          	addi	a1,a1,1142 # 80009ad0 <syscalls+0x490>
    80007662:	00020517          	auipc	a0,0x20
    80007666:	ac650513          	addi	a0,a0,-1338 # 80027128 <disk+0x2128>
    8000766a:	ffff9097          	auipc	ra,0xffff9
    8000766e:	4d4080e7          	jalr	1236(ra) # 80000b3e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80007672:	100017b7          	lui	a5,0x10001
    80007676:	4398                	lw	a4,0(a5)
    80007678:	2701                	sext.w	a4,a4
    8000767a:	747277b7          	lui	a5,0x74727
    8000767e:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80007682:	0ef71063          	bne	a4,a5,80007762 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80007686:	100017b7          	lui	a5,0x10001
    8000768a:	43dc                	lw	a5,4(a5)
    8000768c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000768e:	4705                	li	a4,1
    80007690:	0ce79963          	bne	a5,a4,80007762 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80007694:	100017b7          	lui	a5,0x10001
    80007698:	479c                	lw	a5,8(a5)
    8000769a:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000769c:	4709                	li	a4,2
    8000769e:	0ce79263          	bne	a5,a4,80007762 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800076a2:	100017b7          	lui	a5,0x10001
    800076a6:	47d8                	lw	a4,12(a5)
    800076a8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800076aa:	554d47b7          	lui	a5,0x554d4
    800076ae:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800076b2:	0af71863          	bne	a4,a5,80007762 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    800076b6:	100017b7          	lui	a5,0x10001
    800076ba:	4705                	li	a4,1
    800076bc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800076be:	470d                	li	a4,3
    800076c0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800076c2:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800076c4:	c7ffe6b7          	lui	a3,0xc7ffe
    800076c8:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd675f>
    800076cc:	8f75                	and	a4,a4,a3
    800076ce:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800076d0:	472d                	li	a4,11
    800076d2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800076d4:	473d                	li	a4,15
    800076d6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800076d8:	6705                	lui	a4,0x1
    800076da:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800076dc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800076e0:	5bdc                	lw	a5,52(a5)
    800076e2:	2781                	sext.w	a5,a5
  if(max == 0)
    800076e4:	c7d9                	beqz	a5,80007772 <virtio_disk_init+0x122>
  if(max < NUM)
    800076e6:	471d                	li	a4,7
    800076e8:	08f77d63          	bgeu	a4,a5,80007782 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800076ec:	100014b7          	lui	s1,0x10001
    800076f0:	47a1                	li	a5,8
    800076f2:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800076f4:	6609                	lui	a2,0x2
    800076f6:	4581                	li	a1,0
    800076f8:	0001e517          	auipc	a0,0x1e
    800076fc:	90850513          	addi	a0,a0,-1784 # 80025000 <disk>
    80007700:	ffff9097          	auipc	ra,0xffff9
    80007704:	5ca080e7          	jalr	1482(ra) # 80000cca <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80007708:	0001e717          	auipc	a4,0x1e
    8000770c:	8f870713          	addi	a4,a4,-1800 # 80025000 <disk>
    80007710:	00c75793          	srli	a5,a4,0xc
    80007714:	2781                	sext.w	a5,a5
    80007716:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80007718:	00020797          	auipc	a5,0x20
    8000771c:	8e878793          	addi	a5,a5,-1816 # 80027000 <disk+0x2000>
    80007720:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80007722:	0001e717          	auipc	a4,0x1e
    80007726:	95e70713          	addi	a4,a4,-1698 # 80025080 <disk+0x80>
    8000772a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000772c:	0001f717          	auipc	a4,0x1f
    80007730:	8d470713          	addi	a4,a4,-1836 # 80026000 <disk+0x1000>
    80007734:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80007736:	4705                	li	a4,1
    80007738:	00e78c23          	sb	a4,24(a5)
    8000773c:	00e78ca3          	sb	a4,25(a5)
    80007740:	00e78d23          	sb	a4,26(a5)
    80007744:	00e78da3          	sb	a4,27(a5)
    80007748:	00e78e23          	sb	a4,28(a5)
    8000774c:	00e78ea3          	sb	a4,29(a5)
    80007750:	00e78f23          	sb	a4,30(a5)
    80007754:	00e78fa3          	sb	a4,31(a5)
}
    80007758:	60e2                	ld	ra,24(sp)
    8000775a:	6442                	ld	s0,16(sp)
    8000775c:	64a2                	ld	s1,8(sp)
    8000775e:	6105                	addi	sp,sp,32
    80007760:	8082                	ret
    panic("could not find virtio disk");
    80007762:	00002517          	auipc	a0,0x2
    80007766:	37e50513          	addi	a0,a0,894 # 80009ae0 <syscalls+0x4a0>
    8000776a:	ffff9097          	auipc	ra,0xffff9
    8000776e:	dce080e7          	jalr	-562(ra) # 80000538 <panic>
    panic("virtio disk has no queue 0");
    80007772:	00002517          	auipc	a0,0x2
    80007776:	38e50513          	addi	a0,a0,910 # 80009b00 <syscalls+0x4c0>
    8000777a:	ffff9097          	auipc	ra,0xffff9
    8000777e:	dbe080e7          	jalr	-578(ra) # 80000538 <panic>
    panic("virtio disk max queue too short");
    80007782:	00002517          	auipc	a0,0x2
    80007786:	39e50513          	addi	a0,a0,926 # 80009b20 <syscalls+0x4e0>
    8000778a:	ffff9097          	auipc	ra,0xffff9
    8000778e:	dae080e7          	jalr	-594(ra) # 80000538 <panic>

0000000080007792 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80007792:	7119                	addi	sp,sp,-128
    80007794:	fc86                	sd	ra,120(sp)
    80007796:	f8a2                	sd	s0,112(sp)
    80007798:	f4a6                	sd	s1,104(sp)
    8000779a:	f0ca                	sd	s2,96(sp)
    8000779c:	ecce                	sd	s3,88(sp)
    8000779e:	e8d2                	sd	s4,80(sp)
    800077a0:	e4d6                	sd	s5,72(sp)
    800077a2:	e0da                	sd	s6,64(sp)
    800077a4:	fc5e                	sd	s7,56(sp)
    800077a6:	f862                	sd	s8,48(sp)
    800077a8:	f466                	sd	s9,40(sp)
    800077aa:	f06a                	sd	s10,32(sp)
    800077ac:	ec6e                	sd	s11,24(sp)
    800077ae:	0100                	addi	s0,sp,128
    800077b0:	8aaa                	mv	s5,a0
    800077b2:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800077b4:	00c52c83          	lw	s9,12(a0)
    800077b8:	001c9c9b          	slliw	s9,s9,0x1
    800077bc:	1c82                	slli	s9,s9,0x20
    800077be:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800077c2:	00020517          	auipc	a0,0x20
    800077c6:	96650513          	addi	a0,a0,-1690 # 80027128 <disk+0x2128>
    800077ca:	ffff9097          	auipc	ra,0xffff9
    800077ce:	404080e7          	jalr	1028(ra) # 80000bce <acquire>
  for(int i = 0; i < 3; i++){
    800077d2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800077d4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800077d6:	0001ec17          	auipc	s8,0x1e
    800077da:	82ac0c13          	addi	s8,s8,-2006 # 80025000 <disk>
    800077de:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800077e0:	4b0d                	li	s6,3
    800077e2:	a0ad                	j	8000784c <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800077e4:	00fc0733          	add	a4,s8,a5
    800077e8:	975e                	add	a4,a4,s7
    800077ea:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800077ee:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800077f0:	0207c563          	bltz	a5,8000781a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800077f4:	2905                	addiw	s2,s2,1
    800077f6:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    800077f8:	19690c63          	beq	s2,s6,80007990 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    800077fc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800077fe:	00020717          	auipc	a4,0x20
    80007802:	81a70713          	addi	a4,a4,-2022 # 80027018 <disk+0x2018>
    80007806:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80007808:	00074683          	lbu	a3,0(a4)
    8000780c:	fee1                	bnez	a3,800077e4 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    8000780e:	2785                	addiw	a5,a5,1
    80007810:	0705                	addi	a4,a4,1
    80007812:	fe979be3          	bne	a5,s1,80007808 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80007816:	57fd                	li	a5,-1
    80007818:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000781a:	01205d63          	blez	s2,80007834 <virtio_disk_rw+0xa2>
    8000781e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007820:	000a2503          	lw	a0,0(s4)
    80007824:	00000097          	auipc	ra,0x0
    80007828:	d92080e7          	jalr	-622(ra) # 800075b6 <free_desc>
      for(int j = 0; j < i; j++)
    8000782c:	2d85                	addiw	s11,s11,1
    8000782e:	0a11                	addi	s4,s4,4
    80007830:	ff2d98e3          	bne	s11,s2,80007820 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007834:	00020597          	auipc	a1,0x20
    80007838:	8f458593          	addi	a1,a1,-1804 # 80027128 <disk+0x2128>
    8000783c:	0001f517          	auipc	a0,0x1f
    80007840:	7dc50513          	addi	a0,a0,2012 # 80027018 <disk+0x2018>
    80007844:	ffffb097          	auipc	ra,0xffffb
    80007848:	f28080e7          	jalr	-216(ra) # 8000276c <sleep>
  for(int i = 0; i < 3; i++){
    8000784c:	f8040a13          	addi	s4,s0,-128
{
    80007850:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007852:	894e                	mv	s2,s3
    80007854:	b765                	j	800077fc <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80007856:	0001f697          	auipc	a3,0x1f
    8000785a:	7aa6b683          	ld	a3,1962(a3) # 80027000 <disk+0x2000>
    8000785e:	96ba                	add	a3,a3,a4
    80007860:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007864:	0001d817          	auipc	a6,0x1d
    80007868:	79c80813          	addi	a6,a6,1948 # 80025000 <disk>
    8000786c:	0001f697          	auipc	a3,0x1f
    80007870:	79468693          	addi	a3,a3,1940 # 80027000 <disk+0x2000>
    80007874:	6290                	ld	a2,0(a3)
    80007876:	963a                	add	a2,a2,a4
    80007878:	00c65583          	lhu	a1,12(a2)
    8000787c:	0015e593          	ori	a1,a1,1
    80007880:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80007884:	f8842603          	lw	a2,-120(s0)
    80007888:	628c                	ld	a1,0(a3)
    8000788a:	972e                	add	a4,a4,a1
    8000788c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007890:	20050593          	addi	a1,a0,512
    80007894:	0592                	slli	a1,a1,0x4
    80007896:	95c2                	add	a1,a1,a6
    80007898:	577d                	li	a4,-1
    8000789a:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000789e:	00461713          	slli	a4,a2,0x4
    800078a2:	6290                	ld	a2,0(a3)
    800078a4:	963a                	add	a2,a2,a4
    800078a6:	03078793          	addi	a5,a5,48
    800078aa:	97c2                	add	a5,a5,a6
    800078ac:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800078ae:	629c                	ld	a5,0(a3)
    800078b0:	97ba                	add	a5,a5,a4
    800078b2:	4605                	li	a2,1
    800078b4:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800078b6:	629c                	ld	a5,0(a3)
    800078b8:	97ba                	add	a5,a5,a4
    800078ba:	4809                	li	a6,2
    800078bc:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800078c0:	629c                	ld	a5,0(a3)
    800078c2:	97ba                	add	a5,a5,a4
    800078c4:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800078c8:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800078cc:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800078d0:	6698                	ld	a4,8(a3)
    800078d2:	00275783          	lhu	a5,2(a4)
    800078d6:	8b9d                	andi	a5,a5,7
    800078d8:	0786                	slli	a5,a5,0x1
    800078da:	973e                	add	a4,a4,a5
    800078dc:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    800078e0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800078e4:	6698                	ld	a4,8(a3)
    800078e6:	00275783          	lhu	a5,2(a4)
    800078ea:	2785                	addiw	a5,a5,1
    800078ec:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800078f0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800078f4:	100017b7          	lui	a5,0x10001
    800078f8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800078fc:	004aa783          	lw	a5,4(s5)
    80007900:	02c79163          	bne	a5,a2,80007922 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007904:	00020917          	auipc	s2,0x20
    80007908:	82490913          	addi	s2,s2,-2012 # 80027128 <disk+0x2128>
  while(b->disk == 1) {
    8000790c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000790e:	85ca                	mv	a1,s2
    80007910:	8556                	mv	a0,s5
    80007912:	ffffb097          	auipc	ra,0xffffb
    80007916:	e5a080e7          	jalr	-422(ra) # 8000276c <sleep>
  while(b->disk == 1) {
    8000791a:	004aa783          	lw	a5,4(s5)
    8000791e:	fe9788e3          	beq	a5,s1,8000790e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007922:	f8042903          	lw	s2,-128(s0)
    80007926:	20090713          	addi	a4,s2,512
    8000792a:	0712                	slli	a4,a4,0x4
    8000792c:	0001d797          	auipc	a5,0x1d
    80007930:	6d478793          	addi	a5,a5,1748 # 80025000 <disk>
    80007934:	97ba                	add	a5,a5,a4
    80007936:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000793a:	0001f997          	auipc	s3,0x1f
    8000793e:	6c698993          	addi	s3,s3,1734 # 80027000 <disk+0x2000>
    80007942:	00491713          	slli	a4,s2,0x4
    80007946:	0009b783          	ld	a5,0(s3)
    8000794a:	97ba                	add	a5,a5,a4
    8000794c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007950:	854a                	mv	a0,s2
    80007952:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80007956:	00000097          	auipc	ra,0x0
    8000795a:	c60080e7          	jalr	-928(ra) # 800075b6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000795e:	8885                	andi	s1,s1,1
    80007960:	f0ed                	bnez	s1,80007942 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007962:	0001f517          	auipc	a0,0x1f
    80007966:	7c650513          	addi	a0,a0,1990 # 80027128 <disk+0x2128>
    8000796a:	ffff9097          	auipc	ra,0xffff9
    8000796e:	318080e7          	jalr	792(ra) # 80000c82 <release>
}
    80007972:	70e6                	ld	ra,120(sp)
    80007974:	7446                	ld	s0,112(sp)
    80007976:	74a6                	ld	s1,104(sp)
    80007978:	7906                	ld	s2,96(sp)
    8000797a:	69e6                	ld	s3,88(sp)
    8000797c:	6a46                	ld	s4,80(sp)
    8000797e:	6aa6                	ld	s5,72(sp)
    80007980:	6b06                	ld	s6,64(sp)
    80007982:	7be2                	ld	s7,56(sp)
    80007984:	7c42                	ld	s8,48(sp)
    80007986:	7ca2                	ld	s9,40(sp)
    80007988:	7d02                	ld	s10,32(sp)
    8000798a:	6de2                	ld	s11,24(sp)
    8000798c:	6109                	addi	sp,sp,128
    8000798e:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007990:	f8042503          	lw	a0,-128(s0)
    80007994:	20050793          	addi	a5,a0,512
    80007998:	0792                	slli	a5,a5,0x4
  if(write)
    8000799a:	0001d817          	auipc	a6,0x1d
    8000799e:	66680813          	addi	a6,a6,1638 # 80025000 <disk>
    800079a2:	00f80733          	add	a4,a6,a5
    800079a6:	01a036b3          	snez	a3,s10
    800079aa:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800079ae:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800079b2:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800079b6:	7679                	lui	a2,0xffffe
    800079b8:	963e                	add	a2,a2,a5
    800079ba:	0001f697          	auipc	a3,0x1f
    800079be:	64668693          	addi	a3,a3,1606 # 80027000 <disk+0x2000>
    800079c2:	6298                	ld	a4,0(a3)
    800079c4:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800079c6:	0a878593          	addi	a1,a5,168
    800079ca:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800079cc:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800079ce:	6298                	ld	a4,0(a3)
    800079d0:	9732                	add	a4,a4,a2
    800079d2:	45c1                	li	a1,16
    800079d4:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800079d6:	6298                	ld	a4,0(a3)
    800079d8:	9732                	add	a4,a4,a2
    800079da:	4585                	li	a1,1
    800079dc:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800079e0:	f8442703          	lw	a4,-124(s0)
    800079e4:	628c                	ld	a1,0(a3)
    800079e6:	962e                	add	a2,a2,a1
    800079e8:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd600e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800079ec:	0712                	slli	a4,a4,0x4
    800079ee:	6290                	ld	a2,0(a3)
    800079f0:	963a                	add	a2,a2,a4
    800079f2:	058a8593          	addi	a1,s5,88
    800079f6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800079f8:	6294                	ld	a3,0(a3)
    800079fa:	96ba                	add	a3,a3,a4
    800079fc:	40000613          	li	a2,1024
    80007a00:	c690                	sw	a2,8(a3)
  if(write)
    80007a02:	e40d1ae3          	bnez	s10,80007856 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80007a06:	0001f697          	auipc	a3,0x1f
    80007a0a:	5fa6b683          	ld	a3,1530(a3) # 80027000 <disk+0x2000>
    80007a0e:	96ba                	add	a3,a3,a4
    80007a10:	4609                	li	a2,2
    80007a12:	00c69623          	sh	a2,12(a3)
    80007a16:	b5b9                	j	80007864 <virtio_disk_rw+0xd2>

0000000080007a18 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80007a18:	1101                	addi	sp,sp,-32
    80007a1a:	ec06                	sd	ra,24(sp)
    80007a1c:	e822                	sd	s0,16(sp)
    80007a1e:	e426                	sd	s1,8(sp)
    80007a20:	e04a                	sd	s2,0(sp)
    80007a22:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80007a24:	0001f517          	auipc	a0,0x1f
    80007a28:	70450513          	addi	a0,a0,1796 # 80027128 <disk+0x2128>
    80007a2c:	ffff9097          	auipc	ra,0xffff9
    80007a30:	1a2080e7          	jalr	418(ra) # 80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80007a34:	10001737          	lui	a4,0x10001
    80007a38:	533c                	lw	a5,96(a4)
    80007a3a:	8b8d                	andi	a5,a5,3
    80007a3c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007a3e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007a42:	0001f797          	auipc	a5,0x1f
    80007a46:	5be78793          	addi	a5,a5,1470 # 80027000 <disk+0x2000>
    80007a4a:	6b94                	ld	a3,16(a5)
    80007a4c:	0207d703          	lhu	a4,32(a5)
    80007a50:	0026d783          	lhu	a5,2(a3)
    80007a54:	06f70163          	beq	a4,a5,80007ab6 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007a58:	0001d917          	auipc	s2,0x1d
    80007a5c:	5a890913          	addi	s2,s2,1448 # 80025000 <disk>
    80007a60:	0001f497          	auipc	s1,0x1f
    80007a64:	5a048493          	addi	s1,s1,1440 # 80027000 <disk+0x2000>
    __sync_synchronize();
    80007a68:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007a6c:	6898                	ld	a4,16(s1)
    80007a6e:	0204d783          	lhu	a5,32(s1)
    80007a72:	8b9d                	andi	a5,a5,7
    80007a74:	078e                	slli	a5,a5,0x3
    80007a76:	97ba                	add	a5,a5,a4
    80007a78:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007a7a:	20078713          	addi	a4,a5,512
    80007a7e:	0712                	slli	a4,a4,0x4
    80007a80:	974a                	add	a4,a4,s2
    80007a82:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80007a86:	e731                	bnez	a4,80007ad2 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80007a88:	20078793          	addi	a5,a5,512
    80007a8c:	0792                	slli	a5,a5,0x4
    80007a8e:	97ca                	add	a5,a5,s2
    80007a90:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007a92:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80007a96:	ffffb097          	auipc	ra,0xffffb
    80007a9a:	0da080e7          	jalr	218(ra) # 80002b70 <wakeup>

    disk.used_idx += 1;
    80007a9e:	0204d783          	lhu	a5,32(s1)
    80007aa2:	2785                	addiw	a5,a5,1
    80007aa4:	17c2                	slli	a5,a5,0x30
    80007aa6:	93c1                	srli	a5,a5,0x30
    80007aa8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007aac:	6898                	ld	a4,16(s1)
    80007aae:	00275703          	lhu	a4,2(a4)
    80007ab2:	faf71be3          	bne	a4,a5,80007a68 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80007ab6:	0001f517          	auipc	a0,0x1f
    80007aba:	67250513          	addi	a0,a0,1650 # 80027128 <disk+0x2128>
    80007abe:	ffff9097          	auipc	ra,0xffff9
    80007ac2:	1c4080e7          	jalr	452(ra) # 80000c82 <release>
}
    80007ac6:	60e2                	ld	ra,24(sp)
    80007ac8:	6442                	ld	s0,16(sp)
    80007aca:	64a2                	ld	s1,8(sp)
    80007acc:	6902                	ld	s2,0(sp)
    80007ace:	6105                	addi	sp,sp,32
    80007ad0:	8082                	ret
      panic("virtio_disk_intr status");
    80007ad2:	00002517          	auipc	a0,0x2
    80007ad6:	06e50513          	addi	a0,a0,110 # 80009b40 <syscalls+0x500>
    80007ada:	ffff9097          	auipc	ra,0xffff9
    80007ade:	a5e080e7          	jalr	-1442(ra) # 80000538 <panic>

0000000080007ae2 <cond_wait>:
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"
#include "condvar.h"

void cond_wait (struct cond_t *cv, struct sleeplock *lock){
    80007ae2:	1141                	addi	sp,sp,-16
    80007ae4:	e406                	sd	ra,8(sp)
    80007ae6:	e022                	sd	s0,0(sp)
    80007ae8:	0800                	addi	s0,sp,16
    condsleep(cv, lock);
    80007aea:	ffffc097          	auipc	ra,0xffffc
    80007aee:	b06080e7          	jalr	-1274(ra) # 800035f0 <condsleep>
};
    80007af2:	60a2                	ld	ra,8(sp)
    80007af4:	6402                	ld	s0,0(sp)
    80007af6:	0141                	addi	sp,sp,16
    80007af8:	8082                	ret

0000000080007afa <cond_signal>:
void cond_signal (struct cond_t *cv){
    80007afa:	1141                	addi	sp,sp,-16
    80007afc:	e406                	sd	ra,8(sp)
    80007afe:	e022                	sd	s0,0(sp)
    80007b00:	0800                	addi	s0,sp,16
    wakeupone(cv);
    80007b02:	ffffc097          	auipc	ra,0xffffc
    80007b06:	b52080e7          	jalr	-1198(ra) # 80003654 <wakeupone>
};
    80007b0a:	60a2                	ld	ra,8(sp)
    80007b0c:	6402                	ld	s0,0(sp)
    80007b0e:	0141                	addi	sp,sp,16
    80007b10:	8082                	ret

0000000080007b12 <cond_broadcast>:
void cond_broadcast (struct cond_t *cv){
    80007b12:	1141                	addi	sp,sp,-16
    80007b14:	e406                	sd	ra,8(sp)
    80007b16:	e022                	sd	s0,0(sp)
    80007b18:	0800                	addi	s0,sp,16
    wakeup(cv);
    80007b1a:	ffffb097          	auipc	ra,0xffffb
    80007b1e:	056080e7          	jalr	86(ra) # 80002b70 <wakeup>
    80007b22:	60a2                	ld	ra,8(sp)
    80007b24:	6402                	ld	s0,0(sp)
    80007b26:	0141                	addi	sp,sp,16
    80007b28:	8082                	ret

0000000080007b2a <sem_init>:
#include "proc.h"
#include "sleeplock.h"
#include "condvar.h"
#include "semaphore.h"

void sem_init (struct semaphore *s, int x){
    80007b2a:	1141                	addi	sp,sp,-16
    80007b2c:	e406                	sd	ra,8(sp)
    80007b2e:	e022                	sd	s0,0(sp)
    80007b30:	0800                	addi	s0,sp,16
    s->value = x;
    80007b32:	c10c                	sw	a1,0(a0)
    s->cv.cond = 0;
    80007b34:	02052c23          	sw	zero,56(a0)
    initsleeplock(&(s->lock), "semaphore");
    80007b38:	00002597          	auipc	a1,0x2
    80007b3c:	02058593          	addi	a1,a1,32 # 80009b58 <syscalls+0x518>
    80007b40:	0521                	addi	a0,a0,8
    80007b42:	ffffe097          	auipc	ra,0xffffe
    80007b46:	0e2080e7          	jalr	226(ra) # 80005c24 <initsleeplock>
};
    80007b4a:	60a2                	ld	ra,8(sp)
    80007b4c:	6402                	ld	s0,0(sp)
    80007b4e:	0141                	addi	sp,sp,16
    80007b50:	8082                	ret

0000000080007b52 <sem_wait>:
void sem_wait (struct semaphore *s){
    80007b52:	7179                	addi	sp,sp,-48
    80007b54:	f406                	sd	ra,40(sp)
    80007b56:	f022                	sd	s0,32(sp)
    80007b58:	ec26                	sd	s1,24(sp)
    80007b5a:	e84a                	sd	s2,16(sp)
    80007b5c:	e44e                	sd	s3,8(sp)
    80007b5e:	1800                	addi	s0,sp,48
    80007b60:	84aa                	mv	s1,a0
    acquiresleep(&(s->lock));
    80007b62:	00850913          	addi	s2,a0,8
    80007b66:	854a                	mv	a0,s2
    80007b68:	ffffe097          	auipc	ra,0xffffe
    80007b6c:	0f6080e7          	jalr	246(ra) # 80005c5e <acquiresleep>
    while(s->value>=0){
    80007b70:	409c                	lw	a5,0(s1)
    80007b72:	0007cd63          	bltz	a5,80007b8c <sem_wait+0x3a>
        cond_wait(&(s->cv), &(s->lock));
    80007b76:	03848993          	addi	s3,s1,56
    80007b7a:	85ca                	mv	a1,s2
    80007b7c:	854e                	mv	a0,s3
    80007b7e:	00000097          	auipc	ra,0x0
    80007b82:	f64080e7          	jalr	-156(ra) # 80007ae2 <cond_wait>
    while(s->value>=0){
    80007b86:	409c                	lw	a5,0(s1)
    80007b88:	fe07d9e3          	bgez	a5,80007b7a <sem_wait+0x28>
    }
    s->value--;
    80007b8c:	37fd                	addiw	a5,a5,-1
    80007b8e:	c09c                	sw	a5,0(s1)
    releasesleep(&(s->lock));
    80007b90:	854a                	mv	a0,s2
    80007b92:	ffffe097          	auipc	ra,0xffffe
    80007b96:	122080e7          	jalr	290(ra) # 80005cb4 <releasesleep>
};
    80007b9a:	70a2                	ld	ra,40(sp)
    80007b9c:	7402                	ld	s0,32(sp)
    80007b9e:	64e2                	ld	s1,24(sp)
    80007ba0:	6942                	ld	s2,16(sp)
    80007ba2:	69a2                	ld	s3,8(sp)
    80007ba4:	6145                	addi	sp,sp,48
    80007ba6:	8082                	ret

0000000080007ba8 <sem_post>:
void sem_post (struct semaphore *s){
    80007ba8:	1101                	addi	sp,sp,-32
    80007baa:	ec06                	sd	ra,24(sp)
    80007bac:	e822                	sd	s0,16(sp)
    80007bae:	e426                	sd	s1,8(sp)
    80007bb0:	e04a                	sd	s2,0(sp)
    80007bb2:	1000                	addi	s0,sp,32
    80007bb4:	84aa                	mv	s1,a0
    acquiresleep(&(s->lock));
    80007bb6:	00850913          	addi	s2,a0,8
    80007bba:	854a                	mv	a0,s2
    80007bbc:	ffffe097          	auipc	ra,0xffffe
    80007bc0:	0a2080e7          	jalr	162(ra) # 80005c5e <acquiresleep>
    s->value++;
    80007bc4:	409c                	lw	a5,0(s1)
    80007bc6:	2785                	addiw	a5,a5,1
    80007bc8:	c09c                	sw	a5,0(s1)
    cond_signal(&(s->cv));
    80007bca:	03848513          	addi	a0,s1,56
    80007bce:	00000097          	auipc	ra,0x0
    80007bd2:	f2c080e7          	jalr	-212(ra) # 80007afa <cond_signal>
    releasesleep(&(s->lock));
    80007bd6:	854a                	mv	a0,s2
    80007bd8:	ffffe097          	auipc	ra,0xffffe
    80007bdc:	0dc080e7          	jalr	220(ra) # 80005cb4 <releasesleep>
    80007be0:	60e2                	ld	ra,24(sp)
    80007be2:	6442                	ld	s0,16(sp)
    80007be4:	64a2                	ld	s1,8(sp)
    80007be6:	6902                	ld	s2,0(sp)
    80007be8:	6105                	addi	sp,sp,32
    80007bea:	8082                	ret
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
