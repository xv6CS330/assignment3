
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	b6013103          	ld	sp,-1184(sp) # 80009b60 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = TIMER_INTERVAL; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	6661                	lui	a2,0x18
    8000003e:	6a060613          	addi	a2,a2,1696 # 186a0 <_entry-0x7ffe7960>
    80000042:	95b2                	add	a1,a1,a2
    80000044:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000046:	00269713          	slli	a4,a3,0x2
    8000004a:	9736                	add	a4,a4,a3
    8000004c:	00371693          	slli	a3,a4,0x3
    80000050:	0000a717          	auipc	a4,0xa
    80000054:	02070713          	addi	a4,a4,32 # 8000a070 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00007797          	auipc	a5,0x7
    80000066:	01e78793          	addi	a5,a5,30 # 80007080 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd67ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	de078793          	addi	a5,a5,-544 # 80000e8c <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05663          	blez	a2,8000015e <consolewrite+0x5e>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	09e080e7          	jalr	158(ra) # 800031c8 <either_copyin>
    80000132:	01550c63          	beq	a0,s5,8000014a <consolewrite+0x4a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	78e080e7          	jalr	1934(ra) # 800008c8 <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
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
    80000160:	b7ed                	j	8000014a <consolewrite+0x4a>

0000000080000162 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000162:	7119                	addi	sp,sp,-128
    80000164:	fc86                	sd	ra,120(sp)
    80000166:	f8a2                	sd	s0,112(sp)
    80000168:	f4a6                	sd	s1,104(sp)
    8000016a:	f0ca                	sd	s2,96(sp)
    8000016c:	ecce                	sd	s3,88(sp)
    8000016e:	e8d2                	sd	s4,80(sp)
    80000170:	e4d6                	sd	s5,72(sp)
    80000172:	e0da                	sd	s6,64(sp)
    80000174:	fc5e                	sd	s7,56(sp)
    80000176:	f862                	sd	s8,48(sp)
    80000178:	f466                	sd	s9,40(sp)
    8000017a:	f06a                	sd	s10,32(sp)
    8000017c:	ec6e                	sd	s11,24(sp)
    8000017e:	0100                	addi	s0,sp,128
    80000180:	8b2a                	mv	s6,a0
    80000182:	8aae                	mv	s5,a1
    80000184:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018a:	00012517          	auipc	a0,0x12
    8000018e:	02650513          	addi	a0,a0,38 # 800121b0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a50080e7          	jalr	-1456(ra) # 80000be2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00012497          	auipc	s1,0x12
    8000019e:	01648493          	addi	s1,s1,22 # 800121b0 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	89a6                	mv	s3,s1
    800001a4:	00012917          	auipc	s2,0x12
    800001a8:	0a490913          	addi	s2,s2,164 # 80012248 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001ac:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ae:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b0:	4da9                	li	s11,10
  while(n > 0){
    800001b2:	07405863          	blez	s4,80000222 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001b6:	0984a783          	lw	a5,152(s1)
    800001ba:	09c4a703          	lw	a4,156(s1)
    800001be:	02f71463          	bne	a4,a5,800001e6 <consoleread+0x84>
      if(myproc()->killed){
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	812080e7          	jalr	-2030(ra) # 800019d4 <myproc>
    800001ca:	551c                	lw	a5,40(a0)
    800001cc:	e7b5                	bnez	a5,80000238 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001ce:	85ce                	mv	a1,s3
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	5a4080e7          	jalr	1444(ra) # 80002776 <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fef700e3          	beq	a4,a5,800001c2 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e6:	0017871b          	addiw	a4,a5,1
    800001ea:	08e4ac23          	sw	a4,152(s1)
    800001ee:	07f7f713          	andi	a4,a5,127
    800001f2:	9726                	add	a4,a4,s1
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001fc:	079c0663          	beq	s8,s9,80000268 <consoleread+0x106>
    cbuf = c;
    80000200:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000204:	4685                	li	a3,1
    80000206:	f8f40613          	addi	a2,s0,-113
    8000020a:	85d6                	mv	a1,s5
    8000020c:	855a                	mv	a0,s6
    8000020e:	00003097          	auipc	ra,0x3
    80000212:	f64080e7          	jalr	-156(ra) # 80003172 <either_copyout>
    80000216:	01a50663          	beq	a0,s10,80000222 <consoleread+0xc0>
    dst++;
    8000021a:	0a85                	addi	s5,s5,1
    --n;
    8000021c:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000021e:	f9bc1ae3          	bne	s8,s11,800001b2 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000222:	00012517          	auipc	a0,0x12
    80000226:	f8e50513          	addi	a0,a0,-114 # 800121b0 <cons>
    8000022a:	00001097          	auipc	ra,0x1
    8000022e:	a6c080e7          	jalr	-1428(ra) # 80000c96 <release>

  return target - n;
    80000232:	414b853b          	subw	a0,s7,s4
    80000236:	a811                	j	8000024a <consoleread+0xe8>
        release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	f7850513          	addi	a0,a0,-136 # 800121b0 <cons>
    80000240:	00001097          	auipc	ra,0x1
    80000244:	a56080e7          	jalr	-1450(ra) # 80000c96 <release>
        return -1;
    80000248:	557d                	li	a0,-1
}
    8000024a:	70e6                	ld	ra,120(sp)
    8000024c:	7446                	ld	s0,112(sp)
    8000024e:	74a6                	ld	s1,104(sp)
    80000250:	7906                	ld	s2,96(sp)
    80000252:	69e6                	ld	s3,88(sp)
    80000254:	6a46                	ld	s4,80(sp)
    80000256:	6aa6                	ld	s5,72(sp)
    80000258:	6b06                	ld	s6,64(sp)
    8000025a:	7be2                	ld	s7,56(sp)
    8000025c:	7c42                	ld	s8,48(sp)
    8000025e:	7ca2                	ld	s9,40(sp)
    80000260:	7d02                	ld	s10,32(sp)
    80000262:	6de2                	ld	s11,24(sp)
    80000264:	6109                	addi	sp,sp,128
    80000266:	8082                	ret
      if(n < target){
    80000268:	000a071b          	sext.w	a4,s4
    8000026c:	fb777be3          	bgeu	a4,s7,80000222 <consoleread+0xc0>
        cons.r--;
    80000270:	00012717          	auipc	a4,0x12
    80000274:	fcf72c23          	sw	a5,-40(a4) # 80012248 <cons+0x98>
    80000278:	b76d                	j	80000222 <consoleread+0xc0>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50a63          	beq	a0,a5,8000029a <consputc+0x20>
    uartputc_sync(c);
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	564080e7          	jalr	1380(ra) # 800007ee <uartputc_sync>
}
    80000292:	60a2                	ld	ra,8(sp)
    80000294:	6402                	ld	s0,0(sp)
    80000296:	0141                	addi	sp,sp,16
    80000298:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029a:	4521                	li	a0,8
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	552080e7          	jalr	1362(ra) # 800007ee <uartputc_sync>
    800002a4:	02000513          	li	a0,32
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	546080e7          	jalr	1350(ra) # 800007ee <uartputc_sync>
    800002b0:	4521                	li	a0,8
    800002b2:	00000097          	auipc	ra,0x0
    800002b6:	53c080e7          	jalr	1340(ra) # 800007ee <uartputc_sync>
    800002ba:	bfe1                	j	80000292 <consputc+0x18>

00000000800002bc <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002bc:	1101                	addi	sp,sp,-32
    800002be:	ec06                	sd	ra,24(sp)
    800002c0:	e822                	sd	s0,16(sp)
    800002c2:	e426                	sd	s1,8(sp)
    800002c4:	e04a                	sd	s2,0(sp)
    800002c6:	1000                	addi	s0,sp,32
    800002c8:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002ca:	00012517          	auipc	a0,0x12
    800002ce:	ee650513          	addi	a0,a0,-282 # 800121b0 <cons>
    800002d2:	00001097          	auipc	ra,0x1
    800002d6:	910080e7          	jalr	-1776(ra) # 80000be2 <acquire>

  switch(c){
    800002da:	47d5                	li	a5,21
    800002dc:	0af48663          	beq	s1,a5,80000388 <consoleintr+0xcc>
    800002e0:	0297ca63          	blt	a5,s1,80000314 <consoleintr+0x58>
    800002e4:	47a1                	li	a5,8
    800002e6:	0ef48763          	beq	s1,a5,800003d4 <consoleintr+0x118>
    800002ea:	47c1                	li	a5,16
    800002ec:	10f49a63          	bne	s1,a5,80000400 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f0:	00003097          	auipc	ra,0x3
    800002f4:	f2e080e7          	jalr	-210(ra) # 8000321e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f8:	00012517          	auipc	a0,0x12
    800002fc:	eb850513          	addi	a0,a0,-328 # 800121b0 <cons>
    80000300:	00001097          	auipc	ra,0x1
    80000304:	996080e7          	jalr	-1642(ra) # 80000c96 <release>
}
    80000308:	60e2                	ld	ra,24(sp)
    8000030a:	6442                	ld	s0,16(sp)
    8000030c:	64a2                	ld	s1,8(sp)
    8000030e:	6902                	ld	s2,0(sp)
    80000310:	6105                	addi	sp,sp,32
    80000312:	8082                	ret
  switch(c){
    80000314:	07f00793          	li	a5,127
    80000318:	0af48e63          	beq	s1,a5,800003d4 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000031c:	00012717          	auipc	a4,0x12
    80000320:	e9470713          	addi	a4,a4,-364 # 800121b0 <cons>
    80000324:	0a072783          	lw	a5,160(a4)
    80000328:	09872703          	lw	a4,152(a4)
    8000032c:	9f99                	subw	a5,a5,a4
    8000032e:	07f00713          	li	a4,127
    80000332:	fcf763e3          	bltu	a4,a5,800002f8 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000336:	47b5                	li	a5,13
    80000338:	0cf48763          	beq	s1,a5,80000406 <consoleintr+0x14a>
      consputc(c);
    8000033c:	8526                	mv	a0,s1
    8000033e:	00000097          	auipc	ra,0x0
    80000342:	f3c080e7          	jalr	-196(ra) # 8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000346:	00012797          	auipc	a5,0x12
    8000034a:	e6a78793          	addi	a5,a5,-406 # 800121b0 <cons>
    8000034e:	0a07a703          	lw	a4,160(a5)
    80000352:	0017069b          	addiw	a3,a4,1
    80000356:	0006861b          	sext.w	a2,a3
    8000035a:	0ad7a023          	sw	a3,160(a5)
    8000035e:	07f77713          	andi	a4,a4,127
    80000362:	97ba                	add	a5,a5,a4
    80000364:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000368:	47a9                	li	a5,10
    8000036a:	0cf48563          	beq	s1,a5,80000434 <consoleintr+0x178>
    8000036e:	4791                	li	a5,4
    80000370:	0cf48263          	beq	s1,a5,80000434 <consoleintr+0x178>
    80000374:	00012797          	auipc	a5,0x12
    80000378:	ed47a783          	lw	a5,-300(a5) # 80012248 <cons+0x98>
    8000037c:	0807879b          	addiw	a5,a5,128
    80000380:	f6f61ce3          	bne	a2,a5,800002f8 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000384:	863e                	mv	a2,a5
    80000386:	a07d                	j	80000434 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000388:	00012717          	auipc	a4,0x12
    8000038c:	e2870713          	addi	a4,a4,-472 # 800121b0 <cons>
    80000390:	0a072783          	lw	a5,160(a4)
    80000394:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000398:	00012497          	auipc	s1,0x12
    8000039c:	e1848493          	addi	s1,s1,-488 # 800121b0 <cons>
    while(cons.e != cons.w &&
    800003a0:	4929                	li	s2,10
    800003a2:	f4f70be3          	beq	a4,a5,800002f8 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a6:	37fd                	addiw	a5,a5,-1
    800003a8:	07f7f713          	andi	a4,a5,127
    800003ac:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ae:	01874703          	lbu	a4,24(a4)
    800003b2:	f52703e3          	beq	a4,s2,800002f8 <consoleintr+0x3c>
      cons.e--;
    800003b6:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003ba:	10000513          	li	a0,256
    800003be:	00000097          	auipc	ra,0x0
    800003c2:	ebc080e7          	jalr	-324(ra) # 8000027a <consputc>
    while(cons.e != cons.w &&
    800003c6:	0a04a783          	lw	a5,160(s1)
    800003ca:	09c4a703          	lw	a4,156(s1)
    800003ce:	fcf71ce3          	bne	a4,a5,800003a6 <consoleintr+0xea>
    800003d2:	b71d                	j	800002f8 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d4:	00012717          	auipc	a4,0x12
    800003d8:	ddc70713          	addi	a4,a4,-548 # 800121b0 <cons>
    800003dc:	0a072783          	lw	a5,160(a4)
    800003e0:	09c72703          	lw	a4,156(a4)
    800003e4:	f0f70ae3          	beq	a4,a5,800002f8 <consoleintr+0x3c>
      cons.e--;
    800003e8:	37fd                	addiw	a5,a5,-1
    800003ea:	00012717          	auipc	a4,0x12
    800003ee:	e6f72323          	sw	a5,-410(a4) # 80012250 <cons+0xa0>
      consputc(BACKSPACE);
    800003f2:	10000513          	li	a0,256
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e84080e7          	jalr	-380(ra) # 8000027a <consputc>
    800003fe:	bded                	j	800002f8 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000400:	ee048ce3          	beqz	s1,800002f8 <consoleintr+0x3c>
    80000404:	bf21                	j	8000031c <consoleintr+0x60>
      consputc(c);
    80000406:	4529                	li	a0,10
    80000408:	00000097          	auipc	ra,0x0
    8000040c:	e72080e7          	jalr	-398(ra) # 8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000410:	00012797          	auipc	a5,0x12
    80000414:	da078793          	addi	a5,a5,-608 # 800121b0 <cons>
    80000418:	0a07a703          	lw	a4,160(a5)
    8000041c:	0017069b          	addiw	a3,a4,1
    80000420:	0006861b          	sext.w	a2,a3
    80000424:	0ad7a023          	sw	a3,160(a5)
    80000428:	07f77713          	andi	a4,a4,127
    8000042c:	97ba                	add	a5,a5,a4
    8000042e:	4729                	li	a4,10
    80000430:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000434:	00012797          	auipc	a5,0x12
    80000438:	e0c7ac23          	sw	a2,-488(a5) # 8001224c <cons+0x9c>
        wakeup(&cons.r);
    8000043c:	00012517          	auipc	a0,0x12
    80000440:	e0c50513          	addi	a0,a0,-500 # 80012248 <cons+0x98>
    80000444:	00002097          	auipc	ra,0x2
    80000448:	738080e7          	jalr	1848(ra) # 80002b7c <wakeup>
    8000044c:	b575                	j	800002f8 <consoleintr+0x3c>

000000008000044e <consoleinit>:

void
consoleinit(void)
{
    8000044e:	1141                	addi	sp,sp,-16
    80000450:	e406                	sd	ra,8(sp)
    80000452:	e022                	sd	s0,0(sp)
    80000454:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000456:	00009597          	auipc	a1,0x9
    8000045a:	bba58593          	addi	a1,a1,-1094 # 80009010 <etext+0x10>
    8000045e:	00012517          	auipc	a0,0x12
    80000462:	d5250513          	addi	a0,a0,-686 # 800121b0 <cons>
    80000466:	00000097          	auipc	ra,0x0
    8000046a:	6ec080e7          	jalr	1772(ra) # 80000b52 <initlock>

  uartinit();
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	330080e7          	jalr	816(ra) # 8000079e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000476:	00023797          	auipc	a5,0x23
    8000047a:	b5278793          	addi	a5,a5,-1198 # 80022fc8 <devsw>
    8000047e:	00000717          	auipc	a4,0x0
    80000482:	ce470713          	addi	a4,a4,-796 # 80000162 <consoleread>
    80000486:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000488:	00000717          	auipc	a4,0x0
    8000048c:	c7870713          	addi	a4,a4,-904 # 80000100 <consolewrite>
    80000490:	ef98                	sd	a4,24(a5)
}
    80000492:	60a2                	ld	ra,8(sp)
    80000494:	6402                	ld	s0,0(sp)
    80000496:	0141                	addi	sp,sp,16
    80000498:	8082                	ret

000000008000049a <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049a:	7179                	addi	sp,sp,-48
    8000049c:	f406                	sd	ra,40(sp)
    8000049e:	f022                	sd	s0,32(sp)
    800004a0:	ec26                	sd	s1,24(sp)
    800004a2:	e84a                	sd	s2,16(sp)
    800004a4:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a6:	c219                	beqz	a2,800004ac <printint+0x12>
    800004a8:	08054663          	bltz	a0,80000534 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ac:	2501                	sext.w	a0,a0
    800004ae:	4881                	li	a7,0
    800004b0:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b4:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b6:	2581                	sext.w	a1,a1
    800004b8:	00009617          	auipc	a2,0x9
    800004bc:	b8860613          	addi	a2,a2,-1144 # 80009040 <digits>
    800004c0:	883a                	mv	a6,a4
    800004c2:	2705                	addiw	a4,a4,1
    800004c4:	02b577bb          	remuw	a5,a0,a1
    800004c8:	1782                	slli	a5,a5,0x20
    800004ca:	9381                	srli	a5,a5,0x20
    800004cc:	97b2                	add	a5,a5,a2
    800004ce:	0007c783          	lbu	a5,0(a5)
    800004d2:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d6:	0005079b          	sext.w	a5,a0
    800004da:	02b5553b          	divuw	a0,a0,a1
    800004de:	0685                	addi	a3,a3,1
    800004e0:	feb7f0e3          	bgeu	a5,a1,800004c0 <printint+0x26>

  if(sign)
    800004e4:	00088b63          	beqz	a7,800004fa <printint+0x60>
    buf[i++] = '-';
    800004e8:	fe040793          	addi	a5,s0,-32
    800004ec:	973e                	add	a4,a4,a5
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x8e>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d60080e7          	jalr	-672(ra) # 8000027a <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7c>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf9d                	j	800004b0 <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00012797          	auipc	a5,0x12
    8000054c:	d207a423          	sw	zero,-728(a5) # 80012270 <pr+0x18>
  printf("panic: ");
    80000550:	00009517          	auipc	a0,0x9
    80000554:	ac850513          	addi	a0,a0,-1336 # 80009018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00009517          	auipc	a0,0x9
    8000056e:	1f650513          	addi	a0,a0,502 # 80009760 <syscalls+0x120>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	0000a717          	auipc	a4,0xa
    80000580:	a8f72223          	sw	a5,-1404(a4) # 8000a000 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00012d97          	auipc	s11,0x12
    800005bc:	cb8dad83          	lw	s11,-840(s11) # 80012270 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	16050263          	beqz	a0,80000738 <printf+0x1b2>
    800005d8:	4481                	li	s1,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b13          	li	s6,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00009b97          	auipc	s7,0x9
    800005e8:	a5cb8b93          	addi	s7,s7,-1444 # 80009040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00012517          	auipc	a0,0x12
    800005fa:	c6250513          	addi	a0,a0,-926 # 80012258 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5e4080e7          	jalr	1508(ra) # 80000be2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00009517          	auipc	a0,0x9
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80009028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c62080e7          	jalr	-926(ra) # 8000027a <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2485                	addiw	s1,s1,1
    80000622:	009a07b3          	add	a5,s4,s1
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050763          	beqz	a0,80000738 <printf+0x1b2>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2485                	addiw	s1,s1,1
    80000634:	009a07b3          	add	a5,s4,s1
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000640:	cfe5                	beqz	a5,80000738 <printf+0x1b2>
    switch(c){
    80000642:	05678a63          	beq	a5,s6,80000696 <printf+0x110>
    80000646:	02fb7663          	bgeu	s6,a5,80000672 <printf+0xec>
    8000064a:	09978963          	beq	a5,s9,800006dc <printf+0x156>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79863          	bne	a5,a4,80000722 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e32080e7          	jalr	-462(ra) # 8000049a <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	0b578263          	beq	a5,s5,80000716 <printf+0x190>
    80000676:	0b879663          	bne	a5,s8,80000722 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0e080e7          	jalr	-498(ra) # 8000049a <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bd0080e7          	jalr	-1072(ra) # 8000027a <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc4080e7          	jalr	-1084(ra) # 8000027a <consputc>
    800006be:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c9d793          	srli	a5,s3,0x3c
    800006c4:	97de                	add	a5,a5,s7
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bb0080e7          	jalr	-1104(ra) # 8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0992                	slli	s3,s3,0x4
    800006d4:	397d                	addiw	s2,s2,-1
    800006d6:	fe0915e3          	bnez	s2,800006c0 <printf+0x13a>
    800006da:	b799                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	0007b903          	ld	s2,0(a5)
    800006ec:	00090e63          	beqz	s2,80000708 <printf+0x182>
      for(; *s; s++)
    800006f0:	00094503          	lbu	a0,0(s2)
    800006f4:	d515                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f6:	00000097          	auipc	ra,0x0
    800006fa:	b84080e7          	jalr	-1148(ra) # 8000027a <consputc>
      for(; *s; s++)
    800006fe:	0905                	addi	s2,s2,1
    80000700:	00094503          	lbu	a0,0(s2)
    80000704:	f96d                	bnez	a0,800006f6 <printf+0x170>
    80000706:	bf29                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000708:	00009917          	auipc	s2,0x9
    8000070c:	91890913          	addi	s2,s2,-1768 # 80009020 <etext+0x20>
      for(; *s; s++)
    80000710:	02800513          	li	a0,40
    80000714:	b7cd                	j	800006f6 <printf+0x170>
      consputc('%');
    80000716:	8556                	mv	a0,s5
    80000718:	00000097          	auipc	ra,0x0
    8000071c:	b62080e7          	jalr	-1182(ra) # 8000027a <consputc>
      break;
    80000720:	b701                	j	80000620 <printf+0x9a>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b56080e7          	jalr	-1194(ra) # 8000027a <consputc>
      consputc(c);
    8000072c:	854a                	mv	a0,s2
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	b4c080e7          	jalr	-1204(ra) # 8000027a <consputc>
      break;
    80000736:	b5ed                	j	80000620 <printf+0x9a>
  if(locking)
    80000738:	020d9163          	bnez	s11,8000075a <printf+0x1d4>
}
    8000073c:	70e6                	ld	ra,120(sp)
    8000073e:	7446                	ld	s0,112(sp)
    80000740:	74a6                	ld	s1,104(sp)
    80000742:	7906                	ld	s2,96(sp)
    80000744:	69e6                	ld	s3,88(sp)
    80000746:	6a46                	ld	s4,80(sp)
    80000748:	6aa6                	ld	s5,72(sp)
    8000074a:	6b06                	ld	s6,64(sp)
    8000074c:	7be2                	ld	s7,56(sp)
    8000074e:	7c42                	ld	s8,48(sp)
    80000750:	7ca2                	ld	s9,40(sp)
    80000752:	7d02                	ld	s10,32(sp)
    80000754:	6de2                	ld	s11,24(sp)
    80000756:	6129                	addi	sp,sp,192
    80000758:	8082                	ret
    release(&pr.lock);
    8000075a:	00012517          	auipc	a0,0x12
    8000075e:	afe50513          	addi	a0,a0,-1282 # 80012258 <pr>
    80000762:	00000097          	auipc	ra,0x0
    80000766:	534080e7          	jalr	1332(ra) # 80000c96 <release>
}
    8000076a:	bfc9                	j	8000073c <printf+0x1b6>

000000008000076c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076c:	1101                	addi	sp,sp,-32
    8000076e:	ec06                	sd	ra,24(sp)
    80000770:	e822                	sd	s0,16(sp)
    80000772:	e426                	sd	s1,8(sp)
    80000774:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000776:	00012497          	auipc	s1,0x12
    8000077a:	ae248493          	addi	s1,s1,-1310 # 80012258 <pr>
    8000077e:	00009597          	auipc	a1,0x9
    80000782:	8ba58593          	addi	a1,a1,-1862 # 80009038 <etext+0x38>
    80000786:	8526                	mv	a0,s1
    80000788:	00000097          	auipc	ra,0x0
    8000078c:	3ca080e7          	jalr	970(ra) # 80000b52 <initlock>
  pr.locking = 1;
    80000790:	4785                	li	a5,1
    80000792:	cc9c                	sw	a5,24(s1)
}
    80000794:	60e2                	ld	ra,24(sp)
    80000796:	6442                	ld	s0,16(sp)
    80000798:	64a2                	ld	s1,8(sp)
    8000079a:	6105                	addi	sp,sp,32
    8000079c:	8082                	ret

000000008000079e <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079e:	1141                	addi	sp,sp,-16
    800007a0:	e406                	sd	ra,8(sp)
    800007a2:	e022                	sd	s0,0(sp)
    800007a4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a6:	100007b7          	lui	a5,0x10000
    800007aa:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ae:	f8000713          	li	a4,-128
    800007b2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b6:	470d                	li	a4,3
    800007b8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007bc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c4:	469d                	li	a3,7
    800007c6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007ca:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ce:	00009597          	auipc	a1,0x9
    800007d2:	88a58593          	addi	a1,a1,-1910 # 80009058 <digits+0x18>
    800007d6:	00012517          	auipc	a0,0x12
    800007da:	aa250513          	addi	a0,a0,-1374 # 80012278 <uart_tx_lock>
    800007de:	00000097          	auipc	ra,0x0
    800007e2:	374080e7          	jalr	884(ra) # 80000b52 <initlock>
}
    800007e6:	60a2                	ld	ra,8(sp)
    800007e8:	6402                	ld	s0,0(sp)
    800007ea:	0141                	addi	sp,sp,16
    800007ec:	8082                	ret

00000000800007ee <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ee:	1101                	addi	sp,sp,-32
    800007f0:	ec06                	sd	ra,24(sp)
    800007f2:	e822                	sd	s0,16(sp)
    800007f4:	e426                	sd	s1,8(sp)
    800007f6:	1000                	addi	s0,sp,32
    800007f8:	84aa                	mv	s1,a0
  push_off();
    800007fa:	00000097          	auipc	ra,0x0
    800007fe:	39c080e7          	jalr	924(ra) # 80000b96 <push_off>

  if(panicked){
    80000802:	00009797          	auipc	a5,0x9
    80000806:	7fe7a783          	lw	a5,2046(a5) # 8000a000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080e:	c391                	beqz	a5,80000812 <uartputc_sync+0x24>
    for(;;)
    80000810:	a001                	j	80000810 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000816:	0ff7f793          	andi	a5,a5,255
    8000081a:	0207f793          	andi	a5,a5,32
    8000081e:	dbf5                	beqz	a5,80000812 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000820:	0ff4f793          	andi	a5,s1,255
    80000824:	10000737          	lui	a4,0x10000
    80000828:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082c:	00000097          	auipc	ra,0x0
    80000830:	40a080e7          	jalr	1034(ra) # 80000c36 <pop_off>
}
    80000834:	60e2                	ld	ra,24(sp)
    80000836:	6442                	ld	s0,16(sp)
    80000838:	64a2                	ld	s1,8(sp)
    8000083a:	6105                	addi	sp,sp,32
    8000083c:	8082                	ret

000000008000083e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000083e:	00009717          	auipc	a4,0x9
    80000842:	7ca73703          	ld	a4,1994(a4) # 8000a008 <uart_tx_r>
    80000846:	00009797          	auipc	a5,0x9
    8000084a:	7ca7b783          	ld	a5,1994(a5) # 8000a010 <uart_tx_w>
    8000084e:	06e78c63          	beq	a5,a4,800008c6 <uartstart+0x88>
{
    80000852:	7139                	addi	sp,sp,-64
    80000854:	fc06                	sd	ra,56(sp)
    80000856:	f822                	sd	s0,48(sp)
    80000858:	f426                	sd	s1,40(sp)
    8000085a:	f04a                	sd	s2,32(sp)
    8000085c:	ec4e                	sd	s3,24(sp)
    8000085e:	e852                	sd	s4,16(sp)
    80000860:	e456                	sd	s5,8(sp)
    80000862:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000868:	00012a17          	auipc	s4,0x12
    8000086c:	a10a0a13          	addi	s4,s4,-1520 # 80012278 <uart_tx_lock>
    uart_tx_r += 1;
    80000870:	00009497          	auipc	s1,0x9
    80000874:	79848493          	addi	s1,s1,1944 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000878:	00009997          	auipc	s3,0x9
    8000087c:	79898993          	addi	s3,s3,1944 # 8000a010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000880:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000884:	0ff7f793          	andi	a5,a5,255
    80000888:	0207f793          	andi	a5,a5,32
    8000088c:	c785                	beqz	a5,800008b4 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000088e:	01f77793          	andi	a5,a4,31
    80000892:	97d2                	add	a5,a5,s4
    80000894:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    80000898:	0705                	addi	a4,a4,1
    8000089a:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000089c:	8526                	mv	a0,s1
    8000089e:	00002097          	auipc	ra,0x2
    800008a2:	2de080e7          	jalr	734(ra) # 80002b7c <wakeup>
    
    WriteReg(THR, c);
    800008a6:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008aa:	6098                	ld	a4,0(s1)
    800008ac:	0009b783          	ld	a5,0(s3)
    800008b0:	fce798e3          	bne	a5,a4,80000880 <uartstart+0x42>
  }
}
    800008b4:	70e2                	ld	ra,56(sp)
    800008b6:	7442                	ld	s0,48(sp)
    800008b8:	74a2                	ld	s1,40(sp)
    800008ba:	7902                	ld	s2,32(sp)
    800008bc:	69e2                	ld	s3,24(sp)
    800008be:	6a42                	ld	s4,16(sp)
    800008c0:	6aa2                	ld	s5,8(sp)
    800008c2:	6121                	addi	sp,sp,64
    800008c4:	8082                	ret
    800008c6:	8082                	ret

00000000800008c8 <uartputc>:
{
    800008c8:	7179                	addi	sp,sp,-48
    800008ca:	f406                	sd	ra,40(sp)
    800008cc:	f022                	sd	s0,32(sp)
    800008ce:	ec26                	sd	s1,24(sp)
    800008d0:	e84a                	sd	s2,16(sp)
    800008d2:	e44e                	sd	s3,8(sp)
    800008d4:	e052                	sd	s4,0(sp)
    800008d6:	1800                	addi	s0,sp,48
    800008d8:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008da:	00012517          	auipc	a0,0x12
    800008de:	99e50513          	addi	a0,a0,-1634 # 80012278 <uart_tx_lock>
    800008e2:	00000097          	auipc	ra,0x0
    800008e6:	300080e7          	jalr	768(ra) # 80000be2 <acquire>
  if(panicked){
    800008ea:	00009797          	auipc	a5,0x9
    800008ee:	7167a783          	lw	a5,1814(a5) # 8000a000 <panicked>
    800008f2:	c391                	beqz	a5,800008f6 <uartputc+0x2e>
    for(;;)
    800008f4:	a001                	j	800008f4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f6:	00009797          	auipc	a5,0x9
    800008fa:	71a7b783          	ld	a5,1818(a5) # 8000a010 <uart_tx_w>
    800008fe:	00009717          	auipc	a4,0x9
    80000902:	70a73703          	ld	a4,1802(a4) # 8000a008 <uart_tx_r>
    80000906:	02070713          	addi	a4,a4,32
    8000090a:	02f71b63          	bne	a4,a5,80000940 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000090e:	00012a17          	auipc	s4,0x12
    80000912:	96aa0a13          	addi	s4,s4,-1686 # 80012278 <uart_tx_lock>
    80000916:	00009497          	auipc	s1,0x9
    8000091a:	6f248493          	addi	s1,s1,1778 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000091e:	00009917          	auipc	s2,0x9
    80000922:	6f290913          	addi	s2,s2,1778 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000926:	85d2                	mv	a1,s4
    80000928:	8526                	mv	a0,s1
    8000092a:	00002097          	auipc	ra,0x2
    8000092e:	e4c080e7          	jalr	-436(ra) # 80002776 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000932:	00093783          	ld	a5,0(s2)
    80000936:	6098                	ld	a4,0(s1)
    80000938:	02070713          	addi	a4,a4,32
    8000093c:	fef705e3          	beq	a4,a5,80000926 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000940:	00012497          	auipc	s1,0x12
    80000944:	93848493          	addi	s1,s1,-1736 # 80012278 <uart_tx_lock>
    80000948:	01f7f713          	andi	a4,a5,31
    8000094c:	9726                	add	a4,a4,s1
    8000094e:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000952:	0785                	addi	a5,a5,1
    80000954:	00009717          	auipc	a4,0x9
    80000958:	6af73e23          	sd	a5,1724(a4) # 8000a010 <uart_tx_w>
      uartstart();
    8000095c:	00000097          	auipc	ra,0x0
    80000960:	ee2080e7          	jalr	-286(ra) # 8000083e <uartstart>
      release(&uart_tx_lock);
    80000964:	8526                	mv	a0,s1
    80000966:	00000097          	auipc	ra,0x0
    8000096a:	330080e7          	jalr	816(ra) # 80000c96 <release>
}
    8000096e:	70a2                	ld	ra,40(sp)
    80000970:	7402                	ld	s0,32(sp)
    80000972:	64e2                	ld	s1,24(sp)
    80000974:	6942                	ld	s2,16(sp)
    80000976:	69a2                	ld	s3,8(sp)
    80000978:	6a02                	ld	s4,0(sp)
    8000097a:	6145                	addi	sp,sp,48
    8000097c:	8082                	ret

000000008000097e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000097e:	1141                	addi	sp,sp,-16
    80000980:	e422                	sd	s0,8(sp)
    80000982:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000098c:	8b85                	andi	a5,a5,1
    8000098e:	cb91                	beqz	a5,800009a2 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000998:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000099c:	6422                	ld	s0,8(sp)
    8000099e:	0141                	addi	sp,sp,16
    800009a0:	8082                	ret
    return -1;
    800009a2:	557d                	li	a0,-1
    800009a4:	bfe5                	j	8000099c <uartgetc+0x1e>

00000000800009a6 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009a6:	1101                	addi	sp,sp,-32
    800009a8:	ec06                	sd	ra,24(sp)
    800009aa:	e822                	sd	s0,16(sp)
    800009ac:	e426                	sd	s1,8(sp)
    800009ae:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b0:	54fd                	li	s1,-1
    int c = uartgetc();
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	fcc080e7          	jalr	-52(ra) # 8000097e <uartgetc>
    if(c == -1)
    800009ba:	00950763          	beq	a0,s1,800009c8 <uartintr+0x22>
      break;
    consoleintr(c);
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	8fe080e7          	jalr	-1794(ra) # 800002bc <consoleintr>
  while(1){
    800009c6:	b7f5                	j	800009b2 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009c8:	00012497          	auipc	s1,0x12
    800009cc:	8b048493          	addi	s1,s1,-1872 # 80012278 <uart_tx_lock>
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	210080e7          	jalr	528(ra) # 80000be2 <acquire>
  uartstart();
    800009da:	00000097          	auipc	ra,0x0
    800009de:	e64080e7          	jalr	-412(ra) # 8000083e <uartstart>
  release(&uart_tx_lock);
    800009e2:	8526                	mv	a0,s1
    800009e4:	00000097          	auipc	ra,0x0
    800009e8:	2b2080e7          	jalr	690(ra) # 80000c96 <release>
}
    800009ec:	60e2                	ld	ra,24(sp)
    800009ee:	6442                	ld	s0,16(sp)
    800009f0:	64a2                	ld	s1,8(sp)
    800009f2:	6105                	addi	sp,sp,32
    800009f4:	8082                	ret

00000000800009f6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009f6:	1101                	addi	sp,sp,-32
    800009f8:	ec06                	sd	ra,24(sp)
    800009fa:	e822                	sd	s0,16(sp)
    800009fc:	e426                	sd	s1,8(sp)
    800009fe:	e04a                	sd	s2,0(sp)
    80000a00:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a02:	03451793          	slli	a5,a0,0x34
    80000a06:	ebb9                	bnez	a5,80000a5c <kfree+0x66>
    80000a08:	84aa                	mv	s1,a0
    80000a0a:	00027797          	auipc	a5,0x27
    80000a0e:	5f678793          	addi	a5,a5,1526 # 80028000 <end>
    80000a12:	04f56563          	bltu	a0,a5,80000a5c <kfree+0x66>
    80000a16:	47c5                	li	a5,17
    80000a18:	07ee                	slli	a5,a5,0x1b
    80000a1a:	04f57163          	bgeu	a0,a5,80000a5c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a1e:	6605                	lui	a2,0x1
    80000a20:	4585                	li	a1,1
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	2bc080e7          	jalr	700(ra) # 80000cde <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a2a:	00012917          	auipc	s2,0x12
    80000a2e:	88690913          	addi	s2,s2,-1914 # 800122b0 <kmem>
    80000a32:	854a                	mv	a0,s2
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	1ae080e7          	jalr	430(ra) # 80000be2 <acquire>
  r->next = kmem.freelist;
    80000a3c:	01893783          	ld	a5,24(s2)
    80000a40:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a42:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a46:	854a                	mv	a0,s2
    80000a48:	00000097          	auipc	ra,0x0
    80000a4c:	24e080e7          	jalr	590(ra) # 80000c96 <release>
}
    80000a50:	60e2                	ld	ra,24(sp)
    80000a52:	6442                	ld	s0,16(sp)
    80000a54:	64a2                	ld	s1,8(sp)
    80000a56:	6902                	ld	s2,0(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret
    panic("kfree");
    80000a5c:	00008517          	auipc	a0,0x8
    80000a60:	60450513          	addi	a0,a0,1540 # 80009060 <digits+0x20>
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	ad8080e7          	jalr	-1320(ra) # 8000053c <panic>

0000000080000a6c <freerange>:
{
    80000a6c:	7179                	addi	sp,sp,-48
    80000a6e:	f406                	sd	ra,40(sp)
    80000a70:	f022                	sd	s0,32(sp)
    80000a72:	ec26                	sd	s1,24(sp)
    80000a74:	e84a                	sd	s2,16(sp)
    80000a76:	e44e                	sd	s3,8(sp)
    80000a78:	e052                	sd	s4,0(sp)
    80000a7a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a7c:	6785                	lui	a5,0x1
    80000a7e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a82:	94aa                	add	s1,s1,a0
    80000a84:	757d                	lui	a0,0xfffff
    80000a86:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a88:	94be                	add	s1,s1,a5
    80000a8a:	0095ee63          	bltu	a1,s1,80000aa6 <freerange+0x3a>
    80000a8e:	892e                	mv	s2,a1
    kfree(p);
    80000a90:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a92:	6985                	lui	s3,0x1
    kfree(p);
    80000a94:	01448533          	add	a0,s1,s4
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	f5e080e7          	jalr	-162(ra) # 800009f6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa0:	94ce                	add	s1,s1,s3
    80000aa2:	fe9979e3          	bgeu	s2,s1,80000a94 <freerange+0x28>
}
    80000aa6:	70a2                	ld	ra,40(sp)
    80000aa8:	7402                	ld	s0,32(sp)
    80000aaa:	64e2                	ld	s1,24(sp)
    80000aac:	6942                	ld	s2,16(sp)
    80000aae:	69a2                	ld	s3,8(sp)
    80000ab0:	6a02                	ld	s4,0(sp)
    80000ab2:	6145                	addi	sp,sp,48
    80000ab4:	8082                	ret

0000000080000ab6 <kinit>:
{
    80000ab6:	1141                	addi	sp,sp,-16
    80000ab8:	e406                	sd	ra,8(sp)
    80000aba:	e022                	sd	s0,0(sp)
    80000abc:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000abe:	00008597          	auipc	a1,0x8
    80000ac2:	5aa58593          	addi	a1,a1,1450 # 80009068 <digits+0x28>
    80000ac6:	00011517          	auipc	a0,0x11
    80000aca:	7ea50513          	addi	a0,a0,2026 # 800122b0 <kmem>
    80000ace:	00000097          	auipc	ra,0x0
    80000ad2:	084080e7          	jalr	132(ra) # 80000b52 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ad6:	45c5                	li	a1,17
    80000ad8:	05ee                	slli	a1,a1,0x1b
    80000ada:	00027517          	auipc	a0,0x27
    80000ade:	52650513          	addi	a0,a0,1318 # 80028000 <end>
    80000ae2:	00000097          	auipc	ra,0x0
    80000ae6:	f8a080e7          	jalr	-118(ra) # 80000a6c <freerange>
}
    80000aea:	60a2                	ld	ra,8(sp)
    80000aec:	6402                	ld	s0,0(sp)
    80000aee:	0141                	addi	sp,sp,16
    80000af0:	8082                	ret

0000000080000af2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000af2:	1101                	addi	sp,sp,-32
    80000af4:	ec06                	sd	ra,24(sp)
    80000af6:	e822                	sd	s0,16(sp)
    80000af8:	e426                	sd	s1,8(sp)
    80000afa:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000afc:	00011497          	auipc	s1,0x11
    80000b00:	7b448493          	addi	s1,s1,1972 # 800122b0 <kmem>
    80000b04:	8526                	mv	a0,s1
    80000b06:	00000097          	auipc	ra,0x0
    80000b0a:	0dc080e7          	jalr	220(ra) # 80000be2 <acquire>
  r = kmem.freelist;
    80000b0e:	6c84                	ld	s1,24(s1)
  if(r)
    80000b10:	c885                	beqz	s1,80000b40 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b12:	609c                	ld	a5,0(s1)
    80000b14:	00011517          	auipc	a0,0x11
    80000b18:	79c50513          	addi	a0,a0,1948 # 800122b0 <kmem>
    80000b1c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b1e:	00000097          	auipc	ra,0x0
    80000b22:	178080e7          	jalr	376(ra) # 80000c96 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b26:	6605                	lui	a2,0x1
    80000b28:	4595                	li	a1,5
    80000b2a:	8526                	mv	a0,s1
    80000b2c:	00000097          	auipc	ra,0x0
    80000b30:	1b2080e7          	jalr	434(ra) # 80000cde <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	00011517          	auipc	a0,0x11
    80000b44:	77050513          	addi	a0,a0,1904 # 800122b0 <kmem>
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	14e080e7          	jalr	334(ra) # 80000c96 <release>
  if(r)
    80000b50:	b7d5                	j	80000b34 <kalloc+0x42>

0000000080000b52 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b52:	1141                	addi	sp,sp,-16
    80000b54:	e422                	sd	s0,8(sp)
    80000b56:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b58:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b5a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5e:	00053823          	sd	zero,16(a0)
}
    80000b62:	6422                	ld	s0,8(sp)
    80000b64:	0141                	addi	sp,sp,16
    80000b66:	8082                	ret

0000000080000b68 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b68:	411c                	lw	a5,0(a0)
    80000b6a:	e399                	bnez	a5,80000b70 <holding+0x8>
    80000b6c:	4501                	li	a0,0
  return r;
}
    80000b6e:	8082                	ret
{
    80000b70:	1101                	addi	sp,sp,-32
    80000b72:	ec06                	sd	ra,24(sp)
    80000b74:	e822                	sd	s0,16(sp)
    80000b76:	e426                	sd	s1,8(sp)
    80000b78:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b7a:	6904                	ld	s1,16(a0)
    80000b7c:	00001097          	auipc	ra,0x1
    80000b80:	e3c080e7          	jalr	-452(ra) # 800019b8 <mycpu>
    80000b84:	40a48533          	sub	a0,s1,a0
    80000b88:	00153513          	seqz	a0,a0
}
    80000b8c:	60e2                	ld	ra,24(sp)
    80000b8e:	6442                	ld	s0,16(sp)
    80000b90:	64a2                	ld	s1,8(sp)
    80000b92:	6105                	addi	sp,sp,32
    80000b94:	8082                	ret

0000000080000b96 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b96:	1101                	addi	sp,sp,-32
    80000b98:	ec06                	sd	ra,24(sp)
    80000b9a:	e822                	sd	s0,16(sp)
    80000b9c:	e426                	sd	s1,8(sp)
    80000b9e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba0:	100024f3          	csrr	s1,sstatus
    80000ba4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000baa:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	e0a080e7          	jalr	-502(ra) # 800019b8 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	cf89                	beqz	a5,80000bd2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bba:	00001097          	auipc	ra,0x1
    80000bbe:	dfe080e7          	jalr	-514(ra) # 800019b8 <mycpu>
    80000bc2:	5d3c                	lw	a5,120(a0)
    80000bc4:	2785                	addiw	a5,a5,1
    80000bc6:	dd3c                	sw	a5,120(a0)
}
    80000bc8:	60e2                	ld	ra,24(sp)
    80000bca:	6442                	ld	s0,16(sp)
    80000bcc:	64a2                	ld	s1,8(sp)
    80000bce:	6105                	addi	sp,sp,32
    80000bd0:	8082                	ret
    mycpu()->intena = old;
    80000bd2:	00001097          	auipc	ra,0x1
    80000bd6:	de6080e7          	jalr	-538(ra) # 800019b8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bda:	8085                	srli	s1,s1,0x1
    80000bdc:	8885                	andi	s1,s1,1
    80000bde:	dd64                	sw	s1,124(a0)
    80000be0:	bfe9                	j	80000bba <push_off+0x24>

0000000080000be2 <acquire>:
{
    80000be2:	1101                	addi	sp,sp,-32
    80000be4:	ec06                	sd	ra,24(sp)
    80000be6:	e822                	sd	s0,16(sp)
    80000be8:	e426                	sd	s1,8(sp)
    80000bea:	1000                	addi	s0,sp,32
    80000bec:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bee:	00000097          	auipc	ra,0x0
    80000bf2:	fa8080e7          	jalr	-88(ra) # 80000b96 <push_off>
  if(holding(lk))
    80000bf6:	8526                	mv	a0,s1
    80000bf8:	00000097          	auipc	ra,0x0
    80000bfc:	f70080e7          	jalr	-144(ra) # 80000b68 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c00:	4705                	li	a4,1
  if(holding(lk))
    80000c02:	e115                	bnez	a0,80000c26 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c04:	87ba                	mv	a5,a4
    80000c06:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c0a:	2781                	sext.w	a5,a5
    80000c0c:	ffe5                	bnez	a5,80000c04 <acquire+0x22>
  __sync_synchronize();
    80000c0e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c12:	00001097          	auipc	ra,0x1
    80000c16:	da6080e7          	jalr	-602(ra) # 800019b8 <mycpu>
    80000c1a:	e888                	sd	a0,16(s1)
}
    80000c1c:	60e2                	ld	ra,24(sp)
    80000c1e:	6442                	ld	s0,16(sp)
    80000c20:	64a2                	ld	s1,8(sp)
    80000c22:	6105                	addi	sp,sp,32
    80000c24:	8082                	ret
    panic("acquire");
    80000c26:	00008517          	auipc	a0,0x8
    80000c2a:	44a50513          	addi	a0,a0,1098 # 80009070 <digits+0x30>
    80000c2e:	00000097          	auipc	ra,0x0
    80000c32:	90e080e7          	jalr	-1778(ra) # 8000053c <panic>

0000000080000c36 <pop_off>:

void
pop_off(void)
{
    80000c36:	1141                	addi	sp,sp,-16
    80000c38:	e406                	sd	ra,8(sp)
    80000c3a:	e022                	sd	s0,0(sp)
    80000c3c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c3e:	00001097          	auipc	ra,0x1
    80000c42:	d7a080e7          	jalr	-646(ra) # 800019b8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c46:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c4a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4c:	e78d                	bnez	a5,80000c76 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4e:	5d3c                	lw	a5,120(a0)
    80000c50:	02f05b63          	blez	a5,80000c86 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c54:	37fd                	addiw	a5,a5,-1
    80000c56:	0007871b          	sext.w	a4,a5
    80000c5a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5c:	eb09                	bnez	a4,80000c6e <pop_off+0x38>
    80000c5e:	5d7c                	lw	a5,124(a0)
    80000c60:	c799                	beqz	a5,80000c6e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c62:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c66:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6e:	60a2                	ld	ra,8(sp)
    80000c70:	6402                	ld	s0,0(sp)
    80000c72:	0141                	addi	sp,sp,16
    80000c74:	8082                	ret
    panic("pop_off - interruptible");
    80000c76:	00008517          	auipc	a0,0x8
    80000c7a:	40250513          	addi	a0,a0,1026 # 80009078 <digits+0x38>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>
    panic("pop_off");
    80000c86:	00008517          	auipc	a0,0x8
    80000c8a:	40a50513          	addi	a0,a0,1034 # 80009090 <digits+0x50>
    80000c8e:	00000097          	auipc	ra,0x0
    80000c92:	8ae080e7          	jalr	-1874(ra) # 8000053c <panic>

0000000080000c96 <release>:
{
    80000c96:	1101                	addi	sp,sp,-32
    80000c98:	ec06                	sd	ra,24(sp)
    80000c9a:	e822                	sd	s0,16(sp)
    80000c9c:	e426                	sd	s1,8(sp)
    80000c9e:	1000                	addi	s0,sp,32
    80000ca0:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca2:	00000097          	auipc	ra,0x0
    80000ca6:	ec6080e7          	jalr	-314(ra) # 80000b68 <holding>
    80000caa:	c115                	beqz	a0,80000cce <release+0x38>
  lk->cpu = 0;
    80000cac:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cb4:	0f50000f          	fence	iorw,ow
    80000cb8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cbc:	00000097          	auipc	ra,0x0
    80000cc0:	f7a080e7          	jalr	-134(ra) # 80000c36 <pop_off>
}
    80000cc4:	60e2                	ld	ra,24(sp)
    80000cc6:	6442                	ld	s0,16(sp)
    80000cc8:	64a2                	ld	s1,8(sp)
    80000cca:	6105                	addi	sp,sp,32
    80000ccc:	8082                	ret
    panic("release");
    80000cce:	00008517          	auipc	a0,0x8
    80000cd2:	3ca50513          	addi	a0,a0,970 # 80009098 <digits+0x58>
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	866080e7          	jalr	-1946(ra) # 8000053c <panic>

0000000080000cde <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cde:	1141                	addi	sp,sp,-16
    80000ce0:	e422                	sd	s0,8(sp)
    80000ce2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ce4:	ce09                	beqz	a2,80000cfe <memset+0x20>
    80000ce6:	87aa                	mv	a5,a0
    80000ce8:	fff6071b          	addiw	a4,a2,-1
    80000cec:	1702                	slli	a4,a4,0x20
    80000cee:	9301                	srli	a4,a4,0x20
    80000cf0:	0705                	addi	a4,a4,1
    80000cf2:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cf4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cf8:	0785                	addi	a5,a5,1
    80000cfa:	fee79de3          	bne	a5,a4,80000cf4 <memset+0x16>
  }
  return dst;
}
    80000cfe:	6422                	ld	s0,8(sp)
    80000d00:	0141                	addi	sp,sp,16
    80000d02:	8082                	ret

0000000080000d04 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d04:	1141                	addi	sp,sp,-16
    80000d06:	e422                	sd	s0,8(sp)
    80000d08:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0a:	ca05                	beqz	a2,80000d3a <memcmp+0x36>
    80000d0c:	fff6069b          	addiw	a3,a2,-1
    80000d10:	1682                	slli	a3,a3,0x20
    80000d12:	9281                	srli	a3,a3,0x20
    80000d14:	0685                	addi	a3,a3,1
    80000d16:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d18:	00054783          	lbu	a5,0(a0)
    80000d1c:	0005c703          	lbu	a4,0(a1)
    80000d20:	00e79863          	bne	a5,a4,80000d30 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d24:	0505                	addi	a0,a0,1
    80000d26:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d28:	fed518e3          	bne	a0,a3,80000d18 <memcmp+0x14>
  }

  return 0;
    80000d2c:	4501                	li	a0,0
    80000d2e:	a019                	j	80000d34 <memcmp+0x30>
      return *s1 - *s2;
    80000d30:	40e7853b          	subw	a0,a5,a4
}
    80000d34:	6422                	ld	s0,8(sp)
    80000d36:	0141                	addi	sp,sp,16
    80000d38:	8082                	ret
  return 0;
    80000d3a:	4501                	li	a0,0
    80000d3c:	bfe5                	j	80000d34 <memcmp+0x30>

0000000080000d3e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d3e:	1141                	addi	sp,sp,-16
    80000d40:	e422                	sd	s0,8(sp)
    80000d42:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d44:	ca0d                	beqz	a2,80000d76 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d46:	00a5f963          	bgeu	a1,a0,80000d58 <memmove+0x1a>
    80000d4a:	02061693          	slli	a3,a2,0x20
    80000d4e:	9281                	srli	a3,a3,0x20
    80000d50:	00d58733          	add	a4,a1,a3
    80000d54:	02e56463          	bltu	a0,a4,80000d7c <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d58:	fff6079b          	addiw	a5,a2,-1
    80000d5c:	1782                	slli	a5,a5,0x20
    80000d5e:	9381                	srli	a5,a5,0x20
    80000d60:	0785                	addi	a5,a5,1
    80000d62:	97ae                	add	a5,a5,a1
    80000d64:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d66:	0585                	addi	a1,a1,1
    80000d68:	0705                	addi	a4,a4,1
    80000d6a:	fff5c683          	lbu	a3,-1(a1)
    80000d6e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d72:	fef59ae3          	bne	a1,a5,80000d66 <memmove+0x28>

  return dst;
}
    80000d76:	6422                	ld	s0,8(sp)
    80000d78:	0141                	addi	sp,sp,16
    80000d7a:	8082                	ret
    d += n;
    80000d7c:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d7e:	fff6079b          	addiw	a5,a2,-1
    80000d82:	1782                	slli	a5,a5,0x20
    80000d84:	9381                	srli	a5,a5,0x20
    80000d86:	fff7c793          	not	a5,a5
    80000d8a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d8c:	177d                	addi	a4,a4,-1
    80000d8e:	16fd                	addi	a3,a3,-1
    80000d90:	00074603          	lbu	a2,0(a4)
    80000d94:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d98:	fef71ae3          	bne	a4,a5,80000d8c <memmove+0x4e>
    80000d9c:	bfe9                	j	80000d76 <memmove+0x38>

0000000080000d9e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e406                	sd	ra,8(sp)
    80000da2:	e022                	sd	s0,0(sp)
    80000da4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da6:	00000097          	auipc	ra,0x0
    80000daa:	f98080e7          	jalr	-104(ra) # 80000d3e <memmove>
}
    80000dae:	60a2                	ld	ra,8(sp)
    80000db0:	6402                	ld	s0,0(sp)
    80000db2:	0141                	addi	sp,sp,16
    80000db4:	8082                	ret

0000000080000db6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db6:	1141                	addi	sp,sp,-16
    80000db8:	e422                	sd	s0,8(sp)
    80000dba:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dbc:	ce11                	beqz	a2,80000dd8 <strncmp+0x22>
    80000dbe:	00054783          	lbu	a5,0(a0)
    80000dc2:	cf89                	beqz	a5,80000ddc <strncmp+0x26>
    80000dc4:	0005c703          	lbu	a4,0(a1)
    80000dc8:	00f71a63          	bne	a4,a5,80000ddc <strncmp+0x26>
    n--, p++, q++;
    80000dcc:	367d                	addiw	a2,a2,-1
    80000dce:	0505                	addi	a0,a0,1
    80000dd0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd2:	f675                	bnez	a2,80000dbe <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dd4:	4501                	li	a0,0
    80000dd6:	a809                	j	80000de8 <strncmp+0x32>
    80000dd8:	4501                	li	a0,0
    80000dda:	a039                	j	80000de8 <strncmp+0x32>
  if(n == 0)
    80000ddc:	ca09                	beqz	a2,80000dee <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dde:	00054503          	lbu	a0,0(a0)
    80000de2:	0005c783          	lbu	a5,0(a1)
    80000de6:	9d1d                	subw	a0,a0,a5
}
    80000de8:	6422                	ld	s0,8(sp)
    80000dea:	0141                	addi	sp,sp,16
    80000dec:	8082                	ret
    return 0;
    80000dee:	4501                	li	a0,0
    80000df0:	bfe5                	j	80000de8 <strncmp+0x32>

0000000080000df2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df2:	1141                	addi	sp,sp,-16
    80000df4:	e422                	sd	s0,8(sp)
    80000df6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000df8:	872a                	mv	a4,a0
    80000dfa:	8832                	mv	a6,a2
    80000dfc:	367d                	addiw	a2,a2,-1
    80000dfe:	01005963          	blez	a6,80000e10 <strncpy+0x1e>
    80000e02:	0705                	addi	a4,a4,1
    80000e04:	0005c783          	lbu	a5,0(a1)
    80000e08:	fef70fa3          	sb	a5,-1(a4)
    80000e0c:	0585                	addi	a1,a1,1
    80000e0e:	f7f5                	bnez	a5,80000dfa <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e10:	00c05d63          	blez	a2,80000e2a <strncpy+0x38>
    80000e14:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e16:	0685                	addi	a3,a3,1
    80000e18:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e1c:	fff6c793          	not	a5,a3
    80000e20:	9fb9                	addw	a5,a5,a4
    80000e22:	010787bb          	addw	a5,a5,a6
    80000e26:	fef048e3          	bgtz	a5,80000e16 <strncpy+0x24>
  return os;
}
    80000e2a:	6422                	ld	s0,8(sp)
    80000e2c:	0141                	addi	sp,sp,16
    80000e2e:	8082                	ret

0000000080000e30 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e30:	1141                	addi	sp,sp,-16
    80000e32:	e422                	sd	s0,8(sp)
    80000e34:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e36:	02c05363          	blez	a2,80000e5c <safestrcpy+0x2c>
    80000e3a:	fff6069b          	addiw	a3,a2,-1
    80000e3e:	1682                	slli	a3,a3,0x20
    80000e40:	9281                	srli	a3,a3,0x20
    80000e42:	96ae                	add	a3,a3,a1
    80000e44:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e46:	00d58963          	beq	a1,a3,80000e58 <safestrcpy+0x28>
    80000e4a:	0585                	addi	a1,a1,1
    80000e4c:	0785                	addi	a5,a5,1
    80000e4e:	fff5c703          	lbu	a4,-1(a1)
    80000e52:	fee78fa3          	sb	a4,-1(a5)
    80000e56:	fb65                	bnez	a4,80000e46 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e58:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e5c:	6422                	ld	s0,8(sp)
    80000e5e:	0141                	addi	sp,sp,16
    80000e60:	8082                	ret

0000000080000e62 <strlen>:

int
strlen(const char *s)
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e422                	sd	s0,8(sp)
    80000e66:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e68:	00054783          	lbu	a5,0(a0)
    80000e6c:	cf91                	beqz	a5,80000e88 <strlen+0x26>
    80000e6e:	0505                	addi	a0,a0,1
    80000e70:	87aa                	mv	a5,a0
    80000e72:	4685                	li	a3,1
    80000e74:	9e89                	subw	a3,a3,a0
    80000e76:	00f6853b          	addw	a0,a3,a5
    80000e7a:	0785                	addi	a5,a5,1
    80000e7c:	fff7c703          	lbu	a4,-1(a5)
    80000e80:	fb7d                	bnez	a4,80000e76 <strlen+0x14>
    ;
  return n;
}
    80000e82:	6422                	ld	s0,8(sp)
    80000e84:	0141                	addi	sp,sp,16
    80000e86:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e88:	4501                	li	a0,0
    80000e8a:	bfe5                	j	80000e82 <strlen+0x20>

0000000080000e8c <main>:
extern struct barr barrier_arr[10];

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e8c:	1141                	addi	sp,sp,-16
    80000e8e:	e406                	sd	ra,8(sp)
    80000e90:	e022                	sd	s0,0(sp)
    80000e92:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e94:	00001097          	auipc	ra,0x1
    80000e98:	b14080e7          	jalr	-1260(ra) # 800019a8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e9c:	00009717          	auipc	a4,0x9
    80000ea0:	17c70713          	addi	a4,a4,380 # 8000a018 <started>
  if(cpuid() == 0){
    80000ea4:	c535                	beqz	a0,80000f10 <main+0x84>
    while(started == 0)
    80000ea6:	431c                	lw	a5,0(a4)
    80000ea8:	2781                	sext.w	a5,a5
    80000eaa:	dff5                	beqz	a5,80000ea6 <main+0x1a>
      ;
    __sync_synchronize();
    80000eac:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb0:	00001097          	auipc	ra,0x1
    80000eb4:	af8080e7          	jalr	-1288(ra) # 800019a8 <cpuid>
    80000eb8:	85aa                	mv	a1,a0
    80000eba:	00008517          	auipc	a0,0x8
    80000ebe:	1fe50513          	addi	a0,a0,510 # 800090b8 <digits+0x78>
    80000ec2:	fffff097          	auipc	ra,0xfffff
    80000ec6:	6c4080e7          	jalr	1732(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eca:	00000097          	auipc	ra,0x0
    80000ece:	0fe080e7          	jalr	254(ra) # 80000fc8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed2:	00003097          	auipc	ra,0x3
    80000ed6:	890080e7          	jalr	-1904(ra) # 80003762 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eda:	00006097          	auipc	ra,0x6
    80000ede:	1e6080e7          	jalr	486(ra) # 800070c0 <plicinithart>
  }

  sched_policy = SCHED_PREEMPT_RR;
    80000ee2:	4789                	li	a5,2
    80000ee4:	00009717          	auipc	a4,0x9
    80000ee8:	18f72223          	sw	a5,388(a4) # 8000a068 <sched_policy>

  for(int i=0; i<10; i++){
    80000eec:	00018797          	auipc	a5,0x18
    80000ef0:	c2c78793          	addi	a5,a5,-980 # 80018b18 <barrier_arr>
    80000ef4:	00018697          	auipc	a3,0x18
    80000ef8:	ea468693          	addi	a3,a3,-348 # 80018d98 <bcache>
    barrier_arr[i].count = -1;
    80000efc:	577d                	li	a4,-1
    80000efe:	c398                	sw	a4,0(a5)
  for(int i=0; i<10; i++){
    80000f00:	04078793          	addi	a5,a5,64
    80000f04:	fed79de3          	bne	a5,a3,80000efe <main+0x72>
  }

  scheduler();        
    80000f08:	00001097          	auipc	ra,0x1
    80000f0c:	30c080e7          	jalr	780(ra) # 80002214 <scheduler>
    consoleinit();
    80000f10:	fffff097          	auipc	ra,0xfffff
    80000f14:	53e080e7          	jalr	1342(ra) # 8000044e <consoleinit>
    printfinit();
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	854080e7          	jalr	-1964(ra) # 8000076c <printfinit>
    printf("\n");
    80000f20:	00009517          	auipc	a0,0x9
    80000f24:	84050513          	addi	a0,a0,-1984 # 80009760 <syscalls+0x120>
    80000f28:	fffff097          	auipc	ra,0xfffff
    80000f2c:	65e080e7          	jalr	1630(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000f30:	00008517          	auipc	a0,0x8
    80000f34:	17050513          	addi	a0,a0,368 # 800090a0 <digits+0x60>
    80000f38:	fffff097          	auipc	ra,0xfffff
    80000f3c:	64e080e7          	jalr	1614(ra) # 80000586 <printf>
    printf("\n");
    80000f40:	00009517          	auipc	a0,0x9
    80000f44:	82050513          	addi	a0,a0,-2016 # 80009760 <syscalls+0x120>
    80000f48:	fffff097          	auipc	ra,0xfffff
    80000f4c:	63e080e7          	jalr	1598(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f50:	00000097          	auipc	ra,0x0
    80000f54:	b66080e7          	jalr	-1178(ra) # 80000ab6 <kinit>
    kvminit();       // create kernel page table
    80000f58:	00000097          	auipc	ra,0x0
    80000f5c:	322080e7          	jalr	802(ra) # 8000127a <kvminit>
    kvminithart();   // turn on paging
    80000f60:	00000097          	auipc	ra,0x0
    80000f64:	068080e7          	jalr	104(ra) # 80000fc8 <kvminithart>
    procinit();      // process table
    80000f68:	00001097          	auipc	ra,0x1
    80000f6c:	990080e7          	jalr	-1648(ra) # 800018f8 <procinit>
    trapinit();      // trap vectors
    80000f70:	00002097          	auipc	ra,0x2
    80000f74:	7ca080e7          	jalr	1994(ra) # 8000373a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f78:	00002097          	auipc	ra,0x2
    80000f7c:	7ea080e7          	jalr	2026(ra) # 80003762 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f80:	00006097          	auipc	ra,0x6
    80000f84:	12a080e7          	jalr	298(ra) # 800070aa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f88:	00006097          	auipc	ra,0x6
    80000f8c:	138080e7          	jalr	312(ra) # 800070c0 <plicinithart>
    binit();         // buffer cache
    80000f90:	00003097          	auipc	ra,0x3
    80000f94:	312080e7          	jalr	786(ra) # 800042a2 <binit>
    iinit();         // inode table
    80000f98:	00004097          	auipc	ra,0x4
    80000f9c:	9a2080e7          	jalr	-1630(ra) # 8000493a <iinit>
    fileinit();      // file table
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	94c080e7          	jalr	-1716(ra) # 800058ec <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fa8:	00006097          	auipc	ra,0x6
    80000fac:	23a080e7          	jalr	570(ra) # 800071e2 <virtio_disk_init>
    userinit();      // first user process
    80000fb0:	00001097          	auipc	ra,0x1
    80000fb4:	d72080e7          	jalr	-654(ra) # 80001d22 <userinit>
    __sync_synchronize();
    80000fb8:	0ff0000f          	fence
    started = 1;
    80000fbc:	4785                	li	a5,1
    80000fbe:	00009717          	auipc	a4,0x9
    80000fc2:	04f72d23          	sw	a5,90(a4) # 8000a018 <started>
    80000fc6:	bf31                	j	80000ee2 <main+0x56>

0000000080000fc8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fc8:	1141                	addi	sp,sp,-16
    80000fca:	e422                	sd	s0,8(sp)
    80000fcc:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fce:	00009797          	auipc	a5,0x9
    80000fd2:	0527b783          	ld	a5,82(a5) # 8000a020 <kernel_pagetable>
    80000fd6:	83b1                	srli	a5,a5,0xc
    80000fd8:	577d                	li	a4,-1
    80000fda:	177e                	slli	a4,a4,0x3f
    80000fdc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fde:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fe2:	12000073          	sfence.vma
  sfence_vma();
}
    80000fe6:	6422                	ld	s0,8(sp)
    80000fe8:	0141                	addi	sp,sp,16
    80000fea:	8082                	ret

0000000080000fec <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fec:	7139                	addi	sp,sp,-64
    80000fee:	fc06                	sd	ra,56(sp)
    80000ff0:	f822                	sd	s0,48(sp)
    80000ff2:	f426                	sd	s1,40(sp)
    80000ff4:	f04a                	sd	s2,32(sp)
    80000ff6:	ec4e                	sd	s3,24(sp)
    80000ff8:	e852                	sd	s4,16(sp)
    80000ffa:	e456                	sd	s5,8(sp)
    80000ffc:	e05a                	sd	s6,0(sp)
    80000ffe:	0080                	addi	s0,sp,64
    80001000:	84aa                	mv	s1,a0
    80001002:	89ae                	mv	s3,a1
    80001004:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001006:	57fd                	li	a5,-1
    80001008:	83e9                	srli	a5,a5,0x1a
    8000100a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000100c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000100e:	04b7f263          	bgeu	a5,a1,80001052 <walk+0x66>
    panic("walk");
    80001012:	00008517          	auipc	a0,0x8
    80001016:	0be50513          	addi	a0,a0,190 # 800090d0 <digits+0x90>
    8000101a:	fffff097          	auipc	ra,0xfffff
    8000101e:	522080e7          	jalr	1314(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001022:	060a8663          	beqz	s5,8000108e <walk+0xa2>
    80001026:	00000097          	auipc	ra,0x0
    8000102a:	acc080e7          	jalr	-1332(ra) # 80000af2 <kalloc>
    8000102e:	84aa                	mv	s1,a0
    80001030:	c529                	beqz	a0,8000107a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001032:	6605                	lui	a2,0x1
    80001034:	4581                	li	a1,0
    80001036:	00000097          	auipc	ra,0x0
    8000103a:	ca8080e7          	jalr	-856(ra) # 80000cde <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000103e:	00c4d793          	srli	a5,s1,0xc
    80001042:	07aa                	slli	a5,a5,0xa
    80001044:	0017e793          	ori	a5,a5,1
    80001048:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000104c:	3a5d                	addiw	s4,s4,-9
    8000104e:	036a0063          	beq	s4,s6,8000106e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001052:	0149d933          	srl	s2,s3,s4
    80001056:	1ff97913          	andi	s2,s2,511
    8000105a:	090e                	slli	s2,s2,0x3
    8000105c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000105e:	00093483          	ld	s1,0(s2)
    80001062:	0014f793          	andi	a5,s1,1
    80001066:	dfd5                	beqz	a5,80001022 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001068:	80a9                	srli	s1,s1,0xa
    8000106a:	04b2                	slli	s1,s1,0xc
    8000106c:	b7c5                	j	8000104c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000106e:	00c9d513          	srli	a0,s3,0xc
    80001072:	1ff57513          	andi	a0,a0,511
    80001076:	050e                	slli	a0,a0,0x3
    80001078:	9526                	add	a0,a0,s1
}
    8000107a:	70e2                	ld	ra,56(sp)
    8000107c:	7442                	ld	s0,48(sp)
    8000107e:	74a2                	ld	s1,40(sp)
    80001080:	7902                	ld	s2,32(sp)
    80001082:	69e2                	ld	s3,24(sp)
    80001084:	6a42                	ld	s4,16(sp)
    80001086:	6aa2                	ld	s5,8(sp)
    80001088:	6b02                	ld	s6,0(sp)
    8000108a:	6121                	addi	sp,sp,64
    8000108c:	8082                	ret
        return 0;
    8000108e:	4501                	li	a0,0
    80001090:	b7ed                	j	8000107a <walk+0x8e>

0000000080001092 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001092:	57fd                	li	a5,-1
    80001094:	83e9                	srli	a5,a5,0x1a
    80001096:	00b7f463          	bgeu	a5,a1,8000109e <walkaddr+0xc>
    return 0;
    8000109a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000109c:	8082                	ret
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010a6:	4601                	li	a2,0
    800010a8:	00000097          	auipc	ra,0x0
    800010ac:	f44080e7          	jalr	-188(ra) # 80000fec <walk>
  if(pte == 0)
    800010b0:	c105                	beqz	a0,800010d0 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010b2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010b4:	0117f693          	andi	a3,a5,17
    800010b8:	4745                	li	a4,17
    return 0;
    800010ba:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010bc:	00e68663          	beq	a3,a4,800010c8 <walkaddr+0x36>
}
    800010c0:	60a2                	ld	ra,8(sp)
    800010c2:	6402                	ld	s0,0(sp)
    800010c4:	0141                	addi	sp,sp,16
    800010c6:	8082                	ret
  pa = PTE2PA(*pte);
    800010c8:	00a7d513          	srli	a0,a5,0xa
    800010cc:	0532                	slli	a0,a0,0xc
  return pa;
    800010ce:	bfcd                	j	800010c0 <walkaddr+0x2e>
    return 0;
    800010d0:	4501                	li	a0,0
    800010d2:	b7fd                	j	800010c0 <walkaddr+0x2e>

00000000800010d4 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010d4:	715d                	addi	sp,sp,-80
    800010d6:	e486                	sd	ra,72(sp)
    800010d8:	e0a2                	sd	s0,64(sp)
    800010da:	fc26                	sd	s1,56(sp)
    800010dc:	f84a                	sd	s2,48(sp)
    800010de:	f44e                	sd	s3,40(sp)
    800010e0:	f052                	sd	s4,32(sp)
    800010e2:	ec56                	sd	s5,24(sp)
    800010e4:	e85a                	sd	s6,16(sp)
    800010e6:	e45e                	sd	s7,8(sp)
    800010e8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ea:	c205                	beqz	a2,8000110a <mappages+0x36>
    800010ec:	8aaa                	mv	s5,a0
    800010ee:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010f0:	77fd                	lui	a5,0xfffff
    800010f2:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010f6:	15fd                	addi	a1,a1,-1
    800010f8:	00c589b3          	add	s3,a1,a2
    800010fc:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    80001100:	8952                	mv	s2,s4
    80001102:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001106:	6b85                	lui	s7,0x1
    80001108:	a015                	j	8000112c <mappages+0x58>
    panic("mappages: size");
    8000110a:	00008517          	auipc	a0,0x8
    8000110e:	fce50513          	addi	a0,a0,-50 # 800090d8 <digits+0x98>
    80001112:	fffff097          	auipc	ra,0xfffff
    80001116:	42a080e7          	jalr	1066(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000111a:	00008517          	auipc	a0,0x8
    8000111e:	fce50513          	addi	a0,a0,-50 # 800090e8 <digits+0xa8>
    80001122:	fffff097          	auipc	ra,0xfffff
    80001126:	41a080e7          	jalr	1050(ra) # 8000053c <panic>
    a += PGSIZE;
    8000112a:	995e                	add	s2,s2,s7
  for(;;){
    8000112c:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001130:	4605                	li	a2,1
    80001132:	85ca                	mv	a1,s2
    80001134:	8556                	mv	a0,s5
    80001136:	00000097          	auipc	ra,0x0
    8000113a:	eb6080e7          	jalr	-330(ra) # 80000fec <walk>
    8000113e:	cd19                	beqz	a0,8000115c <mappages+0x88>
    if(*pte & PTE_V)
    80001140:	611c                	ld	a5,0(a0)
    80001142:	8b85                	andi	a5,a5,1
    80001144:	fbf9                	bnez	a5,8000111a <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001146:	80b1                	srli	s1,s1,0xc
    80001148:	04aa                	slli	s1,s1,0xa
    8000114a:	0164e4b3          	or	s1,s1,s6
    8000114e:	0014e493          	ori	s1,s1,1
    80001152:	e104                	sd	s1,0(a0)
    if(a == last)
    80001154:	fd391be3          	bne	s2,s3,8000112a <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80001158:	4501                	li	a0,0
    8000115a:	a011                	j	8000115e <mappages+0x8a>
      return -1;
    8000115c:	557d                	li	a0,-1
}
    8000115e:	60a6                	ld	ra,72(sp)
    80001160:	6406                	ld	s0,64(sp)
    80001162:	74e2                	ld	s1,56(sp)
    80001164:	7942                	ld	s2,48(sp)
    80001166:	79a2                	ld	s3,40(sp)
    80001168:	7a02                	ld	s4,32(sp)
    8000116a:	6ae2                	ld	s5,24(sp)
    8000116c:	6b42                	ld	s6,16(sp)
    8000116e:	6ba2                	ld	s7,8(sp)
    80001170:	6161                	addi	sp,sp,80
    80001172:	8082                	ret

0000000080001174 <kvmmap>:
{
    80001174:	1141                	addi	sp,sp,-16
    80001176:	e406                	sd	ra,8(sp)
    80001178:	e022                	sd	s0,0(sp)
    8000117a:	0800                	addi	s0,sp,16
    8000117c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000117e:	86b2                	mv	a3,a2
    80001180:	863e                	mv	a2,a5
    80001182:	00000097          	auipc	ra,0x0
    80001186:	f52080e7          	jalr	-174(ra) # 800010d4 <mappages>
    8000118a:	e509                	bnez	a0,80001194 <kvmmap+0x20>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret
    panic("kvmmap");
    80001194:	00008517          	auipc	a0,0x8
    80001198:	f6450513          	addi	a0,a0,-156 # 800090f8 <digits+0xb8>
    8000119c:	fffff097          	auipc	ra,0xfffff
    800011a0:	3a0080e7          	jalr	928(ra) # 8000053c <panic>

00000000800011a4 <kvmmake>:
{
    800011a4:	1101                	addi	sp,sp,-32
    800011a6:	ec06                	sd	ra,24(sp)
    800011a8:	e822                	sd	s0,16(sp)
    800011aa:	e426                	sd	s1,8(sp)
    800011ac:	e04a                	sd	s2,0(sp)
    800011ae:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011b0:	00000097          	auipc	ra,0x0
    800011b4:	942080e7          	jalr	-1726(ra) # 80000af2 <kalloc>
    800011b8:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011ba:	6605                	lui	a2,0x1
    800011bc:	4581                	li	a1,0
    800011be:	00000097          	auipc	ra,0x0
    800011c2:	b20080e7          	jalr	-1248(ra) # 80000cde <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011c6:	4719                	li	a4,6
    800011c8:	6685                	lui	a3,0x1
    800011ca:	10000637          	lui	a2,0x10000
    800011ce:	100005b7          	lui	a1,0x10000
    800011d2:	8526                	mv	a0,s1
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	fa0080e7          	jalr	-96(ra) # 80001174 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011dc:	4719                	li	a4,6
    800011de:	6685                	lui	a3,0x1
    800011e0:	10001637          	lui	a2,0x10001
    800011e4:	100015b7          	lui	a1,0x10001
    800011e8:	8526                	mv	a0,s1
    800011ea:	00000097          	auipc	ra,0x0
    800011ee:	f8a080e7          	jalr	-118(ra) # 80001174 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011f2:	4719                	li	a4,6
    800011f4:	004006b7          	lui	a3,0x400
    800011f8:	0c000637          	lui	a2,0xc000
    800011fc:	0c0005b7          	lui	a1,0xc000
    80001200:	8526                	mv	a0,s1
    80001202:	00000097          	auipc	ra,0x0
    80001206:	f72080e7          	jalr	-142(ra) # 80001174 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000120a:	00008917          	auipc	s2,0x8
    8000120e:	df690913          	addi	s2,s2,-522 # 80009000 <etext>
    80001212:	4729                	li	a4,10
    80001214:	80008697          	auipc	a3,0x80008
    80001218:	dec68693          	addi	a3,a3,-532 # 9000 <_entry-0x7fff7000>
    8000121c:	4605                	li	a2,1
    8000121e:	067e                	slli	a2,a2,0x1f
    80001220:	85b2                	mv	a1,a2
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f50080e7          	jalr	-176(ra) # 80001174 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000122c:	4719                	li	a4,6
    8000122e:	46c5                	li	a3,17
    80001230:	06ee                	slli	a3,a3,0x1b
    80001232:	412686b3          	sub	a3,a3,s2
    80001236:	864a                	mv	a2,s2
    80001238:	85ca                	mv	a1,s2
    8000123a:	8526                	mv	a0,s1
    8000123c:	00000097          	auipc	ra,0x0
    80001240:	f38080e7          	jalr	-200(ra) # 80001174 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001244:	4729                	li	a4,10
    80001246:	6685                	lui	a3,0x1
    80001248:	00007617          	auipc	a2,0x7
    8000124c:	db860613          	addi	a2,a2,-584 # 80008000 <_trampoline>
    80001250:	040005b7          	lui	a1,0x4000
    80001254:	15fd                	addi	a1,a1,-1
    80001256:	05b2                	slli	a1,a1,0xc
    80001258:	8526                	mv	a0,s1
    8000125a:	00000097          	auipc	ra,0x0
    8000125e:	f1a080e7          	jalr	-230(ra) # 80001174 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001262:	8526                	mv	a0,s1
    80001264:	00000097          	auipc	ra,0x0
    80001268:	5fe080e7          	jalr	1534(ra) # 80001862 <proc_mapstacks>
}
    8000126c:	8526                	mv	a0,s1
    8000126e:	60e2                	ld	ra,24(sp)
    80001270:	6442                	ld	s0,16(sp)
    80001272:	64a2                	ld	s1,8(sp)
    80001274:	6902                	ld	s2,0(sp)
    80001276:	6105                	addi	sp,sp,32
    80001278:	8082                	ret

000000008000127a <kvminit>:
{
    8000127a:	1141                	addi	sp,sp,-16
    8000127c:	e406                	sd	ra,8(sp)
    8000127e:	e022                	sd	s0,0(sp)
    80001280:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001282:	00000097          	auipc	ra,0x0
    80001286:	f22080e7          	jalr	-222(ra) # 800011a4 <kvmmake>
    8000128a:	00009797          	auipc	a5,0x9
    8000128e:	d8a7bb23          	sd	a0,-618(a5) # 8000a020 <kernel_pagetable>
}
    80001292:	60a2                	ld	ra,8(sp)
    80001294:	6402                	ld	s0,0(sp)
    80001296:	0141                	addi	sp,sp,16
    80001298:	8082                	ret

000000008000129a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000129a:	715d                	addi	sp,sp,-80
    8000129c:	e486                	sd	ra,72(sp)
    8000129e:	e0a2                	sd	s0,64(sp)
    800012a0:	fc26                	sd	s1,56(sp)
    800012a2:	f84a                	sd	s2,48(sp)
    800012a4:	f44e                	sd	s3,40(sp)
    800012a6:	f052                	sd	s4,32(sp)
    800012a8:	ec56                	sd	s5,24(sp)
    800012aa:	e85a                	sd	s6,16(sp)
    800012ac:	e45e                	sd	s7,8(sp)
    800012ae:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012b0:	03459793          	slli	a5,a1,0x34
    800012b4:	e795                	bnez	a5,800012e0 <uvmunmap+0x46>
    800012b6:	8a2a                	mv	s4,a0
    800012b8:	892e                	mv	s2,a1
    800012ba:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012bc:	0632                	slli	a2,a2,0xc
    800012be:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012c2:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012c4:	6b05                	lui	s6,0x1
    800012c6:	0735e863          	bltu	a1,s3,80001336 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012ca:	60a6                	ld	ra,72(sp)
    800012cc:	6406                	ld	s0,64(sp)
    800012ce:	74e2                	ld	s1,56(sp)
    800012d0:	7942                	ld	s2,48(sp)
    800012d2:	79a2                	ld	s3,40(sp)
    800012d4:	7a02                	ld	s4,32(sp)
    800012d6:	6ae2                	ld	s5,24(sp)
    800012d8:	6b42                	ld	s6,16(sp)
    800012da:	6ba2                	ld	s7,8(sp)
    800012dc:	6161                	addi	sp,sp,80
    800012de:	8082                	ret
    panic("uvmunmap: not aligned");
    800012e0:	00008517          	auipc	a0,0x8
    800012e4:	e2050513          	addi	a0,a0,-480 # 80009100 <digits+0xc0>
    800012e8:	fffff097          	auipc	ra,0xfffff
    800012ec:	254080e7          	jalr	596(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012f0:	00008517          	auipc	a0,0x8
    800012f4:	e2850513          	addi	a0,a0,-472 # 80009118 <digits+0xd8>
    800012f8:	fffff097          	auipc	ra,0xfffff
    800012fc:	244080e7          	jalr	580(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    80001300:	00008517          	auipc	a0,0x8
    80001304:	e2850513          	addi	a0,a0,-472 # 80009128 <digits+0xe8>
    80001308:	fffff097          	auipc	ra,0xfffff
    8000130c:	234080e7          	jalr	564(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    80001310:	00008517          	auipc	a0,0x8
    80001314:	e3050513          	addi	a0,a0,-464 # 80009140 <digits+0x100>
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	224080e7          	jalr	548(ra) # 8000053c <panic>
      uint64 pa = PTE2PA(*pte);
    80001320:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001322:	0532                	slli	a0,a0,0xc
    80001324:	fffff097          	auipc	ra,0xfffff
    80001328:	6d2080e7          	jalr	1746(ra) # 800009f6 <kfree>
    *pte = 0;
    8000132c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001330:	995a                	add	s2,s2,s6
    80001332:	f9397ce3          	bgeu	s2,s3,800012ca <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001336:	4601                	li	a2,0
    80001338:	85ca                	mv	a1,s2
    8000133a:	8552                	mv	a0,s4
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	cb0080e7          	jalr	-848(ra) # 80000fec <walk>
    80001344:	84aa                	mv	s1,a0
    80001346:	d54d                	beqz	a0,800012f0 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001348:	6108                	ld	a0,0(a0)
    8000134a:	00157793          	andi	a5,a0,1
    8000134e:	dbcd                	beqz	a5,80001300 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001350:	3ff57793          	andi	a5,a0,1023
    80001354:	fb778ee3          	beq	a5,s7,80001310 <uvmunmap+0x76>
    if(do_free){
    80001358:	fc0a8ae3          	beqz	s5,8000132c <uvmunmap+0x92>
    8000135c:	b7d1                	j	80001320 <uvmunmap+0x86>

000000008000135e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000135e:	1101                	addi	sp,sp,-32
    80001360:	ec06                	sd	ra,24(sp)
    80001362:	e822                	sd	s0,16(sp)
    80001364:	e426                	sd	s1,8(sp)
    80001366:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001368:	fffff097          	auipc	ra,0xfffff
    8000136c:	78a080e7          	jalr	1930(ra) # 80000af2 <kalloc>
    80001370:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001372:	c519                	beqz	a0,80001380 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001374:	6605                	lui	a2,0x1
    80001376:	4581                	li	a1,0
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	966080e7          	jalr	-1690(ra) # 80000cde <memset>
  return pagetable;
}
    80001380:	8526                	mv	a0,s1
    80001382:	60e2                	ld	ra,24(sp)
    80001384:	6442                	ld	s0,16(sp)
    80001386:	64a2                	ld	s1,8(sp)
    80001388:	6105                	addi	sp,sp,32
    8000138a:	8082                	ret

000000008000138c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000138c:	7179                	addi	sp,sp,-48
    8000138e:	f406                	sd	ra,40(sp)
    80001390:	f022                	sd	s0,32(sp)
    80001392:	ec26                	sd	s1,24(sp)
    80001394:	e84a                	sd	s2,16(sp)
    80001396:	e44e                	sd	s3,8(sp)
    80001398:	e052                	sd	s4,0(sp)
    8000139a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000139c:	6785                	lui	a5,0x1
    8000139e:	04f67863          	bgeu	a2,a5,800013ee <uvminit+0x62>
    800013a2:	8a2a                	mv	s4,a0
    800013a4:	89ae                	mv	s3,a1
    800013a6:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013a8:	fffff097          	auipc	ra,0xfffff
    800013ac:	74a080e7          	jalr	1866(ra) # 80000af2 <kalloc>
    800013b0:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013b2:	6605                	lui	a2,0x1
    800013b4:	4581                	li	a1,0
    800013b6:	00000097          	auipc	ra,0x0
    800013ba:	928080e7          	jalr	-1752(ra) # 80000cde <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013be:	4779                	li	a4,30
    800013c0:	86ca                	mv	a3,s2
    800013c2:	6605                	lui	a2,0x1
    800013c4:	4581                	li	a1,0
    800013c6:	8552                	mv	a0,s4
    800013c8:	00000097          	auipc	ra,0x0
    800013cc:	d0c080e7          	jalr	-756(ra) # 800010d4 <mappages>
  memmove(mem, src, sz);
    800013d0:	8626                	mv	a2,s1
    800013d2:	85ce                	mv	a1,s3
    800013d4:	854a                	mv	a0,s2
    800013d6:	00000097          	auipc	ra,0x0
    800013da:	968080e7          	jalr	-1688(ra) # 80000d3e <memmove>
}
    800013de:	70a2                	ld	ra,40(sp)
    800013e0:	7402                	ld	s0,32(sp)
    800013e2:	64e2                	ld	s1,24(sp)
    800013e4:	6942                	ld	s2,16(sp)
    800013e6:	69a2                	ld	s3,8(sp)
    800013e8:	6a02                	ld	s4,0(sp)
    800013ea:	6145                	addi	sp,sp,48
    800013ec:	8082                	ret
    panic("inituvm: more than a page");
    800013ee:	00008517          	auipc	a0,0x8
    800013f2:	d6a50513          	addi	a0,a0,-662 # 80009158 <digits+0x118>
    800013f6:	fffff097          	auipc	ra,0xfffff
    800013fa:	146080e7          	jalr	326(ra) # 8000053c <panic>

00000000800013fe <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013fe:	1101                	addi	sp,sp,-32
    80001400:	ec06                	sd	ra,24(sp)
    80001402:	e822                	sd	s0,16(sp)
    80001404:	e426                	sd	s1,8(sp)
    80001406:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001408:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000140a:	00b67d63          	bgeu	a2,a1,80001424 <uvmdealloc+0x26>
    8000140e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001410:	6785                	lui	a5,0x1
    80001412:	17fd                	addi	a5,a5,-1
    80001414:	00f60733          	add	a4,a2,a5
    80001418:	767d                	lui	a2,0xfffff
    8000141a:	8f71                	and	a4,a4,a2
    8000141c:	97ae                	add	a5,a5,a1
    8000141e:	8ff1                	and	a5,a5,a2
    80001420:	00f76863          	bltu	a4,a5,80001430 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001424:	8526                	mv	a0,s1
    80001426:	60e2                	ld	ra,24(sp)
    80001428:	6442                	ld	s0,16(sp)
    8000142a:	64a2                	ld	s1,8(sp)
    8000142c:	6105                	addi	sp,sp,32
    8000142e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001430:	8f99                	sub	a5,a5,a4
    80001432:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001434:	4685                	li	a3,1
    80001436:	0007861b          	sext.w	a2,a5
    8000143a:	85ba                	mv	a1,a4
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	e5e080e7          	jalr	-418(ra) # 8000129a <uvmunmap>
    80001444:	b7c5                	j	80001424 <uvmdealloc+0x26>

0000000080001446 <uvmalloc>:
  if(newsz < oldsz)
    80001446:	0ab66163          	bltu	a2,a1,800014e8 <uvmalloc+0xa2>
{
    8000144a:	7139                	addi	sp,sp,-64
    8000144c:	fc06                	sd	ra,56(sp)
    8000144e:	f822                	sd	s0,48(sp)
    80001450:	f426                	sd	s1,40(sp)
    80001452:	f04a                	sd	s2,32(sp)
    80001454:	ec4e                	sd	s3,24(sp)
    80001456:	e852                	sd	s4,16(sp)
    80001458:	e456                	sd	s5,8(sp)
    8000145a:	0080                	addi	s0,sp,64
    8000145c:	8aaa                	mv	s5,a0
    8000145e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001460:	6985                	lui	s3,0x1
    80001462:	19fd                	addi	s3,s3,-1
    80001464:	95ce                	add	a1,a1,s3
    80001466:	79fd                	lui	s3,0xfffff
    80001468:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146c:	08c9f063          	bgeu	s3,a2,800014ec <uvmalloc+0xa6>
    80001470:	894e                	mv	s2,s3
    mem = kalloc();
    80001472:	fffff097          	auipc	ra,0xfffff
    80001476:	680080e7          	jalr	1664(ra) # 80000af2 <kalloc>
    8000147a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000147c:	c51d                	beqz	a0,800014aa <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000147e:	6605                	lui	a2,0x1
    80001480:	4581                	li	a1,0
    80001482:	00000097          	auipc	ra,0x0
    80001486:	85c080e7          	jalr	-1956(ra) # 80000cde <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000148a:	4779                	li	a4,30
    8000148c:	86a6                	mv	a3,s1
    8000148e:	6605                	lui	a2,0x1
    80001490:	85ca                	mv	a1,s2
    80001492:	8556                	mv	a0,s5
    80001494:	00000097          	auipc	ra,0x0
    80001498:	c40080e7          	jalr	-960(ra) # 800010d4 <mappages>
    8000149c:	e905                	bnez	a0,800014cc <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149e:	6785                	lui	a5,0x1
    800014a0:	993e                	add	s2,s2,a5
    800014a2:	fd4968e3          	bltu	s2,s4,80001472 <uvmalloc+0x2c>
  return newsz;
    800014a6:	8552                	mv	a0,s4
    800014a8:	a809                	j	800014ba <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014aa:	864e                	mv	a2,s3
    800014ac:	85ca                	mv	a1,s2
    800014ae:	8556                	mv	a0,s5
    800014b0:	00000097          	auipc	ra,0x0
    800014b4:	f4e080e7          	jalr	-178(ra) # 800013fe <uvmdealloc>
      return 0;
    800014b8:	4501                	li	a0,0
}
    800014ba:	70e2                	ld	ra,56(sp)
    800014bc:	7442                	ld	s0,48(sp)
    800014be:	74a2                	ld	s1,40(sp)
    800014c0:	7902                	ld	s2,32(sp)
    800014c2:	69e2                	ld	s3,24(sp)
    800014c4:	6a42                	ld	s4,16(sp)
    800014c6:	6aa2                	ld	s5,8(sp)
    800014c8:	6121                	addi	sp,sp,64
    800014ca:	8082                	ret
      kfree(mem);
    800014cc:	8526                	mv	a0,s1
    800014ce:	fffff097          	auipc	ra,0xfffff
    800014d2:	528080e7          	jalr	1320(ra) # 800009f6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014d6:	864e                	mv	a2,s3
    800014d8:	85ca                	mv	a1,s2
    800014da:	8556                	mv	a0,s5
    800014dc:	00000097          	auipc	ra,0x0
    800014e0:	f22080e7          	jalr	-222(ra) # 800013fe <uvmdealloc>
      return 0;
    800014e4:	4501                	li	a0,0
    800014e6:	bfd1                	j	800014ba <uvmalloc+0x74>
    return oldsz;
    800014e8:	852e                	mv	a0,a1
}
    800014ea:	8082                	ret
  return newsz;
    800014ec:	8532                	mv	a0,a2
    800014ee:	b7f1                	j	800014ba <uvmalloc+0x74>

00000000800014f0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014f0:	7179                	addi	sp,sp,-48
    800014f2:	f406                	sd	ra,40(sp)
    800014f4:	f022                	sd	s0,32(sp)
    800014f6:	ec26                	sd	s1,24(sp)
    800014f8:	e84a                	sd	s2,16(sp)
    800014fa:	e44e                	sd	s3,8(sp)
    800014fc:	e052                	sd	s4,0(sp)
    800014fe:	1800                	addi	s0,sp,48
    80001500:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001502:	84aa                	mv	s1,a0
    80001504:	6905                	lui	s2,0x1
    80001506:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001508:	4985                	li	s3,1
    8000150a:	a821                	j	80001522 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000150c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000150e:	0532                	slli	a0,a0,0xc
    80001510:	00000097          	auipc	ra,0x0
    80001514:	fe0080e7          	jalr	-32(ra) # 800014f0 <freewalk>
      pagetable[i] = 0;
    80001518:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000151c:	04a1                	addi	s1,s1,8
    8000151e:	03248163          	beq	s1,s2,80001540 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001522:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001524:	00f57793          	andi	a5,a0,15
    80001528:	ff3782e3          	beq	a5,s3,8000150c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000152c:	8905                	andi	a0,a0,1
    8000152e:	d57d                	beqz	a0,8000151c <freewalk+0x2c>
      panic("freewalk: leaf");
    80001530:	00008517          	auipc	a0,0x8
    80001534:	c4850513          	addi	a0,a0,-952 # 80009178 <digits+0x138>
    80001538:	fffff097          	auipc	ra,0xfffff
    8000153c:	004080e7          	jalr	4(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    80001540:	8552                	mv	a0,s4
    80001542:	fffff097          	auipc	ra,0xfffff
    80001546:	4b4080e7          	jalr	1204(ra) # 800009f6 <kfree>
}
    8000154a:	70a2                	ld	ra,40(sp)
    8000154c:	7402                	ld	s0,32(sp)
    8000154e:	64e2                	ld	s1,24(sp)
    80001550:	6942                	ld	s2,16(sp)
    80001552:	69a2                	ld	s3,8(sp)
    80001554:	6a02                	ld	s4,0(sp)
    80001556:	6145                	addi	sp,sp,48
    80001558:	8082                	ret

000000008000155a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000155a:	1101                	addi	sp,sp,-32
    8000155c:	ec06                	sd	ra,24(sp)
    8000155e:	e822                	sd	s0,16(sp)
    80001560:	e426                	sd	s1,8(sp)
    80001562:	1000                	addi	s0,sp,32
    80001564:	84aa                	mv	s1,a0
  if(sz > 0)
    80001566:	e999                	bnez	a1,8000157c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001568:	8526                	mv	a0,s1
    8000156a:	00000097          	auipc	ra,0x0
    8000156e:	f86080e7          	jalr	-122(ra) # 800014f0 <freewalk>
}
    80001572:	60e2                	ld	ra,24(sp)
    80001574:	6442                	ld	s0,16(sp)
    80001576:	64a2                	ld	s1,8(sp)
    80001578:	6105                	addi	sp,sp,32
    8000157a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000157c:	6605                	lui	a2,0x1
    8000157e:	167d                	addi	a2,a2,-1
    80001580:	962e                	add	a2,a2,a1
    80001582:	4685                	li	a3,1
    80001584:	8231                	srli	a2,a2,0xc
    80001586:	4581                	li	a1,0
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	d12080e7          	jalr	-750(ra) # 8000129a <uvmunmap>
    80001590:	bfe1                	j	80001568 <uvmfree+0xe>

0000000080001592 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001592:	c679                	beqz	a2,80001660 <uvmcopy+0xce>
{
    80001594:	715d                	addi	sp,sp,-80
    80001596:	e486                	sd	ra,72(sp)
    80001598:	e0a2                	sd	s0,64(sp)
    8000159a:	fc26                	sd	s1,56(sp)
    8000159c:	f84a                	sd	s2,48(sp)
    8000159e:	f44e                	sd	s3,40(sp)
    800015a0:	f052                	sd	s4,32(sp)
    800015a2:	ec56                	sd	s5,24(sp)
    800015a4:	e85a                	sd	s6,16(sp)
    800015a6:	e45e                	sd	s7,8(sp)
    800015a8:	0880                	addi	s0,sp,80
    800015aa:	8b2a                	mv	s6,a0
    800015ac:	8aae                	mv	s5,a1
    800015ae:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015b0:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015b2:	4601                	li	a2,0
    800015b4:	85ce                	mv	a1,s3
    800015b6:	855a                	mv	a0,s6
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	a34080e7          	jalr	-1484(ra) # 80000fec <walk>
    800015c0:	c531                	beqz	a0,8000160c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015c2:	6118                	ld	a4,0(a0)
    800015c4:	00177793          	andi	a5,a4,1
    800015c8:	cbb1                	beqz	a5,8000161c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015ca:	00a75593          	srli	a1,a4,0xa
    800015ce:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015d2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	51c080e7          	jalr	1308(ra) # 80000af2 <kalloc>
    800015de:	892a                	mv	s2,a0
    800015e0:	c939                	beqz	a0,80001636 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015e2:	6605                	lui	a2,0x1
    800015e4:	85de                	mv	a1,s7
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	758080e7          	jalr	1880(ra) # 80000d3e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ee:	8726                	mv	a4,s1
    800015f0:	86ca                	mv	a3,s2
    800015f2:	6605                	lui	a2,0x1
    800015f4:	85ce                	mv	a1,s3
    800015f6:	8556                	mv	a0,s5
    800015f8:	00000097          	auipc	ra,0x0
    800015fc:	adc080e7          	jalr	-1316(ra) # 800010d4 <mappages>
    80001600:	e515                	bnez	a0,8000162c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001602:	6785                	lui	a5,0x1
    80001604:	99be                	add	s3,s3,a5
    80001606:	fb49e6e3          	bltu	s3,s4,800015b2 <uvmcopy+0x20>
    8000160a:	a081                	j	8000164a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000160c:	00008517          	auipc	a0,0x8
    80001610:	b7c50513          	addi	a0,a0,-1156 # 80009188 <digits+0x148>
    80001614:	fffff097          	auipc	ra,0xfffff
    80001618:	f28080e7          	jalr	-216(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    8000161c:	00008517          	auipc	a0,0x8
    80001620:	b8c50513          	addi	a0,a0,-1140 # 800091a8 <digits+0x168>
    80001624:	fffff097          	auipc	ra,0xfffff
    80001628:	f18080e7          	jalr	-232(ra) # 8000053c <panic>
      kfree(mem);
    8000162c:	854a                	mv	a0,s2
    8000162e:	fffff097          	auipc	ra,0xfffff
    80001632:	3c8080e7          	jalr	968(ra) # 800009f6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001636:	4685                	li	a3,1
    80001638:	00c9d613          	srli	a2,s3,0xc
    8000163c:	4581                	li	a1,0
    8000163e:	8556                	mv	a0,s5
    80001640:	00000097          	auipc	ra,0x0
    80001644:	c5a080e7          	jalr	-934(ra) # 8000129a <uvmunmap>
  return -1;
    80001648:	557d                	li	a0,-1
}
    8000164a:	60a6                	ld	ra,72(sp)
    8000164c:	6406                	ld	s0,64(sp)
    8000164e:	74e2                	ld	s1,56(sp)
    80001650:	7942                	ld	s2,48(sp)
    80001652:	79a2                	ld	s3,40(sp)
    80001654:	7a02                	ld	s4,32(sp)
    80001656:	6ae2                	ld	s5,24(sp)
    80001658:	6b42                	ld	s6,16(sp)
    8000165a:	6ba2                	ld	s7,8(sp)
    8000165c:	6161                	addi	sp,sp,80
    8000165e:	8082                	ret
  return 0;
    80001660:	4501                	li	a0,0
}
    80001662:	8082                	ret

0000000080001664 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001664:	1141                	addi	sp,sp,-16
    80001666:	e406                	sd	ra,8(sp)
    80001668:	e022                	sd	s0,0(sp)
    8000166a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000166c:	4601                	li	a2,0
    8000166e:	00000097          	auipc	ra,0x0
    80001672:	97e080e7          	jalr	-1666(ra) # 80000fec <walk>
  if(pte == 0)
    80001676:	c901                	beqz	a0,80001686 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001678:	611c                	ld	a5,0(a0)
    8000167a:	9bbd                	andi	a5,a5,-17
    8000167c:	e11c                	sd	a5,0(a0)
}
    8000167e:	60a2                	ld	ra,8(sp)
    80001680:	6402                	ld	s0,0(sp)
    80001682:	0141                	addi	sp,sp,16
    80001684:	8082                	ret
    panic("uvmclear");
    80001686:	00008517          	auipc	a0,0x8
    8000168a:	b4250513          	addi	a0,a0,-1214 # 800091c8 <digits+0x188>
    8000168e:	fffff097          	auipc	ra,0xfffff
    80001692:	eae080e7          	jalr	-338(ra) # 8000053c <panic>

0000000080001696 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001696:	c6bd                	beqz	a3,80001704 <copyout+0x6e>
{
    80001698:	715d                	addi	sp,sp,-80
    8000169a:	e486                	sd	ra,72(sp)
    8000169c:	e0a2                	sd	s0,64(sp)
    8000169e:	fc26                	sd	s1,56(sp)
    800016a0:	f84a                	sd	s2,48(sp)
    800016a2:	f44e                	sd	s3,40(sp)
    800016a4:	f052                	sd	s4,32(sp)
    800016a6:	ec56                	sd	s5,24(sp)
    800016a8:	e85a                	sd	s6,16(sp)
    800016aa:	e45e                	sd	s7,8(sp)
    800016ac:	e062                	sd	s8,0(sp)
    800016ae:	0880                	addi	s0,sp,80
    800016b0:	8b2a                	mv	s6,a0
    800016b2:	8c2e                	mv	s8,a1
    800016b4:	8a32                	mv	s4,a2
    800016b6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016b8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016ba:	6a85                	lui	s5,0x1
    800016bc:	a015                	j	800016e0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016be:	9562                	add	a0,a0,s8
    800016c0:	0004861b          	sext.w	a2,s1
    800016c4:	85d2                	mv	a1,s4
    800016c6:	41250533          	sub	a0,a0,s2
    800016ca:	fffff097          	auipc	ra,0xfffff
    800016ce:	674080e7          	jalr	1652(ra) # 80000d3e <memmove>

    len -= n;
    800016d2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016d6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016d8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016dc:	02098263          	beqz	s3,80001700 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016e0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016e4:	85ca                	mv	a1,s2
    800016e6:	855a                	mv	a0,s6
    800016e8:	00000097          	auipc	ra,0x0
    800016ec:	9aa080e7          	jalr	-1622(ra) # 80001092 <walkaddr>
    if(pa0 == 0)
    800016f0:	cd01                	beqz	a0,80001708 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016f2:	418904b3          	sub	s1,s2,s8
    800016f6:	94d6                	add	s1,s1,s5
    if(n > len)
    800016f8:	fc99f3e3          	bgeu	s3,s1,800016be <copyout+0x28>
    800016fc:	84ce                	mv	s1,s3
    800016fe:	b7c1                	j	800016be <copyout+0x28>
  }
  return 0;
    80001700:	4501                	li	a0,0
    80001702:	a021                	j	8000170a <copyout+0x74>
    80001704:	4501                	li	a0,0
}
    80001706:	8082                	ret
      return -1;
    80001708:	557d                	li	a0,-1
}
    8000170a:	60a6                	ld	ra,72(sp)
    8000170c:	6406                	ld	s0,64(sp)
    8000170e:	74e2                	ld	s1,56(sp)
    80001710:	7942                	ld	s2,48(sp)
    80001712:	79a2                	ld	s3,40(sp)
    80001714:	7a02                	ld	s4,32(sp)
    80001716:	6ae2                	ld	s5,24(sp)
    80001718:	6b42                	ld	s6,16(sp)
    8000171a:	6ba2                	ld	s7,8(sp)
    8000171c:	6c02                	ld	s8,0(sp)
    8000171e:	6161                	addi	sp,sp,80
    80001720:	8082                	ret

0000000080001722 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001722:	c6bd                	beqz	a3,80001790 <copyin+0x6e>
{
    80001724:	715d                	addi	sp,sp,-80
    80001726:	e486                	sd	ra,72(sp)
    80001728:	e0a2                	sd	s0,64(sp)
    8000172a:	fc26                	sd	s1,56(sp)
    8000172c:	f84a                	sd	s2,48(sp)
    8000172e:	f44e                	sd	s3,40(sp)
    80001730:	f052                	sd	s4,32(sp)
    80001732:	ec56                	sd	s5,24(sp)
    80001734:	e85a                	sd	s6,16(sp)
    80001736:	e45e                	sd	s7,8(sp)
    80001738:	e062                	sd	s8,0(sp)
    8000173a:	0880                	addi	s0,sp,80
    8000173c:	8b2a                	mv	s6,a0
    8000173e:	8a2e                	mv	s4,a1
    80001740:	8c32                	mv	s8,a2
    80001742:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001744:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001746:	6a85                	lui	s5,0x1
    80001748:	a015                	j	8000176c <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000174a:	9562                	add	a0,a0,s8
    8000174c:	0004861b          	sext.w	a2,s1
    80001750:	412505b3          	sub	a1,a0,s2
    80001754:	8552                	mv	a0,s4
    80001756:	fffff097          	auipc	ra,0xfffff
    8000175a:	5e8080e7          	jalr	1512(ra) # 80000d3e <memmove>

    len -= n;
    8000175e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001762:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001764:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001768:	02098263          	beqz	s3,8000178c <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000176c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001770:	85ca                	mv	a1,s2
    80001772:	855a                	mv	a0,s6
    80001774:	00000097          	auipc	ra,0x0
    80001778:	91e080e7          	jalr	-1762(ra) # 80001092 <walkaddr>
    if(pa0 == 0)
    8000177c:	cd01                	beqz	a0,80001794 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000177e:	418904b3          	sub	s1,s2,s8
    80001782:	94d6                	add	s1,s1,s5
    if(n > len)
    80001784:	fc99f3e3          	bgeu	s3,s1,8000174a <copyin+0x28>
    80001788:	84ce                	mv	s1,s3
    8000178a:	b7c1                	j	8000174a <copyin+0x28>
  }
  return 0;
    8000178c:	4501                	li	a0,0
    8000178e:	a021                	j	80001796 <copyin+0x74>
    80001790:	4501                	li	a0,0
}
    80001792:	8082                	ret
      return -1;
    80001794:	557d                	li	a0,-1
}
    80001796:	60a6                	ld	ra,72(sp)
    80001798:	6406                	ld	s0,64(sp)
    8000179a:	74e2                	ld	s1,56(sp)
    8000179c:	7942                	ld	s2,48(sp)
    8000179e:	79a2                	ld	s3,40(sp)
    800017a0:	7a02                	ld	s4,32(sp)
    800017a2:	6ae2                	ld	s5,24(sp)
    800017a4:	6b42                	ld	s6,16(sp)
    800017a6:	6ba2                	ld	s7,8(sp)
    800017a8:	6c02                	ld	s8,0(sp)
    800017aa:	6161                	addi	sp,sp,80
    800017ac:	8082                	ret

00000000800017ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017ae:	c6c5                	beqz	a3,80001856 <copyinstr+0xa8>
{
    800017b0:	715d                	addi	sp,sp,-80
    800017b2:	e486                	sd	ra,72(sp)
    800017b4:	e0a2                	sd	s0,64(sp)
    800017b6:	fc26                	sd	s1,56(sp)
    800017b8:	f84a                	sd	s2,48(sp)
    800017ba:	f44e                	sd	s3,40(sp)
    800017bc:	f052                	sd	s4,32(sp)
    800017be:	ec56                	sd	s5,24(sp)
    800017c0:	e85a                	sd	s6,16(sp)
    800017c2:	e45e                	sd	s7,8(sp)
    800017c4:	0880                	addi	s0,sp,80
    800017c6:	8a2a                	mv	s4,a0
    800017c8:	8b2e                	mv	s6,a1
    800017ca:	8bb2                	mv	s7,a2
    800017cc:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017d0:	6985                	lui	s3,0x1
    800017d2:	a035                	j	800017fe <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017da:	0017b793          	seqz	a5,a5
    800017de:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017e2:	60a6                	ld	ra,72(sp)
    800017e4:	6406                	ld	s0,64(sp)
    800017e6:	74e2                	ld	s1,56(sp)
    800017e8:	7942                	ld	s2,48(sp)
    800017ea:	79a2                	ld	s3,40(sp)
    800017ec:	7a02                	ld	s4,32(sp)
    800017ee:	6ae2                	ld	s5,24(sp)
    800017f0:	6b42                	ld	s6,16(sp)
    800017f2:	6ba2                	ld	s7,8(sp)
    800017f4:	6161                	addi	sp,sp,80
    800017f6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017f8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017fc:	c8a9                	beqz	s1,8000184e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017fe:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001802:	85ca                	mv	a1,s2
    80001804:	8552                	mv	a0,s4
    80001806:	00000097          	auipc	ra,0x0
    8000180a:	88c080e7          	jalr	-1908(ra) # 80001092 <walkaddr>
    if(pa0 == 0)
    8000180e:	c131                	beqz	a0,80001852 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001810:	41790833          	sub	a6,s2,s7
    80001814:	984e                	add	a6,a6,s3
    if(n > max)
    80001816:	0104f363          	bgeu	s1,a6,8000181c <copyinstr+0x6e>
    8000181a:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000181c:	955e                	add	a0,a0,s7
    8000181e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001822:	fc080be3          	beqz	a6,800017f8 <copyinstr+0x4a>
    80001826:	985a                	add	a6,a6,s6
    80001828:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000182a:	41650633          	sub	a2,a0,s6
    8000182e:	14fd                	addi	s1,s1,-1
    80001830:	9b26                	add	s6,s6,s1
    80001832:	00f60733          	add	a4,a2,a5
    80001836:	00074703          	lbu	a4,0(a4)
    8000183a:	df49                	beqz	a4,800017d4 <copyinstr+0x26>
        *dst = *p;
    8000183c:	00e78023          	sb	a4,0(a5)
      --max;
    80001840:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001844:	0785                	addi	a5,a5,1
    while(n > 0){
    80001846:	ff0796e3          	bne	a5,a6,80001832 <copyinstr+0x84>
      dst++;
    8000184a:	8b42                	mv	s6,a6
    8000184c:	b775                	j	800017f8 <copyinstr+0x4a>
    8000184e:	4781                	li	a5,0
    80001850:	b769                	j	800017da <copyinstr+0x2c>
      return -1;
    80001852:	557d                	li	a0,-1
    80001854:	b779                	j	800017e2 <copyinstr+0x34>
  int got_null = 0;
    80001856:	4781                	li	a5,0
  if(got_null){
    80001858:	0017b793          	seqz	a5,a5
    8000185c:	40f00533          	neg	a0,a5
}
    80001860:	8082                	ret

0000000080001862 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001862:	7139                	addi	sp,sp,-64
    80001864:	fc06                	sd	ra,56(sp)
    80001866:	f822                	sd	s0,48(sp)
    80001868:	f426                	sd	s1,40(sp)
    8000186a:	f04a                	sd	s2,32(sp)
    8000186c:	ec4e                	sd	s3,24(sp)
    8000186e:	e852                	sd	s4,16(sp)
    80001870:	e456                	sd	s5,8(sp)
    80001872:	e05a                	sd	s6,0(sp)
    80001874:	0080                	addi	s0,sp,64
    80001876:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001878:	00011497          	auipc	s1,0x11
    8000187c:	e8848493          	addi	s1,s1,-376 # 80012700 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001880:	8b26                	mv	s6,s1
    80001882:	00007a97          	auipc	s5,0x7
    80001886:	77ea8a93          	addi	s5,s5,1918 # 80009000 <etext>
    8000188a:	04000937          	lui	s2,0x4000
    8000188e:	197d                	addi	s2,s2,-1
    80001890:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001892:	00017a17          	auipc	s4,0x17
    80001896:	26ea0a13          	addi	s4,s4,622 # 80018b00 <tickslock>
    char *pa = kalloc();
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	258080e7          	jalr	600(ra) # 80000af2 <kalloc>
    800018a2:	862a                	mv	a2,a0
    if(pa == 0)
    800018a4:	c131                	beqz	a0,800018e8 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800018a6:	416485b3          	sub	a1,s1,s6
    800018aa:	8591                	srai	a1,a1,0x4
    800018ac:	000ab783          	ld	a5,0(s5)
    800018b0:	02f585b3          	mul	a1,a1,a5
    800018b4:	2585                	addiw	a1,a1,1
    800018b6:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018ba:	4719                	li	a4,6
    800018bc:	6685                	lui	a3,0x1
    800018be:	40b905b3          	sub	a1,s2,a1
    800018c2:	854e                	mv	a0,s3
    800018c4:	00000097          	auipc	ra,0x0
    800018c8:	8b0080e7          	jalr	-1872(ra) # 80001174 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018cc:	19048493          	addi	s1,s1,400
    800018d0:	fd4495e3          	bne	s1,s4,8000189a <proc_mapstacks+0x38>
  }
}
    800018d4:	70e2                	ld	ra,56(sp)
    800018d6:	7442                	ld	s0,48(sp)
    800018d8:	74a2                	ld	s1,40(sp)
    800018da:	7902                	ld	s2,32(sp)
    800018dc:	69e2                	ld	s3,24(sp)
    800018de:	6a42                	ld	s4,16(sp)
    800018e0:	6aa2                	ld	s5,8(sp)
    800018e2:	6b02                	ld	s6,0(sp)
    800018e4:	6121                	addi	sp,sp,64
    800018e6:	8082                	ret
      panic("kalloc");
    800018e8:	00008517          	auipc	a0,0x8
    800018ec:	8f050513          	addi	a0,a0,-1808 # 800091d8 <digits+0x198>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	c4c080e7          	jalr	-948(ra) # 8000053c <panic>

00000000800018f8 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018f8:	7139                	addi	sp,sp,-64
    800018fa:	fc06                	sd	ra,56(sp)
    800018fc:	f822                	sd	s0,48(sp)
    800018fe:	f426                	sd	s1,40(sp)
    80001900:	f04a                	sd	s2,32(sp)
    80001902:	ec4e                	sd	s3,24(sp)
    80001904:	e852                	sd	s4,16(sp)
    80001906:	e456                	sd	s5,8(sp)
    80001908:	e05a                	sd	s6,0(sp)
    8000190a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000190c:	00008597          	auipc	a1,0x8
    80001910:	8d458593          	addi	a1,a1,-1836 # 800091e0 <digits+0x1a0>
    80001914:	00011517          	auipc	a0,0x11
    80001918:	9bc50513          	addi	a0,a0,-1604 # 800122d0 <pid_lock>
    8000191c:	fffff097          	auipc	ra,0xfffff
    80001920:	236080e7          	jalr	566(ra) # 80000b52 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001924:	00008597          	auipc	a1,0x8
    80001928:	8c458593          	addi	a1,a1,-1852 # 800091e8 <digits+0x1a8>
    8000192c:	00011517          	auipc	a0,0x11
    80001930:	9bc50513          	addi	a0,a0,-1604 # 800122e8 <wait_lock>
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	21e080e7          	jalr	542(ra) # 80000b52 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193c:	00011497          	auipc	s1,0x11
    80001940:	dc448493          	addi	s1,s1,-572 # 80012700 <proc>
      initlock(&p->lock, "proc");
    80001944:	00008b17          	auipc	s6,0x8
    80001948:	8b4b0b13          	addi	s6,s6,-1868 # 800091f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    8000194c:	8aa6                	mv	s5,s1
    8000194e:	00007a17          	auipc	s4,0x7
    80001952:	6b2a0a13          	addi	s4,s4,1714 # 80009000 <etext>
    80001956:	04000937          	lui	s2,0x4000
    8000195a:	197d                	addi	s2,s2,-1
    8000195c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195e:	00017997          	auipc	s3,0x17
    80001962:	1a298993          	addi	s3,s3,418 # 80018b00 <tickslock>
      initlock(&p->lock, "proc");
    80001966:	85da                	mv	a1,s6
    80001968:	8526                	mv	a0,s1
    8000196a:	fffff097          	auipc	ra,0xfffff
    8000196e:	1e8080e7          	jalr	488(ra) # 80000b52 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001972:	415487b3          	sub	a5,s1,s5
    80001976:	8791                	srai	a5,a5,0x4
    80001978:	000a3703          	ld	a4,0(s4)
    8000197c:	02e787b3          	mul	a5,a5,a4
    80001980:	2785                	addiw	a5,a5,1
    80001982:	00d7979b          	slliw	a5,a5,0xd
    80001986:	40f907b3          	sub	a5,s2,a5
    8000198a:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000198c:	19048493          	addi	s1,s1,400
    80001990:	fd349be3          	bne	s1,s3,80001966 <procinit+0x6e>
  }
}
    80001994:	70e2                	ld	ra,56(sp)
    80001996:	7442                	ld	s0,48(sp)
    80001998:	74a2                	ld	s1,40(sp)
    8000199a:	7902                	ld	s2,32(sp)
    8000199c:	69e2                	ld	s3,24(sp)
    8000199e:	6a42                	ld	s4,16(sp)
    800019a0:	6aa2                	ld	s5,8(sp)
    800019a2:	6b02                	ld	s6,0(sp)
    800019a4:	6121                	addi	sp,sp,64
    800019a6:	8082                	ret

00000000800019a8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019a8:	1141                	addi	sp,sp,-16
    800019aa:	e422                	sd	s0,8(sp)
    800019ac:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019ae:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019b0:	2501                	sext.w	a0,a0
    800019b2:	6422                	ld	s0,8(sp)
    800019b4:	0141                	addi	sp,sp,16
    800019b6:	8082                	ret

00000000800019b8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    800019b8:	1141                	addi	sp,sp,-16
    800019ba:	e422                	sd	s0,8(sp)
    800019bc:	0800                	addi	s0,sp,16
    800019be:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
  return c;
}
    800019c4:	00011517          	auipc	a0,0x11
    800019c8:	93c50513          	addi	a0,a0,-1732 # 80012300 <cpus>
    800019cc:	953e                	add	a0,a0,a5
    800019ce:	6422                	ld	s0,8(sp)
    800019d0:	0141                	addi	sp,sp,16
    800019d2:	8082                	ret

00000000800019d4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019d4:	1101                	addi	sp,sp,-32
    800019d6:	ec06                	sd	ra,24(sp)
    800019d8:	e822                	sd	s0,16(sp)
    800019da:	e426                	sd	s1,8(sp)
    800019dc:	1000                	addi	s0,sp,32
  push_off();
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	1b8080e7          	jalr	440(ra) # 80000b96 <push_off>
    800019e6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019e8:	2781                	sext.w	a5,a5
    800019ea:	079e                	slli	a5,a5,0x7
    800019ec:	00011717          	auipc	a4,0x11
    800019f0:	8e470713          	addi	a4,a4,-1820 # 800122d0 <pid_lock>
    800019f4:	97ba                	add	a5,a5,a4
    800019f6:	7b84                	ld	s1,48(a5)
  pop_off();
    800019f8:	fffff097          	auipc	ra,0xfffff
    800019fc:	23e080e7          	jalr	574(ra) # 80000c36 <pop_off>
  return p;
}
    80001a00:	8526                	mv	a0,s1
    80001a02:	60e2                	ld	ra,24(sp)
    80001a04:	6442                	ld	s0,16(sp)
    80001a06:	64a2                	ld	s1,8(sp)
    80001a08:	6105                	addi	sp,sp,32
    80001a0a:	8082                	ret

0000000080001a0c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	1000                	addi	s0,sp,32
  static int first = 1;
  uint xticks;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a16:	00000097          	auipc	ra,0x0
    80001a1a:	fbe080e7          	jalr	-66(ra) # 800019d4 <myproc>
    80001a1e:	fffff097          	auipc	ra,0xfffff
    80001a22:	278080e7          	jalr	632(ra) # 80000c96 <release>

  acquire(&tickslock);
    80001a26:	00017517          	auipc	a0,0x17
    80001a2a:	0da50513          	addi	a0,a0,218 # 80018b00 <tickslock>
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	1b4080e7          	jalr	436(ra) # 80000be2 <acquire>
  xticks = ticks;
    80001a36:	00008497          	auipc	s1,0x8
    80001a3a:	6364a483          	lw	s1,1590(s1) # 8000a06c <ticks>
  release(&tickslock);
    80001a3e:	00017517          	auipc	a0,0x17
    80001a42:	0c250513          	addi	a0,a0,194 # 80018b00 <tickslock>
    80001a46:	fffff097          	auipc	ra,0xfffff
    80001a4a:	250080e7          	jalr	592(ra) # 80000c96 <release>

  myproc()->stime = xticks;
    80001a4e:	00000097          	auipc	ra,0x0
    80001a52:	f86080e7          	jalr	-122(ra) # 800019d4 <myproc>
    80001a56:	16952a23          	sw	s1,372(a0)

  if (first) {
    80001a5a:	00008797          	auipc	a5,0x8
    80001a5e:	0a67a783          	lw	a5,166(a5) # 80009b00 <first.1791>
    80001a62:	eb91                	bnez	a5,80001a76 <forkret+0x6a>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a64:	00002097          	auipc	ra,0x2
    80001a68:	d16080e7          	jalr	-746(ra) # 8000377a <usertrapret>
}
    80001a6c:	60e2                	ld	ra,24(sp)
    80001a6e:	6442                	ld	s0,16(sp)
    80001a70:	64a2                	ld	s1,8(sp)
    80001a72:	6105                	addi	sp,sp,32
    80001a74:	8082                	ret
    first = 0;
    80001a76:	00008797          	auipc	a5,0x8
    80001a7a:	0807a523          	sw	zero,138(a5) # 80009b00 <first.1791>
    fsinit(ROOTDEV);
    80001a7e:	4505                	li	a0,1
    80001a80:	00003097          	auipc	ra,0x3
    80001a84:	e3a080e7          	jalr	-454(ra) # 800048ba <fsinit>
    80001a88:	bff1                	j	80001a64 <forkret+0x58>

0000000080001a8a <allocpid>:
allocpid() {
    80001a8a:	1101                	addi	sp,sp,-32
    80001a8c:	ec06                	sd	ra,24(sp)
    80001a8e:	e822                	sd	s0,16(sp)
    80001a90:	e426                	sd	s1,8(sp)
    80001a92:	e04a                	sd	s2,0(sp)
    80001a94:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a96:	00011917          	auipc	s2,0x11
    80001a9a:	83a90913          	addi	s2,s2,-1990 # 800122d0 <pid_lock>
    80001a9e:	854a                	mv	a0,s2
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	142080e7          	jalr	322(ra) # 80000be2 <acquire>
  pid = nextpid;
    80001aa8:	00008797          	auipc	a5,0x8
    80001aac:	06c78793          	addi	a5,a5,108 # 80009b14 <nextpid>
    80001ab0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ab2:	0014871b          	addiw	a4,s1,1
    80001ab6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ab8:	854a                	mv	a0,s2
    80001aba:	fffff097          	auipc	ra,0xfffff
    80001abe:	1dc080e7          	jalr	476(ra) # 80000c96 <release>
}
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	60e2                	ld	ra,24(sp)
    80001ac6:	6442                	ld	s0,16(sp)
    80001ac8:	64a2                	ld	s1,8(sp)
    80001aca:	6902                	ld	s2,0(sp)
    80001acc:	6105                	addi	sp,sp,32
    80001ace:	8082                	ret

0000000080001ad0 <proc_pagetable>:
{
    80001ad0:	1101                	addi	sp,sp,-32
    80001ad2:	ec06                	sd	ra,24(sp)
    80001ad4:	e822                	sd	s0,16(sp)
    80001ad6:	e426                	sd	s1,8(sp)
    80001ad8:	e04a                	sd	s2,0(sp)
    80001ada:	1000                	addi	s0,sp,32
    80001adc:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ade:	00000097          	auipc	ra,0x0
    80001ae2:	880080e7          	jalr	-1920(ra) # 8000135e <uvmcreate>
    80001ae6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ae8:	c121                	beqz	a0,80001b28 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aea:	4729                	li	a4,10
    80001aec:	00006697          	auipc	a3,0x6
    80001af0:	51468693          	addi	a3,a3,1300 # 80008000 <_trampoline>
    80001af4:	6605                	lui	a2,0x1
    80001af6:	040005b7          	lui	a1,0x4000
    80001afa:	15fd                	addi	a1,a1,-1
    80001afc:	05b2                	slli	a1,a1,0xc
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	5d6080e7          	jalr	1494(ra) # 800010d4 <mappages>
    80001b06:	02054863          	bltz	a0,80001b36 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b0a:	4719                	li	a4,6
    80001b0c:	06093683          	ld	a3,96(s2)
    80001b10:	6605                	lui	a2,0x1
    80001b12:	020005b7          	lui	a1,0x2000
    80001b16:	15fd                	addi	a1,a1,-1
    80001b18:	05b6                	slli	a1,a1,0xd
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	fffff097          	auipc	ra,0xfffff
    80001b20:	5b8080e7          	jalr	1464(ra) # 800010d4 <mappages>
    80001b24:	02054163          	bltz	a0,80001b46 <proc_pagetable+0x76>
}
    80001b28:	8526                	mv	a0,s1
    80001b2a:	60e2                	ld	ra,24(sp)
    80001b2c:	6442                	ld	s0,16(sp)
    80001b2e:	64a2                	ld	s1,8(sp)
    80001b30:	6902                	ld	s2,0(sp)
    80001b32:	6105                	addi	sp,sp,32
    80001b34:	8082                	ret
    uvmfree(pagetable, 0);
    80001b36:	4581                	li	a1,0
    80001b38:	8526                	mv	a0,s1
    80001b3a:	00000097          	auipc	ra,0x0
    80001b3e:	a20080e7          	jalr	-1504(ra) # 8000155a <uvmfree>
    return 0;
    80001b42:	4481                	li	s1,0
    80001b44:	b7d5                	j	80001b28 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b46:	4681                	li	a3,0
    80001b48:	4605                	li	a2,1
    80001b4a:	040005b7          	lui	a1,0x4000
    80001b4e:	15fd                	addi	a1,a1,-1
    80001b50:	05b2                	slli	a1,a1,0xc
    80001b52:	8526                	mv	a0,s1
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	746080e7          	jalr	1862(ra) # 8000129a <uvmunmap>
    uvmfree(pagetable, 0);
    80001b5c:	4581                	li	a1,0
    80001b5e:	8526                	mv	a0,s1
    80001b60:	00000097          	auipc	ra,0x0
    80001b64:	9fa080e7          	jalr	-1542(ra) # 8000155a <uvmfree>
    return 0;
    80001b68:	4481                	li	s1,0
    80001b6a:	bf7d                	j	80001b28 <proc_pagetable+0x58>

0000000080001b6c <proc_freepagetable>:
{
    80001b6c:	1101                	addi	sp,sp,-32
    80001b6e:	ec06                	sd	ra,24(sp)
    80001b70:	e822                	sd	s0,16(sp)
    80001b72:	e426                	sd	s1,8(sp)
    80001b74:	e04a                	sd	s2,0(sp)
    80001b76:	1000                	addi	s0,sp,32
    80001b78:	84aa                	mv	s1,a0
    80001b7a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b7c:	4681                	li	a3,0
    80001b7e:	4605                	li	a2,1
    80001b80:	040005b7          	lui	a1,0x4000
    80001b84:	15fd                	addi	a1,a1,-1
    80001b86:	05b2                	slli	a1,a1,0xc
    80001b88:	fffff097          	auipc	ra,0xfffff
    80001b8c:	712080e7          	jalr	1810(ra) # 8000129a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b90:	4681                	li	a3,0
    80001b92:	4605                	li	a2,1
    80001b94:	020005b7          	lui	a1,0x2000
    80001b98:	15fd                	addi	a1,a1,-1
    80001b9a:	05b6                	slli	a1,a1,0xd
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	6fc080e7          	jalr	1788(ra) # 8000129a <uvmunmap>
  uvmfree(pagetable, sz);
    80001ba6:	85ca                	mv	a1,s2
    80001ba8:	8526                	mv	a0,s1
    80001baa:	00000097          	auipc	ra,0x0
    80001bae:	9b0080e7          	jalr	-1616(ra) # 8000155a <uvmfree>
}
    80001bb2:	60e2                	ld	ra,24(sp)
    80001bb4:	6442                	ld	s0,16(sp)
    80001bb6:	64a2                	ld	s1,8(sp)
    80001bb8:	6902                	ld	s2,0(sp)
    80001bba:	6105                	addi	sp,sp,32
    80001bbc:	8082                	ret

0000000080001bbe <freeproc>:
{
    80001bbe:	1101                	addi	sp,sp,-32
    80001bc0:	ec06                	sd	ra,24(sp)
    80001bc2:	e822                	sd	s0,16(sp)
    80001bc4:	e426                	sd	s1,8(sp)
    80001bc6:	1000                	addi	s0,sp,32
    80001bc8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bca:	7128                	ld	a0,96(a0)
    80001bcc:	c509                	beqz	a0,80001bd6 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	e28080e7          	jalr	-472(ra) # 800009f6 <kfree>
  p->trapframe = 0;
    80001bd6:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001bda:	6ca8                	ld	a0,88(s1)
    80001bdc:	c511                	beqz	a0,80001be8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bde:	68ac                	ld	a1,80(s1)
    80001be0:	00000097          	auipc	ra,0x0
    80001be4:	f8c080e7          	jalr	-116(ra) # 80001b6c <proc_freepagetable>
  p->pagetable = 0;
    80001be8:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001bec:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001bf0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bf4:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001bf8:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001bfc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c00:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c04:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c08:	0004ac23          	sw	zero,24(s1)
}
    80001c0c:	60e2                	ld	ra,24(sp)
    80001c0e:	6442                	ld	s0,16(sp)
    80001c10:	64a2                	ld	s1,8(sp)
    80001c12:	6105                	addi	sp,sp,32
    80001c14:	8082                	ret

0000000080001c16 <allocproc>:
{
    80001c16:	1101                	addi	sp,sp,-32
    80001c18:	ec06                	sd	ra,24(sp)
    80001c1a:	e822                	sd	s0,16(sp)
    80001c1c:	e426                	sd	s1,8(sp)
    80001c1e:	e04a                	sd	s2,0(sp)
    80001c20:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c22:	00011497          	auipc	s1,0x11
    80001c26:	ade48493          	addi	s1,s1,-1314 # 80012700 <proc>
    80001c2a:	00017917          	auipc	s2,0x17
    80001c2e:	ed690913          	addi	s2,s2,-298 # 80018b00 <tickslock>
    acquire(&p->lock);
    80001c32:	8526                	mv	a0,s1
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	fae080e7          	jalr	-82(ra) # 80000be2 <acquire>
    if(p->state == UNUSED) {
    80001c3c:	4c9c                	lw	a5,24(s1)
    80001c3e:	cf81                	beqz	a5,80001c56 <allocproc+0x40>
      release(&p->lock);
    80001c40:	8526                	mv	a0,s1
    80001c42:	fffff097          	auipc	ra,0xfffff
    80001c46:	054080e7          	jalr	84(ra) # 80000c96 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c4a:	19048493          	addi	s1,s1,400
    80001c4e:	ff2492e3          	bne	s1,s2,80001c32 <allocproc+0x1c>
  return 0;
    80001c52:	4481                	li	s1,0
    80001c54:	a841                	j	80001ce4 <allocproc+0xce>
  p->pid = allocpid();
    80001c56:	00000097          	auipc	ra,0x0
    80001c5a:	e34080e7          	jalr	-460(ra) # 80001a8a <allocpid>
    80001c5e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c60:	4785                	li	a5,1
    80001c62:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	e8e080e7          	jalr	-370(ra) # 80000af2 <kalloc>
    80001c6c:	892a                	mv	s2,a0
    80001c6e:	f0a8                	sd	a0,96(s1)
    80001c70:	c149                	beqz	a0,80001cf2 <allocproc+0xdc>
  p->pagetable = proc_pagetable(p);
    80001c72:	8526                	mv	a0,s1
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	e5c080e7          	jalr	-420(ra) # 80001ad0 <proc_pagetable>
    80001c7c:	892a                	mv	s2,a0
    80001c7e:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001c80:	c549                	beqz	a0,80001d0a <allocproc+0xf4>
  memset(&p->context, 0, sizeof(p->context));
    80001c82:	07000613          	li	a2,112
    80001c86:	4581                	li	a1,0
    80001c88:	06848513          	addi	a0,s1,104
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	052080e7          	jalr	82(ra) # 80000cde <memset>
  p->context.ra = (uint64)forkret;
    80001c94:	00000797          	auipc	a5,0x0
    80001c98:	d7878793          	addi	a5,a5,-648 # 80001a0c <forkret>
    80001c9c:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c9e:	64bc                	ld	a5,72(s1)
    80001ca0:	6705                	lui	a4,0x1
    80001ca2:	97ba                	add	a5,a5,a4
    80001ca4:	f8bc                	sd	a5,112(s1)
  acquire(&tickslock);
    80001ca6:	00017517          	auipc	a0,0x17
    80001caa:	e5a50513          	addi	a0,a0,-422 # 80018b00 <tickslock>
    80001cae:	fffff097          	auipc	ra,0xfffff
    80001cb2:	f34080e7          	jalr	-204(ra) # 80000be2 <acquire>
  xticks = ticks;
    80001cb6:	00008917          	auipc	s2,0x8
    80001cba:	3b692903          	lw	s2,950(s2) # 8000a06c <ticks>
  release(&tickslock);
    80001cbe:	00017517          	auipc	a0,0x17
    80001cc2:	e4250513          	addi	a0,a0,-446 # 80018b00 <tickslock>
    80001cc6:	fffff097          	auipc	ra,0xfffff
    80001cca:	fd0080e7          	jalr	-48(ra) # 80000c96 <release>
  p->ctime = xticks;
    80001cce:	1724a823          	sw	s2,368(s1)
  p->stime = -1;
    80001cd2:	57fd                	li	a5,-1
    80001cd4:	16f4aa23          	sw	a5,372(s1)
  p->endtime = -1;
    80001cd8:	16f4ac23          	sw	a5,376(s1)
  p->is_batchproc = 0;
    80001cdc:	0204ae23          	sw	zero,60(s1)
  p->cpu_usage = 0;
    80001ce0:	1804a623          	sw	zero,396(s1)
}
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6902                	ld	s2,0(sp)
    80001cee:	6105                	addi	sp,sp,32
    80001cf0:	8082                	ret
    freeproc(p);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	00000097          	auipc	ra,0x0
    80001cf8:	eca080e7          	jalr	-310(ra) # 80001bbe <freeproc>
    release(&p->lock);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	f98080e7          	jalr	-104(ra) # 80000c96 <release>
    return 0;
    80001d06:	84ca                	mv	s1,s2
    80001d08:	bff1                	j	80001ce4 <allocproc+0xce>
    freeproc(p);
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	00000097          	auipc	ra,0x0
    80001d10:	eb2080e7          	jalr	-334(ra) # 80001bbe <freeproc>
    release(&p->lock);
    80001d14:	8526                	mv	a0,s1
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	f80080e7          	jalr	-128(ra) # 80000c96 <release>
    return 0;
    80001d1e:	84ca                	mv	s1,s2
    80001d20:	b7d1                	j	80001ce4 <allocproc+0xce>

0000000080001d22 <userinit>:
{
    80001d22:	1101                	addi	sp,sp,-32
    80001d24:	ec06                	sd	ra,24(sp)
    80001d26:	e822                	sd	s0,16(sp)
    80001d28:	e426                	sd	s1,8(sp)
    80001d2a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	eea080e7          	jalr	-278(ra) # 80001c16 <allocproc>
    80001d34:	84aa                	mv	s1,a0
  initproc = p;
    80001d36:	00008797          	auipc	a5,0x8
    80001d3a:	32a7b523          	sd	a0,810(a5) # 8000a060 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d3e:	03400613          	li	a2,52
    80001d42:	00008597          	auipc	a1,0x8
    80001d46:	dde58593          	addi	a1,a1,-546 # 80009b20 <initcode>
    80001d4a:	6d28                	ld	a0,88(a0)
    80001d4c:	fffff097          	auipc	ra,0xfffff
    80001d50:	640080e7          	jalr	1600(ra) # 8000138c <uvminit>
  p->sz = PGSIZE;
    80001d54:	6785                	lui	a5,0x1
    80001d56:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d58:	70b8                	ld	a4,96(s1)
    80001d5a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d5e:	70b8                	ld	a4,96(s1)
    80001d60:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d62:	4641                	li	a2,16
    80001d64:	00007597          	auipc	a1,0x7
    80001d68:	49c58593          	addi	a1,a1,1180 # 80009200 <digits+0x1c0>
    80001d6c:	16048513          	addi	a0,s1,352
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	0c0080e7          	jalr	192(ra) # 80000e30 <safestrcpy>
  p->cwd = namei("/");
    80001d78:	00007517          	auipc	a0,0x7
    80001d7c:	49850513          	addi	a0,a0,1176 # 80009210 <digits+0x1d0>
    80001d80:	00003097          	auipc	ra,0x3
    80001d84:	568080e7          	jalr	1384(ra) # 800052e8 <namei>
    80001d88:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d8c:	478d                	li	a5,3
    80001d8e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d90:	8526                	mv	a0,s1
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	f04080e7          	jalr	-252(ra) # 80000c96 <release>
}
    80001d9a:	60e2                	ld	ra,24(sp)
    80001d9c:	6442                	ld	s0,16(sp)
    80001d9e:	64a2                	ld	s1,8(sp)
    80001da0:	6105                	addi	sp,sp,32
    80001da2:	8082                	ret

0000000080001da4 <growproc>:
{
    80001da4:	1101                	addi	sp,sp,-32
    80001da6:	ec06                	sd	ra,24(sp)
    80001da8:	e822                	sd	s0,16(sp)
    80001daa:	e426                	sd	s1,8(sp)
    80001dac:	e04a                	sd	s2,0(sp)
    80001dae:	1000                	addi	s0,sp,32
    80001db0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	c22080e7          	jalr	-990(ra) # 800019d4 <myproc>
    80001dba:	892a                	mv	s2,a0
  sz = p->sz;
    80001dbc:	692c                	ld	a1,80(a0)
    80001dbe:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001dc2:	00904f63          	bgtz	s1,80001de0 <growproc+0x3c>
  } else if(n < 0){
    80001dc6:	0204cc63          	bltz	s1,80001dfe <growproc+0x5a>
  p->sz = sz;
    80001dca:	1602                	slli	a2,a2,0x20
    80001dcc:	9201                	srli	a2,a2,0x20
    80001dce:	04c93823          	sd	a2,80(s2)
  return 0;
    80001dd2:	4501                	li	a0,0
}
    80001dd4:	60e2                	ld	ra,24(sp)
    80001dd6:	6442                	ld	s0,16(sp)
    80001dd8:	64a2                	ld	s1,8(sp)
    80001dda:	6902                	ld	s2,0(sp)
    80001ddc:	6105                	addi	sp,sp,32
    80001dde:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001de0:	9e25                	addw	a2,a2,s1
    80001de2:	1602                	slli	a2,a2,0x20
    80001de4:	9201                	srli	a2,a2,0x20
    80001de6:	1582                	slli	a1,a1,0x20
    80001de8:	9181                	srli	a1,a1,0x20
    80001dea:	6d28                	ld	a0,88(a0)
    80001dec:	fffff097          	auipc	ra,0xfffff
    80001df0:	65a080e7          	jalr	1626(ra) # 80001446 <uvmalloc>
    80001df4:	0005061b          	sext.w	a2,a0
    80001df8:	fa69                	bnez	a2,80001dca <growproc+0x26>
      return -1;
    80001dfa:	557d                	li	a0,-1
    80001dfc:	bfe1                	j	80001dd4 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dfe:	9e25                	addw	a2,a2,s1
    80001e00:	1602                	slli	a2,a2,0x20
    80001e02:	9201                	srli	a2,a2,0x20
    80001e04:	1582                	slli	a1,a1,0x20
    80001e06:	9181                	srli	a1,a1,0x20
    80001e08:	6d28                	ld	a0,88(a0)
    80001e0a:	fffff097          	auipc	ra,0xfffff
    80001e0e:	5f4080e7          	jalr	1524(ra) # 800013fe <uvmdealloc>
    80001e12:	0005061b          	sext.w	a2,a0
    80001e16:	bf55                	j	80001dca <growproc+0x26>

0000000080001e18 <fork>:
{
    80001e18:	7179                	addi	sp,sp,-48
    80001e1a:	f406                	sd	ra,40(sp)
    80001e1c:	f022                	sd	s0,32(sp)
    80001e1e:	ec26                	sd	s1,24(sp)
    80001e20:	e84a                	sd	s2,16(sp)
    80001e22:	e44e                	sd	s3,8(sp)
    80001e24:	e052                	sd	s4,0(sp)
    80001e26:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e28:	00000097          	auipc	ra,0x0
    80001e2c:	bac080e7          	jalr	-1108(ra) # 800019d4 <myproc>
    80001e30:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e32:	00000097          	auipc	ra,0x0
    80001e36:	de4080e7          	jalr	-540(ra) # 80001c16 <allocproc>
    80001e3a:	10050b63          	beqz	a0,80001f50 <fork+0x138>
    80001e3e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e40:	05093603          	ld	a2,80(s2)
    80001e44:	6d2c                	ld	a1,88(a0)
    80001e46:	05893503          	ld	a0,88(s2)
    80001e4a:	fffff097          	auipc	ra,0xfffff
    80001e4e:	748080e7          	jalr	1864(ra) # 80001592 <uvmcopy>
    80001e52:	04054663          	bltz	a0,80001e9e <fork+0x86>
  np->sz = p->sz;
    80001e56:	05093783          	ld	a5,80(s2)
    80001e5a:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e5e:	06093683          	ld	a3,96(s2)
    80001e62:	87b6                	mv	a5,a3
    80001e64:	0609b703          	ld	a4,96(s3)
    80001e68:	12068693          	addi	a3,a3,288
    80001e6c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e70:	6788                	ld	a0,8(a5)
    80001e72:	6b8c                	ld	a1,16(a5)
    80001e74:	6f90                	ld	a2,24(a5)
    80001e76:	01073023          	sd	a6,0(a4)
    80001e7a:	e708                	sd	a0,8(a4)
    80001e7c:	eb0c                	sd	a1,16(a4)
    80001e7e:	ef10                	sd	a2,24(a4)
    80001e80:	02078793          	addi	a5,a5,32
    80001e84:	02070713          	addi	a4,a4,32
    80001e88:	fed792e3          	bne	a5,a3,80001e6c <fork+0x54>
  np->trapframe->a0 = 0;
    80001e8c:	0609b783          	ld	a5,96(s3)
    80001e90:	0607b823          	sd	zero,112(a5)
    80001e94:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80001e98:	15800a13          	li	s4,344
    80001e9c:	a03d                	j	80001eca <fork+0xb2>
    freeproc(np);
    80001e9e:	854e                	mv	a0,s3
    80001ea0:	00000097          	auipc	ra,0x0
    80001ea4:	d1e080e7          	jalr	-738(ra) # 80001bbe <freeproc>
    release(&np->lock);
    80001ea8:	854e                	mv	a0,s3
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	dec080e7          	jalr	-532(ra) # 80000c96 <release>
    return -1;
    80001eb2:	5a7d                	li	s4,-1
    80001eb4:	a069                	j	80001f3e <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb6:	00004097          	auipc	ra,0x4
    80001eba:	ac8080e7          	jalr	-1336(ra) # 8000597e <filedup>
    80001ebe:	009987b3          	add	a5,s3,s1
    80001ec2:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001ec4:	04a1                	addi	s1,s1,8
    80001ec6:	01448763          	beq	s1,s4,80001ed4 <fork+0xbc>
    if(p->ofile[i])
    80001eca:	009907b3          	add	a5,s2,s1
    80001ece:	6388                	ld	a0,0(a5)
    80001ed0:	f17d                	bnez	a0,80001eb6 <fork+0x9e>
    80001ed2:	bfcd                	j	80001ec4 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001ed4:	15893503          	ld	a0,344(s2)
    80001ed8:	00003097          	auipc	ra,0x3
    80001edc:	c1c080e7          	jalr	-996(ra) # 80004af4 <idup>
    80001ee0:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ee4:	4641                	li	a2,16
    80001ee6:	16090593          	addi	a1,s2,352
    80001eea:	16098513          	addi	a0,s3,352
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	f42080e7          	jalr	-190(ra) # 80000e30 <safestrcpy>
  pid = np->pid;
    80001ef6:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001efa:	854e                	mv	a0,s3
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	d9a080e7          	jalr	-614(ra) # 80000c96 <release>
  acquire(&wait_lock);
    80001f04:	00010497          	auipc	s1,0x10
    80001f08:	3e448493          	addi	s1,s1,996 # 800122e8 <wait_lock>
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	cd4080e7          	jalr	-812(ra) # 80000be2 <acquire>
  np->parent = p;
    80001f16:	0529b023          	sd	s2,64(s3)
  release(&wait_lock);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	d7a080e7          	jalr	-646(ra) # 80000c96 <release>
  acquire(&np->lock);
    80001f24:	854e                	mv	a0,s3
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	cbc080e7          	jalr	-836(ra) # 80000be2 <acquire>
  np->state = RUNNABLE;
    80001f2e:	478d                	li	a5,3
    80001f30:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f34:	854e                	mv	a0,s3
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	d60080e7          	jalr	-672(ra) # 80000c96 <release>
}
    80001f3e:	8552                	mv	a0,s4
    80001f40:	70a2                	ld	ra,40(sp)
    80001f42:	7402                	ld	s0,32(sp)
    80001f44:	64e2                	ld	s1,24(sp)
    80001f46:	6942                	ld	s2,16(sp)
    80001f48:	69a2                	ld	s3,8(sp)
    80001f4a:	6a02                	ld	s4,0(sp)
    80001f4c:	6145                	addi	sp,sp,48
    80001f4e:	8082                	ret
    return -1;
    80001f50:	5a7d                	li	s4,-1
    80001f52:	b7f5                	j	80001f3e <fork+0x126>

0000000080001f54 <forkf>:
{
    80001f54:	7179                	addi	sp,sp,-48
    80001f56:	f406                	sd	ra,40(sp)
    80001f58:	f022                	sd	s0,32(sp)
    80001f5a:	ec26                	sd	s1,24(sp)
    80001f5c:	e84a                	sd	s2,16(sp)
    80001f5e:	e44e                	sd	s3,8(sp)
    80001f60:	e052                	sd	s4,0(sp)
    80001f62:	1800                	addi	s0,sp,48
    80001f64:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f66:	00000097          	auipc	ra,0x0
    80001f6a:	a6e080e7          	jalr	-1426(ra) # 800019d4 <myproc>
    80001f6e:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001f70:	00000097          	auipc	ra,0x0
    80001f74:	ca6080e7          	jalr	-858(ra) # 80001c16 <allocproc>
    80001f78:	12050063          	beqz	a0,80002098 <forkf+0x144>
    80001f7c:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f7e:	05093603          	ld	a2,80(s2)
    80001f82:	6d2c                	ld	a1,88(a0)
    80001f84:	05893503          	ld	a0,88(s2)
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	60a080e7          	jalr	1546(ra) # 80001592 <uvmcopy>
    80001f90:	04054b63          	bltz	a0,80001fe6 <forkf+0x92>
  np->sz = p->sz;
    80001f94:	05093783          	ld	a5,80(s2)
    80001f98:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f9c:	06093683          	ld	a3,96(s2)
    80001fa0:	87b6                	mv	a5,a3
    80001fa2:	0609b703          	ld	a4,96(s3)
    80001fa6:	12068693          	addi	a3,a3,288
    80001faa:	0007b883          	ld	a7,0(a5)
    80001fae:	0087b803          	ld	a6,8(a5)
    80001fb2:	6b8c                	ld	a1,16(a5)
    80001fb4:	6f90                	ld	a2,24(a5)
    80001fb6:	01173023          	sd	a7,0(a4)
    80001fba:	01073423          	sd	a6,8(a4)
    80001fbe:	eb0c                	sd	a1,16(a4)
    80001fc0:	ef10                	sd	a2,24(a4)
    80001fc2:	02078793          	addi	a5,a5,32
    80001fc6:	02070713          	addi	a4,a4,32
    80001fca:	fed790e3          	bne	a5,a3,80001faa <forkf+0x56>
  np->trapframe->a0 = 0;
    80001fce:	0609b783          	ld	a5,96(s3)
    80001fd2:	0607b823          	sd	zero,112(a5)
  np->trapframe->epc = faddr;
    80001fd6:	0609b783          	ld	a5,96(s3)
    80001fda:	ef84                	sd	s1,24(a5)
    80001fdc:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80001fe0:	15800a13          	li	s4,344
    80001fe4:	a03d                	j	80002012 <forkf+0xbe>
    freeproc(np);
    80001fe6:	854e                	mv	a0,s3
    80001fe8:	00000097          	auipc	ra,0x0
    80001fec:	bd6080e7          	jalr	-1066(ra) # 80001bbe <freeproc>
    release(&np->lock);
    80001ff0:	854e                	mv	a0,s3
    80001ff2:	fffff097          	auipc	ra,0xfffff
    80001ff6:	ca4080e7          	jalr	-860(ra) # 80000c96 <release>
    return -1;
    80001ffa:	5a7d                	li	s4,-1
    80001ffc:	a069                	j	80002086 <forkf+0x132>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ffe:	00004097          	auipc	ra,0x4
    80002002:	980080e7          	jalr	-1664(ra) # 8000597e <filedup>
    80002006:	009987b3          	add	a5,s3,s1
    8000200a:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    8000200c:	04a1                	addi	s1,s1,8
    8000200e:	01448763          	beq	s1,s4,8000201c <forkf+0xc8>
    if(p->ofile[i])
    80002012:	009907b3          	add	a5,s2,s1
    80002016:	6388                	ld	a0,0(a5)
    80002018:	f17d                	bnez	a0,80001ffe <forkf+0xaa>
    8000201a:	bfcd                	j	8000200c <forkf+0xb8>
  np->cwd = idup(p->cwd);
    8000201c:	15893503          	ld	a0,344(s2)
    80002020:	00003097          	auipc	ra,0x3
    80002024:	ad4080e7          	jalr	-1324(ra) # 80004af4 <idup>
    80002028:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000202c:	4641                	li	a2,16
    8000202e:	16090593          	addi	a1,s2,352
    80002032:	16098513          	addi	a0,s3,352
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	dfa080e7          	jalr	-518(ra) # 80000e30 <safestrcpy>
  pid = np->pid;
    8000203e:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80002042:	854e                	mv	a0,s3
    80002044:	fffff097          	auipc	ra,0xfffff
    80002048:	c52080e7          	jalr	-942(ra) # 80000c96 <release>
  acquire(&wait_lock);
    8000204c:	00010497          	auipc	s1,0x10
    80002050:	29c48493          	addi	s1,s1,668 # 800122e8 <wait_lock>
    80002054:	8526                	mv	a0,s1
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	b8c080e7          	jalr	-1140(ra) # 80000be2 <acquire>
  np->parent = p;
    8000205e:	0529b023          	sd	s2,64(s3)
  release(&wait_lock);
    80002062:	8526                	mv	a0,s1
    80002064:	fffff097          	auipc	ra,0xfffff
    80002068:	c32080e7          	jalr	-974(ra) # 80000c96 <release>
  acquire(&np->lock);
    8000206c:	854e                	mv	a0,s3
    8000206e:	fffff097          	auipc	ra,0xfffff
    80002072:	b74080e7          	jalr	-1164(ra) # 80000be2 <acquire>
  np->state = RUNNABLE;
    80002076:	478d                	li	a5,3
    80002078:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000207c:	854e                	mv	a0,s3
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	c18080e7          	jalr	-1000(ra) # 80000c96 <release>
}
    80002086:	8552                	mv	a0,s4
    80002088:	70a2                	ld	ra,40(sp)
    8000208a:	7402                	ld	s0,32(sp)
    8000208c:	64e2                	ld	s1,24(sp)
    8000208e:	6942                	ld	s2,16(sp)
    80002090:	69a2                	ld	s3,8(sp)
    80002092:	6a02                	ld	s4,0(sp)
    80002094:	6145                	addi	sp,sp,48
    80002096:	8082                	ret
    return -1;
    80002098:	5a7d                	li	s4,-1
    8000209a:	b7f5                	j	80002086 <forkf+0x132>

000000008000209c <forkp>:
{
    8000209c:	7139                	addi	sp,sp,-64
    8000209e:	fc06                	sd	ra,56(sp)
    800020a0:	f822                	sd	s0,48(sp)
    800020a2:	f426                	sd	s1,40(sp)
    800020a4:	f04a                	sd	s2,32(sp)
    800020a6:	ec4e                	sd	s3,24(sp)
    800020a8:	e852                	sd	s4,16(sp)
    800020aa:	e456                	sd	s5,8(sp)
    800020ac:	0080                	addi	s0,sp,64
    800020ae:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    800020b0:	00000097          	auipc	ra,0x0
    800020b4:	924080e7          	jalr	-1756(ra) # 800019d4 <myproc>
    800020b8:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	b5c080e7          	jalr	-1188(ra) # 80001c16 <allocproc>
    800020c2:	14050763          	beqz	a0,80002210 <forkp+0x174>
    800020c6:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020c8:	0509b603          	ld	a2,80(s3)
    800020cc:	6d2c                	ld	a1,88(a0)
    800020ce:	0589b503          	ld	a0,88(s3)
    800020d2:	fffff097          	auipc	ra,0xfffff
    800020d6:	4c0080e7          	jalr	1216(ra) # 80001592 <uvmcopy>
    800020da:	04054663          	bltz	a0,80002126 <forkp+0x8a>
  np->sz = p->sz;
    800020de:	0509b783          	ld	a5,80(s3)
    800020e2:	04f93823          	sd	a5,80(s2)
  *(np->trapframe) = *(p->trapframe);
    800020e6:	0609b683          	ld	a3,96(s3)
    800020ea:	87b6                	mv	a5,a3
    800020ec:	06093703          	ld	a4,96(s2)
    800020f0:	12068693          	addi	a3,a3,288
    800020f4:	0007b803          	ld	a6,0(a5)
    800020f8:	6788                	ld	a0,8(a5)
    800020fa:	6b8c                	ld	a1,16(a5)
    800020fc:	6f90                	ld	a2,24(a5)
    800020fe:	01073023          	sd	a6,0(a4)
    80002102:	e708                	sd	a0,8(a4)
    80002104:	eb0c                	sd	a1,16(a4)
    80002106:	ef10                	sd	a2,24(a4)
    80002108:	02078793          	addi	a5,a5,32
    8000210c:	02070713          	addi	a4,a4,32
    80002110:	fed792e3          	bne	a5,a3,800020f4 <forkp+0x58>
  np->trapframe->a0 = 0;
    80002114:	06093783          	ld	a5,96(s2)
    80002118:	0607b823          	sd	zero,112(a5)
    8000211c:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80002120:	15800a13          	li	s4,344
    80002124:	a03d                	j	80002152 <forkp+0xb6>
    freeproc(np);
    80002126:	854a                	mv	a0,s2
    80002128:	00000097          	auipc	ra,0x0
    8000212c:	a96080e7          	jalr	-1386(ra) # 80001bbe <freeproc>
    release(&np->lock);
    80002130:	854a                	mv	a0,s2
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	b64080e7          	jalr	-1180(ra) # 80000c96 <release>
    return -1;
    8000213a:	5a7d                	li	s4,-1
    8000213c:	a0c1                	j	800021fc <forkp+0x160>
      np->ofile[i] = filedup(p->ofile[i]);
    8000213e:	00004097          	auipc	ra,0x4
    80002142:	840080e7          	jalr	-1984(ra) # 8000597e <filedup>
    80002146:	009907b3          	add	a5,s2,s1
    8000214a:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    8000214c:	04a1                	addi	s1,s1,8
    8000214e:	01448763          	beq	s1,s4,8000215c <forkp+0xc0>
    if(p->ofile[i])
    80002152:	009987b3          	add	a5,s3,s1
    80002156:	6388                	ld	a0,0(a5)
    80002158:	f17d                	bnez	a0,8000213e <forkp+0xa2>
    8000215a:	bfcd                	j	8000214c <forkp+0xb0>
  np->cwd = idup(p->cwd);
    8000215c:	1589b503          	ld	a0,344(s3)
    80002160:	00003097          	auipc	ra,0x3
    80002164:	994080e7          	jalr	-1644(ra) # 80004af4 <idup>
    80002168:	14a93c23          	sd	a0,344(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000216c:	4641                	li	a2,16
    8000216e:	16098593          	addi	a1,s3,352
    80002172:	16090513          	addi	a0,s2,352
    80002176:	fffff097          	auipc	ra,0xfffff
    8000217a:	cba080e7          	jalr	-838(ra) # 80000e30 <safestrcpy>
  pid = np->pid;
    8000217e:	03092a03          	lw	s4,48(s2)
  np->base_priority = priority;
    80002182:	03592a23          	sw	s5,52(s2)
  np->is_batchproc = 1;
    80002186:	4785                	li	a5,1
    80002188:	02f92e23          	sw	a5,60(s2)
  np->nextburst_estimate = 0;
    8000218c:	18092423          	sw	zero,392(s2)
  np->waittime = 0;
    80002190:	16092e23          	sw	zero,380(s2)
  release(&np->lock);
    80002194:	854a                	mv	a0,s2
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	b00080e7          	jalr	-1280(ra) # 80000c96 <release>
  batchsize++;
    8000219e:	00008717          	auipc	a4,0x8
    800021a2:	ebe70713          	addi	a4,a4,-322 # 8000a05c <batchsize>
    800021a6:	431c                	lw	a5,0(a4)
    800021a8:	2785                	addiw	a5,a5,1
    800021aa:	c31c                	sw	a5,0(a4)
  batchsize2++;
    800021ac:	00008717          	auipc	a4,0x8
    800021b0:	eac70713          	addi	a4,a4,-340 # 8000a058 <batchsize2>
    800021b4:	431c                	lw	a5,0(a4)
    800021b6:	2785                	addiw	a5,a5,1
    800021b8:	c31c                	sw	a5,0(a4)
  acquire(&wait_lock);
    800021ba:	00010497          	auipc	s1,0x10
    800021be:	12e48493          	addi	s1,s1,302 # 800122e8 <wait_lock>
    800021c2:	8526                	mv	a0,s1
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	a1e080e7          	jalr	-1506(ra) # 80000be2 <acquire>
  np->parent = p;
    800021cc:	05393023          	sd	s3,64(s2)
  release(&wait_lock);
    800021d0:	8526                	mv	a0,s1
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	ac4080e7          	jalr	-1340(ra) # 80000c96 <release>
  acquire(&np->lock);
    800021da:	854a                	mv	a0,s2
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	a06080e7          	jalr	-1530(ra) # 80000be2 <acquire>
  np->state = RUNNABLE;
    800021e4:	478d                	li	a5,3
    800021e6:	00f92c23          	sw	a5,24(s2)
  np->waitstart = np->ctime;
    800021ea:	17092783          	lw	a5,368(s2)
    800021ee:	18f92023          	sw	a5,384(s2)
  release(&np->lock);
    800021f2:	854a                	mv	a0,s2
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	aa2080e7          	jalr	-1374(ra) # 80000c96 <release>
}
    800021fc:	8552                	mv	a0,s4
    800021fe:	70e2                	ld	ra,56(sp)
    80002200:	7442                	ld	s0,48(sp)
    80002202:	74a2                	ld	s1,40(sp)
    80002204:	7902                	ld	s2,32(sp)
    80002206:	69e2                	ld	s3,24(sp)
    80002208:	6a42                	ld	s4,16(sp)
    8000220a:	6aa2                	ld	s5,8(sp)
    8000220c:	6121                	addi	sp,sp,64
    8000220e:	8082                	ret
    return -1;
    80002210:	5a7d                	li	s4,-1
    80002212:	b7ed                	j	800021fc <forkp+0x160>

0000000080002214 <scheduler>:
{
    80002214:	711d                	addi	sp,sp,-96
    80002216:	ec86                	sd	ra,88(sp)
    80002218:	e8a2                	sd	s0,80(sp)
    8000221a:	e4a6                	sd	s1,72(sp)
    8000221c:	e0ca                	sd	s2,64(sp)
    8000221e:	fc4e                	sd	s3,56(sp)
    80002220:	f852                	sd	s4,48(sp)
    80002222:	f456                	sd	s5,40(sp)
    80002224:	f05a                	sd	s6,32(sp)
    80002226:	ec5e                	sd	s7,24(sp)
    80002228:	e862                	sd	s8,16(sp)
    8000222a:	e466                	sd	s9,8(sp)
    8000222c:	e06a                	sd	s10,0(sp)
    8000222e:	1080                	addi	s0,sp,96
    80002230:	8792                	mv	a5,tp
  int id = r_tp();
    80002232:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002234:	00779a93          	slli	s5,a5,0x7
    80002238:	00010717          	auipc	a4,0x10
    8000223c:	09870713          	addi	a4,a4,152 # 800122d0 <pid_lock>
    80002240:	9756                	add	a4,a4,s5
    80002242:	02073823          	sd	zero,48(a4)
            swtch(&c->context, &p->context);
    80002246:	00010717          	auipc	a4,0x10
    8000224a:	0c270713          	addi	a4,a4,194 # 80012308 <cpus+0x8>
    8000224e:	9aba                	add	s5,s5,a4
          xticks = ticks;
    80002250:	00008997          	auipc	s3,0x8
    80002254:	e1c98993          	addi	s3,s3,-484 # 8000a06c <ticks>
            c->proc = p;
    80002258:	079e                	slli	a5,a5,0x7
    8000225a:	00010a17          	auipc	s4,0x10
    8000225e:	076a0a13          	addi	s4,s4,118 # 800122d0 <pid_lock>
    80002262:	9a3e                	add	s4,s4,a5
       for(p = proc; p < &proc[NPROC]; p++) {
    80002264:	00017917          	auipc	s2,0x17
    80002268:	89c90913          	addi	s2,s2,-1892 # 80018b00 <tickslock>
    8000226c:	aca9                	j	800024c6 <scheduler+0x2b2>
       acquire(&tickslock);
    8000226e:	00017517          	auipc	a0,0x17
    80002272:	89250513          	addi	a0,a0,-1902 # 80018b00 <tickslock>
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	96c080e7          	jalr	-1684(ra) # 80000be2 <acquire>
       xticks = ticks;
    8000227e:	0009ad03          	lw	s10,0(s3)
       release(&tickslock);
    80002282:	00017517          	auipc	a0,0x17
    80002286:	87e50513          	addi	a0,a0,-1922 # 80018b00 <tickslock>
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	a0c080e7          	jalr	-1524(ra) # 80000c96 <release>
       min_burst = 0x7FFFFFFF;
    80002292:	80000c37          	lui	s8,0x80000
    80002296:	fffc4c13          	not	s8,s8
       q = 0;
    8000229a:	4c81                	li	s9,0
       for(p = proc; p < &proc[NPROC]; p++) {
    8000229c:	00010497          	auipc	s1,0x10
    800022a0:	46448493          	addi	s1,s1,1124 # 80012700 <proc>
	  if(p->state == RUNNABLE) {
    800022a4:	4b8d                	li	s7,3
    800022a6:	a0ad                	j	80002310 <scheduler+0xfc>
                if (q) release(&q->lock);
    800022a8:	000c8763          	beqz	s9,800022b6 <scheduler+0xa2>
    800022ac:	8566                	mv	a0,s9
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	9e8080e7          	jalr	-1560(ra) # 80000c96 <release>
          q->state = RUNNING;
    800022b6:	4791                	li	a5,4
    800022b8:	cc9c                	sw	a5,24(s1)
          q->waittime += (xticks - q->waitstart);
    800022ba:	17c4a783          	lw	a5,380(s1)
    800022be:	01a787bb          	addw	a5,a5,s10
    800022c2:	1804a703          	lw	a4,384(s1)
    800022c6:	9f99                	subw	a5,a5,a4
    800022c8:	16f4ae23          	sw	a5,380(s1)
          q->burst_start = xticks;
    800022cc:	19a4a223          	sw	s10,388(s1)
          c->proc = q;
    800022d0:	029a3823          	sd	s1,48(s4)
          swtch(&c->context, &q->context);
    800022d4:	06848593          	addi	a1,s1,104
    800022d8:	8556                	mv	a0,s5
    800022da:	00001097          	auipc	ra,0x1
    800022de:	3f6080e7          	jalr	1014(ra) # 800036d0 <swtch>
          c->proc = 0;
    800022e2:	020a3823          	sd	zero,48(s4)
	  release(&q->lock);
    800022e6:	8526                	mv	a0,s1
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	9ae080e7          	jalr	-1618(ra) # 80000c96 <release>
    800022f0:	aad9                	j	800024c6 <scheduler+0x2b2>
             else release(&p->lock);
    800022f2:	8526                	mv	a0,s1
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	9a2080e7          	jalr	-1630(ra) # 80000c96 <release>
    800022fc:	a031                	j	80002308 <scheduler+0xf4>
	  else release(&p->lock);
    800022fe:	8526                	mv	a0,s1
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	996080e7          	jalr	-1642(ra) # 80000c96 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002308:	19048493          	addi	s1,s1,400
    8000230c:	03248d63          	beq	s1,s2,80002346 <scheduler+0x132>
          acquire(&p->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	8d0080e7          	jalr	-1840(ra) # 80000be2 <acquire>
	  if(p->state == RUNNABLE) {
    8000231a:	4c9c                	lw	a5,24(s1)
    8000231c:	ff7791e3          	bne	a5,s7,800022fe <scheduler+0xea>
	     if (!p->is_batchproc) {
    80002320:	5cdc                	lw	a5,60(s1)
    80002322:	d3d9                	beqz	a5,800022a8 <scheduler+0x94>
             else if (p->nextburst_estimate < min_burst) {
    80002324:	1884ab03          	lw	s6,392(s1)
    80002328:	fd8b55e3          	bge	s6,s8,800022f2 <scheduler+0xde>
		if (q) release(&q->lock);
    8000232c:	000c8a63          	beqz	s9,80002340 <scheduler+0x12c>
    80002330:	8566                	mv	a0,s9
    80002332:	fffff097          	auipc	ra,0xfffff
    80002336:	964080e7          	jalr	-1692(ra) # 80000c96 <release>
	        min_burst = p->nextburst_estimate;
    8000233a:	8c5a                	mv	s8,s6
		if (q) release(&q->lock);
    8000233c:	8ca6                	mv	s9,s1
    8000233e:	b7e9                	j	80002308 <scheduler+0xf4>
	        min_burst = p->nextburst_estimate;
    80002340:	8c5a                	mv	s8,s6
    80002342:	8ca6                	mv	s9,s1
    80002344:	b7d1                	j	80002308 <scheduler+0xf4>
       if (q) {
    80002346:	180c8063          	beqz	s9,800024c6 <scheduler+0x2b2>
    8000234a:	84e6                	mv	s1,s9
    8000234c:	b7ad                	j	800022b6 <scheduler+0xa2>
       acquire(&tickslock);
    8000234e:	00016517          	auipc	a0,0x16
    80002352:	7b250513          	addi	a0,a0,1970 # 80018b00 <tickslock>
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	88c080e7          	jalr	-1908(ra) # 80000be2 <acquire>
       xticks = ticks;
    8000235e:	0009ab03          	lw	s6,0(s3)
       release(&tickslock);
    80002362:	00016517          	auipc	a0,0x16
    80002366:	79e50513          	addi	a0,a0,1950 # 80018b00 <tickslock>
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	92c080e7          	jalr	-1748(ra) # 80000c96 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002372:	00010497          	auipc	s1,0x10
    80002376:	38e48493          	addi	s1,s1,910 # 80012700 <proc>
	  if(p->state == RUNNABLE) {
    8000237a:	4b8d                	li	s7,3
    8000237c:	a811                	j	80002390 <scheduler+0x17c>
	  release(&p->lock);
    8000237e:	8526                	mv	a0,s1
    80002380:	fffff097          	auipc	ra,0xfffff
    80002384:	916080e7          	jalr	-1770(ra) # 80000c96 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    80002388:	19048493          	addi	s1,s1,400
    8000238c:	03248e63          	beq	s1,s2,800023c8 <scheduler+0x1b4>
          acquire(&p->lock);
    80002390:	8526                	mv	a0,s1
    80002392:	fffff097          	auipc	ra,0xfffff
    80002396:	850080e7          	jalr	-1968(ra) # 80000be2 <acquire>
	  if(p->state == RUNNABLE) {
    8000239a:	4c9c                	lw	a5,24(s1)
    8000239c:	ff7791e3          	bne	a5,s7,8000237e <scheduler+0x16a>
	     p->cpu_usage = p->cpu_usage/2;
    800023a0:	18c4a683          	lw	a3,396(s1)
    800023a4:	01f6d71b          	srliw	a4,a3,0x1f
    800023a8:	9f35                	addw	a4,a4,a3
    800023aa:	4017571b          	sraiw	a4,a4,0x1
    800023ae:	18e4a623          	sw	a4,396(s1)
	     p->priority = p->base_priority + (p->cpu_usage/2);
    800023b2:	41f6d79b          	sraiw	a5,a3,0x1f
    800023b6:	01e7d79b          	srliw	a5,a5,0x1e
    800023ba:	9fb5                	addw	a5,a5,a3
    800023bc:	4027d79b          	sraiw	a5,a5,0x2
    800023c0:	58d8                	lw	a4,52(s1)
    800023c2:	9fb9                	addw	a5,a5,a4
    800023c4:	dc9c                	sw	a5,56(s1)
    800023c6:	bf65                	j	8000237e <scheduler+0x16a>
       min_prio = 0x7FFFFFFF;
    800023c8:	80000cb7          	lui	s9,0x80000
    800023cc:	fffccc93          	not	s9,s9
       q = 0;
    800023d0:	4d01                	li	s10,0
       for(p = proc; p < &proc[NPROC]; p++) {
    800023d2:	00010497          	auipc	s1,0x10
    800023d6:	32e48493          	addi	s1,s1,814 # 80012700 <proc>
          if(p->state == RUNNABLE) {
    800023da:	4c0d                	li	s8,3
    800023dc:	a0ad                	j	80002446 <scheduler+0x232>
                if (q) release(&q->lock);
    800023de:	000d0763          	beqz	s10,800023ec <scheduler+0x1d8>
    800023e2:	856a                	mv	a0,s10
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	8b2080e7          	jalr	-1870(ra) # 80000c96 <release>
          q->state = RUNNING;
    800023ec:	4791                	li	a5,4
    800023ee:	cc9c                	sw	a5,24(s1)
          q->waittime += (xticks - q->waitstart);
    800023f0:	17c4a783          	lw	a5,380(s1)
    800023f4:	016787bb          	addw	a5,a5,s6
    800023f8:	1804a703          	lw	a4,384(s1)
    800023fc:	9f99                	subw	a5,a5,a4
    800023fe:	16f4ae23          	sw	a5,380(s1)
          q->burst_start = xticks;
    80002402:	1964a223          	sw	s6,388(s1)
          c->proc = q;
    80002406:	029a3823          	sd	s1,48(s4)
          swtch(&c->context, &q->context);
    8000240a:	06848593          	addi	a1,s1,104
    8000240e:	8556                	mv	a0,s5
    80002410:	00001097          	auipc	ra,0x1
    80002414:	2c0080e7          	jalr	704(ra) # 800036d0 <swtch>
          c->proc = 0;
    80002418:	020a3823          	sd	zero,48(s4)
          release(&q->lock);
    8000241c:	8526                	mv	a0,s1
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	878080e7          	jalr	-1928(ra) # 80000c96 <release>
    80002426:	a045                	j	800024c6 <scheduler+0x2b2>
             else release(&p->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	86c080e7          	jalr	-1940(ra) # 80000c96 <release>
    80002432:	a031                	j	8000243e <scheduler+0x22a>
          else release(&p->lock);
    80002434:	8526                	mv	a0,s1
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	860080e7          	jalr	-1952(ra) # 80000c96 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    8000243e:	19048493          	addi	s1,s1,400
    80002442:	03248d63          	beq	s1,s2,8000247c <scheduler+0x268>
          acquire(&p->lock);
    80002446:	8526                	mv	a0,s1
    80002448:	ffffe097          	auipc	ra,0xffffe
    8000244c:	79a080e7          	jalr	1946(ra) # 80000be2 <acquire>
          if(p->state == RUNNABLE) {
    80002450:	4c9c                	lw	a5,24(s1)
    80002452:	ff8791e3          	bne	a5,s8,80002434 <scheduler+0x220>
             if (!p->is_batchproc) {
    80002456:	5cdc                	lw	a5,60(s1)
    80002458:	d3d9                	beqz	a5,800023de <scheduler+0x1ca>
             else if (p->priority < min_prio) {
    8000245a:	0384ab83          	lw	s7,56(s1)
    8000245e:	fd9bd5e3          	bge	s7,s9,80002428 <scheduler+0x214>
                if (q) release(&q->lock);
    80002462:	000d0a63          	beqz	s10,80002476 <scheduler+0x262>
    80002466:	856a                	mv	a0,s10
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	82e080e7          	jalr	-2002(ra) # 80000c96 <release>
                min_prio = p->priority;
    80002470:	8cde                	mv	s9,s7
                if (q) release(&q->lock);
    80002472:	8d26                	mv	s10,s1
    80002474:	b7e9                	j	8000243e <scheduler+0x22a>
                min_prio = p->priority;
    80002476:	8cde                	mv	s9,s7
    80002478:	8d26                	mv	s10,s1
    8000247a:	b7d1                	j	8000243e <scheduler+0x22a>
       if (q) {
    8000247c:	040d0563          	beqz	s10,800024c6 <scheduler+0x2b2>
    80002480:	84ea                	mv	s1,s10
    80002482:	b7ad                	j	800023ec <scheduler+0x1d8>
          acquire(&tickslock);
    80002484:	855a                	mv	a0,s6
    80002486:	ffffe097          	auipc	ra,0xffffe
    8000248a:	75c080e7          	jalr	1884(ra) # 80000be2 <acquire>
          xticks = ticks;
    8000248e:	0009ac83          	lw	s9,0(s3)
          release(&tickslock);
    80002492:	855a                	mv	a0,s6
    80002494:	fffff097          	auipc	ra,0xfffff
    80002498:	802080e7          	jalr	-2046(ra) # 80000c96 <release>
          acquire(&p->lock);
    8000249c:	8526                	mv	a0,s1
    8000249e:	ffffe097          	auipc	ra,0xffffe
    800024a2:	744080e7          	jalr	1860(ra) # 80000be2 <acquire>
          if(p->state == RUNNABLE) {
    800024a6:	4c9c                	lw	a5,24(s1)
    800024a8:	05878d63          	beq	a5,s8,80002502 <scheduler+0x2ee>
          release(&p->lock);
    800024ac:	8526                	mv	a0,s1
    800024ae:	ffffe097          	auipc	ra,0xffffe
    800024b2:	7e8080e7          	jalr	2024(ra) # 80000c96 <release>
       for(p = proc; p < &proc[NPROC]; p++) {
    800024b6:	19048493          	addi	s1,s1,400
    800024ba:	01248663          	beq	s1,s2,800024c6 <scheduler+0x2b2>
          if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_PREEMPT_RR)) break;
    800024be:	000ba783          	lw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffd7000>
    800024c2:	9bf5                	andi	a5,a5,-3
    800024c4:	d3e1                	beqz	a5,80002484 <scheduler+0x270>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024c6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024ca:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024ce:	10079073          	csrw	sstatus,a5
    if (sched_policy == SCHED_NPREEMPT_SJF) {
    800024d2:	00008797          	auipc	a5,0x8
    800024d6:	b967a783          	lw	a5,-1130(a5) # 8000a068 <sched_policy>
    800024da:	4705                	li	a4,1
    800024dc:	d8e789e3          	beq	a5,a4,8000226e <scheduler+0x5a>
    else if (sched_policy == SCHED_PREEMPT_UNIX) {
    800024e0:	470d                	li	a4,3
       for(p = proc; p < &proc[NPROC]; p++) {
    800024e2:	00010497          	auipc	s1,0x10
    800024e6:	21e48493          	addi	s1,s1,542 # 80012700 <proc>
    else if (sched_policy == SCHED_PREEMPT_UNIX) {
    800024ea:	e6e782e3          	beq	a5,a4,8000234e <scheduler+0x13a>
          if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_PREEMPT_RR)) break;
    800024ee:	00008b97          	auipc	s7,0x8
    800024f2:	b7ab8b93          	addi	s7,s7,-1158 # 8000a068 <sched_policy>
          acquire(&tickslock);
    800024f6:	00016b17          	auipc	s6,0x16
    800024fa:	60ab0b13          	addi	s6,s6,1546 # 80018b00 <tickslock>
          if(p->state == RUNNABLE) {
    800024fe:	4c0d                	li	s8,3
    80002500:	bf7d                	j	800024be <scheduler+0x2aa>
            p->state = RUNNING;
    80002502:	4791                	li	a5,4
    80002504:	cc9c                	sw	a5,24(s1)
	    p->waittime += (xticks - p->waitstart);
    80002506:	17c4a783          	lw	a5,380(s1)
    8000250a:	019787bb          	addw	a5,a5,s9
    8000250e:	1804a703          	lw	a4,384(s1)
    80002512:	9f99                	subw	a5,a5,a4
    80002514:	16f4ae23          	sw	a5,380(s1)
	    p->burst_start = xticks;
    80002518:	1994a223          	sw	s9,388(s1)
            c->proc = p;
    8000251c:	029a3823          	sd	s1,48(s4)
            swtch(&c->context, &p->context);
    80002520:	06848593          	addi	a1,s1,104
    80002524:	8556                	mv	a0,s5
    80002526:	00001097          	auipc	ra,0x1
    8000252a:	1aa080e7          	jalr	426(ra) # 800036d0 <swtch>
            c->proc = 0;
    8000252e:	020a3823          	sd	zero,48(s4)
    80002532:	bfad                	j	800024ac <scheduler+0x298>

0000000080002534 <sched>:
{
    80002534:	7179                	addi	sp,sp,-48
    80002536:	f406                	sd	ra,40(sp)
    80002538:	f022                	sd	s0,32(sp)
    8000253a:	ec26                	sd	s1,24(sp)
    8000253c:	e84a                	sd	s2,16(sp)
    8000253e:	e44e                	sd	s3,8(sp)
    80002540:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002542:	fffff097          	auipc	ra,0xfffff
    80002546:	492080e7          	jalr	1170(ra) # 800019d4 <myproc>
    8000254a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	61c080e7          	jalr	1564(ra) # 80000b68 <holding>
    80002554:	c93d                	beqz	a0,800025ca <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002556:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002558:	2781                	sext.w	a5,a5
    8000255a:	079e                	slli	a5,a5,0x7
    8000255c:	00010717          	auipc	a4,0x10
    80002560:	d7470713          	addi	a4,a4,-652 # 800122d0 <pid_lock>
    80002564:	97ba                	add	a5,a5,a4
    80002566:	0a87a703          	lw	a4,168(a5)
    8000256a:	4785                	li	a5,1
    8000256c:	06f71763          	bne	a4,a5,800025da <sched+0xa6>
  if(p->state == RUNNING)
    80002570:	4c98                	lw	a4,24(s1)
    80002572:	4791                	li	a5,4
    80002574:	06f70b63          	beq	a4,a5,800025ea <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002578:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000257c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000257e:	efb5                	bnez	a5,800025fa <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002580:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002582:	00010917          	auipc	s2,0x10
    80002586:	d4e90913          	addi	s2,s2,-690 # 800122d0 <pid_lock>
    8000258a:	2781                	sext.w	a5,a5
    8000258c:	079e                	slli	a5,a5,0x7
    8000258e:	97ca                	add	a5,a5,s2
    80002590:	0ac7a983          	lw	s3,172(a5)
    80002594:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002596:	2781                	sext.w	a5,a5
    80002598:	079e                	slli	a5,a5,0x7
    8000259a:	00010597          	auipc	a1,0x10
    8000259e:	d6e58593          	addi	a1,a1,-658 # 80012308 <cpus+0x8>
    800025a2:	95be                	add	a1,a1,a5
    800025a4:	06848513          	addi	a0,s1,104
    800025a8:	00001097          	auipc	ra,0x1
    800025ac:	128080e7          	jalr	296(ra) # 800036d0 <swtch>
    800025b0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800025b2:	2781                	sext.w	a5,a5
    800025b4:	079e                	slli	a5,a5,0x7
    800025b6:	97ca                	add	a5,a5,s2
    800025b8:	0b37a623          	sw	s3,172(a5)
}
    800025bc:	70a2                	ld	ra,40(sp)
    800025be:	7402                	ld	s0,32(sp)
    800025c0:	64e2                	ld	s1,24(sp)
    800025c2:	6942                	ld	s2,16(sp)
    800025c4:	69a2                	ld	s3,8(sp)
    800025c6:	6145                	addi	sp,sp,48
    800025c8:	8082                	ret
    panic("sched p->lock");
    800025ca:	00007517          	auipc	a0,0x7
    800025ce:	c4e50513          	addi	a0,a0,-946 # 80009218 <digits+0x1d8>
    800025d2:	ffffe097          	auipc	ra,0xffffe
    800025d6:	f6a080e7          	jalr	-150(ra) # 8000053c <panic>
    panic("sched locks");
    800025da:	00007517          	auipc	a0,0x7
    800025de:	c4e50513          	addi	a0,a0,-946 # 80009228 <digits+0x1e8>
    800025e2:	ffffe097          	auipc	ra,0xffffe
    800025e6:	f5a080e7          	jalr	-166(ra) # 8000053c <panic>
    panic("sched running");
    800025ea:	00007517          	auipc	a0,0x7
    800025ee:	c4e50513          	addi	a0,a0,-946 # 80009238 <digits+0x1f8>
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	f4a080e7          	jalr	-182(ra) # 8000053c <panic>
    panic("sched interruptible");
    800025fa:	00007517          	auipc	a0,0x7
    800025fe:	c4e50513          	addi	a0,a0,-946 # 80009248 <digits+0x208>
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	f3a080e7          	jalr	-198(ra) # 8000053c <panic>

000000008000260a <yield>:
{
    8000260a:	1101                	addi	sp,sp,-32
    8000260c:	ec06                	sd	ra,24(sp)
    8000260e:	e822                	sd	s0,16(sp)
    80002610:	e426                	sd	s1,8(sp)
    80002612:	e04a                	sd	s2,0(sp)
    80002614:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002616:	fffff097          	auipc	ra,0xfffff
    8000261a:	3be080e7          	jalr	958(ra) # 800019d4 <myproc>
    8000261e:	84aa                	mv	s1,a0
  acquire(&tickslock);
    80002620:	00016517          	auipc	a0,0x16
    80002624:	4e050513          	addi	a0,a0,1248 # 80018b00 <tickslock>
    80002628:	ffffe097          	auipc	ra,0xffffe
    8000262c:	5ba080e7          	jalr	1466(ra) # 80000be2 <acquire>
  xticks = ticks;
    80002630:	00008917          	auipc	s2,0x8
    80002634:	a3c92903          	lw	s2,-1476(s2) # 8000a06c <ticks>
  release(&tickslock);
    80002638:	00016517          	auipc	a0,0x16
    8000263c:	4c850513          	addi	a0,a0,1224 # 80018b00 <tickslock>
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	656080e7          	jalr	1622(ra) # 80000c96 <release>
  acquire(&p->lock);
    80002648:	8526                	mv	a0,s1
    8000264a:	ffffe097          	auipc	ra,0xffffe
    8000264e:	598080e7          	jalr	1432(ra) # 80000be2 <acquire>
  p->state = RUNNABLE;
    80002652:	478d                	li	a5,3
    80002654:	cc9c                	sw	a5,24(s1)
  p->waitstart = xticks;
    80002656:	1924a023          	sw	s2,384(s1)
  p->cpu_usage += SCHED_PARAM_CPU_USAGE;
    8000265a:	18c4a783          	lw	a5,396(s1)
    8000265e:	0c87879b          	addiw	a5,a5,200
    80002662:	18f4a623          	sw	a5,396(s1)
  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    80002666:	5cdc                	lw	a5,60(s1)
    80002668:	c7ed                	beqz	a5,80002752 <yield+0x148>
    8000266a:	1844a683          	lw	a3,388(s1)
    8000266e:	0f268263          	beq	a3,s2,80002752 <yield+0x148>
     num_cpubursts++;
    80002672:	00008717          	auipc	a4,0x8
    80002676:	9d270713          	addi	a4,a4,-1582 # 8000a044 <num_cpubursts>
    8000267a:	431c                	lw	a5,0(a4)
    8000267c:	2785                	addiw	a5,a5,1
    8000267e:	c31c                	sw	a5,0(a4)
     cpubursts_tot += (xticks - p->burst_start);
    80002680:	40d9073b          	subw	a4,s2,a3
    80002684:	0007059b          	sext.w	a1,a4
    80002688:	00008617          	auipc	a2,0x8
    8000268c:	9b860613          	addi	a2,a2,-1608 # 8000a040 <cpubursts_tot>
    80002690:	421c                	lw	a5,0(a2)
    80002692:	9fb9                	addw	a5,a5,a4
    80002694:	c21c                	sw	a5,0(a2)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002696:	00008797          	auipc	a5,0x8
    8000269a:	9a67a783          	lw	a5,-1626(a5) # 8000a03c <cpubursts_max>
    8000269e:	00b7f663          	bgeu	a5,a1,800026aa <yield+0xa0>
    800026a2:	00008797          	auipc	a5,0x8
    800026a6:	98e7ad23          	sw	a4,-1638(a5) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    800026aa:	00007797          	auipc	a5,0x7
    800026ae:	45e7a783          	lw	a5,1118(a5) # 80009b08 <cpubursts_min>
    800026b2:	00f5f663          	bgeu	a1,a5,800026be <yield+0xb4>
    800026b6:	00007797          	auipc	a5,0x7
    800026ba:	44e7a923          	sw	a4,1106(a5) # 80009b08 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    800026be:	1884a603          	lw	a2,392(s1)
    800026c2:	02c05763          	blez	a2,800026f0 <yield+0xe6>
        estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    800026c6:	0006079b          	sext.w	a5,a2
    800026ca:	0ab7e363          	bltu	a5,a1,80002770 <yield+0x166>
    800026ce:	9ebd                	addw	a3,a3,a5
    800026d0:	412686bb          	subw	a3,a3,s2
    800026d4:	00008597          	auipc	a1,0x8
    800026d8:	95858593          	addi	a1,a1,-1704 # 8000a02c <estimation_error>
    800026dc:	419c                	lw	a5,0(a1)
    800026de:	9ebd                	addw	a3,a3,a5
    800026e0:	c194                	sw	a3,0(a1)
	estimation_error_instance++;
    800026e2:	00008697          	auipc	a3,0x8
    800026e6:	94668693          	addi	a3,a3,-1722 # 8000a028 <estimation_error_instance>
    800026ea:	429c                	lw	a5,0(a3)
    800026ec:	2785                	addiw	a5,a5,1
    800026ee:	c29c                	sw	a5,0(a3)
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    800026f0:	01f6579b          	srliw	a5,a2,0x1f
    800026f4:	9fb1                	addw	a5,a5,a2
    800026f6:	4017d79b          	sraiw	a5,a5,0x1
    800026fa:	9fb9                	addw	a5,a5,a4
    800026fc:	0017571b          	srliw	a4,a4,0x1
    80002700:	9f99                	subw	a5,a5,a4
    80002702:	0007871b          	sext.w	a4,a5
    80002706:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    8000270a:	04e05463          	blez	a4,80002752 <yield+0x148>
        num_cpubursts_est++;
    8000270e:	00008617          	auipc	a2,0x8
    80002712:	92a60613          	addi	a2,a2,-1750 # 8000a038 <num_cpubursts_est>
    80002716:	4214                	lw	a3,0(a2)
    80002718:	2685                	addiw	a3,a3,1
    8000271a:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    8000271c:	00008617          	auipc	a2,0x8
    80002720:	91860613          	addi	a2,a2,-1768 # 8000a034 <cpubursts_est_tot>
    80002724:	4214                	lw	a3,0(a2)
    80002726:	9ebd                	addw	a3,a3,a5
    80002728:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    8000272a:	00008697          	auipc	a3,0x8
    8000272e:	9066a683          	lw	a3,-1786(a3) # 8000a030 <cpubursts_est_max>
    80002732:	00e6d663          	bge	a3,a4,8000273e <yield+0x134>
    80002736:	00008697          	auipc	a3,0x8
    8000273a:	8ef6ad23          	sw	a5,-1798(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    8000273e:	00007697          	auipc	a3,0x7
    80002742:	3c66a683          	lw	a3,966(a3) # 80009b04 <cpubursts_est_min>
    80002746:	00d75663          	bge	a4,a3,80002752 <yield+0x148>
    8000274a:	00007717          	auipc	a4,0x7
    8000274e:	3af72d23          	sw	a5,954(a4) # 80009b04 <cpubursts_est_min>
  sched();
    80002752:	00000097          	auipc	ra,0x0
    80002756:	de2080e7          	jalr	-542(ra) # 80002534 <sched>
  release(&p->lock);
    8000275a:	8526                	mv	a0,s1
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	53a080e7          	jalr	1338(ra) # 80000c96 <release>
}
    80002764:	60e2                	ld	ra,24(sp)
    80002766:	6442                	ld	s0,16(sp)
    80002768:	64a2                	ld	s1,8(sp)
    8000276a:	6902                	ld	s2,0(sp)
    8000276c:	6105                	addi	sp,sp,32
    8000276e:	8082                	ret
        estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002770:	40f706bb          	subw	a3,a4,a5
    80002774:	b785                	j	800026d4 <yield+0xca>

0000000080002776 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002776:	7179                	addi	sp,sp,-48
    80002778:	f406                	sd	ra,40(sp)
    8000277a:	f022                	sd	s0,32(sp)
    8000277c:	ec26                	sd	s1,24(sp)
    8000277e:	e84a                	sd	s2,16(sp)
    80002780:	e44e                	sd	s3,8(sp)
    80002782:	e052                	sd	s4,0(sp)
    80002784:	1800                	addi	s0,sp,48
    80002786:	89aa                	mv	s3,a0
    80002788:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000278a:	fffff097          	auipc	ra,0xfffff
    8000278e:	24a080e7          	jalr	586(ra) # 800019d4 <myproc>
    80002792:	84aa                	mv	s1,a0
  uint xticks;

  if (!holding(&tickslock)) {
    80002794:	00016517          	auipc	a0,0x16
    80002798:	36c50513          	addi	a0,a0,876 # 80018b00 <tickslock>
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	3cc080e7          	jalr	972(ra) # 80000b68 <holding>
    800027a4:	14050863          	beqz	a0,800028f4 <sleep+0x17e>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    800027a8:	00008a17          	auipc	s4,0x8
    800027ac:	8c4a2a03          	lw	s4,-1852(s4) # 8000a06c <ticks>
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800027b0:	8526                	mv	a0,s1
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	430080e7          	jalr	1072(ra) # 80000be2 <acquire>
  release(lk);
    800027ba:	854a                	mv	a0,s2
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	4da080e7          	jalr	1242(ra) # 80000c96 <release>

  // Go to sleep.
  p->chan = chan;
    800027c4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800027c8:	4789                	li	a5,2
    800027ca:	cc9c                	sw	a5,24(s1)

  p->cpu_usage += (SCHED_PARAM_CPU_USAGE/2);
    800027cc:	18c4a783          	lw	a5,396(s1)
    800027d0:	0647879b          	addiw	a5,a5,100
    800027d4:	18f4a623          	sw	a5,396(s1)

  if ((p->is_batchproc) && ((xticks - p->burst_start) > 0)) {
    800027d8:	5cdc                	lw	a5,60(s1)
    800027da:	c7ed                	beqz	a5,800028c4 <sleep+0x14e>
    800027dc:	1844a683          	lw	a3,388(s1)
    800027e0:	0f468263          	beq	a3,s4,800028c4 <sleep+0x14e>
     num_cpubursts++;
    800027e4:	00008717          	auipc	a4,0x8
    800027e8:	86070713          	addi	a4,a4,-1952 # 8000a044 <num_cpubursts>
    800027ec:	431c                	lw	a5,0(a4)
    800027ee:	2785                	addiw	a5,a5,1
    800027f0:	c31c                	sw	a5,0(a4)
     cpubursts_tot += (xticks - p->burst_start);
    800027f2:	40da073b          	subw	a4,s4,a3
    800027f6:	0007059b          	sext.w	a1,a4
    800027fa:	00008617          	auipc	a2,0x8
    800027fe:	84660613          	addi	a2,a2,-1978 # 8000a040 <cpubursts_tot>
    80002802:	421c                	lw	a5,0(a2)
    80002804:	9fb9                	addw	a5,a5,a4
    80002806:	c21c                	sw	a5,0(a2)
     if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002808:	00008797          	auipc	a5,0x8
    8000280c:	8347a783          	lw	a5,-1996(a5) # 8000a03c <cpubursts_max>
    80002810:	00b7f663          	bgeu	a5,a1,8000281c <sleep+0xa6>
    80002814:	00008797          	auipc	a5,0x8
    80002818:	82e7a423          	sw	a4,-2008(a5) # 8000a03c <cpubursts_max>
     if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    8000281c:	00007797          	auipc	a5,0x7
    80002820:	2ec7a783          	lw	a5,748(a5) # 80009b08 <cpubursts_min>
    80002824:	00f5f663          	bgeu	a1,a5,80002830 <sleep+0xba>
    80002828:	00007797          	auipc	a5,0x7
    8000282c:	2ee7a023          	sw	a4,736(a5) # 80009b08 <cpubursts_min>
     if (p->nextburst_estimate > 0) {
    80002830:	1884a603          	lw	a2,392(s1)
    80002834:	02c05763          	blez	a2,80002862 <sleep+0xec>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002838:	0006079b          	sext.w	a5,a2
    8000283c:	0eb7e163          	bltu	a5,a1,8000291e <sleep+0x1a8>
    80002840:	9ebd                	addw	a3,a3,a5
    80002842:	414686bb          	subw	a3,a3,s4
    80002846:	00007597          	auipc	a1,0x7
    8000284a:	7e658593          	addi	a1,a1,2022 # 8000a02c <estimation_error>
    8000284e:	419c                	lw	a5,0(a1)
    80002850:	9ebd                	addw	a3,a3,a5
    80002852:	c194                	sw	a3,0(a1)
        estimation_error_instance++;
    80002854:	00007697          	auipc	a3,0x7
    80002858:	7d468693          	addi	a3,a3,2004 # 8000a028 <estimation_error_instance>
    8000285c:	429c                	lw	a5,0(a3)
    8000285e:	2785                	addiw	a5,a5,1
    80002860:	c29c                	sw	a5,0(a3)
     }
     p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    80002862:	01f6579b          	srliw	a5,a2,0x1f
    80002866:	9fb1                	addw	a5,a5,a2
    80002868:	4017d79b          	sraiw	a5,a5,0x1
    8000286c:	9fb9                	addw	a5,a5,a4
    8000286e:	0017571b          	srliw	a4,a4,0x1
    80002872:	9f99                	subw	a5,a5,a4
    80002874:	0007871b          	sext.w	a4,a5
    80002878:	18f4a423          	sw	a5,392(s1)
     if (p->nextburst_estimate > 0) {
    8000287c:	04e05463          	blez	a4,800028c4 <sleep+0x14e>
        num_cpubursts_est++;
    80002880:	00007617          	auipc	a2,0x7
    80002884:	7b860613          	addi	a2,a2,1976 # 8000a038 <num_cpubursts_est>
    80002888:	4214                	lw	a3,0(a2)
    8000288a:	2685                	addiw	a3,a3,1
    8000288c:	c214                	sw	a3,0(a2)
        cpubursts_est_tot += p->nextburst_estimate;
    8000288e:	00007617          	auipc	a2,0x7
    80002892:	7a660613          	addi	a2,a2,1958 # 8000a034 <cpubursts_est_tot>
    80002896:	4214                	lw	a3,0(a2)
    80002898:	9ebd                	addw	a3,a3,a5
    8000289a:	c214                	sw	a3,0(a2)
        if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    8000289c:	00007697          	auipc	a3,0x7
    800028a0:	7946a683          	lw	a3,1940(a3) # 8000a030 <cpubursts_est_max>
    800028a4:	00e6d663          	bge	a3,a4,800028b0 <sleep+0x13a>
    800028a8:	00007697          	auipc	a3,0x7
    800028ac:	78f6a423          	sw	a5,1928(a3) # 8000a030 <cpubursts_est_max>
        if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    800028b0:	00007697          	auipc	a3,0x7
    800028b4:	2546a683          	lw	a3,596(a3) # 80009b04 <cpubursts_est_min>
    800028b8:	00d75663          	bge	a4,a3,800028c4 <sleep+0x14e>
    800028bc:	00007717          	auipc	a4,0x7
    800028c0:	24f72423          	sw	a5,584(a4) # 80009b04 <cpubursts_est_min>
     }
  }

  sched();
    800028c4:	00000097          	auipc	ra,0x0
    800028c8:	c70080e7          	jalr	-912(ra) # 80002534 <sched>

  // Tidy up.
  p->chan = 0;
    800028cc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800028d0:	8526                	mv	a0,s1
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	3c4080e7          	jalr	964(ra) # 80000c96 <release>
  acquire(lk);
    800028da:	854a                	mv	a0,s2
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	306080e7          	jalr	774(ra) # 80000be2 <acquire>
}
    800028e4:	70a2                	ld	ra,40(sp)
    800028e6:	7402                	ld	s0,32(sp)
    800028e8:	64e2                	ld	s1,24(sp)
    800028ea:	6942                	ld	s2,16(sp)
    800028ec:	69a2                	ld	s3,8(sp)
    800028ee:	6a02                	ld	s4,0(sp)
    800028f0:	6145                	addi	sp,sp,48
    800028f2:	8082                	ret
     acquire(&tickslock);
    800028f4:	00016517          	auipc	a0,0x16
    800028f8:	20c50513          	addi	a0,a0,524 # 80018b00 <tickslock>
    800028fc:	ffffe097          	auipc	ra,0xffffe
    80002900:	2e6080e7          	jalr	742(ra) # 80000be2 <acquire>
     xticks = ticks;
    80002904:	00007a17          	auipc	s4,0x7
    80002908:	768a2a03          	lw	s4,1896(s4) # 8000a06c <ticks>
     release(&tickslock);
    8000290c:	00016517          	auipc	a0,0x16
    80002910:	1f450513          	addi	a0,a0,500 # 80018b00 <tickslock>
    80002914:	ffffe097          	auipc	ra,0xffffe
    80002918:	382080e7          	jalr	898(ra) # 80000c96 <release>
    8000291c:	bd51                	j	800027b0 <sleep+0x3a>
	estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    8000291e:	40f706bb          	subw	a3,a4,a5
    80002922:	b715                	j	80002846 <sleep+0xd0>

0000000080002924 <wait>:
{
    80002924:	715d                	addi	sp,sp,-80
    80002926:	e486                	sd	ra,72(sp)
    80002928:	e0a2                	sd	s0,64(sp)
    8000292a:	fc26                	sd	s1,56(sp)
    8000292c:	f84a                	sd	s2,48(sp)
    8000292e:	f44e                	sd	s3,40(sp)
    80002930:	f052                	sd	s4,32(sp)
    80002932:	ec56                	sd	s5,24(sp)
    80002934:	e85a                	sd	s6,16(sp)
    80002936:	e45e                	sd	s7,8(sp)
    80002938:	e062                	sd	s8,0(sp)
    8000293a:	0880                	addi	s0,sp,80
    8000293c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000293e:	fffff097          	auipc	ra,0xfffff
    80002942:	096080e7          	jalr	150(ra) # 800019d4 <myproc>
    80002946:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002948:	00010517          	auipc	a0,0x10
    8000294c:	9a050513          	addi	a0,a0,-1632 # 800122e8 <wait_lock>
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	292080e7          	jalr	658(ra) # 80000be2 <acquire>
    havekids = 0;
    80002958:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000295a:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    8000295c:	00016997          	auipc	s3,0x16
    80002960:	1a498993          	addi	s3,s3,420 # 80018b00 <tickslock>
        havekids = 1;
    80002964:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002966:	00010c17          	auipc	s8,0x10
    8000296a:	982c0c13          	addi	s8,s8,-1662 # 800122e8 <wait_lock>
    havekids = 0;
    8000296e:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002970:	00010497          	auipc	s1,0x10
    80002974:	d9048493          	addi	s1,s1,-624 # 80012700 <proc>
    80002978:	a0bd                	j	800029e6 <wait+0xc2>
          pid = np->pid;
    8000297a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000297e:	000b0e63          	beqz	s6,8000299a <wait+0x76>
    80002982:	4691                	li	a3,4
    80002984:	02c48613          	addi	a2,s1,44
    80002988:	85da                	mv	a1,s6
    8000298a:	05893503          	ld	a0,88(s2)
    8000298e:	fffff097          	auipc	ra,0xfffff
    80002992:	d08080e7          	jalr	-760(ra) # 80001696 <copyout>
    80002996:	02054563          	bltz	a0,800029c0 <wait+0x9c>
          freeproc(np);
    8000299a:	8526                	mv	a0,s1
    8000299c:	fffff097          	auipc	ra,0xfffff
    800029a0:	222080e7          	jalr	546(ra) # 80001bbe <freeproc>
          release(&np->lock);
    800029a4:	8526                	mv	a0,s1
    800029a6:	ffffe097          	auipc	ra,0xffffe
    800029aa:	2f0080e7          	jalr	752(ra) # 80000c96 <release>
          release(&wait_lock);
    800029ae:	00010517          	auipc	a0,0x10
    800029b2:	93a50513          	addi	a0,a0,-1734 # 800122e8 <wait_lock>
    800029b6:	ffffe097          	auipc	ra,0xffffe
    800029ba:	2e0080e7          	jalr	736(ra) # 80000c96 <release>
          return pid;
    800029be:	a09d                	j	80002a24 <wait+0x100>
            release(&np->lock);
    800029c0:	8526                	mv	a0,s1
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	2d4080e7          	jalr	724(ra) # 80000c96 <release>
            release(&wait_lock);
    800029ca:	00010517          	auipc	a0,0x10
    800029ce:	91e50513          	addi	a0,a0,-1762 # 800122e8 <wait_lock>
    800029d2:	ffffe097          	auipc	ra,0xffffe
    800029d6:	2c4080e7          	jalr	708(ra) # 80000c96 <release>
            return -1;
    800029da:	59fd                	li	s3,-1
    800029dc:	a0a1                	j	80002a24 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800029de:	19048493          	addi	s1,s1,400
    800029e2:	03348463          	beq	s1,s3,80002a0a <wait+0xe6>
      if(np->parent == p){
    800029e6:	60bc                	ld	a5,64(s1)
    800029e8:	ff279be3          	bne	a5,s2,800029de <wait+0xba>
        acquire(&np->lock);
    800029ec:	8526                	mv	a0,s1
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	1f4080e7          	jalr	500(ra) # 80000be2 <acquire>
        if(np->state == ZOMBIE){
    800029f6:	4c9c                	lw	a5,24(s1)
    800029f8:	f94781e3          	beq	a5,s4,8000297a <wait+0x56>
        release(&np->lock);
    800029fc:	8526                	mv	a0,s1
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	298080e7          	jalr	664(ra) # 80000c96 <release>
        havekids = 1;
    80002a06:	8756                	mv	a4,s5
    80002a08:	bfd9                	j	800029de <wait+0xba>
    if(!havekids || p->killed){
    80002a0a:	c701                	beqz	a4,80002a12 <wait+0xee>
    80002a0c:	02892783          	lw	a5,40(s2)
    80002a10:	c79d                	beqz	a5,80002a3e <wait+0x11a>
      release(&wait_lock);
    80002a12:	00010517          	auipc	a0,0x10
    80002a16:	8d650513          	addi	a0,a0,-1834 # 800122e8 <wait_lock>
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	27c080e7          	jalr	636(ra) # 80000c96 <release>
      return -1;
    80002a22:	59fd                	li	s3,-1
}
    80002a24:	854e                	mv	a0,s3
    80002a26:	60a6                	ld	ra,72(sp)
    80002a28:	6406                	ld	s0,64(sp)
    80002a2a:	74e2                	ld	s1,56(sp)
    80002a2c:	7942                	ld	s2,48(sp)
    80002a2e:	79a2                	ld	s3,40(sp)
    80002a30:	7a02                	ld	s4,32(sp)
    80002a32:	6ae2                	ld	s5,24(sp)
    80002a34:	6b42                	ld	s6,16(sp)
    80002a36:	6ba2                	ld	s7,8(sp)
    80002a38:	6c02                	ld	s8,0(sp)
    80002a3a:	6161                	addi	sp,sp,80
    80002a3c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a3e:	85e2                	mv	a1,s8
    80002a40:	854a                	mv	a0,s2
    80002a42:	00000097          	auipc	ra,0x0
    80002a46:	d34080e7          	jalr	-716(ra) # 80002776 <sleep>
    havekids = 0;
    80002a4a:	b715                	j	8000296e <wait+0x4a>

0000000080002a4c <waitpid>:
{
    80002a4c:	711d                	addi	sp,sp,-96
    80002a4e:	ec86                	sd	ra,88(sp)
    80002a50:	e8a2                	sd	s0,80(sp)
    80002a52:	e4a6                	sd	s1,72(sp)
    80002a54:	e0ca                	sd	s2,64(sp)
    80002a56:	fc4e                	sd	s3,56(sp)
    80002a58:	f852                	sd	s4,48(sp)
    80002a5a:	f456                	sd	s5,40(sp)
    80002a5c:	f05a                	sd	s6,32(sp)
    80002a5e:	ec5e                	sd	s7,24(sp)
    80002a60:	e862                	sd	s8,16(sp)
    80002a62:	e466                	sd	s9,8(sp)
    80002a64:	1080                	addi	s0,sp,96
    80002a66:	8a2a                	mv	s4,a0
    80002a68:	8c2e                	mv	s8,a1
  struct proc *p = myproc();
    80002a6a:	fffff097          	auipc	ra,0xfffff
    80002a6e:	f6a080e7          	jalr	-150(ra) # 800019d4 <myproc>
    80002a72:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002a74:	00010517          	auipc	a0,0x10
    80002a78:	87450513          	addi	a0,a0,-1932 # 800122e8 <wait_lock>
    80002a7c:	ffffe097          	auipc	ra,0xffffe
    80002a80:	166080e7          	jalr	358(ra) # 80000be2 <acquire>
  int found=0;
    80002a84:	4c81                	li	s9,0
        if(np->state == ZOMBIE){
    80002a86:	4a95                	li	s5,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002a88:	00016997          	auipc	s3,0x16
    80002a8c:	07898993          	addi	s3,s3,120 # 80018b00 <tickslock>
	found = 1;
    80002a90:	4b05                	li	s6,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a92:	00010b97          	auipc	s7,0x10
    80002a96:	856b8b93          	addi	s7,s7,-1962 # 800122e8 <wait_lock>
    80002a9a:	a0d1                	j	80002b5e <waitpid+0x112>
           if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002a9c:	000c0e63          	beqz	s8,80002ab8 <waitpid+0x6c>
    80002aa0:	4691                	li	a3,4
    80002aa2:	02c48613          	addi	a2,s1,44
    80002aa6:	85e2                	mv	a1,s8
    80002aa8:	05893503          	ld	a0,88(s2)
    80002aac:	fffff097          	auipc	ra,0xfffff
    80002ab0:	bea080e7          	jalr	-1046(ra) # 80001696 <copyout>
    80002ab4:	04054263          	bltz	a0,80002af8 <waitpid+0xac>
           freeproc(np);
    80002ab8:	8526                	mv	a0,s1
    80002aba:	fffff097          	auipc	ra,0xfffff
    80002abe:	104080e7          	jalr	260(ra) # 80001bbe <freeproc>
           release(&np->lock);
    80002ac2:	8526                	mv	a0,s1
    80002ac4:	ffffe097          	auipc	ra,0xffffe
    80002ac8:	1d2080e7          	jalr	466(ra) # 80000c96 <release>
           release(&wait_lock);
    80002acc:	00010517          	auipc	a0,0x10
    80002ad0:	81c50513          	addi	a0,a0,-2020 # 800122e8 <wait_lock>
    80002ad4:	ffffe097          	auipc	ra,0xffffe
    80002ad8:	1c2080e7          	jalr	450(ra) # 80000c96 <release>
           return pid;
    80002adc:	8552                	mv	a0,s4
}
    80002ade:	60e6                	ld	ra,88(sp)
    80002ae0:	6446                	ld	s0,80(sp)
    80002ae2:	64a6                	ld	s1,72(sp)
    80002ae4:	6906                	ld	s2,64(sp)
    80002ae6:	79e2                	ld	s3,56(sp)
    80002ae8:	7a42                	ld	s4,48(sp)
    80002aea:	7aa2                	ld	s5,40(sp)
    80002aec:	7b02                	ld	s6,32(sp)
    80002aee:	6be2                	ld	s7,24(sp)
    80002af0:	6c42                	ld	s8,16(sp)
    80002af2:	6ca2                	ld	s9,8(sp)
    80002af4:	6125                	addi	sp,sp,96
    80002af6:	8082                	ret
             release(&np->lock);
    80002af8:	8526                	mv	a0,s1
    80002afa:	ffffe097          	auipc	ra,0xffffe
    80002afe:	19c080e7          	jalr	412(ra) # 80000c96 <release>
             release(&wait_lock);
    80002b02:	0000f517          	auipc	a0,0xf
    80002b06:	7e650513          	addi	a0,a0,2022 # 800122e8 <wait_lock>
    80002b0a:	ffffe097          	auipc	ra,0xffffe
    80002b0e:	18c080e7          	jalr	396(ra) # 80000c96 <release>
             return -1;
    80002b12:	557d                	li	a0,-1
    80002b14:	b7e9                	j	80002ade <waitpid+0x92>
    for(np = proc; np < &proc[NPROC]; np++){
    80002b16:	19048493          	addi	s1,s1,400
    80002b1a:	03348763          	beq	s1,s3,80002b48 <waitpid+0xfc>
      if((np->parent == p) && (np->pid == pid)){
    80002b1e:	60bc                	ld	a5,64(s1)
    80002b20:	ff279be3          	bne	a5,s2,80002b16 <waitpid+0xca>
    80002b24:	589c                	lw	a5,48(s1)
    80002b26:	ff4798e3          	bne	a5,s4,80002b16 <waitpid+0xca>
        acquire(&np->lock);
    80002b2a:	8526                	mv	a0,s1
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	0b6080e7          	jalr	182(ra) # 80000be2 <acquire>
        if(np->state == ZOMBIE){
    80002b34:	4c9c                	lw	a5,24(s1)
    80002b36:	f75783e3          	beq	a5,s5,80002a9c <waitpid+0x50>
        release(&np->lock);
    80002b3a:	8526                	mv	a0,s1
    80002b3c:	ffffe097          	auipc	ra,0xffffe
    80002b40:	15a080e7          	jalr	346(ra) # 80000c96 <release>
	found = 1;
    80002b44:	8cda                	mv	s9,s6
    80002b46:	bfc1                	j	80002b16 <waitpid+0xca>
    if(!found || p->killed){
    80002b48:	020c8063          	beqz	s9,80002b68 <waitpid+0x11c>
    80002b4c:	02892783          	lw	a5,40(s2)
    80002b50:	ef81                	bnez	a5,80002b68 <waitpid+0x11c>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002b52:	85de                	mv	a1,s7
    80002b54:	854a                	mv	a0,s2
    80002b56:	00000097          	auipc	ra,0x0
    80002b5a:	c20080e7          	jalr	-992(ra) # 80002776 <sleep>
    for(np = proc; np < &proc[NPROC]; np++){
    80002b5e:	00010497          	auipc	s1,0x10
    80002b62:	ba248493          	addi	s1,s1,-1118 # 80012700 <proc>
    80002b66:	bf65                	j	80002b1e <waitpid+0xd2>
      release(&wait_lock);
    80002b68:	0000f517          	auipc	a0,0xf
    80002b6c:	78050513          	addi	a0,a0,1920 # 800122e8 <wait_lock>
    80002b70:	ffffe097          	auipc	ra,0xffffe
    80002b74:	126080e7          	jalr	294(ra) # 80000c96 <release>
      return -1;
    80002b78:	557d                	li	a0,-1
    80002b7a:	b795                	j	80002ade <waitpid+0x92>

0000000080002b7c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002b7c:	7139                	addi	sp,sp,-64
    80002b7e:	fc06                	sd	ra,56(sp)
    80002b80:	f822                	sd	s0,48(sp)
    80002b82:	f426                	sd	s1,40(sp)
    80002b84:	f04a                	sd	s2,32(sp)
    80002b86:	ec4e                	sd	s3,24(sp)
    80002b88:	e852                	sd	s4,16(sp)
    80002b8a:	e456                	sd	s5,8(sp)
    80002b8c:	e05a                	sd	s6,0(sp)
    80002b8e:	0080                	addi	s0,sp,64
    80002b90:	8a2a                	mv	s4,a0
  struct proc *p;
  uint xticks;

  if (!holding(&tickslock)) {
    80002b92:	00016517          	auipc	a0,0x16
    80002b96:	f6e50513          	addi	a0,a0,-146 # 80018b00 <tickslock>
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	fce080e7          	jalr	-50(ra) # 80000b68 <holding>
    80002ba2:	c105                	beqz	a0,80002bc2 <wakeup+0x46>
     acquire(&tickslock);
     xticks = ticks;
     release(&tickslock);
  }
  else xticks = ticks;
    80002ba4:	00007b17          	auipc	s6,0x7
    80002ba8:	4c8b2b03          	lw	s6,1224(s6) # 8000a06c <ticks>

  for(p = proc; p < &proc[NPROC]; p++) {
    80002bac:	00010497          	auipc	s1,0x10
    80002bb0:	b5448493          	addi	s1,s1,-1196 # 80012700 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002bb4:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002bb6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002bb8:	00016917          	auipc	s2,0x16
    80002bbc:	f4890913          	addi	s2,s2,-184 # 80018b00 <tickslock>
    80002bc0:	a099                	j	80002c06 <wakeup+0x8a>
     acquire(&tickslock);
    80002bc2:	00016517          	auipc	a0,0x16
    80002bc6:	f3e50513          	addi	a0,a0,-194 # 80018b00 <tickslock>
    80002bca:	ffffe097          	auipc	ra,0xffffe
    80002bce:	018080e7          	jalr	24(ra) # 80000be2 <acquire>
     xticks = ticks;
    80002bd2:	00007b17          	auipc	s6,0x7
    80002bd6:	49ab2b03          	lw	s6,1178(s6) # 8000a06c <ticks>
     release(&tickslock);
    80002bda:	00016517          	auipc	a0,0x16
    80002bde:	f2650513          	addi	a0,a0,-218 # 80018b00 <tickslock>
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	0b4080e7          	jalr	180(ra) # 80000c96 <release>
    80002bea:	b7c9                	j	80002bac <wakeup+0x30>
        p->state = RUNNABLE;
    80002bec:	0154ac23          	sw	s5,24(s1)
	p->waitstart = xticks;
    80002bf0:	1964a023          	sw	s6,384(s1)
      }
      release(&p->lock);
    80002bf4:	8526                	mv	a0,s1
    80002bf6:	ffffe097          	auipc	ra,0xffffe
    80002bfa:	0a0080e7          	jalr	160(ra) # 80000c96 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002bfe:	19048493          	addi	s1,s1,400
    80002c02:	03248463          	beq	s1,s2,80002c2a <wakeup+0xae>
    if(p != myproc()){
    80002c06:	fffff097          	auipc	ra,0xfffff
    80002c0a:	dce080e7          	jalr	-562(ra) # 800019d4 <myproc>
    80002c0e:	fea488e3          	beq	s1,a0,80002bfe <wakeup+0x82>
      acquire(&p->lock);
    80002c12:	8526                	mv	a0,s1
    80002c14:	ffffe097          	auipc	ra,0xffffe
    80002c18:	fce080e7          	jalr	-50(ra) # 80000be2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002c1c:	4c9c                	lw	a5,24(s1)
    80002c1e:	fd379be3          	bne	a5,s3,80002bf4 <wakeup+0x78>
    80002c22:	709c                	ld	a5,32(s1)
    80002c24:	fd4798e3          	bne	a5,s4,80002bf4 <wakeup+0x78>
    80002c28:	b7d1                	j	80002bec <wakeup+0x70>
    }
  }
}
    80002c2a:	70e2                	ld	ra,56(sp)
    80002c2c:	7442                	ld	s0,48(sp)
    80002c2e:	74a2                	ld	s1,40(sp)
    80002c30:	7902                	ld	s2,32(sp)
    80002c32:	69e2                	ld	s3,24(sp)
    80002c34:	6a42                	ld	s4,16(sp)
    80002c36:	6aa2                	ld	s5,8(sp)
    80002c38:	6b02                	ld	s6,0(sp)
    80002c3a:	6121                	addi	sp,sp,64
    80002c3c:	8082                	ret

0000000080002c3e <reparent>:
{
    80002c3e:	7179                	addi	sp,sp,-48
    80002c40:	f406                	sd	ra,40(sp)
    80002c42:	f022                	sd	s0,32(sp)
    80002c44:	ec26                	sd	s1,24(sp)
    80002c46:	e84a                	sd	s2,16(sp)
    80002c48:	e44e                	sd	s3,8(sp)
    80002c4a:	e052                	sd	s4,0(sp)
    80002c4c:	1800                	addi	s0,sp,48
    80002c4e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002c50:	00010497          	auipc	s1,0x10
    80002c54:	ab048493          	addi	s1,s1,-1360 # 80012700 <proc>
      pp->parent = initproc;
    80002c58:	00007a17          	auipc	s4,0x7
    80002c5c:	408a0a13          	addi	s4,s4,1032 # 8000a060 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002c60:	00016997          	auipc	s3,0x16
    80002c64:	ea098993          	addi	s3,s3,-352 # 80018b00 <tickslock>
    80002c68:	a029                	j	80002c72 <reparent+0x34>
    80002c6a:	19048493          	addi	s1,s1,400
    80002c6e:	01348d63          	beq	s1,s3,80002c88 <reparent+0x4a>
    if(pp->parent == p){
    80002c72:	60bc                	ld	a5,64(s1)
    80002c74:	ff279be3          	bne	a5,s2,80002c6a <reparent+0x2c>
      pp->parent = initproc;
    80002c78:	000a3503          	ld	a0,0(s4)
    80002c7c:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	efe080e7          	jalr	-258(ra) # 80002b7c <wakeup>
    80002c86:	b7d5                	j	80002c6a <reparent+0x2c>
}
    80002c88:	70a2                	ld	ra,40(sp)
    80002c8a:	7402                	ld	s0,32(sp)
    80002c8c:	64e2                	ld	s1,24(sp)
    80002c8e:	6942                	ld	s2,16(sp)
    80002c90:	69a2                	ld	s3,8(sp)
    80002c92:	6a02                	ld	s4,0(sp)
    80002c94:	6145                	addi	sp,sp,48
    80002c96:	8082                	ret

0000000080002c98 <exit>:
{
    80002c98:	7179                	addi	sp,sp,-48
    80002c9a:	f406                	sd	ra,40(sp)
    80002c9c:	f022                	sd	s0,32(sp)
    80002c9e:	ec26                	sd	s1,24(sp)
    80002ca0:	e84a                	sd	s2,16(sp)
    80002ca2:	e44e                	sd	s3,8(sp)
    80002ca4:	e052                	sd	s4,0(sp)
    80002ca6:	1800                	addi	s0,sp,48
    80002ca8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002caa:	fffff097          	auipc	ra,0xfffff
    80002cae:	d2a080e7          	jalr	-726(ra) # 800019d4 <myproc>
    80002cb2:	892a                	mv	s2,a0
  if(p == initproc)
    80002cb4:	00007797          	auipc	a5,0x7
    80002cb8:	3ac7b783          	ld	a5,940(a5) # 8000a060 <initproc>
    80002cbc:	0d850493          	addi	s1,a0,216
    80002cc0:	15850993          	addi	s3,a0,344
    80002cc4:	02a79363          	bne	a5,a0,80002cea <exit+0x52>
    panic("init exiting");
    80002cc8:	00006517          	auipc	a0,0x6
    80002ccc:	59850513          	addi	a0,a0,1432 # 80009260 <digits+0x220>
    80002cd0:	ffffe097          	auipc	ra,0xffffe
    80002cd4:	86c080e7          	jalr	-1940(ra) # 8000053c <panic>
      fileclose(f);
    80002cd8:	00003097          	auipc	ra,0x3
    80002cdc:	cf8080e7          	jalr	-776(ra) # 800059d0 <fileclose>
      p->ofile[fd] = 0;
    80002ce0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002ce4:	04a1                	addi	s1,s1,8
    80002ce6:	01348563          	beq	s1,s3,80002cf0 <exit+0x58>
    if(p->ofile[fd]){
    80002cea:	6088                	ld	a0,0(s1)
    80002cec:	f575                	bnez	a0,80002cd8 <exit+0x40>
    80002cee:	bfdd                	j	80002ce4 <exit+0x4c>
  begin_op();
    80002cf0:	00003097          	auipc	ra,0x3
    80002cf4:	814080e7          	jalr	-2028(ra) # 80005504 <begin_op>
  iput(p->cwd);
    80002cf8:	15893503          	ld	a0,344(s2)
    80002cfc:	00002097          	auipc	ra,0x2
    80002d00:	ff0080e7          	jalr	-16(ra) # 80004cec <iput>
  end_op();
    80002d04:	00003097          	auipc	ra,0x3
    80002d08:	880080e7          	jalr	-1920(ra) # 80005584 <end_op>
  p->cwd = 0;
    80002d0c:	14093c23          	sd	zero,344(s2)
  acquire(&wait_lock);
    80002d10:	0000f497          	auipc	s1,0xf
    80002d14:	5d848493          	addi	s1,s1,1496 # 800122e8 <wait_lock>
    80002d18:	8526                	mv	a0,s1
    80002d1a:	ffffe097          	auipc	ra,0xffffe
    80002d1e:	ec8080e7          	jalr	-312(ra) # 80000be2 <acquire>
  reparent(p);
    80002d22:	854a                	mv	a0,s2
    80002d24:	00000097          	auipc	ra,0x0
    80002d28:	f1a080e7          	jalr	-230(ra) # 80002c3e <reparent>
  wakeup(p->parent);
    80002d2c:	04093503          	ld	a0,64(s2)
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	e4c080e7          	jalr	-436(ra) # 80002b7c <wakeup>
  acquire(&p->lock);
    80002d38:	854a                	mv	a0,s2
    80002d3a:	ffffe097          	auipc	ra,0xffffe
    80002d3e:	ea8080e7          	jalr	-344(ra) # 80000be2 <acquire>
  p->xstate = status;
    80002d42:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    80002d46:	4795                	li	a5,5
    80002d48:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    80002d4c:	8526                	mv	a0,s1
    80002d4e:	ffffe097          	auipc	ra,0xffffe
    80002d52:	f48080e7          	jalr	-184(ra) # 80000c96 <release>
  acquire(&tickslock);
    80002d56:	00016517          	auipc	a0,0x16
    80002d5a:	daa50513          	addi	a0,a0,-598 # 80018b00 <tickslock>
    80002d5e:	ffffe097          	auipc	ra,0xffffe
    80002d62:	e84080e7          	jalr	-380(ra) # 80000be2 <acquire>
  xticks = ticks;
    80002d66:	00007497          	auipc	s1,0x7
    80002d6a:	3064a483          	lw	s1,774(s1) # 8000a06c <ticks>
  release(&tickslock);
    80002d6e:	00016517          	auipc	a0,0x16
    80002d72:	d9250513          	addi	a0,a0,-622 # 80018b00 <tickslock>
    80002d76:	ffffe097          	auipc	ra,0xffffe
    80002d7a:	f20080e7          	jalr	-224(ra) # 80000c96 <release>
  p->endtime = xticks;
    80002d7e:	0004879b          	sext.w	a5,s1
    80002d82:	16f92c23          	sw	a5,376(s2)
  if (p->is_batchproc) {
    80002d86:	03c92703          	lw	a4,60(s2)
    80002d8a:	16070663          	beqz	a4,80002ef6 <exit+0x25e>
     if ((xticks - p->burst_start) > 0) {
    80002d8e:	18492703          	lw	a4,388(s2)
    80002d92:	0c970f63          	beq	a4,s1,80002e70 <exit+0x1d8>
        num_cpubursts++;
    80002d96:	00007617          	auipc	a2,0x7
    80002d9a:	2ae60613          	addi	a2,a2,686 # 8000a044 <num_cpubursts>
    80002d9e:	4214                	lw	a3,0(a2)
    80002da0:	2685                	addiw	a3,a3,1
    80002da2:	c214                	sw	a3,0(a2)
        cpubursts_tot += (xticks - p->burst_start);
    80002da4:	40e4863b          	subw	a2,s1,a4
    80002da8:	0006059b          	sext.w	a1,a2
    80002dac:	00007517          	auipc	a0,0x7
    80002db0:	29450513          	addi	a0,a0,660 # 8000a040 <cpubursts_tot>
    80002db4:	4114                	lw	a3,0(a0)
    80002db6:	9eb1                	addw	a3,a3,a2
    80002db8:	c114                	sw	a3,0(a0)
        if (cpubursts_max < (xticks - p->burst_start)) cpubursts_max = xticks - p->burst_start;
    80002dba:	00007697          	auipc	a3,0x7
    80002dbe:	2826a683          	lw	a3,642(a3) # 8000a03c <cpubursts_max>
    80002dc2:	00b6f663          	bgeu	a3,a1,80002dce <exit+0x136>
    80002dc6:	00007697          	auipc	a3,0x7
    80002dca:	26c6ab23          	sw	a2,630(a3) # 8000a03c <cpubursts_max>
        if (cpubursts_min > (xticks - p->burst_start)) cpubursts_min = xticks - p->burst_start;
    80002dce:	00007697          	auipc	a3,0x7
    80002dd2:	d3a6a683          	lw	a3,-710(a3) # 80009b08 <cpubursts_min>
    80002dd6:	00d5f663          	bgeu	a1,a3,80002de2 <exit+0x14a>
    80002dda:	00007697          	auipc	a3,0x7
    80002dde:	d2c6a723          	sw	a2,-722(a3) # 80009b08 <cpubursts_min>
        if (p->nextburst_estimate > 0) {
    80002de2:	18892683          	lw	a3,392(s2)
    80002de6:	02d05663          	blez	a3,80002e12 <exit+0x17a>
           estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002dea:	0006851b          	sext.w	a0,a3
    80002dee:	12b56063          	bltu	a0,a1,80002f0e <exit+0x276>
    80002df2:	9f29                	addw	a4,a4,a0
    80002df4:	9f05                	subw	a4,a4,s1
    80002df6:	00007517          	auipc	a0,0x7
    80002dfa:	23650513          	addi	a0,a0,566 # 8000a02c <estimation_error>
    80002dfe:	410c                	lw	a1,0(a0)
    80002e00:	9f2d                	addw	a4,a4,a1
    80002e02:	c118                	sw	a4,0(a0)
           estimation_error_instance++;
    80002e04:	00007597          	auipc	a1,0x7
    80002e08:	22458593          	addi	a1,a1,548 # 8000a028 <estimation_error_instance>
    80002e0c:	4198                	lw	a4,0(a1)
    80002e0e:	2705                	addiw	a4,a4,1
    80002e10:	c198                	sw	a4,0(a1)
        p->nextburst_estimate = (xticks - p->burst_start) - ((xticks - p->burst_start)*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM + (p->nextburst_estimate*SCHED_PARAM_SJF_A_NUMER)/SCHED_PARAM_SJF_A_DENOM;
    80002e12:	4709                	li	a4,2
    80002e14:	02e6c73b          	divw	a4,a3,a4
    80002e18:	9f31                	addw	a4,a4,a2
    80002e1a:	0016561b          	srliw	a2,a2,0x1
    80002e1e:	9f11                	subw	a4,a4,a2
    80002e20:	0007069b          	sext.w	a3,a4
    80002e24:	18e92423          	sw	a4,392(s2)
        if (p->nextburst_estimate > 0) {
    80002e28:	04d05463          	blez	a3,80002e70 <exit+0x1d8>
           num_cpubursts_est++;
    80002e2c:	00007597          	auipc	a1,0x7
    80002e30:	20c58593          	addi	a1,a1,524 # 8000a038 <num_cpubursts_est>
    80002e34:	4190                	lw	a2,0(a1)
    80002e36:	2605                	addiw	a2,a2,1
    80002e38:	c190                	sw	a2,0(a1)
           cpubursts_est_tot += p->nextburst_estimate;
    80002e3a:	00007597          	auipc	a1,0x7
    80002e3e:	1fa58593          	addi	a1,a1,506 # 8000a034 <cpubursts_est_tot>
    80002e42:	4190                	lw	a2,0(a1)
    80002e44:	9e39                	addw	a2,a2,a4
    80002e46:	c190                	sw	a2,0(a1)
           if (cpubursts_est_max < p->nextburst_estimate) cpubursts_est_max = p->nextburst_estimate;
    80002e48:	00007617          	auipc	a2,0x7
    80002e4c:	1e862603          	lw	a2,488(a2) # 8000a030 <cpubursts_est_max>
    80002e50:	00d65663          	bge	a2,a3,80002e5c <exit+0x1c4>
    80002e54:	00007617          	auipc	a2,0x7
    80002e58:	1ce62e23          	sw	a4,476(a2) # 8000a030 <cpubursts_est_max>
           if (cpubursts_est_min > p->nextburst_estimate) cpubursts_est_min = p->nextburst_estimate;
    80002e5c:	00007617          	auipc	a2,0x7
    80002e60:	ca862603          	lw	a2,-856(a2) # 80009b04 <cpubursts_est_min>
    80002e64:	00c6d663          	bge	a3,a2,80002e70 <exit+0x1d8>
    80002e68:	00007697          	auipc	a3,0x7
    80002e6c:	c8e6ae23          	sw	a4,-868(a3) # 80009b04 <cpubursts_est_min>
     if (p->stime < batch_start) batch_start = p->stime;
    80002e70:	17492703          	lw	a4,372(s2)
    80002e74:	00007697          	auipc	a3,0x7
    80002e78:	c9c6a683          	lw	a3,-868(a3) # 80009b10 <batch_start>
    80002e7c:	00d75663          	bge	a4,a3,80002e88 <exit+0x1f0>
    80002e80:	00007697          	auipc	a3,0x7
    80002e84:	c8e6a823          	sw	a4,-880(a3) # 80009b10 <batch_start>
     batchsize--;
    80002e88:	00007617          	auipc	a2,0x7
    80002e8c:	1d460613          	addi	a2,a2,468 # 8000a05c <batchsize>
    80002e90:	4214                	lw	a3,0(a2)
    80002e92:	36fd                	addiw	a3,a3,-1
    80002e94:	0006859b          	sext.w	a1,a3
    80002e98:	c214                	sw	a3,0(a2)
     turnaround += (p->endtime - p->stime);
    80002e9a:	00007697          	auipc	a3,0x7
    80002e9e:	1ba68693          	addi	a3,a3,442 # 8000a054 <turnaround>
    80002ea2:	40e7873b          	subw	a4,a5,a4
    80002ea6:	4290                	lw	a2,0(a3)
    80002ea8:	9f31                	addw	a4,a4,a2
    80002eaa:	c298                	sw	a4,0(a3)
     waiting_tot += p->waittime;
    80002eac:	00007697          	auipc	a3,0x7
    80002eb0:	1a068693          	addi	a3,a3,416 # 8000a04c <waiting_tot>
    80002eb4:	17c92703          	lw	a4,380(s2)
    80002eb8:	4290                	lw	a2,0(a3)
    80002eba:	9f31                	addw	a4,a4,a2
    80002ebc:	c298                	sw	a4,0(a3)
     completion_tot += p->endtime;
    80002ebe:	00007697          	auipc	a3,0x7
    80002ec2:	19268693          	addi	a3,a3,402 # 8000a050 <completion_tot>
    80002ec6:	4298                	lw	a4,0(a3)
    80002ec8:	9f3d                	addw	a4,a4,a5
    80002eca:	c298                	sw	a4,0(a3)
     if (p->endtime > completion_max) completion_max = p->endtime;
    80002ecc:	00007717          	auipc	a4,0x7
    80002ed0:	17c72703          	lw	a4,380(a4) # 8000a048 <completion_max>
    80002ed4:	00f75663          	bge	a4,a5,80002ee0 <exit+0x248>
    80002ed8:	00007717          	auipc	a4,0x7
    80002edc:	16f72823          	sw	a5,368(a4) # 8000a048 <completion_max>
     if (p->endtime < completion_min) completion_min = p->endtime;
    80002ee0:	00007717          	auipc	a4,0x7
    80002ee4:	c2c72703          	lw	a4,-980(a4) # 80009b0c <completion_min>
    80002ee8:	00e7d663          	bge	a5,a4,80002ef4 <exit+0x25c>
    80002eec:	00007717          	auipc	a4,0x7
    80002ef0:	c2f72023          	sw	a5,-992(a4) # 80009b0c <completion_min>
     if (batchsize == 0) {
    80002ef4:	c185                	beqz	a1,80002f14 <exit+0x27c>
  sched();
    80002ef6:	fffff097          	auipc	ra,0xfffff
    80002efa:	63e080e7          	jalr	1598(ra) # 80002534 <sched>
  panic("zombie exit");
    80002efe:	00006517          	auipc	a0,0x6
    80002f02:	4aa50513          	addi	a0,a0,1194 # 800093a8 <digits+0x368>
    80002f06:	ffffd097          	auipc	ra,0xffffd
    80002f0a:	636080e7          	jalr	1590(ra) # 8000053c <panic>
           estimation_error += ((p->nextburst_estimate >= (xticks - p->burst_start)) ? (p->nextburst_estimate - (xticks - p->burst_start)) : ((xticks - p->burst_start) - p->nextburst_estimate));
    80002f0e:	40a6073b          	subw	a4,a2,a0
    80002f12:	b5d5                	j	80002df6 <exit+0x15e>
        printf("\nBatch execution time: %d\n", p->endtime - batch_start);
    80002f14:	00007597          	auipc	a1,0x7
    80002f18:	bfc5a583          	lw	a1,-1028(a1) # 80009b10 <batch_start>
    80002f1c:	40b785bb          	subw	a1,a5,a1
    80002f20:	00006517          	auipc	a0,0x6
    80002f24:	35050513          	addi	a0,a0,848 # 80009270 <digits+0x230>
    80002f28:	ffffd097          	auipc	ra,0xffffd
    80002f2c:	65e080e7          	jalr	1630(ra) # 80000586 <printf>
	printf("Average turn-around time: %d\n", turnaround/batchsize2);
    80002f30:	00007497          	auipc	s1,0x7
    80002f34:	12848493          	addi	s1,s1,296 # 8000a058 <batchsize2>
    80002f38:	409c                	lw	a5,0(s1)
    80002f3a:	00007597          	auipc	a1,0x7
    80002f3e:	11a5a583          	lw	a1,282(a1) # 8000a054 <turnaround>
    80002f42:	02f5c5bb          	divw	a1,a1,a5
    80002f46:	00006517          	auipc	a0,0x6
    80002f4a:	34a50513          	addi	a0,a0,842 # 80009290 <digits+0x250>
    80002f4e:	ffffd097          	auipc	ra,0xffffd
    80002f52:	638080e7          	jalr	1592(ra) # 80000586 <printf>
	printf("Average waiting time: %d\n", waiting_tot/batchsize2);
    80002f56:	409c                	lw	a5,0(s1)
    80002f58:	00007597          	auipc	a1,0x7
    80002f5c:	0f45a583          	lw	a1,244(a1) # 8000a04c <waiting_tot>
    80002f60:	02f5c5bb          	divw	a1,a1,a5
    80002f64:	00006517          	auipc	a0,0x6
    80002f68:	34c50513          	addi	a0,a0,844 # 800092b0 <digits+0x270>
    80002f6c:	ffffd097          	auipc	ra,0xffffd
    80002f70:	61a080e7          	jalr	1562(ra) # 80000586 <printf>
	printf("Completion time: avg: %d, max: %d, min: %d\n", completion_tot/batchsize2, completion_max, completion_min);
    80002f74:	409c                	lw	a5,0(s1)
    80002f76:	00007697          	auipc	a3,0x7
    80002f7a:	b966a683          	lw	a3,-1130(a3) # 80009b0c <completion_min>
    80002f7e:	00007617          	auipc	a2,0x7
    80002f82:	0ca62603          	lw	a2,202(a2) # 8000a048 <completion_max>
    80002f86:	00007597          	auipc	a1,0x7
    80002f8a:	0ca5a583          	lw	a1,202(a1) # 8000a050 <completion_tot>
    80002f8e:	02f5c5bb          	divw	a1,a1,a5
    80002f92:	00006517          	auipc	a0,0x6
    80002f96:	33e50513          	addi	a0,a0,830 # 800092d0 <digits+0x290>
    80002f9a:	ffffd097          	auipc	ra,0xffffd
    80002f9e:	5ec080e7          	jalr	1516(ra) # 80000586 <printf>
	if ((sched_policy == SCHED_NPREEMPT_FCFS) || (sched_policy == SCHED_NPREEMPT_SJF)) {
    80002fa2:	00007717          	auipc	a4,0x7
    80002fa6:	0c672703          	lw	a4,198(a4) # 8000a068 <sched_policy>
    80002faa:	4785                	li	a5,1
    80002fac:	08e7fb63          	bgeu	a5,a4,80003042 <exit+0x3aa>
	batchsize2 = 0;
    80002fb0:	00007797          	auipc	a5,0x7
    80002fb4:	0a07a423          	sw	zero,168(a5) # 8000a058 <batchsize2>
	batch_start = 0x7FFFFFFF;
    80002fb8:	800007b7          	lui	a5,0x80000
    80002fbc:	fff7c793          	not	a5,a5
    80002fc0:	00007717          	auipc	a4,0x7
    80002fc4:	b4f72823          	sw	a5,-1200(a4) # 80009b10 <batch_start>
	turnaround = 0;
    80002fc8:	00007717          	auipc	a4,0x7
    80002fcc:	08072623          	sw	zero,140(a4) # 8000a054 <turnaround>
	waiting_tot = 0;
    80002fd0:	00007717          	auipc	a4,0x7
    80002fd4:	06072e23          	sw	zero,124(a4) # 8000a04c <waiting_tot>
	completion_tot = 0;
    80002fd8:	00007717          	auipc	a4,0x7
    80002fdc:	06072c23          	sw	zero,120(a4) # 8000a050 <completion_tot>
	completion_max = 0;
    80002fe0:	00007717          	auipc	a4,0x7
    80002fe4:	06072423          	sw	zero,104(a4) # 8000a048 <completion_max>
	completion_min = 0x7FFFFFFF;
    80002fe8:	00007717          	auipc	a4,0x7
    80002fec:	b2f72223          	sw	a5,-1244(a4) # 80009b0c <completion_min>
	num_cpubursts = 0;
    80002ff0:	00007717          	auipc	a4,0x7
    80002ff4:	04072a23          	sw	zero,84(a4) # 8000a044 <num_cpubursts>
        cpubursts_tot = 0;
    80002ff8:	00007717          	auipc	a4,0x7
    80002ffc:	04072423          	sw	zero,72(a4) # 8000a040 <cpubursts_tot>
        cpubursts_max = 0;
    80003000:	00007717          	auipc	a4,0x7
    80003004:	02072e23          	sw	zero,60(a4) # 8000a03c <cpubursts_max>
        cpubursts_min = 0x7FFFFFFF;
    80003008:	00007717          	auipc	a4,0x7
    8000300c:	b0f72023          	sw	a5,-1280(a4) # 80009b08 <cpubursts_min>
	num_cpubursts_est = 0;
    80003010:	00007717          	auipc	a4,0x7
    80003014:	02072423          	sw	zero,40(a4) # 8000a038 <num_cpubursts_est>
        cpubursts_est_tot = 0;
    80003018:	00007717          	auipc	a4,0x7
    8000301c:	00072e23          	sw	zero,28(a4) # 8000a034 <cpubursts_est_tot>
        cpubursts_est_max = 0;
    80003020:	00007717          	auipc	a4,0x7
    80003024:	00072823          	sw	zero,16(a4) # 8000a030 <cpubursts_est_max>
        cpubursts_est_min = 0x7FFFFFFF;
    80003028:	00007717          	auipc	a4,0x7
    8000302c:	acf72e23          	sw	a5,-1316(a4) # 80009b04 <cpubursts_est_min>
	estimation_error = 0;
    80003030:	00007797          	auipc	a5,0x7
    80003034:	fe07ae23          	sw	zero,-4(a5) # 8000a02c <estimation_error>
        estimation_error_instance = 0;
    80003038:	00007797          	auipc	a5,0x7
    8000303c:	fe07a823          	sw	zero,-16(a5) # 8000a028 <estimation_error_instance>
    80003040:	bd5d                	j	80002ef6 <exit+0x25e>
	   printf("CPU bursts: count: %d, avg: %d, max: %d, min: %d\n", num_cpubursts, cpubursts_tot/num_cpubursts, cpubursts_max, cpubursts_min);
    80003042:	00007597          	auipc	a1,0x7
    80003046:	0025a583          	lw	a1,2(a1) # 8000a044 <num_cpubursts>
    8000304a:	00007717          	auipc	a4,0x7
    8000304e:	abe72703          	lw	a4,-1346(a4) # 80009b08 <cpubursts_min>
    80003052:	00007697          	auipc	a3,0x7
    80003056:	fea6a683          	lw	a3,-22(a3) # 8000a03c <cpubursts_max>
    8000305a:	00007617          	auipc	a2,0x7
    8000305e:	fe662603          	lw	a2,-26(a2) # 8000a040 <cpubursts_tot>
    80003062:	02b6463b          	divw	a2,a2,a1
    80003066:	00006517          	auipc	a0,0x6
    8000306a:	29a50513          	addi	a0,a0,666 # 80009300 <digits+0x2c0>
    8000306e:	ffffd097          	auipc	ra,0xffffd
    80003072:	518080e7          	jalr	1304(ra) # 80000586 <printf>
	   printf("CPU burst estimates: count: %d, avg: %d, max: %d, min: %d\n", num_cpubursts_est, cpubursts_est_tot/num_cpubursts_est, cpubursts_est_max, cpubursts_est_min);
    80003076:	00007597          	auipc	a1,0x7
    8000307a:	fc25a583          	lw	a1,-62(a1) # 8000a038 <num_cpubursts_est>
    8000307e:	00007717          	auipc	a4,0x7
    80003082:	a8672703          	lw	a4,-1402(a4) # 80009b04 <cpubursts_est_min>
    80003086:	00007697          	auipc	a3,0x7
    8000308a:	faa6a683          	lw	a3,-86(a3) # 8000a030 <cpubursts_est_max>
    8000308e:	00007617          	auipc	a2,0x7
    80003092:	fa662603          	lw	a2,-90(a2) # 8000a034 <cpubursts_est_tot>
    80003096:	02b6463b          	divw	a2,a2,a1
    8000309a:	00006517          	auipc	a0,0x6
    8000309e:	29e50513          	addi	a0,a0,670 # 80009338 <digits+0x2f8>
    800030a2:	ffffd097          	auipc	ra,0xffffd
    800030a6:	4e4080e7          	jalr	1252(ra) # 80000586 <printf>
	   printf("CPU burst estimation error: count: %d, avg: %d\n", estimation_error_instance, estimation_error/estimation_error_instance);
    800030aa:	00007597          	auipc	a1,0x7
    800030ae:	f7e5a583          	lw	a1,-130(a1) # 8000a028 <estimation_error_instance>
    800030b2:	00007617          	auipc	a2,0x7
    800030b6:	f7a62603          	lw	a2,-134(a2) # 8000a02c <estimation_error>
    800030ba:	02b6463b          	divw	a2,a2,a1
    800030be:	00006517          	auipc	a0,0x6
    800030c2:	2ba50513          	addi	a0,a0,698 # 80009378 <digits+0x338>
    800030c6:	ffffd097          	auipc	ra,0xffffd
    800030ca:	4c0080e7          	jalr	1216(ra) # 80000586 <printf>
    800030ce:	b5cd                	j	80002fb0 <exit+0x318>

00000000800030d0 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800030d0:	7179                	addi	sp,sp,-48
    800030d2:	f406                	sd	ra,40(sp)
    800030d4:	f022                	sd	s0,32(sp)
    800030d6:	ec26                	sd	s1,24(sp)
    800030d8:	e84a                	sd	s2,16(sp)
    800030da:	e44e                	sd	s3,8(sp)
    800030dc:	e052                	sd	s4,0(sp)
    800030de:	1800                	addi	s0,sp,48
    800030e0:	892a                	mv	s2,a0
  struct proc *p;
  uint xticks;

  acquire(&tickslock);
    800030e2:	00016517          	auipc	a0,0x16
    800030e6:	a1e50513          	addi	a0,a0,-1506 # 80018b00 <tickslock>
    800030ea:	ffffe097          	auipc	ra,0xffffe
    800030ee:	af8080e7          	jalr	-1288(ra) # 80000be2 <acquire>
  xticks = ticks;
    800030f2:	00007a17          	auipc	s4,0x7
    800030f6:	f7aa2a03          	lw	s4,-134(s4) # 8000a06c <ticks>
  release(&tickslock);
    800030fa:	00016517          	auipc	a0,0x16
    800030fe:	a0650513          	addi	a0,a0,-1530 # 80018b00 <tickslock>
    80003102:	ffffe097          	auipc	ra,0xffffe
    80003106:	b94080e7          	jalr	-1132(ra) # 80000c96 <release>

  for(p = proc; p < &proc[NPROC]; p++){
    8000310a:	0000f497          	auipc	s1,0xf
    8000310e:	5f648493          	addi	s1,s1,1526 # 80012700 <proc>
    80003112:	00016997          	auipc	s3,0x16
    80003116:	9ee98993          	addi	s3,s3,-1554 # 80018b00 <tickslock>
    acquire(&p->lock);
    8000311a:	8526                	mv	a0,s1
    8000311c:	ffffe097          	auipc	ra,0xffffe
    80003120:	ac6080e7          	jalr	-1338(ra) # 80000be2 <acquire>
    if(p->pid == pid){
    80003124:	589c                	lw	a5,48(s1)
    80003126:	01278d63          	beq	a5,s2,80003140 <kill+0x70>
	p->waitstart = xticks;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000312a:	8526                	mv	a0,s1
    8000312c:	ffffe097          	auipc	ra,0xffffe
    80003130:	b6a080e7          	jalr	-1174(ra) # 80000c96 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80003134:	19048493          	addi	s1,s1,400
    80003138:	ff3491e3          	bne	s1,s3,8000311a <kill+0x4a>
  }
  return -1;
    8000313c:	557d                	li	a0,-1
    8000313e:	a829                	j	80003158 <kill+0x88>
      p->killed = 1;
    80003140:	4785                	li	a5,1
    80003142:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80003144:	4c98                	lw	a4,24(s1)
    80003146:	4789                	li	a5,2
    80003148:	02f70063          	beq	a4,a5,80003168 <kill+0x98>
      release(&p->lock);
    8000314c:	8526                	mv	a0,s1
    8000314e:	ffffe097          	auipc	ra,0xffffe
    80003152:	b48080e7          	jalr	-1208(ra) # 80000c96 <release>
      return 0;
    80003156:	4501                	li	a0,0
}
    80003158:	70a2                	ld	ra,40(sp)
    8000315a:	7402                	ld	s0,32(sp)
    8000315c:	64e2                	ld	s1,24(sp)
    8000315e:	6942                	ld	s2,16(sp)
    80003160:	69a2                	ld	s3,8(sp)
    80003162:	6a02                	ld	s4,0(sp)
    80003164:	6145                	addi	sp,sp,48
    80003166:	8082                	ret
        p->state = RUNNABLE;
    80003168:	478d                	li	a5,3
    8000316a:	cc9c                	sw	a5,24(s1)
	p->waitstart = xticks;
    8000316c:	1944a023          	sw	s4,384(s1)
    80003170:	bff1                	j	8000314c <kill+0x7c>

0000000080003172 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80003172:	7179                	addi	sp,sp,-48
    80003174:	f406                	sd	ra,40(sp)
    80003176:	f022                	sd	s0,32(sp)
    80003178:	ec26                	sd	s1,24(sp)
    8000317a:	e84a                	sd	s2,16(sp)
    8000317c:	e44e                	sd	s3,8(sp)
    8000317e:	e052                	sd	s4,0(sp)
    80003180:	1800                	addi	s0,sp,48
    80003182:	84aa                	mv	s1,a0
    80003184:	892e                	mv	s2,a1
    80003186:	89b2                	mv	s3,a2
    80003188:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000318a:	fffff097          	auipc	ra,0xfffff
    8000318e:	84a080e7          	jalr	-1974(ra) # 800019d4 <myproc>
  if(user_dst){
    80003192:	c08d                	beqz	s1,800031b4 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80003194:	86d2                	mv	a3,s4
    80003196:	864e                	mv	a2,s3
    80003198:	85ca                	mv	a1,s2
    8000319a:	6d28                	ld	a0,88(a0)
    8000319c:	ffffe097          	auipc	ra,0xffffe
    800031a0:	4fa080e7          	jalr	1274(ra) # 80001696 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800031a4:	70a2                	ld	ra,40(sp)
    800031a6:	7402                	ld	s0,32(sp)
    800031a8:	64e2                	ld	s1,24(sp)
    800031aa:	6942                	ld	s2,16(sp)
    800031ac:	69a2                	ld	s3,8(sp)
    800031ae:	6a02                	ld	s4,0(sp)
    800031b0:	6145                	addi	sp,sp,48
    800031b2:	8082                	ret
    memmove((char *)dst, src, len);
    800031b4:	000a061b          	sext.w	a2,s4
    800031b8:	85ce                	mv	a1,s3
    800031ba:	854a                	mv	a0,s2
    800031bc:	ffffe097          	auipc	ra,0xffffe
    800031c0:	b82080e7          	jalr	-1150(ra) # 80000d3e <memmove>
    return 0;
    800031c4:	8526                	mv	a0,s1
    800031c6:	bff9                	j	800031a4 <either_copyout+0x32>

00000000800031c8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800031c8:	7179                	addi	sp,sp,-48
    800031ca:	f406                	sd	ra,40(sp)
    800031cc:	f022                	sd	s0,32(sp)
    800031ce:	ec26                	sd	s1,24(sp)
    800031d0:	e84a                	sd	s2,16(sp)
    800031d2:	e44e                	sd	s3,8(sp)
    800031d4:	e052                	sd	s4,0(sp)
    800031d6:	1800                	addi	s0,sp,48
    800031d8:	892a                	mv	s2,a0
    800031da:	84ae                	mv	s1,a1
    800031dc:	89b2                	mv	s3,a2
    800031de:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800031e0:	ffffe097          	auipc	ra,0xffffe
    800031e4:	7f4080e7          	jalr	2036(ra) # 800019d4 <myproc>
  if(user_src){
    800031e8:	c08d                	beqz	s1,8000320a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800031ea:	86d2                	mv	a3,s4
    800031ec:	864e                	mv	a2,s3
    800031ee:	85ca                	mv	a1,s2
    800031f0:	6d28                	ld	a0,88(a0)
    800031f2:	ffffe097          	auipc	ra,0xffffe
    800031f6:	530080e7          	jalr	1328(ra) # 80001722 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800031fa:	70a2                	ld	ra,40(sp)
    800031fc:	7402                	ld	s0,32(sp)
    800031fe:	64e2                	ld	s1,24(sp)
    80003200:	6942                	ld	s2,16(sp)
    80003202:	69a2                	ld	s3,8(sp)
    80003204:	6a02                	ld	s4,0(sp)
    80003206:	6145                	addi	sp,sp,48
    80003208:	8082                	ret
    memmove(dst, (char*)src, len);
    8000320a:	000a061b          	sext.w	a2,s4
    8000320e:	85ce                	mv	a1,s3
    80003210:	854a                	mv	a0,s2
    80003212:	ffffe097          	auipc	ra,0xffffe
    80003216:	b2c080e7          	jalr	-1236(ra) # 80000d3e <memmove>
    return 0;
    8000321a:	8526                	mv	a0,s1
    8000321c:	bff9                	j	800031fa <either_copyin+0x32>

000000008000321e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000321e:	715d                	addi	sp,sp,-80
    80003220:	e486                	sd	ra,72(sp)
    80003222:	e0a2                	sd	s0,64(sp)
    80003224:	fc26                	sd	s1,56(sp)
    80003226:	f84a                	sd	s2,48(sp)
    80003228:	f44e                	sd	s3,40(sp)
    8000322a:	f052                	sd	s4,32(sp)
    8000322c:	ec56                	sd	s5,24(sp)
    8000322e:	e85a                	sd	s6,16(sp)
    80003230:	e45e                	sd	s7,8(sp)
    80003232:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80003234:	00006517          	auipc	a0,0x6
    80003238:	52c50513          	addi	a0,a0,1324 # 80009760 <syscalls+0x120>
    8000323c:	ffffd097          	auipc	ra,0xffffd
    80003240:	34a080e7          	jalr	842(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80003244:	0000f497          	auipc	s1,0xf
    80003248:	61c48493          	addi	s1,s1,1564 # 80012860 <proc+0x160>
    8000324c:	00016917          	auipc	s2,0x16
    80003250:	a1490913          	addi	s2,s2,-1516 # 80018c60 <barrier_arr+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003254:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80003256:	00006997          	auipc	s3,0x6
    8000325a:	16298993          	addi	s3,s3,354 # 800093b8 <digits+0x378>
    printf("%d %s %s", p->pid, state, p->name);
    8000325e:	00006a97          	auipc	s5,0x6
    80003262:	162a8a93          	addi	s5,s5,354 # 800093c0 <digits+0x380>
    printf("\n");
    80003266:	00006a17          	auipc	s4,0x6
    8000326a:	4faa0a13          	addi	s4,s4,1274 # 80009760 <syscalls+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000326e:	00006b97          	auipc	s7,0x6
    80003272:	1eab8b93          	addi	s7,s7,490 # 80009458 <states.1832>
    80003276:	a00d                	j	80003298 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80003278:	ed06a583          	lw	a1,-304(a3)
    8000327c:	8556                	mv	a0,s5
    8000327e:	ffffd097          	auipc	ra,0xffffd
    80003282:	308080e7          	jalr	776(ra) # 80000586 <printf>
    printf("\n");
    80003286:	8552                	mv	a0,s4
    80003288:	ffffd097          	auipc	ra,0xffffd
    8000328c:	2fe080e7          	jalr	766(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80003290:	19048493          	addi	s1,s1,400
    80003294:	03248163          	beq	s1,s2,800032b6 <procdump+0x98>
    if(p->state == UNUSED)
    80003298:	86a6                	mv	a3,s1
    8000329a:	eb84a783          	lw	a5,-328(s1)
    8000329e:	dbed                	beqz	a5,80003290 <procdump+0x72>
      state = "???";
    800032a0:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800032a2:	fcfb6be3          	bltu	s6,a5,80003278 <procdump+0x5a>
    800032a6:	1782                	slli	a5,a5,0x20
    800032a8:	9381                	srli	a5,a5,0x20
    800032aa:	078e                	slli	a5,a5,0x3
    800032ac:	97de                	add	a5,a5,s7
    800032ae:	6390                	ld	a2,0(a5)
    800032b0:	f661                	bnez	a2,80003278 <procdump+0x5a>
      state = "???";
    800032b2:	864e                	mv	a2,s3
    800032b4:	b7d1                	j	80003278 <procdump+0x5a>
  }
}
    800032b6:	60a6                	ld	ra,72(sp)
    800032b8:	6406                	ld	s0,64(sp)
    800032ba:	74e2                	ld	s1,56(sp)
    800032bc:	7942                	ld	s2,48(sp)
    800032be:	79a2                	ld	s3,40(sp)
    800032c0:	7a02                	ld	s4,32(sp)
    800032c2:	6ae2                	ld	s5,24(sp)
    800032c4:	6b42                	ld	s6,16(sp)
    800032c6:	6ba2                	ld	s7,8(sp)
    800032c8:	6161                	addi	sp,sp,80
    800032ca:	8082                	ret

00000000800032cc <ps>:

// Print a process listing to console with proper locks held.
// Caution: don't invoke too often; can slow down the machine.
int
ps(void)
{
    800032cc:	7119                	addi	sp,sp,-128
    800032ce:	fc86                	sd	ra,120(sp)
    800032d0:	f8a2                	sd	s0,112(sp)
    800032d2:	f4a6                	sd	s1,104(sp)
    800032d4:	f0ca                	sd	s2,96(sp)
    800032d6:	ecce                	sd	s3,88(sp)
    800032d8:	e8d2                	sd	s4,80(sp)
    800032da:	e4d6                	sd	s5,72(sp)
    800032dc:	e0da                	sd	s6,64(sp)
    800032de:	fc5e                	sd	s7,56(sp)
    800032e0:	f862                	sd	s8,48(sp)
    800032e2:	f466                	sd	s9,40(sp)
    800032e4:	f06a                	sd	s10,32(sp)
    800032e6:	ec6e                	sd	s11,24(sp)
    800032e8:	0100                	addi	s0,sp,128
  struct proc *p;
  char *state;
  int ppid, pid;
  uint xticks;

  printf("\n");
    800032ea:	00006517          	auipc	a0,0x6
    800032ee:	47650513          	addi	a0,a0,1142 # 80009760 <syscalls+0x120>
    800032f2:	ffffd097          	auipc	ra,0xffffd
    800032f6:	294080e7          	jalr	660(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800032fa:	0000f497          	auipc	s1,0xf
    800032fe:	40648493          	addi	s1,s1,1030 # 80012700 <proc>
    acquire(&p->lock);
    if(p->state == UNUSED) {
      release(&p->lock);
      continue;
    }
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003302:	4d95                	li	s11,5
    else
      state = "???";

    pid = p->pid;
    release(&p->lock);
    acquire(&wait_lock);
    80003304:	0000fb97          	auipc	s7,0xf
    80003308:	fe4b8b93          	addi	s7,s7,-28 # 800122e8 <wait_lock>
    if (p->parent) {
       acquire(&p->parent->lock);
       ppid = p->parent->pid;
       release(&p->parent->lock);
    }
    else ppid = -1;
    8000330c:	5b7d                	li	s6,-1
    release(&wait_lock);

    acquire(&tickslock);
    8000330e:	00015a97          	auipc	s5,0x15
    80003312:	7f2a8a93          	addi	s5,s5,2034 # 80018b00 <tickslock>
  for(p = proc; p < &proc[NPROC]; p++){
    80003316:	00015d17          	auipc	s10,0x15
    8000331a:	7ead0d13          	addi	s10,s10,2026 # 80018b00 <tickslock>
    8000331e:	a85d                	j	800033d4 <ps+0x108>
      release(&p->lock);
    80003320:	8526                	mv	a0,s1
    80003322:	ffffe097          	auipc	ra,0xffffe
    80003326:	974080e7          	jalr	-1676(ra) # 80000c96 <release>
      continue;
    8000332a:	a04d                	j	800033cc <ps+0x100>
    pid = p->pid;
    8000332c:	0304ac03          	lw	s8,48(s1)
    release(&p->lock);
    80003330:	8526                	mv	a0,s1
    80003332:	ffffe097          	auipc	ra,0xffffe
    80003336:	964080e7          	jalr	-1692(ra) # 80000c96 <release>
    acquire(&wait_lock);
    8000333a:	855e                	mv	a0,s7
    8000333c:	ffffe097          	auipc	ra,0xffffe
    80003340:	8a6080e7          	jalr	-1882(ra) # 80000be2 <acquire>
    if (p->parent) {
    80003344:	60a8                	ld	a0,64(s1)
    else ppid = -1;
    80003346:	8a5a                	mv	s4,s6
    if (p->parent) {
    80003348:	cd01                	beqz	a0,80003360 <ps+0x94>
       acquire(&p->parent->lock);
    8000334a:	ffffe097          	auipc	ra,0xffffe
    8000334e:	898080e7          	jalr	-1896(ra) # 80000be2 <acquire>
       ppid = p->parent->pid;
    80003352:	60a8                	ld	a0,64(s1)
    80003354:	03052a03          	lw	s4,48(a0)
       release(&p->parent->lock);
    80003358:	ffffe097          	auipc	ra,0xffffe
    8000335c:	93e080e7          	jalr	-1730(ra) # 80000c96 <release>
    release(&wait_lock);
    80003360:	855e                	mv	a0,s7
    80003362:	ffffe097          	auipc	ra,0xffffe
    80003366:	934080e7          	jalr	-1740(ra) # 80000c96 <release>
    acquire(&tickslock);
    8000336a:	8556                	mv	a0,s5
    8000336c:	ffffe097          	auipc	ra,0xffffe
    80003370:	876080e7          	jalr	-1930(ra) # 80000be2 <acquire>
    xticks = ticks;
    80003374:	00007797          	auipc	a5,0x7
    80003378:	cf878793          	addi	a5,a5,-776 # 8000a06c <ticks>
    8000337c:	0007ac83          	lw	s9,0(a5)
    release(&tickslock);
    80003380:	8556                	mv	a0,s5
    80003382:	ffffe097          	auipc	ra,0xffffe
    80003386:	914080e7          	jalr	-1772(ra) # 80000c96 <release>

    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    8000338a:	16090713          	addi	a4,s2,352
    8000338e:	1704a783          	lw	a5,368(s1)
    80003392:	1744a803          	lw	a6,372(s1)
    80003396:	1784a683          	lw	a3,376(s1)
    8000339a:	410688bb          	subw	a7,a3,a6
    8000339e:	07668a63          	beq	a3,s6,80003412 <ps+0x146>
    800033a2:	68b4                	ld	a3,80(s1)
    800033a4:	e036                	sd	a3,0(sp)
    800033a6:	86ce                	mv	a3,s3
    800033a8:	8652                	mv	a2,s4
    800033aa:	85e2                	mv	a1,s8
    800033ac:	00006517          	auipc	a0,0x6
    800033b0:	02450513          	addi	a0,a0,36 # 800093d0 <digits+0x390>
    800033b4:	ffffd097          	auipc	ra,0xffffd
    800033b8:	1d2080e7          	jalr	466(ra) # 80000586 <printf>
    printf("\n");
    800033bc:	00006517          	auipc	a0,0x6
    800033c0:	3a450513          	addi	a0,a0,932 # 80009760 <syscalls+0x120>
    800033c4:	ffffd097          	auipc	ra,0xffffd
    800033c8:	1c2080e7          	jalr	450(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800033cc:	19048493          	addi	s1,s1,400
    800033d0:	05a48463          	beq	s1,s10,80003418 <ps+0x14c>
    acquire(&p->lock);
    800033d4:	8926                	mv	s2,s1
    800033d6:	8526                	mv	a0,s1
    800033d8:	ffffe097          	auipc	ra,0xffffe
    800033dc:	80a080e7          	jalr	-2038(ra) # 80000be2 <acquire>
    if(p->state == UNUSED) {
    800033e0:	4c9c                	lw	a5,24(s1)
    800033e2:	df9d                	beqz	a5,80003320 <ps+0x54>
      state = "???";
    800033e4:	00006997          	auipc	s3,0x6
    800033e8:	fd498993          	addi	s3,s3,-44 # 800093b8 <digits+0x378>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800033ec:	f4fde0e3          	bltu	s11,a5,8000332c <ps+0x60>
    800033f0:	1782                	slli	a5,a5,0x20
    800033f2:	9381                	srli	a5,a5,0x20
    800033f4:	078e                	slli	a5,a5,0x3
    800033f6:	00006717          	auipc	a4,0x6
    800033fa:	06270713          	addi	a4,a4,98 # 80009458 <states.1832>
    800033fe:	97ba                	add	a5,a5,a4
    80003400:	0307b983          	ld	s3,48(a5)
    80003404:	f20994e3          	bnez	s3,8000332c <ps+0x60>
      state = "???";
    80003408:	00006997          	auipc	s3,0x6
    8000340c:	fb098993          	addi	s3,s3,-80 # 800093b8 <digits+0x378>
    80003410:	bf31                	j	8000332c <ps+0x60>
    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p", pid, ppid, state, p->name, p->ctime, p->stime, (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime, p->sz);
    80003412:	410c88bb          	subw	a7,s9,a6
    80003416:	b771                	j	800033a2 <ps+0xd6>
  }
  return 0;
}
    80003418:	4501                	li	a0,0
    8000341a:	70e6                	ld	ra,120(sp)
    8000341c:	7446                	ld	s0,112(sp)
    8000341e:	74a6                	ld	s1,104(sp)
    80003420:	7906                	ld	s2,96(sp)
    80003422:	69e6                	ld	s3,88(sp)
    80003424:	6a46                	ld	s4,80(sp)
    80003426:	6aa6                	ld	s5,72(sp)
    80003428:	6b06                	ld	s6,64(sp)
    8000342a:	7be2                	ld	s7,56(sp)
    8000342c:	7c42                	ld	s8,48(sp)
    8000342e:	7ca2                	ld	s9,40(sp)
    80003430:	7d02                	ld	s10,32(sp)
    80003432:	6de2                	ld	s11,24(sp)
    80003434:	6109                	addi	sp,sp,128
    80003436:	8082                	ret

0000000080003438 <pinfo>:

int
pinfo(int pid, uint64 addr)
{
    80003438:	7159                	addi	sp,sp,-112
    8000343a:	f486                	sd	ra,104(sp)
    8000343c:	f0a2                	sd	s0,96(sp)
    8000343e:	eca6                	sd	s1,88(sp)
    80003440:	e8ca                	sd	s2,80(sp)
    80003442:	e4ce                	sd	s3,72(sp)
    80003444:	e0d2                	sd	s4,64(sp)
    80003446:	1880                	addi	s0,sp,112
    80003448:	892a                	mv	s2,a0
    8000344a:	89ae                	mv	s3,a1
  struct proc *p;
  char *state;
  uint xticks;
  int found=0;

  if (pid == -1) {
    8000344c:	57fd                	li	a5,-1
     p = myproc();
     acquire(&p->lock);
     found=1;
  }
  else {
     for(p = proc; p < &proc[NPROC]; p++){
    8000344e:	0000f497          	auipc	s1,0xf
    80003452:	2b248493          	addi	s1,s1,690 # 80012700 <proc>
    80003456:	00015a17          	auipc	s4,0x15
    8000345a:	6aaa0a13          	addi	s4,s4,1706 # 80018b00 <tickslock>
  if (pid == -1) {
    8000345e:	02f51563          	bne	a0,a5,80003488 <pinfo+0x50>
     p = myproc();
    80003462:	ffffe097          	auipc	ra,0xffffe
    80003466:	572080e7          	jalr	1394(ra) # 800019d4 <myproc>
    8000346a:	84aa                	mv	s1,a0
     acquire(&p->lock);
    8000346c:	ffffd097          	auipc	ra,0xffffd
    80003470:	776080e7          	jalr	1910(ra) # 80000be2 <acquire>
         found=1;
         break;
       }
     }
  }
  if (found) {
    80003474:	a025                	j	8000349c <pinfo+0x64>
         release(&p->lock);
    80003476:	8526                	mv	a0,s1
    80003478:	ffffe097          	auipc	ra,0xffffe
    8000347c:	81e080e7          	jalr	-2018(ra) # 80000c96 <release>
     for(p = proc; p < &proc[NPROC]; p++){
    80003480:	19048493          	addi	s1,s1,400
    80003484:	13448d63          	beq	s1,s4,800035be <pinfo+0x186>
       acquire(&p->lock);
    80003488:	8526                	mv	a0,s1
    8000348a:	ffffd097          	auipc	ra,0xffffd
    8000348e:	758080e7          	jalr	1880(ra) # 80000be2 <acquire>
       if((p->state == UNUSED) || (p->pid != pid)) {
    80003492:	4c9c                	lw	a5,24(s1)
    80003494:	d3ed                	beqz	a5,80003476 <pinfo+0x3e>
    80003496:	589c                	lw	a5,48(s1)
    80003498:	fd279fe3          	bne	a5,s2,80003476 <pinfo+0x3e>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000349c:	4c9c                	lw	a5,24(s1)
    8000349e:	4715                	li	a4,5
         state = states[p->state];
     else
         state = "???";
    800034a0:	00006917          	auipc	s2,0x6
    800034a4:	f1890913          	addi	s2,s2,-232 # 800093b8 <digits+0x378>
     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800034a8:	00f76e63          	bltu	a4,a5,800034c4 <pinfo+0x8c>
    800034ac:	1782                	slli	a5,a5,0x20
    800034ae:	9381                	srli	a5,a5,0x20
    800034b0:	078e                	slli	a5,a5,0x3
    800034b2:	00006717          	auipc	a4,0x6
    800034b6:	fa670713          	addi	a4,a4,-90 # 80009458 <states.1832>
    800034ba:	97ba                	add	a5,a5,a4
    800034bc:	0607b903          	ld	s2,96(a5)
    800034c0:	10090163          	beqz	s2,800035c2 <pinfo+0x18a>

     pstat.pid = p->pid;
    800034c4:	589c                	lw	a5,48(s1)
    800034c6:	f8f42c23          	sw	a5,-104(s0)
     release(&p->lock);
    800034ca:	8526                	mv	a0,s1
    800034cc:	ffffd097          	auipc	ra,0xffffd
    800034d0:	7ca080e7          	jalr	1994(ra) # 80000c96 <release>
     acquire(&wait_lock);
    800034d4:	0000f517          	auipc	a0,0xf
    800034d8:	e1450513          	addi	a0,a0,-492 # 800122e8 <wait_lock>
    800034dc:	ffffd097          	auipc	ra,0xffffd
    800034e0:	706080e7          	jalr	1798(ra) # 80000be2 <acquire>
     if (p->parent) {
    800034e4:	60a8                	ld	a0,64(s1)
    800034e6:	c17d                	beqz	a0,800035cc <pinfo+0x194>
        acquire(&p->parent->lock);
    800034e8:	ffffd097          	auipc	ra,0xffffd
    800034ec:	6fa080e7          	jalr	1786(ra) # 80000be2 <acquire>
        pstat.ppid = p->parent->pid;
    800034f0:	60a8                	ld	a0,64(s1)
    800034f2:	591c                	lw	a5,48(a0)
    800034f4:	f8f42e23          	sw	a5,-100(s0)
        release(&p->parent->lock);
    800034f8:	ffffd097          	auipc	ra,0xffffd
    800034fc:	79e080e7          	jalr	1950(ra) # 80000c96 <release>
     }
     else pstat.ppid = -1;
     release(&wait_lock);
    80003500:	0000f517          	auipc	a0,0xf
    80003504:	de850513          	addi	a0,a0,-536 # 800122e8 <wait_lock>
    80003508:	ffffd097          	auipc	ra,0xffffd
    8000350c:	78e080e7          	jalr	1934(ra) # 80000c96 <release>

     acquire(&tickslock);
    80003510:	00015517          	auipc	a0,0x15
    80003514:	5f050513          	addi	a0,a0,1520 # 80018b00 <tickslock>
    80003518:	ffffd097          	auipc	ra,0xffffd
    8000351c:	6ca080e7          	jalr	1738(ra) # 80000be2 <acquire>
     xticks = ticks;
    80003520:	00007a17          	auipc	s4,0x7
    80003524:	b4ca2a03          	lw	s4,-1204(s4) # 8000a06c <ticks>
     release(&tickslock);
    80003528:	00015517          	auipc	a0,0x15
    8000352c:	5d850513          	addi	a0,a0,1496 # 80018b00 <tickslock>
    80003530:	ffffd097          	auipc	ra,0xffffd
    80003534:	766080e7          	jalr	1894(ra) # 80000c96 <release>

     safestrcpy(&pstat.state[0], state, strlen(state)+1);
    80003538:	854a                	mv	a0,s2
    8000353a:	ffffe097          	auipc	ra,0xffffe
    8000353e:	928080e7          	jalr	-1752(ra) # 80000e62 <strlen>
    80003542:	0015061b          	addiw	a2,a0,1
    80003546:	85ca                	mv	a1,s2
    80003548:	fa040513          	addi	a0,s0,-96
    8000354c:	ffffe097          	auipc	ra,0xffffe
    80003550:	8e4080e7          	jalr	-1820(ra) # 80000e30 <safestrcpy>
     safestrcpy(&pstat.command[0], &p->name[0], sizeof(p->name));
    80003554:	4641                	li	a2,16
    80003556:	16048593          	addi	a1,s1,352
    8000355a:	fa840513          	addi	a0,s0,-88
    8000355e:	ffffe097          	auipc	ra,0xffffe
    80003562:	8d2080e7          	jalr	-1838(ra) # 80000e30 <safestrcpy>
     pstat.ctime = p->ctime;
    80003566:	1704a783          	lw	a5,368(s1)
    8000356a:	faf42c23          	sw	a5,-72(s0)
     pstat.stime = p->stime;
    8000356e:	1744a783          	lw	a5,372(s1)
    80003572:	faf42e23          	sw	a5,-68(s0)
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    80003576:	1784a703          	lw	a4,376(s1)
    8000357a:	567d                	li	a2,-1
    8000357c:	40f706bb          	subw	a3,a4,a5
    80003580:	04c70a63          	beq	a4,a2,800035d4 <pinfo+0x19c>
    80003584:	fcd42023          	sw	a3,-64(s0)
     pstat.size = p->sz;
    80003588:	68bc                	ld	a5,80(s1)
    8000358a:	fcf43423          	sd	a5,-56(s0)
     if(copyout(myproc()->pagetable, addr, (char *)&pstat, sizeof(pstat)) < 0) return -1;
    8000358e:	ffffe097          	auipc	ra,0xffffe
    80003592:	446080e7          	jalr	1094(ra) # 800019d4 <myproc>
    80003596:	03800693          	li	a3,56
    8000359a:	f9840613          	addi	a2,s0,-104
    8000359e:	85ce                	mv	a1,s3
    800035a0:	6d28                	ld	a0,88(a0)
    800035a2:	ffffe097          	auipc	ra,0xffffe
    800035a6:	0f4080e7          	jalr	244(ra) # 80001696 <copyout>
    800035aa:	41f5551b          	sraiw	a0,a0,0x1f
     return 0;
  }
  else return -1;
}
    800035ae:	70a6                	ld	ra,104(sp)
    800035b0:	7406                	ld	s0,96(sp)
    800035b2:	64e6                	ld	s1,88(sp)
    800035b4:	6946                	ld	s2,80(sp)
    800035b6:	69a6                	ld	s3,72(sp)
    800035b8:	6a06                	ld	s4,64(sp)
    800035ba:	6165                	addi	sp,sp,112
    800035bc:	8082                	ret
  else return -1;
    800035be:	557d                	li	a0,-1
    800035c0:	b7fd                	j	800035ae <pinfo+0x176>
         state = "???";
    800035c2:	00006917          	auipc	s2,0x6
    800035c6:	df690913          	addi	s2,s2,-522 # 800093b8 <digits+0x378>
    800035ca:	bded                	j	800034c4 <pinfo+0x8c>
     else pstat.ppid = -1;
    800035cc:	57fd                	li	a5,-1
    800035ce:	f8f42e23          	sw	a5,-100(s0)
    800035d2:	b73d                	j	80003500 <pinfo+0xc8>
     pstat.etime = (p->endtime == -1) ? xticks-p->stime : p->endtime-p->stime;
    800035d4:	40fa06bb          	subw	a3,s4,a5
    800035d8:	b775                	j	80003584 <pinfo+0x14c>

00000000800035da <schedpolicy>:

int
schedpolicy(int x)
{
    800035da:	1141                	addi	sp,sp,-16
    800035dc:	e422                	sd	s0,8(sp)
    800035de:	0800                	addi	s0,sp,16
   int y = sched_policy;
    800035e0:	00007797          	auipc	a5,0x7
    800035e4:	a8878793          	addi	a5,a5,-1400 # 8000a068 <sched_policy>
    800035e8:	4398                	lw	a4,0(a5)
   sched_policy = x;
    800035ea:	c388                	sw	a0,0(a5)
   return y;
}
    800035ec:	853a                	mv	a0,a4
    800035ee:	6422                	ld	s0,8(sp)
    800035f0:	0141                	addi	sp,sp,16
    800035f2:	8082                	ret

00000000800035f4 <condsleep>:

void
condsleep(struct cond_t *chan, struct sleeplock *lk)
{
    800035f4:	7179                	addi	sp,sp,-48
    800035f6:	f406                	sd	ra,40(sp)
    800035f8:	f022                	sd	s0,32(sp)
    800035fa:	ec26                	sd	s1,24(sp)
    800035fc:	e84a                	sd	s2,16(sp)
    800035fe:	e44e                	sd	s3,8(sp)
    80003600:	1800                	addi	s0,sp,48
    80003602:	89aa                	mv	s3,a0
    80003604:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003606:	ffffe097          	auipc	ra,0xffffe
    8000360a:	3ce080e7          	jalr	974(ra) # 800019d4 <myproc>
    8000360e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80003610:	ffffd097          	auipc	ra,0xffffd
    80003614:	5d2080e7          	jalr	1490(ra) # 80000be2 <acquire>
  releasesleep(lk);
    80003618:	854a                	mv	a0,s2
    8000361a:	00002097          	auipc	ra,0x2
    8000361e:	238080e7          	jalr	568(ra) # 80005852 <releasesleep>

  // Go to sleep.
  p->chan = chan;
    80003622:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80003626:	4789                	li	a5,2
    80003628:	cc9c                	sw	a5,24(s1)

  sched();
    8000362a:	fffff097          	auipc	ra,0xfffff
    8000362e:	f0a080e7          	jalr	-246(ra) # 80002534 <sched>

  // Tidy up.
  p->chan = 0;
    80003632:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80003636:	8526                	mv	a0,s1
    80003638:	ffffd097          	auipc	ra,0xffffd
    8000363c:	65e080e7          	jalr	1630(ra) # 80000c96 <release>
  acquiresleep(lk);
    80003640:	854a                	mv	a0,s2
    80003642:	00002097          	auipc	ra,0x2
    80003646:	1ba080e7          	jalr	442(ra) # 800057fc <acquiresleep>
}
    8000364a:	70a2                	ld	ra,40(sp)
    8000364c:	7402                	ld	s0,32(sp)
    8000364e:	64e2                	ld	s1,24(sp)
    80003650:	6942                	ld	s2,16(sp)
    80003652:	69a2                	ld	s3,8(sp)
    80003654:	6145                	addi	sp,sp,48
    80003656:	8082                	ret

0000000080003658 <wakeupone>:

void
wakeupone(struct cond_t *chan)
{
    80003658:	7179                	addi	sp,sp,-48
    8000365a:	f406                	sd	ra,40(sp)
    8000365c:	f022                	sd	s0,32(sp)
    8000365e:	ec26                	sd	s1,24(sp)
    80003660:	e84a                	sd	s2,16(sp)
    80003662:	e44e                	sd	s3,8(sp)
    80003664:	e052                	sd	s4,0(sp)
    80003666:	1800                	addi	s0,sp,48
    80003668:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000366a:	0000f497          	auipc	s1,0xf
    8000366e:	09648493          	addi	s1,s1,150 # 80012700 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80003672:	4989                	li	s3,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80003674:	00015917          	auipc	s2,0x15
    80003678:	48c90913          	addi	s2,s2,1164 # 80018b00 <tickslock>
    8000367c:	a811                	j	80003690 <wakeupone+0x38>
        p->state = RUNNABLE;
        release(&p->lock);
        break;
      }
      release(&p->lock);
    8000367e:	8526                	mv	a0,s1
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	616080e7          	jalr	1558(ra) # 80000c96 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80003688:	19048493          	addi	s1,s1,400
    8000368c:	03248a63          	beq	s1,s2,800036c0 <wakeupone+0x68>
    if(p != myproc()){
    80003690:	ffffe097          	auipc	ra,0xffffe
    80003694:	344080e7          	jalr	836(ra) # 800019d4 <myproc>
    80003698:	fea488e3          	beq	s1,a0,80003688 <wakeupone+0x30>
      acquire(&p->lock);
    8000369c:	8526                	mv	a0,s1
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	544080e7          	jalr	1348(ra) # 80000be2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800036a6:	4c9c                	lw	a5,24(s1)
    800036a8:	fd379be3          	bne	a5,s3,8000367e <wakeupone+0x26>
    800036ac:	709c                	ld	a5,32(s1)
    800036ae:	fd4798e3          	bne	a5,s4,8000367e <wakeupone+0x26>
        p->state = RUNNABLE;
    800036b2:	478d                	li	a5,3
    800036b4:	cc9c                	sw	a5,24(s1)
        release(&p->lock);
    800036b6:	8526                	mv	a0,s1
    800036b8:	ffffd097          	auipc	ra,0xffffd
    800036bc:	5de080e7          	jalr	1502(ra) # 80000c96 <release>
    }
  }
    800036c0:	70a2                	ld	ra,40(sp)
    800036c2:	7402                	ld	s0,32(sp)
    800036c4:	64e2                	ld	s1,24(sp)
    800036c6:	6942                	ld	s2,16(sp)
    800036c8:	69a2                	ld	s3,8(sp)
    800036ca:	6a02                	ld	s4,0(sp)
    800036cc:	6145                	addi	sp,sp,48
    800036ce:	8082                	ret

00000000800036d0 <swtch>:
    800036d0:	00153023          	sd	ra,0(a0)
    800036d4:	00253423          	sd	sp,8(a0)
    800036d8:	e900                	sd	s0,16(a0)
    800036da:	ed04                	sd	s1,24(a0)
    800036dc:	03253023          	sd	s2,32(a0)
    800036e0:	03353423          	sd	s3,40(a0)
    800036e4:	03453823          	sd	s4,48(a0)
    800036e8:	03553c23          	sd	s5,56(a0)
    800036ec:	05653023          	sd	s6,64(a0)
    800036f0:	05753423          	sd	s7,72(a0)
    800036f4:	05853823          	sd	s8,80(a0)
    800036f8:	05953c23          	sd	s9,88(a0)
    800036fc:	07a53023          	sd	s10,96(a0)
    80003700:	07b53423          	sd	s11,104(a0)
    80003704:	0005b083          	ld	ra,0(a1)
    80003708:	0085b103          	ld	sp,8(a1)
    8000370c:	6980                	ld	s0,16(a1)
    8000370e:	6d84                	ld	s1,24(a1)
    80003710:	0205b903          	ld	s2,32(a1)
    80003714:	0285b983          	ld	s3,40(a1)
    80003718:	0305ba03          	ld	s4,48(a1)
    8000371c:	0385ba83          	ld	s5,56(a1)
    80003720:	0405bb03          	ld	s6,64(a1)
    80003724:	0485bb83          	ld	s7,72(a1)
    80003728:	0505bc03          	ld	s8,80(a1)
    8000372c:	0585bc83          	ld	s9,88(a1)
    80003730:	0605bd03          	ld	s10,96(a1)
    80003734:	0685bd83          	ld	s11,104(a1)
    80003738:	8082                	ret

000000008000373a <trapinit>:

extern int sched_policy;

void
trapinit(void)
{
    8000373a:	1141                	addi	sp,sp,-16
    8000373c:	e406                	sd	ra,8(sp)
    8000373e:	e022                	sd	s0,0(sp)
    80003740:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80003742:	00006597          	auipc	a1,0x6
    80003746:	da658593          	addi	a1,a1,-602 # 800094e8 <states.1857+0x30>
    8000374a:	00015517          	auipc	a0,0x15
    8000374e:	3b650513          	addi	a0,a0,950 # 80018b00 <tickslock>
    80003752:	ffffd097          	auipc	ra,0xffffd
    80003756:	400080e7          	jalr	1024(ra) # 80000b52 <initlock>
}
    8000375a:	60a2                	ld	ra,8(sp)
    8000375c:	6402                	ld	s0,0(sp)
    8000375e:	0141                	addi	sp,sp,16
    80003760:	8082                	ret

0000000080003762 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003762:	1141                	addi	sp,sp,-16
    80003764:	e422                	sd	s0,8(sp)
    80003766:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003768:	00004797          	auipc	a5,0x4
    8000376c:	88878793          	addi	a5,a5,-1912 # 80006ff0 <kernelvec>
    80003770:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003774:	6422                	ld	s0,8(sp)
    80003776:	0141                	addi	sp,sp,16
    80003778:	8082                	ret

000000008000377a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000377a:	1141                	addi	sp,sp,-16
    8000377c:	e406                	sd	ra,8(sp)
    8000377e:	e022                	sd	s0,0(sp)
    80003780:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003782:	ffffe097          	auipc	ra,0xffffe
    80003786:	252080e7          	jalr	594(ra) # 800019d4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000378a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000378e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003790:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003794:	00005617          	auipc	a2,0x5
    80003798:	86c60613          	addi	a2,a2,-1940 # 80008000 <_trampoline>
    8000379c:	00005697          	auipc	a3,0x5
    800037a0:	86468693          	addi	a3,a3,-1948 # 80008000 <_trampoline>
    800037a4:	8e91                	sub	a3,a3,a2
    800037a6:	040007b7          	lui	a5,0x4000
    800037aa:	17fd                	addi	a5,a5,-1
    800037ac:	07b2                	slli	a5,a5,0xc
    800037ae:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800037b0:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800037b4:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800037b6:	180026f3          	csrr	a3,satp
    800037ba:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800037bc:	7138                	ld	a4,96(a0)
    800037be:	6534                	ld	a3,72(a0)
    800037c0:	6585                	lui	a1,0x1
    800037c2:	96ae                	add	a3,a3,a1
    800037c4:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800037c6:	7138                	ld	a4,96(a0)
    800037c8:	00000697          	auipc	a3,0x0
    800037cc:	13868693          	addi	a3,a3,312 # 80003900 <usertrap>
    800037d0:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800037d2:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800037d4:	8692                	mv	a3,tp
    800037d6:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800037d8:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800037dc:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800037e0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800037e4:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800037e8:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800037ea:	6f18                	ld	a4,24(a4)
    800037ec:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800037f0:	6d2c                	ld	a1,88(a0)
    800037f2:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800037f4:	00005717          	auipc	a4,0x5
    800037f8:	89c70713          	addi	a4,a4,-1892 # 80008090 <userret>
    800037fc:	8f11                	sub	a4,a4,a2
    800037fe:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80003800:	577d                	li	a4,-1
    80003802:	177e                	slli	a4,a4,0x3f
    80003804:	8dd9                	or	a1,a1,a4
    80003806:	02000537          	lui	a0,0x2000
    8000380a:	157d                	addi	a0,a0,-1
    8000380c:	0536                	slli	a0,a0,0xd
    8000380e:	9782                	jalr	a5
}
    80003810:	60a2                	ld	ra,8(sp)
    80003812:	6402                	ld	s0,0(sp)
    80003814:	0141                	addi	sp,sp,16
    80003816:	8082                	ret

0000000080003818 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80003818:	1101                	addi	sp,sp,-32
    8000381a:	ec06                	sd	ra,24(sp)
    8000381c:	e822                	sd	s0,16(sp)
    8000381e:	e426                	sd	s1,8(sp)
    80003820:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003822:	00015497          	auipc	s1,0x15
    80003826:	2de48493          	addi	s1,s1,734 # 80018b00 <tickslock>
    8000382a:	8526                	mv	a0,s1
    8000382c:	ffffd097          	auipc	ra,0xffffd
    80003830:	3b6080e7          	jalr	950(ra) # 80000be2 <acquire>
  ticks++;
    80003834:	00007517          	auipc	a0,0x7
    80003838:	83850513          	addi	a0,a0,-1992 # 8000a06c <ticks>
    8000383c:	411c                	lw	a5,0(a0)
    8000383e:	2785                	addiw	a5,a5,1
    80003840:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003842:	fffff097          	auipc	ra,0xfffff
    80003846:	33a080e7          	jalr	826(ra) # 80002b7c <wakeup>
  release(&tickslock);
    8000384a:	8526                	mv	a0,s1
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	44a080e7          	jalr	1098(ra) # 80000c96 <release>
}
    80003854:	60e2                	ld	ra,24(sp)
    80003856:	6442                	ld	s0,16(sp)
    80003858:	64a2                	ld	s1,8(sp)
    8000385a:	6105                	addi	sp,sp,32
    8000385c:	8082                	ret

000000008000385e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000385e:	1101                	addi	sp,sp,-32
    80003860:	ec06                	sd	ra,24(sp)
    80003862:	e822                	sd	s0,16(sp)
    80003864:	e426                	sd	s1,8(sp)
    80003866:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003868:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000386c:	00074d63          	bltz	a4,80003886 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80003870:	57fd                	li	a5,-1
    80003872:	17fe                	slli	a5,a5,0x3f
    80003874:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80003876:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80003878:	06f70363          	beq	a4,a5,800038de <devintr+0x80>
  }
}
    8000387c:	60e2                	ld	ra,24(sp)
    8000387e:	6442                	ld	s0,16(sp)
    80003880:	64a2                	ld	s1,8(sp)
    80003882:	6105                	addi	sp,sp,32
    80003884:	8082                	ret
     (scause & 0xff) == 9){
    80003886:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000388a:	46a5                	li	a3,9
    8000388c:	fed792e3          	bne	a5,a3,80003870 <devintr+0x12>
    int irq = plic_claim();
    80003890:	00004097          	auipc	ra,0x4
    80003894:	868080e7          	jalr	-1944(ra) # 800070f8 <plic_claim>
    80003898:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000389a:	47a9                	li	a5,10
    8000389c:	02f50763          	beq	a0,a5,800038ca <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800038a0:	4785                	li	a5,1
    800038a2:	02f50963          	beq	a0,a5,800038d4 <devintr+0x76>
    return 1;
    800038a6:	4505                	li	a0,1
    } else if(irq){
    800038a8:	d8f1                	beqz	s1,8000387c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800038aa:	85a6                	mv	a1,s1
    800038ac:	00006517          	auipc	a0,0x6
    800038b0:	c4450513          	addi	a0,a0,-956 # 800094f0 <states.1857+0x38>
    800038b4:	ffffd097          	auipc	ra,0xffffd
    800038b8:	cd2080e7          	jalr	-814(ra) # 80000586 <printf>
      plic_complete(irq);
    800038bc:	8526                	mv	a0,s1
    800038be:	00004097          	auipc	ra,0x4
    800038c2:	85e080e7          	jalr	-1954(ra) # 8000711c <plic_complete>
    return 1;
    800038c6:	4505                	li	a0,1
    800038c8:	bf55                	j	8000387c <devintr+0x1e>
      uartintr();
    800038ca:	ffffd097          	auipc	ra,0xffffd
    800038ce:	0dc080e7          	jalr	220(ra) # 800009a6 <uartintr>
    800038d2:	b7ed                	j	800038bc <devintr+0x5e>
      virtio_disk_intr();
    800038d4:	00004097          	auipc	ra,0x4
    800038d8:	d28080e7          	jalr	-728(ra) # 800075fc <virtio_disk_intr>
    800038dc:	b7c5                	j	800038bc <devintr+0x5e>
    if(cpuid() == 0){
    800038de:	ffffe097          	auipc	ra,0xffffe
    800038e2:	0ca080e7          	jalr	202(ra) # 800019a8 <cpuid>
    800038e6:	c901                	beqz	a0,800038f6 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800038e8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800038ec:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800038ee:	14479073          	csrw	sip,a5
    return 2;
    800038f2:	4509                	li	a0,2
    800038f4:	b761                	j	8000387c <devintr+0x1e>
      clockintr();
    800038f6:	00000097          	auipc	ra,0x0
    800038fa:	f22080e7          	jalr	-222(ra) # 80003818 <clockintr>
    800038fe:	b7ed                	j	800038e8 <devintr+0x8a>

0000000080003900 <usertrap>:
{
    80003900:	1101                	addi	sp,sp,-32
    80003902:	ec06                	sd	ra,24(sp)
    80003904:	e822                	sd	s0,16(sp)
    80003906:	e426                	sd	s1,8(sp)
    80003908:	e04a                	sd	s2,0(sp)
    8000390a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000390c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003910:	1007f793          	andi	a5,a5,256
    80003914:	e3ad                	bnez	a5,80003976 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003916:	00003797          	auipc	a5,0x3
    8000391a:	6da78793          	addi	a5,a5,1754 # 80006ff0 <kernelvec>
    8000391e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003922:	ffffe097          	auipc	ra,0xffffe
    80003926:	0b2080e7          	jalr	178(ra) # 800019d4 <myproc>
    8000392a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000392c:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000392e:	14102773          	csrr	a4,sepc
    80003932:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003934:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003938:	47a1                	li	a5,8
    8000393a:	04f71c63          	bne	a4,a5,80003992 <usertrap+0x92>
    if(p->killed)
    8000393e:	551c                	lw	a5,40(a0)
    80003940:	e3b9                	bnez	a5,80003986 <usertrap+0x86>
    p->trapframe->epc += 4;
    80003942:	70b8                	ld	a4,96(s1)
    80003944:	6f1c                	ld	a5,24(a4)
    80003946:	0791                	addi	a5,a5,4
    80003948:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000394a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000394e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003952:	10079073          	csrw	sstatus,a5
    syscall();
    80003956:	00000097          	auipc	ra,0x0
    8000395a:	2fc080e7          	jalr	764(ra) # 80003c52 <syscall>
  if(p->killed)
    8000395e:	549c                	lw	a5,40(s1)
    80003960:	efd9                	bnez	a5,800039fe <usertrap+0xfe>
  usertrapret();
    80003962:	00000097          	auipc	ra,0x0
    80003966:	e18080e7          	jalr	-488(ra) # 8000377a <usertrapret>
}
    8000396a:	60e2                	ld	ra,24(sp)
    8000396c:	6442                	ld	s0,16(sp)
    8000396e:	64a2                	ld	s1,8(sp)
    80003970:	6902                	ld	s2,0(sp)
    80003972:	6105                	addi	sp,sp,32
    80003974:	8082                	ret
    panic("usertrap: not from user mode");
    80003976:	00006517          	auipc	a0,0x6
    8000397a:	b9a50513          	addi	a0,a0,-1126 # 80009510 <states.1857+0x58>
    8000397e:	ffffd097          	auipc	ra,0xffffd
    80003982:	bbe080e7          	jalr	-1090(ra) # 8000053c <panic>
      exit(-1);
    80003986:	557d                	li	a0,-1
    80003988:	fffff097          	auipc	ra,0xfffff
    8000398c:	310080e7          	jalr	784(ra) # 80002c98 <exit>
    80003990:	bf4d                	j	80003942 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80003992:	00000097          	auipc	ra,0x0
    80003996:	ecc080e7          	jalr	-308(ra) # 8000385e <devintr>
    8000399a:	892a                	mv	s2,a0
    8000399c:	c501                	beqz	a0,800039a4 <usertrap+0xa4>
  if(p->killed)
    8000399e:	549c                	lw	a5,40(s1)
    800039a0:	c3a1                	beqz	a5,800039e0 <usertrap+0xe0>
    800039a2:	a815                	j	800039d6 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800039a4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800039a8:	5890                	lw	a2,48(s1)
    800039aa:	00006517          	auipc	a0,0x6
    800039ae:	b8650513          	addi	a0,a0,-1146 # 80009530 <states.1857+0x78>
    800039b2:	ffffd097          	auipc	ra,0xffffd
    800039b6:	bd4080e7          	jalr	-1068(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800039ba:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800039be:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800039c2:	00006517          	auipc	a0,0x6
    800039c6:	b9e50513          	addi	a0,a0,-1122 # 80009560 <states.1857+0xa8>
    800039ca:	ffffd097          	auipc	ra,0xffffd
    800039ce:	bbc080e7          	jalr	-1092(ra) # 80000586 <printf>
    p->killed = 1;
    800039d2:	4785                	li	a5,1
    800039d4:	d49c                	sw	a5,40(s1)
    exit(-1);
    800039d6:	557d                	li	a0,-1
    800039d8:	fffff097          	auipc	ra,0xfffff
    800039dc:	2c0080e7          	jalr	704(ra) # 80002c98 <exit>
  if(which_dev == 2) {
    800039e0:	4789                	li	a5,2
    800039e2:	f8f910e3          	bne	s2,a5,80003962 <usertrap+0x62>
    if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_NPREEMPT_SJF)) yield();
    800039e6:	00006717          	auipc	a4,0x6
    800039ea:	68272703          	lw	a4,1666(a4) # 8000a068 <sched_policy>
    800039ee:	4785                	li	a5,1
    800039f0:	f6e7f9e3          	bgeu	a5,a4,80003962 <usertrap+0x62>
    800039f4:	fffff097          	auipc	ra,0xfffff
    800039f8:	c16080e7          	jalr	-1002(ra) # 8000260a <yield>
    800039fc:	b79d                	j	80003962 <usertrap+0x62>
  int which_dev = 0;
    800039fe:	4901                	li	s2,0
    80003a00:	bfd9                	j	800039d6 <usertrap+0xd6>

0000000080003a02 <kerneltrap>:
{
    80003a02:	7179                	addi	sp,sp,-48
    80003a04:	f406                	sd	ra,40(sp)
    80003a06:	f022                	sd	s0,32(sp)
    80003a08:	ec26                	sd	s1,24(sp)
    80003a0a:	e84a                	sd	s2,16(sp)
    80003a0c:	e44e                	sd	s3,8(sp)
    80003a0e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003a10:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003a14:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003a18:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003a1c:	1004f793          	andi	a5,s1,256
    80003a20:	cb85                	beqz	a5,80003a50 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003a22:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003a26:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003a28:	ef85                	bnez	a5,80003a60 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003a2a:	00000097          	auipc	ra,0x0
    80003a2e:	e34080e7          	jalr	-460(ra) # 8000385e <devintr>
    80003a32:	cd1d                	beqz	a0,80003a70 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80003a34:	4789                	li	a5,2
    80003a36:	06f50a63          	beq	a0,a5,80003aaa <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003a3a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003a3e:	10049073          	csrw	sstatus,s1
}
    80003a42:	70a2                	ld	ra,40(sp)
    80003a44:	7402                	ld	s0,32(sp)
    80003a46:	64e2                	ld	s1,24(sp)
    80003a48:	6942                	ld	s2,16(sp)
    80003a4a:	69a2                	ld	s3,8(sp)
    80003a4c:	6145                	addi	sp,sp,48
    80003a4e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003a50:	00006517          	auipc	a0,0x6
    80003a54:	b3050513          	addi	a0,a0,-1232 # 80009580 <states.1857+0xc8>
    80003a58:	ffffd097          	auipc	ra,0xffffd
    80003a5c:	ae4080e7          	jalr	-1308(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80003a60:	00006517          	auipc	a0,0x6
    80003a64:	b4850513          	addi	a0,a0,-1208 # 800095a8 <states.1857+0xf0>
    80003a68:	ffffd097          	auipc	ra,0xffffd
    80003a6c:	ad4080e7          	jalr	-1324(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80003a70:	85ce                	mv	a1,s3
    80003a72:	00006517          	auipc	a0,0x6
    80003a76:	b5650513          	addi	a0,a0,-1194 # 800095c8 <states.1857+0x110>
    80003a7a:	ffffd097          	auipc	ra,0xffffd
    80003a7e:	b0c080e7          	jalr	-1268(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003a82:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003a86:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003a8a:	00006517          	auipc	a0,0x6
    80003a8e:	b4e50513          	addi	a0,a0,-1202 # 800095d8 <states.1857+0x120>
    80003a92:	ffffd097          	auipc	ra,0xffffd
    80003a96:	af4080e7          	jalr	-1292(ra) # 80000586 <printf>
    panic("kerneltrap");
    80003a9a:	00006517          	auipc	a0,0x6
    80003a9e:	b5650513          	addi	a0,a0,-1194 # 800095f0 <states.1857+0x138>
    80003aa2:	ffffd097          	auipc	ra,0xffffd
    80003aa6:	a9a080e7          	jalr	-1382(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80003aaa:	ffffe097          	auipc	ra,0xffffe
    80003aae:	f2a080e7          	jalr	-214(ra) # 800019d4 <myproc>
    80003ab2:	d541                	beqz	a0,80003a3a <kerneltrap+0x38>
    80003ab4:	ffffe097          	auipc	ra,0xffffe
    80003ab8:	f20080e7          	jalr	-224(ra) # 800019d4 <myproc>
    80003abc:	4d18                	lw	a4,24(a0)
    80003abe:	4791                	li	a5,4
    80003ac0:	f6f71de3          	bne	a4,a5,80003a3a <kerneltrap+0x38>
     if ((sched_policy != SCHED_NPREEMPT_FCFS) && (sched_policy != SCHED_NPREEMPT_SJF)) yield();
    80003ac4:	00006717          	auipc	a4,0x6
    80003ac8:	5a472703          	lw	a4,1444(a4) # 8000a068 <sched_policy>
    80003acc:	4785                	li	a5,1
    80003ace:	f6e7f6e3          	bgeu	a5,a4,80003a3a <kerneltrap+0x38>
    80003ad2:	fffff097          	auipc	ra,0xfffff
    80003ad6:	b38080e7          	jalr	-1224(ra) # 8000260a <yield>
    80003ada:	b785                	j	80003a3a <kerneltrap+0x38>

0000000080003adc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003adc:	1101                	addi	sp,sp,-32
    80003ade:	ec06                	sd	ra,24(sp)
    80003ae0:	e822                	sd	s0,16(sp)
    80003ae2:	e426                	sd	s1,8(sp)
    80003ae4:	1000                	addi	s0,sp,32
    80003ae6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003ae8:	ffffe097          	auipc	ra,0xffffe
    80003aec:	eec080e7          	jalr	-276(ra) # 800019d4 <myproc>
  switch (n) {
    80003af0:	4795                	li	a5,5
    80003af2:	0497e163          	bltu	a5,s1,80003b34 <argraw+0x58>
    80003af6:	048a                	slli	s1,s1,0x2
    80003af8:	00006717          	auipc	a4,0x6
    80003afc:	b3070713          	addi	a4,a4,-1232 # 80009628 <states.1857+0x170>
    80003b00:	94ba                	add	s1,s1,a4
    80003b02:	409c                	lw	a5,0(s1)
    80003b04:	97ba                	add	a5,a5,a4
    80003b06:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003b08:	713c                	ld	a5,96(a0)
    80003b0a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003b0c:	60e2                	ld	ra,24(sp)
    80003b0e:	6442                	ld	s0,16(sp)
    80003b10:	64a2                	ld	s1,8(sp)
    80003b12:	6105                	addi	sp,sp,32
    80003b14:	8082                	ret
    return p->trapframe->a1;
    80003b16:	713c                	ld	a5,96(a0)
    80003b18:	7fa8                	ld	a0,120(a5)
    80003b1a:	bfcd                	j	80003b0c <argraw+0x30>
    return p->trapframe->a2;
    80003b1c:	713c                	ld	a5,96(a0)
    80003b1e:	63c8                	ld	a0,128(a5)
    80003b20:	b7f5                	j	80003b0c <argraw+0x30>
    return p->trapframe->a3;
    80003b22:	713c                	ld	a5,96(a0)
    80003b24:	67c8                	ld	a0,136(a5)
    80003b26:	b7dd                	j	80003b0c <argraw+0x30>
    return p->trapframe->a4;
    80003b28:	713c                	ld	a5,96(a0)
    80003b2a:	6bc8                	ld	a0,144(a5)
    80003b2c:	b7c5                	j	80003b0c <argraw+0x30>
    return p->trapframe->a5;
    80003b2e:	713c                	ld	a5,96(a0)
    80003b30:	6fc8                	ld	a0,152(a5)
    80003b32:	bfe9                	j	80003b0c <argraw+0x30>
  panic("argraw");
    80003b34:	00006517          	auipc	a0,0x6
    80003b38:	acc50513          	addi	a0,a0,-1332 # 80009600 <states.1857+0x148>
    80003b3c:	ffffd097          	auipc	ra,0xffffd
    80003b40:	a00080e7          	jalr	-1536(ra) # 8000053c <panic>

0000000080003b44 <fetchaddr>:
{
    80003b44:	1101                	addi	sp,sp,-32
    80003b46:	ec06                	sd	ra,24(sp)
    80003b48:	e822                	sd	s0,16(sp)
    80003b4a:	e426                	sd	s1,8(sp)
    80003b4c:	e04a                	sd	s2,0(sp)
    80003b4e:	1000                	addi	s0,sp,32
    80003b50:	84aa                	mv	s1,a0
    80003b52:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003b54:	ffffe097          	auipc	ra,0xffffe
    80003b58:	e80080e7          	jalr	-384(ra) # 800019d4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003b5c:	693c                	ld	a5,80(a0)
    80003b5e:	02f4f863          	bgeu	s1,a5,80003b8e <fetchaddr+0x4a>
    80003b62:	00848713          	addi	a4,s1,8
    80003b66:	02e7e663          	bltu	a5,a4,80003b92 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003b6a:	46a1                	li	a3,8
    80003b6c:	8626                	mv	a2,s1
    80003b6e:	85ca                	mv	a1,s2
    80003b70:	6d28                	ld	a0,88(a0)
    80003b72:	ffffe097          	auipc	ra,0xffffe
    80003b76:	bb0080e7          	jalr	-1104(ra) # 80001722 <copyin>
    80003b7a:	00a03533          	snez	a0,a0
    80003b7e:	40a00533          	neg	a0,a0
}
    80003b82:	60e2                	ld	ra,24(sp)
    80003b84:	6442                	ld	s0,16(sp)
    80003b86:	64a2                	ld	s1,8(sp)
    80003b88:	6902                	ld	s2,0(sp)
    80003b8a:	6105                	addi	sp,sp,32
    80003b8c:	8082                	ret
    return -1;
    80003b8e:	557d                	li	a0,-1
    80003b90:	bfcd                	j	80003b82 <fetchaddr+0x3e>
    80003b92:	557d                	li	a0,-1
    80003b94:	b7fd                	j	80003b82 <fetchaddr+0x3e>

0000000080003b96 <fetchstr>:
{
    80003b96:	7179                	addi	sp,sp,-48
    80003b98:	f406                	sd	ra,40(sp)
    80003b9a:	f022                	sd	s0,32(sp)
    80003b9c:	ec26                	sd	s1,24(sp)
    80003b9e:	e84a                	sd	s2,16(sp)
    80003ba0:	e44e                	sd	s3,8(sp)
    80003ba2:	1800                	addi	s0,sp,48
    80003ba4:	892a                	mv	s2,a0
    80003ba6:	84ae                	mv	s1,a1
    80003ba8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003baa:	ffffe097          	auipc	ra,0xffffe
    80003bae:	e2a080e7          	jalr	-470(ra) # 800019d4 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003bb2:	86ce                	mv	a3,s3
    80003bb4:	864a                	mv	a2,s2
    80003bb6:	85a6                	mv	a1,s1
    80003bb8:	6d28                	ld	a0,88(a0)
    80003bba:	ffffe097          	auipc	ra,0xffffe
    80003bbe:	bf4080e7          	jalr	-1036(ra) # 800017ae <copyinstr>
  if(err < 0)
    80003bc2:	00054763          	bltz	a0,80003bd0 <fetchstr+0x3a>
  return strlen(buf);
    80003bc6:	8526                	mv	a0,s1
    80003bc8:	ffffd097          	auipc	ra,0xffffd
    80003bcc:	29a080e7          	jalr	666(ra) # 80000e62 <strlen>
}
    80003bd0:	70a2                	ld	ra,40(sp)
    80003bd2:	7402                	ld	s0,32(sp)
    80003bd4:	64e2                	ld	s1,24(sp)
    80003bd6:	6942                	ld	s2,16(sp)
    80003bd8:	69a2                	ld	s3,8(sp)
    80003bda:	6145                	addi	sp,sp,48
    80003bdc:	8082                	ret

0000000080003bde <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003bde:	1101                	addi	sp,sp,-32
    80003be0:	ec06                	sd	ra,24(sp)
    80003be2:	e822                	sd	s0,16(sp)
    80003be4:	e426                	sd	s1,8(sp)
    80003be6:	1000                	addi	s0,sp,32
    80003be8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003bea:	00000097          	auipc	ra,0x0
    80003bee:	ef2080e7          	jalr	-270(ra) # 80003adc <argraw>
    80003bf2:	c088                	sw	a0,0(s1)
  return 0;
}
    80003bf4:	4501                	li	a0,0
    80003bf6:	60e2                	ld	ra,24(sp)
    80003bf8:	6442                	ld	s0,16(sp)
    80003bfa:	64a2                	ld	s1,8(sp)
    80003bfc:	6105                	addi	sp,sp,32
    80003bfe:	8082                	ret

0000000080003c00 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003c00:	1101                	addi	sp,sp,-32
    80003c02:	ec06                	sd	ra,24(sp)
    80003c04:	e822                	sd	s0,16(sp)
    80003c06:	e426                	sd	s1,8(sp)
    80003c08:	1000                	addi	s0,sp,32
    80003c0a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	ed0080e7          	jalr	-304(ra) # 80003adc <argraw>
    80003c14:	e088                	sd	a0,0(s1)
  return 0;
}
    80003c16:	4501                	li	a0,0
    80003c18:	60e2                	ld	ra,24(sp)
    80003c1a:	6442                	ld	s0,16(sp)
    80003c1c:	64a2                	ld	s1,8(sp)
    80003c1e:	6105                	addi	sp,sp,32
    80003c20:	8082                	ret

0000000080003c22 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003c22:	1101                	addi	sp,sp,-32
    80003c24:	ec06                	sd	ra,24(sp)
    80003c26:	e822                	sd	s0,16(sp)
    80003c28:	e426                	sd	s1,8(sp)
    80003c2a:	e04a                	sd	s2,0(sp)
    80003c2c:	1000                	addi	s0,sp,32
    80003c2e:	84ae                	mv	s1,a1
    80003c30:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003c32:	00000097          	auipc	ra,0x0
    80003c36:	eaa080e7          	jalr	-342(ra) # 80003adc <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003c3a:	864a                	mv	a2,s2
    80003c3c:	85a6                	mv	a1,s1
    80003c3e:	00000097          	auipc	ra,0x0
    80003c42:	f58080e7          	jalr	-168(ra) # 80003b96 <fetchstr>
}
    80003c46:	60e2                	ld	ra,24(sp)
    80003c48:	6442                	ld	s0,16(sp)
    80003c4a:	64a2                	ld	s1,8(sp)
    80003c4c:	6902                	ld	s2,0(sp)
    80003c4e:	6105                	addi	sp,sp,32
    80003c50:	8082                	ret

0000000080003c52 <syscall>:

};

void
syscall(void)
{
    80003c52:	1101                	addi	sp,sp,-32
    80003c54:	ec06                	sd	ra,24(sp)
    80003c56:	e822                	sd	s0,16(sp)
    80003c58:	e426                	sd	s1,8(sp)
    80003c5a:	e04a                	sd	s2,0(sp)
    80003c5c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003c5e:	ffffe097          	auipc	ra,0xffffe
    80003c62:	d76080e7          	jalr	-650(ra) # 800019d4 <myproc>
    80003c66:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003c68:	06053903          	ld	s2,96(a0)
    80003c6c:	0a893783          	ld	a5,168(s2)
    80003c70:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003c74:	37fd                	addiw	a5,a5,-1
    80003c76:	02000713          	li	a4,32
    80003c7a:	00f76f63          	bltu	a4,a5,80003c98 <syscall+0x46>
    80003c7e:	00369713          	slli	a4,a3,0x3
    80003c82:	00006797          	auipc	a5,0x6
    80003c86:	9be78793          	addi	a5,a5,-1602 # 80009640 <syscalls>
    80003c8a:	97ba                	add	a5,a5,a4
    80003c8c:	639c                	ld	a5,0(a5)
    80003c8e:	c789                	beqz	a5,80003c98 <syscall+0x46>
    p->trapframe->a0 = syscalls[num]();
    80003c90:	9782                	jalr	a5
    80003c92:	06a93823          	sd	a0,112(s2)
    80003c96:	a839                	j	80003cb4 <syscall+0x62>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003c98:	16048613          	addi	a2,s1,352
    80003c9c:	588c                	lw	a1,48(s1)
    80003c9e:	00006517          	auipc	a0,0x6
    80003ca2:	96a50513          	addi	a0,a0,-1686 # 80009608 <states.1857+0x150>
    80003ca6:	ffffd097          	auipc	ra,0xffffd
    80003caa:	8e0080e7          	jalr	-1824(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003cae:	70bc                	ld	a5,96(s1)
    80003cb0:	577d                	li	a4,-1
    80003cb2:	fbb8                	sd	a4,112(a5)
  }
}
    80003cb4:	60e2                	ld	ra,24(sp)
    80003cb6:	6442                	ld	s0,16(sp)
    80003cb8:	64a2                	ld	s1,8(sp)
    80003cba:	6902                	ld	s2,0(sp)
    80003cbc:	6105                	addi	sp,sp,32
    80003cbe:	8082                	ret

0000000080003cc0 <sys_exit>:

struct barr barrier_arr[10];

uint64
sys_exit(void)
{
    80003cc0:	1101                	addi	sp,sp,-32
    80003cc2:	ec06                	sd	ra,24(sp)
    80003cc4:	e822                	sd	s0,16(sp)
    80003cc6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003cc8:	fec40593          	addi	a1,s0,-20
    80003ccc:	4501                	li	a0,0
    80003cce:	00000097          	auipc	ra,0x0
    80003cd2:	f10080e7          	jalr	-240(ra) # 80003bde <argint>
    return -1;
    80003cd6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003cd8:	00054963          	bltz	a0,80003cea <sys_exit+0x2a>
  exit(n);
    80003cdc:	fec42503          	lw	a0,-20(s0)
    80003ce0:	fffff097          	auipc	ra,0xfffff
    80003ce4:	fb8080e7          	jalr	-72(ra) # 80002c98 <exit>
  return 0;  // not reached
    80003ce8:	4781                	li	a5,0
}
    80003cea:	853e                	mv	a0,a5
    80003cec:	60e2                	ld	ra,24(sp)
    80003cee:	6442                	ld	s0,16(sp)
    80003cf0:	6105                	addi	sp,sp,32
    80003cf2:	8082                	ret

0000000080003cf4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003cf4:	1141                	addi	sp,sp,-16
    80003cf6:	e406                	sd	ra,8(sp)
    80003cf8:	e022                	sd	s0,0(sp)
    80003cfa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003cfc:	ffffe097          	auipc	ra,0xffffe
    80003d00:	cd8080e7          	jalr	-808(ra) # 800019d4 <myproc>
}
    80003d04:	5908                	lw	a0,48(a0)
    80003d06:	60a2                	ld	ra,8(sp)
    80003d08:	6402                	ld	s0,0(sp)
    80003d0a:	0141                	addi	sp,sp,16
    80003d0c:	8082                	ret

0000000080003d0e <sys_fork>:

uint64
sys_fork(void)
{
    80003d0e:	1141                	addi	sp,sp,-16
    80003d10:	e406                	sd	ra,8(sp)
    80003d12:	e022                	sd	s0,0(sp)
    80003d14:	0800                	addi	s0,sp,16
  return fork();
    80003d16:	ffffe097          	auipc	ra,0xffffe
    80003d1a:	102080e7          	jalr	258(ra) # 80001e18 <fork>
}
    80003d1e:	60a2                	ld	ra,8(sp)
    80003d20:	6402                	ld	s0,0(sp)
    80003d22:	0141                	addi	sp,sp,16
    80003d24:	8082                	ret

0000000080003d26 <sys_wait>:

uint64
sys_wait(void)
{
    80003d26:	1101                	addi	sp,sp,-32
    80003d28:	ec06                	sd	ra,24(sp)
    80003d2a:	e822                	sd	s0,16(sp)
    80003d2c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003d2e:	fe840593          	addi	a1,s0,-24
    80003d32:	4501                	li	a0,0
    80003d34:	00000097          	auipc	ra,0x0
    80003d38:	ecc080e7          	jalr	-308(ra) # 80003c00 <argaddr>
    80003d3c:	87aa                	mv	a5,a0
    return -1;
    80003d3e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003d40:	0007c863          	bltz	a5,80003d50 <sys_wait+0x2a>
  return wait(p);
    80003d44:	fe843503          	ld	a0,-24(s0)
    80003d48:	fffff097          	auipc	ra,0xfffff
    80003d4c:	bdc080e7          	jalr	-1060(ra) # 80002924 <wait>
}
    80003d50:	60e2                	ld	ra,24(sp)
    80003d52:	6442                	ld	s0,16(sp)
    80003d54:	6105                	addi	sp,sp,32
    80003d56:	8082                	ret

0000000080003d58 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003d58:	7179                	addi	sp,sp,-48
    80003d5a:	f406                	sd	ra,40(sp)
    80003d5c:	f022                	sd	s0,32(sp)
    80003d5e:	ec26                	sd	s1,24(sp)
    80003d60:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003d62:	fdc40593          	addi	a1,s0,-36
    80003d66:	4501                	li	a0,0
    80003d68:	00000097          	auipc	ra,0x0
    80003d6c:	e76080e7          	jalr	-394(ra) # 80003bde <argint>
    80003d70:	87aa                	mv	a5,a0
    return -1;
    80003d72:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80003d74:	0207c063          	bltz	a5,80003d94 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80003d78:	ffffe097          	auipc	ra,0xffffe
    80003d7c:	c5c080e7          	jalr	-932(ra) # 800019d4 <myproc>
    80003d80:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80003d82:	fdc42503          	lw	a0,-36(s0)
    80003d86:	ffffe097          	auipc	ra,0xffffe
    80003d8a:	01e080e7          	jalr	30(ra) # 80001da4 <growproc>
    80003d8e:	00054863          	bltz	a0,80003d9e <sys_sbrk+0x46>
    return -1;
  return addr;
    80003d92:	8526                	mv	a0,s1
}
    80003d94:	70a2                	ld	ra,40(sp)
    80003d96:	7402                	ld	s0,32(sp)
    80003d98:	64e2                	ld	s1,24(sp)
    80003d9a:	6145                	addi	sp,sp,48
    80003d9c:	8082                	ret
    return -1;
    80003d9e:	557d                	li	a0,-1
    80003da0:	bfd5                	j	80003d94 <sys_sbrk+0x3c>

0000000080003da2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003da2:	7139                	addi	sp,sp,-64
    80003da4:	fc06                	sd	ra,56(sp)
    80003da6:	f822                	sd	s0,48(sp)
    80003da8:	f426                	sd	s1,40(sp)
    80003daa:	f04a                	sd	s2,32(sp)
    80003dac:	ec4e                	sd	s3,24(sp)
    80003dae:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003db0:	fcc40593          	addi	a1,s0,-52
    80003db4:	4501                	li	a0,0
    80003db6:	00000097          	auipc	ra,0x0
    80003dba:	e28080e7          	jalr	-472(ra) # 80003bde <argint>
    return -1;
    80003dbe:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003dc0:	06054563          	bltz	a0,80003e2a <sys_sleep+0x88>
  acquire(&tickslock);
    80003dc4:	00015517          	auipc	a0,0x15
    80003dc8:	d3c50513          	addi	a0,a0,-708 # 80018b00 <tickslock>
    80003dcc:	ffffd097          	auipc	ra,0xffffd
    80003dd0:	e16080e7          	jalr	-490(ra) # 80000be2 <acquire>
  ticks0 = ticks;
    80003dd4:	00006917          	auipc	s2,0x6
    80003dd8:	29892903          	lw	s2,664(s2) # 8000a06c <ticks>
  while(ticks - ticks0 < n){
    80003ddc:	fcc42783          	lw	a5,-52(s0)
    80003de0:	cf85                	beqz	a5,80003e18 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003de2:	00015997          	auipc	s3,0x15
    80003de6:	d1e98993          	addi	s3,s3,-738 # 80018b00 <tickslock>
    80003dea:	00006497          	auipc	s1,0x6
    80003dee:	28248493          	addi	s1,s1,642 # 8000a06c <ticks>
    if(myproc()->killed){
    80003df2:	ffffe097          	auipc	ra,0xffffe
    80003df6:	be2080e7          	jalr	-1054(ra) # 800019d4 <myproc>
    80003dfa:	551c                	lw	a5,40(a0)
    80003dfc:	ef9d                	bnez	a5,80003e3a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003dfe:	85ce                	mv	a1,s3
    80003e00:	8526                	mv	a0,s1
    80003e02:	fffff097          	auipc	ra,0xfffff
    80003e06:	974080e7          	jalr	-1676(ra) # 80002776 <sleep>
  while(ticks - ticks0 < n){
    80003e0a:	409c                	lw	a5,0(s1)
    80003e0c:	412787bb          	subw	a5,a5,s2
    80003e10:	fcc42703          	lw	a4,-52(s0)
    80003e14:	fce7efe3          	bltu	a5,a4,80003df2 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003e18:	00015517          	auipc	a0,0x15
    80003e1c:	ce850513          	addi	a0,a0,-792 # 80018b00 <tickslock>
    80003e20:	ffffd097          	auipc	ra,0xffffd
    80003e24:	e76080e7          	jalr	-394(ra) # 80000c96 <release>
  return 0;
    80003e28:	4781                	li	a5,0
}
    80003e2a:	853e                	mv	a0,a5
    80003e2c:	70e2                	ld	ra,56(sp)
    80003e2e:	7442                	ld	s0,48(sp)
    80003e30:	74a2                	ld	s1,40(sp)
    80003e32:	7902                	ld	s2,32(sp)
    80003e34:	69e2                	ld	s3,24(sp)
    80003e36:	6121                	addi	sp,sp,64
    80003e38:	8082                	ret
      release(&tickslock);
    80003e3a:	00015517          	auipc	a0,0x15
    80003e3e:	cc650513          	addi	a0,a0,-826 # 80018b00 <tickslock>
    80003e42:	ffffd097          	auipc	ra,0xffffd
    80003e46:	e54080e7          	jalr	-428(ra) # 80000c96 <release>
      return -1;
    80003e4a:	57fd                	li	a5,-1
    80003e4c:	bff9                	j	80003e2a <sys_sleep+0x88>

0000000080003e4e <sys_kill>:

uint64
sys_kill(void)
{
    80003e4e:	1101                	addi	sp,sp,-32
    80003e50:	ec06                	sd	ra,24(sp)
    80003e52:	e822                	sd	s0,16(sp)
    80003e54:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003e56:	fec40593          	addi	a1,s0,-20
    80003e5a:	4501                	li	a0,0
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	d82080e7          	jalr	-638(ra) # 80003bde <argint>
    80003e64:	87aa                	mv	a5,a0
    return -1;
    80003e66:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003e68:	0007c863          	bltz	a5,80003e78 <sys_kill+0x2a>
  return kill(pid);
    80003e6c:	fec42503          	lw	a0,-20(s0)
    80003e70:	fffff097          	auipc	ra,0xfffff
    80003e74:	260080e7          	jalr	608(ra) # 800030d0 <kill>
}
    80003e78:	60e2                	ld	ra,24(sp)
    80003e7a:	6442                	ld	s0,16(sp)
    80003e7c:	6105                	addi	sp,sp,32
    80003e7e:	8082                	ret

0000000080003e80 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003e80:	1101                	addi	sp,sp,-32
    80003e82:	ec06                	sd	ra,24(sp)
    80003e84:	e822                	sd	s0,16(sp)
    80003e86:	e426                	sd	s1,8(sp)
    80003e88:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003e8a:	00015517          	auipc	a0,0x15
    80003e8e:	c7650513          	addi	a0,a0,-906 # 80018b00 <tickslock>
    80003e92:	ffffd097          	auipc	ra,0xffffd
    80003e96:	d50080e7          	jalr	-688(ra) # 80000be2 <acquire>
  xticks = ticks;
    80003e9a:	00006497          	auipc	s1,0x6
    80003e9e:	1d24a483          	lw	s1,466(s1) # 8000a06c <ticks>
  release(&tickslock);
    80003ea2:	00015517          	auipc	a0,0x15
    80003ea6:	c5e50513          	addi	a0,a0,-930 # 80018b00 <tickslock>
    80003eaa:	ffffd097          	auipc	ra,0xffffd
    80003eae:	dec080e7          	jalr	-532(ra) # 80000c96 <release>
  return xticks;
}
    80003eb2:	02049513          	slli	a0,s1,0x20
    80003eb6:	9101                	srli	a0,a0,0x20
    80003eb8:	60e2                	ld	ra,24(sp)
    80003eba:	6442                	ld	s0,16(sp)
    80003ebc:	64a2                	ld	s1,8(sp)
    80003ebe:	6105                	addi	sp,sp,32
    80003ec0:	8082                	ret

0000000080003ec2 <sys_getppid>:

uint64
sys_getppid(void)
{
    80003ec2:	1141                	addi	sp,sp,-16
    80003ec4:	e406                	sd	ra,8(sp)
    80003ec6:	e022                	sd	s0,0(sp)
    80003ec8:	0800                	addi	s0,sp,16
  if (myproc()->parent) return myproc()->parent->pid;
    80003eca:	ffffe097          	auipc	ra,0xffffe
    80003ece:	b0a080e7          	jalr	-1270(ra) # 800019d4 <myproc>
    80003ed2:	613c                	ld	a5,64(a0)
    80003ed4:	cb99                	beqz	a5,80003eea <sys_getppid+0x28>
    80003ed6:	ffffe097          	auipc	ra,0xffffe
    80003eda:	afe080e7          	jalr	-1282(ra) # 800019d4 <myproc>
    80003ede:	613c                	ld	a5,64(a0)
    80003ee0:	5b88                	lw	a0,48(a5)
  else {
     printf("No parent found.\n");
     return 0;
  }
}
    80003ee2:	60a2                	ld	ra,8(sp)
    80003ee4:	6402                	ld	s0,0(sp)
    80003ee6:	0141                	addi	sp,sp,16
    80003ee8:	8082                	ret
     printf("No parent found.\n");
    80003eea:	00006517          	auipc	a0,0x6
    80003eee:	86650513          	addi	a0,a0,-1946 # 80009750 <syscalls+0x110>
    80003ef2:	ffffc097          	auipc	ra,0xffffc
    80003ef6:	694080e7          	jalr	1684(ra) # 80000586 <printf>
     return 0;
    80003efa:	4501                	li	a0,0
    80003efc:	b7dd                	j	80003ee2 <sys_getppid+0x20>

0000000080003efe <sys_yield>:

uint64
sys_yield(void)
{
    80003efe:	1141                	addi	sp,sp,-16
    80003f00:	e406                	sd	ra,8(sp)
    80003f02:	e022                	sd	s0,0(sp)
    80003f04:	0800                	addi	s0,sp,16
  yield();
    80003f06:	ffffe097          	auipc	ra,0xffffe
    80003f0a:	704080e7          	jalr	1796(ra) # 8000260a <yield>
  return 0;
}
    80003f0e:	4501                	li	a0,0
    80003f10:	60a2                	ld	ra,8(sp)
    80003f12:	6402                	ld	s0,0(sp)
    80003f14:	0141                	addi	sp,sp,16
    80003f16:	8082                	ret

0000000080003f18 <sys_getpa>:

uint64
sys_getpa(void)
{
    80003f18:	1101                	addi	sp,sp,-32
    80003f1a:	ec06                	sd	ra,24(sp)
    80003f1c:	e822                	sd	s0,16(sp)
    80003f1e:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
    80003f20:	fe840593          	addi	a1,s0,-24
    80003f24:	4501                	li	a0,0
    80003f26:	00000097          	auipc	ra,0x0
    80003f2a:	cda080e7          	jalr	-806(ra) # 80003c00 <argaddr>
    80003f2e:	87aa                	mv	a5,a0
    80003f30:	557d                	li	a0,-1
    80003f32:	0207c263          	bltz	a5,80003f56 <sys_getpa+0x3e>
  return walkaddr(myproc()->pagetable, x) + (x & (PGSIZE - 1));
    80003f36:	ffffe097          	auipc	ra,0xffffe
    80003f3a:	a9e080e7          	jalr	-1378(ra) # 800019d4 <myproc>
    80003f3e:	fe843583          	ld	a1,-24(s0)
    80003f42:	6d28                	ld	a0,88(a0)
    80003f44:	ffffd097          	auipc	ra,0xffffd
    80003f48:	14e080e7          	jalr	334(ra) # 80001092 <walkaddr>
    80003f4c:	fe843783          	ld	a5,-24(s0)
    80003f50:	17d2                	slli	a5,a5,0x34
    80003f52:	93d1                	srli	a5,a5,0x34
    80003f54:	953e                	add	a0,a0,a5
}
    80003f56:	60e2                	ld	ra,24(sp)
    80003f58:	6442                	ld	s0,16(sp)
    80003f5a:	6105                	addi	sp,sp,32
    80003f5c:	8082                	ret

0000000080003f5e <sys_forkf>:

uint64
sys_forkf(void)
{
    80003f5e:	1101                	addi	sp,sp,-32
    80003f60:	ec06                	sd	ra,24(sp)
    80003f62:	e822                	sd	s0,16(sp)
    80003f64:	1000                	addi	s0,sp,32
  uint64 x;
  if (argaddr(0, &x) < 0) return -1;
    80003f66:	fe840593          	addi	a1,s0,-24
    80003f6a:	4501                	li	a0,0
    80003f6c:	00000097          	auipc	ra,0x0
    80003f70:	c94080e7          	jalr	-876(ra) # 80003c00 <argaddr>
    80003f74:	87aa                	mv	a5,a0
    80003f76:	557d                	li	a0,-1
    80003f78:	0007c863          	bltz	a5,80003f88 <sys_forkf+0x2a>
  return forkf(x);
    80003f7c:	fe843503          	ld	a0,-24(s0)
    80003f80:	ffffe097          	auipc	ra,0xffffe
    80003f84:	fd4080e7          	jalr	-44(ra) # 80001f54 <forkf>
}
    80003f88:	60e2                	ld	ra,24(sp)
    80003f8a:	6442                	ld	s0,16(sp)
    80003f8c:	6105                	addi	sp,sp,32
    80003f8e:	8082                	ret

0000000080003f90 <sys_waitpid>:

uint64
sys_waitpid(void)
{
    80003f90:	1101                	addi	sp,sp,-32
    80003f92:	ec06                	sd	ra,24(sp)
    80003f94:	e822                	sd	s0,16(sp)
    80003f96:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    80003f98:	fe440593          	addi	a1,s0,-28
    80003f9c:	4501                	li	a0,0
    80003f9e:	00000097          	auipc	ra,0x0
    80003fa2:	c40080e7          	jalr	-960(ra) # 80003bde <argint>
    return -1;
    80003fa6:	57fd                	li	a5,-1
  if(argint(0, &x) < 0)
    80003fa8:	02054c63          	bltz	a0,80003fe0 <sys_waitpid+0x50>
  if(argaddr(1, &p) < 0)
    80003fac:	fe840593          	addi	a1,s0,-24
    80003fb0:	4505                	li	a0,1
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	c4e080e7          	jalr	-946(ra) # 80003c00 <argaddr>
    80003fba:	04054063          	bltz	a0,80003ffa <sys_waitpid+0x6a>
    return -1;

  if (x == -1) return wait(p);
    80003fbe:	fe442503          	lw	a0,-28(s0)
    80003fc2:	57fd                	li	a5,-1
    80003fc4:	02f50363          	beq	a0,a5,80003fea <sys_waitpid+0x5a>
  if ((x == 0) || (x < -1)) return -1;
    80003fc8:	57fd                	li	a5,-1
    80003fca:	c919                	beqz	a0,80003fe0 <sys_waitpid+0x50>
    80003fcc:	577d                	li	a4,-1
    80003fce:	00e54963          	blt	a0,a4,80003fe0 <sys_waitpid+0x50>
  return waitpid(x, p);
    80003fd2:	fe843583          	ld	a1,-24(s0)
    80003fd6:	fffff097          	auipc	ra,0xfffff
    80003fda:	a76080e7          	jalr	-1418(ra) # 80002a4c <waitpid>
    80003fde:	87aa                	mv	a5,a0
}
    80003fe0:	853e                	mv	a0,a5
    80003fe2:	60e2                	ld	ra,24(sp)
    80003fe4:	6442                	ld	s0,16(sp)
    80003fe6:	6105                	addi	sp,sp,32
    80003fe8:	8082                	ret
  if (x == -1) return wait(p);
    80003fea:	fe843503          	ld	a0,-24(s0)
    80003fee:	fffff097          	auipc	ra,0xfffff
    80003ff2:	936080e7          	jalr	-1738(ra) # 80002924 <wait>
    80003ff6:	87aa                	mv	a5,a0
    80003ff8:	b7e5                	j	80003fe0 <sys_waitpid+0x50>
    return -1;
    80003ffa:	57fd                	li	a5,-1
    80003ffc:	b7d5                	j	80003fe0 <sys_waitpid+0x50>

0000000080003ffe <sys_ps>:

uint64
sys_ps(void)
{
    80003ffe:	1141                	addi	sp,sp,-16
    80004000:	e406                	sd	ra,8(sp)
    80004002:	e022                	sd	s0,0(sp)
    80004004:	0800                	addi	s0,sp,16
   return ps();
    80004006:	fffff097          	auipc	ra,0xfffff
    8000400a:	2c6080e7          	jalr	710(ra) # 800032cc <ps>
}
    8000400e:	60a2                	ld	ra,8(sp)
    80004010:	6402                	ld	s0,0(sp)
    80004012:	0141                	addi	sp,sp,16
    80004014:	8082                	ret

0000000080004016 <sys_pinfo>:

uint64
sys_pinfo(void)
{
    80004016:	1101                	addi	sp,sp,-32
    80004018:	ec06                	sd	ra,24(sp)
    8000401a:	e822                	sd	s0,16(sp)
    8000401c:	1000                	addi	s0,sp,32
  uint64 p;
  int x;

  if(argint(0, &x) < 0)
    8000401e:	fe440593          	addi	a1,s0,-28
    80004022:	4501                	li	a0,0
    80004024:	00000097          	auipc	ra,0x0
    80004028:	bba080e7          	jalr	-1094(ra) # 80003bde <argint>
    return -1;
    8000402c:	57fd                	li	a5,-1
  if(argint(0, &x) < 0)
    8000402e:	02054963          	bltz	a0,80004060 <sys_pinfo+0x4a>
  if(argaddr(1, &p) < 0)
    80004032:	fe840593          	addi	a1,s0,-24
    80004036:	4505                	li	a0,1
    80004038:	00000097          	auipc	ra,0x0
    8000403c:	bc8080e7          	jalr	-1080(ra) # 80003c00 <argaddr>
    80004040:	02054563          	bltz	a0,8000406a <sys_pinfo+0x54>
    return -1;

  if ((x == 0) || (x < -1) || (p == 0)) return -1;
    80004044:	fe442503          	lw	a0,-28(s0)
    80004048:	57fd                	li	a5,-1
    8000404a:	c919                	beqz	a0,80004060 <sys_pinfo+0x4a>
    8000404c:	02f54163          	blt	a0,a5,8000406e <sys_pinfo+0x58>
    80004050:	fe843583          	ld	a1,-24(s0)
    80004054:	c591                	beqz	a1,80004060 <sys_pinfo+0x4a>
  return pinfo(x, p);
    80004056:	fffff097          	auipc	ra,0xfffff
    8000405a:	3e2080e7          	jalr	994(ra) # 80003438 <pinfo>
    8000405e:	87aa                	mv	a5,a0
}
    80004060:	853e                	mv	a0,a5
    80004062:	60e2                	ld	ra,24(sp)
    80004064:	6442                	ld	s0,16(sp)
    80004066:	6105                	addi	sp,sp,32
    80004068:	8082                	ret
    return -1;
    8000406a:	57fd                	li	a5,-1
    8000406c:	bfd5                	j	80004060 <sys_pinfo+0x4a>
  if ((x == 0) || (x < -1) || (p == 0)) return -1;
    8000406e:	57fd                	li	a5,-1
    80004070:	bfc5                	j	80004060 <sys_pinfo+0x4a>

0000000080004072 <sys_forkp>:

uint64
sys_forkp(void)
{
    80004072:	1101                	addi	sp,sp,-32
    80004074:	ec06                	sd	ra,24(sp)
    80004076:	e822                	sd	s0,16(sp)
    80004078:	1000                	addi	s0,sp,32
  int x;
  if(argint(0, &x) < 0) return -1;
    8000407a:	fec40593          	addi	a1,s0,-20
    8000407e:	4501                	li	a0,0
    80004080:	00000097          	auipc	ra,0x0
    80004084:	b5e080e7          	jalr	-1186(ra) # 80003bde <argint>
    80004088:	87aa                	mv	a5,a0
    8000408a:	557d                	li	a0,-1
    8000408c:	0007c863          	bltz	a5,8000409c <sys_forkp+0x2a>
  return forkp(x);
    80004090:	fec42503          	lw	a0,-20(s0)
    80004094:	ffffe097          	auipc	ra,0xffffe
    80004098:	008080e7          	jalr	8(ra) # 8000209c <forkp>
}
    8000409c:	60e2                	ld	ra,24(sp)
    8000409e:	6442                	ld	s0,16(sp)
    800040a0:	6105                	addi	sp,sp,32
    800040a2:	8082                	ret

00000000800040a4 <sys_schedpolicy>:

uint64
sys_schedpolicy(void)
{
    800040a4:	1101                	addi	sp,sp,-32
    800040a6:	ec06                	sd	ra,24(sp)
    800040a8:	e822                	sd	s0,16(sp)
    800040aa:	1000                	addi	s0,sp,32
  int x;
  if(argint(0, &x) < 0) return -1;
    800040ac:	fec40593          	addi	a1,s0,-20
    800040b0:	4501                	li	a0,0
    800040b2:	00000097          	auipc	ra,0x0
    800040b6:	b2c080e7          	jalr	-1236(ra) # 80003bde <argint>
    800040ba:	87aa                	mv	a5,a0
    800040bc:	557d                	li	a0,-1
    800040be:	0007c863          	bltz	a5,800040ce <sys_schedpolicy+0x2a>
  return schedpolicy(x);
    800040c2:	fec42503          	lw	a0,-20(s0)
    800040c6:	fffff097          	auipc	ra,0xfffff
    800040ca:	514080e7          	jalr	1300(ra) # 800035da <schedpolicy>
}
    800040ce:	60e2                	ld	ra,24(sp)
    800040d0:	6442                	ld	s0,16(sp)
    800040d2:	6105                	addi	sp,sp,32
    800040d4:	8082                	ret

00000000800040d6 <sys_barrier_alloc>:

uint64
sys_barrier_alloc(void)
{
    800040d6:	1101                	addi	sp,sp,-32
    800040d8:	ec06                	sd	ra,24(sp)
    800040da:	e822                	sd	s0,16(sp)
    800040dc:	e426                	sd	s1,8(sp)
    800040de:	e04a                	sd	s2,0(sp)
    800040e0:	1000                	addi	s0,sp,32
  for(int i = 0; i < 10; i++)
    800040e2:	00015797          	auipc	a5,0x15
    800040e6:	a3678793          	addi	a5,a5,-1482 # 80018b18 <barrier_arr>
    800040ea:	4501                	li	a0,0
  {
    if(barrier_arr[i].count == -1){
    800040ec:	56fd                	li	a3,-1
  for(int i = 0; i < 10; i++)
    800040ee:	4629                	li	a2,10
    if(barrier_arr[i].count == -1){
    800040f0:	4398                	lw	a4,0(a5)
    800040f2:	00d70f63          	beq	a4,a3,80004110 <sys_barrier_alloc+0x3a>
  for(int i = 0; i < 10; i++)
    800040f6:	2505                	addiw	a0,a0,1
    800040f8:	04078793          	addi	a5,a5,64
    800040fc:	fec51ae3          	bne	a0,a2,800040f0 <sys_barrier_alloc+0x1a>
      (barrier_arr[i].cv).cond = 0;
      return i;
    }
  }

  return -1;
    80004100:	54fd                	li	s1,-1
}
    80004102:	8526                	mv	a0,s1
    80004104:	60e2                	ld	ra,24(sp)
    80004106:	6442                	ld	s0,16(sp)
    80004108:	64a2                	ld	s1,8(sp)
    8000410a:	6902                	ld	s2,0(sp)
    8000410c:	6105                	addi	sp,sp,32
    8000410e:	8082                	ret
      barrier_arr[i].count = 0;
    80004110:	00015717          	auipc	a4,0x15
    80004114:	a0870713          	addi	a4,a4,-1528 # 80018b18 <barrier_arr>
    80004118:	00651793          	slli	a5,a0,0x6
    8000411c:	00f70933          	add	s2,a4,a5
    80004120:	00092023          	sw	zero,0(s2)
      initsleeplock(&(barrier_arr[i].barr_lock), "barrier_lock");
    80004124:	84aa                	mv	s1,a0
    80004126:	07a1                	addi	a5,a5,8
    80004128:	00005597          	auipc	a1,0x5
    8000412c:	64058593          	addi	a1,a1,1600 # 80009768 <syscalls+0x128>
    80004130:	00f70533          	add	a0,a4,a5
    80004134:	00001097          	auipc	ra,0x1
    80004138:	68e080e7          	jalr	1678(ra) # 800057c2 <initsleeplock>
      (barrier_arr[i].cv).cond = 0;
    8000413c:	02092c23          	sw	zero,56(s2)
      return i;
    80004140:	b7c9                	j	80004102 <sys_barrier_alloc+0x2c>

0000000080004142 <sys_barrier>:

uint64
sys_barrier(void)
{
    80004142:	7179                	addi	sp,sp,-48
    80004144:	f406                	sd	ra,40(sp)
    80004146:	f022                	sd	s0,32(sp)
    80004148:	ec26                	sd	s1,24(sp)
    8000414a:	1800                	addi	s0,sp,48
  int barr_inst_no, barr_id, proc_nu;
  if(argint(0, &barr_inst_no) < 0) return -1;
    8000414c:	fdc40593          	addi	a1,s0,-36
    80004150:	4501                	li	a0,0
    80004152:	00000097          	auipc	ra,0x0
    80004156:	a8c080e7          	jalr	-1396(ra) # 80003bde <argint>
    8000415a:	57fd                	li	a5,-1
    8000415c:	0c054f63          	bltz	a0,8000423a <sys_barrier+0xf8>
  if(argint(1, &barr_id) < 0) return -1;
    80004160:	fd840593          	addi	a1,s0,-40
    80004164:	4505                	li	a0,1
    80004166:	00000097          	auipc	ra,0x0
    8000416a:	a78080e7          	jalr	-1416(ra) # 80003bde <argint>
    8000416e:	57fd                	li	a5,-1
    80004170:	0c054563          	bltz	a0,8000423a <sys_barrier+0xf8>
  if(argint(2, &proc_nu) < 0) return -1;
    80004174:	fd440593          	addi	a1,s0,-44
    80004178:	4509                	li	a0,2
    8000417a:	00000097          	auipc	ra,0x0
    8000417e:	a64080e7          	jalr	-1436(ra) # 80003bde <argint>
    80004182:	57fd                	li	a5,-1
    80004184:	0a054b63          	bltz	a0,8000423a <sys_barrier+0xf8>

  acquiresleep(&(barrier_arr[barr_id].barr_lock));
    80004188:	00015497          	auipc	s1,0x15
    8000418c:	99048493          	addi	s1,s1,-1648 # 80018b18 <barrier_arr>
    80004190:	fd842503          	lw	a0,-40(s0)
    80004194:	051a                	slli	a0,a0,0x6
    80004196:	0521                	addi	a0,a0,8
    80004198:	9526                	add	a0,a0,s1
    8000419a:	00001097          	auipc	ra,0x1
    8000419e:	662080e7          	jalr	1634(ra) # 800057fc <acquiresleep>

  printf("%d: Entered barrier#%d for barrier array id %d\n", myproc()->pid, barr_inst_no, barr_id);
    800041a2:	ffffe097          	auipc	ra,0xffffe
    800041a6:	832080e7          	jalr	-1998(ra) # 800019d4 <myproc>
    800041aa:	fd842683          	lw	a3,-40(s0)
    800041ae:	fdc42603          	lw	a2,-36(s0)
    800041b2:	590c                	lw	a1,48(a0)
    800041b4:	00005517          	auipc	a0,0x5
    800041b8:	5c450513          	addi	a0,a0,1476 # 80009778 <syscalls+0x138>
    800041bc:	ffffc097          	auipc	ra,0xffffc
    800041c0:	3ca080e7          	jalr	970(ra) # 80000586 <printf>

  barrier_arr[barr_id].count++;
    800041c4:	fd842783          	lw	a5,-40(s0)
    800041c8:	00679713          	slli	a4,a5,0x6
    800041cc:	94ba                	add	s1,s1,a4
    800041ce:	4098                	lw	a4,0(s1)
    800041d0:	2705                	addiw	a4,a4,1
    800041d2:	0007069b          	sext.w	a3,a4
    800041d6:	c098                	sw	a4,0(s1)
  if(barrier_arr[barr_id].count == proc_nu){
    800041d8:	fd442703          	lw	a4,-44(s0)
    800041dc:	06d70563          	beq	a4,a3,80004246 <sys_barrier+0x104>
    barrier_arr[barr_id].count = 0;
    cond_broadcast(&(barrier_arr[barr_id].cv));
  }
  else cond_wait(&(barrier_arr[barr_id].cv), &(barrier_arr[barr_id].barr_lock));
    800041e0:	079a                	slli	a5,a5,0x6
    800041e2:	00015517          	auipc	a0,0x15
    800041e6:	93650513          	addi	a0,a0,-1738 # 80018b18 <barrier_arr>
    800041ea:	00878593          	addi	a1,a5,8
    800041ee:	03878793          	addi	a5,a5,56
    800041f2:	95aa                	add	a1,a1,a0
    800041f4:	953e                	add	a0,a0,a5
    800041f6:	00003097          	auipc	ra,0x3
    800041fa:	4d0080e7          	jalr	1232(ra) # 800076c6 <cond_wait>

  printf("%d: Finished barrier#%d for barrier array id %d\n", myproc()->pid, barr_inst_no, barr_id);
    800041fe:	ffffd097          	auipc	ra,0xffffd
    80004202:	7d6080e7          	jalr	2006(ra) # 800019d4 <myproc>
    80004206:	fd842683          	lw	a3,-40(s0)
    8000420a:	fdc42603          	lw	a2,-36(s0)
    8000420e:	590c                	lw	a1,48(a0)
    80004210:	00005517          	auipc	a0,0x5
    80004214:	59850513          	addi	a0,a0,1432 # 800097a8 <syscalls+0x168>
    80004218:	ffffc097          	auipc	ra,0xffffc
    8000421c:	36e080e7          	jalr	878(ra) # 80000586 <printf>

  releasesleep(&(barrier_arr[barr_id].barr_lock));
    80004220:	fd842783          	lw	a5,-40(s0)
    80004224:	079a                	slli	a5,a5,0x6
    80004226:	00015517          	auipc	a0,0x15
    8000422a:	8fa50513          	addi	a0,a0,-1798 # 80018b20 <barrier_arr+0x8>
    8000422e:	953e                	add	a0,a0,a5
    80004230:	00001097          	auipc	ra,0x1
    80004234:	622080e7          	jalr	1570(ra) # 80005852 <releasesleep>

  return 1;
    80004238:	4785                	li	a5,1
}
    8000423a:	853e                	mv	a0,a5
    8000423c:	70a2                	ld	ra,40(sp)
    8000423e:	7402                	ld	s0,32(sp)
    80004240:	64e2                	ld	s1,24(sp)
    80004242:	6145                	addi	sp,sp,48
    80004244:	8082                	ret
    barrier_arr[barr_id].count = 0;
    80004246:	00015517          	auipc	a0,0x15
    8000424a:	8d250513          	addi	a0,a0,-1838 # 80018b18 <barrier_arr>
    8000424e:	079a                	slli	a5,a5,0x6
    80004250:	0004a023          	sw	zero,0(s1)
    cond_broadcast(&(barrier_arr[barr_id].cv));
    80004254:	03878793          	addi	a5,a5,56
    80004258:	953e                	add	a0,a0,a5
    8000425a:	00003097          	auipc	ra,0x3
    8000425e:	49c080e7          	jalr	1180(ra) # 800076f6 <cond_broadcast>
    80004262:	bf71                	j	800041fe <sys_barrier+0xbc>

0000000080004264 <sys_barrier_free>:

uint64
sys_barrier_free(void)
{
    80004264:	1101                	addi	sp,sp,-32
    80004266:	ec06                	sd	ra,24(sp)
    80004268:	e822                	sd	s0,16(sp)
    8000426a:	1000                	addi	s0,sp,32
  int i;
  if(argint(0, &i) < 0) return -1;
    8000426c:	fec40593          	addi	a1,s0,-20
    80004270:	4501                	li	a0,0
    80004272:	00000097          	auipc	ra,0x0
    80004276:	96c080e7          	jalr	-1684(ra) # 80003bde <argint>
    8000427a:	02054263          	bltz	a0,8000429e <sys_barrier_free+0x3a>

  barrier_arr[i].count = -1;
    8000427e:	fec42783          	lw	a5,-20(s0)
    80004282:	00679713          	slli	a4,a5,0x6
    80004286:	00015797          	auipc	a5,0x15
    8000428a:	89278793          	addi	a5,a5,-1902 # 80018b18 <barrier_arr>
    8000428e:	97ba                	add	a5,a5,a4
    80004290:	577d                	li	a4,-1
    80004292:	c398                	sw	a4,0(a5)
  return 1;
    80004294:	4505                	li	a0,1
    80004296:	60e2                	ld	ra,24(sp)
    80004298:	6442                	ld	s0,16(sp)
    8000429a:	6105                	addi	sp,sp,32
    8000429c:	8082                	ret
  if(argint(0, &i) < 0) return -1;
    8000429e:	557d                	li	a0,-1
    800042a0:	bfdd                	j	80004296 <sys_barrier_free+0x32>

00000000800042a2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800042a2:	7179                	addi	sp,sp,-48
    800042a4:	f406                	sd	ra,40(sp)
    800042a6:	f022                	sd	s0,32(sp)
    800042a8:	ec26                	sd	s1,24(sp)
    800042aa:	e84a                	sd	s2,16(sp)
    800042ac:	e44e                	sd	s3,8(sp)
    800042ae:	e052                	sd	s4,0(sp)
    800042b0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800042b2:	00005597          	auipc	a1,0x5
    800042b6:	52e58593          	addi	a1,a1,1326 # 800097e0 <syscalls+0x1a0>
    800042ba:	00015517          	auipc	a0,0x15
    800042be:	ade50513          	addi	a0,a0,-1314 # 80018d98 <bcache>
    800042c2:	ffffd097          	auipc	ra,0xffffd
    800042c6:	890080e7          	jalr	-1904(ra) # 80000b52 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800042ca:	0001d797          	auipc	a5,0x1d
    800042ce:	ace78793          	addi	a5,a5,-1330 # 80020d98 <bcache+0x8000>
    800042d2:	0001d717          	auipc	a4,0x1d
    800042d6:	d2e70713          	addi	a4,a4,-722 # 80021000 <bcache+0x8268>
    800042da:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800042de:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800042e2:	00015497          	auipc	s1,0x15
    800042e6:	ace48493          	addi	s1,s1,-1330 # 80018db0 <bcache+0x18>
    b->next = bcache.head.next;
    800042ea:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800042ec:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800042ee:	00005a17          	auipc	s4,0x5
    800042f2:	4faa0a13          	addi	s4,s4,1274 # 800097e8 <syscalls+0x1a8>
    b->next = bcache.head.next;
    800042f6:	2b893783          	ld	a5,696(s2)
    800042fa:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800042fc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80004300:	85d2                	mv	a1,s4
    80004302:	01048513          	addi	a0,s1,16
    80004306:	00001097          	auipc	ra,0x1
    8000430a:	4bc080e7          	jalr	1212(ra) # 800057c2 <initsleeplock>
    bcache.head.next->prev = b;
    8000430e:	2b893783          	ld	a5,696(s2)
    80004312:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80004314:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004318:	45848493          	addi	s1,s1,1112
    8000431c:	fd349de3          	bne	s1,s3,800042f6 <binit+0x54>
  }
}
    80004320:	70a2                	ld	ra,40(sp)
    80004322:	7402                	ld	s0,32(sp)
    80004324:	64e2                	ld	s1,24(sp)
    80004326:	6942                	ld	s2,16(sp)
    80004328:	69a2                	ld	s3,8(sp)
    8000432a:	6a02                	ld	s4,0(sp)
    8000432c:	6145                	addi	sp,sp,48
    8000432e:	8082                	ret

0000000080004330 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80004330:	7179                	addi	sp,sp,-48
    80004332:	f406                	sd	ra,40(sp)
    80004334:	f022                	sd	s0,32(sp)
    80004336:	ec26                	sd	s1,24(sp)
    80004338:	e84a                	sd	s2,16(sp)
    8000433a:	e44e                	sd	s3,8(sp)
    8000433c:	1800                	addi	s0,sp,48
    8000433e:	89aa                	mv	s3,a0
    80004340:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80004342:	00015517          	auipc	a0,0x15
    80004346:	a5650513          	addi	a0,a0,-1450 # 80018d98 <bcache>
    8000434a:	ffffd097          	auipc	ra,0xffffd
    8000434e:	898080e7          	jalr	-1896(ra) # 80000be2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004352:	0001d497          	auipc	s1,0x1d
    80004356:	cfe4b483          	ld	s1,-770(s1) # 80021050 <bcache+0x82b8>
    8000435a:	0001d797          	auipc	a5,0x1d
    8000435e:	ca678793          	addi	a5,a5,-858 # 80021000 <bcache+0x8268>
    80004362:	02f48f63          	beq	s1,a5,800043a0 <bread+0x70>
    80004366:	873e                	mv	a4,a5
    80004368:	a021                	j	80004370 <bread+0x40>
    8000436a:	68a4                	ld	s1,80(s1)
    8000436c:	02e48a63          	beq	s1,a4,800043a0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80004370:	449c                	lw	a5,8(s1)
    80004372:	ff379ce3          	bne	a5,s3,8000436a <bread+0x3a>
    80004376:	44dc                	lw	a5,12(s1)
    80004378:	ff2799e3          	bne	a5,s2,8000436a <bread+0x3a>
      b->refcnt++;
    8000437c:	40bc                	lw	a5,64(s1)
    8000437e:	2785                	addiw	a5,a5,1
    80004380:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004382:	00015517          	auipc	a0,0x15
    80004386:	a1650513          	addi	a0,a0,-1514 # 80018d98 <bcache>
    8000438a:	ffffd097          	auipc	ra,0xffffd
    8000438e:	90c080e7          	jalr	-1780(ra) # 80000c96 <release>
      acquiresleep(&b->lock);
    80004392:	01048513          	addi	a0,s1,16
    80004396:	00001097          	auipc	ra,0x1
    8000439a:	466080e7          	jalr	1126(ra) # 800057fc <acquiresleep>
      return b;
    8000439e:	a8b9                	j	800043fc <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800043a0:	0001d497          	auipc	s1,0x1d
    800043a4:	ca84b483          	ld	s1,-856(s1) # 80021048 <bcache+0x82b0>
    800043a8:	0001d797          	auipc	a5,0x1d
    800043ac:	c5878793          	addi	a5,a5,-936 # 80021000 <bcache+0x8268>
    800043b0:	00f48863          	beq	s1,a5,800043c0 <bread+0x90>
    800043b4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800043b6:	40bc                	lw	a5,64(s1)
    800043b8:	cf81                	beqz	a5,800043d0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800043ba:	64a4                	ld	s1,72(s1)
    800043bc:	fee49de3          	bne	s1,a4,800043b6 <bread+0x86>
  panic("bget: no buffers");
    800043c0:	00005517          	auipc	a0,0x5
    800043c4:	43050513          	addi	a0,a0,1072 # 800097f0 <syscalls+0x1b0>
    800043c8:	ffffc097          	auipc	ra,0xffffc
    800043cc:	174080e7          	jalr	372(ra) # 8000053c <panic>
      b->dev = dev;
    800043d0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800043d4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800043d8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800043dc:	4785                	li	a5,1
    800043de:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800043e0:	00015517          	auipc	a0,0x15
    800043e4:	9b850513          	addi	a0,a0,-1608 # 80018d98 <bcache>
    800043e8:	ffffd097          	auipc	ra,0xffffd
    800043ec:	8ae080e7          	jalr	-1874(ra) # 80000c96 <release>
      acquiresleep(&b->lock);
    800043f0:	01048513          	addi	a0,s1,16
    800043f4:	00001097          	auipc	ra,0x1
    800043f8:	408080e7          	jalr	1032(ra) # 800057fc <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800043fc:	409c                	lw	a5,0(s1)
    800043fe:	cb89                	beqz	a5,80004410 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80004400:	8526                	mv	a0,s1
    80004402:	70a2                	ld	ra,40(sp)
    80004404:	7402                	ld	s0,32(sp)
    80004406:	64e2                	ld	s1,24(sp)
    80004408:	6942                	ld	s2,16(sp)
    8000440a:	69a2                	ld	s3,8(sp)
    8000440c:	6145                	addi	sp,sp,48
    8000440e:	8082                	ret
    virtio_disk_rw(b, 0);
    80004410:	4581                	li	a1,0
    80004412:	8526                	mv	a0,s1
    80004414:	00003097          	auipc	ra,0x3
    80004418:	f12080e7          	jalr	-238(ra) # 80007326 <virtio_disk_rw>
    b->valid = 1;
    8000441c:	4785                	li	a5,1
    8000441e:	c09c                	sw	a5,0(s1)
  return b;
    80004420:	b7c5                	j	80004400 <bread+0xd0>

0000000080004422 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004422:	1101                	addi	sp,sp,-32
    80004424:	ec06                	sd	ra,24(sp)
    80004426:	e822                	sd	s0,16(sp)
    80004428:	e426                	sd	s1,8(sp)
    8000442a:	1000                	addi	s0,sp,32
    8000442c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000442e:	0541                	addi	a0,a0,16
    80004430:	00001097          	auipc	ra,0x1
    80004434:	466080e7          	jalr	1126(ra) # 80005896 <holdingsleep>
    80004438:	cd01                	beqz	a0,80004450 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000443a:	4585                	li	a1,1
    8000443c:	8526                	mv	a0,s1
    8000443e:	00003097          	auipc	ra,0x3
    80004442:	ee8080e7          	jalr	-280(ra) # 80007326 <virtio_disk_rw>
}
    80004446:	60e2                	ld	ra,24(sp)
    80004448:	6442                	ld	s0,16(sp)
    8000444a:	64a2                	ld	s1,8(sp)
    8000444c:	6105                	addi	sp,sp,32
    8000444e:	8082                	ret
    panic("bwrite");
    80004450:	00005517          	auipc	a0,0x5
    80004454:	3b850513          	addi	a0,a0,952 # 80009808 <syscalls+0x1c8>
    80004458:	ffffc097          	auipc	ra,0xffffc
    8000445c:	0e4080e7          	jalr	228(ra) # 8000053c <panic>

0000000080004460 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004460:	1101                	addi	sp,sp,-32
    80004462:	ec06                	sd	ra,24(sp)
    80004464:	e822                	sd	s0,16(sp)
    80004466:	e426                	sd	s1,8(sp)
    80004468:	e04a                	sd	s2,0(sp)
    8000446a:	1000                	addi	s0,sp,32
    8000446c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000446e:	01050913          	addi	s2,a0,16
    80004472:	854a                	mv	a0,s2
    80004474:	00001097          	auipc	ra,0x1
    80004478:	422080e7          	jalr	1058(ra) # 80005896 <holdingsleep>
    8000447c:	c92d                	beqz	a0,800044ee <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000447e:	854a                	mv	a0,s2
    80004480:	00001097          	auipc	ra,0x1
    80004484:	3d2080e7          	jalr	978(ra) # 80005852 <releasesleep>

  acquire(&bcache.lock);
    80004488:	00015517          	auipc	a0,0x15
    8000448c:	91050513          	addi	a0,a0,-1776 # 80018d98 <bcache>
    80004490:	ffffc097          	auipc	ra,0xffffc
    80004494:	752080e7          	jalr	1874(ra) # 80000be2 <acquire>
  b->refcnt--;
    80004498:	40bc                	lw	a5,64(s1)
    8000449a:	37fd                	addiw	a5,a5,-1
    8000449c:	0007871b          	sext.w	a4,a5
    800044a0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800044a2:	eb05                	bnez	a4,800044d2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800044a4:	68bc                	ld	a5,80(s1)
    800044a6:	64b8                	ld	a4,72(s1)
    800044a8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800044aa:	64bc                	ld	a5,72(s1)
    800044ac:	68b8                	ld	a4,80(s1)
    800044ae:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800044b0:	0001d797          	auipc	a5,0x1d
    800044b4:	8e878793          	addi	a5,a5,-1816 # 80020d98 <bcache+0x8000>
    800044b8:	2b87b703          	ld	a4,696(a5)
    800044bc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800044be:	0001d717          	auipc	a4,0x1d
    800044c2:	b4270713          	addi	a4,a4,-1214 # 80021000 <bcache+0x8268>
    800044c6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800044c8:	2b87b703          	ld	a4,696(a5)
    800044cc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800044ce:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800044d2:	00015517          	auipc	a0,0x15
    800044d6:	8c650513          	addi	a0,a0,-1850 # 80018d98 <bcache>
    800044da:	ffffc097          	auipc	ra,0xffffc
    800044de:	7bc080e7          	jalr	1980(ra) # 80000c96 <release>
}
    800044e2:	60e2                	ld	ra,24(sp)
    800044e4:	6442                	ld	s0,16(sp)
    800044e6:	64a2                	ld	s1,8(sp)
    800044e8:	6902                	ld	s2,0(sp)
    800044ea:	6105                	addi	sp,sp,32
    800044ec:	8082                	ret
    panic("brelse");
    800044ee:	00005517          	auipc	a0,0x5
    800044f2:	32250513          	addi	a0,a0,802 # 80009810 <syscalls+0x1d0>
    800044f6:	ffffc097          	auipc	ra,0xffffc
    800044fa:	046080e7          	jalr	70(ra) # 8000053c <panic>

00000000800044fe <bpin>:

void
bpin(struct buf *b) {
    800044fe:	1101                	addi	sp,sp,-32
    80004500:	ec06                	sd	ra,24(sp)
    80004502:	e822                	sd	s0,16(sp)
    80004504:	e426                	sd	s1,8(sp)
    80004506:	1000                	addi	s0,sp,32
    80004508:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000450a:	00015517          	auipc	a0,0x15
    8000450e:	88e50513          	addi	a0,a0,-1906 # 80018d98 <bcache>
    80004512:	ffffc097          	auipc	ra,0xffffc
    80004516:	6d0080e7          	jalr	1744(ra) # 80000be2 <acquire>
  b->refcnt++;
    8000451a:	40bc                	lw	a5,64(s1)
    8000451c:	2785                	addiw	a5,a5,1
    8000451e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004520:	00015517          	auipc	a0,0x15
    80004524:	87850513          	addi	a0,a0,-1928 # 80018d98 <bcache>
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	76e080e7          	jalr	1902(ra) # 80000c96 <release>
}
    80004530:	60e2                	ld	ra,24(sp)
    80004532:	6442                	ld	s0,16(sp)
    80004534:	64a2                	ld	s1,8(sp)
    80004536:	6105                	addi	sp,sp,32
    80004538:	8082                	ret

000000008000453a <bunpin>:

void
bunpin(struct buf *b) {
    8000453a:	1101                	addi	sp,sp,-32
    8000453c:	ec06                	sd	ra,24(sp)
    8000453e:	e822                	sd	s0,16(sp)
    80004540:	e426                	sd	s1,8(sp)
    80004542:	1000                	addi	s0,sp,32
    80004544:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004546:	00015517          	auipc	a0,0x15
    8000454a:	85250513          	addi	a0,a0,-1966 # 80018d98 <bcache>
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	694080e7          	jalr	1684(ra) # 80000be2 <acquire>
  b->refcnt--;
    80004556:	40bc                	lw	a5,64(s1)
    80004558:	37fd                	addiw	a5,a5,-1
    8000455a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000455c:	00015517          	auipc	a0,0x15
    80004560:	83c50513          	addi	a0,a0,-1988 # 80018d98 <bcache>
    80004564:	ffffc097          	auipc	ra,0xffffc
    80004568:	732080e7          	jalr	1842(ra) # 80000c96 <release>
}
    8000456c:	60e2                	ld	ra,24(sp)
    8000456e:	6442                	ld	s0,16(sp)
    80004570:	64a2                	ld	s1,8(sp)
    80004572:	6105                	addi	sp,sp,32
    80004574:	8082                	ret

0000000080004576 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004576:	1101                	addi	sp,sp,-32
    80004578:	ec06                	sd	ra,24(sp)
    8000457a:	e822                	sd	s0,16(sp)
    8000457c:	e426                	sd	s1,8(sp)
    8000457e:	e04a                	sd	s2,0(sp)
    80004580:	1000                	addi	s0,sp,32
    80004582:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004584:	00d5d59b          	srliw	a1,a1,0xd
    80004588:	0001d797          	auipc	a5,0x1d
    8000458c:	eec7a783          	lw	a5,-276(a5) # 80021474 <sb+0x1c>
    80004590:	9dbd                	addw	a1,a1,a5
    80004592:	00000097          	auipc	ra,0x0
    80004596:	d9e080e7          	jalr	-610(ra) # 80004330 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000459a:	0074f713          	andi	a4,s1,7
    8000459e:	4785                	li	a5,1
    800045a0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800045a4:	14ce                	slli	s1,s1,0x33
    800045a6:	90d9                	srli	s1,s1,0x36
    800045a8:	00950733          	add	a4,a0,s1
    800045ac:	05874703          	lbu	a4,88(a4)
    800045b0:	00e7f6b3          	and	a3,a5,a4
    800045b4:	c69d                	beqz	a3,800045e2 <bfree+0x6c>
    800045b6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800045b8:	94aa                	add	s1,s1,a0
    800045ba:	fff7c793          	not	a5,a5
    800045be:	8ff9                	and	a5,a5,a4
    800045c0:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800045c4:	00001097          	auipc	ra,0x1
    800045c8:	118080e7          	jalr	280(ra) # 800056dc <log_write>
  brelse(bp);
    800045cc:	854a                	mv	a0,s2
    800045ce:	00000097          	auipc	ra,0x0
    800045d2:	e92080e7          	jalr	-366(ra) # 80004460 <brelse>
}
    800045d6:	60e2                	ld	ra,24(sp)
    800045d8:	6442                	ld	s0,16(sp)
    800045da:	64a2                	ld	s1,8(sp)
    800045dc:	6902                	ld	s2,0(sp)
    800045de:	6105                	addi	sp,sp,32
    800045e0:	8082                	ret
    panic("freeing free block");
    800045e2:	00005517          	auipc	a0,0x5
    800045e6:	23650513          	addi	a0,a0,566 # 80009818 <syscalls+0x1d8>
    800045ea:	ffffc097          	auipc	ra,0xffffc
    800045ee:	f52080e7          	jalr	-174(ra) # 8000053c <panic>

00000000800045f2 <balloc>:
{
    800045f2:	711d                	addi	sp,sp,-96
    800045f4:	ec86                	sd	ra,88(sp)
    800045f6:	e8a2                	sd	s0,80(sp)
    800045f8:	e4a6                	sd	s1,72(sp)
    800045fa:	e0ca                	sd	s2,64(sp)
    800045fc:	fc4e                	sd	s3,56(sp)
    800045fe:	f852                	sd	s4,48(sp)
    80004600:	f456                	sd	s5,40(sp)
    80004602:	f05a                	sd	s6,32(sp)
    80004604:	ec5e                	sd	s7,24(sp)
    80004606:	e862                	sd	s8,16(sp)
    80004608:	e466                	sd	s9,8(sp)
    8000460a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000460c:	0001d797          	auipc	a5,0x1d
    80004610:	e507a783          	lw	a5,-432(a5) # 8002145c <sb+0x4>
    80004614:	cbd1                	beqz	a5,800046a8 <balloc+0xb6>
    80004616:	8baa                	mv	s7,a0
    80004618:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000461a:	0001db17          	auipc	s6,0x1d
    8000461e:	e3eb0b13          	addi	s6,s6,-450 # 80021458 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004622:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80004624:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004626:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004628:	6c89                	lui	s9,0x2
    8000462a:	a831                	j	80004646 <balloc+0x54>
    brelse(bp);
    8000462c:	854a                	mv	a0,s2
    8000462e:	00000097          	auipc	ra,0x0
    80004632:	e32080e7          	jalr	-462(ra) # 80004460 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004636:	015c87bb          	addw	a5,s9,s5
    8000463a:	00078a9b          	sext.w	s5,a5
    8000463e:	004b2703          	lw	a4,4(s6)
    80004642:	06eaf363          	bgeu	s5,a4,800046a8 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80004646:	41fad79b          	sraiw	a5,s5,0x1f
    8000464a:	0137d79b          	srliw	a5,a5,0x13
    8000464e:	015787bb          	addw	a5,a5,s5
    80004652:	40d7d79b          	sraiw	a5,a5,0xd
    80004656:	01cb2583          	lw	a1,28(s6)
    8000465a:	9dbd                	addw	a1,a1,a5
    8000465c:	855e                	mv	a0,s7
    8000465e:	00000097          	auipc	ra,0x0
    80004662:	cd2080e7          	jalr	-814(ra) # 80004330 <bread>
    80004666:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004668:	004b2503          	lw	a0,4(s6)
    8000466c:	000a849b          	sext.w	s1,s5
    80004670:	8662                	mv	a2,s8
    80004672:	faa4fde3          	bgeu	s1,a0,8000462c <balloc+0x3a>
      m = 1 << (bi % 8);
    80004676:	41f6579b          	sraiw	a5,a2,0x1f
    8000467a:	01d7d69b          	srliw	a3,a5,0x1d
    8000467e:	00c6873b          	addw	a4,a3,a2
    80004682:	00777793          	andi	a5,a4,7
    80004686:	9f95                	subw	a5,a5,a3
    80004688:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000468c:	4037571b          	sraiw	a4,a4,0x3
    80004690:	00e906b3          	add	a3,s2,a4
    80004694:	0586c683          	lbu	a3,88(a3)
    80004698:	00d7f5b3          	and	a1,a5,a3
    8000469c:	cd91                	beqz	a1,800046b8 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000469e:	2605                	addiw	a2,a2,1
    800046a0:	2485                	addiw	s1,s1,1
    800046a2:	fd4618e3          	bne	a2,s4,80004672 <balloc+0x80>
    800046a6:	b759                	j	8000462c <balloc+0x3a>
  panic("balloc: out of blocks");
    800046a8:	00005517          	auipc	a0,0x5
    800046ac:	18850513          	addi	a0,a0,392 # 80009830 <syscalls+0x1f0>
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	e8c080e7          	jalr	-372(ra) # 8000053c <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800046b8:	974a                	add	a4,a4,s2
    800046ba:	8fd5                	or	a5,a5,a3
    800046bc:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800046c0:	854a                	mv	a0,s2
    800046c2:	00001097          	auipc	ra,0x1
    800046c6:	01a080e7          	jalr	26(ra) # 800056dc <log_write>
        brelse(bp);
    800046ca:	854a                	mv	a0,s2
    800046cc:	00000097          	auipc	ra,0x0
    800046d0:	d94080e7          	jalr	-620(ra) # 80004460 <brelse>
  bp = bread(dev, bno);
    800046d4:	85a6                	mv	a1,s1
    800046d6:	855e                	mv	a0,s7
    800046d8:	00000097          	auipc	ra,0x0
    800046dc:	c58080e7          	jalr	-936(ra) # 80004330 <bread>
    800046e0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800046e2:	40000613          	li	a2,1024
    800046e6:	4581                	li	a1,0
    800046e8:	05850513          	addi	a0,a0,88
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	5f2080e7          	jalr	1522(ra) # 80000cde <memset>
  log_write(bp);
    800046f4:	854a                	mv	a0,s2
    800046f6:	00001097          	auipc	ra,0x1
    800046fa:	fe6080e7          	jalr	-26(ra) # 800056dc <log_write>
  brelse(bp);
    800046fe:	854a                	mv	a0,s2
    80004700:	00000097          	auipc	ra,0x0
    80004704:	d60080e7          	jalr	-672(ra) # 80004460 <brelse>
}
    80004708:	8526                	mv	a0,s1
    8000470a:	60e6                	ld	ra,88(sp)
    8000470c:	6446                	ld	s0,80(sp)
    8000470e:	64a6                	ld	s1,72(sp)
    80004710:	6906                	ld	s2,64(sp)
    80004712:	79e2                	ld	s3,56(sp)
    80004714:	7a42                	ld	s4,48(sp)
    80004716:	7aa2                	ld	s5,40(sp)
    80004718:	7b02                	ld	s6,32(sp)
    8000471a:	6be2                	ld	s7,24(sp)
    8000471c:	6c42                	ld	s8,16(sp)
    8000471e:	6ca2                	ld	s9,8(sp)
    80004720:	6125                	addi	sp,sp,96
    80004722:	8082                	ret

0000000080004724 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004724:	7179                	addi	sp,sp,-48
    80004726:	f406                	sd	ra,40(sp)
    80004728:	f022                	sd	s0,32(sp)
    8000472a:	ec26                	sd	s1,24(sp)
    8000472c:	e84a                	sd	s2,16(sp)
    8000472e:	e44e                	sd	s3,8(sp)
    80004730:	e052                	sd	s4,0(sp)
    80004732:	1800                	addi	s0,sp,48
    80004734:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004736:	47ad                	li	a5,11
    80004738:	04b7fe63          	bgeu	a5,a1,80004794 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000473c:	ff45849b          	addiw	s1,a1,-12
    80004740:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004744:	0ff00793          	li	a5,255
    80004748:	0ae7e363          	bltu	a5,a4,800047ee <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000474c:	08052583          	lw	a1,128(a0)
    80004750:	c5ad                	beqz	a1,800047ba <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004752:	00092503          	lw	a0,0(s2)
    80004756:	00000097          	auipc	ra,0x0
    8000475a:	bda080e7          	jalr	-1062(ra) # 80004330 <bread>
    8000475e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004760:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004764:	02049593          	slli	a1,s1,0x20
    80004768:	9181                	srli	a1,a1,0x20
    8000476a:	058a                	slli	a1,a1,0x2
    8000476c:	00b784b3          	add	s1,a5,a1
    80004770:	0004a983          	lw	s3,0(s1)
    80004774:	04098d63          	beqz	s3,800047ce <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004778:	8552                	mv	a0,s4
    8000477a:	00000097          	auipc	ra,0x0
    8000477e:	ce6080e7          	jalr	-794(ra) # 80004460 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80004782:	854e                	mv	a0,s3
    80004784:	70a2                	ld	ra,40(sp)
    80004786:	7402                	ld	s0,32(sp)
    80004788:	64e2                	ld	s1,24(sp)
    8000478a:	6942                	ld	s2,16(sp)
    8000478c:	69a2                	ld	s3,8(sp)
    8000478e:	6a02                	ld	s4,0(sp)
    80004790:	6145                	addi	sp,sp,48
    80004792:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80004794:	02059493          	slli	s1,a1,0x20
    80004798:	9081                	srli	s1,s1,0x20
    8000479a:	048a                	slli	s1,s1,0x2
    8000479c:	94aa                	add	s1,s1,a0
    8000479e:	0504a983          	lw	s3,80(s1)
    800047a2:	fe0990e3          	bnez	s3,80004782 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800047a6:	4108                	lw	a0,0(a0)
    800047a8:	00000097          	auipc	ra,0x0
    800047ac:	e4a080e7          	jalr	-438(ra) # 800045f2 <balloc>
    800047b0:	0005099b          	sext.w	s3,a0
    800047b4:	0534a823          	sw	s3,80(s1)
    800047b8:	b7e9                	j	80004782 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800047ba:	4108                	lw	a0,0(a0)
    800047bc:	00000097          	auipc	ra,0x0
    800047c0:	e36080e7          	jalr	-458(ra) # 800045f2 <balloc>
    800047c4:	0005059b          	sext.w	a1,a0
    800047c8:	08b92023          	sw	a1,128(s2)
    800047cc:	b759                	j	80004752 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800047ce:	00092503          	lw	a0,0(s2)
    800047d2:	00000097          	auipc	ra,0x0
    800047d6:	e20080e7          	jalr	-480(ra) # 800045f2 <balloc>
    800047da:	0005099b          	sext.w	s3,a0
    800047de:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800047e2:	8552                	mv	a0,s4
    800047e4:	00001097          	auipc	ra,0x1
    800047e8:	ef8080e7          	jalr	-264(ra) # 800056dc <log_write>
    800047ec:	b771                	j	80004778 <bmap+0x54>
  panic("bmap: out of range");
    800047ee:	00005517          	auipc	a0,0x5
    800047f2:	05a50513          	addi	a0,a0,90 # 80009848 <syscalls+0x208>
    800047f6:	ffffc097          	auipc	ra,0xffffc
    800047fa:	d46080e7          	jalr	-698(ra) # 8000053c <panic>

00000000800047fe <iget>:
{
    800047fe:	7179                	addi	sp,sp,-48
    80004800:	f406                	sd	ra,40(sp)
    80004802:	f022                	sd	s0,32(sp)
    80004804:	ec26                	sd	s1,24(sp)
    80004806:	e84a                	sd	s2,16(sp)
    80004808:	e44e                	sd	s3,8(sp)
    8000480a:	e052                	sd	s4,0(sp)
    8000480c:	1800                	addi	s0,sp,48
    8000480e:	89aa                	mv	s3,a0
    80004810:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80004812:	0001d517          	auipc	a0,0x1d
    80004816:	c6650513          	addi	a0,a0,-922 # 80021478 <itable>
    8000481a:	ffffc097          	auipc	ra,0xffffc
    8000481e:	3c8080e7          	jalr	968(ra) # 80000be2 <acquire>
  empty = 0;
    80004822:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004824:	0001d497          	auipc	s1,0x1d
    80004828:	c6c48493          	addi	s1,s1,-916 # 80021490 <itable+0x18>
    8000482c:	0001e697          	auipc	a3,0x1e
    80004830:	6f468693          	addi	a3,a3,1780 # 80022f20 <log>
    80004834:	a039                	j	80004842 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004836:	02090b63          	beqz	s2,8000486c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000483a:	08848493          	addi	s1,s1,136
    8000483e:	02d48a63          	beq	s1,a3,80004872 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004842:	449c                	lw	a5,8(s1)
    80004844:	fef059e3          	blez	a5,80004836 <iget+0x38>
    80004848:	4098                	lw	a4,0(s1)
    8000484a:	ff3716e3          	bne	a4,s3,80004836 <iget+0x38>
    8000484e:	40d8                	lw	a4,4(s1)
    80004850:	ff4713e3          	bne	a4,s4,80004836 <iget+0x38>
      ip->ref++;
    80004854:	2785                	addiw	a5,a5,1
    80004856:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004858:	0001d517          	auipc	a0,0x1d
    8000485c:	c2050513          	addi	a0,a0,-992 # 80021478 <itable>
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	436080e7          	jalr	1078(ra) # 80000c96 <release>
      return ip;
    80004868:	8926                	mv	s2,s1
    8000486a:	a03d                	j	80004898 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000486c:	f7f9                	bnez	a5,8000483a <iget+0x3c>
    8000486e:	8926                	mv	s2,s1
    80004870:	b7e9                	j	8000483a <iget+0x3c>
  if(empty == 0)
    80004872:	02090c63          	beqz	s2,800048aa <iget+0xac>
  ip->dev = dev;
    80004876:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000487a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000487e:	4785                	li	a5,1
    80004880:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004884:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004888:	0001d517          	auipc	a0,0x1d
    8000488c:	bf050513          	addi	a0,a0,-1040 # 80021478 <itable>
    80004890:	ffffc097          	auipc	ra,0xffffc
    80004894:	406080e7          	jalr	1030(ra) # 80000c96 <release>
}
    80004898:	854a                	mv	a0,s2
    8000489a:	70a2                	ld	ra,40(sp)
    8000489c:	7402                	ld	s0,32(sp)
    8000489e:	64e2                	ld	s1,24(sp)
    800048a0:	6942                	ld	s2,16(sp)
    800048a2:	69a2                	ld	s3,8(sp)
    800048a4:	6a02                	ld	s4,0(sp)
    800048a6:	6145                	addi	sp,sp,48
    800048a8:	8082                	ret
    panic("iget: no inodes");
    800048aa:	00005517          	auipc	a0,0x5
    800048ae:	fb650513          	addi	a0,a0,-74 # 80009860 <syscalls+0x220>
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	c8a080e7          	jalr	-886(ra) # 8000053c <panic>

00000000800048ba <fsinit>:
fsinit(int dev) {
    800048ba:	7179                	addi	sp,sp,-48
    800048bc:	f406                	sd	ra,40(sp)
    800048be:	f022                	sd	s0,32(sp)
    800048c0:	ec26                	sd	s1,24(sp)
    800048c2:	e84a                	sd	s2,16(sp)
    800048c4:	e44e                	sd	s3,8(sp)
    800048c6:	1800                	addi	s0,sp,48
    800048c8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800048ca:	4585                	li	a1,1
    800048cc:	00000097          	auipc	ra,0x0
    800048d0:	a64080e7          	jalr	-1436(ra) # 80004330 <bread>
    800048d4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800048d6:	0001d997          	auipc	s3,0x1d
    800048da:	b8298993          	addi	s3,s3,-1150 # 80021458 <sb>
    800048de:	02000613          	li	a2,32
    800048e2:	05850593          	addi	a1,a0,88
    800048e6:	854e                	mv	a0,s3
    800048e8:	ffffc097          	auipc	ra,0xffffc
    800048ec:	456080e7          	jalr	1110(ra) # 80000d3e <memmove>
  brelse(bp);
    800048f0:	8526                	mv	a0,s1
    800048f2:	00000097          	auipc	ra,0x0
    800048f6:	b6e080e7          	jalr	-1170(ra) # 80004460 <brelse>
  if(sb.magic != FSMAGIC)
    800048fa:	0009a703          	lw	a4,0(s3)
    800048fe:	102037b7          	lui	a5,0x10203
    80004902:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004906:	02f71263          	bne	a4,a5,8000492a <fsinit+0x70>
  initlog(dev, &sb);
    8000490a:	0001d597          	auipc	a1,0x1d
    8000490e:	b4e58593          	addi	a1,a1,-1202 # 80021458 <sb>
    80004912:	854a                	mv	a0,s2
    80004914:	00001097          	auipc	ra,0x1
    80004918:	b4c080e7          	jalr	-1204(ra) # 80005460 <initlog>
}
    8000491c:	70a2                	ld	ra,40(sp)
    8000491e:	7402                	ld	s0,32(sp)
    80004920:	64e2                	ld	s1,24(sp)
    80004922:	6942                	ld	s2,16(sp)
    80004924:	69a2                	ld	s3,8(sp)
    80004926:	6145                	addi	sp,sp,48
    80004928:	8082                	ret
    panic("invalid file system");
    8000492a:	00005517          	auipc	a0,0x5
    8000492e:	f4650513          	addi	a0,a0,-186 # 80009870 <syscalls+0x230>
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	c0a080e7          	jalr	-1014(ra) # 8000053c <panic>

000000008000493a <iinit>:
{
    8000493a:	7179                	addi	sp,sp,-48
    8000493c:	f406                	sd	ra,40(sp)
    8000493e:	f022                	sd	s0,32(sp)
    80004940:	ec26                	sd	s1,24(sp)
    80004942:	e84a                	sd	s2,16(sp)
    80004944:	e44e                	sd	s3,8(sp)
    80004946:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004948:	00005597          	auipc	a1,0x5
    8000494c:	f4058593          	addi	a1,a1,-192 # 80009888 <syscalls+0x248>
    80004950:	0001d517          	auipc	a0,0x1d
    80004954:	b2850513          	addi	a0,a0,-1240 # 80021478 <itable>
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	1fa080e7          	jalr	506(ra) # 80000b52 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004960:	0001d497          	auipc	s1,0x1d
    80004964:	b4048493          	addi	s1,s1,-1216 # 800214a0 <itable+0x28>
    80004968:	0001e997          	auipc	s3,0x1e
    8000496c:	5c898993          	addi	s3,s3,1480 # 80022f30 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80004970:	00005917          	auipc	s2,0x5
    80004974:	f2090913          	addi	s2,s2,-224 # 80009890 <syscalls+0x250>
    80004978:	85ca                	mv	a1,s2
    8000497a:	8526                	mv	a0,s1
    8000497c:	00001097          	auipc	ra,0x1
    80004980:	e46080e7          	jalr	-442(ra) # 800057c2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004984:	08848493          	addi	s1,s1,136
    80004988:	ff3498e3          	bne	s1,s3,80004978 <iinit+0x3e>
}
    8000498c:	70a2                	ld	ra,40(sp)
    8000498e:	7402                	ld	s0,32(sp)
    80004990:	64e2                	ld	s1,24(sp)
    80004992:	6942                	ld	s2,16(sp)
    80004994:	69a2                	ld	s3,8(sp)
    80004996:	6145                	addi	sp,sp,48
    80004998:	8082                	ret

000000008000499a <ialloc>:
{
    8000499a:	715d                	addi	sp,sp,-80
    8000499c:	e486                	sd	ra,72(sp)
    8000499e:	e0a2                	sd	s0,64(sp)
    800049a0:	fc26                	sd	s1,56(sp)
    800049a2:	f84a                	sd	s2,48(sp)
    800049a4:	f44e                	sd	s3,40(sp)
    800049a6:	f052                	sd	s4,32(sp)
    800049a8:	ec56                	sd	s5,24(sp)
    800049aa:	e85a                	sd	s6,16(sp)
    800049ac:	e45e                	sd	s7,8(sp)
    800049ae:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800049b0:	0001d717          	auipc	a4,0x1d
    800049b4:	ab472703          	lw	a4,-1356(a4) # 80021464 <sb+0xc>
    800049b8:	4785                	li	a5,1
    800049ba:	04e7fa63          	bgeu	a5,a4,80004a0e <ialloc+0x74>
    800049be:	8aaa                	mv	s5,a0
    800049c0:	8bae                	mv	s7,a1
    800049c2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800049c4:	0001da17          	auipc	s4,0x1d
    800049c8:	a94a0a13          	addi	s4,s4,-1388 # 80021458 <sb>
    800049cc:	00048b1b          	sext.w	s6,s1
    800049d0:	0044d593          	srli	a1,s1,0x4
    800049d4:	018a2783          	lw	a5,24(s4)
    800049d8:	9dbd                	addw	a1,a1,a5
    800049da:	8556                	mv	a0,s5
    800049dc:	00000097          	auipc	ra,0x0
    800049e0:	954080e7          	jalr	-1708(ra) # 80004330 <bread>
    800049e4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800049e6:	05850993          	addi	s3,a0,88
    800049ea:	00f4f793          	andi	a5,s1,15
    800049ee:	079a                	slli	a5,a5,0x6
    800049f0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800049f2:	00099783          	lh	a5,0(s3)
    800049f6:	c785                	beqz	a5,80004a1e <ialloc+0x84>
    brelse(bp);
    800049f8:	00000097          	auipc	ra,0x0
    800049fc:	a68080e7          	jalr	-1432(ra) # 80004460 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004a00:	0485                	addi	s1,s1,1
    80004a02:	00ca2703          	lw	a4,12(s4)
    80004a06:	0004879b          	sext.w	a5,s1
    80004a0a:	fce7e1e3          	bltu	a5,a4,800049cc <ialloc+0x32>
  panic("ialloc: no inodes");
    80004a0e:	00005517          	auipc	a0,0x5
    80004a12:	e8a50513          	addi	a0,a0,-374 # 80009898 <syscalls+0x258>
    80004a16:	ffffc097          	auipc	ra,0xffffc
    80004a1a:	b26080e7          	jalr	-1242(ra) # 8000053c <panic>
      memset(dip, 0, sizeof(*dip));
    80004a1e:	04000613          	li	a2,64
    80004a22:	4581                	li	a1,0
    80004a24:	854e                	mv	a0,s3
    80004a26:	ffffc097          	auipc	ra,0xffffc
    80004a2a:	2b8080e7          	jalr	696(ra) # 80000cde <memset>
      dip->type = type;
    80004a2e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004a32:	854a                	mv	a0,s2
    80004a34:	00001097          	auipc	ra,0x1
    80004a38:	ca8080e7          	jalr	-856(ra) # 800056dc <log_write>
      brelse(bp);
    80004a3c:	854a                	mv	a0,s2
    80004a3e:	00000097          	auipc	ra,0x0
    80004a42:	a22080e7          	jalr	-1502(ra) # 80004460 <brelse>
      return iget(dev, inum);
    80004a46:	85da                	mv	a1,s6
    80004a48:	8556                	mv	a0,s5
    80004a4a:	00000097          	auipc	ra,0x0
    80004a4e:	db4080e7          	jalr	-588(ra) # 800047fe <iget>
}
    80004a52:	60a6                	ld	ra,72(sp)
    80004a54:	6406                	ld	s0,64(sp)
    80004a56:	74e2                	ld	s1,56(sp)
    80004a58:	7942                	ld	s2,48(sp)
    80004a5a:	79a2                	ld	s3,40(sp)
    80004a5c:	7a02                	ld	s4,32(sp)
    80004a5e:	6ae2                	ld	s5,24(sp)
    80004a60:	6b42                	ld	s6,16(sp)
    80004a62:	6ba2                	ld	s7,8(sp)
    80004a64:	6161                	addi	sp,sp,80
    80004a66:	8082                	ret

0000000080004a68 <iupdate>:
{
    80004a68:	1101                	addi	sp,sp,-32
    80004a6a:	ec06                	sd	ra,24(sp)
    80004a6c:	e822                	sd	s0,16(sp)
    80004a6e:	e426                	sd	s1,8(sp)
    80004a70:	e04a                	sd	s2,0(sp)
    80004a72:	1000                	addi	s0,sp,32
    80004a74:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004a76:	415c                	lw	a5,4(a0)
    80004a78:	0047d79b          	srliw	a5,a5,0x4
    80004a7c:	0001d597          	auipc	a1,0x1d
    80004a80:	9f45a583          	lw	a1,-1548(a1) # 80021470 <sb+0x18>
    80004a84:	9dbd                	addw	a1,a1,a5
    80004a86:	4108                	lw	a0,0(a0)
    80004a88:	00000097          	auipc	ra,0x0
    80004a8c:	8a8080e7          	jalr	-1880(ra) # 80004330 <bread>
    80004a90:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004a92:	05850793          	addi	a5,a0,88
    80004a96:	40c8                	lw	a0,4(s1)
    80004a98:	893d                	andi	a0,a0,15
    80004a9a:	051a                	slli	a0,a0,0x6
    80004a9c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80004a9e:	04449703          	lh	a4,68(s1)
    80004aa2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80004aa6:	04649703          	lh	a4,70(s1)
    80004aaa:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80004aae:	04849703          	lh	a4,72(s1)
    80004ab2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80004ab6:	04a49703          	lh	a4,74(s1)
    80004aba:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80004abe:	44f8                	lw	a4,76(s1)
    80004ac0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004ac2:	03400613          	li	a2,52
    80004ac6:	05048593          	addi	a1,s1,80
    80004aca:	0531                	addi	a0,a0,12
    80004acc:	ffffc097          	auipc	ra,0xffffc
    80004ad0:	272080e7          	jalr	626(ra) # 80000d3e <memmove>
  log_write(bp);
    80004ad4:	854a                	mv	a0,s2
    80004ad6:	00001097          	auipc	ra,0x1
    80004ada:	c06080e7          	jalr	-1018(ra) # 800056dc <log_write>
  brelse(bp);
    80004ade:	854a                	mv	a0,s2
    80004ae0:	00000097          	auipc	ra,0x0
    80004ae4:	980080e7          	jalr	-1664(ra) # 80004460 <brelse>
}
    80004ae8:	60e2                	ld	ra,24(sp)
    80004aea:	6442                	ld	s0,16(sp)
    80004aec:	64a2                	ld	s1,8(sp)
    80004aee:	6902                	ld	s2,0(sp)
    80004af0:	6105                	addi	sp,sp,32
    80004af2:	8082                	ret

0000000080004af4 <idup>:
{
    80004af4:	1101                	addi	sp,sp,-32
    80004af6:	ec06                	sd	ra,24(sp)
    80004af8:	e822                	sd	s0,16(sp)
    80004afa:	e426                	sd	s1,8(sp)
    80004afc:	1000                	addi	s0,sp,32
    80004afe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004b00:	0001d517          	auipc	a0,0x1d
    80004b04:	97850513          	addi	a0,a0,-1672 # 80021478 <itable>
    80004b08:	ffffc097          	auipc	ra,0xffffc
    80004b0c:	0da080e7          	jalr	218(ra) # 80000be2 <acquire>
  ip->ref++;
    80004b10:	449c                	lw	a5,8(s1)
    80004b12:	2785                	addiw	a5,a5,1
    80004b14:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004b16:	0001d517          	auipc	a0,0x1d
    80004b1a:	96250513          	addi	a0,a0,-1694 # 80021478 <itable>
    80004b1e:	ffffc097          	auipc	ra,0xffffc
    80004b22:	178080e7          	jalr	376(ra) # 80000c96 <release>
}
    80004b26:	8526                	mv	a0,s1
    80004b28:	60e2                	ld	ra,24(sp)
    80004b2a:	6442                	ld	s0,16(sp)
    80004b2c:	64a2                	ld	s1,8(sp)
    80004b2e:	6105                	addi	sp,sp,32
    80004b30:	8082                	ret

0000000080004b32 <ilock>:
{
    80004b32:	1101                	addi	sp,sp,-32
    80004b34:	ec06                	sd	ra,24(sp)
    80004b36:	e822                	sd	s0,16(sp)
    80004b38:	e426                	sd	s1,8(sp)
    80004b3a:	e04a                	sd	s2,0(sp)
    80004b3c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004b3e:	c115                	beqz	a0,80004b62 <ilock+0x30>
    80004b40:	84aa                	mv	s1,a0
    80004b42:	451c                	lw	a5,8(a0)
    80004b44:	00f05f63          	blez	a5,80004b62 <ilock+0x30>
  acquiresleep(&ip->lock);
    80004b48:	0541                	addi	a0,a0,16
    80004b4a:	00001097          	auipc	ra,0x1
    80004b4e:	cb2080e7          	jalr	-846(ra) # 800057fc <acquiresleep>
  if(ip->valid == 0){
    80004b52:	40bc                	lw	a5,64(s1)
    80004b54:	cf99                	beqz	a5,80004b72 <ilock+0x40>
}
    80004b56:	60e2                	ld	ra,24(sp)
    80004b58:	6442                	ld	s0,16(sp)
    80004b5a:	64a2                	ld	s1,8(sp)
    80004b5c:	6902                	ld	s2,0(sp)
    80004b5e:	6105                	addi	sp,sp,32
    80004b60:	8082                	ret
    panic("ilock");
    80004b62:	00005517          	auipc	a0,0x5
    80004b66:	d4e50513          	addi	a0,a0,-690 # 800098b0 <syscalls+0x270>
    80004b6a:	ffffc097          	auipc	ra,0xffffc
    80004b6e:	9d2080e7          	jalr	-1582(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004b72:	40dc                	lw	a5,4(s1)
    80004b74:	0047d79b          	srliw	a5,a5,0x4
    80004b78:	0001d597          	auipc	a1,0x1d
    80004b7c:	8f85a583          	lw	a1,-1800(a1) # 80021470 <sb+0x18>
    80004b80:	9dbd                	addw	a1,a1,a5
    80004b82:	4088                	lw	a0,0(s1)
    80004b84:	fffff097          	auipc	ra,0xfffff
    80004b88:	7ac080e7          	jalr	1964(ra) # 80004330 <bread>
    80004b8c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004b8e:	05850593          	addi	a1,a0,88
    80004b92:	40dc                	lw	a5,4(s1)
    80004b94:	8bbd                	andi	a5,a5,15
    80004b96:	079a                	slli	a5,a5,0x6
    80004b98:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004b9a:	00059783          	lh	a5,0(a1)
    80004b9e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004ba2:	00259783          	lh	a5,2(a1)
    80004ba6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004baa:	00459783          	lh	a5,4(a1)
    80004bae:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004bb2:	00659783          	lh	a5,6(a1)
    80004bb6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004bba:	459c                	lw	a5,8(a1)
    80004bbc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004bbe:	03400613          	li	a2,52
    80004bc2:	05b1                	addi	a1,a1,12
    80004bc4:	05048513          	addi	a0,s1,80
    80004bc8:	ffffc097          	auipc	ra,0xffffc
    80004bcc:	176080e7          	jalr	374(ra) # 80000d3e <memmove>
    brelse(bp);
    80004bd0:	854a                	mv	a0,s2
    80004bd2:	00000097          	auipc	ra,0x0
    80004bd6:	88e080e7          	jalr	-1906(ra) # 80004460 <brelse>
    ip->valid = 1;
    80004bda:	4785                	li	a5,1
    80004bdc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004bde:	04449783          	lh	a5,68(s1)
    80004be2:	fbb5                	bnez	a5,80004b56 <ilock+0x24>
      panic("ilock: no type");
    80004be4:	00005517          	auipc	a0,0x5
    80004be8:	cd450513          	addi	a0,a0,-812 # 800098b8 <syscalls+0x278>
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	950080e7          	jalr	-1712(ra) # 8000053c <panic>

0000000080004bf4 <iunlock>:
{
    80004bf4:	1101                	addi	sp,sp,-32
    80004bf6:	ec06                	sd	ra,24(sp)
    80004bf8:	e822                	sd	s0,16(sp)
    80004bfa:	e426                	sd	s1,8(sp)
    80004bfc:	e04a                	sd	s2,0(sp)
    80004bfe:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004c00:	c905                	beqz	a0,80004c30 <iunlock+0x3c>
    80004c02:	84aa                	mv	s1,a0
    80004c04:	01050913          	addi	s2,a0,16
    80004c08:	854a                	mv	a0,s2
    80004c0a:	00001097          	auipc	ra,0x1
    80004c0e:	c8c080e7          	jalr	-884(ra) # 80005896 <holdingsleep>
    80004c12:	cd19                	beqz	a0,80004c30 <iunlock+0x3c>
    80004c14:	449c                	lw	a5,8(s1)
    80004c16:	00f05d63          	blez	a5,80004c30 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004c1a:	854a                	mv	a0,s2
    80004c1c:	00001097          	auipc	ra,0x1
    80004c20:	c36080e7          	jalr	-970(ra) # 80005852 <releasesleep>
}
    80004c24:	60e2                	ld	ra,24(sp)
    80004c26:	6442                	ld	s0,16(sp)
    80004c28:	64a2                	ld	s1,8(sp)
    80004c2a:	6902                	ld	s2,0(sp)
    80004c2c:	6105                	addi	sp,sp,32
    80004c2e:	8082                	ret
    panic("iunlock");
    80004c30:	00005517          	auipc	a0,0x5
    80004c34:	c9850513          	addi	a0,a0,-872 # 800098c8 <syscalls+0x288>
    80004c38:	ffffc097          	auipc	ra,0xffffc
    80004c3c:	904080e7          	jalr	-1788(ra) # 8000053c <panic>

0000000080004c40 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004c40:	7179                	addi	sp,sp,-48
    80004c42:	f406                	sd	ra,40(sp)
    80004c44:	f022                	sd	s0,32(sp)
    80004c46:	ec26                	sd	s1,24(sp)
    80004c48:	e84a                	sd	s2,16(sp)
    80004c4a:	e44e                	sd	s3,8(sp)
    80004c4c:	e052                	sd	s4,0(sp)
    80004c4e:	1800                	addi	s0,sp,48
    80004c50:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004c52:	05050493          	addi	s1,a0,80
    80004c56:	08050913          	addi	s2,a0,128
    80004c5a:	a021                	j	80004c62 <itrunc+0x22>
    80004c5c:	0491                	addi	s1,s1,4
    80004c5e:	01248d63          	beq	s1,s2,80004c78 <itrunc+0x38>
    if(ip->addrs[i]){
    80004c62:	408c                	lw	a1,0(s1)
    80004c64:	dde5                	beqz	a1,80004c5c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004c66:	0009a503          	lw	a0,0(s3)
    80004c6a:	00000097          	auipc	ra,0x0
    80004c6e:	90c080e7          	jalr	-1780(ra) # 80004576 <bfree>
      ip->addrs[i] = 0;
    80004c72:	0004a023          	sw	zero,0(s1)
    80004c76:	b7dd                	j	80004c5c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004c78:	0809a583          	lw	a1,128(s3)
    80004c7c:	e185                	bnez	a1,80004c9c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004c7e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004c82:	854e                	mv	a0,s3
    80004c84:	00000097          	auipc	ra,0x0
    80004c88:	de4080e7          	jalr	-540(ra) # 80004a68 <iupdate>
}
    80004c8c:	70a2                	ld	ra,40(sp)
    80004c8e:	7402                	ld	s0,32(sp)
    80004c90:	64e2                	ld	s1,24(sp)
    80004c92:	6942                	ld	s2,16(sp)
    80004c94:	69a2                	ld	s3,8(sp)
    80004c96:	6a02                	ld	s4,0(sp)
    80004c98:	6145                	addi	sp,sp,48
    80004c9a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004c9c:	0009a503          	lw	a0,0(s3)
    80004ca0:	fffff097          	auipc	ra,0xfffff
    80004ca4:	690080e7          	jalr	1680(ra) # 80004330 <bread>
    80004ca8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004caa:	05850493          	addi	s1,a0,88
    80004cae:	45850913          	addi	s2,a0,1112
    80004cb2:	a811                	j	80004cc6 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80004cb4:	0009a503          	lw	a0,0(s3)
    80004cb8:	00000097          	auipc	ra,0x0
    80004cbc:	8be080e7          	jalr	-1858(ra) # 80004576 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80004cc0:	0491                	addi	s1,s1,4
    80004cc2:	01248563          	beq	s1,s2,80004ccc <itrunc+0x8c>
      if(a[j])
    80004cc6:	408c                	lw	a1,0(s1)
    80004cc8:	dde5                	beqz	a1,80004cc0 <itrunc+0x80>
    80004cca:	b7ed                	j	80004cb4 <itrunc+0x74>
    brelse(bp);
    80004ccc:	8552                	mv	a0,s4
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	792080e7          	jalr	1938(ra) # 80004460 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004cd6:	0809a583          	lw	a1,128(s3)
    80004cda:	0009a503          	lw	a0,0(s3)
    80004cde:	00000097          	auipc	ra,0x0
    80004ce2:	898080e7          	jalr	-1896(ra) # 80004576 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004ce6:	0809a023          	sw	zero,128(s3)
    80004cea:	bf51                	j	80004c7e <itrunc+0x3e>

0000000080004cec <iput>:
{
    80004cec:	1101                	addi	sp,sp,-32
    80004cee:	ec06                	sd	ra,24(sp)
    80004cf0:	e822                	sd	s0,16(sp)
    80004cf2:	e426                	sd	s1,8(sp)
    80004cf4:	e04a                	sd	s2,0(sp)
    80004cf6:	1000                	addi	s0,sp,32
    80004cf8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004cfa:	0001c517          	auipc	a0,0x1c
    80004cfe:	77e50513          	addi	a0,a0,1918 # 80021478 <itable>
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	ee0080e7          	jalr	-288(ra) # 80000be2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004d0a:	4498                	lw	a4,8(s1)
    80004d0c:	4785                	li	a5,1
    80004d0e:	02f70363          	beq	a4,a5,80004d34 <iput+0x48>
  ip->ref--;
    80004d12:	449c                	lw	a5,8(s1)
    80004d14:	37fd                	addiw	a5,a5,-1
    80004d16:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004d18:	0001c517          	auipc	a0,0x1c
    80004d1c:	76050513          	addi	a0,a0,1888 # 80021478 <itable>
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	f76080e7          	jalr	-138(ra) # 80000c96 <release>
}
    80004d28:	60e2                	ld	ra,24(sp)
    80004d2a:	6442                	ld	s0,16(sp)
    80004d2c:	64a2                	ld	s1,8(sp)
    80004d2e:	6902                	ld	s2,0(sp)
    80004d30:	6105                	addi	sp,sp,32
    80004d32:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004d34:	40bc                	lw	a5,64(s1)
    80004d36:	dff1                	beqz	a5,80004d12 <iput+0x26>
    80004d38:	04a49783          	lh	a5,74(s1)
    80004d3c:	fbf9                	bnez	a5,80004d12 <iput+0x26>
    acquiresleep(&ip->lock);
    80004d3e:	01048913          	addi	s2,s1,16
    80004d42:	854a                	mv	a0,s2
    80004d44:	00001097          	auipc	ra,0x1
    80004d48:	ab8080e7          	jalr	-1352(ra) # 800057fc <acquiresleep>
    release(&itable.lock);
    80004d4c:	0001c517          	auipc	a0,0x1c
    80004d50:	72c50513          	addi	a0,a0,1836 # 80021478 <itable>
    80004d54:	ffffc097          	auipc	ra,0xffffc
    80004d58:	f42080e7          	jalr	-190(ra) # 80000c96 <release>
    itrunc(ip);
    80004d5c:	8526                	mv	a0,s1
    80004d5e:	00000097          	auipc	ra,0x0
    80004d62:	ee2080e7          	jalr	-286(ra) # 80004c40 <itrunc>
    ip->type = 0;
    80004d66:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004d6a:	8526                	mv	a0,s1
    80004d6c:	00000097          	auipc	ra,0x0
    80004d70:	cfc080e7          	jalr	-772(ra) # 80004a68 <iupdate>
    ip->valid = 0;
    80004d74:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004d78:	854a                	mv	a0,s2
    80004d7a:	00001097          	auipc	ra,0x1
    80004d7e:	ad8080e7          	jalr	-1320(ra) # 80005852 <releasesleep>
    acquire(&itable.lock);
    80004d82:	0001c517          	auipc	a0,0x1c
    80004d86:	6f650513          	addi	a0,a0,1782 # 80021478 <itable>
    80004d8a:	ffffc097          	auipc	ra,0xffffc
    80004d8e:	e58080e7          	jalr	-424(ra) # 80000be2 <acquire>
    80004d92:	b741                	j	80004d12 <iput+0x26>

0000000080004d94 <iunlockput>:
{
    80004d94:	1101                	addi	sp,sp,-32
    80004d96:	ec06                	sd	ra,24(sp)
    80004d98:	e822                	sd	s0,16(sp)
    80004d9a:	e426                	sd	s1,8(sp)
    80004d9c:	1000                	addi	s0,sp,32
    80004d9e:	84aa                	mv	s1,a0
  iunlock(ip);
    80004da0:	00000097          	auipc	ra,0x0
    80004da4:	e54080e7          	jalr	-428(ra) # 80004bf4 <iunlock>
  iput(ip);
    80004da8:	8526                	mv	a0,s1
    80004daa:	00000097          	auipc	ra,0x0
    80004dae:	f42080e7          	jalr	-190(ra) # 80004cec <iput>
}
    80004db2:	60e2                	ld	ra,24(sp)
    80004db4:	6442                	ld	s0,16(sp)
    80004db6:	64a2                	ld	s1,8(sp)
    80004db8:	6105                	addi	sp,sp,32
    80004dba:	8082                	ret

0000000080004dbc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004dbc:	1141                	addi	sp,sp,-16
    80004dbe:	e422                	sd	s0,8(sp)
    80004dc0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004dc2:	411c                	lw	a5,0(a0)
    80004dc4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004dc6:	415c                	lw	a5,4(a0)
    80004dc8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004dca:	04451783          	lh	a5,68(a0)
    80004dce:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004dd2:	04a51783          	lh	a5,74(a0)
    80004dd6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004dda:	04c56783          	lwu	a5,76(a0)
    80004dde:	e99c                	sd	a5,16(a1)
}
    80004de0:	6422                	ld	s0,8(sp)
    80004de2:	0141                	addi	sp,sp,16
    80004de4:	8082                	ret

0000000080004de6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004de6:	457c                	lw	a5,76(a0)
    80004de8:	0ed7e963          	bltu	a5,a3,80004eda <readi+0xf4>
{
    80004dec:	7159                	addi	sp,sp,-112
    80004dee:	f486                	sd	ra,104(sp)
    80004df0:	f0a2                	sd	s0,96(sp)
    80004df2:	eca6                	sd	s1,88(sp)
    80004df4:	e8ca                	sd	s2,80(sp)
    80004df6:	e4ce                	sd	s3,72(sp)
    80004df8:	e0d2                	sd	s4,64(sp)
    80004dfa:	fc56                	sd	s5,56(sp)
    80004dfc:	f85a                	sd	s6,48(sp)
    80004dfe:	f45e                	sd	s7,40(sp)
    80004e00:	f062                	sd	s8,32(sp)
    80004e02:	ec66                	sd	s9,24(sp)
    80004e04:	e86a                	sd	s10,16(sp)
    80004e06:	e46e                	sd	s11,8(sp)
    80004e08:	1880                	addi	s0,sp,112
    80004e0a:	8baa                	mv	s7,a0
    80004e0c:	8c2e                	mv	s8,a1
    80004e0e:	8ab2                	mv	s5,a2
    80004e10:	84b6                	mv	s1,a3
    80004e12:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004e14:	9f35                	addw	a4,a4,a3
    return 0;
    80004e16:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004e18:	0ad76063          	bltu	a4,a3,80004eb8 <readi+0xd2>
  if(off + n > ip->size)
    80004e1c:	00e7f463          	bgeu	a5,a4,80004e24 <readi+0x3e>
    n = ip->size - off;
    80004e20:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004e24:	0a0b0963          	beqz	s6,80004ed6 <readi+0xf0>
    80004e28:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004e2a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004e2e:	5cfd                	li	s9,-1
    80004e30:	a82d                	j	80004e6a <readi+0x84>
    80004e32:	020a1d93          	slli	s11,s4,0x20
    80004e36:	020ddd93          	srli	s11,s11,0x20
    80004e3a:	05890613          	addi	a2,s2,88
    80004e3e:	86ee                	mv	a3,s11
    80004e40:	963a                	add	a2,a2,a4
    80004e42:	85d6                	mv	a1,s5
    80004e44:	8562                	mv	a0,s8
    80004e46:	ffffe097          	auipc	ra,0xffffe
    80004e4a:	32c080e7          	jalr	812(ra) # 80003172 <either_copyout>
    80004e4e:	05950d63          	beq	a0,s9,80004ea8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004e52:	854a                	mv	a0,s2
    80004e54:	fffff097          	auipc	ra,0xfffff
    80004e58:	60c080e7          	jalr	1548(ra) # 80004460 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004e5c:	013a09bb          	addw	s3,s4,s3
    80004e60:	009a04bb          	addw	s1,s4,s1
    80004e64:	9aee                	add	s5,s5,s11
    80004e66:	0569f763          	bgeu	s3,s6,80004eb4 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004e6a:	000ba903          	lw	s2,0(s7)
    80004e6e:	00a4d59b          	srliw	a1,s1,0xa
    80004e72:	855e                	mv	a0,s7
    80004e74:	00000097          	auipc	ra,0x0
    80004e78:	8b0080e7          	jalr	-1872(ra) # 80004724 <bmap>
    80004e7c:	0005059b          	sext.w	a1,a0
    80004e80:	854a                	mv	a0,s2
    80004e82:	fffff097          	auipc	ra,0xfffff
    80004e86:	4ae080e7          	jalr	1198(ra) # 80004330 <bread>
    80004e8a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004e8c:	3ff4f713          	andi	a4,s1,1023
    80004e90:	40ed07bb          	subw	a5,s10,a4
    80004e94:	413b06bb          	subw	a3,s6,s3
    80004e98:	8a3e                	mv	s4,a5
    80004e9a:	2781                	sext.w	a5,a5
    80004e9c:	0006861b          	sext.w	a2,a3
    80004ea0:	f8f679e3          	bgeu	a2,a5,80004e32 <readi+0x4c>
    80004ea4:	8a36                	mv	s4,a3
    80004ea6:	b771                	j	80004e32 <readi+0x4c>
      brelse(bp);
    80004ea8:	854a                	mv	a0,s2
    80004eaa:	fffff097          	auipc	ra,0xfffff
    80004eae:	5b6080e7          	jalr	1462(ra) # 80004460 <brelse>
      tot = -1;
    80004eb2:	59fd                	li	s3,-1
  }
  return tot;
    80004eb4:	0009851b          	sext.w	a0,s3
}
    80004eb8:	70a6                	ld	ra,104(sp)
    80004eba:	7406                	ld	s0,96(sp)
    80004ebc:	64e6                	ld	s1,88(sp)
    80004ebe:	6946                	ld	s2,80(sp)
    80004ec0:	69a6                	ld	s3,72(sp)
    80004ec2:	6a06                	ld	s4,64(sp)
    80004ec4:	7ae2                	ld	s5,56(sp)
    80004ec6:	7b42                	ld	s6,48(sp)
    80004ec8:	7ba2                	ld	s7,40(sp)
    80004eca:	7c02                	ld	s8,32(sp)
    80004ecc:	6ce2                	ld	s9,24(sp)
    80004ece:	6d42                	ld	s10,16(sp)
    80004ed0:	6da2                	ld	s11,8(sp)
    80004ed2:	6165                	addi	sp,sp,112
    80004ed4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004ed6:	89da                	mv	s3,s6
    80004ed8:	bff1                	j	80004eb4 <readi+0xce>
    return 0;
    80004eda:	4501                	li	a0,0
}
    80004edc:	8082                	ret

0000000080004ede <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004ede:	457c                	lw	a5,76(a0)
    80004ee0:	10d7e863          	bltu	a5,a3,80004ff0 <writei+0x112>
{
    80004ee4:	7159                	addi	sp,sp,-112
    80004ee6:	f486                	sd	ra,104(sp)
    80004ee8:	f0a2                	sd	s0,96(sp)
    80004eea:	eca6                	sd	s1,88(sp)
    80004eec:	e8ca                	sd	s2,80(sp)
    80004eee:	e4ce                	sd	s3,72(sp)
    80004ef0:	e0d2                	sd	s4,64(sp)
    80004ef2:	fc56                	sd	s5,56(sp)
    80004ef4:	f85a                	sd	s6,48(sp)
    80004ef6:	f45e                	sd	s7,40(sp)
    80004ef8:	f062                	sd	s8,32(sp)
    80004efa:	ec66                	sd	s9,24(sp)
    80004efc:	e86a                	sd	s10,16(sp)
    80004efe:	e46e                	sd	s11,8(sp)
    80004f00:	1880                	addi	s0,sp,112
    80004f02:	8b2a                	mv	s6,a0
    80004f04:	8c2e                	mv	s8,a1
    80004f06:	8ab2                	mv	s5,a2
    80004f08:	8936                	mv	s2,a3
    80004f0a:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004f0c:	00e687bb          	addw	a5,a3,a4
    80004f10:	0ed7e263          	bltu	a5,a3,80004ff4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004f14:	00043737          	lui	a4,0x43
    80004f18:	0ef76063          	bltu	a4,a5,80004ff8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004f1c:	0c0b8863          	beqz	s7,80004fec <writei+0x10e>
    80004f20:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004f22:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004f26:	5cfd                	li	s9,-1
    80004f28:	a091                	j	80004f6c <writei+0x8e>
    80004f2a:	02099d93          	slli	s11,s3,0x20
    80004f2e:	020ddd93          	srli	s11,s11,0x20
    80004f32:	05848513          	addi	a0,s1,88
    80004f36:	86ee                	mv	a3,s11
    80004f38:	8656                	mv	a2,s5
    80004f3a:	85e2                	mv	a1,s8
    80004f3c:	953a                	add	a0,a0,a4
    80004f3e:	ffffe097          	auipc	ra,0xffffe
    80004f42:	28a080e7          	jalr	650(ra) # 800031c8 <either_copyin>
    80004f46:	07950263          	beq	a0,s9,80004faa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004f4a:	8526                	mv	a0,s1
    80004f4c:	00000097          	auipc	ra,0x0
    80004f50:	790080e7          	jalr	1936(ra) # 800056dc <log_write>
    brelse(bp);
    80004f54:	8526                	mv	a0,s1
    80004f56:	fffff097          	auipc	ra,0xfffff
    80004f5a:	50a080e7          	jalr	1290(ra) # 80004460 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004f5e:	01498a3b          	addw	s4,s3,s4
    80004f62:	0129893b          	addw	s2,s3,s2
    80004f66:	9aee                	add	s5,s5,s11
    80004f68:	057a7663          	bgeu	s4,s7,80004fb4 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004f6c:	000b2483          	lw	s1,0(s6)
    80004f70:	00a9559b          	srliw	a1,s2,0xa
    80004f74:	855a                	mv	a0,s6
    80004f76:	fffff097          	auipc	ra,0xfffff
    80004f7a:	7ae080e7          	jalr	1966(ra) # 80004724 <bmap>
    80004f7e:	0005059b          	sext.w	a1,a0
    80004f82:	8526                	mv	a0,s1
    80004f84:	fffff097          	auipc	ra,0xfffff
    80004f88:	3ac080e7          	jalr	940(ra) # 80004330 <bread>
    80004f8c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004f8e:	3ff97713          	andi	a4,s2,1023
    80004f92:	40ed07bb          	subw	a5,s10,a4
    80004f96:	414b86bb          	subw	a3,s7,s4
    80004f9a:	89be                	mv	s3,a5
    80004f9c:	2781                	sext.w	a5,a5
    80004f9e:	0006861b          	sext.w	a2,a3
    80004fa2:	f8f674e3          	bgeu	a2,a5,80004f2a <writei+0x4c>
    80004fa6:	89b6                	mv	s3,a3
    80004fa8:	b749                	j	80004f2a <writei+0x4c>
      brelse(bp);
    80004faa:	8526                	mv	a0,s1
    80004fac:	fffff097          	auipc	ra,0xfffff
    80004fb0:	4b4080e7          	jalr	1204(ra) # 80004460 <brelse>
  }

  if(off > ip->size)
    80004fb4:	04cb2783          	lw	a5,76(s6)
    80004fb8:	0127f463          	bgeu	a5,s2,80004fc0 <writei+0xe2>
    ip->size = off;
    80004fbc:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004fc0:	855a                	mv	a0,s6
    80004fc2:	00000097          	auipc	ra,0x0
    80004fc6:	aa6080e7          	jalr	-1370(ra) # 80004a68 <iupdate>

  return tot;
    80004fca:	000a051b          	sext.w	a0,s4
}
    80004fce:	70a6                	ld	ra,104(sp)
    80004fd0:	7406                	ld	s0,96(sp)
    80004fd2:	64e6                	ld	s1,88(sp)
    80004fd4:	6946                	ld	s2,80(sp)
    80004fd6:	69a6                	ld	s3,72(sp)
    80004fd8:	6a06                	ld	s4,64(sp)
    80004fda:	7ae2                	ld	s5,56(sp)
    80004fdc:	7b42                	ld	s6,48(sp)
    80004fde:	7ba2                	ld	s7,40(sp)
    80004fe0:	7c02                	ld	s8,32(sp)
    80004fe2:	6ce2                	ld	s9,24(sp)
    80004fe4:	6d42                	ld	s10,16(sp)
    80004fe6:	6da2                	ld	s11,8(sp)
    80004fe8:	6165                	addi	sp,sp,112
    80004fea:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004fec:	8a5e                	mv	s4,s7
    80004fee:	bfc9                	j	80004fc0 <writei+0xe2>
    return -1;
    80004ff0:	557d                	li	a0,-1
}
    80004ff2:	8082                	ret
    return -1;
    80004ff4:	557d                	li	a0,-1
    80004ff6:	bfe1                	j	80004fce <writei+0xf0>
    return -1;
    80004ff8:	557d                	li	a0,-1
    80004ffa:	bfd1                	j	80004fce <writei+0xf0>

0000000080004ffc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004ffc:	1141                	addi	sp,sp,-16
    80004ffe:	e406                	sd	ra,8(sp)
    80005000:	e022                	sd	s0,0(sp)
    80005002:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80005004:	4639                	li	a2,14
    80005006:	ffffc097          	auipc	ra,0xffffc
    8000500a:	db0080e7          	jalr	-592(ra) # 80000db6 <strncmp>
}
    8000500e:	60a2                	ld	ra,8(sp)
    80005010:	6402                	ld	s0,0(sp)
    80005012:	0141                	addi	sp,sp,16
    80005014:	8082                	ret

0000000080005016 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80005016:	7139                	addi	sp,sp,-64
    80005018:	fc06                	sd	ra,56(sp)
    8000501a:	f822                	sd	s0,48(sp)
    8000501c:	f426                	sd	s1,40(sp)
    8000501e:	f04a                	sd	s2,32(sp)
    80005020:	ec4e                	sd	s3,24(sp)
    80005022:	e852                	sd	s4,16(sp)
    80005024:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80005026:	04451703          	lh	a4,68(a0)
    8000502a:	4785                	li	a5,1
    8000502c:	00f71a63          	bne	a4,a5,80005040 <dirlookup+0x2a>
    80005030:	892a                	mv	s2,a0
    80005032:	89ae                	mv	s3,a1
    80005034:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80005036:	457c                	lw	a5,76(a0)
    80005038:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000503a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000503c:	e79d                	bnez	a5,8000506a <dirlookup+0x54>
    8000503e:	a8a5                	j	800050b6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80005040:	00005517          	auipc	a0,0x5
    80005044:	89050513          	addi	a0,a0,-1904 # 800098d0 <syscalls+0x290>
    80005048:	ffffb097          	auipc	ra,0xffffb
    8000504c:	4f4080e7          	jalr	1268(ra) # 8000053c <panic>
      panic("dirlookup read");
    80005050:	00005517          	auipc	a0,0x5
    80005054:	89850513          	addi	a0,a0,-1896 # 800098e8 <syscalls+0x2a8>
    80005058:	ffffb097          	auipc	ra,0xffffb
    8000505c:	4e4080e7          	jalr	1252(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005060:	24c1                	addiw	s1,s1,16
    80005062:	04c92783          	lw	a5,76(s2)
    80005066:	04f4f763          	bgeu	s1,a5,800050b4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000506a:	4741                	li	a4,16
    8000506c:	86a6                	mv	a3,s1
    8000506e:	fc040613          	addi	a2,s0,-64
    80005072:	4581                	li	a1,0
    80005074:	854a                	mv	a0,s2
    80005076:	00000097          	auipc	ra,0x0
    8000507a:	d70080e7          	jalr	-656(ra) # 80004de6 <readi>
    8000507e:	47c1                	li	a5,16
    80005080:	fcf518e3          	bne	a0,a5,80005050 <dirlookup+0x3a>
    if(de.inum == 0)
    80005084:	fc045783          	lhu	a5,-64(s0)
    80005088:	dfe1                	beqz	a5,80005060 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000508a:	fc240593          	addi	a1,s0,-62
    8000508e:	854e                	mv	a0,s3
    80005090:	00000097          	auipc	ra,0x0
    80005094:	f6c080e7          	jalr	-148(ra) # 80004ffc <namecmp>
    80005098:	f561                	bnez	a0,80005060 <dirlookup+0x4a>
      if(poff)
    8000509a:	000a0463          	beqz	s4,800050a2 <dirlookup+0x8c>
        *poff = off;
    8000509e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800050a2:	fc045583          	lhu	a1,-64(s0)
    800050a6:	00092503          	lw	a0,0(s2)
    800050aa:	fffff097          	auipc	ra,0xfffff
    800050ae:	754080e7          	jalr	1876(ra) # 800047fe <iget>
    800050b2:	a011                	j	800050b6 <dirlookup+0xa0>
  return 0;
    800050b4:	4501                	li	a0,0
}
    800050b6:	70e2                	ld	ra,56(sp)
    800050b8:	7442                	ld	s0,48(sp)
    800050ba:	74a2                	ld	s1,40(sp)
    800050bc:	7902                	ld	s2,32(sp)
    800050be:	69e2                	ld	s3,24(sp)
    800050c0:	6a42                	ld	s4,16(sp)
    800050c2:	6121                	addi	sp,sp,64
    800050c4:	8082                	ret

00000000800050c6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800050c6:	711d                	addi	sp,sp,-96
    800050c8:	ec86                	sd	ra,88(sp)
    800050ca:	e8a2                	sd	s0,80(sp)
    800050cc:	e4a6                	sd	s1,72(sp)
    800050ce:	e0ca                	sd	s2,64(sp)
    800050d0:	fc4e                	sd	s3,56(sp)
    800050d2:	f852                	sd	s4,48(sp)
    800050d4:	f456                	sd	s5,40(sp)
    800050d6:	f05a                	sd	s6,32(sp)
    800050d8:	ec5e                	sd	s7,24(sp)
    800050da:	e862                	sd	s8,16(sp)
    800050dc:	e466                	sd	s9,8(sp)
    800050de:	1080                	addi	s0,sp,96
    800050e0:	84aa                	mv	s1,a0
    800050e2:	8b2e                	mv	s6,a1
    800050e4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800050e6:	00054703          	lbu	a4,0(a0)
    800050ea:	02f00793          	li	a5,47
    800050ee:	02f70363          	beq	a4,a5,80005114 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800050f2:	ffffd097          	auipc	ra,0xffffd
    800050f6:	8e2080e7          	jalr	-1822(ra) # 800019d4 <myproc>
    800050fa:	15853503          	ld	a0,344(a0)
    800050fe:	00000097          	auipc	ra,0x0
    80005102:	9f6080e7          	jalr	-1546(ra) # 80004af4 <idup>
    80005106:	89aa                	mv	s3,a0
  while(*path == '/')
    80005108:	02f00913          	li	s2,47
  len = path - s;
    8000510c:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000510e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80005110:	4c05                	li	s8,1
    80005112:	a865                	j	800051ca <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80005114:	4585                	li	a1,1
    80005116:	4505                	li	a0,1
    80005118:	fffff097          	auipc	ra,0xfffff
    8000511c:	6e6080e7          	jalr	1766(ra) # 800047fe <iget>
    80005120:	89aa                	mv	s3,a0
    80005122:	b7dd                	j	80005108 <namex+0x42>
      iunlockput(ip);
    80005124:	854e                	mv	a0,s3
    80005126:	00000097          	auipc	ra,0x0
    8000512a:	c6e080e7          	jalr	-914(ra) # 80004d94 <iunlockput>
      return 0;
    8000512e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80005130:	854e                	mv	a0,s3
    80005132:	60e6                	ld	ra,88(sp)
    80005134:	6446                	ld	s0,80(sp)
    80005136:	64a6                	ld	s1,72(sp)
    80005138:	6906                	ld	s2,64(sp)
    8000513a:	79e2                	ld	s3,56(sp)
    8000513c:	7a42                	ld	s4,48(sp)
    8000513e:	7aa2                	ld	s5,40(sp)
    80005140:	7b02                	ld	s6,32(sp)
    80005142:	6be2                	ld	s7,24(sp)
    80005144:	6c42                	ld	s8,16(sp)
    80005146:	6ca2                	ld	s9,8(sp)
    80005148:	6125                	addi	sp,sp,96
    8000514a:	8082                	ret
      iunlock(ip);
    8000514c:	854e                	mv	a0,s3
    8000514e:	00000097          	auipc	ra,0x0
    80005152:	aa6080e7          	jalr	-1370(ra) # 80004bf4 <iunlock>
      return ip;
    80005156:	bfe9                	j	80005130 <namex+0x6a>
      iunlockput(ip);
    80005158:	854e                	mv	a0,s3
    8000515a:	00000097          	auipc	ra,0x0
    8000515e:	c3a080e7          	jalr	-966(ra) # 80004d94 <iunlockput>
      return 0;
    80005162:	89d2                	mv	s3,s4
    80005164:	b7f1                	j	80005130 <namex+0x6a>
  len = path - s;
    80005166:	40b48633          	sub	a2,s1,a1
    8000516a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    8000516e:	094cd463          	bge	s9,s4,800051f6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80005172:	4639                	li	a2,14
    80005174:	8556                	mv	a0,s5
    80005176:	ffffc097          	auipc	ra,0xffffc
    8000517a:	bc8080e7          	jalr	-1080(ra) # 80000d3e <memmove>
  while(*path == '/')
    8000517e:	0004c783          	lbu	a5,0(s1)
    80005182:	01279763          	bne	a5,s2,80005190 <namex+0xca>
    path++;
    80005186:	0485                	addi	s1,s1,1
  while(*path == '/')
    80005188:	0004c783          	lbu	a5,0(s1)
    8000518c:	ff278de3          	beq	a5,s2,80005186 <namex+0xc0>
    ilock(ip);
    80005190:	854e                	mv	a0,s3
    80005192:	00000097          	auipc	ra,0x0
    80005196:	9a0080e7          	jalr	-1632(ra) # 80004b32 <ilock>
    if(ip->type != T_DIR){
    8000519a:	04499783          	lh	a5,68(s3)
    8000519e:	f98793e3          	bne	a5,s8,80005124 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800051a2:	000b0563          	beqz	s6,800051ac <namex+0xe6>
    800051a6:	0004c783          	lbu	a5,0(s1)
    800051aa:	d3cd                	beqz	a5,8000514c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800051ac:	865e                	mv	a2,s7
    800051ae:	85d6                	mv	a1,s5
    800051b0:	854e                	mv	a0,s3
    800051b2:	00000097          	auipc	ra,0x0
    800051b6:	e64080e7          	jalr	-412(ra) # 80005016 <dirlookup>
    800051ba:	8a2a                	mv	s4,a0
    800051bc:	dd51                	beqz	a0,80005158 <namex+0x92>
    iunlockput(ip);
    800051be:	854e                	mv	a0,s3
    800051c0:	00000097          	auipc	ra,0x0
    800051c4:	bd4080e7          	jalr	-1068(ra) # 80004d94 <iunlockput>
    ip = next;
    800051c8:	89d2                	mv	s3,s4
  while(*path == '/')
    800051ca:	0004c783          	lbu	a5,0(s1)
    800051ce:	05279763          	bne	a5,s2,8000521c <namex+0x156>
    path++;
    800051d2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800051d4:	0004c783          	lbu	a5,0(s1)
    800051d8:	ff278de3          	beq	a5,s2,800051d2 <namex+0x10c>
  if(*path == 0)
    800051dc:	c79d                	beqz	a5,8000520a <namex+0x144>
    path++;
    800051de:	85a6                	mv	a1,s1
  len = path - s;
    800051e0:	8a5e                	mv	s4,s7
    800051e2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800051e4:	01278963          	beq	a5,s2,800051f6 <namex+0x130>
    800051e8:	dfbd                	beqz	a5,80005166 <namex+0xa0>
    path++;
    800051ea:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800051ec:	0004c783          	lbu	a5,0(s1)
    800051f0:	ff279ce3          	bne	a5,s2,800051e8 <namex+0x122>
    800051f4:	bf8d                	j	80005166 <namex+0xa0>
    memmove(name, s, len);
    800051f6:	2601                	sext.w	a2,a2
    800051f8:	8556                	mv	a0,s5
    800051fa:	ffffc097          	auipc	ra,0xffffc
    800051fe:	b44080e7          	jalr	-1212(ra) # 80000d3e <memmove>
    name[len] = 0;
    80005202:	9a56                	add	s4,s4,s5
    80005204:	000a0023          	sb	zero,0(s4)
    80005208:	bf9d                	j	8000517e <namex+0xb8>
  if(nameiparent){
    8000520a:	f20b03e3          	beqz	s6,80005130 <namex+0x6a>
    iput(ip);
    8000520e:	854e                	mv	a0,s3
    80005210:	00000097          	auipc	ra,0x0
    80005214:	adc080e7          	jalr	-1316(ra) # 80004cec <iput>
    return 0;
    80005218:	4981                	li	s3,0
    8000521a:	bf19                	j	80005130 <namex+0x6a>
  if(*path == 0)
    8000521c:	d7fd                	beqz	a5,8000520a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000521e:	0004c783          	lbu	a5,0(s1)
    80005222:	85a6                	mv	a1,s1
    80005224:	b7d1                	j	800051e8 <namex+0x122>

0000000080005226 <dirlink>:
{
    80005226:	7139                	addi	sp,sp,-64
    80005228:	fc06                	sd	ra,56(sp)
    8000522a:	f822                	sd	s0,48(sp)
    8000522c:	f426                	sd	s1,40(sp)
    8000522e:	f04a                	sd	s2,32(sp)
    80005230:	ec4e                	sd	s3,24(sp)
    80005232:	e852                	sd	s4,16(sp)
    80005234:	0080                	addi	s0,sp,64
    80005236:	892a                	mv	s2,a0
    80005238:	8a2e                	mv	s4,a1
    8000523a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000523c:	4601                	li	a2,0
    8000523e:	00000097          	auipc	ra,0x0
    80005242:	dd8080e7          	jalr	-552(ra) # 80005016 <dirlookup>
    80005246:	e93d                	bnez	a0,800052bc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005248:	04c92483          	lw	s1,76(s2)
    8000524c:	c49d                	beqz	s1,8000527a <dirlink+0x54>
    8000524e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005250:	4741                	li	a4,16
    80005252:	86a6                	mv	a3,s1
    80005254:	fc040613          	addi	a2,s0,-64
    80005258:	4581                	li	a1,0
    8000525a:	854a                	mv	a0,s2
    8000525c:	00000097          	auipc	ra,0x0
    80005260:	b8a080e7          	jalr	-1142(ra) # 80004de6 <readi>
    80005264:	47c1                	li	a5,16
    80005266:	06f51163          	bne	a0,a5,800052c8 <dirlink+0xa2>
    if(de.inum == 0)
    8000526a:	fc045783          	lhu	a5,-64(s0)
    8000526e:	c791                	beqz	a5,8000527a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005270:	24c1                	addiw	s1,s1,16
    80005272:	04c92783          	lw	a5,76(s2)
    80005276:	fcf4ede3          	bltu	s1,a5,80005250 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000527a:	4639                	li	a2,14
    8000527c:	85d2                	mv	a1,s4
    8000527e:	fc240513          	addi	a0,s0,-62
    80005282:	ffffc097          	auipc	ra,0xffffc
    80005286:	b70080e7          	jalr	-1168(ra) # 80000df2 <strncpy>
  de.inum = inum;
    8000528a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000528e:	4741                	li	a4,16
    80005290:	86a6                	mv	a3,s1
    80005292:	fc040613          	addi	a2,s0,-64
    80005296:	4581                	li	a1,0
    80005298:	854a                	mv	a0,s2
    8000529a:	00000097          	auipc	ra,0x0
    8000529e:	c44080e7          	jalr	-956(ra) # 80004ede <writei>
    800052a2:	872a                	mv	a4,a0
    800052a4:	47c1                	li	a5,16
  return 0;
    800052a6:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052a8:	02f71863          	bne	a4,a5,800052d8 <dirlink+0xb2>
}
    800052ac:	70e2                	ld	ra,56(sp)
    800052ae:	7442                	ld	s0,48(sp)
    800052b0:	74a2                	ld	s1,40(sp)
    800052b2:	7902                	ld	s2,32(sp)
    800052b4:	69e2                	ld	s3,24(sp)
    800052b6:	6a42                	ld	s4,16(sp)
    800052b8:	6121                	addi	sp,sp,64
    800052ba:	8082                	ret
    iput(ip);
    800052bc:	00000097          	auipc	ra,0x0
    800052c0:	a30080e7          	jalr	-1488(ra) # 80004cec <iput>
    return -1;
    800052c4:	557d                	li	a0,-1
    800052c6:	b7dd                	j	800052ac <dirlink+0x86>
      panic("dirlink read");
    800052c8:	00004517          	auipc	a0,0x4
    800052cc:	63050513          	addi	a0,a0,1584 # 800098f8 <syscalls+0x2b8>
    800052d0:	ffffb097          	auipc	ra,0xffffb
    800052d4:	26c080e7          	jalr	620(ra) # 8000053c <panic>
    panic("dirlink");
    800052d8:	00004517          	auipc	a0,0x4
    800052dc:	73050513          	addi	a0,a0,1840 # 80009a08 <syscalls+0x3c8>
    800052e0:	ffffb097          	auipc	ra,0xffffb
    800052e4:	25c080e7          	jalr	604(ra) # 8000053c <panic>

00000000800052e8 <namei>:

struct inode*
namei(char *path)
{
    800052e8:	1101                	addi	sp,sp,-32
    800052ea:	ec06                	sd	ra,24(sp)
    800052ec:	e822                	sd	s0,16(sp)
    800052ee:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800052f0:	fe040613          	addi	a2,s0,-32
    800052f4:	4581                	li	a1,0
    800052f6:	00000097          	auipc	ra,0x0
    800052fa:	dd0080e7          	jalr	-560(ra) # 800050c6 <namex>
}
    800052fe:	60e2                	ld	ra,24(sp)
    80005300:	6442                	ld	s0,16(sp)
    80005302:	6105                	addi	sp,sp,32
    80005304:	8082                	ret

0000000080005306 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80005306:	1141                	addi	sp,sp,-16
    80005308:	e406                	sd	ra,8(sp)
    8000530a:	e022                	sd	s0,0(sp)
    8000530c:	0800                	addi	s0,sp,16
    8000530e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80005310:	4585                	li	a1,1
    80005312:	00000097          	auipc	ra,0x0
    80005316:	db4080e7          	jalr	-588(ra) # 800050c6 <namex>
}
    8000531a:	60a2                	ld	ra,8(sp)
    8000531c:	6402                	ld	s0,0(sp)
    8000531e:	0141                	addi	sp,sp,16
    80005320:	8082                	ret

0000000080005322 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80005322:	1101                	addi	sp,sp,-32
    80005324:	ec06                	sd	ra,24(sp)
    80005326:	e822                	sd	s0,16(sp)
    80005328:	e426                	sd	s1,8(sp)
    8000532a:	e04a                	sd	s2,0(sp)
    8000532c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000532e:	0001e917          	auipc	s2,0x1e
    80005332:	bf290913          	addi	s2,s2,-1038 # 80022f20 <log>
    80005336:	01892583          	lw	a1,24(s2)
    8000533a:	02892503          	lw	a0,40(s2)
    8000533e:	fffff097          	auipc	ra,0xfffff
    80005342:	ff2080e7          	jalr	-14(ra) # 80004330 <bread>
    80005346:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80005348:	02c92683          	lw	a3,44(s2)
    8000534c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000534e:	02d05763          	blez	a3,8000537c <write_head+0x5a>
    80005352:	0001e797          	auipc	a5,0x1e
    80005356:	bfe78793          	addi	a5,a5,-1026 # 80022f50 <log+0x30>
    8000535a:	05c50713          	addi	a4,a0,92
    8000535e:	36fd                	addiw	a3,a3,-1
    80005360:	1682                	slli	a3,a3,0x20
    80005362:	9281                	srli	a3,a3,0x20
    80005364:	068a                	slli	a3,a3,0x2
    80005366:	0001e617          	auipc	a2,0x1e
    8000536a:	bee60613          	addi	a2,a2,-1042 # 80022f54 <log+0x34>
    8000536e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80005370:	4390                	lw	a2,0(a5)
    80005372:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005374:	0791                	addi	a5,a5,4
    80005376:	0711                	addi	a4,a4,4
    80005378:	fed79ce3          	bne	a5,a3,80005370 <write_head+0x4e>
  }
  bwrite(buf);
    8000537c:	8526                	mv	a0,s1
    8000537e:	fffff097          	auipc	ra,0xfffff
    80005382:	0a4080e7          	jalr	164(ra) # 80004422 <bwrite>
  brelse(buf);
    80005386:	8526                	mv	a0,s1
    80005388:	fffff097          	auipc	ra,0xfffff
    8000538c:	0d8080e7          	jalr	216(ra) # 80004460 <brelse>
}
    80005390:	60e2                	ld	ra,24(sp)
    80005392:	6442                	ld	s0,16(sp)
    80005394:	64a2                	ld	s1,8(sp)
    80005396:	6902                	ld	s2,0(sp)
    80005398:	6105                	addi	sp,sp,32
    8000539a:	8082                	ret

000000008000539c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000539c:	0001e797          	auipc	a5,0x1e
    800053a0:	bb07a783          	lw	a5,-1104(a5) # 80022f4c <log+0x2c>
    800053a4:	0af05d63          	blez	a5,8000545e <install_trans+0xc2>
{
    800053a8:	7139                	addi	sp,sp,-64
    800053aa:	fc06                	sd	ra,56(sp)
    800053ac:	f822                	sd	s0,48(sp)
    800053ae:	f426                	sd	s1,40(sp)
    800053b0:	f04a                	sd	s2,32(sp)
    800053b2:	ec4e                	sd	s3,24(sp)
    800053b4:	e852                	sd	s4,16(sp)
    800053b6:	e456                	sd	s5,8(sp)
    800053b8:	e05a                	sd	s6,0(sp)
    800053ba:	0080                	addi	s0,sp,64
    800053bc:	8b2a                	mv	s6,a0
    800053be:	0001ea97          	auipc	s5,0x1e
    800053c2:	b92a8a93          	addi	s5,s5,-1134 # 80022f50 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800053c6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800053c8:	0001e997          	auipc	s3,0x1e
    800053cc:	b5898993          	addi	s3,s3,-1192 # 80022f20 <log>
    800053d0:	a035                	j	800053fc <install_trans+0x60>
      bunpin(dbuf);
    800053d2:	8526                	mv	a0,s1
    800053d4:	fffff097          	auipc	ra,0xfffff
    800053d8:	166080e7          	jalr	358(ra) # 8000453a <bunpin>
    brelse(lbuf);
    800053dc:	854a                	mv	a0,s2
    800053de:	fffff097          	auipc	ra,0xfffff
    800053e2:	082080e7          	jalr	130(ra) # 80004460 <brelse>
    brelse(dbuf);
    800053e6:	8526                	mv	a0,s1
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	078080e7          	jalr	120(ra) # 80004460 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800053f0:	2a05                	addiw	s4,s4,1
    800053f2:	0a91                	addi	s5,s5,4
    800053f4:	02c9a783          	lw	a5,44(s3)
    800053f8:	04fa5963          	bge	s4,a5,8000544a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800053fc:	0189a583          	lw	a1,24(s3)
    80005400:	014585bb          	addw	a1,a1,s4
    80005404:	2585                	addiw	a1,a1,1
    80005406:	0289a503          	lw	a0,40(s3)
    8000540a:	fffff097          	auipc	ra,0xfffff
    8000540e:	f26080e7          	jalr	-218(ra) # 80004330 <bread>
    80005412:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80005414:	000aa583          	lw	a1,0(s5)
    80005418:	0289a503          	lw	a0,40(s3)
    8000541c:	fffff097          	auipc	ra,0xfffff
    80005420:	f14080e7          	jalr	-236(ra) # 80004330 <bread>
    80005424:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005426:	40000613          	li	a2,1024
    8000542a:	05890593          	addi	a1,s2,88
    8000542e:	05850513          	addi	a0,a0,88
    80005432:	ffffc097          	auipc	ra,0xffffc
    80005436:	90c080e7          	jalr	-1780(ra) # 80000d3e <memmove>
    bwrite(dbuf);  // write dst to disk
    8000543a:	8526                	mv	a0,s1
    8000543c:	fffff097          	auipc	ra,0xfffff
    80005440:	fe6080e7          	jalr	-26(ra) # 80004422 <bwrite>
    if(recovering == 0)
    80005444:	f80b1ce3          	bnez	s6,800053dc <install_trans+0x40>
    80005448:	b769                	j	800053d2 <install_trans+0x36>
}
    8000544a:	70e2                	ld	ra,56(sp)
    8000544c:	7442                	ld	s0,48(sp)
    8000544e:	74a2                	ld	s1,40(sp)
    80005450:	7902                	ld	s2,32(sp)
    80005452:	69e2                	ld	s3,24(sp)
    80005454:	6a42                	ld	s4,16(sp)
    80005456:	6aa2                	ld	s5,8(sp)
    80005458:	6b02                	ld	s6,0(sp)
    8000545a:	6121                	addi	sp,sp,64
    8000545c:	8082                	ret
    8000545e:	8082                	ret

0000000080005460 <initlog>:
{
    80005460:	7179                	addi	sp,sp,-48
    80005462:	f406                	sd	ra,40(sp)
    80005464:	f022                	sd	s0,32(sp)
    80005466:	ec26                	sd	s1,24(sp)
    80005468:	e84a                	sd	s2,16(sp)
    8000546a:	e44e                	sd	s3,8(sp)
    8000546c:	1800                	addi	s0,sp,48
    8000546e:	892a                	mv	s2,a0
    80005470:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80005472:	0001e497          	auipc	s1,0x1e
    80005476:	aae48493          	addi	s1,s1,-1362 # 80022f20 <log>
    8000547a:	00004597          	auipc	a1,0x4
    8000547e:	48e58593          	addi	a1,a1,1166 # 80009908 <syscalls+0x2c8>
    80005482:	8526                	mv	a0,s1
    80005484:	ffffb097          	auipc	ra,0xffffb
    80005488:	6ce080e7          	jalr	1742(ra) # 80000b52 <initlock>
  log.start = sb->logstart;
    8000548c:	0149a583          	lw	a1,20(s3)
    80005490:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80005492:	0109a783          	lw	a5,16(s3)
    80005496:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80005498:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000549c:	854a                	mv	a0,s2
    8000549e:	fffff097          	auipc	ra,0xfffff
    800054a2:	e92080e7          	jalr	-366(ra) # 80004330 <bread>
  log.lh.n = lh->n;
    800054a6:	4d3c                	lw	a5,88(a0)
    800054a8:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800054aa:	02f05563          	blez	a5,800054d4 <initlog+0x74>
    800054ae:	05c50713          	addi	a4,a0,92
    800054b2:	0001e697          	auipc	a3,0x1e
    800054b6:	a9e68693          	addi	a3,a3,-1378 # 80022f50 <log+0x30>
    800054ba:	37fd                	addiw	a5,a5,-1
    800054bc:	1782                	slli	a5,a5,0x20
    800054be:	9381                	srli	a5,a5,0x20
    800054c0:	078a                	slli	a5,a5,0x2
    800054c2:	06050613          	addi	a2,a0,96
    800054c6:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800054c8:	4310                	lw	a2,0(a4)
    800054ca:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800054cc:	0711                	addi	a4,a4,4
    800054ce:	0691                	addi	a3,a3,4
    800054d0:	fef71ce3          	bne	a4,a5,800054c8 <initlog+0x68>
  brelse(buf);
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	f8c080e7          	jalr	-116(ra) # 80004460 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800054dc:	4505                	li	a0,1
    800054de:	00000097          	auipc	ra,0x0
    800054e2:	ebe080e7          	jalr	-322(ra) # 8000539c <install_trans>
  log.lh.n = 0;
    800054e6:	0001e797          	auipc	a5,0x1e
    800054ea:	a607a323          	sw	zero,-1434(a5) # 80022f4c <log+0x2c>
  write_head(); // clear the log
    800054ee:	00000097          	auipc	ra,0x0
    800054f2:	e34080e7          	jalr	-460(ra) # 80005322 <write_head>
}
    800054f6:	70a2                	ld	ra,40(sp)
    800054f8:	7402                	ld	s0,32(sp)
    800054fa:	64e2                	ld	s1,24(sp)
    800054fc:	6942                	ld	s2,16(sp)
    800054fe:	69a2                	ld	s3,8(sp)
    80005500:	6145                	addi	sp,sp,48
    80005502:	8082                	ret

0000000080005504 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80005504:	1101                	addi	sp,sp,-32
    80005506:	ec06                	sd	ra,24(sp)
    80005508:	e822                	sd	s0,16(sp)
    8000550a:	e426                	sd	s1,8(sp)
    8000550c:	e04a                	sd	s2,0(sp)
    8000550e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80005510:	0001e517          	auipc	a0,0x1e
    80005514:	a1050513          	addi	a0,a0,-1520 # 80022f20 <log>
    80005518:	ffffb097          	auipc	ra,0xffffb
    8000551c:	6ca080e7          	jalr	1738(ra) # 80000be2 <acquire>
  while(1){
    if(log.committing){
    80005520:	0001e497          	auipc	s1,0x1e
    80005524:	a0048493          	addi	s1,s1,-1536 # 80022f20 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005528:	4979                	li	s2,30
    8000552a:	a039                	j	80005538 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000552c:	85a6                	mv	a1,s1
    8000552e:	8526                	mv	a0,s1
    80005530:	ffffd097          	auipc	ra,0xffffd
    80005534:	246080e7          	jalr	582(ra) # 80002776 <sleep>
    if(log.committing){
    80005538:	50dc                	lw	a5,36(s1)
    8000553a:	fbed                	bnez	a5,8000552c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000553c:	509c                	lw	a5,32(s1)
    8000553e:	0017871b          	addiw	a4,a5,1
    80005542:	0007069b          	sext.w	a3,a4
    80005546:	0027179b          	slliw	a5,a4,0x2
    8000554a:	9fb9                	addw	a5,a5,a4
    8000554c:	0017979b          	slliw	a5,a5,0x1
    80005550:	54d8                	lw	a4,44(s1)
    80005552:	9fb9                	addw	a5,a5,a4
    80005554:	00f95963          	bge	s2,a5,80005566 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005558:	85a6                	mv	a1,s1
    8000555a:	8526                	mv	a0,s1
    8000555c:	ffffd097          	auipc	ra,0xffffd
    80005560:	21a080e7          	jalr	538(ra) # 80002776 <sleep>
    80005564:	bfd1                	j	80005538 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80005566:	0001e517          	auipc	a0,0x1e
    8000556a:	9ba50513          	addi	a0,a0,-1606 # 80022f20 <log>
    8000556e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80005570:	ffffb097          	auipc	ra,0xffffb
    80005574:	726080e7          	jalr	1830(ra) # 80000c96 <release>
      break;
    }
  }
}
    80005578:	60e2                	ld	ra,24(sp)
    8000557a:	6442                	ld	s0,16(sp)
    8000557c:	64a2                	ld	s1,8(sp)
    8000557e:	6902                	ld	s2,0(sp)
    80005580:	6105                	addi	sp,sp,32
    80005582:	8082                	ret

0000000080005584 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005584:	7139                	addi	sp,sp,-64
    80005586:	fc06                	sd	ra,56(sp)
    80005588:	f822                	sd	s0,48(sp)
    8000558a:	f426                	sd	s1,40(sp)
    8000558c:	f04a                	sd	s2,32(sp)
    8000558e:	ec4e                	sd	s3,24(sp)
    80005590:	e852                	sd	s4,16(sp)
    80005592:	e456                	sd	s5,8(sp)
    80005594:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80005596:	0001e497          	auipc	s1,0x1e
    8000559a:	98a48493          	addi	s1,s1,-1654 # 80022f20 <log>
    8000559e:	8526                	mv	a0,s1
    800055a0:	ffffb097          	auipc	ra,0xffffb
    800055a4:	642080e7          	jalr	1602(ra) # 80000be2 <acquire>
  log.outstanding -= 1;
    800055a8:	509c                	lw	a5,32(s1)
    800055aa:	37fd                	addiw	a5,a5,-1
    800055ac:	0007891b          	sext.w	s2,a5
    800055b0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800055b2:	50dc                	lw	a5,36(s1)
    800055b4:	efb9                	bnez	a5,80005612 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800055b6:	06091663          	bnez	s2,80005622 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800055ba:	0001e497          	auipc	s1,0x1e
    800055be:	96648493          	addi	s1,s1,-1690 # 80022f20 <log>
    800055c2:	4785                	li	a5,1
    800055c4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800055c6:	8526                	mv	a0,s1
    800055c8:	ffffb097          	auipc	ra,0xffffb
    800055cc:	6ce080e7          	jalr	1742(ra) # 80000c96 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800055d0:	54dc                	lw	a5,44(s1)
    800055d2:	06f04763          	bgtz	a5,80005640 <end_op+0xbc>
    acquire(&log.lock);
    800055d6:	0001e497          	auipc	s1,0x1e
    800055da:	94a48493          	addi	s1,s1,-1718 # 80022f20 <log>
    800055de:	8526                	mv	a0,s1
    800055e0:	ffffb097          	auipc	ra,0xffffb
    800055e4:	602080e7          	jalr	1538(ra) # 80000be2 <acquire>
    log.committing = 0;
    800055e8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800055ec:	8526                	mv	a0,s1
    800055ee:	ffffd097          	auipc	ra,0xffffd
    800055f2:	58e080e7          	jalr	1422(ra) # 80002b7c <wakeup>
    release(&log.lock);
    800055f6:	8526                	mv	a0,s1
    800055f8:	ffffb097          	auipc	ra,0xffffb
    800055fc:	69e080e7          	jalr	1694(ra) # 80000c96 <release>
}
    80005600:	70e2                	ld	ra,56(sp)
    80005602:	7442                	ld	s0,48(sp)
    80005604:	74a2                	ld	s1,40(sp)
    80005606:	7902                	ld	s2,32(sp)
    80005608:	69e2                	ld	s3,24(sp)
    8000560a:	6a42                	ld	s4,16(sp)
    8000560c:	6aa2                	ld	s5,8(sp)
    8000560e:	6121                	addi	sp,sp,64
    80005610:	8082                	ret
    panic("log.committing");
    80005612:	00004517          	auipc	a0,0x4
    80005616:	2fe50513          	addi	a0,a0,766 # 80009910 <syscalls+0x2d0>
    8000561a:	ffffb097          	auipc	ra,0xffffb
    8000561e:	f22080e7          	jalr	-222(ra) # 8000053c <panic>
    wakeup(&log);
    80005622:	0001e497          	auipc	s1,0x1e
    80005626:	8fe48493          	addi	s1,s1,-1794 # 80022f20 <log>
    8000562a:	8526                	mv	a0,s1
    8000562c:	ffffd097          	auipc	ra,0xffffd
    80005630:	550080e7          	jalr	1360(ra) # 80002b7c <wakeup>
  release(&log.lock);
    80005634:	8526                	mv	a0,s1
    80005636:	ffffb097          	auipc	ra,0xffffb
    8000563a:	660080e7          	jalr	1632(ra) # 80000c96 <release>
  if(do_commit){
    8000563e:	b7c9                	j	80005600 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005640:	0001ea97          	auipc	s5,0x1e
    80005644:	910a8a93          	addi	s5,s5,-1776 # 80022f50 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005648:	0001ea17          	auipc	s4,0x1e
    8000564c:	8d8a0a13          	addi	s4,s4,-1832 # 80022f20 <log>
    80005650:	018a2583          	lw	a1,24(s4)
    80005654:	012585bb          	addw	a1,a1,s2
    80005658:	2585                	addiw	a1,a1,1
    8000565a:	028a2503          	lw	a0,40(s4)
    8000565e:	fffff097          	auipc	ra,0xfffff
    80005662:	cd2080e7          	jalr	-814(ra) # 80004330 <bread>
    80005666:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005668:	000aa583          	lw	a1,0(s5)
    8000566c:	028a2503          	lw	a0,40(s4)
    80005670:	fffff097          	auipc	ra,0xfffff
    80005674:	cc0080e7          	jalr	-832(ra) # 80004330 <bread>
    80005678:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000567a:	40000613          	li	a2,1024
    8000567e:	05850593          	addi	a1,a0,88
    80005682:	05848513          	addi	a0,s1,88
    80005686:	ffffb097          	auipc	ra,0xffffb
    8000568a:	6b8080e7          	jalr	1720(ra) # 80000d3e <memmove>
    bwrite(to);  // write the log
    8000568e:	8526                	mv	a0,s1
    80005690:	fffff097          	auipc	ra,0xfffff
    80005694:	d92080e7          	jalr	-622(ra) # 80004422 <bwrite>
    brelse(from);
    80005698:	854e                	mv	a0,s3
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	dc6080e7          	jalr	-570(ra) # 80004460 <brelse>
    brelse(to);
    800056a2:	8526                	mv	a0,s1
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	dbc080e7          	jalr	-580(ra) # 80004460 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800056ac:	2905                	addiw	s2,s2,1
    800056ae:	0a91                	addi	s5,s5,4
    800056b0:	02ca2783          	lw	a5,44(s4)
    800056b4:	f8f94ee3          	blt	s2,a5,80005650 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800056b8:	00000097          	auipc	ra,0x0
    800056bc:	c6a080e7          	jalr	-918(ra) # 80005322 <write_head>
    install_trans(0); // Now install writes to home locations
    800056c0:	4501                	li	a0,0
    800056c2:	00000097          	auipc	ra,0x0
    800056c6:	cda080e7          	jalr	-806(ra) # 8000539c <install_trans>
    log.lh.n = 0;
    800056ca:	0001e797          	auipc	a5,0x1e
    800056ce:	8807a123          	sw	zero,-1918(a5) # 80022f4c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800056d2:	00000097          	auipc	ra,0x0
    800056d6:	c50080e7          	jalr	-944(ra) # 80005322 <write_head>
    800056da:	bdf5                	j	800055d6 <end_op+0x52>

00000000800056dc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800056dc:	1101                	addi	sp,sp,-32
    800056de:	ec06                	sd	ra,24(sp)
    800056e0:	e822                	sd	s0,16(sp)
    800056e2:	e426                	sd	s1,8(sp)
    800056e4:	e04a                	sd	s2,0(sp)
    800056e6:	1000                	addi	s0,sp,32
    800056e8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800056ea:	0001e917          	auipc	s2,0x1e
    800056ee:	83690913          	addi	s2,s2,-1994 # 80022f20 <log>
    800056f2:	854a                	mv	a0,s2
    800056f4:	ffffb097          	auipc	ra,0xffffb
    800056f8:	4ee080e7          	jalr	1262(ra) # 80000be2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800056fc:	02c92603          	lw	a2,44(s2)
    80005700:	47f5                	li	a5,29
    80005702:	06c7c563          	blt	a5,a2,8000576c <log_write+0x90>
    80005706:	0001e797          	auipc	a5,0x1e
    8000570a:	8367a783          	lw	a5,-1994(a5) # 80022f3c <log+0x1c>
    8000570e:	37fd                	addiw	a5,a5,-1
    80005710:	04f65e63          	bge	a2,a5,8000576c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005714:	0001e797          	auipc	a5,0x1e
    80005718:	82c7a783          	lw	a5,-2004(a5) # 80022f40 <log+0x20>
    8000571c:	06f05063          	blez	a5,8000577c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005720:	4781                	li	a5,0
    80005722:	06c05563          	blez	a2,8000578c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005726:	44cc                	lw	a1,12(s1)
    80005728:	0001e717          	auipc	a4,0x1e
    8000572c:	82870713          	addi	a4,a4,-2008 # 80022f50 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005730:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80005732:	4314                	lw	a3,0(a4)
    80005734:	04b68c63          	beq	a3,a1,8000578c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005738:	2785                	addiw	a5,a5,1
    8000573a:	0711                	addi	a4,a4,4
    8000573c:	fef61be3          	bne	a2,a5,80005732 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005740:	0621                	addi	a2,a2,8
    80005742:	060a                	slli	a2,a2,0x2
    80005744:	0001d797          	auipc	a5,0x1d
    80005748:	7dc78793          	addi	a5,a5,2012 # 80022f20 <log>
    8000574c:	963e                	add	a2,a2,a5
    8000574e:	44dc                	lw	a5,12(s1)
    80005750:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005752:	8526                	mv	a0,s1
    80005754:	fffff097          	auipc	ra,0xfffff
    80005758:	daa080e7          	jalr	-598(ra) # 800044fe <bpin>
    log.lh.n++;
    8000575c:	0001d717          	auipc	a4,0x1d
    80005760:	7c470713          	addi	a4,a4,1988 # 80022f20 <log>
    80005764:	575c                	lw	a5,44(a4)
    80005766:	2785                	addiw	a5,a5,1
    80005768:	d75c                	sw	a5,44(a4)
    8000576a:	a835                	j	800057a6 <log_write+0xca>
    panic("too big a transaction");
    8000576c:	00004517          	auipc	a0,0x4
    80005770:	1b450513          	addi	a0,a0,436 # 80009920 <syscalls+0x2e0>
    80005774:	ffffb097          	auipc	ra,0xffffb
    80005778:	dc8080e7          	jalr	-568(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    8000577c:	00004517          	auipc	a0,0x4
    80005780:	1bc50513          	addi	a0,a0,444 # 80009938 <syscalls+0x2f8>
    80005784:	ffffb097          	auipc	ra,0xffffb
    80005788:	db8080e7          	jalr	-584(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    8000578c:	00878713          	addi	a4,a5,8
    80005790:	00271693          	slli	a3,a4,0x2
    80005794:	0001d717          	auipc	a4,0x1d
    80005798:	78c70713          	addi	a4,a4,1932 # 80022f20 <log>
    8000579c:	9736                	add	a4,a4,a3
    8000579e:	44d4                	lw	a3,12(s1)
    800057a0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800057a2:	faf608e3          	beq	a2,a5,80005752 <log_write+0x76>
  }
  release(&log.lock);
    800057a6:	0001d517          	auipc	a0,0x1d
    800057aa:	77a50513          	addi	a0,a0,1914 # 80022f20 <log>
    800057ae:	ffffb097          	auipc	ra,0xffffb
    800057b2:	4e8080e7          	jalr	1256(ra) # 80000c96 <release>
}
    800057b6:	60e2                	ld	ra,24(sp)
    800057b8:	6442                	ld	s0,16(sp)
    800057ba:	64a2                	ld	s1,8(sp)
    800057bc:	6902                	ld	s2,0(sp)
    800057be:	6105                	addi	sp,sp,32
    800057c0:	8082                	ret

00000000800057c2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800057c2:	1101                	addi	sp,sp,-32
    800057c4:	ec06                	sd	ra,24(sp)
    800057c6:	e822                	sd	s0,16(sp)
    800057c8:	e426                	sd	s1,8(sp)
    800057ca:	e04a                	sd	s2,0(sp)
    800057cc:	1000                	addi	s0,sp,32
    800057ce:	84aa                	mv	s1,a0
    800057d0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800057d2:	00004597          	auipc	a1,0x4
    800057d6:	18658593          	addi	a1,a1,390 # 80009958 <syscalls+0x318>
    800057da:	0521                	addi	a0,a0,8
    800057dc:	ffffb097          	auipc	ra,0xffffb
    800057e0:	376080e7          	jalr	886(ra) # 80000b52 <initlock>
  lk->name = name;
    800057e4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800057e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800057ec:	0204a423          	sw	zero,40(s1)
}
    800057f0:	60e2                	ld	ra,24(sp)
    800057f2:	6442                	ld	s0,16(sp)
    800057f4:	64a2                	ld	s1,8(sp)
    800057f6:	6902                	ld	s2,0(sp)
    800057f8:	6105                	addi	sp,sp,32
    800057fa:	8082                	ret

00000000800057fc <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800057fc:	1101                	addi	sp,sp,-32
    800057fe:	ec06                	sd	ra,24(sp)
    80005800:	e822                	sd	s0,16(sp)
    80005802:	e426                	sd	s1,8(sp)
    80005804:	e04a                	sd	s2,0(sp)
    80005806:	1000                	addi	s0,sp,32
    80005808:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000580a:	00850913          	addi	s2,a0,8
    8000580e:	854a                	mv	a0,s2
    80005810:	ffffb097          	auipc	ra,0xffffb
    80005814:	3d2080e7          	jalr	978(ra) # 80000be2 <acquire>
  while (lk->locked) {
    80005818:	409c                	lw	a5,0(s1)
    8000581a:	cb89                	beqz	a5,8000582c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000581c:	85ca                	mv	a1,s2
    8000581e:	8526                	mv	a0,s1
    80005820:	ffffd097          	auipc	ra,0xffffd
    80005824:	f56080e7          	jalr	-170(ra) # 80002776 <sleep>
  while (lk->locked) {
    80005828:	409c                	lw	a5,0(s1)
    8000582a:	fbed                	bnez	a5,8000581c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000582c:	4785                	li	a5,1
    8000582e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005830:	ffffc097          	auipc	ra,0xffffc
    80005834:	1a4080e7          	jalr	420(ra) # 800019d4 <myproc>
    80005838:	591c                	lw	a5,48(a0)
    8000583a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000583c:	854a                	mv	a0,s2
    8000583e:	ffffb097          	auipc	ra,0xffffb
    80005842:	458080e7          	jalr	1112(ra) # 80000c96 <release>
}
    80005846:	60e2                	ld	ra,24(sp)
    80005848:	6442                	ld	s0,16(sp)
    8000584a:	64a2                	ld	s1,8(sp)
    8000584c:	6902                	ld	s2,0(sp)
    8000584e:	6105                	addi	sp,sp,32
    80005850:	8082                	ret

0000000080005852 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005852:	1101                	addi	sp,sp,-32
    80005854:	ec06                	sd	ra,24(sp)
    80005856:	e822                	sd	s0,16(sp)
    80005858:	e426                	sd	s1,8(sp)
    8000585a:	e04a                	sd	s2,0(sp)
    8000585c:	1000                	addi	s0,sp,32
    8000585e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005860:	00850913          	addi	s2,a0,8
    80005864:	854a                	mv	a0,s2
    80005866:	ffffb097          	auipc	ra,0xffffb
    8000586a:	37c080e7          	jalr	892(ra) # 80000be2 <acquire>
  lk->locked = 0;
    8000586e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005872:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005876:	8526                	mv	a0,s1
    80005878:	ffffd097          	auipc	ra,0xffffd
    8000587c:	304080e7          	jalr	772(ra) # 80002b7c <wakeup>
  release(&lk->lk);
    80005880:	854a                	mv	a0,s2
    80005882:	ffffb097          	auipc	ra,0xffffb
    80005886:	414080e7          	jalr	1044(ra) # 80000c96 <release>
}
    8000588a:	60e2                	ld	ra,24(sp)
    8000588c:	6442                	ld	s0,16(sp)
    8000588e:	64a2                	ld	s1,8(sp)
    80005890:	6902                	ld	s2,0(sp)
    80005892:	6105                	addi	sp,sp,32
    80005894:	8082                	ret

0000000080005896 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005896:	7179                	addi	sp,sp,-48
    80005898:	f406                	sd	ra,40(sp)
    8000589a:	f022                	sd	s0,32(sp)
    8000589c:	ec26                	sd	s1,24(sp)
    8000589e:	e84a                	sd	s2,16(sp)
    800058a0:	e44e                	sd	s3,8(sp)
    800058a2:	1800                	addi	s0,sp,48
    800058a4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800058a6:	00850913          	addi	s2,a0,8
    800058aa:	854a                	mv	a0,s2
    800058ac:	ffffb097          	auipc	ra,0xffffb
    800058b0:	336080e7          	jalr	822(ra) # 80000be2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800058b4:	409c                	lw	a5,0(s1)
    800058b6:	ef99                	bnez	a5,800058d4 <holdingsleep+0x3e>
    800058b8:	4481                	li	s1,0
  release(&lk->lk);
    800058ba:	854a                	mv	a0,s2
    800058bc:	ffffb097          	auipc	ra,0xffffb
    800058c0:	3da080e7          	jalr	986(ra) # 80000c96 <release>
  return r;
}
    800058c4:	8526                	mv	a0,s1
    800058c6:	70a2                	ld	ra,40(sp)
    800058c8:	7402                	ld	s0,32(sp)
    800058ca:	64e2                	ld	s1,24(sp)
    800058cc:	6942                	ld	s2,16(sp)
    800058ce:	69a2                	ld	s3,8(sp)
    800058d0:	6145                	addi	sp,sp,48
    800058d2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800058d4:	0284a983          	lw	s3,40(s1)
    800058d8:	ffffc097          	auipc	ra,0xffffc
    800058dc:	0fc080e7          	jalr	252(ra) # 800019d4 <myproc>
    800058e0:	5904                	lw	s1,48(a0)
    800058e2:	413484b3          	sub	s1,s1,s3
    800058e6:	0014b493          	seqz	s1,s1
    800058ea:	bfc1                	j	800058ba <holdingsleep+0x24>

00000000800058ec <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800058ec:	1141                	addi	sp,sp,-16
    800058ee:	e406                	sd	ra,8(sp)
    800058f0:	e022                	sd	s0,0(sp)
    800058f2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800058f4:	00004597          	auipc	a1,0x4
    800058f8:	07458593          	addi	a1,a1,116 # 80009968 <syscalls+0x328>
    800058fc:	0001d517          	auipc	a0,0x1d
    80005900:	76c50513          	addi	a0,a0,1900 # 80023068 <ftable>
    80005904:	ffffb097          	auipc	ra,0xffffb
    80005908:	24e080e7          	jalr	590(ra) # 80000b52 <initlock>
}
    8000590c:	60a2                	ld	ra,8(sp)
    8000590e:	6402                	ld	s0,0(sp)
    80005910:	0141                	addi	sp,sp,16
    80005912:	8082                	ret

0000000080005914 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005914:	1101                	addi	sp,sp,-32
    80005916:	ec06                	sd	ra,24(sp)
    80005918:	e822                	sd	s0,16(sp)
    8000591a:	e426                	sd	s1,8(sp)
    8000591c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000591e:	0001d517          	auipc	a0,0x1d
    80005922:	74a50513          	addi	a0,a0,1866 # 80023068 <ftable>
    80005926:	ffffb097          	auipc	ra,0xffffb
    8000592a:	2bc080e7          	jalr	700(ra) # 80000be2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000592e:	0001d497          	auipc	s1,0x1d
    80005932:	75248493          	addi	s1,s1,1874 # 80023080 <ftable+0x18>
    80005936:	0001e717          	auipc	a4,0x1e
    8000593a:	6ea70713          	addi	a4,a4,1770 # 80024020 <ftable+0xfb8>
    if(f->ref == 0){
    8000593e:	40dc                	lw	a5,4(s1)
    80005940:	cf99                	beqz	a5,8000595e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005942:	02848493          	addi	s1,s1,40
    80005946:	fee49ce3          	bne	s1,a4,8000593e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000594a:	0001d517          	auipc	a0,0x1d
    8000594e:	71e50513          	addi	a0,a0,1822 # 80023068 <ftable>
    80005952:	ffffb097          	auipc	ra,0xffffb
    80005956:	344080e7          	jalr	836(ra) # 80000c96 <release>
  return 0;
    8000595a:	4481                	li	s1,0
    8000595c:	a819                	j	80005972 <filealloc+0x5e>
      f->ref = 1;
    8000595e:	4785                	li	a5,1
    80005960:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005962:	0001d517          	auipc	a0,0x1d
    80005966:	70650513          	addi	a0,a0,1798 # 80023068 <ftable>
    8000596a:	ffffb097          	auipc	ra,0xffffb
    8000596e:	32c080e7          	jalr	812(ra) # 80000c96 <release>
}
    80005972:	8526                	mv	a0,s1
    80005974:	60e2                	ld	ra,24(sp)
    80005976:	6442                	ld	s0,16(sp)
    80005978:	64a2                	ld	s1,8(sp)
    8000597a:	6105                	addi	sp,sp,32
    8000597c:	8082                	ret

000000008000597e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000597e:	1101                	addi	sp,sp,-32
    80005980:	ec06                	sd	ra,24(sp)
    80005982:	e822                	sd	s0,16(sp)
    80005984:	e426                	sd	s1,8(sp)
    80005986:	1000                	addi	s0,sp,32
    80005988:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000598a:	0001d517          	auipc	a0,0x1d
    8000598e:	6de50513          	addi	a0,a0,1758 # 80023068 <ftable>
    80005992:	ffffb097          	auipc	ra,0xffffb
    80005996:	250080e7          	jalr	592(ra) # 80000be2 <acquire>
  if(f->ref < 1)
    8000599a:	40dc                	lw	a5,4(s1)
    8000599c:	02f05263          	blez	a5,800059c0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800059a0:	2785                	addiw	a5,a5,1
    800059a2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800059a4:	0001d517          	auipc	a0,0x1d
    800059a8:	6c450513          	addi	a0,a0,1732 # 80023068 <ftable>
    800059ac:	ffffb097          	auipc	ra,0xffffb
    800059b0:	2ea080e7          	jalr	746(ra) # 80000c96 <release>
  return f;
}
    800059b4:	8526                	mv	a0,s1
    800059b6:	60e2                	ld	ra,24(sp)
    800059b8:	6442                	ld	s0,16(sp)
    800059ba:	64a2                	ld	s1,8(sp)
    800059bc:	6105                	addi	sp,sp,32
    800059be:	8082                	ret
    panic("filedup");
    800059c0:	00004517          	auipc	a0,0x4
    800059c4:	fb050513          	addi	a0,a0,-80 # 80009970 <syscalls+0x330>
    800059c8:	ffffb097          	auipc	ra,0xffffb
    800059cc:	b74080e7          	jalr	-1164(ra) # 8000053c <panic>

00000000800059d0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800059d0:	7139                	addi	sp,sp,-64
    800059d2:	fc06                	sd	ra,56(sp)
    800059d4:	f822                	sd	s0,48(sp)
    800059d6:	f426                	sd	s1,40(sp)
    800059d8:	f04a                	sd	s2,32(sp)
    800059da:	ec4e                	sd	s3,24(sp)
    800059dc:	e852                	sd	s4,16(sp)
    800059de:	e456                	sd	s5,8(sp)
    800059e0:	0080                	addi	s0,sp,64
    800059e2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800059e4:	0001d517          	auipc	a0,0x1d
    800059e8:	68450513          	addi	a0,a0,1668 # 80023068 <ftable>
    800059ec:	ffffb097          	auipc	ra,0xffffb
    800059f0:	1f6080e7          	jalr	502(ra) # 80000be2 <acquire>
  if(f->ref < 1)
    800059f4:	40dc                	lw	a5,4(s1)
    800059f6:	06f05163          	blez	a5,80005a58 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800059fa:	37fd                	addiw	a5,a5,-1
    800059fc:	0007871b          	sext.w	a4,a5
    80005a00:	c0dc                	sw	a5,4(s1)
    80005a02:	06e04363          	bgtz	a4,80005a68 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005a06:	0004a903          	lw	s2,0(s1)
    80005a0a:	0094ca83          	lbu	s5,9(s1)
    80005a0e:	0104ba03          	ld	s4,16(s1)
    80005a12:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005a16:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005a1a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005a1e:	0001d517          	auipc	a0,0x1d
    80005a22:	64a50513          	addi	a0,a0,1610 # 80023068 <ftable>
    80005a26:	ffffb097          	auipc	ra,0xffffb
    80005a2a:	270080e7          	jalr	624(ra) # 80000c96 <release>

  if(ff.type == FD_PIPE){
    80005a2e:	4785                	li	a5,1
    80005a30:	04f90d63          	beq	s2,a5,80005a8a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005a34:	3979                	addiw	s2,s2,-2
    80005a36:	4785                	li	a5,1
    80005a38:	0527e063          	bltu	a5,s2,80005a78 <fileclose+0xa8>
    begin_op();
    80005a3c:	00000097          	auipc	ra,0x0
    80005a40:	ac8080e7          	jalr	-1336(ra) # 80005504 <begin_op>
    iput(ff.ip);
    80005a44:	854e                	mv	a0,s3
    80005a46:	fffff097          	auipc	ra,0xfffff
    80005a4a:	2a6080e7          	jalr	678(ra) # 80004cec <iput>
    end_op();
    80005a4e:	00000097          	auipc	ra,0x0
    80005a52:	b36080e7          	jalr	-1226(ra) # 80005584 <end_op>
    80005a56:	a00d                	j	80005a78 <fileclose+0xa8>
    panic("fileclose");
    80005a58:	00004517          	auipc	a0,0x4
    80005a5c:	f2050513          	addi	a0,a0,-224 # 80009978 <syscalls+0x338>
    80005a60:	ffffb097          	auipc	ra,0xffffb
    80005a64:	adc080e7          	jalr	-1316(ra) # 8000053c <panic>
    release(&ftable.lock);
    80005a68:	0001d517          	auipc	a0,0x1d
    80005a6c:	60050513          	addi	a0,a0,1536 # 80023068 <ftable>
    80005a70:	ffffb097          	auipc	ra,0xffffb
    80005a74:	226080e7          	jalr	550(ra) # 80000c96 <release>
  }
}
    80005a78:	70e2                	ld	ra,56(sp)
    80005a7a:	7442                	ld	s0,48(sp)
    80005a7c:	74a2                	ld	s1,40(sp)
    80005a7e:	7902                	ld	s2,32(sp)
    80005a80:	69e2                	ld	s3,24(sp)
    80005a82:	6a42                	ld	s4,16(sp)
    80005a84:	6aa2                	ld	s5,8(sp)
    80005a86:	6121                	addi	sp,sp,64
    80005a88:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005a8a:	85d6                	mv	a1,s5
    80005a8c:	8552                	mv	a0,s4
    80005a8e:	00000097          	auipc	ra,0x0
    80005a92:	34c080e7          	jalr	844(ra) # 80005dda <pipeclose>
    80005a96:	b7cd                	j	80005a78 <fileclose+0xa8>

0000000080005a98 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005a98:	715d                	addi	sp,sp,-80
    80005a9a:	e486                	sd	ra,72(sp)
    80005a9c:	e0a2                	sd	s0,64(sp)
    80005a9e:	fc26                	sd	s1,56(sp)
    80005aa0:	f84a                	sd	s2,48(sp)
    80005aa2:	f44e                	sd	s3,40(sp)
    80005aa4:	0880                	addi	s0,sp,80
    80005aa6:	84aa                	mv	s1,a0
    80005aa8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005aaa:	ffffc097          	auipc	ra,0xffffc
    80005aae:	f2a080e7          	jalr	-214(ra) # 800019d4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005ab2:	409c                	lw	a5,0(s1)
    80005ab4:	37f9                	addiw	a5,a5,-2
    80005ab6:	4705                	li	a4,1
    80005ab8:	04f76763          	bltu	a4,a5,80005b06 <filestat+0x6e>
    80005abc:	892a                	mv	s2,a0
    ilock(f->ip);
    80005abe:	6c88                	ld	a0,24(s1)
    80005ac0:	fffff097          	auipc	ra,0xfffff
    80005ac4:	072080e7          	jalr	114(ra) # 80004b32 <ilock>
    stati(f->ip, &st);
    80005ac8:	fb840593          	addi	a1,s0,-72
    80005acc:	6c88                	ld	a0,24(s1)
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	2ee080e7          	jalr	750(ra) # 80004dbc <stati>
    iunlock(f->ip);
    80005ad6:	6c88                	ld	a0,24(s1)
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	11c080e7          	jalr	284(ra) # 80004bf4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005ae0:	46e1                	li	a3,24
    80005ae2:	fb840613          	addi	a2,s0,-72
    80005ae6:	85ce                	mv	a1,s3
    80005ae8:	05893503          	ld	a0,88(s2)
    80005aec:	ffffc097          	auipc	ra,0xffffc
    80005af0:	baa080e7          	jalr	-1110(ra) # 80001696 <copyout>
    80005af4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005af8:	60a6                	ld	ra,72(sp)
    80005afa:	6406                	ld	s0,64(sp)
    80005afc:	74e2                	ld	s1,56(sp)
    80005afe:	7942                	ld	s2,48(sp)
    80005b00:	79a2                	ld	s3,40(sp)
    80005b02:	6161                	addi	sp,sp,80
    80005b04:	8082                	ret
  return -1;
    80005b06:	557d                	li	a0,-1
    80005b08:	bfc5                	j	80005af8 <filestat+0x60>

0000000080005b0a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005b0a:	7179                	addi	sp,sp,-48
    80005b0c:	f406                	sd	ra,40(sp)
    80005b0e:	f022                	sd	s0,32(sp)
    80005b10:	ec26                	sd	s1,24(sp)
    80005b12:	e84a                	sd	s2,16(sp)
    80005b14:	e44e                	sd	s3,8(sp)
    80005b16:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005b18:	00854783          	lbu	a5,8(a0)
    80005b1c:	c3d5                	beqz	a5,80005bc0 <fileread+0xb6>
    80005b1e:	84aa                	mv	s1,a0
    80005b20:	89ae                	mv	s3,a1
    80005b22:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005b24:	411c                	lw	a5,0(a0)
    80005b26:	4705                	li	a4,1
    80005b28:	04e78963          	beq	a5,a4,80005b7a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005b2c:	470d                	li	a4,3
    80005b2e:	04e78d63          	beq	a5,a4,80005b88 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005b32:	4709                	li	a4,2
    80005b34:	06e79e63          	bne	a5,a4,80005bb0 <fileread+0xa6>
    ilock(f->ip);
    80005b38:	6d08                	ld	a0,24(a0)
    80005b3a:	fffff097          	auipc	ra,0xfffff
    80005b3e:	ff8080e7          	jalr	-8(ra) # 80004b32 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005b42:	874a                	mv	a4,s2
    80005b44:	5094                	lw	a3,32(s1)
    80005b46:	864e                	mv	a2,s3
    80005b48:	4585                	li	a1,1
    80005b4a:	6c88                	ld	a0,24(s1)
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	29a080e7          	jalr	666(ra) # 80004de6 <readi>
    80005b54:	892a                	mv	s2,a0
    80005b56:	00a05563          	blez	a0,80005b60 <fileread+0x56>
      f->off += r;
    80005b5a:	509c                	lw	a5,32(s1)
    80005b5c:	9fa9                	addw	a5,a5,a0
    80005b5e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005b60:	6c88                	ld	a0,24(s1)
    80005b62:	fffff097          	auipc	ra,0xfffff
    80005b66:	092080e7          	jalr	146(ra) # 80004bf4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005b6a:	854a                	mv	a0,s2
    80005b6c:	70a2                	ld	ra,40(sp)
    80005b6e:	7402                	ld	s0,32(sp)
    80005b70:	64e2                	ld	s1,24(sp)
    80005b72:	6942                	ld	s2,16(sp)
    80005b74:	69a2                	ld	s3,8(sp)
    80005b76:	6145                	addi	sp,sp,48
    80005b78:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005b7a:	6908                	ld	a0,16(a0)
    80005b7c:	00000097          	auipc	ra,0x0
    80005b80:	3c8080e7          	jalr	968(ra) # 80005f44 <piperead>
    80005b84:	892a                	mv	s2,a0
    80005b86:	b7d5                	j	80005b6a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005b88:	02451783          	lh	a5,36(a0)
    80005b8c:	03079693          	slli	a3,a5,0x30
    80005b90:	92c1                	srli	a3,a3,0x30
    80005b92:	4725                	li	a4,9
    80005b94:	02d76863          	bltu	a4,a3,80005bc4 <fileread+0xba>
    80005b98:	0792                	slli	a5,a5,0x4
    80005b9a:	0001d717          	auipc	a4,0x1d
    80005b9e:	42e70713          	addi	a4,a4,1070 # 80022fc8 <devsw>
    80005ba2:	97ba                	add	a5,a5,a4
    80005ba4:	639c                	ld	a5,0(a5)
    80005ba6:	c38d                	beqz	a5,80005bc8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005ba8:	4505                	li	a0,1
    80005baa:	9782                	jalr	a5
    80005bac:	892a                	mv	s2,a0
    80005bae:	bf75                	j	80005b6a <fileread+0x60>
    panic("fileread");
    80005bb0:	00004517          	auipc	a0,0x4
    80005bb4:	dd850513          	addi	a0,a0,-552 # 80009988 <syscalls+0x348>
    80005bb8:	ffffb097          	auipc	ra,0xffffb
    80005bbc:	984080e7          	jalr	-1660(ra) # 8000053c <panic>
    return -1;
    80005bc0:	597d                	li	s2,-1
    80005bc2:	b765                	j	80005b6a <fileread+0x60>
      return -1;
    80005bc4:	597d                	li	s2,-1
    80005bc6:	b755                	j	80005b6a <fileread+0x60>
    80005bc8:	597d                	li	s2,-1
    80005bca:	b745                	j	80005b6a <fileread+0x60>

0000000080005bcc <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005bcc:	715d                	addi	sp,sp,-80
    80005bce:	e486                	sd	ra,72(sp)
    80005bd0:	e0a2                	sd	s0,64(sp)
    80005bd2:	fc26                	sd	s1,56(sp)
    80005bd4:	f84a                	sd	s2,48(sp)
    80005bd6:	f44e                	sd	s3,40(sp)
    80005bd8:	f052                	sd	s4,32(sp)
    80005bda:	ec56                	sd	s5,24(sp)
    80005bdc:	e85a                	sd	s6,16(sp)
    80005bde:	e45e                	sd	s7,8(sp)
    80005be0:	e062                	sd	s8,0(sp)
    80005be2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005be4:	00954783          	lbu	a5,9(a0)
    80005be8:	10078663          	beqz	a5,80005cf4 <filewrite+0x128>
    80005bec:	892a                	mv	s2,a0
    80005bee:	8aae                	mv	s5,a1
    80005bf0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005bf2:	411c                	lw	a5,0(a0)
    80005bf4:	4705                	li	a4,1
    80005bf6:	02e78263          	beq	a5,a4,80005c1a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005bfa:	470d                	li	a4,3
    80005bfc:	02e78663          	beq	a5,a4,80005c28 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005c00:	4709                	li	a4,2
    80005c02:	0ee79163          	bne	a5,a4,80005ce4 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005c06:	0ac05d63          	blez	a2,80005cc0 <filewrite+0xf4>
    int i = 0;
    80005c0a:	4981                	li	s3,0
    80005c0c:	6b05                	lui	s6,0x1
    80005c0e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005c12:	6b85                	lui	s7,0x1
    80005c14:	c00b8b9b          	addiw	s7,s7,-1024
    80005c18:	a861                	j	80005cb0 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005c1a:	6908                	ld	a0,16(a0)
    80005c1c:	00000097          	auipc	ra,0x0
    80005c20:	22e080e7          	jalr	558(ra) # 80005e4a <pipewrite>
    80005c24:	8a2a                	mv	s4,a0
    80005c26:	a045                	j	80005cc6 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005c28:	02451783          	lh	a5,36(a0)
    80005c2c:	03079693          	slli	a3,a5,0x30
    80005c30:	92c1                	srli	a3,a3,0x30
    80005c32:	4725                	li	a4,9
    80005c34:	0cd76263          	bltu	a4,a3,80005cf8 <filewrite+0x12c>
    80005c38:	0792                	slli	a5,a5,0x4
    80005c3a:	0001d717          	auipc	a4,0x1d
    80005c3e:	38e70713          	addi	a4,a4,910 # 80022fc8 <devsw>
    80005c42:	97ba                	add	a5,a5,a4
    80005c44:	679c                	ld	a5,8(a5)
    80005c46:	cbdd                	beqz	a5,80005cfc <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005c48:	4505                	li	a0,1
    80005c4a:	9782                	jalr	a5
    80005c4c:	8a2a                	mv	s4,a0
    80005c4e:	a8a5                	j	80005cc6 <filewrite+0xfa>
    80005c50:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005c54:	00000097          	auipc	ra,0x0
    80005c58:	8b0080e7          	jalr	-1872(ra) # 80005504 <begin_op>
      ilock(f->ip);
    80005c5c:	01893503          	ld	a0,24(s2)
    80005c60:	fffff097          	auipc	ra,0xfffff
    80005c64:	ed2080e7          	jalr	-302(ra) # 80004b32 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005c68:	8762                	mv	a4,s8
    80005c6a:	02092683          	lw	a3,32(s2)
    80005c6e:	01598633          	add	a2,s3,s5
    80005c72:	4585                	li	a1,1
    80005c74:	01893503          	ld	a0,24(s2)
    80005c78:	fffff097          	auipc	ra,0xfffff
    80005c7c:	266080e7          	jalr	614(ra) # 80004ede <writei>
    80005c80:	84aa                	mv	s1,a0
    80005c82:	00a05763          	blez	a0,80005c90 <filewrite+0xc4>
        f->off += r;
    80005c86:	02092783          	lw	a5,32(s2)
    80005c8a:	9fa9                	addw	a5,a5,a0
    80005c8c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005c90:	01893503          	ld	a0,24(s2)
    80005c94:	fffff097          	auipc	ra,0xfffff
    80005c98:	f60080e7          	jalr	-160(ra) # 80004bf4 <iunlock>
      end_op();
    80005c9c:	00000097          	auipc	ra,0x0
    80005ca0:	8e8080e7          	jalr	-1816(ra) # 80005584 <end_op>

      if(r != n1){
    80005ca4:	009c1f63          	bne	s8,s1,80005cc2 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005ca8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005cac:	0149db63          	bge	s3,s4,80005cc2 <filewrite+0xf6>
      int n1 = n - i;
    80005cb0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005cb4:	84be                	mv	s1,a5
    80005cb6:	2781                	sext.w	a5,a5
    80005cb8:	f8fb5ce3          	bge	s6,a5,80005c50 <filewrite+0x84>
    80005cbc:	84de                	mv	s1,s7
    80005cbe:	bf49                	j	80005c50 <filewrite+0x84>
    int i = 0;
    80005cc0:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005cc2:	013a1f63          	bne	s4,s3,80005ce0 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005cc6:	8552                	mv	a0,s4
    80005cc8:	60a6                	ld	ra,72(sp)
    80005cca:	6406                	ld	s0,64(sp)
    80005ccc:	74e2                	ld	s1,56(sp)
    80005cce:	7942                	ld	s2,48(sp)
    80005cd0:	79a2                	ld	s3,40(sp)
    80005cd2:	7a02                	ld	s4,32(sp)
    80005cd4:	6ae2                	ld	s5,24(sp)
    80005cd6:	6b42                	ld	s6,16(sp)
    80005cd8:	6ba2                	ld	s7,8(sp)
    80005cda:	6c02                	ld	s8,0(sp)
    80005cdc:	6161                	addi	sp,sp,80
    80005cde:	8082                	ret
    ret = (i == n ? n : -1);
    80005ce0:	5a7d                	li	s4,-1
    80005ce2:	b7d5                	j	80005cc6 <filewrite+0xfa>
    panic("filewrite");
    80005ce4:	00004517          	auipc	a0,0x4
    80005ce8:	cb450513          	addi	a0,a0,-844 # 80009998 <syscalls+0x358>
    80005cec:	ffffb097          	auipc	ra,0xffffb
    80005cf0:	850080e7          	jalr	-1968(ra) # 8000053c <panic>
    return -1;
    80005cf4:	5a7d                	li	s4,-1
    80005cf6:	bfc1                	j	80005cc6 <filewrite+0xfa>
      return -1;
    80005cf8:	5a7d                	li	s4,-1
    80005cfa:	b7f1                	j	80005cc6 <filewrite+0xfa>
    80005cfc:	5a7d                	li	s4,-1
    80005cfe:	b7e1                	j	80005cc6 <filewrite+0xfa>

0000000080005d00 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005d00:	7179                	addi	sp,sp,-48
    80005d02:	f406                	sd	ra,40(sp)
    80005d04:	f022                	sd	s0,32(sp)
    80005d06:	ec26                	sd	s1,24(sp)
    80005d08:	e84a                	sd	s2,16(sp)
    80005d0a:	e44e                	sd	s3,8(sp)
    80005d0c:	e052                	sd	s4,0(sp)
    80005d0e:	1800                	addi	s0,sp,48
    80005d10:	84aa                	mv	s1,a0
    80005d12:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005d14:	0005b023          	sd	zero,0(a1)
    80005d18:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005d1c:	00000097          	auipc	ra,0x0
    80005d20:	bf8080e7          	jalr	-1032(ra) # 80005914 <filealloc>
    80005d24:	e088                	sd	a0,0(s1)
    80005d26:	c551                	beqz	a0,80005db2 <pipealloc+0xb2>
    80005d28:	00000097          	auipc	ra,0x0
    80005d2c:	bec080e7          	jalr	-1044(ra) # 80005914 <filealloc>
    80005d30:	00aa3023          	sd	a0,0(s4)
    80005d34:	c92d                	beqz	a0,80005da6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005d36:	ffffb097          	auipc	ra,0xffffb
    80005d3a:	dbc080e7          	jalr	-580(ra) # 80000af2 <kalloc>
    80005d3e:	892a                	mv	s2,a0
    80005d40:	c125                	beqz	a0,80005da0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005d42:	4985                	li	s3,1
    80005d44:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005d48:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005d4c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005d50:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005d54:	00004597          	auipc	a1,0x4
    80005d58:	c5458593          	addi	a1,a1,-940 # 800099a8 <syscalls+0x368>
    80005d5c:	ffffb097          	auipc	ra,0xffffb
    80005d60:	df6080e7          	jalr	-522(ra) # 80000b52 <initlock>
  (*f0)->type = FD_PIPE;
    80005d64:	609c                	ld	a5,0(s1)
    80005d66:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005d6a:	609c                	ld	a5,0(s1)
    80005d6c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005d70:	609c                	ld	a5,0(s1)
    80005d72:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005d76:	609c                	ld	a5,0(s1)
    80005d78:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005d7c:	000a3783          	ld	a5,0(s4)
    80005d80:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005d84:	000a3783          	ld	a5,0(s4)
    80005d88:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005d8c:	000a3783          	ld	a5,0(s4)
    80005d90:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005d94:	000a3783          	ld	a5,0(s4)
    80005d98:	0127b823          	sd	s2,16(a5)
  return 0;
    80005d9c:	4501                	li	a0,0
    80005d9e:	a025                	j	80005dc6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005da0:	6088                	ld	a0,0(s1)
    80005da2:	e501                	bnez	a0,80005daa <pipealloc+0xaa>
    80005da4:	a039                	j	80005db2 <pipealloc+0xb2>
    80005da6:	6088                	ld	a0,0(s1)
    80005da8:	c51d                	beqz	a0,80005dd6 <pipealloc+0xd6>
    fileclose(*f0);
    80005daa:	00000097          	auipc	ra,0x0
    80005dae:	c26080e7          	jalr	-986(ra) # 800059d0 <fileclose>
  if(*f1)
    80005db2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005db6:	557d                	li	a0,-1
  if(*f1)
    80005db8:	c799                	beqz	a5,80005dc6 <pipealloc+0xc6>
    fileclose(*f1);
    80005dba:	853e                	mv	a0,a5
    80005dbc:	00000097          	auipc	ra,0x0
    80005dc0:	c14080e7          	jalr	-1004(ra) # 800059d0 <fileclose>
  return -1;
    80005dc4:	557d                	li	a0,-1
}
    80005dc6:	70a2                	ld	ra,40(sp)
    80005dc8:	7402                	ld	s0,32(sp)
    80005dca:	64e2                	ld	s1,24(sp)
    80005dcc:	6942                	ld	s2,16(sp)
    80005dce:	69a2                	ld	s3,8(sp)
    80005dd0:	6a02                	ld	s4,0(sp)
    80005dd2:	6145                	addi	sp,sp,48
    80005dd4:	8082                	ret
  return -1;
    80005dd6:	557d                	li	a0,-1
    80005dd8:	b7fd                	j	80005dc6 <pipealloc+0xc6>

0000000080005dda <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005dda:	1101                	addi	sp,sp,-32
    80005ddc:	ec06                	sd	ra,24(sp)
    80005dde:	e822                	sd	s0,16(sp)
    80005de0:	e426                	sd	s1,8(sp)
    80005de2:	e04a                	sd	s2,0(sp)
    80005de4:	1000                	addi	s0,sp,32
    80005de6:	84aa                	mv	s1,a0
    80005de8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005dea:	ffffb097          	auipc	ra,0xffffb
    80005dee:	df8080e7          	jalr	-520(ra) # 80000be2 <acquire>
  if(writable){
    80005df2:	02090d63          	beqz	s2,80005e2c <pipeclose+0x52>
    pi->writeopen = 0;
    80005df6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005dfa:	21848513          	addi	a0,s1,536
    80005dfe:	ffffd097          	auipc	ra,0xffffd
    80005e02:	d7e080e7          	jalr	-642(ra) # 80002b7c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005e06:	2204b783          	ld	a5,544(s1)
    80005e0a:	eb95                	bnez	a5,80005e3e <pipeclose+0x64>
    release(&pi->lock);
    80005e0c:	8526                	mv	a0,s1
    80005e0e:	ffffb097          	auipc	ra,0xffffb
    80005e12:	e88080e7          	jalr	-376(ra) # 80000c96 <release>
    kfree((char*)pi);
    80005e16:	8526                	mv	a0,s1
    80005e18:	ffffb097          	auipc	ra,0xffffb
    80005e1c:	bde080e7          	jalr	-1058(ra) # 800009f6 <kfree>
  } else
    release(&pi->lock);
}
    80005e20:	60e2                	ld	ra,24(sp)
    80005e22:	6442                	ld	s0,16(sp)
    80005e24:	64a2                	ld	s1,8(sp)
    80005e26:	6902                	ld	s2,0(sp)
    80005e28:	6105                	addi	sp,sp,32
    80005e2a:	8082                	ret
    pi->readopen = 0;
    80005e2c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005e30:	21c48513          	addi	a0,s1,540
    80005e34:	ffffd097          	auipc	ra,0xffffd
    80005e38:	d48080e7          	jalr	-696(ra) # 80002b7c <wakeup>
    80005e3c:	b7e9                	j	80005e06 <pipeclose+0x2c>
    release(&pi->lock);
    80005e3e:	8526                	mv	a0,s1
    80005e40:	ffffb097          	auipc	ra,0xffffb
    80005e44:	e56080e7          	jalr	-426(ra) # 80000c96 <release>
}
    80005e48:	bfe1                	j	80005e20 <pipeclose+0x46>

0000000080005e4a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005e4a:	7159                	addi	sp,sp,-112
    80005e4c:	f486                	sd	ra,104(sp)
    80005e4e:	f0a2                	sd	s0,96(sp)
    80005e50:	eca6                	sd	s1,88(sp)
    80005e52:	e8ca                	sd	s2,80(sp)
    80005e54:	e4ce                	sd	s3,72(sp)
    80005e56:	e0d2                	sd	s4,64(sp)
    80005e58:	fc56                	sd	s5,56(sp)
    80005e5a:	f85a                	sd	s6,48(sp)
    80005e5c:	f45e                	sd	s7,40(sp)
    80005e5e:	f062                	sd	s8,32(sp)
    80005e60:	ec66                	sd	s9,24(sp)
    80005e62:	1880                	addi	s0,sp,112
    80005e64:	84aa                	mv	s1,a0
    80005e66:	8aae                	mv	s5,a1
    80005e68:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005e6a:	ffffc097          	auipc	ra,0xffffc
    80005e6e:	b6a080e7          	jalr	-1174(ra) # 800019d4 <myproc>
    80005e72:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005e74:	8526                	mv	a0,s1
    80005e76:	ffffb097          	auipc	ra,0xffffb
    80005e7a:	d6c080e7          	jalr	-660(ra) # 80000be2 <acquire>
  while(i < n){
    80005e7e:	0d405163          	blez	s4,80005f40 <pipewrite+0xf6>
    80005e82:	8ba6                	mv	s7,s1
  int i = 0;
    80005e84:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005e86:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005e88:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005e8c:	21c48c13          	addi	s8,s1,540
    80005e90:	a08d                	j	80005ef2 <pipewrite+0xa8>
      release(&pi->lock);
    80005e92:	8526                	mv	a0,s1
    80005e94:	ffffb097          	auipc	ra,0xffffb
    80005e98:	e02080e7          	jalr	-510(ra) # 80000c96 <release>
      return -1;
    80005e9c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005e9e:	854a                	mv	a0,s2
    80005ea0:	70a6                	ld	ra,104(sp)
    80005ea2:	7406                	ld	s0,96(sp)
    80005ea4:	64e6                	ld	s1,88(sp)
    80005ea6:	6946                	ld	s2,80(sp)
    80005ea8:	69a6                	ld	s3,72(sp)
    80005eaa:	6a06                	ld	s4,64(sp)
    80005eac:	7ae2                	ld	s5,56(sp)
    80005eae:	7b42                	ld	s6,48(sp)
    80005eb0:	7ba2                	ld	s7,40(sp)
    80005eb2:	7c02                	ld	s8,32(sp)
    80005eb4:	6ce2                	ld	s9,24(sp)
    80005eb6:	6165                	addi	sp,sp,112
    80005eb8:	8082                	ret
      wakeup(&pi->nread);
    80005eba:	8566                	mv	a0,s9
    80005ebc:	ffffd097          	auipc	ra,0xffffd
    80005ec0:	cc0080e7          	jalr	-832(ra) # 80002b7c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005ec4:	85de                	mv	a1,s7
    80005ec6:	8562                	mv	a0,s8
    80005ec8:	ffffd097          	auipc	ra,0xffffd
    80005ecc:	8ae080e7          	jalr	-1874(ra) # 80002776 <sleep>
    80005ed0:	a839                	j	80005eee <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005ed2:	21c4a783          	lw	a5,540(s1)
    80005ed6:	0017871b          	addiw	a4,a5,1
    80005eda:	20e4ae23          	sw	a4,540(s1)
    80005ede:	1ff7f793          	andi	a5,a5,511
    80005ee2:	97a6                	add	a5,a5,s1
    80005ee4:	f9f44703          	lbu	a4,-97(s0)
    80005ee8:	00e78c23          	sb	a4,24(a5)
      i++;
    80005eec:	2905                	addiw	s2,s2,1
  while(i < n){
    80005eee:	03495d63          	bge	s2,s4,80005f28 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80005ef2:	2204a783          	lw	a5,544(s1)
    80005ef6:	dfd1                	beqz	a5,80005e92 <pipewrite+0x48>
    80005ef8:	0289a783          	lw	a5,40(s3)
    80005efc:	fbd9                	bnez	a5,80005e92 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005efe:	2184a783          	lw	a5,536(s1)
    80005f02:	21c4a703          	lw	a4,540(s1)
    80005f06:	2007879b          	addiw	a5,a5,512
    80005f0a:	faf708e3          	beq	a4,a5,80005eba <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005f0e:	4685                	li	a3,1
    80005f10:	01590633          	add	a2,s2,s5
    80005f14:	f9f40593          	addi	a1,s0,-97
    80005f18:	0589b503          	ld	a0,88(s3)
    80005f1c:	ffffc097          	auipc	ra,0xffffc
    80005f20:	806080e7          	jalr	-2042(ra) # 80001722 <copyin>
    80005f24:	fb6517e3          	bne	a0,s6,80005ed2 <pipewrite+0x88>
  wakeup(&pi->nread);
    80005f28:	21848513          	addi	a0,s1,536
    80005f2c:	ffffd097          	auipc	ra,0xffffd
    80005f30:	c50080e7          	jalr	-944(ra) # 80002b7c <wakeup>
  release(&pi->lock);
    80005f34:	8526                	mv	a0,s1
    80005f36:	ffffb097          	auipc	ra,0xffffb
    80005f3a:	d60080e7          	jalr	-672(ra) # 80000c96 <release>
  return i;
    80005f3e:	b785                	j	80005e9e <pipewrite+0x54>
  int i = 0;
    80005f40:	4901                	li	s2,0
    80005f42:	b7dd                	j	80005f28 <pipewrite+0xde>

0000000080005f44 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005f44:	715d                	addi	sp,sp,-80
    80005f46:	e486                	sd	ra,72(sp)
    80005f48:	e0a2                	sd	s0,64(sp)
    80005f4a:	fc26                	sd	s1,56(sp)
    80005f4c:	f84a                	sd	s2,48(sp)
    80005f4e:	f44e                	sd	s3,40(sp)
    80005f50:	f052                	sd	s4,32(sp)
    80005f52:	ec56                	sd	s5,24(sp)
    80005f54:	e85a                	sd	s6,16(sp)
    80005f56:	0880                	addi	s0,sp,80
    80005f58:	84aa                	mv	s1,a0
    80005f5a:	892e                	mv	s2,a1
    80005f5c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005f5e:	ffffc097          	auipc	ra,0xffffc
    80005f62:	a76080e7          	jalr	-1418(ra) # 800019d4 <myproc>
    80005f66:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005f68:	8b26                	mv	s6,s1
    80005f6a:	8526                	mv	a0,s1
    80005f6c:	ffffb097          	auipc	ra,0xffffb
    80005f70:	c76080e7          	jalr	-906(ra) # 80000be2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005f74:	2184a703          	lw	a4,536(s1)
    80005f78:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005f7c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005f80:	02f71463          	bne	a4,a5,80005fa8 <piperead+0x64>
    80005f84:	2244a783          	lw	a5,548(s1)
    80005f88:	c385                	beqz	a5,80005fa8 <piperead+0x64>
    if(pr->killed){
    80005f8a:	028a2783          	lw	a5,40(s4)
    80005f8e:	ebc1                	bnez	a5,8000601e <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005f90:	85da                	mv	a1,s6
    80005f92:	854e                	mv	a0,s3
    80005f94:	ffffc097          	auipc	ra,0xffffc
    80005f98:	7e2080e7          	jalr	2018(ra) # 80002776 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005f9c:	2184a703          	lw	a4,536(s1)
    80005fa0:	21c4a783          	lw	a5,540(s1)
    80005fa4:	fef700e3          	beq	a4,a5,80005f84 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005fa8:	09505263          	blez	s5,8000602c <piperead+0xe8>
    80005fac:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005fae:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005fb0:	2184a783          	lw	a5,536(s1)
    80005fb4:	21c4a703          	lw	a4,540(s1)
    80005fb8:	02f70d63          	beq	a4,a5,80005ff2 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005fbc:	0017871b          	addiw	a4,a5,1
    80005fc0:	20e4ac23          	sw	a4,536(s1)
    80005fc4:	1ff7f793          	andi	a5,a5,511
    80005fc8:	97a6                	add	a5,a5,s1
    80005fca:	0187c783          	lbu	a5,24(a5)
    80005fce:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005fd2:	4685                	li	a3,1
    80005fd4:	fbf40613          	addi	a2,s0,-65
    80005fd8:	85ca                	mv	a1,s2
    80005fda:	058a3503          	ld	a0,88(s4)
    80005fde:	ffffb097          	auipc	ra,0xffffb
    80005fe2:	6b8080e7          	jalr	1720(ra) # 80001696 <copyout>
    80005fe6:	01650663          	beq	a0,s6,80005ff2 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005fea:	2985                	addiw	s3,s3,1
    80005fec:	0905                	addi	s2,s2,1
    80005fee:	fd3a91e3          	bne	s5,s3,80005fb0 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005ff2:	21c48513          	addi	a0,s1,540
    80005ff6:	ffffd097          	auipc	ra,0xffffd
    80005ffa:	b86080e7          	jalr	-1146(ra) # 80002b7c <wakeup>
  release(&pi->lock);
    80005ffe:	8526                	mv	a0,s1
    80006000:	ffffb097          	auipc	ra,0xffffb
    80006004:	c96080e7          	jalr	-874(ra) # 80000c96 <release>
  return i;
}
    80006008:	854e                	mv	a0,s3
    8000600a:	60a6                	ld	ra,72(sp)
    8000600c:	6406                	ld	s0,64(sp)
    8000600e:	74e2                	ld	s1,56(sp)
    80006010:	7942                	ld	s2,48(sp)
    80006012:	79a2                	ld	s3,40(sp)
    80006014:	7a02                	ld	s4,32(sp)
    80006016:	6ae2                	ld	s5,24(sp)
    80006018:	6b42                	ld	s6,16(sp)
    8000601a:	6161                	addi	sp,sp,80
    8000601c:	8082                	ret
      release(&pi->lock);
    8000601e:	8526                	mv	a0,s1
    80006020:	ffffb097          	auipc	ra,0xffffb
    80006024:	c76080e7          	jalr	-906(ra) # 80000c96 <release>
      return -1;
    80006028:	59fd                	li	s3,-1
    8000602a:	bff9                	j	80006008 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000602c:	4981                	li	s3,0
    8000602e:	b7d1                	j	80005ff2 <piperead+0xae>

0000000080006030 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80006030:	df010113          	addi	sp,sp,-528
    80006034:	20113423          	sd	ra,520(sp)
    80006038:	20813023          	sd	s0,512(sp)
    8000603c:	ffa6                	sd	s1,504(sp)
    8000603e:	fbca                	sd	s2,496(sp)
    80006040:	f7ce                	sd	s3,488(sp)
    80006042:	f3d2                	sd	s4,480(sp)
    80006044:	efd6                	sd	s5,472(sp)
    80006046:	ebda                	sd	s6,464(sp)
    80006048:	e7de                	sd	s7,456(sp)
    8000604a:	e3e2                	sd	s8,448(sp)
    8000604c:	ff66                	sd	s9,440(sp)
    8000604e:	fb6a                	sd	s10,432(sp)
    80006050:	f76e                	sd	s11,424(sp)
    80006052:	0c00                	addi	s0,sp,528
    80006054:	84aa                	mv	s1,a0
    80006056:	dea43c23          	sd	a0,-520(s0)
    8000605a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000605e:	ffffc097          	auipc	ra,0xffffc
    80006062:	976080e7          	jalr	-1674(ra) # 800019d4 <myproc>
    80006066:	892a                	mv	s2,a0

  begin_op();
    80006068:	fffff097          	auipc	ra,0xfffff
    8000606c:	49c080e7          	jalr	1180(ra) # 80005504 <begin_op>

  if((ip = namei(path)) == 0){
    80006070:	8526                	mv	a0,s1
    80006072:	fffff097          	auipc	ra,0xfffff
    80006076:	276080e7          	jalr	630(ra) # 800052e8 <namei>
    8000607a:	c92d                	beqz	a0,800060ec <exec+0xbc>
    8000607c:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000607e:	fffff097          	auipc	ra,0xfffff
    80006082:	ab4080e7          	jalr	-1356(ra) # 80004b32 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80006086:	04000713          	li	a4,64
    8000608a:	4681                	li	a3,0
    8000608c:	e5040613          	addi	a2,s0,-432
    80006090:	4581                	li	a1,0
    80006092:	8526                	mv	a0,s1
    80006094:	fffff097          	auipc	ra,0xfffff
    80006098:	d52080e7          	jalr	-686(ra) # 80004de6 <readi>
    8000609c:	04000793          	li	a5,64
    800060a0:	00f51a63          	bne	a0,a5,800060b4 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800060a4:	e5042703          	lw	a4,-432(s0)
    800060a8:	464c47b7          	lui	a5,0x464c4
    800060ac:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800060b0:	04f70463          	beq	a4,a5,800060f8 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800060b4:	8526                	mv	a0,s1
    800060b6:	fffff097          	auipc	ra,0xfffff
    800060ba:	cde080e7          	jalr	-802(ra) # 80004d94 <iunlockput>
    end_op();
    800060be:	fffff097          	auipc	ra,0xfffff
    800060c2:	4c6080e7          	jalr	1222(ra) # 80005584 <end_op>
  }
  return -1;
    800060c6:	557d                	li	a0,-1
}
    800060c8:	20813083          	ld	ra,520(sp)
    800060cc:	20013403          	ld	s0,512(sp)
    800060d0:	74fe                	ld	s1,504(sp)
    800060d2:	795e                	ld	s2,496(sp)
    800060d4:	79be                	ld	s3,488(sp)
    800060d6:	7a1e                	ld	s4,480(sp)
    800060d8:	6afe                	ld	s5,472(sp)
    800060da:	6b5e                	ld	s6,464(sp)
    800060dc:	6bbe                	ld	s7,456(sp)
    800060de:	6c1e                	ld	s8,448(sp)
    800060e0:	7cfa                	ld	s9,440(sp)
    800060e2:	7d5a                	ld	s10,432(sp)
    800060e4:	7dba                	ld	s11,424(sp)
    800060e6:	21010113          	addi	sp,sp,528
    800060ea:	8082                	ret
    end_op();
    800060ec:	fffff097          	auipc	ra,0xfffff
    800060f0:	498080e7          	jalr	1176(ra) # 80005584 <end_op>
    return -1;
    800060f4:	557d                	li	a0,-1
    800060f6:	bfc9                	j	800060c8 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800060f8:	854a                	mv	a0,s2
    800060fa:	ffffc097          	auipc	ra,0xffffc
    800060fe:	9d6080e7          	jalr	-1578(ra) # 80001ad0 <proc_pagetable>
    80006102:	8baa                	mv	s7,a0
    80006104:	d945                	beqz	a0,800060b4 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006106:	e7042983          	lw	s3,-400(s0)
    8000610a:	e8845783          	lhu	a5,-376(s0)
    8000610e:	c7ad                	beqz	a5,80006178 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80006110:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006112:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80006114:	6c85                	lui	s9,0x1
    80006116:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000611a:	def43823          	sd	a5,-528(s0)
    8000611e:	a42d                	j	80006348 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80006120:	00004517          	auipc	a0,0x4
    80006124:	89050513          	addi	a0,a0,-1904 # 800099b0 <syscalls+0x370>
    80006128:	ffffa097          	auipc	ra,0xffffa
    8000612c:	414080e7          	jalr	1044(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80006130:	8756                	mv	a4,s5
    80006132:	012d86bb          	addw	a3,s11,s2
    80006136:	4581                	li	a1,0
    80006138:	8526                	mv	a0,s1
    8000613a:	fffff097          	auipc	ra,0xfffff
    8000613e:	cac080e7          	jalr	-852(ra) # 80004de6 <readi>
    80006142:	2501                	sext.w	a0,a0
    80006144:	1aaa9963          	bne	s5,a0,800062f6 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80006148:	6785                	lui	a5,0x1
    8000614a:	0127893b          	addw	s2,a5,s2
    8000614e:	77fd                	lui	a5,0xfffff
    80006150:	01478a3b          	addw	s4,a5,s4
    80006154:	1f897163          	bgeu	s2,s8,80006336 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80006158:	02091593          	slli	a1,s2,0x20
    8000615c:	9181                	srli	a1,a1,0x20
    8000615e:	95ea                	add	a1,a1,s10
    80006160:	855e                	mv	a0,s7
    80006162:	ffffb097          	auipc	ra,0xffffb
    80006166:	f30080e7          	jalr	-208(ra) # 80001092 <walkaddr>
    8000616a:	862a                	mv	a2,a0
    if(pa == 0)
    8000616c:	d955                	beqz	a0,80006120 <exec+0xf0>
      n = PGSIZE;
    8000616e:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80006170:	fd9a70e3          	bgeu	s4,s9,80006130 <exec+0x100>
      n = sz - i;
    80006174:	8ad2                	mv	s5,s4
    80006176:	bf6d                	j	80006130 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80006178:	4901                	li	s2,0
  iunlockput(ip);
    8000617a:	8526                	mv	a0,s1
    8000617c:	fffff097          	auipc	ra,0xfffff
    80006180:	c18080e7          	jalr	-1000(ra) # 80004d94 <iunlockput>
  end_op();
    80006184:	fffff097          	auipc	ra,0xfffff
    80006188:	400080e7          	jalr	1024(ra) # 80005584 <end_op>
  p = myproc();
    8000618c:	ffffc097          	auipc	ra,0xffffc
    80006190:	848080e7          	jalr	-1976(ra) # 800019d4 <myproc>
    80006194:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80006196:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    8000619a:	6785                	lui	a5,0x1
    8000619c:	17fd                	addi	a5,a5,-1
    8000619e:	993e                	add	s2,s2,a5
    800061a0:	757d                	lui	a0,0xfffff
    800061a2:	00a977b3          	and	a5,s2,a0
    800061a6:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800061aa:	6609                	lui	a2,0x2
    800061ac:	963e                	add	a2,a2,a5
    800061ae:	85be                	mv	a1,a5
    800061b0:	855e                	mv	a0,s7
    800061b2:	ffffb097          	auipc	ra,0xffffb
    800061b6:	294080e7          	jalr	660(ra) # 80001446 <uvmalloc>
    800061ba:	8b2a                	mv	s6,a0
  ip = 0;
    800061bc:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800061be:	12050c63          	beqz	a0,800062f6 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800061c2:	75f9                	lui	a1,0xffffe
    800061c4:	95aa                	add	a1,a1,a0
    800061c6:	855e                	mv	a0,s7
    800061c8:	ffffb097          	auipc	ra,0xffffb
    800061cc:	49c080e7          	jalr	1180(ra) # 80001664 <uvmclear>
  stackbase = sp - PGSIZE;
    800061d0:	7c7d                	lui	s8,0xfffff
    800061d2:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800061d4:	e0043783          	ld	a5,-512(s0)
    800061d8:	6388                	ld	a0,0(a5)
    800061da:	c535                	beqz	a0,80006246 <exec+0x216>
    800061dc:	e9040993          	addi	s3,s0,-368
    800061e0:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800061e4:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800061e6:	ffffb097          	auipc	ra,0xffffb
    800061ea:	c7c080e7          	jalr	-900(ra) # 80000e62 <strlen>
    800061ee:	2505                	addiw	a0,a0,1
    800061f0:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800061f4:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800061f8:	13896363          	bltu	s2,s8,8000631e <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800061fc:	e0043d83          	ld	s11,-512(s0)
    80006200:	000dba03          	ld	s4,0(s11)
    80006204:	8552                	mv	a0,s4
    80006206:	ffffb097          	auipc	ra,0xffffb
    8000620a:	c5c080e7          	jalr	-932(ra) # 80000e62 <strlen>
    8000620e:	0015069b          	addiw	a3,a0,1
    80006212:	8652                	mv	a2,s4
    80006214:	85ca                	mv	a1,s2
    80006216:	855e                	mv	a0,s7
    80006218:	ffffb097          	auipc	ra,0xffffb
    8000621c:	47e080e7          	jalr	1150(ra) # 80001696 <copyout>
    80006220:	10054363          	bltz	a0,80006326 <exec+0x2f6>
    ustack[argc] = sp;
    80006224:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80006228:	0485                	addi	s1,s1,1
    8000622a:	008d8793          	addi	a5,s11,8
    8000622e:	e0f43023          	sd	a5,-512(s0)
    80006232:	008db503          	ld	a0,8(s11)
    80006236:	c911                	beqz	a0,8000624a <exec+0x21a>
    if(argc >= MAXARG)
    80006238:	09a1                	addi	s3,s3,8
    8000623a:	fb3c96e3          	bne	s9,s3,800061e6 <exec+0x1b6>
  sz = sz1;
    8000623e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80006242:	4481                	li	s1,0
    80006244:	a84d                	j	800062f6 <exec+0x2c6>
  sp = sz;
    80006246:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80006248:	4481                	li	s1,0
  ustack[argc] = 0;
    8000624a:	00349793          	slli	a5,s1,0x3
    8000624e:	f9040713          	addi	a4,s0,-112
    80006252:	97ba                	add	a5,a5,a4
    80006254:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80006258:	00148693          	addi	a3,s1,1
    8000625c:	068e                	slli	a3,a3,0x3
    8000625e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80006262:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80006266:	01897663          	bgeu	s2,s8,80006272 <exec+0x242>
  sz = sz1;
    8000626a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000626e:	4481                	li	s1,0
    80006270:	a059                	j	800062f6 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80006272:	e9040613          	addi	a2,s0,-368
    80006276:	85ca                	mv	a1,s2
    80006278:	855e                	mv	a0,s7
    8000627a:	ffffb097          	auipc	ra,0xffffb
    8000627e:	41c080e7          	jalr	1052(ra) # 80001696 <copyout>
    80006282:	0a054663          	bltz	a0,8000632e <exec+0x2fe>
  p->trapframe->a1 = sp;
    80006286:	060ab783          	ld	a5,96(s5)
    8000628a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000628e:	df843783          	ld	a5,-520(s0)
    80006292:	0007c703          	lbu	a4,0(a5)
    80006296:	cf11                	beqz	a4,800062b2 <exec+0x282>
    80006298:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000629a:	02f00693          	li	a3,47
    8000629e:	a039                	j	800062ac <exec+0x27c>
      last = s+1;
    800062a0:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800062a4:	0785                	addi	a5,a5,1
    800062a6:	fff7c703          	lbu	a4,-1(a5)
    800062aa:	c701                	beqz	a4,800062b2 <exec+0x282>
    if(*s == '/')
    800062ac:	fed71ce3          	bne	a4,a3,800062a4 <exec+0x274>
    800062b0:	bfc5                	j	800062a0 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    800062b2:	4641                	li	a2,16
    800062b4:	df843583          	ld	a1,-520(s0)
    800062b8:	160a8513          	addi	a0,s5,352
    800062bc:	ffffb097          	auipc	ra,0xffffb
    800062c0:	b74080e7          	jalr	-1164(ra) # 80000e30 <safestrcpy>
  oldpagetable = p->pagetable;
    800062c4:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    800062c8:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    800062cc:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800062d0:	060ab783          	ld	a5,96(s5)
    800062d4:	e6843703          	ld	a4,-408(s0)
    800062d8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800062da:	060ab783          	ld	a5,96(s5)
    800062de:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800062e2:	85ea                	mv	a1,s10
    800062e4:	ffffc097          	auipc	ra,0xffffc
    800062e8:	888080e7          	jalr	-1912(ra) # 80001b6c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800062ec:	0004851b          	sext.w	a0,s1
    800062f0:	bbe1                	j	800060c8 <exec+0x98>
    800062f2:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800062f6:	e0843583          	ld	a1,-504(s0)
    800062fa:	855e                	mv	a0,s7
    800062fc:	ffffc097          	auipc	ra,0xffffc
    80006300:	870080e7          	jalr	-1936(ra) # 80001b6c <proc_freepagetable>
  if(ip){
    80006304:	da0498e3          	bnez	s1,800060b4 <exec+0x84>
  return -1;
    80006308:	557d                	li	a0,-1
    8000630a:	bb7d                	j	800060c8 <exec+0x98>
    8000630c:	e1243423          	sd	s2,-504(s0)
    80006310:	b7dd                	j	800062f6 <exec+0x2c6>
    80006312:	e1243423          	sd	s2,-504(s0)
    80006316:	b7c5                	j	800062f6 <exec+0x2c6>
    80006318:	e1243423          	sd	s2,-504(s0)
    8000631c:	bfe9                	j	800062f6 <exec+0x2c6>
  sz = sz1;
    8000631e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80006322:	4481                	li	s1,0
    80006324:	bfc9                	j	800062f6 <exec+0x2c6>
  sz = sz1;
    80006326:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000632a:	4481                	li	s1,0
    8000632c:	b7e9                	j	800062f6 <exec+0x2c6>
  sz = sz1;
    8000632e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80006332:	4481                	li	s1,0
    80006334:	b7c9                	j	800062f6 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006336:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000633a:	2b05                	addiw	s6,s6,1
    8000633c:	0389899b          	addiw	s3,s3,56
    80006340:	e8845783          	lhu	a5,-376(s0)
    80006344:	e2fb5be3          	bge	s6,a5,8000617a <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80006348:	2981                	sext.w	s3,s3
    8000634a:	03800713          	li	a4,56
    8000634e:	86ce                	mv	a3,s3
    80006350:	e1840613          	addi	a2,s0,-488
    80006354:	4581                	li	a1,0
    80006356:	8526                	mv	a0,s1
    80006358:	fffff097          	auipc	ra,0xfffff
    8000635c:	a8e080e7          	jalr	-1394(ra) # 80004de6 <readi>
    80006360:	03800793          	li	a5,56
    80006364:	f8f517e3          	bne	a0,a5,800062f2 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80006368:	e1842783          	lw	a5,-488(s0)
    8000636c:	4705                	li	a4,1
    8000636e:	fce796e3          	bne	a5,a4,8000633a <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80006372:	e4043603          	ld	a2,-448(s0)
    80006376:	e3843783          	ld	a5,-456(s0)
    8000637a:	f8f669e3          	bltu	a2,a5,8000630c <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000637e:	e2843783          	ld	a5,-472(s0)
    80006382:	963e                	add	a2,a2,a5
    80006384:	f8f667e3          	bltu	a2,a5,80006312 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006388:	85ca                	mv	a1,s2
    8000638a:	855e                	mv	a0,s7
    8000638c:	ffffb097          	auipc	ra,0xffffb
    80006390:	0ba080e7          	jalr	186(ra) # 80001446 <uvmalloc>
    80006394:	e0a43423          	sd	a0,-504(s0)
    80006398:	d141                	beqz	a0,80006318 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    8000639a:	e2843d03          	ld	s10,-472(s0)
    8000639e:	df043783          	ld	a5,-528(s0)
    800063a2:	00fd77b3          	and	a5,s10,a5
    800063a6:	fba1                	bnez	a5,800062f6 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800063a8:	e2042d83          	lw	s11,-480(s0)
    800063ac:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800063b0:	f80c03e3          	beqz	s8,80006336 <exec+0x306>
    800063b4:	8a62                	mv	s4,s8
    800063b6:	4901                	li	s2,0
    800063b8:	b345                	j	80006158 <exec+0x128>

00000000800063ba <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800063ba:	7179                	addi	sp,sp,-48
    800063bc:	f406                	sd	ra,40(sp)
    800063be:	f022                	sd	s0,32(sp)
    800063c0:	ec26                	sd	s1,24(sp)
    800063c2:	e84a                	sd	s2,16(sp)
    800063c4:	1800                	addi	s0,sp,48
    800063c6:	892e                	mv	s2,a1
    800063c8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800063ca:	fdc40593          	addi	a1,s0,-36
    800063ce:	ffffe097          	auipc	ra,0xffffe
    800063d2:	810080e7          	jalr	-2032(ra) # 80003bde <argint>
    800063d6:	04054063          	bltz	a0,80006416 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800063da:	fdc42703          	lw	a4,-36(s0)
    800063de:	47bd                	li	a5,15
    800063e0:	02e7ed63          	bltu	a5,a4,8000641a <argfd+0x60>
    800063e4:	ffffb097          	auipc	ra,0xffffb
    800063e8:	5f0080e7          	jalr	1520(ra) # 800019d4 <myproc>
    800063ec:	fdc42703          	lw	a4,-36(s0)
    800063f0:	01a70793          	addi	a5,a4,26
    800063f4:	078e                	slli	a5,a5,0x3
    800063f6:	953e                	add	a0,a0,a5
    800063f8:	651c                	ld	a5,8(a0)
    800063fa:	c395                	beqz	a5,8000641e <argfd+0x64>
    return -1;
  if(pfd)
    800063fc:	00090463          	beqz	s2,80006404 <argfd+0x4a>
    *pfd = fd;
    80006400:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80006404:	4501                	li	a0,0
  if(pf)
    80006406:	c091                	beqz	s1,8000640a <argfd+0x50>
    *pf = f;
    80006408:	e09c                	sd	a5,0(s1)
}
    8000640a:	70a2                	ld	ra,40(sp)
    8000640c:	7402                	ld	s0,32(sp)
    8000640e:	64e2                	ld	s1,24(sp)
    80006410:	6942                	ld	s2,16(sp)
    80006412:	6145                	addi	sp,sp,48
    80006414:	8082                	ret
    return -1;
    80006416:	557d                	li	a0,-1
    80006418:	bfcd                	j	8000640a <argfd+0x50>
    return -1;
    8000641a:	557d                	li	a0,-1
    8000641c:	b7fd                	j	8000640a <argfd+0x50>
    8000641e:	557d                	li	a0,-1
    80006420:	b7ed                	j	8000640a <argfd+0x50>

0000000080006422 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006422:	1101                	addi	sp,sp,-32
    80006424:	ec06                	sd	ra,24(sp)
    80006426:	e822                	sd	s0,16(sp)
    80006428:	e426                	sd	s1,8(sp)
    8000642a:	1000                	addi	s0,sp,32
    8000642c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000642e:	ffffb097          	auipc	ra,0xffffb
    80006432:	5a6080e7          	jalr	1446(ra) # 800019d4 <myproc>
    80006436:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80006438:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffd70d8>
    8000643c:	4501                	li	a0,0
    8000643e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80006440:	6398                	ld	a4,0(a5)
    80006442:	cb19                	beqz	a4,80006458 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80006444:	2505                	addiw	a0,a0,1
    80006446:	07a1                	addi	a5,a5,8
    80006448:	fed51ce3          	bne	a0,a3,80006440 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000644c:	557d                	li	a0,-1
}
    8000644e:	60e2                	ld	ra,24(sp)
    80006450:	6442                	ld	s0,16(sp)
    80006452:	64a2                	ld	s1,8(sp)
    80006454:	6105                	addi	sp,sp,32
    80006456:	8082                	ret
      p->ofile[fd] = f;
    80006458:	01a50793          	addi	a5,a0,26
    8000645c:	078e                	slli	a5,a5,0x3
    8000645e:	963e                	add	a2,a2,a5
    80006460:	e604                	sd	s1,8(a2)
      return fd;
    80006462:	b7f5                	j	8000644e <fdalloc+0x2c>

0000000080006464 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80006464:	715d                	addi	sp,sp,-80
    80006466:	e486                	sd	ra,72(sp)
    80006468:	e0a2                	sd	s0,64(sp)
    8000646a:	fc26                	sd	s1,56(sp)
    8000646c:	f84a                	sd	s2,48(sp)
    8000646e:	f44e                	sd	s3,40(sp)
    80006470:	f052                	sd	s4,32(sp)
    80006472:	ec56                	sd	s5,24(sp)
    80006474:	0880                	addi	s0,sp,80
    80006476:	89ae                	mv	s3,a1
    80006478:	8ab2                	mv	s5,a2
    8000647a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000647c:	fb040593          	addi	a1,s0,-80
    80006480:	fffff097          	auipc	ra,0xfffff
    80006484:	e86080e7          	jalr	-378(ra) # 80005306 <nameiparent>
    80006488:	892a                	mv	s2,a0
    8000648a:	12050f63          	beqz	a0,800065c8 <create+0x164>
    return 0;

  ilock(dp);
    8000648e:	ffffe097          	auipc	ra,0xffffe
    80006492:	6a4080e7          	jalr	1700(ra) # 80004b32 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80006496:	4601                	li	a2,0
    80006498:	fb040593          	addi	a1,s0,-80
    8000649c:	854a                	mv	a0,s2
    8000649e:	fffff097          	auipc	ra,0xfffff
    800064a2:	b78080e7          	jalr	-1160(ra) # 80005016 <dirlookup>
    800064a6:	84aa                	mv	s1,a0
    800064a8:	c921                	beqz	a0,800064f8 <create+0x94>
    iunlockput(dp);
    800064aa:	854a                	mv	a0,s2
    800064ac:	fffff097          	auipc	ra,0xfffff
    800064b0:	8e8080e7          	jalr	-1816(ra) # 80004d94 <iunlockput>
    ilock(ip);
    800064b4:	8526                	mv	a0,s1
    800064b6:	ffffe097          	auipc	ra,0xffffe
    800064ba:	67c080e7          	jalr	1660(ra) # 80004b32 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800064be:	2981                	sext.w	s3,s3
    800064c0:	4789                	li	a5,2
    800064c2:	02f99463          	bne	s3,a5,800064ea <create+0x86>
    800064c6:	0444d783          	lhu	a5,68(s1)
    800064ca:	37f9                	addiw	a5,a5,-2
    800064cc:	17c2                	slli	a5,a5,0x30
    800064ce:	93c1                	srli	a5,a5,0x30
    800064d0:	4705                	li	a4,1
    800064d2:	00f76c63          	bltu	a4,a5,800064ea <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800064d6:	8526                	mv	a0,s1
    800064d8:	60a6                	ld	ra,72(sp)
    800064da:	6406                	ld	s0,64(sp)
    800064dc:	74e2                	ld	s1,56(sp)
    800064de:	7942                	ld	s2,48(sp)
    800064e0:	79a2                	ld	s3,40(sp)
    800064e2:	7a02                	ld	s4,32(sp)
    800064e4:	6ae2                	ld	s5,24(sp)
    800064e6:	6161                	addi	sp,sp,80
    800064e8:	8082                	ret
    iunlockput(ip);
    800064ea:	8526                	mv	a0,s1
    800064ec:	fffff097          	auipc	ra,0xfffff
    800064f0:	8a8080e7          	jalr	-1880(ra) # 80004d94 <iunlockput>
    return 0;
    800064f4:	4481                	li	s1,0
    800064f6:	b7c5                	j	800064d6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800064f8:	85ce                	mv	a1,s3
    800064fa:	00092503          	lw	a0,0(s2)
    800064fe:	ffffe097          	auipc	ra,0xffffe
    80006502:	49c080e7          	jalr	1180(ra) # 8000499a <ialloc>
    80006506:	84aa                	mv	s1,a0
    80006508:	c529                	beqz	a0,80006552 <create+0xee>
  ilock(ip);
    8000650a:	ffffe097          	auipc	ra,0xffffe
    8000650e:	628080e7          	jalr	1576(ra) # 80004b32 <ilock>
  ip->major = major;
    80006512:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006516:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000651a:	4785                	li	a5,1
    8000651c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006520:	8526                	mv	a0,s1
    80006522:	ffffe097          	auipc	ra,0xffffe
    80006526:	546080e7          	jalr	1350(ra) # 80004a68 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000652a:	2981                	sext.w	s3,s3
    8000652c:	4785                	li	a5,1
    8000652e:	02f98a63          	beq	s3,a5,80006562 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80006532:	40d0                	lw	a2,4(s1)
    80006534:	fb040593          	addi	a1,s0,-80
    80006538:	854a                	mv	a0,s2
    8000653a:	fffff097          	auipc	ra,0xfffff
    8000653e:	cec080e7          	jalr	-788(ra) # 80005226 <dirlink>
    80006542:	06054b63          	bltz	a0,800065b8 <create+0x154>
  iunlockput(dp);
    80006546:	854a                	mv	a0,s2
    80006548:	fffff097          	auipc	ra,0xfffff
    8000654c:	84c080e7          	jalr	-1972(ra) # 80004d94 <iunlockput>
  return ip;
    80006550:	b759                	j	800064d6 <create+0x72>
    panic("create: ialloc");
    80006552:	00003517          	auipc	a0,0x3
    80006556:	47e50513          	addi	a0,a0,1150 # 800099d0 <syscalls+0x390>
    8000655a:	ffffa097          	auipc	ra,0xffffa
    8000655e:	fe2080e7          	jalr	-30(ra) # 8000053c <panic>
    dp->nlink++;  // for ".."
    80006562:	04a95783          	lhu	a5,74(s2)
    80006566:	2785                	addiw	a5,a5,1
    80006568:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000656c:	854a                	mv	a0,s2
    8000656e:	ffffe097          	auipc	ra,0xffffe
    80006572:	4fa080e7          	jalr	1274(ra) # 80004a68 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006576:	40d0                	lw	a2,4(s1)
    80006578:	00003597          	auipc	a1,0x3
    8000657c:	46858593          	addi	a1,a1,1128 # 800099e0 <syscalls+0x3a0>
    80006580:	8526                	mv	a0,s1
    80006582:	fffff097          	auipc	ra,0xfffff
    80006586:	ca4080e7          	jalr	-860(ra) # 80005226 <dirlink>
    8000658a:	00054f63          	bltz	a0,800065a8 <create+0x144>
    8000658e:	00492603          	lw	a2,4(s2)
    80006592:	00003597          	auipc	a1,0x3
    80006596:	45658593          	addi	a1,a1,1110 # 800099e8 <syscalls+0x3a8>
    8000659a:	8526                	mv	a0,s1
    8000659c:	fffff097          	auipc	ra,0xfffff
    800065a0:	c8a080e7          	jalr	-886(ra) # 80005226 <dirlink>
    800065a4:	f80557e3          	bgez	a0,80006532 <create+0xce>
      panic("create dots");
    800065a8:	00003517          	auipc	a0,0x3
    800065ac:	44850513          	addi	a0,a0,1096 # 800099f0 <syscalls+0x3b0>
    800065b0:	ffffa097          	auipc	ra,0xffffa
    800065b4:	f8c080e7          	jalr	-116(ra) # 8000053c <panic>
    panic("create: dirlink");
    800065b8:	00003517          	auipc	a0,0x3
    800065bc:	44850513          	addi	a0,a0,1096 # 80009a00 <syscalls+0x3c0>
    800065c0:	ffffa097          	auipc	ra,0xffffa
    800065c4:	f7c080e7          	jalr	-132(ra) # 8000053c <panic>
    return 0;
    800065c8:	84aa                	mv	s1,a0
    800065ca:	b731                	j	800064d6 <create+0x72>

00000000800065cc <sys_dup>:
{
    800065cc:	7179                	addi	sp,sp,-48
    800065ce:	f406                	sd	ra,40(sp)
    800065d0:	f022                	sd	s0,32(sp)
    800065d2:	ec26                	sd	s1,24(sp)
    800065d4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800065d6:	fd840613          	addi	a2,s0,-40
    800065da:	4581                	li	a1,0
    800065dc:	4501                	li	a0,0
    800065de:	00000097          	auipc	ra,0x0
    800065e2:	ddc080e7          	jalr	-548(ra) # 800063ba <argfd>
    return -1;
    800065e6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800065e8:	02054363          	bltz	a0,8000660e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800065ec:	fd843503          	ld	a0,-40(s0)
    800065f0:	00000097          	auipc	ra,0x0
    800065f4:	e32080e7          	jalr	-462(ra) # 80006422 <fdalloc>
    800065f8:	84aa                	mv	s1,a0
    return -1;
    800065fa:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800065fc:	00054963          	bltz	a0,8000660e <sys_dup+0x42>
  filedup(f);
    80006600:	fd843503          	ld	a0,-40(s0)
    80006604:	fffff097          	auipc	ra,0xfffff
    80006608:	37a080e7          	jalr	890(ra) # 8000597e <filedup>
  return fd;
    8000660c:	87a6                	mv	a5,s1
}
    8000660e:	853e                	mv	a0,a5
    80006610:	70a2                	ld	ra,40(sp)
    80006612:	7402                	ld	s0,32(sp)
    80006614:	64e2                	ld	s1,24(sp)
    80006616:	6145                	addi	sp,sp,48
    80006618:	8082                	ret

000000008000661a <sys_read>:
{
    8000661a:	7179                	addi	sp,sp,-48
    8000661c:	f406                	sd	ra,40(sp)
    8000661e:	f022                	sd	s0,32(sp)
    80006620:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006622:	fe840613          	addi	a2,s0,-24
    80006626:	4581                	li	a1,0
    80006628:	4501                	li	a0,0
    8000662a:	00000097          	auipc	ra,0x0
    8000662e:	d90080e7          	jalr	-624(ra) # 800063ba <argfd>
    return -1;
    80006632:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006634:	04054163          	bltz	a0,80006676 <sys_read+0x5c>
    80006638:	fe440593          	addi	a1,s0,-28
    8000663c:	4509                	li	a0,2
    8000663e:	ffffd097          	auipc	ra,0xffffd
    80006642:	5a0080e7          	jalr	1440(ra) # 80003bde <argint>
    return -1;
    80006646:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006648:	02054763          	bltz	a0,80006676 <sys_read+0x5c>
    8000664c:	fd840593          	addi	a1,s0,-40
    80006650:	4505                	li	a0,1
    80006652:	ffffd097          	auipc	ra,0xffffd
    80006656:	5ae080e7          	jalr	1454(ra) # 80003c00 <argaddr>
    return -1;
    8000665a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000665c:	00054d63          	bltz	a0,80006676 <sys_read+0x5c>
  return fileread(f, p, n);
    80006660:	fe442603          	lw	a2,-28(s0)
    80006664:	fd843583          	ld	a1,-40(s0)
    80006668:	fe843503          	ld	a0,-24(s0)
    8000666c:	fffff097          	auipc	ra,0xfffff
    80006670:	49e080e7          	jalr	1182(ra) # 80005b0a <fileread>
    80006674:	87aa                	mv	a5,a0
}
    80006676:	853e                	mv	a0,a5
    80006678:	70a2                	ld	ra,40(sp)
    8000667a:	7402                	ld	s0,32(sp)
    8000667c:	6145                	addi	sp,sp,48
    8000667e:	8082                	ret

0000000080006680 <sys_write>:
{
    80006680:	7179                	addi	sp,sp,-48
    80006682:	f406                	sd	ra,40(sp)
    80006684:	f022                	sd	s0,32(sp)
    80006686:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006688:	fe840613          	addi	a2,s0,-24
    8000668c:	4581                	li	a1,0
    8000668e:	4501                	li	a0,0
    80006690:	00000097          	auipc	ra,0x0
    80006694:	d2a080e7          	jalr	-726(ra) # 800063ba <argfd>
    return -1;
    80006698:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000669a:	04054163          	bltz	a0,800066dc <sys_write+0x5c>
    8000669e:	fe440593          	addi	a1,s0,-28
    800066a2:	4509                	li	a0,2
    800066a4:	ffffd097          	auipc	ra,0xffffd
    800066a8:	53a080e7          	jalr	1338(ra) # 80003bde <argint>
    return -1;
    800066ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800066ae:	02054763          	bltz	a0,800066dc <sys_write+0x5c>
    800066b2:	fd840593          	addi	a1,s0,-40
    800066b6:	4505                	li	a0,1
    800066b8:	ffffd097          	auipc	ra,0xffffd
    800066bc:	548080e7          	jalr	1352(ra) # 80003c00 <argaddr>
    return -1;
    800066c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800066c2:	00054d63          	bltz	a0,800066dc <sys_write+0x5c>
  return filewrite(f, p, n);
    800066c6:	fe442603          	lw	a2,-28(s0)
    800066ca:	fd843583          	ld	a1,-40(s0)
    800066ce:	fe843503          	ld	a0,-24(s0)
    800066d2:	fffff097          	auipc	ra,0xfffff
    800066d6:	4fa080e7          	jalr	1274(ra) # 80005bcc <filewrite>
    800066da:	87aa                	mv	a5,a0
}
    800066dc:	853e                	mv	a0,a5
    800066de:	70a2                	ld	ra,40(sp)
    800066e0:	7402                	ld	s0,32(sp)
    800066e2:	6145                	addi	sp,sp,48
    800066e4:	8082                	ret

00000000800066e6 <sys_close>:
{
    800066e6:	1101                	addi	sp,sp,-32
    800066e8:	ec06                	sd	ra,24(sp)
    800066ea:	e822                	sd	s0,16(sp)
    800066ec:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800066ee:	fe040613          	addi	a2,s0,-32
    800066f2:	fec40593          	addi	a1,s0,-20
    800066f6:	4501                	li	a0,0
    800066f8:	00000097          	auipc	ra,0x0
    800066fc:	cc2080e7          	jalr	-830(ra) # 800063ba <argfd>
    return -1;
    80006700:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006702:	02054463          	bltz	a0,8000672a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80006706:	ffffb097          	auipc	ra,0xffffb
    8000670a:	2ce080e7          	jalr	718(ra) # 800019d4 <myproc>
    8000670e:	fec42783          	lw	a5,-20(s0)
    80006712:	07e9                	addi	a5,a5,26
    80006714:	078e                	slli	a5,a5,0x3
    80006716:	97aa                	add	a5,a5,a0
    80006718:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000671c:	fe043503          	ld	a0,-32(s0)
    80006720:	fffff097          	auipc	ra,0xfffff
    80006724:	2b0080e7          	jalr	688(ra) # 800059d0 <fileclose>
  return 0;
    80006728:	4781                	li	a5,0
}
    8000672a:	853e                	mv	a0,a5
    8000672c:	60e2                	ld	ra,24(sp)
    8000672e:	6442                	ld	s0,16(sp)
    80006730:	6105                	addi	sp,sp,32
    80006732:	8082                	ret

0000000080006734 <sys_fstat>:
{
    80006734:	1101                	addi	sp,sp,-32
    80006736:	ec06                	sd	ra,24(sp)
    80006738:	e822                	sd	s0,16(sp)
    8000673a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000673c:	fe840613          	addi	a2,s0,-24
    80006740:	4581                	li	a1,0
    80006742:	4501                	li	a0,0
    80006744:	00000097          	auipc	ra,0x0
    80006748:	c76080e7          	jalr	-906(ra) # 800063ba <argfd>
    return -1;
    8000674c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000674e:	02054563          	bltz	a0,80006778 <sys_fstat+0x44>
    80006752:	fe040593          	addi	a1,s0,-32
    80006756:	4505                	li	a0,1
    80006758:	ffffd097          	auipc	ra,0xffffd
    8000675c:	4a8080e7          	jalr	1192(ra) # 80003c00 <argaddr>
    return -1;
    80006760:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006762:	00054b63          	bltz	a0,80006778 <sys_fstat+0x44>
  return filestat(f, st);
    80006766:	fe043583          	ld	a1,-32(s0)
    8000676a:	fe843503          	ld	a0,-24(s0)
    8000676e:	fffff097          	auipc	ra,0xfffff
    80006772:	32a080e7          	jalr	810(ra) # 80005a98 <filestat>
    80006776:	87aa                	mv	a5,a0
}
    80006778:	853e                	mv	a0,a5
    8000677a:	60e2                	ld	ra,24(sp)
    8000677c:	6442                	ld	s0,16(sp)
    8000677e:	6105                	addi	sp,sp,32
    80006780:	8082                	ret

0000000080006782 <sys_link>:
{
    80006782:	7169                	addi	sp,sp,-304
    80006784:	f606                	sd	ra,296(sp)
    80006786:	f222                	sd	s0,288(sp)
    80006788:	ee26                	sd	s1,280(sp)
    8000678a:	ea4a                	sd	s2,272(sp)
    8000678c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000678e:	08000613          	li	a2,128
    80006792:	ed040593          	addi	a1,s0,-304
    80006796:	4501                	li	a0,0
    80006798:	ffffd097          	auipc	ra,0xffffd
    8000679c:	48a080e7          	jalr	1162(ra) # 80003c22 <argstr>
    return -1;
    800067a0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800067a2:	10054e63          	bltz	a0,800068be <sys_link+0x13c>
    800067a6:	08000613          	li	a2,128
    800067aa:	f5040593          	addi	a1,s0,-176
    800067ae:	4505                	li	a0,1
    800067b0:	ffffd097          	auipc	ra,0xffffd
    800067b4:	472080e7          	jalr	1138(ra) # 80003c22 <argstr>
    return -1;
    800067b8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800067ba:	10054263          	bltz	a0,800068be <sys_link+0x13c>
  begin_op();
    800067be:	fffff097          	auipc	ra,0xfffff
    800067c2:	d46080e7          	jalr	-698(ra) # 80005504 <begin_op>
  if((ip = namei(old)) == 0){
    800067c6:	ed040513          	addi	a0,s0,-304
    800067ca:	fffff097          	auipc	ra,0xfffff
    800067ce:	b1e080e7          	jalr	-1250(ra) # 800052e8 <namei>
    800067d2:	84aa                	mv	s1,a0
    800067d4:	c551                	beqz	a0,80006860 <sys_link+0xde>
  ilock(ip);
    800067d6:	ffffe097          	auipc	ra,0xffffe
    800067da:	35c080e7          	jalr	860(ra) # 80004b32 <ilock>
  if(ip->type == T_DIR){
    800067de:	04449703          	lh	a4,68(s1)
    800067e2:	4785                	li	a5,1
    800067e4:	08f70463          	beq	a4,a5,8000686c <sys_link+0xea>
  ip->nlink++;
    800067e8:	04a4d783          	lhu	a5,74(s1)
    800067ec:	2785                	addiw	a5,a5,1
    800067ee:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800067f2:	8526                	mv	a0,s1
    800067f4:	ffffe097          	auipc	ra,0xffffe
    800067f8:	274080e7          	jalr	628(ra) # 80004a68 <iupdate>
  iunlock(ip);
    800067fc:	8526                	mv	a0,s1
    800067fe:	ffffe097          	auipc	ra,0xffffe
    80006802:	3f6080e7          	jalr	1014(ra) # 80004bf4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80006806:	fd040593          	addi	a1,s0,-48
    8000680a:	f5040513          	addi	a0,s0,-176
    8000680e:	fffff097          	auipc	ra,0xfffff
    80006812:	af8080e7          	jalr	-1288(ra) # 80005306 <nameiparent>
    80006816:	892a                	mv	s2,a0
    80006818:	c935                	beqz	a0,8000688c <sys_link+0x10a>
  ilock(dp);
    8000681a:	ffffe097          	auipc	ra,0xffffe
    8000681e:	318080e7          	jalr	792(ra) # 80004b32 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006822:	00092703          	lw	a4,0(s2)
    80006826:	409c                	lw	a5,0(s1)
    80006828:	04f71d63          	bne	a4,a5,80006882 <sys_link+0x100>
    8000682c:	40d0                	lw	a2,4(s1)
    8000682e:	fd040593          	addi	a1,s0,-48
    80006832:	854a                	mv	a0,s2
    80006834:	fffff097          	auipc	ra,0xfffff
    80006838:	9f2080e7          	jalr	-1550(ra) # 80005226 <dirlink>
    8000683c:	04054363          	bltz	a0,80006882 <sys_link+0x100>
  iunlockput(dp);
    80006840:	854a                	mv	a0,s2
    80006842:	ffffe097          	auipc	ra,0xffffe
    80006846:	552080e7          	jalr	1362(ra) # 80004d94 <iunlockput>
  iput(ip);
    8000684a:	8526                	mv	a0,s1
    8000684c:	ffffe097          	auipc	ra,0xffffe
    80006850:	4a0080e7          	jalr	1184(ra) # 80004cec <iput>
  end_op();
    80006854:	fffff097          	auipc	ra,0xfffff
    80006858:	d30080e7          	jalr	-720(ra) # 80005584 <end_op>
  return 0;
    8000685c:	4781                	li	a5,0
    8000685e:	a085                	j	800068be <sys_link+0x13c>
    end_op();
    80006860:	fffff097          	auipc	ra,0xfffff
    80006864:	d24080e7          	jalr	-732(ra) # 80005584 <end_op>
    return -1;
    80006868:	57fd                	li	a5,-1
    8000686a:	a891                	j	800068be <sys_link+0x13c>
    iunlockput(ip);
    8000686c:	8526                	mv	a0,s1
    8000686e:	ffffe097          	auipc	ra,0xffffe
    80006872:	526080e7          	jalr	1318(ra) # 80004d94 <iunlockput>
    end_op();
    80006876:	fffff097          	auipc	ra,0xfffff
    8000687a:	d0e080e7          	jalr	-754(ra) # 80005584 <end_op>
    return -1;
    8000687e:	57fd                	li	a5,-1
    80006880:	a83d                	j	800068be <sys_link+0x13c>
    iunlockput(dp);
    80006882:	854a                	mv	a0,s2
    80006884:	ffffe097          	auipc	ra,0xffffe
    80006888:	510080e7          	jalr	1296(ra) # 80004d94 <iunlockput>
  ilock(ip);
    8000688c:	8526                	mv	a0,s1
    8000688e:	ffffe097          	auipc	ra,0xffffe
    80006892:	2a4080e7          	jalr	676(ra) # 80004b32 <ilock>
  ip->nlink--;
    80006896:	04a4d783          	lhu	a5,74(s1)
    8000689a:	37fd                	addiw	a5,a5,-1
    8000689c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800068a0:	8526                	mv	a0,s1
    800068a2:	ffffe097          	auipc	ra,0xffffe
    800068a6:	1c6080e7          	jalr	454(ra) # 80004a68 <iupdate>
  iunlockput(ip);
    800068aa:	8526                	mv	a0,s1
    800068ac:	ffffe097          	auipc	ra,0xffffe
    800068b0:	4e8080e7          	jalr	1256(ra) # 80004d94 <iunlockput>
  end_op();
    800068b4:	fffff097          	auipc	ra,0xfffff
    800068b8:	cd0080e7          	jalr	-816(ra) # 80005584 <end_op>
  return -1;
    800068bc:	57fd                	li	a5,-1
}
    800068be:	853e                	mv	a0,a5
    800068c0:	70b2                	ld	ra,296(sp)
    800068c2:	7412                	ld	s0,288(sp)
    800068c4:	64f2                	ld	s1,280(sp)
    800068c6:	6952                	ld	s2,272(sp)
    800068c8:	6155                	addi	sp,sp,304
    800068ca:	8082                	ret

00000000800068cc <sys_unlink>:
{
    800068cc:	7151                	addi	sp,sp,-240
    800068ce:	f586                	sd	ra,232(sp)
    800068d0:	f1a2                	sd	s0,224(sp)
    800068d2:	eda6                	sd	s1,216(sp)
    800068d4:	e9ca                	sd	s2,208(sp)
    800068d6:	e5ce                	sd	s3,200(sp)
    800068d8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800068da:	08000613          	li	a2,128
    800068de:	f3040593          	addi	a1,s0,-208
    800068e2:	4501                	li	a0,0
    800068e4:	ffffd097          	auipc	ra,0xffffd
    800068e8:	33e080e7          	jalr	830(ra) # 80003c22 <argstr>
    800068ec:	18054163          	bltz	a0,80006a6e <sys_unlink+0x1a2>
  begin_op();
    800068f0:	fffff097          	auipc	ra,0xfffff
    800068f4:	c14080e7          	jalr	-1004(ra) # 80005504 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800068f8:	fb040593          	addi	a1,s0,-80
    800068fc:	f3040513          	addi	a0,s0,-208
    80006900:	fffff097          	auipc	ra,0xfffff
    80006904:	a06080e7          	jalr	-1530(ra) # 80005306 <nameiparent>
    80006908:	84aa                	mv	s1,a0
    8000690a:	c979                	beqz	a0,800069e0 <sys_unlink+0x114>
  ilock(dp);
    8000690c:	ffffe097          	auipc	ra,0xffffe
    80006910:	226080e7          	jalr	550(ra) # 80004b32 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006914:	00003597          	auipc	a1,0x3
    80006918:	0cc58593          	addi	a1,a1,204 # 800099e0 <syscalls+0x3a0>
    8000691c:	fb040513          	addi	a0,s0,-80
    80006920:	ffffe097          	auipc	ra,0xffffe
    80006924:	6dc080e7          	jalr	1756(ra) # 80004ffc <namecmp>
    80006928:	14050a63          	beqz	a0,80006a7c <sys_unlink+0x1b0>
    8000692c:	00003597          	auipc	a1,0x3
    80006930:	0bc58593          	addi	a1,a1,188 # 800099e8 <syscalls+0x3a8>
    80006934:	fb040513          	addi	a0,s0,-80
    80006938:	ffffe097          	auipc	ra,0xffffe
    8000693c:	6c4080e7          	jalr	1732(ra) # 80004ffc <namecmp>
    80006940:	12050e63          	beqz	a0,80006a7c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80006944:	f2c40613          	addi	a2,s0,-212
    80006948:	fb040593          	addi	a1,s0,-80
    8000694c:	8526                	mv	a0,s1
    8000694e:	ffffe097          	auipc	ra,0xffffe
    80006952:	6c8080e7          	jalr	1736(ra) # 80005016 <dirlookup>
    80006956:	892a                	mv	s2,a0
    80006958:	12050263          	beqz	a0,80006a7c <sys_unlink+0x1b0>
  ilock(ip);
    8000695c:	ffffe097          	auipc	ra,0xffffe
    80006960:	1d6080e7          	jalr	470(ra) # 80004b32 <ilock>
  if(ip->nlink < 1)
    80006964:	04a91783          	lh	a5,74(s2)
    80006968:	08f05263          	blez	a5,800069ec <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000696c:	04491703          	lh	a4,68(s2)
    80006970:	4785                	li	a5,1
    80006972:	08f70563          	beq	a4,a5,800069fc <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006976:	4641                	li	a2,16
    80006978:	4581                	li	a1,0
    8000697a:	fc040513          	addi	a0,s0,-64
    8000697e:	ffffa097          	auipc	ra,0xffffa
    80006982:	360080e7          	jalr	864(ra) # 80000cde <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006986:	4741                	li	a4,16
    80006988:	f2c42683          	lw	a3,-212(s0)
    8000698c:	fc040613          	addi	a2,s0,-64
    80006990:	4581                	li	a1,0
    80006992:	8526                	mv	a0,s1
    80006994:	ffffe097          	auipc	ra,0xffffe
    80006998:	54a080e7          	jalr	1354(ra) # 80004ede <writei>
    8000699c:	47c1                	li	a5,16
    8000699e:	0af51563          	bne	a0,a5,80006a48 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800069a2:	04491703          	lh	a4,68(s2)
    800069a6:	4785                	li	a5,1
    800069a8:	0af70863          	beq	a4,a5,80006a58 <sys_unlink+0x18c>
  iunlockput(dp);
    800069ac:	8526                	mv	a0,s1
    800069ae:	ffffe097          	auipc	ra,0xffffe
    800069b2:	3e6080e7          	jalr	998(ra) # 80004d94 <iunlockput>
  ip->nlink--;
    800069b6:	04a95783          	lhu	a5,74(s2)
    800069ba:	37fd                	addiw	a5,a5,-1
    800069bc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800069c0:	854a                	mv	a0,s2
    800069c2:	ffffe097          	auipc	ra,0xffffe
    800069c6:	0a6080e7          	jalr	166(ra) # 80004a68 <iupdate>
  iunlockput(ip);
    800069ca:	854a                	mv	a0,s2
    800069cc:	ffffe097          	auipc	ra,0xffffe
    800069d0:	3c8080e7          	jalr	968(ra) # 80004d94 <iunlockput>
  end_op();
    800069d4:	fffff097          	auipc	ra,0xfffff
    800069d8:	bb0080e7          	jalr	-1104(ra) # 80005584 <end_op>
  return 0;
    800069dc:	4501                	li	a0,0
    800069de:	a84d                	j	80006a90 <sys_unlink+0x1c4>
    end_op();
    800069e0:	fffff097          	auipc	ra,0xfffff
    800069e4:	ba4080e7          	jalr	-1116(ra) # 80005584 <end_op>
    return -1;
    800069e8:	557d                	li	a0,-1
    800069ea:	a05d                	j	80006a90 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800069ec:	00003517          	auipc	a0,0x3
    800069f0:	02450513          	addi	a0,a0,36 # 80009a10 <syscalls+0x3d0>
    800069f4:	ffffa097          	auipc	ra,0xffffa
    800069f8:	b48080e7          	jalr	-1208(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800069fc:	04c92703          	lw	a4,76(s2)
    80006a00:	02000793          	li	a5,32
    80006a04:	f6e7f9e3          	bgeu	a5,a4,80006976 <sys_unlink+0xaa>
    80006a08:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006a0c:	4741                	li	a4,16
    80006a0e:	86ce                	mv	a3,s3
    80006a10:	f1840613          	addi	a2,s0,-232
    80006a14:	4581                	li	a1,0
    80006a16:	854a                	mv	a0,s2
    80006a18:	ffffe097          	auipc	ra,0xffffe
    80006a1c:	3ce080e7          	jalr	974(ra) # 80004de6 <readi>
    80006a20:	47c1                	li	a5,16
    80006a22:	00f51b63          	bne	a0,a5,80006a38 <sys_unlink+0x16c>
    if(de.inum != 0)
    80006a26:	f1845783          	lhu	a5,-232(s0)
    80006a2a:	e7a1                	bnez	a5,80006a72 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006a2c:	29c1                	addiw	s3,s3,16
    80006a2e:	04c92783          	lw	a5,76(s2)
    80006a32:	fcf9ede3          	bltu	s3,a5,80006a0c <sys_unlink+0x140>
    80006a36:	b781                	j	80006976 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006a38:	00003517          	auipc	a0,0x3
    80006a3c:	ff050513          	addi	a0,a0,-16 # 80009a28 <syscalls+0x3e8>
    80006a40:	ffffa097          	auipc	ra,0xffffa
    80006a44:	afc080e7          	jalr	-1284(ra) # 8000053c <panic>
    panic("unlink: writei");
    80006a48:	00003517          	auipc	a0,0x3
    80006a4c:	ff850513          	addi	a0,a0,-8 # 80009a40 <syscalls+0x400>
    80006a50:	ffffa097          	auipc	ra,0xffffa
    80006a54:	aec080e7          	jalr	-1300(ra) # 8000053c <panic>
    dp->nlink--;
    80006a58:	04a4d783          	lhu	a5,74(s1)
    80006a5c:	37fd                	addiw	a5,a5,-1
    80006a5e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006a62:	8526                	mv	a0,s1
    80006a64:	ffffe097          	auipc	ra,0xffffe
    80006a68:	004080e7          	jalr	4(ra) # 80004a68 <iupdate>
    80006a6c:	b781                	j	800069ac <sys_unlink+0xe0>
    return -1;
    80006a6e:	557d                	li	a0,-1
    80006a70:	a005                	j	80006a90 <sys_unlink+0x1c4>
    iunlockput(ip);
    80006a72:	854a                	mv	a0,s2
    80006a74:	ffffe097          	auipc	ra,0xffffe
    80006a78:	320080e7          	jalr	800(ra) # 80004d94 <iunlockput>
  iunlockput(dp);
    80006a7c:	8526                	mv	a0,s1
    80006a7e:	ffffe097          	auipc	ra,0xffffe
    80006a82:	316080e7          	jalr	790(ra) # 80004d94 <iunlockput>
  end_op();
    80006a86:	fffff097          	auipc	ra,0xfffff
    80006a8a:	afe080e7          	jalr	-1282(ra) # 80005584 <end_op>
  return -1;
    80006a8e:	557d                	li	a0,-1
}
    80006a90:	70ae                	ld	ra,232(sp)
    80006a92:	740e                	ld	s0,224(sp)
    80006a94:	64ee                	ld	s1,216(sp)
    80006a96:	694e                	ld	s2,208(sp)
    80006a98:	69ae                	ld	s3,200(sp)
    80006a9a:	616d                	addi	sp,sp,240
    80006a9c:	8082                	ret

0000000080006a9e <sys_open>:

uint64
sys_open(void)
{
    80006a9e:	7131                	addi	sp,sp,-192
    80006aa0:	fd06                	sd	ra,184(sp)
    80006aa2:	f922                	sd	s0,176(sp)
    80006aa4:	f526                	sd	s1,168(sp)
    80006aa6:	f14a                	sd	s2,160(sp)
    80006aa8:	ed4e                	sd	s3,152(sp)
    80006aaa:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006aac:	08000613          	li	a2,128
    80006ab0:	f5040593          	addi	a1,s0,-176
    80006ab4:	4501                	li	a0,0
    80006ab6:	ffffd097          	auipc	ra,0xffffd
    80006aba:	16c080e7          	jalr	364(ra) # 80003c22 <argstr>
    return -1;
    80006abe:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006ac0:	0c054163          	bltz	a0,80006b82 <sys_open+0xe4>
    80006ac4:	f4c40593          	addi	a1,s0,-180
    80006ac8:	4505                	li	a0,1
    80006aca:	ffffd097          	auipc	ra,0xffffd
    80006ace:	114080e7          	jalr	276(ra) # 80003bde <argint>
    80006ad2:	0a054863          	bltz	a0,80006b82 <sys_open+0xe4>

  begin_op();
    80006ad6:	fffff097          	auipc	ra,0xfffff
    80006ada:	a2e080e7          	jalr	-1490(ra) # 80005504 <begin_op>

  if(omode & O_CREATE){
    80006ade:	f4c42783          	lw	a5,-180(s0)
    80006ae2:	2007f793          	andi	a5,a5,512
    80006ae6:	cbdd                	beqz	a5,80006b9c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006ae8:	4681                	li	a3,0
    80006aea:	4601                	li	a2,0
    80006aec:	4589                	li	a1,2
    80006aee:	f5040513          	addi	a0,s0,-176
    80006af2:	00000097          	auipc	ra,0x0
    80006af6:	972080e7          	jalr	-1678(ra) # 80006464 <create>
    80006afa:	892a                	mv	s2,a0
    if(ip == 0){
    80006afc:	c959                	beqz	a0,80006b92 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006afe:	04491703          	lh	a4,68(s2)
    80006b02:	478d                	li	a5,3
    80006b04:	00f71763          	bne	a4,a5,80006b12 <sys_open+0x74>
    80006b08:	04695703          	lhu	a4,70(s2)
    80006b0c:	47a5                	li	a5,9
    80006b0e:	0ce7ec63          	bltu	a5,a4,80006be6 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006b12:	fffff097          	auipc	ra,0xfffff
    80006b16:	e02080e7          	jalr	-510(ra) # 80005914 <filealloc>
    80006b1a:	89aa                	mv	s3,a0
    80006b1c:	10050263          	beqz	a0,80006c20 <sys_open+0x182>
    80006b20:	00000097          	auipc	ra,0x0
    80006b24:	902080e7          	jalr	-1790(ra) # 80006422 <fdalloc>
    80006b28:	84aa                	mv	s1,a0
    80006b2a:	0e054663          	bltz	a0,80006c16 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006b2e:	04491703          	lh	a4,68(s2)
    80006b32:	478d                	li	a5,3
    80006b34:	0cf70463          	beq	a4,a5,80006bfc <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006b38:	4789                	li	a5,2
    80006b3a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006b3e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006b42:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006b46:	f4c42783          	lw	a5,-180(s0)
    80006b4a:	0017c713          	xori	a4,a5,1
    80006b4e:	8b05                	andi	a4,a4,1
    80006b50:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006b54:	0037f713          	andi	a4,a5,3
    80006b58:	00e03733          	snez	a4,a4
    80006b5c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006b60:	4007f793          	andi	a5,a5,1024
    80006b64:	c791                	beqz	a5,80006b70 <sys_open+0xd2>
    80006b66:	04491703          	lh	a4,68(s2)
    80006b6a:	4789                	li	a5,2
    80006b6c:	08f70f63          	beq	a4,a5,80006c0a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006b70:	854a                	mv	a0,s2
    80006b72:	ffffe097          	auipc	ra,0xffffe
    80006b76:	082080e7          	jalr	130(ra) # 80004bf4 <iunlock>
  end_op();
    80006b7a:	fffff097          	auipc	ra,0xfffff
    80006b7e:	a0a080e7          	jalr	-1526(ra) # 80005584 <end_op>

  return fd;
}
    80006b82:	8526                	mv	a0,s1
    80006b84:	70ea                	ld	ra,184(sp)
    80006b86:	744a                	ld	s0,176(sp)
    80006b88:	74aa                	ld	s1,168(sp)
    80006b8a:	790a                	ld	s2,160(sp)
    80006b8c:	69ea                	ld	s3,152(sp)
    80006b8e:	6129                	addi	sp,sp,192
    80006b90:	8082                	ret
      end_op();
    80006b92:	fffff097          	auipc	ra,0xfffff
    80006b96:	9f2080e7          	jalr	-1550(ra) # 80005584 <end_op>
      return -1;
    80006b9a:	b7e5                	j	80006b82 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006b9c:	f5040513          	addi	a0,s0,-176
    80006ba0:	ffffe097          	auipc	ra,0xffffe
    80006ba4:	748080e7          	jalr	1864(ra) # 800052e8 <namei>
    80006ba8:	892a                	mv	s2,a0
    80006baa:	c905                	beqz	a0,80006bda <sys_open+0x13c>
    ilock(ip);
    80006bac:	ffffe097          	auipc	ra,0xffffe
    80006bb0:	f86080e7          	jalr	-122(ra) # 80004b32 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006bb4:	04491703          	lh	a4,68(s2)
    80006bb8:	4785                	li	a5,1
    80006bba:	f4f712e3          	bne	a4,a5,80006afe <sys_open+0x60>
    80006bbe:	f4c42783          	lw	a5,-180(s0)
    80006bc2:	dba1                	beqz	a5,80006b12 <sys_open+0x74>
      iunlockput(ip);
    80006bc4:	854a                	mv	a0,s2
    80006bc6:	ffffe097          	auipc	ra,0xffffe
    80006bca:	1ce080e7          	jalr	462(ra) # 80004d94 <iunlockput>
      end_op();
    80006bce:	fffff097          	auipc	ra,0xfffff
    80006bd2:	9b6080e7          	jalr	-1610(ra) # 80005584 <end_op>
      return -1;
    80006bd6:	54fd                	li	s1,-1
    80006bd8:	b76d                	j	80006b82 <sys_open+0xe4>
      end_op();
    80006bda:	fffff097          	auipc	ra,0xfffff
    80006bde:	9aa080e7          	jalr	-1622(ra) # 80005584 <end_op>
      return -1;
    80006be2:	54fd                	li	s1,-1
    80006be4:	bf79                	j	80006b82 <sys_open+0xe4>
    iunlockput(ip);
    80006be6:	854a                	mv	a0,s2
    80006be8:	ffffe097          	auipc	ra,0xffffe
    80006bec:	1ac080e7          	jalr	428(ra) # 80004d94 <iunlockput>
    end_op();
    80006bf0:	fffff097          	auipc	ra,0xfffff
    80006bf4:	994080e7          	jalr	-1644(ra) # 80005584 <end_op>
    return -1;
    80006bf8:	54fd                	li	s1,-1
    80006bfa:	b761                	j	80006b82 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006bfc:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006c00:	04691783          	lh	a5,70(s2)
    80006c04:	02f99223          	sh	a5,36(s3)
    80006c08:	bf2d                	j	80006b42 <sys_open+0xa4>
    itrunc(ip);
    80006c0a:	854a                	mv	a0,s2
    80006c0c:	ffffe097          	auipc	ra,0xffffe
    80006c10:	034080e7          	jalr	52(ra) # 80004c40 <itrunc>
    80006c14:	bfb1                	j	80006b70 <sys_open+0xd2>
      fileclose(f);
    80006c16:	854e                	mv	a0,s3
    80006c18:	fffff097          	auipc	ra,0xfffff
    80006c1c:	db8080e7          	jalr	-584(ra) # 800059d0 <fileclose>
    iunlockput(ip);
    80006c20:	854a                	mv	a0,s2
    80006c22:	ffffe097          	auipc	ra,0xffffe
    80006c26:	172080e7          	jalr	370(ra) # 80004d94 <iunlockput>
    end_op();
    80006c2a:	fffff097          	auipc	ra,0xfffff
    80006c2e:	95a080e7          	jalr	-1702(ra) # 80005584 <end_op>
    return -1;
    80006c32:	54fd                	li	s1,-1
    80006c34:	b7b9                	j	80006b82 <sys_open+0xe4>

0000000080006c36 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006c36:	7175                	addi	sp,sp,-144
    80006c38:	e506                	sd	ra,136(sp)
    80006c3a:	e122                	sd	s0,128(sp)
    80006c3c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006c3e:	fffff097          	auipc	ra,0xfffff
    80006c42:	8c6080e7          	jalr	-1850(ra) # 80005504 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006c46:	08000613          	li	a2,128
    80006c4a:	f7040593          	addi	a1,s0,-144
    80006c4e:	4501                	li	a0,0
    80006c50:	ffffd097          	auipc	ra,0xffffd
    80006c54:	fd2080e7          	jalr	-46(ra) # 80003c22 <argstr>
    80006c58:	02054963          	bltz	a0,80006c8a <sys_mkdir+0x54>
    80006c5c:	4681                	li	a3,0
    80006c5e:	4601                	li	a2,0
    80006c60:	4585                	li	a1,1
    80006c62:	f7040513          	addi	a0,s0,-144
    80006c66:	fffff097          	auipc	ra,0xfffff
    80006c6a:	7fe080e7          	jalr	2046(ra) # 80006464 <create>
    80006c6e:	cd11                	beqz	a0,80006c8a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006c70:	ffffe097          	auipc	ra,0xffffe
    80006c74:	124080e7          	jalr	292(ra) # 80004d94 <iunlockput>
  end_op();
    80006c78:	fffff097          	auipc	ra,0xfffff
    80006c7c:	90c080e7          	jalr	-1780(ra) # 80005584 <end_op>
  return 0;
    80006c80:	4501                	li	a0,0
}
    80006c82:	60aa                	ld	ra,136(sp)
    80006c84:	640a                	ld	s0,128(sp)
    80006c86:	6149                	addi	sp,sp,144
    80006c88:	8082                	ret
    end_op();
    80006c8a:	fffff097          	auipc	ra,0xfffff
    80006c8e:	8fa080e7          	jalr	-1798(ra) # 80005584 <end_op>
    return -1;
    80006c92:	557d                	li	a0,-1
    80006c94:	b7fd                	j	80006c82 <sys_mkdir+0x4c>

0000000080006c96 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006c96:	7135                	addi	sp,sp,-160
    80006c98:	ed06                	sd	ra,152(sp)
    80006c9a:	e922                	sd	s0,144(sp)
    80006c9c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006c9e:	fffff097          	auipc	ra,0xfffff
    80006ca2:	866080e7          	jalr	-1946(ra) # 80005504 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006ca6:	08000613          	li	a2,128
    80006caa:	f7040593          	addi	a1,s0,-144
    80006cae:	4501                	li	a0,0
    80006cb0:	ffffd097          	auipc	ra,0xffffd
    80006cb4:	f72080e7          	jalr	-142(ra) # 80003c22 <argstr>
    80006cb8:	04054a63          	bltz	a0,80006d0c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006cbc:	f6c40593          	addi	a1,s0,-148
    80006cc0:	4505                	li	a0,1
    80006cc2:	ffffd097          	auipc	ra,0xffffd
    80006cc6:	f1c080e7          	jalr	-228(ra) # 80003bde <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006cca:	04054163          	bltz	a0,80006d0c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006cce:	f6840593          	addi	a1,s0,-152
    80006cd2:	4509                	li	a0,2
    80006cd4:	ffffd097          	auipc	ra,0xffffd
    80006cd8:	f0a080e7          	jalr	-246(ra) # 80003bde <argint>
     argint(1, &major) < 0 ||
    80006cdc:	02054863          	bltz	a0,80006d0c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006ce0:	f6841683          	lh	a3,-152(s0)
    80006ce4:	f6c41603          	lh	a2,-148(s0)
    80006ce8:	458d                	li	a1,3
    80006cea:	f7040513          	addi	a0,s0,-144
    80006cee:	fffff097          	auipc	ra,0xfffff
    80006cf2:	776080e7          	jalr	1910(ra) # 80006464 <create>
     argint(2, &minor) < 0 ||
    80006cf6:	c919                	beqz	a0,80006d0c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006cf8:	ffffe097          	auipc	ra,0xffffe
    80006cfc:	09c080e7          	jalr	156(ra) # 80004d94 <iunlockput>
  end_op();
    80006d00:	fffff097          	auipc	ra,0xfffff
    80006d04:	884080e7          	jalr	-1916(ra) # 80005584 <end_op>
  return 0;
    80006d08:	4501                	li	a0,0
    80006d0a:	a031                	j	80006d16 <sys_mknod+0x80>
    end_op();
    80006d0c:	fffff097          	auipc	ra,0xfffff
    80006d10:	878080e7          	jalr	-1928(ra) # 80005584 <end_op>
    return -1;
    80006d14:	557d                	li	a0,-1
}
    80006d16:	60ea                	ld	ra,152(sp)
    80006d18:	644a                	ld	s0,144(sp)
    80006d1a:	610d                	addi	sp,sp,160
    80006d1c:	8082                	ret

0000000080006d1e <sys_chdir>:

uint64
sys_chdir(void)
{
    80006d1e:	7135                	addi	sp,sp,-160
    80006d20:	ed06                	sd	ra,152(sp)
    80006d22:	e922                	sd	s0,144(sp)
    80006d24:	e526                	sd	s1,136(sp)
    80006d26:	e14a                	sd	s2,128(sp)
    80006d28:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006d2a:	ffffb097          	auipc	ra,0xffffb
    80006d2e:	caa080e7          	jalr	-854(ra) # 800019d4 <myproc>
    80006d32:	892a                	mv	s2,a0
  
  begin_op();
    80006d34:	ffffe097          	auipc	ra,0xffffe
    80006d38:	7d0080e7          	jalr	2000(ra) # 80005504 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006d3c:	08000613          	li	a2,128
    80006d40:	f6040593          	addi	a1,s0,-160
    80006d44:	4501                	li	a0,0
    80006d46:	ffffd097          	auipc	ra,0xffffd
    80006d4a:	edc080e7          	jalr	-292(ra) # 80003c22 <argstr>
    80006d4e:	04054b63          	bltz	a0,80006da4 <sys_chdir+0x86>
    80006d52:	f6040513          	addi	a0,s0,-160
    80006d56:	ffffe097          	auipc	ra,0xffffe
    80006d5a:	592080e7          	jalr	1426(ra) # 800052e8 <namei>
    80006d5e:	84aa                	mv	s1,a0
    80006d60:	c131                	beqz	a0,80006da4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006d62:	ffffe097          	auipc	ra,0xffffe
    80006d66:	dd0080e7          	jalr	-560(ra) # 80004b32 <ilock>
  if(ip->type != T_DIR){
    80006d6a:	04449703          	lh	a4,68(s1)
    80006d6e:	4785                	li	a5,1
    80006d70:	04f71063          	bne	a4,a5,80006db0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006d74:	8526                	mv	a0,s1
    80006d76:	ffffe097          	auipc	ra,0xffffe
    80006d7a:	e7e080e7          	jalr	-386(ra) # 80004bf4 <iunlock>
  iput(p->cwd);
    80006d7e:	15893503          	ld	a0,344(s2)
    80006d82:	ffffe097          	auipc	ra,0xffffe
    80006d86:	f6a080e7          	jalr	-150(ra) # 80004cec <iput>
  end_op();
    80006d8a:	ffffe097          	auipc	ra,0xffffe
    80006d8e:	7fa080e7          	jalr	2042(ra) # 80005584 <end_op>
  p->cwd = ip;
    80006d92:	14993c23          	sd	s1,344(s2)
  return 0;
    80006d96:	4501                	li	a0,0
}
    80006d98:	60ea                	ld	ra,152(sp)
    80006d9a:	644a                	ld	s0,144(sp)
    80006d9c:	64aa                	ld	s1,136(sp)
    80006d9e:	690a                	ld	s2,128(sp)
    80006da0:	610d                	addi	sp,sp,160
    80006da2:	8082                	ret
    end_op();
    80006da4:	ffffe097          	auipc	ra,0xffffe
    80006da8:	7e0080e7          	jalr	2016(ra) # 80005584 <end_op>
    return -1;
    80006dac:	557d                	li	a0,-1
    80006dae:	b7ed                	j	80006d98 <sys_chdir+0x7a>
    iunlockput(ip);
    80006db0:	8526                	mv	a0,s1
    80006db2:	ffffe097          	auipc	ra,0xffffe
    80006db6:	fe2080e7          	jalr	-30(ra) # 80004d94 <iunlockput>
    end_op();
    80006dba:	ffffe097          	auipc	ra,0xffffe
    80006dbe:	7ca080e7          	jalr	1994(ra) # 80005584 <end_op>
    return -1;
    80006dc2:	557d                	li	a0,-1
    80006dc4:	bfd1                	j	80006d98 <sys_chdir+0x7a>

0000000080006dc6 <sys_exec>:

uint64
sys_exec(void)
{
    80006dc6:	7145                	addi	sp,sp,-464
    80006dc8:	e786                	sd	ra,456(sp)
    80006dca:	e3a2                	sd	s0,448(sp)
    80006dcc:	ff26                	sd	s1,440(sp)
    80006dce:	fb4a                	sd	s2,432(sp)
    80006dd0:	f74e                	sd	s3,424(sp)
    80006dd2:	f352                	sd	s4,416(sp)
    80006dd4:	ef56                	sd	s5,408(sp)
    80006dd6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006dd8:	08000613          	li	a2,128
    80006ddc:	f4040593          	addi	a1,s0,-192
    80006de0:	4501                	li	a0,0
    80006de2:	ffffd097          	auipc	ra,0xffffd
    80006de6:	e40080e7          	jalr	-448(ra) # 80003c22 <argstr>
    return -1;
    80006dea:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006dec:	0c054a63          	bltz	a0,80006ec0 <sys_exec+0xfa>
    80006df0:	e3840593          	addi	a1,s0,-456
    80006df4:	4505                	li	a0,1
    80006df6:	ffffd097          	auipc	ra,0xffffd
    80006dfa:	e0a080e7          	jalr	-502(ra) # 80003c00 <argaddr>
    80006dfe:	0c054163          	bltz	a0,80006ec0 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006e02:	10000613          	li	a2,256
    80006e06:	4581                	li	a1,0
    80006e08:	e4040513          	addi	a0,s0,-448
    80006e0c:	ffffa097          	auipc	ra,0xffffa
    80006e10:	ed2080e7          	jalr	-302(ra) # 80000cde <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006e14:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006e18:	89a6                	mv	s3,s1
    80006e1a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006e1c:	02000a13          	li	s4,32
    80006e20:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006e24:	00391513          	slli	a0,s2,0x3
    80006e28:	e3040593          	addi	a1,s0,-464
    80006e2c:	e3843783          	ld	a5,-456(s0)
    80006e30:	953e                	add	a0,a0,a5
    80006e32:	ffffd097          	auipc	ra,0xffffd
    80006e36:	d12080e7          	jalr	-750(ra) # 80003b44 <fetchaddr>
    80006e3a:	02054a63          	bltz	a0,80006e6e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006e3e:	e3043783          	ld	a5,-464(s0)
    80006e42:	c3b9                	beqz	a5,80006e88 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006e44:	ffffa097          	auipc	ra,0xffffa
    80006e48:	cae080e7          	jalr	-850(ra) # 80000af2 <kalloc>
    80006e4c:	85aa                	mv	a1,a0
    80006e4e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006e52:	cd11                	beqz	a0,80006e6e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006e54:	6605                	lui	a2,0x1
    80006e56:	e3043503          	ld	a0,-464(s0)
    80006e5a:	ffffd097          	auipc	ra,0xffffd
    80006e5e:	d3c080e7          	jalr	-708(ra) # 80003b96 <fetchstr>
    80006e62:	00054663          	bltz	a0,80006e6e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006e66:	0905                	addi	s2,s2,1
    80006e68:	09a1                	addi	s3,s3,8
    80006e6a:	fb491be3          	bne	s2,s4,80006e20 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006e6e:	10048913          	addi	s2,s1,256
    80006e72:	6088                	ld	a0,0(s1)
    80006e74:	c529                	beqz	a0,80006ebe <sys_exec+0xf8>
    kfree(argv[i]);
    80006e76:	ffffa097          	auipc	ra,0xffffa
    80006e7a:	b80080e7          	jalr	-1152(ra) # 800009f6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006e7e:	04a1                	addi	s1,s1,8
    80006e80:	ff2499e3          	bne	s1,s2,80006e72 <sys_exec+0xac>
  return -1;
    80006e84:	597d                	li	s2,-1
    80006e86:	a82d                	j	80006ec0 <sys_exec+0xfa>
      argv[i] = 0;
    80006e88:	0a8e                	slli	s5,s5,0x3
    80006e8a:	fc040793          	addi	a5,s0,-64
    80006e8e:	9abe                	add	s5,s5,a5
    80006e90:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006e94:	e4040593          	addi	a1,s0,-448
    80006e98:	f4040513          	addi	a0,s0,-192
    80006e9c:	fffff097          	auipc	ra,0xfffff
    80006ea0:	194080e7          	jalr	404(ra) # 80006030 <exec>
    80006ea4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006ea6:	10048993          	addi	s3,s1,256
    80006eaa:	6088                	ld	a0,0(s1)
    80006eac:	c911                	beqz	a0,80006ec0 <sys_exec+0xfa>
    kfree(argv[i]);
    80006eae:	ffffa097          	auipc	ra,0xffffa
    80006eb2:	b48080e7          	jalr	-1208(ra) # 800009f6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006eb6:	04a1                	addi	s1,s1,8
    80006eb8:	ff3499e3          	bne	s1,s3,80006eaa <sys_exec+0xe4>
    80006ebc:	a011                	j	80006ec0 <sys_exec+0xfa>
  return -1;
    80006ebe:	597d                	li	s2,-1
}
    80006ec0:	854a                	mv	a0,s2
    80006ec2:	60be                	ld	ra,456(sp)
    80006ec4:	641e                	ld	s0,448(sp)
    80006ec6:	74fa                	ld	s1,440(sp)
    80006ec8:	795a                	ld	s2,432(sp)
    80006eca:	79ba                	ld	s3,424(sp)
    80006ecc:	7a1a                	ld	s4,416(sp)
    80006ece:	6afa                	ld	s5,408(sp)
    80006ed0:	6179                	addi	sp,sp,464
    80006ed2:	8082                	ret

0000000080006ed4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006ed4:	7139                	addi	sp,sp,-64
    80006ed6:	fc06                	sd	ra,56(sp)
    80006ed8:	f822                	sd	s0,48(sp)
    80006eda:	f426                	sd	s1,40(sp)
    80006edc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006ede:	ffffb097          	auipc	ra,0xffffb
    80006ee2:	af6080e7          	jalr	-1290(ra) # 800019d4 <myproc>
    80006ee6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006ee8:	fd840593          	addi	a1,s0,-40
    80006eec:	4501                	li	a0,0
    80006eee:	ffffd097          	auipc	ra,0xffffd
    80006ef2:	d12080e7          	jalr	-750(ra) # 80003c00 <argaddr>
    return -1;
    80006ef6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006ef8:	0e054063          	bltz	a0,80006fd8 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006efc:	fc840593          	addi	a1,s0,-56
    80006f00:	fd040513          	addi	a0,s0,-48
    80006f04:	fffff097          	auipc	ra,0xfffff
    80006f08:	dfc080e7          	jalr	-516(ra) # 80005d00 <pipealloc>
    return -1;
    80006f0c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006f0e:	0c054563          	bltz	a0,80006fd8 <sys_pipe+0x104>
  fd0 = -1;
    80006f12:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006f16:	fd043503          	ld	a0,-48(s0)
    80006f1a:	fffff097          	auipc	ra,0xfffff
    80006f1e:	508080e7          	jalr	1288(ra) # 80006422 <fdalloc>
    80006f22:	fca42223          	sw	a0,-60(s0)
    80006f26:	08054c63          	bltz	a0,80006fbe <sys_pipe+0xea>
    80006f2a:	fc843503          	ld	a0,-56(s0)
    80006f2e:	fffff097          	auipc	ra,0xfffff
    80006f32:	4f4080e7          	jalr	1268(ra) # 80006422 <fdalloc>
    80006f36:	fca42023          	sw	a0,-64(s0)
    80006f3a:	06054863          	bltz	a0,80006faa <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006f3e:	4691                	li	a3,4
    80006f40:	fc440613          	addi	a2,s0,-60
    80006f44:	fd843583          	ld	a1,-40(s0)
    80006f48:	6ca8                	ld	a0,88(s1)
    80006f4a:	ffffa097          	auipc	ra,0xffffa
    80006f4e:	74c080e7          	jalr	1868(ra) # 80001696 <copyout>
    80006f52:	02054063          	bltz	a0,80006f72 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006f56:	4691                	li	a3,4
    80006f58:	fc040613          	addi	a2,s0,-64
    80006f5c:	fd843583          	ld	a1,-40(s0)
    80006f60:	0591                	addi	a1,a1,4
    80006f62:	6ca8                	ld	a0,88(s1)
    80006f64:	ffffa097          	auipc	ra,0xffffa
    80006f68:	732080e7          	jalr	1842(ra) # 80001696 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006f6c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006f6e:	06055563          	bgez	a0,80006fd8 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006f72:	fc442783          	lw	a5,-60(s0)
    80006f76:	07e9                	addi	a5,a5,26
    80006f78:	078e                	slli	a5,a5,0x3
    80006f7a:	97a6                	add	a5,a5,s1
    80006f7c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006f80:	fc042503          	lw	a0,-64(s0)
    80006f84:	0569                	addi	a0,a0,26
    80006f86:	050e                	slli	a0,a0,0x3
    80006f88:	9526                	add	a0,a0,s1
    80006f8a:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006f8e:	fd043503          	ld	a0,-48(s0)
    80006f92:	fffff097          	auipc	ra,0xfffff
    80006f96:	a3e080e7          	jalr	-1474(ra) # 800059d0 <fileclose>
    fileclose(wf);
    80006f9a:	fc843503          	ld	a0,-56(s0)
    80006f9e:	fffff097          	auipc	ra,0xfffff
    80006fa2:	a32080e7          	jalr	-1486(ra) # 800059d0 <fileclose>
    return -1;
    80006fa6:	57fd                	li	a5,-1
    80006fa8:	a805                	j	80006fd8 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006faa:	fc442783          	lw	a5,-60(s0)
    80006fae:	0007c863          	bltz	a5,80006fbe <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006fb2:	01a78513          	addi	a0,a5,26
    80006fb6:	050e                	slli	a0,a0,0x3
    80006fb8:	9526                	add	a0,a0,s1
    80006fba:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006fbe:	fd043503          	ld	a0,-48(s0)
    80006fc2:	fffff097          	auipc	ra,0xfffff
    80006fc6:	a0e080e7          	jalr	-1522(ra) # 800059d0 <fileclose>
    fileclose(wf);
    80006fca:	fc843503          	ld	a0,-56(s0)
    80006fce:	fffff097          	auipc	ra,0xfffff
    80006fd2:	a02080e7          	jalr	-1534(ra) # 800059d0 <fileclose>
    return -1;
    80006fd6:	57fd                	li	a5,-1
}
    80006fd8:	853e                	mv	a0,a5
    80006fda:	70e2                	ld	ra,56(sp)
    80006fdc:	7442                	ld	s0,48(sp)
    80006fde:	74a2                	ld	s1,40(sp)
    80006fe0:	6121                	addi	sp,sp,64
    80006fe2:	8082                	ret
	...

0000000080006ff0 <kernelvec>:
    80006ff0:	7111                	addi	sp,sp,-256
    80006ff2:	e006                	sd	ra,0(sp)
    80006ff4:	e40a                	sd	sp,8(sp)
    80006ff6:	e80e                	sd	gp,16(sp)
    80006ff8:	ec12                	sd	tp,24(sp)
    80006ffa:	f016                	sd	t0,32(sp)
    80006ffc:	f41a                	sd	t1,40(sp)
    80006ffe:	f81e                	sd	t2,48(sp)
    80007000:	fc22                	sd	s0,56(sp)
    80007002:	e0a6                	sd	s1,64(sp)
    80007004:	e4aa                	sd	a0,72(sp)
    80007006:	e8ae                	sd	a1,80(sp)
    80007008:	ecb2                	sd	a2,88(sp)
    8000700a:	f0b6                	sd	a3,96(sp)
    8000700c:	f4ba                	sd	a4,104(sp)
    8000700e:	f8be                	sd	a5,112(sp)
    80007010:	fcc2                	sd	a6,120(sp)
    80007012:	e146                	sd	a7,128(sp)
    80007014:	e54a                	sd	s2,136(sp)
    80007016:	e94e                	sd	s3,144(sp)
    80007018:	ed52                	sd	s4,152(sp)
    8000701a:	f156                	sd	s5,160(sp)
    8000701c:	f55a                	sd	s6,168(sp)
    8000701e:	f95e                	sd	s7,176(sp)
    80007020:	fd62                	sd	s8,184(sp)
    80007022:	e1e6                	sd	s9,192(sp)
    80007024:	e5ea                	sd	s10,200(sp)
    80007026:	e9ee                	sd	s11,208(sp)
    80007028:	edf2                	sd	t3,216(sp)
    8000702a:	f1f6                	sd	t4,224(sp)
    8000702c:	f5fa                	sd	t5,232(sp)
    8000702e:	f9fe                	sd	t6,240(sp)
    80007030:	9d3fc0ef          	jal	ra,80003a02 <kerneltrap>
    80007034:	6082                	ld	ra,0(sp)
    80007036:	6122                	ld	sp,8(sp)
    80007038:	61c2                	ld	gp,16(sp)
    8000703a:	7282                	ld	t0,32(sp)
    8000703c:	7322                	ld	t1,40(sp)
    8000703e:	73c2                	ld	t2,48(sp)
    80007040:	7462                	ld	s0,56(sp)
    80007042:	6486                	ld	s1,64(sp)
    80007044:	6526                	ld	a0,72(sp)
    80007046:	65c6                	ld	a1,80(sp)
    80007048:	6666                	ld	a2,88(sp)
    8000704a:	7686                	ld	a3,96(sp)
    8000704c:	7726                	ld	a4,104(sp)
    8000704e:	77c6                	ld	a5,112(sp)
    80007050:	7866                	ld	a6,120(sp)
    80007052:	688a                	ld	a7,128(sp)
    80007054:	692a                	ld	s2,136(sp)
    80007056:	69ca                	ld	s3,144(sp)
    80007058:	6a6a                	ld	s4,152(sp)
    8000705a:	7a8a                	ld	s5,160(sp)
    8000705c:	7b2a                	ld	s6,168(sp)
    8000705e:	7bca                	ld	s7,176(sp)
    80007060:	7c6a                	ld	s8,184(sp)
    80007062:	6c8e                	ld	s9,192(sp)
    80007064:	6d2e                	ld	s10,200(sp)
    80007066:	6dce                	ld	s11,208(sp)
    80007068:	6e6e                	ld	t3,216(sp)
    8000706a:	7e8e                	ld	t4,224(sp)
    8000706c:	7f2e                	ld	t5,232(sp)
    8000706e:	7fce                	ld	t6,240(sp)
    80007070:	6111                	addi	sp,sp,256
    80007072:	10200073          	sret
    80007076:	00000013          	nop
    8000707a:	00000013          	nop
    8000707e:	0001                	nop

0000000080007080 <timervec>:
    80007080:	34051573          	csrrw	a0,mscratch,a0
    80007084:	e10c                	sd	a1,0(a0)
    80007086:	e510                	sd	a2,8(a0)
    80007088:	e914                	sd	a3,16(a0)
    8000708a:	6d0c                	ld	a1,24(a0)
    8000708c:	7110                	ld	a2,32(a0)
    8000708e:	6194                	ld	a3,0(a1)
    80007090:	96b2                	add	a3,a3,a2
    80007092:	e194                	sd	a3,0(a1)
    80007094:	4589                	li	a1,2
    80007096:	14459073          	csrw	sip,a1
    8000709a:	6914                	ld	a3,16(a0)
    8000709c:	6510                	ld	a2,8(a0)
    8000709e:	610c                	ld	a1,0(a0)
    800070a0:	34051573          	csrrw	a0,mscratch,a0
    800070a4:	30200073          	mret
	...

00000000800070aa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800070aa:	1141                	addi	sp,sp,-16
    800070ac:	e422                	sd	s0,8(sp)
    800070ae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800070b0:	0c0007b7          	lui	a5,0xc000
    800070b4:	4705                	li	a4,1
    800070b6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800070b8:	c3d8                	sw	a4,4(a5)
}
    800070ba:	6422                	ld	s0,8(sp)
    800070bc:	0141                	addi	sp,sp,16
    800070be:	8082                	ret

00000000800070c0 <plicinithart>:

void
plicinithart(void)
{
    800070c0:	1141                	addi	sp,sp,-16
    800070c2:	e406                	sd	ra,8(sp)
    800070c4:	e022                	sd	s0,0(sp)
    800070c6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800070c8:	ffffb097          	auipc	ra,0xffffb
    800070cc:	8e0080e7          	jalr	-1824(ra) # 800019a8 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800070d0:	0085171b          	slliw	a4,a0,0x8
    800070d4:	0c0027b7          	lui	a5,0xc002
    800070d8:	97ba                	add	a5,a5,a4
    800070da:	40200713          	li	a4,1026
    800070de:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800070e2:	00d5151b          	slliw	a0,a0,0xd
    800070e6:	0c2017b7          	lui	a5,0xc201
    800070ea:	953e                	add	a0,a0,a5
    800070ec:	00052023          	sw	zero,0(a0)
}
    800070f0:	60a2                	ld	ra,8(sp)
    800070f2:	6402                	ld	s0,0(sp)
    800070f4:	0141                	addi	sp,sp,16
    800070f6:	8082                	ret

00000000800070f8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800070f8:	1141                	addi	sp,sp,-16
    800070fa:	e406                	sd	ra,8(sp)
    800070fc:	e022                	sd	s0,0(sp)
    800070fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80007100:	ffffb097          	auipc	ra,0xffffb
    80007104:	8a8080e7          	jalr	-1880(ra) # 800019a8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80007108:	00d5179b          	slliw	a5,a0,0xd
    8000710c:	0c201537          	lui	a0,0xc201
    80007110:	953e                	add	a0,a0,a5
  return irq;
}
    80007112:	4148                	lw	a0,4(a0)
    80007114:	60a2                	ld	ra,8(sp)
    80007116:	6402                	ld	s0,0(sp)
    80007118:	0141                	addi	sp,sp,16
    8000711a:	8082                	ret

000000008000711c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000711c:	1101                	addi	sp,sp,-32
    8000711e:	ec06                	sd	ra,24(sp)
    80007120:	e822                	sd	s0,16(sp)
    80007122:	e426                	sd	s1,8(sp)
    80007124:	1000                	addi	s0,sp,32
    80007126:	84aa                	mv	s1,a0
  int hart = cpuid();
    80007128:	ffffb097          	auipc	ra,0xffffb
    8000712c:	880080e7          	jalr	-1920(ra) # 800019a8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80007130:	00d5151b          	slliw	a0,a0,0xd
    80007134:	0c2017b7          	lui	a5,0xc201
    80007138:	97aa                	add	a5,a5,a0
    8000713a:	c3c4                	sw	s1,4(a5)
}
    8000713c:	60e2                	ld	ra,24(sp)
    8000713e:	6442                	ld	s0,16(sp)
    80007140:	64a2                	ld	s1,8(sp)
    80007142:	6105                	addi	sp,sp,32
    80007144:	8082                	ret

0000000080007146 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80007146:	1141                	addi	sp,sp,-16
    80007148:	e406                	sd	ra,8(sp)
    8000714a:	e022                	sd	s0,0(sp)
    8000714c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000714e:	479d                	li	a5,7
    80007150:	06a7c963          	blt	a5,a0,800071c2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80007154:	0001e797          	auipc	a5,0x1e
    80007158:	eac78793          	addi	a5,a5,-340 # 80025000 <disk>
    8000715c:	00a78733          	add	a4,a5,a0
    80007160:	6789                	lui	a5,0x2
    80007162:	97ba                	add	a5,a5,a4
    80007164:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80007168:	e7ad                	bnez	a5,800071d2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000716a:	00451793          	slli	a5,a0,0x4
    8000716e:	00020717          	auipc	a4,0x20
    80007172:	e9270713          	addi	a4,a4,-366 # 80027000 <disk+0x2000>
    80007176:	6314                	ld	a3,0(a4)
    80007178:	96be                	add	a3,a3,a5
    8000717a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000717e:	6314                	ld	a3,0(a4)
    80007180:	96be                	add	a3,a3,a5
    80007182:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80007186:	6314                	ld	a3,0(a4)
    80007188:	96be                	add	a3,a3,a5
    8000718a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000718e:	6318                	ld	a4,0(a4)
    80007190:	97ba                	add	a5,a5,a4
    80007192:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80007196:	0001e797          	auipc	a5,0x1e
    8000719a:	e6a78793          	addi	a5,a5,-406 # 80025000 <disk>
    8000719e:	97aa                	add	a5,a5,a0
    800071a0:	6509                	lui	a0,0x2
    800071a2:	953e                	add	a0,a0,a5
    800071a4:	4785                	li	a5,1
    800071a6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800071aa:	00020517          	auipc	a0,0x20
    800071ae:	e6e50513          	addi	a0,a0,-402 # 80027018 <disk+0x2018>
    800071b2:	ffffc097          	auipc	ra,0xffffc
    800071b6:	9ca080e7          	jalr	-1590(ra) # 80002b7c <wakeup>
}
    800071ba:	60a2                	ld	ra,8(sp)
    800071bc:	6402                	ld	s0,0(sp)
    800071be:	0141                	addi	sp,sp,16
    800071c0:	8082                	ret
    panic("free_desc 1");
    800071c2:	00003517          	auipc	a0,0x3
    800071c6:	88e50513          	addi	a0,a0,-1906 # 80009a50 <syscalls+0x410>
    800071ca:	ffff9097          	auipc	ra,0xffff9
    800071ce:	372080e7          	jalr	882(ra) # 8000053c <panic>
    panic("free_desc 2");
    800071d2:	00003517          	auipc	a0,0x3
    800071d6:	88e50513          	addi	a0,a0,-1906 # 80009a60 <syscalls+0x420>
    800071da:	ffff9097          	auipc	ra,0xffff9
    800071de:	362080e7          	jalr	866(ra) # 8000053c <panic>

00000000800071e2 <virtio_disk_init>:
{
    800071e2:	1101                	addi	sp,sp,-32
    800071e4:	ec06                	sd	ra,24(sp)
    800071e6:	e822                	sd	s0,16(sp)
    800071e8:	e426                	sd	s1,8(sp)
    800071ea:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800071ec:	00003597          	auipc	a1,0x3
    800071f0:	88458593          	addi	a1,a1,-1916 # 80009a70 <syscalls+0x430>
    800071f4:	00020517          	auipc	a0,0x20
    800071f8:	f3450513          	addi	a0,a0,-204 # 80027128 <disk+0x2128>
    800071fc:	ffffa097          	auipc	ra,0xffffa
    80007200:	956080e7          	jalr	-1706(ra) # 80000b52 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80007204:	100017b7          	lui	a5,0x10001
    80007208:	4398                	lw	a4,0(a5)
    8000720a:	2701                	sext.w	a4,a4
    8000720c:	747277b7          	lui	a5,0x74727
    80007210:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80007214:	0ef71163          	bne	a4,a5,800072f6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80007218:	100017b7          	lui	a5,0x10001
    8000721c:	43dc                	lw	a5,4(a5)
    8000721e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80007220:	4705                	li	a4,1
    80007222:	0ce79a63          	bne	a5,a4,800072f6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80007226:	100017b7          	lui	a5,0x10001
    8000722a:	479c                	lw	a5,8(a5)
    8000722c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000722e:	4709                	li	a4,2
    80007230:	0ce79363          	bne	a5,a4,800072f6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80007234:	100017b7          	lui	a5,0x10001
    80007238:	47d8                	lw	a4,12(a5)
    8000723a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000723c:	554d47b7          	lui	a5,0x554d4
    80007240:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80007244:	0af71963          	bne	a4,a5,800072f6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80007248:	100017b7          	lui	a5,0x10001
    8000724c:	4705                	li	a4,1
    8000724e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007250:	470d                	li	a4,3
    80007252:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80007254:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80007256:	c7ffe737          	lui	a4,0xc7ffe
    8000725a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd675f>
    8000725e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80007260:	2701                	sext.w	a4,a4
    80007262:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007264:	472d                	li	a4,11
    80007266:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007268:	473d                	li	a4,15
    8000726a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000726c:	6705                	lui	a4,0x1
    8000726e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80007270:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80007274:	5bdc                	lw	a5,52(a5)
    80007276:	2781                	sext.w	a5,a5
  if(max == 0)
    80007278:	c7d9                	beqz	a5,80007306 <virtio_disk_init+0x124>
  if(max < NUM)
    8000727a:	471d                	li	a4,7
    8000727c:	08f77d63          	bgeu	a4,a5,80007316 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80007280:	100014b7          	lui	s1,0x10001
    80007284:	47a1                	li	a5,8
    80007286:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80007288:	6609                	lui	a2,0x2
    8000728a:	4581                	li	a1,0
    8000728c:	0001e517          	auipc	a0,0x1e
    80007290:	d7450513          	addi	a0,a0,-652 # 80025000 <disk>
    80007294:	ffffa097          	auipc	ra,0xffffa
    80007298:	a4a080e7          	jalr	-1462(ra) # 80000cde <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000729c:	0001e717          	auipc	a4,0x1e
    800072a0:	d6470713          	addi	a4,a4,-668 # 80025000 <disk>
    800072a4:	00c75793          	srli	a5,a4,0xc
    800072a8:	2781                	sext.w	a5,a5
    800072aa:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800072ac:	00020797          	auipc	a5,0x20
    800072b0:	d5478793          	addi	a5,a5,-684 # 80027000 <disk+0x2000>
    800072b4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800072b6:	0001e717          	auipc	a4,0x1e
    800072ba:	dca70713          	addi	a4,a4,-566 # 80025080 <disk+0x80>
    800072be:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800072c0:	0001f717          	auipc	a4,0x1f
    800072c4:	d4070713          	addi	a4,a4,-704 # 80026000 <disk+0x1000>
    800072c8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800072ca:	4705                	li	a4,1
    800072cc:	00e78c23          	sb	a4,24(a5)
    800072d0:	00e78ca3          	sb	a4,25(a5)
    800072d4:	00e78d23          	sb	a4,26(a5)
    800072d8:	00e78da3          	sb	a4,27(a5)
    800072dc:	00e78e23          	sb	a4,28(a5)
    800072e0:	00e78ea3          	sb	a4,29(a5)
    800072e4:	00e78f23          	sb	a4,30(a5)
    800072e8:	00e78fa3          	sb	a4,31(a5)
}
    800072ec:	60e2                	ld	ra,24(sp)
    800072ee:	6442                	ld	s0,16(sp)
    800072f0:	64a2                	ld	s1,8(sp)
    800072f2:	6105                	addi	sp,sp,32
    800072f4:	8082                	ret
    panic("could not find virtio disk");
    800072f6:	00002517          	auipc	a0,0x2
    800072fa:	78a50513          	addi	a0,a0,1930 # 80009a80 <syscalls+0x440>
    800072fe:	ffff9097          	auipc	ra,0xffff9
    80007302:	23e080e7          	jalr	574(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80007306:	00002517          	auipc	a0,0x2
    8000730a:	79a50513          	addi	a0,a0,1946 # 80009aa0 <syscalls+0x460>
    8000730e:	ffff9097          	auipc	ra,0xffff9
    80007312:	22e080e7          	jalr	558(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80007316:	00002517          	auipc	a0,0x2
    8000731a:	7aa50513          	addi	a0,a0,1962 # 80009ac0 <syscalls+0x480>
    8000731e:	ffff9097          	auipc	ra,0xffff9
    80007322:	21e080e7          	jalr	542(ra) # 8000053c <panic>

0000000080007326 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80007326:	7159                	addi	sp,sp,-112
    80007328:	f486                	sd	ra,104(sp)
    8000732a:	f0a2                	sd	s0,96(sp)
    8000732c:	eca6                	sd	s1,88(sp)
    8000732e:	e8ca                	sd	s2,80(sp)
    80007330:	e4ce                	sd	s3,72(sp)
    80007332:	e0d2                	sd	s4,64(sp)
    80007334:	fc56                	sd	s5,56(sp)
    80007336:	f85a                	sd	s6,48(sp)
    80007338:	f45e                	sd	s7,40(sp)
    8000733a:	f062                	sd	s8,32(sp)
    8000733c:	ec66                	sd	s9,24(sp)
    8000733e:	e86a                	sd	s10,16(sp)
    80007340:	1880                	addi	s0,sp,112
    80007342:	892a                	mv	s2,a0
    80007344:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80007346:	00c52c83          	lw	s9,12(a0)
    8000734a:	001c9c9b          	slliw	s9,s9,0x1
    8000734e:	1c82                	slli	s9,s9,0x20
    80007350:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80007354:	00020517          	auipc	a0,0x20
    80007358:	dd450513          	addi	a0,a0,-556 # 80027128 <disk+0x2128>
    8000735c:	ffffa097          	auipc	ra,0xffffa
    80007360:	886080e7          	jalr	-1914(ra) # 80000be2 <acquire>
  for(int i = 0; i < 3; i++){
    80007364:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80007366:	4c21                	li	s8,8
      disk.free[i] = 0;
    80007368:	0001eb97          	auipc	s7,0x1e
    8000736c:	c98b8b93          	addi	s7,s7,-872 # 80025000 <disk>
    80007370:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80007372:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80007374:	8a4e                	mv	s4,s3
    80007376:	a051                	j	800073fa <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80007378:	00fb86b3          	add	a3,s7,a5
    8000737c:	96da                	add	a3,a3,s6
    8000737e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80007382:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80007384:	0207c563          	bltz	a5,800073ae <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007388:	2485                	addiw	s1,s1,1
    8000738a:	0711                	addi	a4,a4,4
    8000738c:	25548063          	beq	s1,s5,800075cc <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80007390:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80007392:	00020697          	auipc	a3,0x20
    80007396:	c8668693          	addi	a3,a3,-890 # 80027018 <disk+0x2018>
    8000739a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000739c:	0006c583          	lbu	a1,0(a3)
    800073a0:	fde1                	bnez	a1,80007378 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    800073a2:	2785                	addiw	a5,a5,1
    800073a4:	0685                	addi	a3,a3,1
    800073a6:	ff879be3          	bne	a5,s8,8000739c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800073aa:	57fd                	li	a5,-1
    800073ac:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800073ae:	02905a63          	blez	s1,800073e2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800073b2:	f9042503          	lw	a0,-112(s0)
    800073b6:	00000097          	auipc	ra,0x0
    800073ba:	d90080e7          	jalr	-624(ra) # 80007146 <free_desc>
      for(int j = 0; j < i; j++)
    800073be:	4785                	li	a5,1
    800073c0:	0297d163          	bge	a5,s1,800073e2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800073c4:	f9442503          	lw	a0,-108(s0)
    800073c8:	00000097          	auipc	ra,0x0
    800073cc:	d7e080e7          	jalr	-642(ra) # 80007146 <free_desc>
      for(int j = 0; j < i; j++)
    800073d0:	4789                	li	a5,2
    800073d2:	0097d863          	bge	a5,s1,800073e2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800073d6:	f9842503          	lw	a0,-104(s0)
    800073da:	00000097          	auipc	ra,0x0
    800073de:	d6c080e7          	jalr	-660(ra) # 80007146 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800073e2:	00020597          	auipc	a1,0x20
    800073e6:	d4658593          	addi	a1,a1,-698 # 80027128 <disk+0x2128>
    800073ea:	00020517          	auipc	a0,0x20
    800073ee:	c2e50513          	addi	a0,a0,-978 # 80027018 <disk+0x2018>
    800073f2:	ffffb097          	auipc	ra,0xffffb
    800073f6:	384080e7          	jalr	900(ra) # 80002776 <sleep>
  for(int i = 0; i < 3; i++){
    800073fa:	f9040713          	addi	a4,s0,-112
    800073fe:	84ce                	mv	s1,s3
    80007400:	bf41                	j	80007390 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80007402:	20058713          	addi	a4,a1,512
    80007406:	00471693          	slli	a3,a4,0x4
    8000740a:	0001e717          	auipc	a4,0x1e
    8000740e:	bf670713          	addi	a4,a4,-1034 # 80025000 <disk>
    80007412:	9736                	add	a4,a4,a3
    80007414:	4685                	li	a3,1
    80007416:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000741a:	20058713          	addi	a4,a1,512
    8000741e:	00471693          	slli	a3,a4,0x4
    80007422:	0001e717          	auipc	a4,0x1e
    80007426:	bde70713          	addi	a4,a4,-1058 # 80025000 <disk>
    8000742a:	9736                	add	a4,a4,a3
    8000742c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007430:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80007434:	7679                	lui	a2,0xffffe
    80007436:	963e                	add	a2,a2,a5
    80007438:	00020697          	auipc	a3,0x20
    8000743c:	bc868693          	addi	a3,a3,-1080 # 80027000 <disk+0x2000>
    80007440:	6298                	ld	a4,0(a3)
    80007442:	9732                	add	a4,a4,a2
    80007444:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007446:	6298                	ld	a4,0(a3)
    80007448:	9732                	add	a4,a4,a2
    8000744a:	4541                	li	a0,16
    8000744c:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000744e:	6298                	ld	a4,0(a3)
    80007450:	9732                	add	a4,a4,a2
    80007452:	4505                	li	a0,1
    80007454:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007458:	f9442703          	lw	a4,-108(s0)
    8000745c:	6288                	ld	a0,0(a3)
    8000745e:	962a                	add	a2,a2,a0
    80007460:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd600e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80007464:	0712                	slli	a4,a4,0x4
    80007466:	6290                	ld	a2,0(a3)
    80007468:	963a                	add	a2,a2,a4
    8000746a:	05890513          	addi	a0,s2,88
    8000746e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80007470:	6294                	ld	a3,0(a3)
    80007472:	96ba                	add	a3,a3,a4
    80007474:	40000613          	li	a2,1024
    80007478:	c690                	sw	a2,8(a3)
  if(write)
    8000747a:	140d0063          	beqz	s10,800075ba <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000747e:	00020697          	auipc	a3,0x20
    80007482:	b826b683          	ld	a3,-1150(a3) # 80027000 <disk+0x2000>
    80007486:	96ba                	add	a3,a3,a4
    80007488:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000748c:	0001e817          	auipc	a6,0x1e
    80007490:	b7480813          	addi	a6,a6,-1164 # 80025000 <disk>
    80007494:	00020517          	auipc	a0,0x20
    80007498:	b6c50513          	addi	a0,a0,-1172 # 80027000 <disk+0x2000>
    8000749c:	6114                	ld	a3,0(a0)
    8000749e:	96ba                	add	a3,a3,a4
    800074a0:	00c6d603          	lhu	a2,12(a3)
    800074a4:	00166613          	ori	a2,a2,1
    800074a8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800074ac:	f9842683          	lw	a3,-104(s0)
    800074b0:	6110                	ld	a2,0(a0)
    800074b2:	9732                	add	a4,a4,a2
    800074b4:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800074b8:	20058613          	addi	a2,a1,512
    800074bc:	0612                	slli	a2,a2,0x4
    800074be:	9642                	add	a2,a2,a6
    800074c0:	577d                	li	a4,-1
    800074c2:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800074c6:	00469713          	slli	a4,a3,0x4
    800074ca:	6114                	ld	a3,0(a0)
    800074cc:	96ba                	add	a3,a3,a4
    800074ce:	03078793          	addi	a5,a5,48
    800074d2:	97c2                	add	a5,a5,a6
    800074d4:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    800074d6:	611c                	ld	a5,0(a0)
    800074d8:	97ba                	add	a5,a5,a4
    800074da:	4685                	li	a3,1
    800074dc:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800074de:	611c                	ld	a5,0(a0)
    800074e0:	97ba                	add	a5,a5,a4
    800074e2:	4809                	li	a6,2
    800074e4:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800074e8:	611c                	ld	a5,0(a0)
    800074ea:	973e                	add	a4,a4,a5
    800074ec:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800074f0:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    800074f4:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800074f8:	6518                	ld	a4,8(a0)
    800074fa:	00275783          	lhu	a5,2(a4)
    800074fe:	8b9d                	andi	a5,a5,7
    80007500:	0786                	slli	a5,a5,0x1
    80007502:	97ba                	add	a5,a5,a4
    80007504:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80007508:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000750c:	6518                	ld	a4,8(a0)
    8000750e:	00275783          	lhu	a5,2(a4)
    80007512:	2785                	addiw	a5,a5,1
    80007514:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007518:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000751c:	100017b7          	lui	a5,0x10001
    80007520:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007524:	00492703          	lw	a4,4(s2)
    80007528:	4785                	li	a5,1
    8000752a:	02f71163          	bne	a4,a5,8000754c <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000752e:	00020997          	auipc	s3,0x20
    80007532:	bfa98993          	addi	s3,s3,-1030 # 80027128 <disk+0x2128>
  while(b->disk == 1) {
    80007536:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80007538:	85ce                	mv	a1,s3
    8000753a:	854a                	mv	a0,s2
    8000753c:	ffffb097          	auipc	ra,0xffffb
    80007540:	23a080e7          	jalr	570(ra) # 80002776 <sleep>
  while(b->disk == 1) {
    80007544:	00492783          	lw	a5,4(s2)
    80007548:	fe9788e3          	beq	a5,s1,80007538 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    8000754c:	f9042903          	lw	s2,-112(s0)
    80007550:	20090793          	addi	a5,s2,512
    80007554:	00479713          	slli	a4,a5,0x4
    80007558:	0001e797          	auipc	a5,0x1e
    8000755c:	aa878793          	addi	a5,a5,-1368 # 80025000 <disk>
    80007560:	97ba                	add	a5,a5,a4
    80007562:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007566:	00020997          	auipc	s3,0x20
    8000756a:	a9a98993          	addi	s3,s3,-1382 # 80027000 <disk+0x2000>
    8000756e:	00491713          	slli	a4,s2,0x4
    80007572:	0009b783          	ld	a5,0(s3)
    80007576:	97ba                	add	a5,a5,a4
    80007578:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000757c:	854a                	mv	a0,s2
    8000757e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80007582:	00000097          	auipc	ra,0x0
    80007586:	bc4080e7          	jalr	-1084(ra) # 80007146 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000758a:	8885                	andi	s1,s1,1
    8000758c:	f0ed                	bnez	s1,8000756e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000758e:	00020517          	auipc	a0,0x20
    80007592:	b9a50513          	addi	a0,a0,-1126 # 80027128 <disk+0x2128>
    80007596:	ffff9097          	auipc	ra,0xffff9
    8000759a:	700080e7          	jalr	1792(ra) # 80000c96 <release>
}
    8000759e:	70a6                	ld	ra,104(sp)
    800075a0:	7406                	ld	s0,96(sp)
    800075a2:	64e6                	ld	s1,88(sp)
    800075a4:	6946                	ld	s2,80(sp)
    800075a6:	69a6                	ld	s3,72(sp)
    800075a8:	6a06                	ld	s4,64(sp)
    800075aa:	7ae2                	ld	s5,56(sp)
    800075ac:	7b42                	ld	s6,48(sp)
    800075ae:	7ba2                	ld	s7,40(sp)
    800075b0:	7c02                	ld	s8,32(sp)
    800075b2:	6ce2                	ld	s9,24(sp)
    800075b4:	6d42                	ld	s10,16(sp)
    800075b6:	6165                	addi	sp,sp,112
    800075b8:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800075ba:	00020697          	auipc	a3,0x20
    800075be:	a466b683          	ld	a3,-1466(a3) # 80027000 <disk+0x2000>
    800075c2:	96ba                	add	a3,a3,a4
    800075c4:	4609                	li	a2,2
    800075c6:	00c69623          	sh	a2,12(a3)
    800075ca:	b5c9                	j	8000748c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800075cc:	f9042583          	lw	a1,-112(s0)
    800075d0:	20058793          	addi	a5,a1,512
    800075d4:	0792                	slli	a5,a5,0x4
    800075d6:	0001e517          	auipc	a0,0x1e
    800075da:	ad250513          	addi	a0,a0,-1326 # 800250a8 <disk+0xa8>
    800075de:	953e                	add	a0,a0,a5
  if(write)
    800075e0:	e20d11e3          	bnez	s10,80007402 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800075e4:	20058713          	addi	a4,a1,512
    800075e8:	00471693          	slli	a3,a4,0x4
    800075ec:	0001e717          	auipc	a4,0x1e
    800075f0:	a1470713          	addi	a4,a4,-1516 # 80025000 <disk>
    800075f4:	9736                	add	a4,a4,a3
    800075f6:	0a072423          	sw	zero,168(a4)
    800075fa:	b505                	j	8000741a <virtio_disk_rw+0xf4>

00000000800075fc <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800075fc:	1101                	addi	sp,sp,-32
    800075fe:	ec06                	sd	ra,24(sp)
    80007600:	e822                	sd	s0,16(sp)
    80007602:	e426                	sd	s1,8(sp)
    80007604:	e04a                	sd	s2,0(sp)
    80007606:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80007608:	00020517          	auipc	a0,0x20
    8000760c:	b2050513          	addi	a0,a0,-1248 # 80027128 <disk+0x2128>
    80007610:	ffff9097          	auipc	ra,0xffff9
    80007614:	5d2080e7          	jalr	1490(ra) # 80000be2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80007618:	10001737          	lui	a4,0x10001
    8000761c:	533c                	lw	a5,96(a4)
    8000761e:	8b8d                	andi	a5,a5,3
    80007620:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007622:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007626:	00020797          	auipc	a5,0x20
    8000762a:	9da78793          	addi	a5,a5,-1574 # 80027000 <disk+0x2000>
    8000762e:	6b94                	ld	a3,16(a5)
    80007630:	0207d703          	lhu	a4,32(a5)
    80007634:	0026d783          	lhu	a5,2(a3)
    80007638:	06f70163          	beq	a4,a5,8000769a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000763c:	0001e917          	auipc	s2,0x1e
    80007640:	9c490913          	addi	s2,s2,-1596 # 80025000 <disk>
    80007644:	00020497          	auipc	s1,0x20
    80007648:	9bc48493          	addi	s1,s1,-1604 # 80027000 <disk+0x2000>
    __sync_synchronize();
    8000764c:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007650:	6898                	ld	a4,16(s1)
    80007652:	0204d783          	lhu	a5,32(s1)
    80007656:	8b9d                	andi	a5,a5,7
    80007658:	078e                	slli	a5,a5,0x3
    8000765a:	97ba                	add	a5,a5,a4
    8000765c:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000765e:	20078713          	addi	a4,a5,512
    80007662:	0712                	slli	a4,a4,0x4
    80007664:	974a                	add	a4,a4,s2
    80007666:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000766a:	e731                	bnez	a4,800076b6 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000766c:	20078793          	addi	a5,a5,512
    80007670:	0792                	slli	a5,a5,0x4
    80007672:	97ca                	add	a5,a5,s2
    80007674:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007676:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000767a:	ffffb097          	auipc	ra,0xffffb
    8000767e:	502080e7          	jalr	1282(ra) # 80002b7c <wakeup>

    disk.used_idx += 1;
    80007682:	0204d783          	lhu	a5,32(s1)
    80007686:	2785                	addiw	a5,a5,1
    80007688:	17c2                	slli	a5,a5,0x30
    8000768a:	93c1                	srli	a5,a5,0x30
    8000768c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007690:	6898                	ld	a4,16(s1)
    80007692:	00275703          	lhu	a4,2(a4)
    80007696:	faf71be3          	bne	a4,a5,8000764c <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000769a:	00020517          	auipc	a0,0x20
    8000769e:	a8e50513          	addi	a0,a0,-1394 # 80027128 <disk+0x2128>
    800076a2:	ffff9097          	auipc	ra,0xffff9
    800076a6:	5f4080e7          	jalr	1524(ra) # 80000c96 <release>
}
    800076aa:	60e2                	ld	ra,24(sp)
    800076ac:	6442                	ld	s0,16(sp)
    800076ae:	64a2                	ld	s1,8(sp)
    800076b0:	6902                	ld	s2,0(sp)
    800076b2:	6105                	addi	sp,sp,32
    800076b4:	8082                	ret
      panic("virtio_disk_intr status");
    800076b6:	00002517          	auipc	a0,0x2
    800076ba:	42a50513          	addi	a0,a0,1066 # 80009ae0 <syscalls+0x4a0>
    800076be:	ffff9097          	auipc	ra,0xffff9
    800076c2:	e7e080e7          	jalr	-386(ra) # 8000053c <panic>

00000000800076c6 <cond_wait>:
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"
#include "condvar.h"

void cond_wait (struct cond_t *cv, struct sleeplock *lock){
    800076c6:	1141                	addi	sp,sp,-16
    800076c8:	e406                	sd	ra,8(sp)
    800076ca:	e022                	sd	s0,0(sp)
    800076cc:	0800                	addi	s0,sp,16
    condsleep(cv, lock);
    800076ce:	ffffc097          	auipc	ra,0xffffc
    800076d2:	f26080e7          	jalr	-218(ra) # 800035f4 <condsleep>
};
    800076d6:	60a2                	ld	ra,8(sp)
    800076d8:	6402                	ld	s0,0(sp)
    800076da:	0141                	addi	sp,sp,16
    800076dc:	8082                	ret

00000000800076de <cond_signal>:
void cond_signal (struct cond_t *cv){
    800076de:	1141                	addi	sp,sp,-16
    800076e0:	e406                	sd	ra,8(sp)
    800076e2:	e022                	sd	s0,0(sp)
    800076e4:	0800                	addi	s0,sp,16
    wakeupone(cv);
    800076e6:	ffffc097          	auipc	ra,0xffffc
    800076ea:	f72080e7          	jalr	-142(ra) # 80003658 <wakeupone>
};
    800076ee:	60a2                	ld	ra,8(sp)
    800076f0:	6402                	ld	s0,0(sp)
    800076f2:	0141                	addi	sp,sp,16
    800076f4:	8082                	ret

00000000800076f6 <cond_broadcast>:
void cond_broadcast (struct cond_t *cv){
    800076f6:	1101                	addi	sp,sp,-32
    800076f8:	ec06                	sd	ra,24(sp)
    800076fa:	e822                	sd	s0,16(sp)
    800076fc:	e426                	sd	s1,8(sp)
    800076fe:	1000                	addi	s0,sp,32
    80007700:	84aa                	mv	s1,a0
    for(int i=0; i<4; i++)wakeupone(cv);
    80007702:	ffffc097          	auipc	ra,0xffffc
    80007706:	f56080e7          	jalr	-170(ra) # 80003658 <wakeupone>
    8000770a:	8526                	mv	a0,s1
    8000770c:	ffffc097          	auipc	ra,0xffffc
    80007710:	f4c080e7          	jalr	-180(ra) # 80003658 <wakeupone>
    80007714:	8526                	mv	a0,s1
    80007716:	ffffc097          	auipc	ra,0xffffc
    8000771a:	f42080e7          	jalr	-190(ra) # 80003658 <wakeupone>
    8000771e:	8526                	mv	a0,s1
    80007720:	ffffc097          	auipc	ra,0xffffc
    80007724:	f38080e7          	jalr	-200(ra) # 80003658 <wakeupone>
    80007728:	60e2                	ld	ra,24(sp)
    8000772a:	6442                	ld	s0,16(sp)
    8000772c:	64a2                	ld	s1,8(sp)
    8000772e:	6105                	addi	sp,sp,32
    80007730:	8082                	ret
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
