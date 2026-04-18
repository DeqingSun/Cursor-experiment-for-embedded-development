
/Users/deqinguser/Documents/GitHub/Cursor-experiment-for-embedded-development/exp4_ch572_bootloader_reverse_engineer/bootloader.bin:     file format binary


Disassembly of section .data:

0003c000 <.data>:
   3c000:	0040006f          	jal	zero,0x3c004
   3c004:	20002197          	auipc	gp,0x20002
   3c008:	39418193          	addi	gp,gp,916 # 0x2003e398
   3c00c:	20002117          	auipc	sp,0x20002
   3c010:	7f410113          	addi	sp,sp,2036 # 0x2003e800
   3c014:	00000517          	auipc	a0,0x0
   3c018:	0ac50513          	addi	a0,a0,172 # 0x3c0c0
   3c01c:	20000597          	auipc	a1,0x20000
   3c020:	fe458593          	addi	a1,a1,-28 # 0x2003c000
   3c024:	20000617          	auipc	a2,0x20000
   3c028:	0d460613          	addi	a2,a2,212 # 0x2003c0f8
   3c02c:	00c5fa63          	bgeu	a1,a2,0x3c040
   3c030:	00052283          	lw	t0,0(a0)
   3c034:	0055a023          	sw	t0,0(a1)
   3c038:	0511                	c.addi	a0,4
   3c03a:	0591                	c.addi	a1,4
   3c03c:	fec5eae3          	bltu	a1,a2,0x3c030
   3c040:	00002517          	auipc	a0,0x2
   3c044:	be450513          	addi	a0,a0,-1052 # 0x3dc24
   3c048:	20002597          	auipc	a1,0x20002
   3c04c:	b1c58593          	addi	a1,a1,-1252 # 0x2003db64
   3c050:	20002617          	auipc	a2,0x20002
   3c054:	b5060613          	addi	a2,a2,-1200 # 0x2003dba0
   3c058:	00c5fa63          	bgeu	a1,a2,0x3c06c
   3c05c:	00052283          	lw	t0,0(a0)
   3c060:	0055a023          	sw	t0,0(a1)
   3c064:	0511                	c.addi	a0,4
   3c066:	0591                	c.addi	a1,4
   3c068:	fec5eae3          	bltu	a1,a2,0x3c05c
   3c06c:	20002517          	auipc	a0,0x20002
   3c070:	b3450513          	addi	a0,a0,-1228 # 0x2003dba0
   3c074:	20002597          	auipc	a1,0x20002
   3c078:	fa058593          	addi	a1,a1,-96 # 0x2003e014
   3c07c:	00b57763          	bgeu	a0,a1,0x3c08a
   3c080:	00052023          	sw	zero,0(a0)
   3c084:	0511                	c.addi	a0,4
   3c086:	feb56de3          	bltu	a0,a1,0x3c080
   3c08a:	42fd                	c.li	t0,31
   3c08c:	bc029073          	csrrw	zero,0xbc0,t0
   3c090:	428d                	c.li	t0,3
   3c092:	80429073          	csrrw	zero,0x804,t0
   3c096:	08800293          	addi	t0,zero,136
   3c09a:	3002a073          	csrrs	zero,mstatus,t0
   3c09e:	20000297          	auipc	t0,0x20000
   3c0a2:	05a28293          	addi	t0,t0,90 # 0x2003c0f8
   3c0a6:	0032e293          	ori	t0,t0,3
   3c0aa:	30529073          	csrrw	zero,mtvec,t0
   3c0ae:	20000297          	auipc	t0,0x20000
   3c0b2:	fd228293          	addi	t0,t0,-46 # 0x2003c080
   3c0b6:	34129073          	csrrw	zero,mepc,t0
   3c0ba:	30200073          	mret
   3c0be:	0000                	c.unimp
   3c0c0:	00b67363          	bgeu	a2,a1,0x3c0c6
   3c0c4:	8082                	c.jr	ra
   3c0c6:	411c                	c.lw	a5,0(a0)
   3c0c8:	0591                	c.addi	a1,4
   3c0ca:	0511                	c.addi	a0,4
   3c0cc:	fef5ae23          	sw	a5,-4(a1)
   3c0d0:	bfc5                	c.j	0x3c0c0
   3c0d2:	200027b7          	lui	a5,0x20002
   3c0d6:	20002737          	lui	a4,0x20002
   3c0da:	ba078793          	addi	a5,a5,-1120 # 0x20001ba0
   3c0de:	01470713          	addi	a4,a4,20 # 0x20002014
   3c0e2:	00f77363          	bgeu	a4,a5,0x3c0e8
   3c0e6:	8082                	c.jr	ra
   3c0e8:	0007a023          	sw	zero,0(a5)
   3c0ec:	0791                	c.addi	a5,4
   3c0ee:	bfd5                	c.j	0x3c0e2
   3c0f0:	20002637          	lui	a2,0x20002
   3c0f4:	200005b7          	lui	a1,0x20000
   3c0f8:	00000537          	lui	a0,0x0
   3c0fc:	1141                	c.addi	sp,-16
   3c0fe:	b6460613          	addi	a2,a2,-1180 # 0x20001b64
   3c102:	0f858593          	addi	a1,a1,248 # 0x200000f8
   3c106:	1b850513          	addi	a0,a0,440 # 0x1b8
   3c10a:	c606                	c.swsp	ra,12(sp)
   3c10c:	00000097          	auipc	ra,0x0
   3c110:	fb4080e7          	jalr	ra,-76(ra) # 0x3c0c0
   3c114:	20002637          	lui	a2,0x20002
   3c118:	200025b7          	lui	a1,0x20002
   3c11c:	00002537          	lui	a0,0x2
   3c120:	ba060613          	addi	a2,a2,-1120 # 0x20001ba0
   3c124:	b6458593          	addi	a1,a1,-1180 # 0x20001b64
   3c128:	c2450513          	addi	a0,a0,-988 # 0x1c24
   3c12c:	00000097          	auipc	ra,0x0
   3c130:	f94080e7          	jalr	ra,-108(ra) # 0x3c0c0
   3c134:	40b2                	c.lwsp	ra,12(sp)
   3c136:	0141                	c.addi	sp,16
   3c138:	00000317          	auipc	t1,0x0
   3c13c:	f9a30067          	jalr	zero,-102(t1) # 0x3c0d2
   3c140:	1141                	c.addi	sp,-16
   3c142:	c606                	c.swsp	ra,12(sp)
   3c144:	400017b7          	lui	a5,0x40001
   3c148:	00a7c703          	lbu	a4,10(a5) # 0x4000100a
   3c14c:	8b41                	c.andi	a4,16
   3c14e:	e705                	c.bnez	a4,0x3c176
   3c150:	05700713          	addi	a4,zero,87
   3c154:	04e78023          	sb	a4,64(a5)
   3c158:	fa800713          	addi	a4,zero,-88
   3c15c:	04e78023          	sb	a4,64(a5)
   3c160:	00a7c703          	lbu	a4,10(a5)
   3c164:	01076713          	ori	a4,a4,16
   3c168:	00e78523          	sb	a4,10(a5)
   3c16c:	1e000793          	addi	a5,zero,480
   3c170:	0001                	c.addi	zero,0
   3c172:	17fd                	c.addi	a5,-1
   3c174:	fff5                	c.bnez	a5,0x3c170
   3c176:	400017b7          	lui	a5,0x40001
   3c17a:	05700713          	addi	a4,zero,87
   3c17e:	04e78023          	sb	a4,64(a5) # 0x40001040
   3c182:	fa800713          	addi	a4,zero,-88
   3c186:	04e78023          	sb	a4,64(a5)
   3c18a:	05900713          	addi	a4,zero,89
   3c18e:	00e79423          	sh	a4,8(a5)
   3c192:	46c1                	c.li	a3,16
   3c194:	40002737          	lui	a4,0x40002
   3c198:	80d702a3          	sb	a3,-2043(a4) # 0x40001805
   3c19c:	469d                	c.li	a3,7
   3c19e:	80d703a3          	sb	a3,-2041(a4)
   3c1a2:	04078023          	sb	zero,64(a5)
   3c1a6:	00000097          	auipc	ra,0x0
   3c1aa:	f4a080e7          	jalr	ra,-182(ra) # 0x3c0f0
   3c1ae:	00001097          	auipc	ra,0x1
   3c1b2:	0a8080e7          	jalr	ra,168(ra) # 0x3d256
	...
   3c1be:	0000                	c.unimp
   3c1c0:	400017b7          	lui	a5,0x40001
   3c1c4:	0a47a503          	lw	a0,164(a5) # 0x400010a4
   3c1c8:	890d                	c.andi	a0,3
   3c1ca:	1579                	c.addi	a0,-2
   3c1cc:	00153513          	sltiu	a0,a0,1
   3c1d0:	8082                	c.jr	ra
   3c1d2:	400037b7          	lui	a5,0x40003
   3c1d6:	40a78423          	sb	a0,1032(a5) # 0x40003408
   3c1da:	40003737          	lui	a4,0x40003
   3c1de:	40574783          	lbu	a5,1029(a4) # 0x40003405
   3c1e2:	0407f793          	andi	a5,a5,64
   3c1e6:	dfe5                	c.beqz	a5,0x3c1de
   3c1e8:	8082                	c.jr	ra
   3c1ea:	40003737          	lui	a4,0x40003
   3c1ee:	40574783          	lbu	a5,1029(a4) # 0x40003405
   3c1f2:	8b85                	c.andi	a5,1
   3c1f4:	dfed                	c.beqz	a5,0x3c1ee
   3c1f6:	40874503          	lbu	a0,1032(a4)
   3c1fa:	8082                	c.jr	ra
   3c1fc:	4781                	c.li	a5,0
   3c1fe:	00c79363          	bne	a5,a2,0x3c204
   3c202:	8082                	c.jr	ra
   3c204:	00f58733          	add	a4,a1,a5
   3c208:	00074683          	lbu	a3,0(a4)
   3c20c:	00f50733          	add	a4,a0,a5
   3c210:	0785                	c.addi	a5,1
   3c212:	00d70023          	sb	a3,0(a4)
   3c216:	b7e5                	c.j	0x3c1fe
   3c218:	1101                	c.addi	sp,-32
   3c21a:	c64e                	c.swsp	s3,12(sp)
   3c21c:	200029b7          	lui	s3,0x20002
   3c220:	bdc9a783          	lw	a5,-1060(s3) # 0x20001bdc
   3c224:	cc22                	c.swsp	s0,24(sp)
   3c226:	c84a                	c.swsp	s2,16(sp)
   3c228:	c452                	c.swsp	s4,8(sp)
   3c22a:	ce06                	c.swsp	ra,28(sp)
   3c22c:	20002a37          	lui	s4,0x20002
   3c230:	ca26                	c.swsp	s1,20(sp)
   3c232:	c256                	c.swsp	s5,4(sp)
   3c234:	c05a                	c.swsp	s6,0(sp)
   3c236:	20002937          	lui	s2,0x20002
   3c23a:	000782a3          	sb	zero,5(a5)
   3c23e:	baca2683          	lw	a3,-1108(s4) # 0x20001bac
   3c242:	4799                	c.li	a5,6
   3c244:	bcf903a3          	sb	a5,-1081(s2) # 0x20001bc7
   3c248:	200027b7          	lui	a5,0x20002
   3c24c:	20002437          	lui	s0,0x20002
   3c250:	be078123          	sb	zero,-1054(a5) # 0x20001be2
   3c254:	bdc98993          	addi	s3,s3,-1060
   3c258:	bc790913          	addi	s2,s2,-1081
   3c25c:	baca0a13          	addi	s4,s4,-1108
   3c260:	f1040413          	addi	s0,s0,-240 # 0x20001f10
   3c264:	c2d5                	c.beqz	a3,0x3c308
   3c266:	00044703          	lbu	a4,0(s0)
   3c26a:	0a500793          	addi	a5,zero,165
   3c26e:	08f70d63          	beq	a4,a5,0x3c308
   3c272:	200027b7          	lui	a5,0x20002
   3c276:	ba87a583          	lw	a1,-1112(a5) # 0x20001ba8
   3c27a:	0003c7b7          	lui	a5,0x3c
   3c27e:	0fe00493          	addi	s1,zero,254
   3c282:	00b68733          	add	a4,a3,a1
   3c286:	02f77063          	bgeu	a4,a5,0x3c2a6
   3c28a:	20002637          	lui	a2,0x20002
   3c28e:	bf060613          	addi	a2,a2,-1040 # 0x20001bf0
   3c292:	4509                	c.li	a0,2
   3c294:	00001097          	auipc	ra,0x1
   3c298:	564080e7          	jalr	ra,1380(ra) # 0x3d7f8
   3c29c:	0ff57493          	andi	s1,a0,255
   3c2a0:	e48d                	c.bnez	s1,0x3c2ca
   3c2a2:	000a2023          	sw	zero,0(s4)
   3c2a6:	00044783          	lbu	a5,0(s0)
   3c2aa:	0a500713          	addi	a4,zero,165
   3c2ae:	26e78863          	beq	a5,a4,0x3c51e
   3c2b2:	14f76f63          	bltu	a4,a5,0x3c410
   3c2b6:	0a200713          	addi	a4,zero,162
   3c2ba:	06e78be3          	beq	a5,a4,0x3cb30
   3c2be:	04f76863          	bltu	a4,a5,0x3c30e
   3c2c2:	0a100713          	addi	a4,zero,161
   3c2c6:	18e78b63          	beq	a5,a4,0x3c45c
   3c2ca:	0009a783          	lw	a5,0(s3)
   3c2ce:	00044703          	lbu	a4,0(s0)
   3c2d2:	00e78023          	sb	a4,0(a5) # 0x3c000
   3c2d6:	00094783          	lbu	a5,0(s2)
   3c2da:	0009a703          	lw	a4,0(s3)
   3c2de:	17f1                	c.addi	a5,-4
   3c2e0:	00f70123          	sb	a5,2(a4)
   3c2e4:	0009a783          	lw	a5,0(s3)
   3c2e8:	000781a3          	sb	zero,3(a5)
   3c2ec:	0009a783          	lw	a5,0(s3)
   3c2f0:	00978223          	sb	s1,4(a5)
   3c2f4:	40f2                	c.lwsp	ra,28(sp)
   3c2f6:	4462                	c.lwsp	s0,24(sp)
   3c2f8:	44d2                	c.lwsp	s1,20(sp)
   3c2fa:	4942                	c.lwsp	s2,16(sp)
   3c2fc:	49b2                	c.lwsp	s3,12(sp)
   3c2fe:	4a22                	c.lwsp	s4,8(sp)
   3c300:	4a92                	c.lwsp	s5,4(sp)
   3c302:	4b02                	c.lwsp	s6,0(sp)
   3c304:	6105                	c.addi16sp	sp,32
   3c306:	8082                	c.jr	ra
   3c308:	0fe00493          	addi	s1,zero,254
   3c30c:	bf69                	c.j	0x3c2a6
   3c30e:	0a300713          	addi	a4,zero,163
   3c312:	3ae78463          	beq	a5,a4,0x3c6ba
   3c316:	0a400713          	addi	a4,zero,164
   3c31a:	fae798e3          	bne	a5,a4,0x3c2ca
   3c31e:	00144703          	lbu	a4,1(s0)
   3c322:	4791                	c.li	a5,4
   3c324:	00344483          	lbu	s1,3(s0)
   3c328:	00f71e63          	bne	a4,a5,0x3c344
   3c32c:	00444783          	lbu	a5,4(s0)
   3c330:	00544703          	lbu	a4,5(s0)
   3c334:	07a2                	c.slli	a5,0x8
   3c336:	0742                	c.slli	a4,0x10
   3c338:	97ba                	c.add	a5,a4
   3c33a:	94be                	c.add	s1,a5
   3c33c:	00644783          	lbu	a5,6(s0)
   3c340:	07e2                	c.slli	a5,0x18
   3c342:	94be                	c.add	s1,a5
   3c344:	47a1                	c.li	a5,8
   3c346:	00f4f363          	bgeu	s1,a5,0x3c34c
   3c34a:	44a1                	c.li	s1,8
   3c34c:	20002637          	lui	a2,0x20002
   3c350:	ba060a93          	addi	s5,a2,-1120 # 0x20001ba0
   3c354:	4691                	c.li	a3,4
   3c356:	ba060613          	addi	a2,a2,-1120
   3c35a:	45d1                	c.li	a1,20
   3c35c:	4531                	c.li	a0,12
   3c35e:	00001097          	auipc	ra,0x1
   3c362:	49a080e7          	jalr	ra,1178(ra) # 0x3d7f8
   3c366:	000aa783          	lw	a5,0(s5)
   3c36a:	048d                	c.addi	s1,3
   3c36c:	8089                	c.srli	s1,0x2
   3c36e:	0187d713          	srli	a4,a5,0x18
   3c372:	8f3d                	c.xor	a4,a5
   3c374:	fff74713          	xori	a4,a4,-1
   3c378:	0ff77713          	andi	a4,a4,255
   3c37c:	ef11                	c.bnez	a4,0x3c398
   3c37e:	00f00737          	lui	a4,0xf00
   3c382:	8f7d                	c.and	a4,a5
   3c384:	005006b7          	lui	a3,0x500
   3c388:	00d71863          	bne	a4,a3,0x3c398
   3c38c:	83a9                	c.srli	a5,0xa
   3c38e:	3ff7f793          	andi	a5,a5,1023
   3c392:	00f4f363          	bgeu	s1,a5,0x3c398
   3c396:	84be                	c.mv	s1,a5
   3c398:	200027b7          	lui	a5,0x20002
   3c39c:	bc57c783          	lbu	a5,-1083(a5) # 0x20001bc5
   3c3a0:	eb95                	c.bnez	a5,0x3c3d4
   3c3a2:	200027b7          	lui	a5,0x20002
   3c3a6:	be87a783          	lw	a5,-1048(a5) # 0x20001be8
   3c3aa:	0187d713          	srli	a4,a5,0x18
   3c3ae:	8f3d                	c.xor	a4,a5
   3c3b0:	fff74713          	xori	a4,a4,-1
   3c3b4:	0ff77713          	andi	a4,a4,255
   3c3b8:	ef11                	c.bnez	a4,0x3c3d4
   3c3ba:	00f00737          	lui	a4,0xf00
   3c3be:	8f7d                	c.and	a4,a5
   3c3c0:	005006b7          	lui	a3,0x500
   3c3c4:	00d71863          	bne	a4,a3,0x3c3d4
   3c3c8:	83a9                	c.srli	a5,0xa
   3c3ca:	3ff7f793          	andi	a5,a5,1023
   3c3ce:	00f4f363          	bgeu	s1,a5,0x3c3d4
   3c3d2:	84be                	c.mv	s1,a5
   3c3d4:	200027b7          	lui	a5,0x20002
   3c3d8:	bb47a683          	lw	a3,-1100(a5) # 0x20001bb4
   3c3dc:	00d4f363          	bgeu	s1,a3,0x3c3e2
   3c3e0:	86a6                	c.mv	a3,s1
   3c3e2:	06b2                	c.slli	a3,0xc
   3c3e4:	4601                	c.li	a2,0
   3c3e6:	4581                	c.li	a1,0
   3c3e8:	4505                	c.li	a0,1
   3c3ea:	000a2023          	sw	zero,0(s4)
   3c3ee:	00001097          	auipc	ra,0x1
   3c3f2:	40a080e7          	jalr	ra,1034(ra) # 0x3d7f8
   3c3f6:	0ff57493          	andi	s1,a0,255
   3c3fa:	ec0498e3          	bne	s1,zero,0x3c2ca
   3c3fe:	200027b7          	lui	a5,0x20002
   3c402:	bc078823          	sb	zero,-1072(a5) # 0x20001bd0
   3c406:	200027b7          	lui	a5,0x20002
   3c40a:	be0781a3          	sb	zero,-1053(a5) # 0x20001be3
   3c40e:	bd75                	c.j	0x3c2ca
   3c410:	0a700713          	addi	a4,zero,167
   3c414:	54e78163          	beq	a5,a4,0x3c956
   3c418:	68e7e563          	bltu	a5,a4,0x3caa2
   3c41c:	0a800713          	addi	a4,zero,168
   3c420:	34e78f63          	beq	a5,a4,0x3c77e
   3c424:	0c500713          	addi	a4,zero,197
   3c428:	eae791e3          	bne	a5,a4,0x3c2ca
   3c42c:	200027b7          	lui	a5,0x20002
   3c430:	4709                	c.li	a4,2
   3c432:	bee78023          	sb	a4,-1056(a5) # 0x20001be0
   3c436:	00444783          	lbu	a5,4(s0)
   3c43a:	00544703          	lbu	a4,5(s0)
   3c43e:	07a2                	c.slli	a5,0x8
   3c440:	0742                	c.slli	a4,0x10
   3c442:	97ba                	c.add	a5,a4
   3c444:	00344703          	lbu	a4,3(s0)
   3c448:	97ba                	c.add	a5,a4
   3c44a:	00644703          	lbu	a4,6(s0)
   3c44e:	0762                	c.slli	a4,0x18
   3c450:	97ba                	c.add	a5,a4
   3c452:	20002737          	lui	a4,0x20002
   3c456:	baf72223          	sw	a5,-1116(a4) # 0x20001ba4
   3c45a:	ac2d                	c.j	0x3c694
   3c45c:	0057e7b7          	lui	a5,0x57e
   3c460:	40002737          	lui	a4,0x40002
   3c464:	40078793          	addi	a5,a5,1024 # 0x57e400
   3c468:	40f72623          	sw	a5,1036(a4) # 0x4000240c
   3c46c:	20002637          	lui	a2,0x20002
   3c470:	4785                	c.li	a5,1
   3c472:	0003e5b7          	lui	a1,0x3e
   3c476:	40f70323          	sb	a5,1030(a4)
   3c47a:	df060a93          	addi	s5,a2,-528 # 0x20001df0
   3c47e:	46a1                	c.li	a3,8
   3c480:	df060613          	addi	a2,a2,-528
   3c484:	15e1                	c.addi	a1,-8 # 0x3dff8
   3c486:	4531                	c.li	a0,12
   3c488:	00001097          	auipc	ra,0x1
   3c48c:	370080e7          	jalr	ra,880(ra) # 0x3d7f8
   3c490:	200027b7          	lui	a5,0x20002
   3c494:	000ac703          	lbu	a4,0(s5)
   3c498:	bd478793          	addi	a5,a5,-1068 # 0x20001bd4
   3c49c:	0157a023          	sw	s5,0(a5)
   3c4a0:	04300693          	addi	a3,zero,67
   3c4a4:	04e69763          	bne	a3,a4,0x3c4f2
   3c4a8:	001a8713          	addi	a4,s5,1
   3c4ac:	c398                	c.sw	a4,0(a5)
   3c4ae:	001ac703          	lbu	a4,1(s5)
   3c4b2:	04800693          	addi	a3,zero,72
   3c4b6:	02e69e63          	bne	a3,a4,0x3c4f2
   3c4ba:	003a8693          	addi	a3,s5,3
   3c4be:	0009a703          	lw	a4,0(s3)
   3c4c2:	002ac483          	lbu	s1,2(s5)
   3c4c6:	c394                	c.sw	a3,0(a5)
   3c4c8:	003ac783          	lbu	a5,3(s5)
   3c4cc:	0ff4f493          	andi	s1,s1,255
   3c4d0:	00f702a3          	sb	a5,5(a4)
   3c4d4:	400017b7          	lui	a5,0x40001
   3c4d8:	0417c783          	lbu	a5,65(a5) # 0x40001041
   3c4dc:	00f70323          	sb	a5,6(a4)
   3c4e0:	47cd                	c.li	a5,19
   3c4e2:	00f703a3          	sb	a5,7(a4)
   3c4e6:	00094783          	lbu	a5,0(s2)
   3c4ea:	0789                	c.addi	a5,2
   3c4ec:	00f90023          	sb	a5,0(s2)
   3c4f0:	bbe9                	c.j	0x3c2ca
   3c4f2:	400017b7          	lui	a5,0x40001
   3c4f6:	0417c483          	lbu	s1,65(a5) # 0x40001041
   3c4fa:	200027b7          	lui	a5,0x20002
   3c4fe:	bc078323          	sb	zero,-1082(a5) # 0x20001bc6
   3c502:	200027b7          	lui	a5,0x20002
   3c506:	ba07a823          	sw	zero,-1104(a5) # 0x20001bb0
   3c50a:	0009a783          	lw	a5,0(s3)
   3c50e:	474d                	c.li	a4,19
   3c510:	0ff4f493          	andi	s1,s1,255
   3c514:	000a2023          	sw	zero,0(s4)
   3c518:	00e782a3          	sb	a4,5(a5)
   3c51c:	b37d                	c.j	0x3c2ca
   3c51e:	200027b7          	lui	a5,0x20002
   3c522:	bee7c703          	lbu	a4,-1042(a5) # 0x20001bee
   3c526:	03a00793          	addi	a5,zero,58
   3c52a:	daf700e3          	beq	a4,a5,0x3c2ca
   3c52e:	200027b7          	lui	a5,0x20002
   3c532:	bd07c783          	lbu	a5,-1072(a5) # 0x20001bd0
   3c536:	d8079ae3          	bne	a5,zero,0x3c2ca
   3c53a:	00244703          	lbu	a4,2(s0)
   3c53e:	00144783          	lbu	a5,1(s0)
   3c542:	00444583          	lbu	a1,4(s0)
   3c546:	0722                	c.slli	a4,0x8
   3c548:	8f5d                	c.or	a4,a5
   3c54a:	00544783          	lbu	a5,5(s0)
   3c54e:	05a2                	c.slli	a1,0x8
   3c550:	176d                	c.addi	a4,-5
   3c552:	07c2                	c.slli	a5,0x10
   3c554:	95be                	c.add	a1,a5
   3c556:	00344783          	lbu	a5,3(s0)
   3c55a:	95be                	c.add	a1,a5
   3c55c:	00644783          	lbu	a5,6(s0)
   3c560:	07e2                	c.slli	a5,0x18
   3c562:	95be                	c.add	a1,a5
   3c564:	00b706b3          	add	a3,a4,a1
   3c568:	0003c7b7          	lui	a5,0x3c
   3c56c:	d4d7efe3          	bltu	a5,a3,0x3c2ca
   3c570:	200027b7          	lui	a5,0x20002
   3c574:	bbc78793          	addi	a5,a5,-1092 # 0x20001bbc
   3c578:	0007c883          	lbu	a7,0(a5)
   3c57c:	0017c303          	lbu	t1,1(a5)
   3c580:	0027ce03          	lbu	t3,2(a5)
   3c584:	0037ce83          	lbu	t4,3(a5)
   3c588:	0047cf03          	lbu	t5,4(a5)
   3c58c:	0057cf83          	lbu	t6,5(a5)
   3c590:	0067c283          	lbu	t0,6(a5)
   3c594:	0077c383          	lbu	t2,7(a5)
   3c598:	20002537          	lui	a0,0x20002
   3c59c:	86a2                	c.mv	a3,s0
   3c59e:	0ff5f613          	andi	a2,a1,255
   3c5a2:	4801                	c.li	a6,0
   3c5a4:	bf050513          	addi	a0,a0,-1040 # 0x20001bf0
   3c5a8:	06a1                	c.addi	a3,8 # 0x500008
   3c5aa:	06e86163          	bltu	a6,a4,0x3c60c
   3c5ae:	000a2683          	lw	a3,0(s4)
   3c5b2:	0ff00793          	addi	a5,zero,255
   3c5b6:	96ba                	c.add	a3,a4
   3c5b8:	00da2023          	sw	a3,0(s4)
   3c5bc:	0cd7f863          	bgeu	a5,a3,0x3c68c
   3c5c0:	f005fb13          	andi	s6,a1,-256
   3c5c4:	20002ab7          	lui	s5,0x20002
   3c5c8:	10000693          	addi	a3,zero,256
   3c5cc:	bf0a8613          	addi	a2,s5,-1040 # 0x20001bf0
   3c5d0:	85da                	c.mv	a1,s6
   3c5d2:	4509                	c.li	a0,2
   3c5d4:	00001097          	auipc	ra,0x1
   3c5d8:	224080e7          	jalr	ra,548(ra) # 0x3d7f8
   3c5dc:	0ff57493          	andi	s1,a0,255
   3c5e0:	ce0495e3          	bne	s1,zero,0x3c2ca
   3c5e4:	000a2783          	lw	a5,0(s4)
   3c5e8:	4681                	c.li	a3,0
   3c5ea:	f0078793          	addi	a5,a5,-256
   3c5ee:	00fa2023          	sw	a5,0(s4)
   3c5f2:	0027d713          	srli	a4,a5,0x2
   3c5f6:	bf0a8793          	addi	a5,s5,-1040
   3c5fa:	08d71263          	bne	a4,a3,0x3c67e
   3c5fe:	100b0593          	addi	a1,s6,256
   3c602:	200027b7          	lui	a5,0x20002
   3c606:	bab7a423          	sw	a1,-1112(a5) # 0x20001ba8
   3c60a:	b1c1                	c.j	0x3c2ca
   3c60c:	0016c783          	lbu	a5,1(a3)
   3c610:	0026c483          	lbu	s1,2(a3)
   3c614:	ffc67a93          	andi	s5,a2,-4
   3c618:	00f347b3          	xor	a5,t1,a5
   3c61c:	009e44b3          	xor	s1,t3,s1
   3c620:	04c2                	c.slli	s1,0x10
   3c622:	07a2                	c.slli	a5,0x8
   3c624:	97a6                	c.add	a5,s1
   3c626:	0006c483          	lbu	s1,0(a3)
   3c62a:	9aaa                	c.add	s5,a0
   3c62c:	0821                	c.addi	a6,8
   3c62e:	0098c4b3          	xor	s1,a7,s1
   3c632:	97a6                	c.add	a5,s1
   3c634:	0036c483          	lbu	s1,3(a3)
   3c638:	009ec4b3          	xor	s1,t4,s1
   3c63c:	04e2                	c.slli	s1,0x18
   3c63e:	97a6                	c.add	a5,s1
   3c640:	00faa023          	sw	a5,0(s5)
   3c644:	0056c783          	lbu	a5,5(a3)
   3c648:	0066ca83          	lbu	s5,6(a3)
   3c64c:	00460493          	addi	s1,a2,4
   3c650:	00ffc7b3          	xor	a5,t6,a5
   3c654:	0152cab3          	xor	s5,t0,s5
   3c658:	0ac2                	c.slli	s5,0x10
   3c65a:	07a2                	c.slli	a5,0x8
   3c65c:	97d6                	c.add	a5,s5
   3c65e:	0046ca83          	lbu	s5,4(a3)
   3c662:	98f1                	c.andi	s1,-4
   3c664:	94aa                	c.add	s1,a0
   3c666:	015f4ab3          	xor	s5,t5,s5
   3c66a:	97d6                	c.add	a5,s5
   3c66c:	0076ca83          	lbu	s5,7(a3)
   3c670:	0621                	c.addi	a2,8
   3c672:	0153cab3          	xor	s5,t2,s5
   3c676:	0ae2                	c.slli	s5,0x18
   3c678:	97d6                	c.add	a5,s5
   3c67a:	c09c                	c.sw	a5,0(s1)
   3c67c:	b735                	c.j	0x3c5a8
   3c67e:	1007a603          	lw	a2,256(a5)
   3c682:	0685                	c.addi	a3,1
   3c684:	0791                	c.addi	a5,4
   3c686:	fec7ae23          	sw	a2,-4(a5)
   3c68a:	bf85                	c.j	0x3c5fa
   3c68c:	03700793          	addi	a5,zero,55
   3c690:	00e7f463          	bgeu	a5,a4,0x3c698
   3c694:	4481                	c.li	s1,0
   3c696:	b915                	c.j	0x3c2ca
   3c698:	def5                	c.beqz	a3,0x3c694
   3c69a:	20002637          	lui	a2,0x20002
   3c69e:	bf060613          	addi	a2,a2,-1040 # 0x20001bf0
   3c6a2:	f005f593          	andi	a1,a1,-256
   3c6a6:	4509                	c.li	a0,2
   3c6a8:	00001097          	auipc	ra,0x1
   3c6ac:	150080e7          	jalr	ra,336(ra) # 0x3d7f8
   3c6b0:	0ff57493          	andi	s1,a0,255
   3c6b4:	000a2023          	sw	zero,0(s4)
   3c6b8:	b909                	c.j	0x3c2ca
   3c6ba:	00144703          	lbu	a4,1(s0)
   3c6be:	47f5                	c.li	a5,29
   3c6c0:	c0e7f5e3          	bgeu	a5,a4,0x3c2ca
   3c6c4:	479d                	c.li	a5,7
   3c6c6:	02f757b3          	divu	a5,a4,a5
   3c6ca:	200026b7          	lui	a3,0x20002
   3c6ce:	bb86c683          	lbu	a3,-1096(a3) # 0x20001bb8
   3c6d2:	20002837          	lui	a6,0x20002
   3c6d6:	488d                	c.li	a7,3
   3c6d8:	4315                	c.li	t1,5
   3c6da:	4481                	c.li	s1,0
   3c6dc:	00f405b3          	add	a1,s0,a5
   3c6e0:	0035c583          	lbu	a1,3(a1)
   3c6e4:	00279613          	slli	a2,a5,0x2
   3c6e8:	9622                	c.add	a2,s0
   3c6ea:	00364503          	lbu	a0,3(a2)
   3c6ee:	8db5                	c.xor	a1,a3
   3c6f0:	bbc80613          	addi	a2,a6,-1092 # 0x20001bbc
   3c6f4:	00b60123          	sb	a1,2(a2)
   3c6f8:	4599                	c.li	a1,6
   3c6fa:	02b785b3          	mul	a1,a5,a1
   3c6fe:	8d35                	c.xor	a0,a3
   3c700:	00a60023          	sb	a0,0(a2)
   3c704:	95a2                	c.add	a1,s0
   3c706:	0035c583          	lbu	a1,3(a1)
   3c70a:	8db5                	c.xor	a1,a3
   3c70c:	00b601a3          	sb	a1,3(a2)
   3c710:	031785b3          	mul	a1,a5,a7
   3c714:	026787b3          	mul	a5,a5,t1
   3c718:	95a2                	c.add	a1,s0
   3c71a:	0035c583          	lbu	a1,3(a1)
   3c71e:	8db5                	c.xor	a1,a3
   3c720:	00b60223          	sb	a1,4(a2)
   3c724:	97a2                	c.add	a5,s0
   3c726:	0037c583          	lbu	a1,3(a5)
   3c72a:	026757b3          	divu	a5,a4,t1
   3c72e:	8db5                	c.xor	a1,a3
   3c730:	00b60323          	sb	a1,6(a2)
   3c734:	00f40733          	add	a4,s0,a5
   3c738:	031787b3          	mul	a5,a5,a7
   3c73c:	00374703          	lbu	a4,3(a4)
   3c740:	8f35                	c.xor	a4,a3
   3c742:	00e600a3          	sb	a4,1(a2)
   3c746:	bbc80713          	addi	a4,a6,-1092
   3c74a:	97a2                	c.add	a5,s0
   3c74c:	0037c783          	lbu	a5,3(a5)
   3c750:	8fb5                	c.xor	a5,a3
   3c752:	00f602a3          	sb	a5,5(a2)
   3c756:	400017b7          	lui	a5,0x40001
   3c75a:	0417c783          	lbu	a5,65(a5) # 0x40001041
   3c75e:	97aa                	c.add	a5,a0
   3c760:	00f603a3          	sb	a5,7(a2)
   3c764:	4781                	c.li	a5,0
   3c766:	4621                	c.li	a2,8
   3c768:	00f706b3          	add	a3,a4,a5
   3c76c:	0006c683          	lbu	a3,0(a3)
   3c770:	0785                	c.addi	a5,1
   3c772:	94b6                	c.add	s1,a3
   3c774:	0ff4f493          	andi	s1,s1,255
   3c778:	fec798e3          	bne	a5,a2,0x3c768
   3c77c:	b6b9                	c.j	0x3c2ca
   3c77e:	00344783          	lbu	a5,3(s0)
   3c782:	471d                	c.li	a4,7
   3c784:	8b9d                	c.andi	a5,7
   3c786:	b4e792e3          	bne	a5,a4,0x3c2ca
   3c78a:	00d44703          	lbu	a4,13(s0)
   3c78e:	00744583          	lbu	a1,7(s0)
   3c792:	20002a37          	lui	s4,0x20002
   3c796:	04076613          	ori	a2,a4,64
   3c79a:	577d                	c.li	a4,-1
   3c79c:	00e407a3          	sb	a4,15(s0)
   3c7a0:	00644703          	lbu	a4,6(s0)
   3c7a4:	05c2                	c.slli	a1,0x10
   3c7a6:	be4a0a93          	addi	s5,s4,-1052 # 0x20001be4
   3c7aa:	0722                	c.slli	a4,0x8
   3c7ac:	972e                	c.add	a4,a1
   3c7ae:	00544583          	lbu	a1,5(s0)
   3c7b2:	00e44783          	lbu	a5,14(s0)
   3c7b6:	01044683          	lbu	a3,16(s0)
   3c7ba:	972e                	c.add	a4,a1
   3c7bc:	00844583          	lbu	a1,8(s0)
   3c7c0:	03f7f793          	andi	a5,a5,63
   3c7c4:	8abd                	c.andi	a3,15
   3c7c6:	05e2                	c.slli	a1,0x18
   3c7c8:	972e                	c.add	a4,a1
   3c7ca:	00eaa023          	sw	a4,0(s5)
   3c7ce:	00b44583          	lbu	a1,11(s0)
   3c7d2:	00a44703          	lbu	a4,10(s0)
   3c7d6:	00f40723          	sb	a5,14(s0)
   3c7da:	05c2                	c.slli	a1,0x10
   3c7dc:	0722                	c.slli	a4,0x8
   3c7de:	972e                	c.add	a4,a1
   3c7e0:	00944583          	lbu	a1,9(s0)
   3c7e4:	0406e693          	ori	a3,a3,64
   3c7e8:	07a2                	c.slli	a5,0x8
   3c7ea:	972e                	c.add	a4,a1
   3c7ec:	00c44583          	lbu	a1,12(s0)
   3c7f0:	200024b7          	lui	s1,0x20002
   3c7f4:	00d40823          	sb	a3,16(s0)
   3c7f8:	05e2                	c.slli	a1,0x18
   3c7fa:	972e                	c.add	a4,a1
   3c7fc:	00eaa223          	sw	a4,4(s5)
   3c800:	00ff0737          	lui	a4,0xff0
   3c804:	9732                	c.add	a4,a2
   3c806:	97ba                	c.add	a5,a4
   3c808:	06e2                	c.slli	a3,0x18
   3c80a:	0003f5b7          	lui	a1,0x3f
   3c80e:	97b6                	c.add	a5,a3
   3c810:	00c406a3          	sb	a2,13(s0)
   3c814:	46b1                	c.li	a3,12
   3c816:	df048613          	addi	a2,s1,-528 # 0x20001df0
   3c81a:	15d1                	c.addi	a1,-12 # 0x3eff4
   3c81c:	4531                	c.li	a0,12
   3c81e:	00faa423          	sw	a5,8(s5)
   3c822:	df048b13          	addi	s6,s1,-528
   3c826:	00001097          	auipc	ra,0x1
   3c82a:	fd2080e7          	jalr	ra,-46(ra) # 0x3d7f8
   3c82e:	008aa703          	lw	a4,8(s5)
   3c832:	008b2783          	lw	a5,8(s6)
   3c836:	df048493          	addi	s1,s1,-528
   3c83a:	00f71c63          	bne	a4,a5,0x3c852
   3c83e:	004aa703          	lw	a4,4(s5)
   3c842:	40dc                	c.lw	a5,4(s1)
   3c844:	00f71763          	bne	a4,a5,0x3c852
   3c848:	000aa703          	lw	a4,0(s5)
   3c84c:	409c                	c.lw	a5,0(s1)
   3c84e:	e4f703e3          	beq	a4,a5,0x3c694
   3c852:	00f44703          	lbu	a4,15(s0)
   3c856:	03a00793          	addi	a5,zero,58
   3c85a:	4a89                	c.li	s5,2
   3c85c:	00f71463          	bne	a4,a5,0x3c864
   3c860:	0f000a93          	addi	s5,zero,240
   3c864:	20002637          	lui	a2,0x20002
   3c868:	ba060b13          	addi	s6,a2,-1120 # 0x20001ba0
   3c86c:	4691                	c.li	a3,4
   3c86e:	ba060613          	addi	a2,a2,-1120
   3c872:	45d1                	c.li	a1,20
   3c874:	4531                	c.li	a0,12
   3c876:	00001097          	auipc	ra,0x1
   3c87a:	f82080e7          	jalr	ra,-126(ra) # 0x3d7f8
   3c87e:	000b2783          	lw	a5,0(s6)
   3c882:	0187d713          	srli	a4,a5,0x18
   3c886:	8f3d                	c.xor	a4,a5
   3c888:	fff74713          	xori	a4,a4,-1
   3c88c:	0ff77713          	andi	a4,a4,255
   3c890:	ef11                	c.bnez	a4,0x3c8ac
   3c892:	00f00737          	lui	a4,0xf00
   3c896:	8f7d                	c.and	a4,a5
   3c898:	005006b7          	lui	a3,0x500
   3c89c:	00d71863          	bne	a4,a3,0x3c8ac
   3c8a0:	83a9                	c.srli	a5,0xa
   3c8a2:	3ff7f793          	andi	a5,a5,1023
   3c8a6:	00faf363          	bgeu	s5,a5,0x3c8ac
   3c8aa:	8abe                	c.mv	s5,a5
   3c8ac:	40dc                	c.lw	a5,4(s1)
   3c8ae:	0187d713          	srli	a4,a5,0x18
   3c8b2:	8f3d                	c.xor	a4,a5
   3c8b4:	fff74713          	xori	a4,a4,-1
   3c8b8:	0ff77713          	andi	a4,a4,255
   3c8bc:	ef11                	c.bnez	a4,0x3c8d8
   3c8be:	00f00737          	lui	a4,0xf00
   3c8c2:	8f7d                	c.and	a4,a5
   3c8c4:	005006b7          	lui	a3,0x500
   3c8c8:	00d71863          	bne	a4,a3,0x3c8d8
   3c8cc:	83a9                	c.srli	a5,0xa
   3c8ce:	3ff7f793          	andi	a5,a5,1023
   3c8d2:	00faf363          	bgeu	s5,a5,0x3c8d8
   3c8d6:	8abe                	c.mv	s5,a5
   3c8d8:	200027b7          	lui	a5,0x20002
   3c8dc:	bb47a683          	lw	a3,-1100(a5) # 0x20001bb4
   3c8e0:	00daf363          	bgeu	s5,a3,0x3c8e6
   3c8e4:	86d6                	c.mv	a3,s5
   3c8e6:	06b2                	c.slli	a3,0xc
   3c8e8:	4601                	c.li	a2,0
   3c8ea:	4581                	c.li	a1,0
   3c8ec:	4505                	c.li	a0,1
   3c8ee:	00001097          	auipc	ra,0x1
   3c8f2:	f0a080e7          	jalr	ra,-246(ra) # 0x3d7f8
   3c8f6:	0ff57493          	andi	s1,a0,255
   3c8fa:	9c0498e3          	bne	s1,zero,0x3c2ca
   3c8fe:	6685                	c.lui	a3,0x1
   3c900:	4601                	c.li	a2,0
   3c902:	0003e5b7          	lui	a1,0x3e
   3c906:	4505                	c.li	a0,1
   3c908:	00001097          	auipc	ra,0x1
   3c90c:	ef0080e7          	jalr	ra,-272(ra) # 0x3d7f8
   3c910:	0ff57493          	andi	s1,a0,255
   3c914:	ec99                	c.bnez	s1,0x3c932
   3c916:	0003f5b7          	lui	a1,0x3f
   3c91a:	46b1                	c.li	a3,12
   3c91c:	be4a0613          	addi	a2,s4,-1052
   3c920:	15d1                	c.addi	a1,-12 # 0x3eff4
   3c922:	4509                	c.li	a0,2
   3c924:	00001097          	auipc	ra,0x1
   3c928:	ed4080e7          	jalr	ra,-300(ra) # 0x3d7f8
   3c92c:	0ff57493          	andi	s1,a0,255
   3c930:	cc89                	c.beqz	s1,0x3c94a
   3c932:	0003f5b7          	lui	a1,0x3f
   3c936:	46b1                	c.li	a3,12
   3c938:	be4a0613          	addi	a2,s4,-1052
   3c93c:	15d1                	c.addi	a1,-12 # 0x3eff4
   3c93e:	4531                	c.li	a0,12
   3c940:	00001097          	auipc	ra,0x1
   3c944:	eb8080e7          	jalr	ra,-328(ra) # 0x3d7f8
   3c948:	b249                	c.j	0x3c2ca
   3c94a:	200027b7          	lui	a5,0x20002
   3c94e:	4705                	c.li	a4,1
   3c950:	bce782a3          	sb	a4,-1083(a5) # 0x20001bc5
   3c954:	ba9d                	c.j	0x3c2ca
   3c956:	00344483          	lbu	s1,3(s0)
   3c95a:	479d                	c.li	a5,7
   3c95c:	889d                	c.andi	s1,7
   3c95e:	14f49063          	bne	s1,a5,0x3ca9e
   3c962:	00094783          	lbu	a5,0(s2)
   3c966:	0009a503          	lw	a0,0(s3)
   3c96a:	200025b7          	lui	a1,0x20002
   3c96e:	4631                	c.li	a2,12
   3c970:	953e                	c.add	a0,a5
   3c972:	be458593          	addi	a1,a1,-1052 # 0x20001be4
   3c976:	00000097          	auipc	ra,0x0
   3c97a:	886080e7          	jalr	ra,-1914(ra) # 0x3c1fc
   3c97e:	00094783          	lbu	a5,0(s2)
   3c982:	0009a683          	lw	a3,0(s3)
   3c986:	07b1                	c.addi	a5,12
   3c988:	00f90023          	sb	a5,0(s2)
   3c98c:	00a6c783          	lbu	a5,10(a3) # 0x100a
   3c990:	0df7f713          	andi	a4,a5,223
   3c994:	00e68523          	sb	a4,10(a3)
   3c998:	400017b7          	lui	a5,0x40001
   3c99c:	0457c783          	lbu	a5,69(a5) # 0x40001045
   3c9a0:	0207f793          	andi	a5,a5,32
   3c9a4:	8fd9                	c.or	a5,a4
   3c9a6:	00f68523          	sb	a5,10(a3)
   3c9aa:	00344783          	lbu	a5,3(s0)
   3c9ae:	8ba1                	c.andi	a5,8
   3c9b0:	cf85                	c.beqz	a5,0x3c9e8
   3c9b2:	200026b7          	lui	a3,0x20002
   3c9b6:	0084e493          	ori	s1,s1,8
   3c9ba:	4781                	c.li	a5,0
   3c9bc:	b9868693          	addi	a3,a3,-1128 # 0x20001b98
   3c9c0:	4611                	c.li	a2,4
   3c9c2:	00f68733          	add	a4,a3,a5
   3c9c6:	00094503          	lbu	a0,0(s2)
   3c9ca:	00074583          	lbu	a1,0(a4) # 0xf00000
   3c9ce:	0009a703          	lw	a4,0(s3)
   3c9d2:	0785                	c.addi	a5,1
   3c9d4:	972a                	c.add	a4,a0
   3c9d6:	00b70023          	sb	a1,0(a4)
   3c9da:	00094703          	lbu	a4,0(s2)
   3c9de:	0705                	c.addi	a4,1
   3c9e0:	00e90023          	sb	a4,0(s2)
   3c9e4:	fcc79fe3          	bne	a5,a2,0x3c9c2
   3c9e8:	00344783          	lbu	a5,3(s0)
   3c9ec:	8bc1                	c.andi	a5,16
   3c9ee:	cfad                	c.beqz	a5,0x3ca68
   3c9f0:	20002637          	lui	a2,0x20002
   3c9f4:	0003f5b7          	lui	a1,0x3f
   3c9f8:	20002a37          	lui	s4,0x20002
   3c9fc:	df060a93          	addi	s5,a2,-528 # 0x20001df0
   3ca00:	46a1                	c.li	a3,8
   3ca02:	df060613          	addi	a2,a2,-528
   3ca06:	05e1                	c.addi	a1,24 # 0x3f018
   3ca08:	4531                	c.li	a0,12
   3ca0a:	ba0a0c23          	sb	zero,-1096(s4) # 0x20001bb8
   3ca0e:	00001097          	auipc	ra,0x1
   3ca12:	dea080e7          	jalr	ra,-534(ra) # 0x3d7f8
   3ca16:	200027b7          	lui	a5,0x20002
   3ca1a:	bd57aa23          	sw	s5,-1068(a5) # 0x20001bd4
   3ca1e:	0104e493          	ori	s1,s1,16
   3ca22:	46a1                	c.li	a3,8
   3ca24:	bd478793          	addi	a5,a5,-1068
   3ca28:	bb8a0a13          	addi	s4,s4,-1096
   3ca2c:	4398                	c.lw	a4,0(a5)
   3ca2e:	00094583          	lbu	a1,0(s2)
   3ca32:	16fd                	c.addi	a3,-1
   3ca34:	00074603          	lbu	a2,0(a4)
   3ca38:	0009a703          	lw	a4,0(s3)
   3ca3c:	972e                	c.add	a4,a1
   3ca3e:	00c70023          	sb	a2,0(a4)
   3ca42:	00094703          	lbu	a4,0(s2)
   3ca46:	0009a603          	lw	a2,0(s3)
   3ca4a:	000a4583          	lbu	a1,0(s4)
   3ca4e:	963a                	c.add	a2,a4
   3ca50:	00064603          	lbu	a2,0(a2)
   3ca54:	0705                	c.addi	a4,1
   3ca56:	00e90023          	sb	a4,0(s2)
   3ca5a:	962e                	c.add	a2,a1
   3ca5c:	00ca0023          	sb	a2,0(s4)
   3ca60:	4390                	c.lw	a2,0(a5)
   3ca62:	0605                	c.addi	a2,1
   3ca64:	c390                	c.sw	a2,0(a5)
   3ca66:	f2f9                	c.bnez	a3,0x3ca2c
   3ca68:	200027b7          	lui	a5,0x20002
   3ca6c:	bc0782a3          	sb	zero,-1083(a5) # 0x20001bc5
   3ca70:	05700713          	addi	a4,zero,87
   3ca74:	400017b7          	lui	a5,0x40001
   3ca78:	04e78023          	sb	a4,64(a5) # 0x40001040
   3ca7c:	fa800713          	addi	a4,zero,-88
   3ca80:	04e78023          	sb	a4,64(a5)
   3ca84:	0447c703          	lbu	a4,68(a5)
   3ca88:	4681                	c.li	a3,0
   3ca8a:	4601                	c.li	a2,0
   3ca8c:	02076713          	ori	a4,a4,32
   3ca90:	04e78223          	sb	a4,68(a5)
   3ca94:	04078023          	sb	zero,64(a5)
   3ca98:	4581                	c.li	a1,0
   3ca9a:	4511                	c.li	a0,4
   3ca9c:	b555                	c.j	0x3c940
   3ca9e:	4481                	c.li	s1,0
   3caa0:	b729                	c.j	0x3c9aa
   3caa2:	00244683          	lbu	a3,2(s0)
   3caa6:	00144783          	lbu	a5,1(s0)
   3caaa:	00444583          	lbu	a1,4(s0)
   3caae:	06a2                	c.slli	a3,0x8
   3cab0:	8edd                	c.or	a3,a5
   3cab2:	00544783          	lbu	a5,5(s0)
   3cab6:	05a2                	c.slli	a1,0x8
   3cab8:	16ed                	c.addi	a3,-5
   3caba:	07c2                	c.slli	a5,0x10
   3cabc:	95be                	c.add	a1,a5
   3cabe:	00344783          	lbu	a5,3(s0)
   3cac2:	95be                	c.add	a1,a5
   3cac4:	00644783          	lbu	a5,6(s0)
   3cac8:	07e2                	c.slli	a5,0x18
   3caca:	95be                	c.add	a1,a5
   3cacc:	00b6e7b3          	or	a5,a3,a1
   3cad0:	8b9d                	c.andi	a5,7
   3cad2:	fe079c63          	bne	a5,zero,0x3c2ca
   3cad6:	20002737          	lui	a4,0x20002
   3cada:	be374603          	lbu	a2,-1053(a4) # 0x20001be3
   3cade:	be370a13          	addi	s4,a4,-1053
   3cae2:	fe061463          	bne	a2,zero,0x3c2ca
   3cae6:	20002637          	lui	a2,0x20002
   3caea:	8722                	c.mv	a4,s0
   3caec:	bbc60613          	addi	a2,a2,-1092 # 0x20001bbc
   3caf0:	0705                	c.addi	a4,1
   3caf2:	02d7e263          	bltu	a5,a3,0x3cb16
   3caf6:	00840613          	addi	a2,s0,8
   3cafa:	450d                	c.li	a0,3
   3cafc:	00001097          	auipc	ra,0x1
   3cb00:	cfc080e7          	jalr	ra,-772(ra) # 0x3d7f8
   3cb04:	0ff57493          	andi	s1,a0,255
   3cb08:	fc048163          	beq	s1,zero,0x3c2ca
   3cb0c:	4785                	c.li	a5,1
   3cb0e:	00fa0023          	sb	a5,0(s4)
   3cb12:	fb8ff06f          	jal	zero,0x3c2ca
   3cb16:	0077f513          	andi	a0,a5,7
   3cb1a:	9532                	c.add	a0,a2
   3cb1c:	00774803          	lbu	a6,7(a4)
   3cb20:	00054503          	lbu	a0,0(a0)
   3cb24:	0785                	c.addi	a5,1
   3cb26:	01054533          	xor	a0,a0,a6
   3cb2a:	00a703a3          	sb	a0,7(a4)
   3cb2e:	b7c9                	c.j	0x3caf0
   3cb30:	00344783          	lbu	a5,3(s0)
   3cb34:	4705                	c.li	a4,1
   3cb36:	00e79663          	bne	a5,a4,0x3cb42
   3cb3a:	20002737          	lui	a4,0x20002
   3cb3e:	bcf70323          	sb	a5,-1082(a4) # 0x20001bc6
   3cb42:	400017b7          	lui	a5,0x40001
   3cb46:	05700713          	addi	a4,zero,87
   3cb4a:	04e78023          	sb	a4,64(a5) # 0x40001040
   3cb4e:	fa800713          	addi	a4,zero,-88
   3cb52:	04e78023          	sb	a4,64(a5)
   3cb56:	0447c703          	lbu	a4,68(a5)
   3cb5a:	0df77713          	andi	a4,a4,223
   3cb5e:	04e78223          	sb	a4,68(a5)
   3cb62:	04078023          	sb	zero,64(a5)
   3cb66:	4705                	c.li	a4,1
   3cb68:	200027b7          	lui	a5,0x20002
   3cb6c:	bee78023          	sb	a4,-1056(a5) # 0x20001be0
   3cb70:	b615                	c.j	0x3c694
   3cb72:	1101                	c.addi	sp,-32
   3cb74:	ce06                	c.swsp	ra,28(sp)
   3cb76:	cc22                	c.swsp	s0,24(sp)
   3cb78:	ca26                	c.swsp	s1,20(sp)
   3cb7a:	c84a                	c.swsp	s2,16(sp)
   3cb7c:	c64e                	c.swsp	s3,12(sp)
   3cb7e:	fffff097          	auipc	ra,0xfffff
   3cb82:	66c080e7          	jalr	ra,1644(ra) # 0x3c1ea
   3cb86:	05700793          	addi	a5,zero,87
   3cb8a:	1af51463          	bne	a0,a5,0x3cd32
   3cb8e:	fffff097          	auipc	ra,0xfffff
   3cb92:	65c080e7          	jalr	ra,1628(ra) # 0x3c1ea
   3cb96:	0ab00793          	addi	a5,zero,171
   3cb9a:	10f51463          	bne	a0,a5,0x3cca2
   3cb9e:	20002437          	lui	s0,0x20002
   3cba2:	f1040913          	addi	s2,s0,-240 # 0x20001f10
   3cba6:	fffff097          	auipc	ra,0xfffff
   3cbaa:	644080e7          	jalr	ra,1604(ra) # 0x3c1ea
   3cbae:	84aa                	c.mv	s1,a0
   3cbb0:	00a90023          	sb	a0,0(s2)
   3cbb4:	fffff097          	auipc	ra,0xfffff
   3cbb8:	636080e7          	jalr	ra,1590(ra) # 0x3c1ea
   3cbbc:	94aa                	c.add	s1,a0
   3cbbe:	00a900a3          	sb	a0,1(s2)
   3cbc2:	0ff4f493          	andi	s1,s1,255
   3cbc6:	fffff097          	auipc	ra,0xfffff
   3cbca:	624080e7          	jalr	ra,1572(ra) # 0x3c1ea
   3cbce:	00a90123          	sb	a0,2(s2)
   3cbd2:	9526                	c.add	a0,s1
   3cbd4:	0ff57493          	andi	s1,a0,255
   3cbd8:	4901                	c.li	s2,0
   3cbda:	f1040413          	addi	s0,s0,-240
   3cbde:	00144783          	lbu	a5,1(s0)
   3cbe2:	0d279763          	bne	a5,s2,0x3ccb0
   3cbe6:	fffff097          	auipc	ra,0xfffff
   3cbea:	604080e7          	jalr	ra,1540(ra) # 0x3c1ea
   3cbee:	00144703          	lbu	a4,1(s0)
   3cbf2:	4781                	c.li	a5,0
   3cbf4:	0405                	c.addi	s0,1
   3cbf6:	0cf71a63          	bne	a4,a5,0x3ccca
   3cbfa:	0aa49063          	bne	s1,a0,0x3cc9a
   3cbfe:	200027b7          	lui	a5,0x20002
   3cc02:	ecc78793          	addi	a5,a5,-308 # 0x20001ecc
   3cc06:	20002937          	lui	s2,0x20002
   3cc0a:	bcf92e23          	sw	a5,-1060(s2) # 0x20001bdc
   3cc0e:	fffff097          	auipc	ra,0xfffff
   3cc12:	60a080e7          	jalr	ra,1546(ra) # 0x3c218
   3cc16:	05500513          	addi	a0,zero,85
   3cc1a:	fffff097          	auipc	ra,0xfffff
   3cc1e:	5b8080e7          	jalr	ra,1464(ra) # 0x3c1d2
   3cc22:	0aa00513          	addi	a0,zero,170
   3cc26:	fffff097          	auipc	ra,0xfffff
   3cc2a:	5ac080e7          	jalr	ra,1452(ra) # 0x3c1d2
   3cc2e:	4481                	c.li	s1,0
   3cc30:	4401                	c.li	s0,0
   3cc32:	bdc90913          	addi	s2,s2,-1060
   3cc36:	200029b7          	lui	s3,0x20002
   3cc3a:	bc79c703          	lbu	a4,-1081(s3) # 0x20001bc7
   3cc3e:	01049793          	slli	a5,s1,0x10
   3cc42:	83c1                	c.srli	a5,0x10
   3cc44:	08e7ec63          	bltu	a5,a4,0x3ccdc
   3cc48:	8522                	c.mv	a0,s0
   3cc4a:	fffff097          	auipc	ra,0xfffff
   3cc4e:	588080e7          	jalr	ra,1416(ra) # 0x3c1d2
   3cc52:	200027b7          	lui	a5,0x20002
   3cc56:	bc67c783          	lbu	a5,-1082(a5) # 0x20001bc6
   3cc5a:	c791                	c.beqz	a5,0x3cc66
   3cc5c:	200027b7          	lui	a5,0x20002
   3cc60:	4705                	c.li	a4,1
   3cc62:	bee780a3          	sb	a4,-1055(a5) # 0x20001be1
   3cc66:	20002737          	lui	a4,0x20002
   3cc6a:	be074783          	lbu	a5,-1056(a4) # 0x20001be0
   3cc6e:	be070713          	addi	a4,a4,-1056
   3cc72:	c785                	c.beqz	a5,0x3cc9a
   3cc74:	06400793          	addi	a5,zero,100
   3cc78:	0001                	c.addi	zero,0
   3cc7a:	17fd                	c.addi	a5,-1
   3cc7c:	07c2                	c.slli	a5,0x10
   3cc7e:	83c1                	c.srli	a5,0x10
   3cc80:	ffe5                	c.bnez	a5,0x3cc78
   3cc82:	00074783          	lbu	a5,0(a4)
   3cc86:	4685                	c.li	a3,1
   3cc88:	06d79d63          	bne	a5,a3,0x3cd02
   3cc8c:	400037b7          	lui	a5,0x40003
   3cc90:	46e9                	c.li	a3,26
   3cc92:	40d79623          	sh	a3,1036(a5) # 0x4000340c
   3cc96:	00070023          	sb	zero,0(a4)
   3cc9a:	200027b7          	lui	a5,0x20002
   3cc9e:	bc0787a3          	sb	zero,-1073(a5) # 0x20001bcf
   3cca2:	40f2                	c.lwsp	ra,28(sp)
   3cca4:	4462                	c.lwsp	s0,24(sp)
   3cca6:	44d2                	c.lwsp	s1,20(sp)
   3cca8:	4942                	c.lwsp	s2,16(sp)
   3ccaa:	49b2                	c.lwsp	s3,12(sp)
   3ccac:	6105                	c.addi16sp	sp,32
   3ccae:	8082                	c.jr	ra
   3ccb0:	fffff097          	auipc	ra,0xfffff
   3ccb4:	53a080e7          	jalr	ra,1338(ra) # 0x3c1ea
   3ccb8:	012407b3          	add	a5,s0,s2
   3ccbc:	0905                	c.addi	s2,1
   3ccbe:	0942                	c.slli	s2,0x10
   3ccc0:	00a781a3          	sb	a0,3(a5)
   3ccc4:	01095913          	srli	s2,s2,0x10
   3ccc8:	bf19                	c.j	0x3cbde
   3ccca:	00244683          	lbu	a3,2(s0)
   3ccce:	0785                	c.addi	a5,1
   3ccd0:	07c2                	c.slli	a5,0x10
   3ccd2:	94b6                	c.add	s1,a3
   3ccd4:	0ff4f493          	andi	s1,s1,255
   3ccd8:	83c1                	c.srli	a5,0x10
   3ccda:	bf29                	c.j	0x3cbf4
   3ccdc:	00092783          	lw	a5,0(s2)
   3cce0:	97a6                	c.add	a5,s1
   3cce2:	0007c503          	lbu	a0,0(a5)
   3cce6:	fffff097          	auipc	ra,0xfffff
   3ccea:	4ec080e7          	jalr	ra,1260(ra) # 0x3c1d2
   3ccee:	00092783          	lw	a5,0(s2)
   3ccf2:	97a6                	c.add	a5,s1
   3ccf4:	0007c783          	lbu	a5,0(a5)
   3ccf8:	0485                	c.addi	s1,1
   3ccfa:	943e                	c.add	s0,a5
   3ccfc:	0ff47413          	andi	s0,s0,255
   3cd00:	bf2d                	c.j	0x3cc3a
   3cd02:	4689                	c.li	a3,2
   3cd04:	f8d79be3          	bne	a5,a3,0x3cc9a
   3cd08:	200027b7          	lui	a5,0x20002
   3cd0c:	ba47a683          	lw	a3,-1116(a5) # 0x20001ba4
   3cd10:	01c9c7b7          	lui	a5,0x1c9c
   3cd14:	38078793          	addi	a5,a5,896 # 0x1c9c380
   3cd18:	02d7d7b3          	divu	a5,a5,a3
   3cd1c:	46a9                	c.li	a3,10
   3cd1e:	0795                	c.addi	a5,5
   3cd20:	02d7d7b3          	divu	a5,a5,a3
   3cd24:	400036b7          	lui	a3,0x40003
   3cd28:	07c2                	c.slli	a5,0x10
   3cd2a:	83c1                	c.srli	a5,0x10
   3cd2c:	40f69623          	sh	a5,1036(a3) # 0x4000340c
   3cd30:	b79d                	c.j	0x3cc96
   3cd32:	20002737          	lui	a4,0x20002
   3cd36:	bcf70713          	addi	a4,a4,-1073 # 0x20001bcf
   3cd3a:	00074783          	lbu	a5,0(a4)
   3cd3e:	0785                	c.addi	a5,1
   3cd40:	0ff7f793          	andi	a5,a5,255
   3cd44:	00f70023          	sb	a5,0(a4)
   3cd48:	0fc7f793          	andi	a5,a5,252
   3cd4c:	dbb9                	c.beqz	a5,0x3cca2
   3cd4e:	400037b7          	lui	a5,0x40003
   3cd52:	4769                	c.li	a4,26
   3cd54:	40e79623          	sh	a4,1036(a5) # 0x4000340c
   3cd58:	b7a9                	c.j	0x3cca2
   3cd5a:	1101                	c.addi	sp,-32
   3cd5c:	cc22                	c.swsp	s0,24(sp)
   3cd5e:	ce06                	c.swsp	ra,28(sp)
   3cd60:	ca26                	c.swsp	s1,20(sp)
   3cd62:	c84a                	c.swsp	s2,16(sp)
   3cd64:	c64e                	c.swsp	s3,12(sp)
   3cd66:	c452                	c.swsp	s4,8(sp)
   3cd68:	c256                	c.swsp	s5,4(sp)
   3cd6a:	40008437          	lui	s0,0x40008
   3cd6e:	00644783          	lbu	a5,6(s0) # 0x40008006
   3cd72:	8b89                	c.andi	a5,2
   3cd74:	34078963          	beq	a5,zero,0x3d0c6
   3cd78:	00744783          	lbu	a5,7(s0)
   3cd7c:	4709                	c.li	a4,2
   3cd7e:	03f7f793          	andi	a5,a5,63
   3cd82:	0ae78a63          	beq	a5,a4,0x3ce36
   3cd86:	06f76d63          	bltu	a4,a5,0x3ce00
   3cd8a:	1a078563          	beq	a5,zero,0x3cf34
   3cd8e:	400087b7          	lui	a5,0x40008
   3cd92:	0077c703          	lbu	a4,7(a5) # 0x40008007
   3cd96:	03000693          	addi	a3,zero,48
   3cd9a:	03077713          	andi	a4,a4,48
   3cd9e:	22d71063          	bne	a4,a3,0x3cfbe
   3cda2:	0077c703          	lbu	a4,7(a5)
   3cda6:	0762                	c.slli	a4,0x18
   3cda8:	8761                	c.srai	a4,0x18
   3cdaa:	20075a63          	bge	a4,zero,0x3cfbe
   3cdae:	fca00713          	addi	a4,zero,-54
   3cdb2:	20002537          	lui	a0,0x20002
   3cdb6:	02e78123          	sb	a4,34(a5)
   3cdba:	e8c50793          	addi	a5,a0,-372 # 0x20001e8c
   3cdbe:	0067d403          	lhu	s0,6(a5)
   3cdc2:	0017c703          	lbu	a4,1(a5)
   3cdc6:	0007c683          	lbu	a3,0(a5)
   3cdca:	200024b7          	lui	s1,0x20002
   3cdce:	200029b7          	lui	s3,0x20002
   3cdd2:	bc849423          	sh	s0,-1080(s1) # 0x20001bc8
   3cdd6:	bce98523          	sb	a4,-1078(s3) # 0x20001bca
   3cdda:	0606f613          	andi	a2,a3,96
   3cdde:	bca98993          	addi	s3,s3,-1078
   3cde2:	bc848493          	addi	s1,s1,-1080
   3cde6:	1a061e63          	bne	a2,zero,0x3cfa2
   3cdea:	4629                	c.li	a2,10
   3cdec:	1ae66b63          	bltu	a2,a4,0x3cfa2
   3cdf0:	20002637          	lui	a2,0x20002
   3cdf4:	070a                	c.slli	a4,0x2
   3cdf6:	b3860613          	addi	a2,a2,-1224 # 0x20001b38
   3cdfa:	9732                	c.add	a4,a2
   3cdfc:	4318                	c.lw	a4,0(a4)
   3cdfe:	8702                	c.jr	a4
   3ce00:	02000693          	addi	a3,zero,32
   3ce04:	08d78a63          	beq	a5,a3,0x3ce98
   3ce08:	02200713          	addi	a4,zero,34
   3ce0c:	f8e791e3          	bne	a5,a4,0x3cd8e
   3ce10:	02a44783          	lbu	a5,42(s0)
   3ce14:	0fc7f793          	andi	a5,a5,252
   3ce18:	0027e793          	ori	a5,a5,2
   3ce1c:	02f40523          	sb	a5,42(s0)
   3ce20:	200027b7          	lui	a5,0x20002
   3ce24:	bc67c783          	lbu	a5,-1082(a5) # 0x20001bc6
   3ce28:	c3b5                	c.beqz	a5,0x3ce8c
   3ce2a:	200027b7          	lui	a5,0x20002
   3ce2e:	4705                	c.li	a4,1
   3ce30:	bee780a3          	sb	a4,-1055(a5) # 0x20001be1
   3ce34:	a8a1                	c.j	0x3ce8c
   3ce36:	00644783          	lbu	a5,6(s0)
   3ce3a:	0407f793          	andi	a5,a5,64
   3ce3e:	c7b9                	c.beqz	a5,0x3ce8c
   3ce40:	00844603          	lbu	a2,8(s0)
   3ce44:	200025b7          	lui	a1,0x20002
   3ce48:	20002537          	lui	a0,0x20002
   3ce4c:	e0858493          	addi	s1,a1,-504 # 0x20001e08
   3ce50:	f1050513          	addi	a0,a0,-240 # 0x20001f10
   3ce54:	e0858593          	addi	a1,a1,-504
   3ce58:	fffff097          	auipc	ra,0xfffff
   3ce5c:	3a4080e7          	jalr	ra,932(ra) # 0x3c1fc
   3ce60:	200027b7          	lui	a5,0x20002
   3ce64:	04048493          	addi	s1,s1,64
   3ce68:	bc97ae23          	sw	s1,-1060(a5) # 0x20001bdc
   3ce6c:	fffff097          	auipc	ra,0xfffff
   3ce70:	3ac080e7          	jalr	ra,940(ra) # 0x3c218
   3ce74:	200027b7          	lui	a5,0x20002
   3ce78:	bc77c783          	lbu	a5,-1081(a5) # 0x20001bc7
   3ce7c:	02f40423          	sb	a5,40(s0)
   3ce80:	02a44783          	lbu	a5,42(s0)
   3ce84:	0fc7f793          	andi	a5,a5,252
   3ce88:	02f40523          	sb	a5,42(s0)
   3ce8c:	400087b7          	lui	a5,0x40008
   3ce90:	4709                	c.li	a4,2
   3ce92:	00e78323          	sb	a4,6(a5) # 0x40008006
   3ce96:	bde5                	c.j	0x3cd8e
   3ce98:	200027b7          	lui	a5,0x20002
   3ce9c:	bca7c783          	lbu	a5,-1078(a5) # 0x20001bca
   3cea0:	4695                	c.li	a3,5
   3cea2:	06d78863          	beq	a5,a3,0x3cf12
   3cea6:	4699                	c.li	a3,6
   3cea8:	08d79363          	bne	a5,a3,0x3cf2e
   3ceac:	200024b7          	lui	s1,0x20002
   3ceb0:	bc84d403          	lhu	s0,-1080(s1) # 0x20001bc8
   3ceb4:	04000793          	addi	a5,zero,64
   3ceb8:	bc848493          	addi	s1,s1,-1080
   3cebc:	0087f463          	bgeu	a5,s0,0x3cec4
   3cec0:	04000413          	addi	s0,zero,64
   3cec4:	20002937          	lui	s2,0x20002
   3cec8:	bd890913          	addi	s2,s2,-1064 # 0x20001bd8
   3cecc:	00092983          	lw	s3,0(s2)
   3ced0:	0442                	c.slli	s0,0x10
   3ced2:	8041                	c.srli	s0,0x10
   3ced4:	0ff47a13          	andi	s4,s0,255
   3ced8:	20002537          	lui	a0,0x20002
   3cedc:	8652                	c.mv	a2,s4
   3cede:	85ce                	c.mv	a1,s3
   3cee0:	e8c50513          	addi	a0,a0,-372 # 0x20001e8c
   3cee4:	fffff097          	auipc	ra,0xfffff
   3cee8:	318080e7          	jalr	ra,792(ra) # 0x3c1fc
   3ceec:	0004d783          	lhu	a5,0(s1)
   3cef0:	8f81                	c.sub	a5,s0
   3cef2:	944e                	c.add	s0,s3
   3cef4:	00f49023          	sh	a5,0(s1)
   3cef8:	00892023          	sw	s0,0(s2)
   3cefc:	400087b7          	lui	a5,0x40008
   3cf00:	03478023          	sb	s4,32(a5) # 0x40008020
   3cf04:	0227c703          	lbu	a4,34(a5)
   3cf08:	04074713          	xori	a4,a4,64
   3cf0c:	02e78123          	sb	a4,34(a5)
   3cf10:	bfb5                	c.j	0x3ce8c
   3cf12:	00344783          	lbu	a5,3(s0)
   3cf16:	200026b7          	lui	a3,0x20002
   3cf1a:	bcc6c683          	lbu	a3,-1076(a3) # 0x20001bcc
   3cf1e:	0807f793          	andi	a5,a5,128
   3cf22:	8fd5                	c.or	a5,a3
   3cf24:	00f401a3          	sb	a5,3(s0)
   3cf28:	02e40123          	sb	a4,34(s0)
   3cf2c:	b785                	c.j	0x3ce8c
   3cf2e:	02040023          	sb	zero,32(s0)
   3cf32:	bfdd                	c.j	0x3cf28
   3cf34:	02e40123          	sb	a4,34(s0)
   3cf38:	00e40323          	sb	a4,6(s0)
   3cf3c:	bd89                	c.j	0x3cd8e
   3cf3e:	0027d783          	lhu	a5,2(a5)
   3cf42:	20002937          	lui	s2,0x20002
   3cf46:	4705                	c.li	a4,1
   3cf48:	83a1                	c.srli	a5,0x8
   3cf4a:	bd890913          	addi	s2,s2,-1064 # 0x20001bd8
   3cf4e:	08e78163          	beq	a5,a4,0x3cfd0
   3cf52:	4709                	c.li	a4,2
   3cf54:	08e78763          	beq	a5,a4,0x3cfe2
   3cf58:	4a85                	c.li	s5,1
   3cf5a:	4781                	c.li	a5,0
   3cf5c:	0087f463          	bgeu	a5,s0,0x3cf64
   3cf60:	00f49023          	sh	a5,0(s1)
   3cf64:	0004d403          	lhu	s0,0(s1)
   3cf68:	04000793          	addi	a5,zero,64
   3cf6c:	0087f463          	bgeu	a5,s0,0x3cf74
   3cf70:	04000413          	addi	s0,zero,64
   3cf74:	00092a03          	lw	s4,0(s2)
   3cf78:	0442                	c.slli	s0,0x10
   3cf7a:	8041                	c.srli	s0,0x10
   3cf7c:	85d2                	c.mv	a1,s4
   3cf7e:	0ff47613          	andi	a2,s0,255
   3cf82:	e8c50513          	addi	a0,a0,-372
   3cf86:	fffff097          	auipc	ra,0xfffff
   3cf8a:	276080e7          	jalr	ra,630(ra) # 0x3c1fc
   3cf8e:	0004d783          	lhu	a5,0(s1)
   3cf92:	9a22                	c.add	s4,s0
   3cf94:	01492023          	sw	s4,0(s2)
   3cf98:	8f81                	c.sub	a5,s0
   3cf9a:	00f49023          	sh	a5,0(s1)
   3cf9e:	060a8363          	beq	s5,zero,0x3d004
   3cfa2:	57fd                	c.li	a5,-1
   3cfa4:	00f98023          	sb	a5,0(s3)
   3cfa8:	fcf00713          	addi	a4,zero,-49
   3cfac:	400087b7          	lui	a5,0x40008
   3cfb0:	02e78123          	sb	a4,34(a5) # 0x40008022
   3cfb4:	400087b7          	lui	a5,0x40008
   3cfb8:	4709                	c.li	a4,2
   3cfba:	00e78323          	sb	a4,6(a5) # 0x40008006
   3cfbe:	40f2                	c.lwsp	ra,28(sp)
   3cfc0:	4462                	c.lwsp	s0,24(sp)
   3cfc2:	44d2                	c.lwsp	s1,20(sp)
   3cfc4:	4942                	c.lwsp	s2,16(sp)
   3cfc6:	49b2                	c.lwsp	s3,12(sp)
   3cfc8:	4a22                	c.lwsp	s4,8(sp)
   3cfca:	4a92                	c.lwsp	s5,4(sp)
   3cfcc:	6105                	c.addi16sp	sp,32
   3cfce:	8082                	c.jr	ra
   3cfd0:	200027b7          	lui	a5,0x20002
   3cfd4:	b8478793          	addi	a5,a5,-1148 # 0x20001b84
   3cfd8:	00f92023          	sw	a5,0(s2)
   3cfdc:	4a81                	c.li	s5,0
   3cfde:	47c9                	c.li	a5,18
   3cfe0:	bfb5                	c.j	0x3cf5c
   3cfe2:	200027b7          	lui	a5,0x20002
   3cfe6:	b6478793          	addi	a5,a5,-1180 # 0x20001b64
   3cfea:	00f92023          	sw	a5,0(s2)
   3cfee:	4a81                	c.li	s5,0
   3cff0:	02000793          	addi	a5,zero,32
   3cff4:	b7a5                	c.j	0x3cf5c
   3cff6:	0027d703          	lhu	a4,2(a5)
   3cffa:	200027b7          	lui	a5,0x20002
   3cffe:	bce78623          	sb	a4,-1076(a5) # 0x20001bcc
   3d002:	4401                	c.li	s0,0
   3d004:	0ff47413          	andi	s0,s0,255
   3d008:	400087b7          	lui	a5,0x40008
   3d00c:	02878023          	sb	s0,32(a5) # 0x40008020
   3d010:	fc000713          	addi	a4,zero,-64
   3d014:	bf71                	c.j	0x3cfb0
   3d016:	20002737          	lui	a4,0x20002
   3d01a:	bcd74703          	lbu	a4,-1075(a4) # 0x20001bcd
   3d01e:	00e78023          	sb	a4,0(a5)
   3d022:	00803433          	sltu	s0,zero,s0
   3d026:	bff9                	c.j	0x3d004
   3d028:	0027d703          	lhu	a4,2(a5)
   3d02c:	200027b7          	lui	a5,0x20002
   3d030:	bce786a3          	sb	a4,-1075(a5) # 0x20001bcd
   3d034:	b7f9                	c.j	0x3d002
   3d036:	01f6f713          	andi	a4,a3,31
   3d03a:	4689                	c.li	a3,2
   3d03c:	f6d713e3          	bne	a4,a3,0x3cfa2
   3d040:	0047c783          	lbu	a5,4(a5)
   3d044:	04e78163          	beq	a5,a4,0x3d086
   3d048:	00f76c63          	bltu	a4,a5,0x3d060
   3d04c:	4705                	c.li	a4,1
   3d04e:	f4e79ae3          	bne	a5,a4,0x3cfa2
   3d052:	40008737          	lui	a4,0x40008
   3d056:	02674783          	lbu	a5,38(a4) # 0x40008026
   3d05a:	0737f793          	andi	a5,a5,115
   3d05e:	a099                	c.j	0x3d0a4
   3d060:	08100713          	addi	a4,zero,129
   3d064:	02e78863          	beq	a5,a4,0x3d094
   3d068:	08200713          	addi	a4,zero,130
   3d06c:	f2e79be3          	bne	a5,a4,0x3cfa2
   3d070:	40008737          	lui	a4,0x40008
   3d074:	02a74783          	lbu	a5,42(a4) # 0x4000802a
   3d078:	0bc7f793          	andi	a5,a5,188
   3d07c:	0027e793          	ori	a5,a5,2
   3d080:	02f70523          	sb	a5,42(a4)
   3d084:	bfbd                	c.j	0x3d002
   3d086:	40008737          	lui	a4,0x40008
   3d08a:	02a74783          	lbu	a5,42(a4) # 0x4000802a
   3d08e:	0737f793          	andi	a5,a5,115
   3d092:	b7fd                	c.j	0x3d080
   3d094:	40008737          	lui	a4,0x40008
   3d098:	02674783          	lbu	a5,38(a4) # 0x40008026
   3d09c:	0bc7f793          	andi	a5,a5,188
   3d0a0:	0027e793          	ori	a5,a5,2
   3d0a4:	02f70323          	sb	a5,38(a4)
   3d0a8:	bfa9                	c.j	0x3d002
   3d0aa:	00078023          	sb	zero,0(a5)
   3d0ae:	bf95                	c.j	0x3d022
   3d0b0:	00079023          	sh	zero,0(a5)
   3d0b4:	4709                	c.li	a4,2
   3d0b6:	87a2                	c.mv	a5,s0
   3d0b8:	00877363          	bgeu	a4,s0,0x3d0be
   3d0bc:	4789                	c.li	a5,2
   3d0be:	01079413          	slli	s0,a5,0x10
   3d0c2:	8041                	c.srli	s0,0x10
   3d0c4:	b781                	c.j	0x3d004
   3d0c6:	00644783          	lbu	a5,6(s0)
   3d0ca:	8b85                	c.andi	a5,1
   3d0cc:	cb8d                	c.beqz	a5,0x3d0fe
   3d0ce:	200027b7          	lui	a5,0x20002
   3d0d2:	bc0788a3          	sb	zero,-1071(a5) # 0x20001bd1
   3d0d6:	4789                	c.li	a5,2
   3d0d8:	02f40123          	sb	a5,34(s0)
   3d0dc:	47c9                	c.li	a5,18
   3d0de:	02f40523          	sb	a5,42(s0)
   3d0e2:	200027b7          	lui	a5,0x20002
   3d0e6:	bc078223          	sb	zero,-1084(a5) # 0x20001bc4
   3d0ea:	200027b7          	lui	a5,0x20002
   3d0ee:	bc0785a3          	sb	zero,-1077(a5) # 0x20001bcb
   3d0f2:	000401a3          	sb	zero,3(s0)
   3d0f6:	4785                	c.li	a5,1
   3d0f8:	00f40323          	sb	a5,6(s0)
   3d0fc:	b5c9                	c.j	0x3cfbe
   3d0fe:	4791                	c.li	a5,4
   3d100:	bfe5                	c.j	0x3d0f8
   3d102:	40001737          	lui	a4,0x40001
   3d106:	0a072023          	sw	zero,160(a4) # 0x400010a0
   3d10a:	00071d23          	sh	zero,26(a4)
   3d10e:	400087b7          	lui	a5,0x40008
   3d112:	00078023          	sb	zero,0(a5) # 0x40008000
   3d116:	000781a3          	sb	zero,3(a5)
   3d11a:	0b472683          	lw	a3,180(a4)
   3d11e:	660d                	c.lui	a2,0x3
   3d120:	9af5                	c.andi	a3,-3
   3d122:	0ad72a23          	sw	a3,180(a4)
   3d126:	46b1                	c.li	a3,12
   3d128:	00d786a3          	sb	a3,13(a5)
   3d12c:	200026b7          	lui	a3,0x20002
   3d130:	e8c68693          	addi	a3,a3,-372 # 0x20001e8c
   3d134:	06c2                	c.slli	a3,0x10
   3d136:	82c1                	c.srli	a3,0x10
   3d138:	00d79823          	sh	a3,16(a5)
   3d13c:	200026b7          	lui	a3,0x20002
   3d140:	e0868693          	addi	a3,a3,-504 # 0x20001e08
   3d144:	06c2                	c.slli	a3,0x10
   3d146:	82c1                	c.srli	a3,0x10
   3d148:	00d79c23          	sh	a3,24(a5)
   3d14c:	02900693          	addi	a3,zero,41
   3d150:	00d78023          	sb	a3,0(a5)
   3d154:	01875683          	lhu	a3,24(a4)
   3d158:	8ed1                	c.or	a3,a2
   3d15a:	00d71c23          	sh	a3,24(a4)
   3d15e:	f8000713          	addi	a4,zero,-128
   3d162:	00e780a3          	sb	a4,1(a5)
   3d166:	577d                	c.li	a4,-1
   3d168:	00e78323          	sb	a4,6(a5)
   3d16c:	471d                	c.li	a4,7
   3d16e:	00e78123          	sb	a4,2(a5)
   3d172:	0017c703          	lbu	a4,1(a5)
   3d176:	00176713          	ori	a4,a4,1
   3d17a:	00e780a3          	sb	a4,1(a5)
   3d17e:	200027b7          	lui	a5,0x20002
   3d182:	be078123          	sb	zero,-1054(a5) # 0x20001be2
   3d186:	200027b7          	lui	a5,0x20002
   3d18a:	be0780a3          	sb	zero,-1055(a5) # 0x20001be1
   3d18e:	8082                	c.jr	ra
   3d190:	200027b7          	lui	a5,0x20002
   3d194:	be078023          	sb	zero,-1056(a5) # 0x20001be0
   3d198:	4705                	c.li	a4,1
   3d19a:	400037b7          	lui	a5,0x40003
   3d19e:	40e78723          	sb	a4,1038(a5) # 0x4000340e
   3d1a2:	4769                	c.li	a4,26
   3d1a4:	40e79623          	sh	a4,1036(a5)
   3d1a8:	f8100713          	addi	a4,zero,-127
   3d1ac:	40e78123          	sb	a4,1026(a5)
   3d1b0:	470d                	c.li	a4,3
   3d1b2:	40e781a3          	sb	a4,1027(a5)
   3d1b6:	04500713          	addi	a4,zero,69
   3d1ba:	40e780a3          	sb	a4,1025(a5)
   3d1be:	4007c703          	lbu	a4,1024(a5)
   3d1c2:	00876713          	ori	a4,a4,8
   3d1c6:	40e78023          	sb	a4,1024(a5)
   3d1ca:	40001737          	lui	a4,0x40001
   3d1ce:	01a75783          	lhu	a5,26(a4) # 0x4000101a
   3d1d2:	07c2                	c.slli	a5,0x10
   3d1d4:	83c1                	c.srli	a5,0x10
   3d1d6:	fc07f793          	andi	a5,a5,-64
   3d1da:	07c2                	c.slli	a5,0x10
   3d1dc:	83c1                	c.srli	a5,0x10
   3d1de:	00f71d23          	sh	a5,26(a4)
   3d1e2:	01a75783          	lhu	a5,26(a4)
   3d1e6:	0127e793          	ori	a5,a5,18
   3d1ea:	00f71d23          	sh	a5,26(a4)
   3d1ee:	8082                	c.jr	ra
   3d1f0:	400017b7          	lui	a5,0x40001
   3d1f4:	0a07a703          	lw	a4,160(a5) # 0x400010a0
   3d1f8:	1141                	c.addi	sp,-16
   3d1fa:	c606                	c.swsp	ra,12(sp)
   3d1fc:	c422                	c.swsp	s0,8(sp)
   3d1fe:	c226                	c.swsp	s1,4(sp)
   3d200:	9b71                	c.andi	a4,-4
   3d202:	0ae7a023          	sw	a4,160(a5)
   3d206:	0b47a703          	lw	a4,180(a5)
   3d20a:	00276713          	ori	a4,a4,2
   3d20e:	0ae7aa23          	sw	a4,180(a5)
   3d212:	fffff097          	auipc	ra,0xfffff
   3d216:	fae080e7          	jalr	ra,-82(ra) # 0x3c1c0
   3d21a:	c90d                	c.beqz	a0,0x3d24c
   3d21c:	4401                	c.li	s0,0
   3d21e:	06300493          	addi	s1,zero,99
   3d222:	fffff097          	auipc	ra,0xfffff
   3d226:	f9e080e7          	jalr	ra,-98(ra) # 0x3c1c0
   3d22a:	cd01                	c.beqz	a0,0x3d242
   3d22c:	0405                	c.addi	s0,1
   3d22e:	fe84dae3          	bge	s1,s0,0x3d222
   3d232:	4422                	c.lwsp	s0,8(sp)
   3d234:	40b2                	c.lwsp	ra,12(sp)
   3d236:	4492                	c.lwsp	s1,4(sp)
   3d238:	0141                	c.addi	sp,16
   3d23a:	00000317          	auipc	t1,0x0
   3d23e:	ec830067          	jalr	zero,-312(t1) # 0x3d102
   3d242:	fffff097          	auipc	ra,0xfffff
   3d246:	f7e080e7          	jalr	ra,-130(ra) # 0x3c1c0
   3d24a:	fd61                	c.bnez	a0,0x3d222
   3d24c:	40b2                	c.lwsp	ra,12(sp)
   3d24e:	4422                	c.lwsp	s0,8(sp)
   3d250:	4492                	c.lwsp	s1,4(sp)
   3d252:	0141                	c.addi	sp,16
   3d254:	8082                	c.jr	ra
   3d256:	715d                	c.addi16sp	sp,-80
   3d258:	200027b7          	lui	a5,0x20002
   3d25c:	20002737          	lui	a4,0x20002
   3d260:	c0ca                	c.swsp	s2,64(sp)
   3d262:	be0781a3          	sb	zero,-1053(a5) # 0x20001be3
   3d266:	20002937          	lui	s2,0x20002
   3d26a:	4785                	c.li	a5,1
   3d26c:	bef900a3          	sb	a5,-1055(s2) # 0x20001be1
   3d270:	bcf70823          	sb	a5,-1072(a4) # 0x20001bd0
   3d274:	200027b7          	lui	a5,0x20002
   3d278:	dc52                	c.swsp	s4,56(sp)
   3d27a:	da56                	c.swsp	s5,52(sp)
   3d27c:	bc078323          	sb	zero,-1082(a5) # 0x20001bc6
   3d280:	20002a37          	lui	s4,0x20002
   3d284:	200027b7          	lui	a5,0x20002
   3d288:	0003fab7          	lui	s5,0x3f
   3d28c:	c2a6                	c.swsp	s1,68(sp)
   3d28e:	de4e                	c.swsp	s3,60(sp)
   3d290:	d65e                	c.swsp	s7,44(sp)
   3d292:	d462                	c.swsp	s8,40(sp)
   3d294:	200024b7          	lui	s1,0x20002
   3d298:	20002bb7          	lui	s7,0x20002
   3d29c:	200029b7          	lui	s3,0x20002
   3d2a0:	20002c37          	lui	s8,0x20002
   3d2a4:	ba07a623          	sw	zero,-1108(a5) # 0x20001bac
   3d2a8:	46b1                	c.li	a3,12
   3d2aa:	200027b7          	lui	a5,0x20002
   3d2ae:	be4a0613          	addi	a2,s4,-1052 # 0x20001be4
   3d2b2:	ff4a8593          	addi	a1,s5,-12 # 0x3eff4
   3d2b6:	4535                	c.li	a0,13
   3d2b8:	c4a2                	c.swsp	s0,72(sp)
   3d2ba:	be048123          	sb	zero,-1054(s1) # 0x20001be2
   3d2be:	bc0b82a3          	sb	zero,-1083(s7) # 0x20001bc5
   3d2c2:	bc098723          	sb	zero,-1074(s3) # 0x20001bce
   3d2c6:	bc0c08a3          	sb	zero,-1071(s8) # 0x20001bd1
   3d2ca:	ba07a823          	sw	zero,-1104(a5) # 0x20001bb0
   3d2ce:	c686                	c.swsp	ra,76(sp)
   3d2d0:	d85a                	c.swsp	s6,48(sp)
   3d2d2:	d266                	c.swsp	s9,36(sp)
   3d2d4:	d06a                	c.swsp	s10,32(sp)
   3d2d6:	ce6e                	c.swsp	s11,28(sp)
   3d2d8:	be4a0413          	addi	s0,s4,-1052
   3d2dc:	00000097          	auipc	ra,0x0
   3d2e0:	51c080e7          	jalr	ra,1308(ra) # 0x3d7f8
   3d2e4:	401c                	c.lw	a5,0(s0)
   3d2e6:	577d                	c.li	a4,-1
   3d2e8:	be248493          	addi	s1,s1,-1054
   3d2ec:	be190913          	addi	s2,s2,-1055
   3d2f0:	bc5b8b93          	addi	s7,s7,-1083
   3d2f4:	bce98993          	addi	s3,s3,-1074
   3d2f8:	bd1c0c13          	addi	s8,s8,-1071
   3d2fc:	28e79563          	bne	a5,a4,0x3d586
   3d300:	4054                	c.lw	a3,4(s0)
   3d302:	4418                	c.lw	a4,8(s0)
   3d304:	8f75                	c.and	a4,a3
   3d306:	00f70e63          	beq	a4,a5,0x3d322
   3d30a:	26f69e63          	bne	a3,a5,0x3d586
   3d30e:	4691                	c.li	a3,4
   3d310:	00840613          	addi	a2,s0,8
   3d314:	ffca8593          	addi	a1,s5,-4
   3d318:	4531                	c.li	a0,12
   3d31a:	00000097          	auipc	ra,0x0
   3d31e:	4de080e7          	jalr	ra,1246(ra) # 0x3d7f8
   3d322:	20002b37          	lui	s6,0x20002
   3d326:	4691                	c.li	a3,4
   3d328:	ba0b0613          	addi	a2,s6,-1120 # 0x20001ba0
   3d32c:	45d1                	c.li	a1,20
   3d32e:	4531                	c.li	a0,12
   3d330:	00000097          	auipc	ra,0x0
   3d334:	4c8080e7          	jalr	ra,1224(ra) # 0x3d7f8
   3d338:	ba0b0a93          	addi	s5,s6,-1120
   3d33c:	000aa783          	lw	a5,0(s5)
   3d340:	ba0b0d93          	addi	s11,s6,-1120
   3d344:	0187d713          	srli	a4,a5,0x18
   3d348:	8f3d                	c.xor	a4,a5
   3d34a:	fff74713          	xori	a4,a4,-1
   3d34e:	0ff77713          	andi	a4,a4,255
   3d352:	eb09                	c.bnez	a4,0x3d364
   3d354:	00f00737          	lui	a4,0xf00
   3d358:	8f7d                	c.and	a4,a5
   3d35a:	005006b7          	lui	a3,0x500
   3d35e:	83a1                	c.srli	a5,0x8
   3d360:	00d70363          	beq	a4,a3,0x3d366
   3d364:	405c                	c.lw	a5,4(s0)
   3d366:	0003f6b7          	lui	a3,0x3f
   3d36a:	4ad0                	c.lw	a2,20(a3)
   3d36c:	20002737          	lui	a4,0x20002
   3d370:	bbc70713          	addi	a4,a4,-1092 # 0x20001bbc
   3d374:	00c70023          	sb	a2,0(a4)
   3d378:	4e90                	c.lw	a2,24(a3)
   3d37a:	8b85                	c.andi	a5,1
   3d37c:	00c700a3          	sb	a2,1(a4)
   3d380:	20002737          	lui	a4,0x20002
   3d384:	03c00613          	addi	a2,zero,60
   3d388:	bac72a23          	sw	a2,-1100(a4) # 0x20001bb4
   3d38c:	52d8                	c.lw	a4,36(a3)
   3d38e:	200026b7          	lui	a3,0x20002
   3d392:	bee6a823          	sw	a4,-1040(a3) # 0x20001bf0
   3d396:	8b3d                	c.andi	a4,15
   3d398:	4695                	c.li	a3,5
   3d39a:	00d71563          	bne	a4,a3,0x3d3a4
   3d39e:	4705                	c.li	a4,1
   3d3a0:	00e98023          	sb	a4,0(s3)
   3d3a4:	400016b7          	lui	a3,0x40001
   3d3a8:	0186d603          	lhu	a2,24(a3) # 0x40001018
   3d3ac:	7771                	c.lui	a4,0xffffc
   3d3ae:	177d                	c.addi	a4,-1 # 0xffffbfff
   3d3b0:	8f71                	c.and	a4,a2
   3d3b2:	00e69c23          	sh	a4,24(a3)
   3d3b6:	1c078f63          	beq	a5,zero,0x3d594
   3d3ba:	00000097          	auipc	ra,0x0
   3d3be:	dd6080e7          	jalr	ra,-554(ra) # 0x3d190
   3d3c2:	57e9                	c.li	a5,-6
   3d3c4:	00f48023          	sb	a5,0(s1)
   3d3c8:	00090023          	sb	zero,0(s2)
   3d3cc:	400027b7          	lui	a5,0x40002
   3d3d0:	4709                	c.li	a4,2
   3d3d2:	40e78023          	sb	a4,1024(a5) # 0x40002400
   3d3d6:	000ea737          	lui	a4,0xea
   3d3da:	60070713          	addi	a4,a4,1536 # 0xea600
   3d3de:	40e7a623          	sw	a4,1036(a5)
   3d3e2:	56fd                	c.li	a3,-1
   3d3e4:	40d78323          	sb	a3,1030(a5)
   3d3e8:	4027c683          	lbu	a3,1026(a5)
   3d3ec:	20002ab7          	lui	s5,0x20002
   3d3f0:	4d01                	c.li	s10,0
   3d3f2:	0016e693          	ori	a3,a3,1
   3d3f6:	40d78123          	sb	a3,1026(a5)
   3d3fa:	4691                	c.li	a3,4
   3d3fc:	40d78023          	sb	a3,1024(a5)
   3d400:	67ad                	c.lui	a5,0xb
   3d402:	aaa78793          	addi	a5,a5,-1366 # 0xaaaa
   3d406:	4c85                	c.li	s9,1
   3d408:	df0a8a93          	addi	s5,s5,-528 # 0x20001df0
   3d40c:	c43a                	c.swsp	a4,8(sp)
   3d40e:	c63e                	c.swsp	a5,12(sp)
   3d410:	00094783          	lbu	a5,0(s2)
   3d414:	21979563          	bne	a5,s9,0x3d61e
   3d418:	1a0d0063          	beq	s10,zero,0x3d5b8
   3d41c:	4691                	c.li	a3,4
   3d41e:	ba0b0613          	addi	a2,s6,-1120
   3d422:	45d1                	c.li	a1,20
   3d424:	4531                	c.li	a0,12
   3d426:	00000097          	auipc	ra,0x0
   3d42a:	3d2080e7          	jalr	ra,978(ra) # 0x3d7f8
   3d42e:	000da703          	lw	a4,0(s11)
   3d432:	01875793          	srli	a5,a4,0x18
   3d436:	8fb9                	c.xor	a5,a4
   3d438:	fff7c793          	xori	a5,a5,-1
   3d43c:	0ff7f793          	andi	a5,a5,255
   3d440:	eff5                	c.bnez	a5,0x3d53c
   3d442:	200024b7          	lui	s1,0x20002
   3d446:	0003f5b7          	lui	a1,0x3f
   3d44a:	46b1                	c.li	a3,12
   3d44c:	df048613          	addi	a2,s1,-528 # 0x20001df0
   3d450:	15d1                	c.addi	a1,-12 # 0x3eff4
   3d452:	4531                	c.li	a0,12
   3d454:	00000097          	auipc	ra,0x0
   3d458:	3a4080e7          	jalr	ra,932(ra) # 0x3d7f8
   3d45c:	000dc703          	lbu	a4,0(s11)
   3d460:	04000793          	addi	a5,zero,64
   3d464:	0d077693          	andi	a3,a4,208
   3d468:	00f69e63          	bne	a3,a5,0x3d484
   3d46c:	441c                	c.lw	a5,8(s0)
   3d46e:	0ff7f693          	andi	a3,a5,255
   3d472:	00e68963          	beq	a3,a4,0x3d484
   3d476:	f007f793          	andi	a5,a5,-256
   3d47a:	8fd9                	c.or	a5,a4
   3d47c:	c41c                	c.sw	a5,8(s0)
   3d47e:	4785                	c.li	a5,1
   3d480:	00fb8023          	sb	a5,0(s7)
   3d484:	df048493          	addi	s1,s1,-528
   3d488:	4498                	c.lw	a4,8(s1)
   3d48a:	441c                	c.lw	a5,8(s0)
   3d48c:	0af70863          	beq	a4,a5,0x3d53c
   3d490:	400017b7          	lui	a5,0x40001
   3d494:	05700713          	addi	a4,zero,87
   3d498:	04e78023          	sb	a4,64(a5) # 0x40001040
   3d49c:	fa800713          	addi	a4,zero,-88
   3d4a0:	04e78023          	sb	a4,64(a5)
   3d4a4:	0447c703          	lbu	a4,68(a5)
   3d4a8:	4681                	c.li	a3,0
   3d4aa:	4601                	c.li	a2,0
   3d4ac:	02076713          	ori	a4,a4,32
   3d4b0:	04e78223          	sb	a4,68(a5)
   3d4b4:	4581                	c.li	a1,0
   3d4b6:	04078023          	sb	zero,64(a5)
   3d4ba:	4511                	c.li	a0,4
   3d4bc:	00000097          	auipc	ra,0x0
   3d4c0:	33c080e7          	jalr	ra,828(ra) # 0x3d7f8
   3d4c4:	6685                	c.lui	a3,0x1
   3d4c6:	4601                	c.li	a2,0
   3d4c8:	0003e5b7          	lui	a1,0x3e
   3d4cc:	4505                	c.li	a0,1
   3d4ce:	00000097          	auipc	ra,0x0
   3d4d2:	32a080e7          	jalr	ra,810(ra) # 0x3d7f8
   3d4d6:	e90d                	c.bnez	a0,0x3d508
   3d4d8:	441c                	c.lw	a5,8(s0)
   3d4da:	40000737          	lui	a4,0x40000
   3d4de:	0003f5b7          	lui	a1,0x3f
   3d4e2:	0792                	c.slli	a5,0x4
   3d4e4:	8391                	c.srli	a5,0x4
   3d4e6:	8fd9                	c.or	a5,a4
   3d4e8:	0087d713          	srli	a4,a5,0x8
   3d4ec:	c41c                	c.sw	a5,8(s0)
   3d4ee:	46b1                	c.li	a3,12
   3d4f0:	0c077793          	andi	a5,a4,192
   3d4f4:	be4a0613          	addi	a2,s4,-1052
   3d4f8:	15d1                	c.addi	a1,-12 # 0x3eff4
   3d4fa:	4509                	c.li	a0,2
   3d4fc:	00f404a3          	sb	a5,9(s0)
   3d500:	00000097          	auipc	ra,0x0
   3d504:	2f8080e7          	jalr	ra,760(ra) # 0x3d7f8
   3d508:	4681                	c.li	a3,0
   3d50a:	4601                	c.li	a2,0
   3d50c:	4581                	c.li	a1,0
   3d50e:	4511                	c.li	a0,4
   3d510:	00000097          	auipc	ra,0x0
   3d514:	2e8080e7          	jalr	ra,744(ra) # 0x3d7f8
   3d518:	400017b7          	lui	a5,0x40001
   3d51c:	05700713          	addi	a4,zero,87
   3d520:	04e78023          	sb	a4,64(a5) # 0x40001040
   3d524:	fa800713          	addi	a4,zero,-88
   3d528:	04e78023          	sb	a4,64(a5)
   3d52c:	0447c703          	lbu	a4,68(a5)
   3d530:	0df77713          	andi	a4,a4,223
   3d534:	04e78223          	sb	a4,68(a5)
   3d538:	04078023          	sb	zero,64(a5)
   3d53c:	40001437          	lui	s0,0x40001
   3d540:	00041d23          	sh	zero,26(s0) # 0x4000101a
   3d544:	4681                	c.li	a3,0
   3d546:	4601                	c.li	a2,0
   3d548:	4581                	c.li	a1,0
   3d54a:	4511                	c.li	a0,4
   3d54c:	00000097          	auipc	ra,0x0
   3d550:	2ac080e7          	jalr	ra,684(ra) # 0x3d7f8
   3d554:	05700793          	addi	a5,zero,87
   3d558:	04f40023          	sb	a5,64(s0)
   3d55c:	fa800793          	addi	a5,zero,-88
   3d560:	04f40023          	sb	a5,64(s0)
   3d564:	000bc783          	lbu	a5,0(s7)
   3d568:	c781                	c.beqz	a5,0x3d570
   3d56a:	57fd                	c.li	a5,-1
   3d56c:	02f41623          	sh	a5,44(s0)
   3d570:	400017b7          	lui	a5,0x40001
   3d574:	0467c703          	lbu	a4,70(a5) # 0x40001046
   3d578:	00176713          	ori	a4,a4,1
   3d57c:	04e78323          	sb	a4,70(a5)
   3d580:	04078023          	sb	zero,64(a5)
   3d584:	a001                	c.j	0x3d584
   3d586:	0003f5b7          	lui	a1,0x3f
   3d58a:	46b1                	c.li	a3,12
   3d58c:	be4a0613          	addi	a2,s4,-1052
   3d590:	15d1                	c.addi	a1,-12 # 0x3eff4
   3d592:	b359                	c.j	0x3d318
   3d594:	0009c783          	lbu	a5,0(s3)
   3d598:	e2079ae3          	bne	a5,zero,0x3d3cc
   3d59c:	0466c783          	lbu	a5,70(a3) # 0x1046
   3d5a0:	8b85                	c.andi	a5,1
   3d5a2:	c791                	c.beqz	a5,0x3d5ae
   3d5a4:	00000097          	auipc	ra,0x0
   3d5a8:	b5e080e7          	jalr	ra,-1186(ra) # 0x3d102
   3d5ac:	b505                	c.j	0x3d3cc
   3d5ae:	00000097          	auipc	ra,0x0
   3d5b2:	c42080e7          	jalr	ra,-958(ra) # 0x3d1f0
   3d5b6:	bd19                	c.j	0x3d3cc
   3d5b8:	46c1                	c.li	a3,16
   3d5ba:	8656                	c.mv	a2,s5
   3d5bc:	4581                	c.li	a1,0
   3d5be:	4535                	c.li	a0,13
   3d5c0:	00000097          	auipc	ra,0x0
   3d5c4:	238080e7          	jalr	ra,568(ra) # 0x3d7f8
   3d5c8:	004aa703          	lw	a4,4(s5)
   3d5cc:	000aa783          	lw	a5,0(s5)
   3d5d0:	8ff9                	c.and	a5,a4
   3d5d2:	008aa703          	lw	a4,8(s5)
   3d5d6:	8ff9                	c.and	a5,a4
   3d5d8:	00caa703          	lw	a4,12(s5)
   3d5dc:	8ff9                	c.and	a5,a4
   3d5de:	577d                	c.li	a4,-1
   3d5e0:	0ce79e63          	bne	a5,a4,0x3d6bc
   3d5e4:	0009c783          	lbu	a5,0(s3)
   3d5e8:	e395                	c.bnez	a5,0x3d60c
   3d5ea:	00000097          	auipc	ra,0x0
   3d5ee:	b18080e7          	jalr	ra,-1256(ra) # 0x3d102
   3d5f2:	4722                	c.lwsp	a4,8(sp)
   3d5f4:	400027b7          	lui	a5,0x40002
   3d5f8:	40e7a623          	sw	a4,1036(a5) # 0x4000240c
   3d5fc:	41978323          	sb	s9,1030(a5)
   3d600:	019c0023          	sb	s9,0(s8)
   3d604:	00094783          	lbu	a5,0(s2)
   3d608:	cb91                	c.beqz	a5,0x3d61c
   3d60a:	bd09                	c.j	0x3d41c
   3d60c:	00000097          	auipc	ra,0x0
   3d610:	b84080e7          	jalr	ra,-1148(ra) # 0x3d190
   3d614:	00048023          	sb	zero,0(s1)
   3d618:	00090023          	sb	zero,0(s2)
   3d61c:	4d05                	c.li	s10,1
   3d61e:	0009c783          	lbu	a5,0(s3)
   3d622:	eb99                	c.bnez	a5,0x3d638
   3d624:	400087b7          	lui	a5,0x40008
   3d628:	0067c783          	lbu	a5,6(a5) # 0x40008006
   3d62c:	8b9d                	c.andi	a5,7
   3d62e:	c789                	c.beqz	a5,0x3d638
   3d630:	fffff097          	auipc	ra,0xfffff
   3d634:	72a080e7          	jalr	ra,1834(ra) # 0x3cd5a
   3d638:	400037b7          	lui	a5,0x40003
   3d63c:	4057c783          	lbu	a5,1029(a5) # 0x40003405
   3d640:	8b85                	c.andi	a5,1
   3d642:	c39d                	c.beqz	a5,0x3d668
   3d644:	400017b7          	lui	a5,0x40001
   3d648:	0a87a703          	lw	a4,168(a5) # 0x400010a8
   3d64c:	00276713          	ori	a4,a4,2
   3d650:	0ae7a423          	sw	a4,168(a5)
   3d654:	0a07a703          	lw	a4,160(a5)
   3d658:	00276713          	ori	a4,a4,2
   3d65c:	0ae7a023          	sw	a4,160(a5)
   3d660:	fffff097          	auipc	ra,0xfffff
   3d664:	512080e7          	jalr	ra,1298(ra) # 0x3cb72
   3d668:	400026b7          	lui	a3,0x40002
   3d66c:	4066c783          	lbu	a5,1030(a3) # 0x40002406
   3d670:	8b85                	c.andi	a5,1
   3d672:	cf99                	c.beqz	a5,0x3d690
   3d674:	4705                	c.li	a4,1
   3d676:	40e68323          	sb	a4,1030(a3)
   3d67a:	0004c783          	lbu	a5,0(s1)
   3d67e:	0f900693          	addi	a3,zero,249
   3d682:	00f6f463          	bgeu	a3,a5,0x3d68a
   3d686:	00e90023          	sb	a4,0(s2)
   3d68a:	0785                	c.addi	a5,1
   3d68c:	00f48023          	sb	a5,0(s1)
   3d690:	000c4783          	lbu	a5,0(s8)
   3d694:	01979f63          	bne	a5,s9,0x3d6b2
   3d698:	0004c783          	lbu	a5,0(s1)
   3d69c:	0c200713          	addi	a4,zero,194
   3d6a0:	17ed                	c.addi	a5,-5
   3d6a2:	0ff7f793          	andi	a5,a5,255
   3d6a6:	00f76663          	bltu	a4,a5,0x3d6b2
   3d6aa:	00000097          	auipc	ra,0x0
   3d6ae:	50a080e7          	jalr	ra,1290(ra) # 0x3dbb4
   3d6b2:	4732                	c.lwsp	a4,12(sp)
   3d6b4:	400017b7          	lui	a5,0x40001
   3d6b8:	c398                	c.sw	a4,0(a5)
   3d6ba:	bb99                	c.j	0x3d410
   3d6bc:	0009c783          	lbu	a5,0(s3)
   3d6c0:	f3b1                	c.bnez	a5,0x3d604
   3d6c2:	400017b7          	lui	a5,0x40001
   3d6c6:	0467c783          	lbu	a5,70(a5) # 0x40001046
   3d6ca:	8b85                	c.andi	a5,1
   3d6cc:	c791                	c.beqz	a5,0x3d6d8
   3d6ce:	00000097          	auipc	ra,0x0
   3d6d2:	a34080e7          	jalr	ra,-1484(ra) # 0x3d102
   3d6d6:	b73d                	c.j	0x3d604
   3d6d8:	00000097          	auipc	ra,0x0
   3d6dc:	b18080e7          	jalr	ra,-1256(ra) # 0x3d1f0
   3d6e0:	b715                	c.j	0x3d604
   3d6e2:	80040323          	sb	zero,-2042(s0)
   3d6e6:	4715                	c.li	a4,5
   3d6e8:	87a2                	c.mv	a5,s0
   3d6ea:	80e40323          	sb	a4,-2042(s0)
   3d6ee:	0001                	c.addi	zero,0
   3d6f0:	80a40223          	sb	a0,-2044(s0)
   3d6f4:	8067c703          	lbu	a4,-2042(a5)
   3d6f8:	0762                	c.slli	a4,0x18
   3d6fa:	8761                	c.srai	a4,0x18
   3d6fc:	fe074ce3          	blt	a4,zero,0x3d6f4
   3d700:	80a78223          	sb	a0,-2044(a5)
   3d704:	8082                	c.jr	ra
   3d706:	80040323          	sb	zero,-2042(s0)
   3d70a:	4715                	c.li	a4,5
   3d70c:	80e40323          	sb	a4,-2042(s0)
   3d710:	0001                	c.addi	zero,0
   3d712:	80a40223          	sb	a0,-2044(s0)
   3d716:	8082                	c.jr	ra
   3d718:	80640783          	lb	a5,-2042(s0)
   3d71c:	fe07cee3          	blt	a5,zero,0x3d718
   3d720:	80040323          	sb	zero,-2042(s0)
   3d724:	8082                	c.jr	ra
   3d726:	80640783          	lb	a5,-2042(s0)
   3d72a:	fe07cee3          	blt	a5,zero,0x3d726
   3d72e:	80444503          	lbu	a0,-2044(s0)
   3d732:	8082                	c.jr	ra
   3d734:	80640783          	lb	a5,-2042(s0)
   3d738:	fe07cee3          	blt	a5,zero,0x3d734
   3d73c:	80a40223          	sb	a0,-2044(s0)
   3d740:	8082                	c.jr	ra
   3d742:	1141                	c.addi	sp,-16
   3d744:	c426                	c.swsp	s1,8(sp)
   3d746:	c24a                	c.swsp	s2,4(sp)
   3d748:	c04e                	c.swsp	s3,0(sp)
   3d74a:	c606                	c.swsp	ra,12(sp)
   3d74c:	0bf57713          	andi	a4,a0,191
   3d750:	47ad                	c.li	a5,11
   3d752:	89aa                	c.mv	s3,a0
   3d754:	892e                	c.mv	s2,a1
   3d756:	4495                	c.li	s1,5
   3d758:	00f70c63          	beq	a4,a5,0x3d770
   3d75c:	4519                	c.li	a0,6
   3d75e:	00000097          	auipc	ra,0x0
   3d762:	fa8080e7          	jalr	ra,-88(ra) # 0x3d706
   3d766:	00000097          	auipc	ra,0x0
   3d76a:	fb2080e7          	jalr	ra,-78(ra) # 0x3d718
   3d76e:	448d                	c.li	s1,3
   3d770:	854e                	c.mv	a0,s3
   3d772:	00000097          	auipc	ra,0x0
   3d776:	f94080e7          	jalr	ra,-108(ra) # 0x3d706
   3d77a:	59fd                	c.li	s3,-1
   3d77c:	14fd                	c.addi	s1,-1
   3d77e:	01349863          	bne	s1,s3,0x3d78e
   3d782:	40b2                	c.lwsp	ra,12(sp)
   3d784:	44a2                	c.lwsp	s1,8(sp)
   3d786:	4912                	c.lwsp	s2,4(sp)
   3d788:	4982                	c.lwsp	s3,0(sp)
   3d78a:	0141                	c.addi	sp,16
   3d78c:	8082                	c.jr	ra
   3d78e:	01095513          	srli	a0,s2,0x10
   3d792:	0ff57513          	andi	a0,a0,255
   3d796:	00000097          	auipc	ra,0x0
   3d79a:	f9e080e7          	jalr	ra,-98(ra) # 0x3d734
   3d79e:	0922                	c.slli	s2,0x8
   3d7a0:	bff1                	c.j	0x3d77c
   3d7a2:	1101                	c.addi	sp,-32
   3d7a4:	cc26                	c.swsp	s1,24(sp)
   3d7a6:	ce06                	c.swsp	ra,28(sp)
   3d7a8:	000804b7          	lui	s1,0x80
   3d7ac:	00000097          	auipc	ra,0x0
   3d7b0:	f6c080e7          	jalr	ra,-148(ra) # 0x3d718
   3d7b4:	4515                	c.li	a0,5
   3d7b6:	00000097          	auipc	ra,0x0
   3d7ba:	f50080e7          	jalr	ra,-176(ra) # 0x3d706
   3d7be:	00000097          	auipc	ra,0x0
   3d7c2:	f68080e7          	jalr	ra,-152(ra) # 0x3d726
   3d7c6:	00000097          	auipc	ra,0x0
   3d7ca:	f60080e7          	jalr	ra,-160(ra) # 0x3d726
   3d7ce:	c62a                	c.swsp	a0,12(sp)
   3d7d0:	00000097          	auipc	ra,0x0
   3d7d4:	f48080e7          	jalr	ra,-184(ra) # 0x3d718
   3d7d8:	4532                	c.lwsp	a0,12(sp)
   3d7da:	00157793          	andi	a5,a0,1
   3d7de:	eb89                	c.bnez	a5,0x3d7f0
   3d7e0:	00156513          	ori	a0,a0,1
   3d7e4:	0ff57513          	andi	a0,a0,255
   3d7e8:	40f2                	c.lwsp	ra,28(sp)
   3d7ea:	44e2                	c.lwsp	s1,24(sp)
   3d7ec:	6105                	c.addi16sp	sp,32
   3d7ee:	8082                	c.jr	ra
   3d7f0:	14fd                	c.addi	s1,-1 # 0x7ffff
   3d7f2:	f0e9                	c.bnez	s1,0x3d7b4
   3d7f4:	4501                	c.li	a0,0
   3d7f6:	bfcd                	c.j	0x3d7e8
   3d7f8:	7179                	c.addi16sp	sp,-48
   3d7fa:	d426                	c.swsp	s1,40(sp)
   3d7fc:	d24a                	c.swsp	s2,36(sp)
   3d7fe:	d04e                	c.swsp	s3,32(sp)
   3d800:	c85e                	c.swsp	s7,16(sp)
   3d802:	d606                	c.swsp	ra,44(sp)
   3d804:	ce52                	c.swsp	s4,28(sp)
   3d806:	cc56                	c.swsp	s5,24(sp)
   3d808:	ca5a                	c.swsp	s6,20(sp)
   3d80a:	89aa                	c.mv	s3,a0
   3d80c:	8bae                	c.mv	s7,a1
   3d80e:	8932                	c.mv	s2,a2
   3d810:	84b6                	c.mv	s1,a3
   3d812:	c622                	c.swsp	s0,12(sp)
   3d814:	40002437          	lui	s0,0x40002
   3d818:	e000e7b7          	lui	a5,0xe000e
   3d81c:	577d                	c.li	a4,-1
   3d81e:	0007aa83          	lw	s5,0(a5) # 0xe000e000
   3d822:	0047aa03          	lw	s4,4(a5)
   3d826:	18e7a023          	sw	a4,384(a5)
   3d82a:	18e7a223          	sw	a4,388(a5)
   3d82e:	40001b37          	lui	s6,0x40001
   3d832:	05700793          	addi	a5,zero,87
   3d836:	04fb0023          	sb	a5,64(s6) # 0x40001040
   3d83a:	fa800793          	addi	a5,zero,-88
   3d83e:	04fb0023          	sb	a5,64(s6)
   3d842:	044b4783          	lbu	a5,68(s6)
   3d846:	4711                	c.li	a4,4
   3d848:	0ff00513          	addi	a0,zero,255
   3d84c:	0e07e793          	ori	a5,a5,224
   3d850:	04fb0223          	sb	a5,68(s6)
   3d854:	80e40323          	sb	a4,-2042(s0) # 0x40001806
   3d858:	00000097          	auipc	ra,0x0
   3d85c:	e8a080e7          	jalr	ra,-374(ra) # 0x3d6e2
   3d860:	00000097          	auipc	ra,0x0
   3d864:	eb8080e7          	jalr	ra,-328(ra) # 0x3d718
   3d868:	ff798793          	addi	a5,s3,-9
   3d86c:	0ff7f793          	andi	a5,a5,255
   3d870:	4709                	c.li	a4,2
   3d872:	12f76f63          	bltu	a4,a5,0x3d9b0
   3d876:	000347b7          	lui	a5,0x34
   3d87a:	9bbe                	c.add	s7,a5
   3d87c:	0003c737          	lui	a4,0x3c
   3d880:	5579                	c.li	a0,-2
   3d882:	04ebfa63          	bgeu	s7,a4,0x3d8d6
   3d886:	009b87b3          	add	a5,s7,s1
   3d88a:	04f76663          	bltu	a4,a5,0x3d8d6
   3d88e:	47a9                	c.li	a5,10
   3d890:	08f99363          	bne	s3,a5,0x3d916
   3d894:	e881                	c.bnez	s1,0x3d8a4
   3d896:	4481                	c.li	s1,0
   3d898:	00000097          	auipc	ra,0x0
   3d89c:	e80080e7          	jalr	ra,-384(ra) # 0x3d718
   3d8a0:	8526                	c.mv	a0,s1
   3d8a2:	a815                	c.j	0x3d8d6
   3d8a4:	85de                	c.mv	a1,s7
   3d8a6:	4509                	c.li	a0,2
   3d8a8:	00000097          	auipc	ra,0x0
   3d8ac:	e9a080e7          	jalr	ra,-358(ra) # 0x3d742
   3d8b0:	0905                	c.addi	s2,1
   3d8b2:	fff94503          	lbu	a0,-1(s2)
   3d8b6:	14fd                	c.addi	s1,-1
   3d8b8:	0b85                	c.addi	s7,1
   3d8ba:	00000097          	auipc	ra,0x0
   3d8be:	e7a080e7          	jalr	ra,-390(ra) # 0x3d734
   3d8c2:	c481                	c.beqz	s1,0x3d8ca
   3d8c4:	0ffbf793          	andi	a5,s7,255
   3d8c8:	f7e5                	c.bnez	a5,0x3d8b0
   3d8ca:	00000097          	auipc	ra,0x0
   3d8ce:	ed8080e7          	jalr	ra,-296(ra) # 0x3d7a2
   3d8d2:	f169                	c.bnez	a0,0x3d894
   3d8d4:	557d                	c.li	a0,-1
   3d8d6:	400017b7          	lui	a5,0x40001
   3d8da:	05700713          	addi	a4,zero,87
   3d8de:	04e78023          	sb	a4,64(a5) # 0x40001040
   3d8e2:	fa800713          	addi	a4,zero,-88
   3d8e6:	04e78023          	sb	a4,64(a5)
   3d8ea:	0447c703          	lbu	a4,68(a5)
   3d8ee:	8b41                	c.andi	a4,16
   3d8f0:	04e78223          	sb	a4,68(a5)
   3d8f4:	e000e7b7          	lui	a5,0xe000e
   3d8f8:	1157a023          	sw	s5,256(a5) # 0xe000e100
   3d8fc:	1147a223          	sw	s4,260(a5)
   3d900:	4432                	c.lwsp	s0,12(sp)
   3d902:	50b2                	c.lwsp	ra,44(sp)
   3d904:	54a2                	c.lwsp	s1,40(sp)
   3d906:	5912                	c.lwsp	s2,36(sp)
   3d908:	5982                	c.lwsp	s3,32(sp)
   3d90a:	4a72                	c.lwsp	s4,28(sp)
   3d90c:	4ae2                	c.lwsp	s5,24(sp)
   3d90e:	4b52                	c.lwsp	s6,20(sp)
   3d910:	4bc2                	c.lwsp	s7,16(sp)
   3d912:	6145                	c.addi16sp	sp,48
   3d914:	8082                	c.jr	ra
   3d916:	47a5                	c.li	a5,9
   3d918:	06f99b63          	bne	s3,a5,0x3d98e
   3d91c:	6985                	c.lui	s3,0x1
   3d91e:	0ff00913          	addi	s2,zero,255
   3d922:	009906b3          	add	a3,s2,s1
   3d926:	012bf4b3          	and	s1,s7,s2
   3d92a:	94b6                	c.add	s1,a3
   3d92c:	fff94913          	xori	s2,s2,-1
   3d930:	009974b3          	and	s1,s2,s1
   3d934:	6b41                	c.lui	s6,0x10
   3d936:	01797933          	and	s2,s2,s7
   3d93a:	6b85                	c.lui	s7,0x1
   3d93c:	fff98793          	addi	a5,s3,-1 # 0xfff
   3d940:	0127f7b3          	and	a5,a5,s2
   3d944:	e399                	c.bnez	a5,0x3d94a
   3d946:	0134fc63          	bgeu	s1,s3,0x3d95e
   3d94a:	0049d993          	srli	s3,s3,0x4
   3d94e:	47c1                	c.li	a5,16
   3d950:	ff37e6e3          	bltu	a5,s3,0x3d93c
   3d954:	b789                	c.j	0x3d896
   3d956:	6905                	c.lui	s2,0x1
   3d958:	69c1                	c.lui	s3,0x10
   3d95a:	197d                	c.addi	s2,-1 # 0xfff
   3d95c:	b7d9                	c.j	0x3d922
   3d95e:	0d800513          	addi	a0,zero,216
   3d962:	01698863          	beq	s3,s6,0x3d972
   3d966:	02000513          	addi	a0,zero,32
   3d96a:	01798463          	beq	s3,s7,0x3d972
   3d96e:	08100513          	addi	a0,zero,129
   3d972:	85ca                	c.mv	a1,s2
   3d974:	00000097          	auipc	ra,0x0
   3d978:	dce080e7          	jalr	ra,-562(ra) # 0x3d742
   3d97c:	00000097          	auipc	ra,0x0
   3d980:	e26080e7          	jalr	ra,-474(ra) # 0x3d7a2
   3d984:	d921                	c.beqz	a0,0x3d8d4
   3d986:	994e                	c.add	s2,s3
   3d988:	413484b3          	sub	s1,s1,s3
   3d98c:	bf6d                	c.j	0x3d946
   3d98e:	85de                	c.mv	a1,s7
   3d990:	452d                	c.li	a0,11
   3d992:	00000097          	auipc	ra,0x0
   3d996:	db0080e7          	jalr	ra,-592(ra) # 0x3d742
   3d99a:	94ca                	c.add	s1,s2
   3d99c:	ee990de3          	beq	s2,s1,0x3d896
   3d9a0:	0905                	c.addi	s2,1
   3d9a2:	00000097          	auipc	ra,0x0
   3d9a6:	d84080e7          	jalr	ra,-636(ra) # 0x3d726
   3d9aa:	fea90fa3          	sb	a0,-1(s2)
   3d9ae:	b7fd                	c.j	0x3d99c
   3d9b0:	47b1                	c.li	a5,12
   3d9b2:	04f99263          	bne	s3,a5,0x3d9f6
   3d9b6:	00040737          	lui	a4,0x40
   3d9ba:	5579                	c.li	a0,-2
   3d9bc:	f0ebfde3          	bgeu	s7,a4,0x3d8d6
   3d9c0:	009b87b3          	add	a5,s7,s1
   3d9c4:	f0f769e3          	bltu	a4,a5,0x3d8d6
   3d9c8:	85de                	c.mv	a1,s7
   3d9ca:	452d                	c.li	a0,11
   3d9cc:	00000097          	auipc	ra,0x0
   3d9d0:	d76080e7          	jalr	ra,-650(ra) # 0x3d742
   3d9d4:	59fd                	c.li	s3,-1
   3d9d6:	14fd                	c.addi	s1,-1
   3d9d8:	eb348fe3          	beq	s1,s3,0x3d896
   3d9dc:	00000097          	auipc	ra,0x0
   3d9e0:	d4a080e7          	jalr	ra,-694(ra) # 0x3d726
   3d9e4:	0034f793          	andi	a5,s1,3
   3d9e8:	f7fd                	c.bnez	a5,0x3d9d6
   3d9ea:	80042783          	lw	a5,-2048(s0)
   3d9ee:	0911                	c.addi	s2,4
   3d9f0:	fef92e23          	sw	a5,-4(s2)
   3d9f4:	b7cd                	c.j	0x3d9d6
   3d9f6:	47b5                	c.li	a5,13
   3d9f8:	02f99e63          	bne	s3,a5,0x3da34
   3d9fc:	00040737          	lui	a4,0x40
   3da00:	5579                	c.li	a0,-2
   3da02:	ecebfae3          	bgeu	s7,a4,0x3d8d6
   3da06:	009b87b3          	add	a5,s7,s1
   3da0a:	ecf766e3          	bltu	a4,a5,0x3d8d6
   3da0e:	85de                	c.mv	a1,s7
   3da10:	452d                	c.li	a0,11
   3da12:	00000097          	auipc	ra,0x0
   3da16:	d30080e7          	jalr	ra,-720(ra) # 0x3d742
   3da1a:	94ca                	c.add	s1,s2
   3da1c:	e6990de3          	beq	s2,s1,0x3d896
   3da20:	00000097          	auipc	ra,0x0
   3da24:	d06080e7          	jalr	ra,-762(ra) # 0x3d726
   3da28:	80444783          	lbu	a5,-2044(s0)
   3da2c:	0905                	c.addi	s2,1
   3da2e:	fef90fa3          	sb	a5,-1(s2)
   3da32:	b7ed                	c.j	0x3da1c
   3da34:	fff98793          	addi	a5,s3,-1 # 0xffff
   3da38:	0ff7f793          	andi	a5,a5,255
   3da3c:	0af76863          	bltu	a4,a5,0x3daec
   3da40:	045b4703          	lbu	a4,69(s6) # 0x10045
   3da44:	000407b7          	lui	a5,0x40
   3da48:	02077713          	andi	a4,a4,32
   3da4c:	e319                	c.bnez	a4,0x3da52
   3da4e:	0003c7b7          	lui	a5,0x3c
   3da52:	5579                	c.li	a0,-2
   3da54:	e8fbf1e3          	bgeu	s7,a5,0x3d8d6
   3da58:	009b8733          	add	a4,s7,s1
   3da5c:	e6e7ede3          	bltu	a5,a4,0x3d8d6
   3da60:	4789                	c.li	a5,2
   3da62:	04f99663          	bne	s3,a5,0x3daae
   3da66:	8089                	c.srli	s1,0x2
   3da68:	49d5                	c.li	s3,21
   3da6a:	e20486e3          	beq	s1,zero,0x3d896
   3da6e:	85de                	c.mv	a1,s7
   3da70:	4509                	c.li	a0,2
   3da72:	00000097          	auipc	ra,0x0
   3da76:	cd0080e7          	jalr	ra,-816(ra) # 0x3d742
   3da7a:	0911                	c.addi	s2,4
   3da7c:	ffc92703          	lw	a4,-4(s2)
   3da80:	4791                	c.li	a5,4
   3da82:	80e42023          	sw	a4,-2048(s0)
   3da86:	80640703          	lb	a4,-2042(s0)
   3da8a:	fe074ee3          	blt	a4,zero,0x3da86
   3da8e:	81340323          	sb	s3,-2042(s0)
   3da92:	17fd                	c.addi	a5,-1 # 0x3bfff
   3da94:	fbed                	c.bnez	a5,0x3da86
   3da96:	14fd                	c.addi	s1,-1
   3da98:	0b91                	c.addi	s7,4 # 0x1004
   3da9a:	c481                	c.beqz	s1,0x3daa2
   3da9c:	0ffbf793          	andi	a5,s7,255
   3daa0:	ffe9                	c.bnez	a5,0x3da7a
   3daa2:	00000097          	auipc	ra,0x0
   3daa6:	d00080e7          	jalr	ra,-768(ra) # 0x3d7a2
   3daaa:	f161                	c.bnez	a0,0x3da6a
   3daac:	b525                	c.j	0x3d8d4
   3daae:	4785                	c.li	a5,1
   3dab0:	eaf983e3          	beq	s3,a5,0x3d956
   3dab4:	85de                	c.mv	a1,s7
   3dab6:	452d                	c.li	a0,11
   3dab8:	00000097          	auipc	ra,0x0
   3dabc:	c8a080e7          	jalr	ra,-886(ra) # 0x3d742
   3dac0:	fff48993          	addi	s3,s1,-1
   3dac4:	dc0489e3          	beq	s1,zero,0x3d896
   3dac8:	00000097          	auipc	ra,0x0
   3dacc:	c5e080e7          	jalr	ra,-930(ra) # 0x3d726
   3dad0:	0039f793          	andi	a5,s3,3
   3dad4:	eb91                	c.bnez	a5,0x3dae8
   3dad6:	80042683          	lw	a3,-2048(s0)
   3dada:	00092703          	lw	a4,0(s2)
   3dade:	00490793          	addi	a5,s2,4
   3dae2:	dae69be3          	bne	a3,a4,0x3d898
   3dae6:	893e                	c.mv	s2,a5
   3dae8:	84ce                	c.mv	s1,s3
   3daea:	bfd9                	c.j	0x3dac0
   3daec:	4799                	c.li	a5,6
   3daee:	04f99763          	bne	s3,a5,0x3db3c
   3daf2:	000405b7          	lui	a1,0x40
   3daf6:	00bbe5b3          	or	a1,s7,a1
   3dafa:	452d                	c.li	a0,11
   3dafc:	00000097          	auipc	ra,0x0
   3db00:	c46080e7          	jalr	ra,-954(ra) # 0x3d742
   3db04:	4481                	c.li	s1,0
   3db06:	4b0d                	c.li	s6,3
   3db08:	49a1                	c.li	s3,8
   3db0a:	00000097          	auipc	ra,0x0
   3db0e:	c1c080e7          	jalr	ra,-996(ra) # 0x3d726
   3db12:	01649663          	bne	s1,s6,0x3db1e
   3db16:	80042783          	lw	a5,-2048(s0)
   3db1a:	00f92023          	sw	a5,0(s2)
   3db1e:	0485                	c.addi	s1,1
   3db20:	ff3495e3          	bne	s1,s3,0x3db0a
   3db24:	80042783          	lw	a5,-2048(s0)
   3db28:	012b9713          	slli	a4,s7,0x12
   3db2c:	00075563          	bge	a4,zero,0x3db36
   3db30:	00f91223          	sh	a5,4(s2)
   3db34:	b38d                	c.j	0x3d896
   3db36:	00f92223          	sw	a5,4(s2)
   3db3a:	bbb1                	c.j	0x3d896
   3db3c:	479d                	c.li	a5,7
   3db3e:	02f99f63          	bne	s3,a5,0x3db7c
   3db42:	4581                	c.li	a1,0
   3db44:	04b00513          	addi	a0,zero,75
   3db48:	00000097          	auipc	ra,0x0
   3db4c:	bfa080e7          	jalr	ra,-1030(ra) # 0x3d742
   3db50:	44bd                	c.li	s1,15
   3db52:	00092023          	sw	zero,0(s2)
   3db56:	00092223          	sw	zero,4(s2)
   3db5a:	59fd                	c.li	s3,-1
   3db5c:	00000097          	auipc	ra,0x0
   3db60:	bca080e7          	jalr	ra,-1078(ra) # 0x3d726
   3db64:	0074f793          	andi	a5,s1,7
   3db68:	97ca                	c.add	a5,s2
   3db6a:	0007c703          	lbu	a4,0(a5)
   3db6e:	14fd                	c.addi	s1,-1
   3db70:	8d39                	c.xor	a0,a4
   3db72:	00a78023          	sb	a0,0(a5)
   3db76:	ff3493e3          	bne	s1,s3,0x3db5c
   3db7a:	bb31                	c.j	0x3d896
   3db7c:	47a1                	c.li	a5,8
   3db7e:	d0f98ce3          	beq	s3,a5,0x3d896
   3db82:	4791                	c.li	a5,4
   3db84:	02f99363          	bne	s3,a5,0x3dbaa
   3db88:	06600513          	addi	a0,zero,102
   3db8c:	00000097          	auipc	ra,0x0
   3db90:	b7a080e7          	jalr	ra,-1158(ra) # 0x3d706
   3db94:	00000097          	auipc	ra,0x0
   3db98:	b84080e7          	jalr	ra,-1148(ra) # 0x3d718
   3db9c:	09900513          	addi	a0,zero,153
   3dba0:	00000097          	auipc	ra,0x0
   3dba4:	b66080e7          	jalr	ra,-1178(ra) # 0x3d706
   3dba8:	b1fd                	c.j	0x3d896
   3dbaa:	ce0986e3          	beq	s3,zero,0x3d896
   3dbae:	54f1                	c.li	s1,-4
   3dbb0:	b1e5                	c.j	0x3d898
   3dbb2:	0000                	c.unimp
   3dbb4:	400017b7          	lui	a5,0x40001
   3dbb8:	0a47a783          	lw	a5,164(a5) # 0x400010a4
   3dbbc:	8b85                	c.andi	a5,1
   3dbbe:	cb9d                	c.beqz	a5,0x3dbf4
   3dbc0:	4799                	c.li	a5,6
   3dbc2:	400016b7          	lui	a3,0x40001
   3dbc6:	0a46a703          	lw	a4,164(a3) # 0x400010a4
   3dbca:	8b05                	c.andi	a4,1
   3dbcc:	c701                	c.beqz	a4,0x3dbd4
   3dbce:	17fd                	c.addi	a5,-1
   3dbd0:	fbfd                	c.bnez	a5,0x3dbc6
   3dbd2:	8082                	c.jr	ra
   3dbd4:	4799                	c.li	a5,6
   3dbd6:	40001737          	lui	a4,0x40001
   3dbda:	0a472683          	lw	a3,164(a4) # 0x400010a4
   3dbde:	8a85                	c.andi	a3,1
   3dbe0:	ca81                	c.beqz	a3,0x3dbf0
   3dbe2:	01875783          	lhu	a5,24(a4)
   3dbe6:	6691                	c.lui	a3,0x4
   3dbe8:	8fd5                	c.or	a5,a3
   3dbea:	00f71c23          	sh	a5,24(a4)
   3dbee:	8082                	c.jr	ra
   3dbf0:	17fd                	c.addi	a5,-1
   3dbf2:	f7e5                	c.bnez	a5,0x3dbda
   3dbf4:	8082                	c.jr	ra
   3dbf6:	0000                	c.unimp
   3dbf8:	0ff0                	c.addi4spn	a2,sp,988
   3dbfa:	2000                	c.fld	fs0,0(s0)
   3dbfc:	0f76                	c.slli	t5,0x1d
   3dbfe:	2000                	c.fld	fs0,0(s0)
   3dc00:	0ee2                	c.slli	t4,0x18
   3dc02:	2000                	c.fld	fs0,0(s0)
   3dc04:	0ee2                	c.slli	t4,0x18
   3dc06:	2000                	c.fld	fs0,0(s0)
   3dc08:	0ee2                	c.slli	t4,0x18
   3dc0a:	2000                	c.fld	fs0,0(s0)
   3dc0c:	0f36                	c.slli	t5,0xd
   3dc0e:	2000                	c.fld	fs0,0(s0)
   3dc10:	0e7e                	c.slli	t3,0x1f
   3dc12:	2000                	c.fld	fs0,0(s0)
   3dc14:	0ee2                	c.slli	t4,0x18
   3dc16:	2000                	c.fld	fs0,0(s0)
   3dc18:	0f56                	c.slli	t5,0x15
   3dc1a:	2000                	c.fld	fs0,0(s0)
   3dc1c:	0f68                	c.addi4spn	a0,sp,924
   3dc1e:	2000                	c.fld	fs0,0(s0)
   3dc20:	0fea                	c.slli	t6,0x1a
   3dc22:	2000                	c.fld	fs0,0(s0)
   3dc24:	0209                	c.addi	tp,2 # 0x2
   3dc26:	0020                	c.addi4spn	s0,sp,8
   3dc28:	0101                	c.addi	sp,0
   3dc2a:	8000                	.2byte	0x8000
   3dc2c:	0932                	c.slli	s2,0xc
   3dc2e:	0004                	.2byte	0x4
   3dc30:	0200                	c.addi4spn	s0,sp,256
   3dc32:	80ff                	.2byte	0x80ff
   3dc34:	0055                	c.addi	zero,21
   3dc36:	02820507          	.4byte	0x2820507
   3dc3a:	0040                	c.addi4spn	s0,sp,4
   3dc3c:	0700                	c.addi4spn	s0,sp,896
   3dc3e:	0205                	c.addi	tp,1 # 0x1
   3dc40:	4002                	.2byte	0x4002
   3dc42:	0000                	c.unimp
   3dc44:	0112                	c.slli	sp,0x4
   3dc46:	0110                	c.addi4spn	a2,sp,128
   3dc48:	80ff                	.2byte	0x80ff
   3dc4a:	4055                	c.li	zero,21
   3dc4c:	1a86                	c.slli	s5,0x21
   3dc4e:	55e0                	c.lw	s0,108(a1)
   3dc50:	2300                	c.fld	fs0,0(a4)
   3dc52:	0000                	c.unimp
   3dc54:	0100                	c.addi4spn	s0,sp,128
   3dc56:	0000                	c.unimp
   3dc58:	0200                	c.addi4spn	s0,sp,256
   3dc5a:	00000003          	lb	zero,0(zero) # 0x0
   3dc5e:	0000                	c.unimp
   3dc60:	bda9                	c.j	0x3daba
   3dc62:	f3f9                	c.bnez	a5,0x3dc28
   3dc64:	bda9                	c.j	0x3dabe
   3dc66:	f3f9                	c.bnez	a5,0x3dc2c
   3dc68:	bda9                	c.j	0x3dac2
   3dc6a:	f3f9                	c.bnez	a5,0x3dc30
   3dc6c:	bda9                	c.j	0x3dac6
   3dc6e:	f3f9                	c.bnez	a5,0x3dc34
   3dc70:	bda9                	c.j	0x3daca
   3dc72:	f3f9                	c.bnez	a5,0x3dc38
   3dc74:	bda9                	c.j	0x3dace
   3dc76:	f3f9                	c.bnez	a5,0x3dc3c
   3dc78:	bda9                	c.j	0x3dad2
   3dc7a:	f3f9                	c.bnez	a5,0x3dc40
   3dc7c:	bda9                	c.j	0x3dad6
   3dc7e:	f3f9                	c.bnez	a5,0x3dc44
   3dc80:	bda9                	c.j	0x3dada
   3dc82:	f3f9                	c.bnez	a5,0x3dc48
   3dc84:	bda9                	c.j	0x3dade
   3dc86:	f3f9                	c.bnez	a5,0x3dc4c
   3dc88:	bda9                	c.j	0x3dae2
   3dc8a:	f3f9                	c.bnez	a5,0x3dc50
   3dc8c:	bda9                	c.j	0x3dae6
   3dc8e:	f3f9                	c.bnez	a5,0x3dc54
   3dc90:	bda9                	c.j	0x3daea
   3dc92:	f3f9                	c.bnez	a5,0x3dc58
   3dc94:	bda9                	c.j	0x3daee
   3dc96:	f3f9                	c.bnez	a5,0x3dc5c
   3dc98:	bda9                	c.j	0x3daf2
   3dc9a:	f3f9                	c.bnez	a5,0x3dc60
   3dc9c:	bda9                	c.j	0x3daf6
   3dc9e:	f3f9                	c.bnez	a5,0x3dc64
   3dca0:	bda9                	c.j	0x3dafa
   3dca2:	f3f9                	c.bnez	a5,0x3dc68
   3dca4:	bda9                	c.j	0x3dafe
   3dca6:	f3f9                	c.bnez	a5,0x3dc6c
   3dca8:	bda9                	c.j	0x3db02
   3dcaa:	f3f9                	c.bnez	a5,0x3dc70
   3dcac:	bda9                	c.j	0x3db06
   3dcae:	f3f9                	c.bnez	a5,0x3dc74
   3dcb0:	bda9                	c.j	0x3db0a
   3dcb2:	f3f9                	c.bnez	a5,0x3dc78
   3dcb4:	bda9                	c.j	0x3db0e
   3dcb6:	f3f9                	c.bnez	a5,0x3dc7c
   3dcb8:	bda9                	c.j	0x3db12
   3dcba:	f3f9                	c.bnez	a5,0x3dc80
   3dcbc:	bda9                	c.j	0x3db16
   3dcbe:	f3f9                	c.bnez	a5,0x3dc84
   3dcc0:	bda9                	c.j	0x3db1a
   3dcc2:	f3f9                	c.bnez	a5,0x3dc88
   3dcc4:	bda9                	c.j	0x3db1e
   3dcc6:	f3f9                	c.bnez	a5,0x3dc8c
   3dcc8:	bda9                	c.j	0x3db22
   3dcca:	f3f9                	c.bnez	a5,0x3dc90
   3dccc:	bda9                	c.j	0x3db26
   3dcce:	f3f9                	c.bnez	a5,0x3dc94
   3dcd0:	bda9                	c.j	0x3db2a
   3dcd2:	f3f9                	c.bnez	a5,0x3dc98
   3dcd4:	bda9                	c.j	0x3db2e
   3dcd6:	f3f9                	c.bnez	a5,0x3dc9c
   3dcd8:	bda9                	c.j	0x3db32
   3dcda:	f3f9                	c.bnez	a5,0x3dca0
   3dcdc:	bda9                	c.j	0x3db36
   3dcde:	f3f9                	c.bnez	a5,0x3dca4
   3dce0:	bda9                	c.j	0x3db3a
   3dce2:	f3f9                	c.bnez	a5,0x3dca8
   3dce4:	bda9                	c.j	0x3db3e
   3dce6:	f3f9                	c.bnez	a5,0x3dcac
   3dce8:	bda9                	c.j	0x3db42
   3dcea:	f3f9                	c.bnez	a5,0x3dcb0
   3dcec:	bda9                	c.j	0x3db46
   3dcee:	f3f9                	c.bnez	a5,0x3dcb4
   3dcf0:	bda9                	c.j	0x3db4a
   3dcf2:	f3f9                	c.bnez	a5,0x3dcb8
   3dcf4:	bda9                	c.j	0x3db4e
   3dcf6:	f3f9                	c.bnez	a5,0x3dcbc
   3dcf8:	bda9                	c.j	0x3db52
   3dcfa:	f3f9                	c.bnez	a5,0x3dcc0
   3dcfc:	bda9                	c.j	0x3db56
   3dcfe:	f3f9                	c.bnez	a5,0x3dcc4
   3dd00:	bda9                	c.j	0x3db5a
   3dd02:	f3f9                	c.bnez	a5,0x3dcc8
   3dd04:	bda9                	c.j	0x3db5e
   3dd06:	f3f9                	c.bnez	a5,0x3dccc
   3dd08:	bda9                	c.j	0x3db62
   3dd0a:	f3f9                	c.bnez	a5,0x3dcd0
   3dd0c:	bda9                	c.j	0x3db66
   3dd0e:	f3f9                	c.bnez	a5,0x3dcd4
   3dd10:	bda9                	c.j	0x3db6a
   3dd12:	f3f9                	c.bnez	a5,0x3dcd8
   3dd14:	bda9                	c.j	0x3db6e
   3dd16:	f3f9                	c.bnez	a5,0x3dcdc
   3dd18:	bda9                	c.j	0x3db72
   3dd1a:	f3f9                	c.bnez	a5,0x3dce0
   3dd1c:	bda9                	c.j	0x3db76
   3dd1e:	f3f9                	c.bnez	a5,0x3dce4
   3dd20:	bda9                	c.j	0x3db7a
   3dd22:	f3f9                	c.bnez	a5,0x3dce8
   3dd24:	bda9                	c.j	0x3db7e
   3dd26:	f3f9                	c.bnez	a5,0x3dcec
   3dd28:	bda9                	c.j	0x3db82
   3dd2a:	f3f9                	c.bnez	a5,0x3dcf0
   3dd2c:	bda9                	c.j	0x3db86
   3dd2e:	f3f9                	c.bnez	a5,0x3dcf4
   3dd30:	bda9                	c.j	0x3db8a
   3dd32:	f3f9                	c.bnez	a5,0x3dcf8
   3dd34:	bda9                	c.j	0x3db8e
   3dd36:	f3f9                	c.bnez	a5,0x3dcfc
   3dd38:	bda9                	c.j	0x3db92
   3dd3a:	f3f9                	c.bnez	a5,0x3dd00
   3dd3c:	bda9                	c.j	0x3db96
   3dd3e:	f3f9                	c.bnez	a5,0x3dd04
   3dd40:	bda9                	c.j	0x3db9a
   3dd42:	f3f9                	c.bnez	a5,0x3dd08
   3dd44:	bda9                	c.j	0x3db9e
   3dd46:	f3f9                	c.bnez	a5,0x3dd0c
   3dd48:	bda9                	c.j	0x3dba2
   3dd4a:	f3f9                	c.bnez	a5,0x3dd10
   3dd4c:	bda9                	c.j	0x3dba6
   3dd4e:	f3f9                	c.bnez	a5,0x3dd14
   3dd50:	bda9                	c.j	0x3dbaa
   3dd52:	f3f9                	c.bnez	a5,0x3dd18
   3dd54:	bda9                	c.j	0x3dbae
   3dd56:	f3f9                	c.bnez	a5,0x3dd1c
   3dd58:	bda9                	c.j	0x3dbb2
   3dd5a:	f3f9                	c.bnez	a5,0x3dd20
   3dd5c:	bda9                	c.j	0x3dbb6
   3dd5e:	f3f9                	c.bnez	a5,0x3dd24
   3dd60:	bda9                	c.j	0x3dbba
   3dd62:	f3f9                	c.bnez	a5,0x3dd28
   3dd64:	bda9                	c.j	0x3dbbe
   3dd66:	f3f9                	c.bnez	a5,0x3dd2c
   3dd68:	bda9                	c.j	0x3dbc2
   3dd6a:	f3f9                	c.bnez	a5,0x3dd30
   3dd6c:	bda9                	c.j	0x3dbc6
   3dd6e:	f3f9                	c.bnez	a5,0x3dd34
   3dd70:	bda9                	c.j	0x3dbca
   3dd72:	f3f9                	c.bnez	a5,0x3dd38
   3dd74:	bda9                	c.j	0x3dbce
   3dd76:	f3f9                	c.bnez	a5,0x3dd3c
   3dd78:	bda9                	c.j	0x3dbd2
   3dd7a:	f3f9                	c.bnez	a5,0x3dd40
   3dd7c:	bda9                	c.j	0x3dbd6
   3dd7e:	f3f9                	c.bnez	a5,0x3dd44
   3dd80:	bda9                	c.j	0x3dbda
   3dd82:	f3f9                	c.bnez	a5,0x3dd48
   3dd84:	bda9                	c.j	0x3dbde
   3dd86:	f3f9                	c.bnez	a5,0x3dd4c
   3dd88:	bda9                	c.j	0x3dbe2
   3dd8a:	f3f9                	c.bnez	a5,0x3dd50
   3dd8c:	bda9                	c.j	0x3dbe6
   3dd8e:	f3f9                	c.bnez	a5,0x3dd54
   3dd90:	bda9                	c.j	0x3dbea
   3dd92:	f3f9                	c.bnez	a5,0x3dd58
   3dd94:	bda9                	c.j	0x3dbee
   3dd96:	f3f9                	c.bnez	a5,0x3dd5c
   3dd98:	bda9                	c.j	0x3dbf2
   3dd9a:	f3f9                	c.bnez	a5,0x3dd60
   3dd9c:	bda9                	c.j	0x3dbf6
   3dd9e:	f3f9                	c.bnez	a5,0x3dd64
   3dda0:	bda9                	c.j	0x3dbfa
   3dda2:	f3f9                	c.bnez	a5,0x3dd68
   3dda4:	bda9                	c.j	0x3dbfe
   3dda6:	f3f9                	c.bnez	a5,0x3dd6c
   3dda8:	bda9                	c.j	0x3dc02
   3ddaa:	f3f9                	c.bnez	a5,0x3dd70
   3ddac:	bda9                	c.j	0x3dc06
   3ddae:	f3f9                	c.bnez	a5,0x3dd74
   3ddb0:	bda9                	c.j	0x3dc0a
   3ddb2:	f3f9                	c.bnez	a5,0x3dd78
   3ddb4:	bda9                	c.j	0x3dc0e
   3ddb6:	f3f9                	c.bnez	a5,0x3dd7c
   3ddb8:	bda9                	c.j	0x3dc12
   3ddba:	f3f9                	c.bnez	a5,0x3dd80
   3ddbc:	bda9                	c.j	0x3dc16
   3ddbe:	f3f9                	c.bnez	a5,0x3dd84
   3ddc0:	bda9                	c.j	0x3dc1a
   3ddc2:	f3f9                	c.bnez	a5,0x3dd88
   3ddc4:	bda9                	c.j	0x3dc1e
   3ddc6:	f3f9                	c.bnez	a5,0x3dd8c
   3ddc8:	bda9                	c.j	0x3dc22
   3ddca:	f3f9                	c.bnez	a5,0x3dd90
   3ddcc:	bda9                	c.j	0x3dc26
   3ddce:	f3f9                	c.bnez	a5,0x3dd94
   3ddd0:	bda9                	c.j	0x3dc2a
   3ddd2:	f3f9                	c.bnez	a5,0x3dd98
   3ddd4:	bda9                	c.j	0x3dc2e
   3ddd6:	f3f9                	c.bnez	a5,0x3dd9c
   3ddd8:	bda9                	c.j	0x3dc32
   3ddda:	f3f9                	c.bnez	a5,0x3dda0
   3dddc:	bda9                	c.j	0x3dc36
   3ddde:	f3f9                	c.bnez	a5,0x3dda4
   3dde0:	bda9                	c.j	0x3dc3a
   3dde2:	f3f9                	c.bnez	a5,0x3dda8
   3dde4:	bda9                	c.j	0x3dc3e
   3dde6:	f3f9                	c.bnez	a5,0x3ddac
   3dde8:	bda9                	c.j	0x3dc42
   3ddea:	f3f9                	c.bnez	a5,0x3ddb0
   3ddec:	bda9                	c.j	0x3dc46
   3ddee:	f3f9                	c.bnez	a5,0x3ddb4
   3ddf0:	bda9                	c.j	0x3dc4a
   3ddf2:	f3f9                	c.bnez	a5,0x3ddb8
   3ddf4:	bda9                	c.j	0x3dc4e
   3ddf6:	f3f9                	c.bnez	a5,0x3ddbc
   3ddf8:	bda9                	c.j	0x3dc52
   3ddfa:	f3f9                	c.bnez	a5,0x3ddc0
   3ddfc:	bda9                	c.j	0x3dc56
   3ddfe:	f3f9                	c.bnez	a5,0x3ddc4
   3de00:	bda9                	c.j	0x3dc5a
   3de02:	f3f9                	c.bnez	a5,0x3ddc8
   3de04:	bda9                	c.j	0x3dc5e
   3de06:	f3f9                	c.bnez	a5,0x3ddcc
   3de08:	bda9                	c.j	0x3dc62
   3de0a:	f3f9                	c.bnez	a5,0x3ddd0
   3de0c:	bda9                	c.j	0x3dc66
   3de0e:	f3f9                	c.bnez	a5,0x3ddd4
   3de10:	bda9                	c.j	0x3dc6a
   3de12:	f3f9                	c.bnez	a5,0x3ddd8
   3de14:	bda9                	c.j	0x3dc6e
   3de16:	f3f9                	c.bnez	a5,0x3dddc
   3de18:	bda9                	c.j	0x3dc72
   3de1a:	f3f9                	c.bnez	a5,0x3dde0
   3de1c:	bda9                	c.j	0x3dc76
   3de1e:	f3f9                	c.bnez	a5,0x3dde4
   3de20:	bda9                	c.j	0x3dc7a
   3de22:	f3f9                	c.bnez	a5,0x3dde8
   3de24:	bda9                	c.j	0x3dc7e
   3de26:	f3f9                	c.bnez	a5,0x3ddec
   3de28:	bda9                	c.j	0x3dc82
   3de2a:	f3f9                	c.bnez	a5,0x3ddf0
   3de2c:	bda9                	c.j	0x3dc86
   3de2e:	f3f9                	c.bnez	a5,0x3ddf4
   3de30:	bda9                	c.j	0x3dc8a
   3de32:	f3f9                	c.bnez	a5,0x3ddf8
   3de34:	bda9                	c.j	0x3dc8e
   3de36:	f3f9                	c.bnez	a5,0x3ddfc
   3de38:	bda9                	c.j	0x3dc92
   3de3a:	f3f9                	c.bnez	a5,0x3de00
   3de3c:	bda9                	c.j	0x3dc96
   3de3e:	f3f9                	c.bnez	a5,0x3de04
   3de40:	bda9                	c.j	0x3dc9a
   3de42:	f3f9                	c.bnez	a5,0x3de08
   3de44:	bda9                	c.j	0x3dc9e
   3de46:	f3f9                	c.bnez	a5,0x3de0c
   3de48:	bda9                	c.j	0x3dca2
   3de4a:	f3f9                	c.bnez	a5,0x3de10
   3de4c:	bda9                	c.j	0x3dca6
   3de4e:	f3f9                	c.bnez	a5,0x3de14
   3de50:	bda9                	c.j	0x3dcaa
   3de52:	f3f9                	c.bnez	a5,0x3de18
   3de54:	bda9                	c.j	0x3dcae
   3de56:	f3f9                	c.bnez	a5,0x3de1c
   3de58:	bda9                	c.j	0x3dcb2
   3de5a:	f3f9                	c.bnez	a5,0x3de20
   3de5c:	bda9                	c.j	0x3dcb6
   3de5e:	f3f9                	c.bnez	a5,0x3de24
   3de60:	bda9                	c.j	0x3dcba
   3de62:	f3f9                	c.bnez	a5,0x3de28
   3de64:	bda9                	c.j	0x3dcbe
   3de66:	f3f9                	c.bnez	a5,0x3de2c
   3de68:	bda9                	c.j	0x3dcc2
   3de6a:	f3f9                	c.bnez	a5,0x3de30
   3de6c:	bda9                	c.j	0x3dcc6
   3de6e:	f3f9                	c.bnez	a5,0x3de34
   3de70:	bda9                	c.j	0x3dcca
   3de72:	f3f9                	c.bnez	a5,0x3de38
   3de74:	bda9                	c.j	0x3dcce
   3de76:	f3f9                	c.bnez	a5,0x3de3c
   3de78:	bda9                	c.j	0x3dcd2
   3de7a:	f3f9                	c.bnez	a5,0x3de40
   3de7c:	bda9                	c.j	0x3dcd6
   3de7e:	f3f9                	c.bnez	a5,0x3de44
   3de80:	bda9                	c.j	0x3dcda
   3de82:	f3f9                	c.bnez	a5,0x3de48
   3de84:	bda9                	c.j	0x3dcde
   3de86:	f3f9                	c.bnez	a5,0x3de4c
   3de88:	bda9                	c.j	0x3dce2
   3de8a:	f3f9                	c.bnez	a5,0x3de50
   3de8c:	bda9                	c.j	0x3dce6
   3de8e:	f3f9                	c.bnez	a5,0x3de54
   3de90:	bda9                	c.j	0x3dcea
   3de92:	f3f9                	c.bnez	a5,0x3de58
   3de94:	bda9                	c.j	0x3dcee
   3de96:	f3f9                	c.bnez	a5,0x3de5c
   3de98:	bda9                	c.j	0x3dcf2
   3de9a:	f3f9                	c.bnez	a5,0x3de60
   3de9c:	bda9                	c.j	0x3dcf6
   3de9e:	f3f9                	c.bnez	a5,0x3de64
   3dea0:	bda9                	c.j	0x3dcfa
   3dea2:	f3f9                	c.bnez	a5,0x3de68
   3dea4:	bda9                	c.j	0x3dcfe
   3dea6:	f3f9                	c.bnez	a5,0x3de6c
   3dea8:	bda9                	c.j	0x3dd02
   3deaa:	f3f9                	c.bnez	a5,0x3de70
   3deac:	bda9                	c.j	0x3dd06
   3deae:	f3f9                	c.bnez	a5,0x3de74
   3deb0:	bda9                	c.j	0x3dd0a
   3deb2:	f3f9                	c.bnez	a5,0x3de78
   3deb4:	bda9                	c.j	0x3dd0e
   3deb6:	f3f9                	c.bnez	a5,0x3de7c
   3deb8:	bda9                	c.j	0x3dd12
   3deba:	f3f9                	c.bnez	a5,0x3de80
   3debc:	bda9                	c.j	0x3dd16
   3debe:	f3f9                	c.bnez	a5,0x3de84
   3dec0:	bda9                	c.j	0x3dd1a
   3dec2:	f3f9                	c.bnez	a5,0x3de88
   3dec4:	bda9                	c.j	0x3dd1e
   3dec6:	f3f9                	c.bnez	a5,0x3de8c
   3dec8:	bda9                	c.j	0x3dd22
   3deca:	f3f9                	c.bnez	a5,0x3de90
   3decc:	bda9                	c.j	0x3dd26
   3dece:	f3f9                	c.bnez	a5,0x3de94
   3ded0:	bda9                	c.j	0x3dd2a
   3ded2:	f3f9                	c.bnez	a5,0x3de98
   3ded4:	bda9                	c.j	0x3dd2e
   3ded6:	f3f9                	c.bnez	a5,0x3de9c
   3ded8:	bda9                	c.j	0x3dd32
   3deda:	f3f9                	c.bnez	a5,0x3dea0
   3dedc:	bda9                	c.j	0x3dd36
   3dede:	f3f9                	c.bnez	a5,0x3dea4
   3dee0:	bda9                	c.j	0x3dd3a
   3dee2:	f3f9                	c.bnez	a5,0x3dea8
   3dee4:	bda9                	c.j	0x3dd3e
   3dee6:	f3f9                	c.bnez	a5,0x3deac
   3dee8:	bda9                	c.j	0x3dd42
   3deea:	f3f9                	c.bnez	a5,0x3deb0
   3deec:	bda9                	c.j	0x3dd46
   3deee:	f3f9                	c.bnez	a5,0x3deb4
   3def0:	bda9                	c.j	0x3dd4a
   3def2:	f3f9                	c.bnez	a5,0x3deb8
   3def4:	bda9                	c.j	0x3dd4e
   3def6:	f3f9                	c.bnez	a5,0x3debc
   3def8:	bda9                	c.j	0x3dd52
   3defa:	f3f9                	c.bnez	a5,0x3dec0
   3defc:	bda9                	c.j	0x3dd56
   3defe:	f3f9                	c.bnez	a5,0x3dec4
   3df00:	bda9                	c.j	0x3dd5a
   3df02:	f3f9                	c.bnez	a5,0x3dec8
   3df04:	bda9                	c.j	0x3dd5e
   3df06:	f3f9                	c.bnez	a5,0x3decc
   3df08:	bda9                	c.j	0x3dd62
   3df0a:	f3f9                	c.bnez	a5,0x3ded0
   3df0c:	bda9                	c.j	0x3dd66
   3df0e:	f3f9                	c.bnez	a5,0x3ded4
   3df10:	bda9                	c.j	0x3dd6a
   3df12:	f3f9                	c.bnez	a5,0x3ded8
   3df14:	bda9                	c.j	0x3dd6e
   3df16:	f3f9                	c.bnez	a5,0x3dedc
   3df18:	bda9                	c.j	0x3dd72
   3df1a:	f3f9                	c.bnez	a5,0x3dee0
   3df1c:	bda9                	c.j	0x3dd76
   3df1e:	f3f9                	c.bnez	a5,0x3dee4
   3df20:	bda9                	c.j	0x3dd7a
   3df22:	f3f9                	c.bnez	a5,0x3dee8
   3df24:	bda9                	c.j	0x3dd7e
   3df26:	f3f9                	c.bnez	a5,0x3deec
   3df28:	bda9                	c.j	0x3dd82
   3df2a:	f3f9                	c.bnez	a5,0x3def0
   3df2c:	bda9                	c.j	0x3dd86
   3df2e:	f3f9                	c.bnez	a5,0x3def4
   3df30:	bda9                	c.j	0x3dd8a
   3df32:	f3f9                	c.bnez	a5,0x3def8
   3df34:	bda9                	c.j	0x3dd8e
   3df36:	f3f9                	c.bnez	a5,0x3defc
   3df38:	bda9                	c.j	0x3dd92
   3df3a:	f3f9                	c.bnez	a5,0x3df00
   3df3c:	bda9                	c.j	0x3dd96
   3df3e:	f3f9                	c.bnez	a5,0x3df04
   3df40:	bda9                	c.j	0x3dd9a
   3df42:	f3f9                	c.bnez	a5,0x3df08
   3df44:	bda9                	c.j	0x3dd9e
   3df46:	f3f9                	c.bnez	a5,0x3df0c
   3df48:	bda9                	c.j	0x3dda2
   3df4a:	f3f9                	c.bnez	a5,0x3df10
   3df4c:	bda9                	c.j	0x3dda6
   3df4e:	f3f9                	c.bnez	a5,0x3df14
   3df50:	bda9                	c.j	0x3ddaa
   3df52:	f3f9                	c.bnez	a5,0x3df18
   3df54:	bda9                	c.j	0x3ddae
   3df56:	f3f9                	c.bnez	a5,0x3df1c
   3df58:	bda9                	c.j	0x3ddb2
   3df5a:	f3f9                	c.bnez	a5,0x3df20
   3df5c:	bda9                	c.j	0x3ddb6
   3df5e:	f3f9                	c.bnez	a5,0x3df24
   3df60:	bda9                	c.j	0x3ddba
   3df62:	f3f9                	c.bnez	a5,0x3df28
   3df64:	bda9                	c.j	0x3ddbe
   3df66:	f3f9                	c.bnez	a5,0x3df2c
   3df68:	bda9                	c.j	0x3ddc2
   3df6a:	f3f9                	c.bnez	a5,0x3df30
   3df6c:	bda9                	c.j	0x3ddc6
   3df6e:	f3f9                	c.bnez	a5,0x3df34
   3df70:	bda9                	c.j	0x3ddca
   3df72:	f3f9                	c.bnez	a5,0x3df38
   3df74:	bda9                	c.j	0x3ddce
   3df76:	f3f9                	c.bnez	a5,0x3df3c
   3df78:	bda9                	c.j	0x3ddd2
   3df7a:	f3f9                	c.bnez	a5,0x3df40
   3df7c:	bda9                	c.j	0x3ddd6
   3df7e:	f3f9                	c.bnez	a5,0x3df44
   3df80:	bda9                	c.j	0x3ddda
   3df82:	f3f9                	c.bnez	a5,0x3df48
   3df84:	bda9                	c.j	0x3ddde
   3df86:	f3f9                	c.bnez	a5,0x3df4c
   3df88:	bda9                	c.j	0x3dde2
   3df8a:	f3f9                	c.bnez	a5,0x3df50
   3df8c:	bda9                	c.j	0x3dde6
   3df8e:	f3f9                	c.bnez	a5,0x3df54
   3df90:	bda9                	c.j	0x3ddea
   3df92:	f3f9                	c.bnez	a5,0x3df58
   3df94:	bda9                	c.j	0x3ddee
   3df96:	f3f9                	c.bnez	a5,0x3df5c
   3df98:	bda9                	c.j	0x3ddf2
   3df9a:	f3f9                	c.bnez	a5,0x3df60
   3df9c:	bda9                	c.j	0x3ddf6
   3df9e:	f3f9                	c.bnez	a5,0x3df64
   3dfa0:	bda9                	c.j	0x3ddfa
   3dfa2:	f3f9                	c.bnez	a5,0x3df68
   3dfa4:	bda9                	c.j	0x3ddfe
   3dfa6:	f3f9                	c.bnez	a5,0x3df6c
   3dfa8:	bda9                	c.j	0x3de02
   3dfaa:	f3f9                	c.bnez	a5,0x3df70
   3dfac:	bda9                	c.j	0x3de06
   3dfae:	f3f9                	c.bnez	a5,0x3df74
   3dfb0:	bda9                	c.j	0x3de0a
   3dfb2:	f3f9                	c.bnez	a5,0x3df78
   3dfb4:	bda9                	c.j	0x3de0e
   3dfb6:	f3f9                	c.bnez	a5,0x3df7c
   3dfb8:	bda9                	c.j	0x3de12
   3dfba:	f3f9                	c.bnez	a5,0x3df80
   3dfbc:	bda9                	c.j	0x3de16
   3dfbe:	f3f9                	c.bnez	a5,0x3df84
   3dfc0:	bda9                	c.j	0x3de1a
   3dfc2:	f3f9                	c.bnez	a5,0x3df88
   3dfc4:	bda9                	c.j	0x3de1e
   3dfc6:	f3f9                	c.bnez	a5,0x3df8c
   3dfc8:	bda9                	c.j	0x3de22
   3dfca:	f3f9                	c.bnez	a5,0x3df90
   3dfcc:	bda9                	c.j	0x3de26
   3dfce:	f3f9                	c.bnez	a5,0x3df94
   3dfd0:	bda9                	c.j	0x3de2a
   3dfd2:	f3f9                	c.bnez	a5,0x3df98
   3dfd4:	bda9                	c.j	0x3de2e
   3dfd6:	f3f9                	c.bnez	a5,0x3df9c
   3dfd8:	bda9                	c.j	0x3de32
   3dfda:	f3f9                	c.bnez	a5,0x3dfa0
   3dfdc:	bda9                	c.j	0x3de36
   3dfde:	f3f9                	c.bnez	a5,0x3dfa4
   3dfe0:	bda9                	c.j	0x3de3a
   3dfe2:	f3f9                	c.bnez	a5,0x3dfa8
