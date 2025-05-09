(*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT-0
 *)

(* ========================================================================= *)
(* Scalar multiplication for NIST P-256.                                     *)
(* ========================================================================= *)

needs "x86/proofs/base.ml";;
needs "common/ecencoding.ml";;
needs "EC/jacobian.ml";;
needs "EC/nistp256.ml";;

prioritize_int();;
prioritize_real();;
prioritize_num();;

needs "x86/proofs/p256_montjadd_alt.ml";;
needs "x86/proofs/p256_montjdouble_alt.ml";;

(* ------------------------------------------------------------------------- *)
(* Code.                                                                     *)
(* ------------------------------------------------------------------------- *)

(**** print_literal_from_elf "x86/p256/p256_montjscalarmul_alt.o";;
 ****)

let p256_montjscalarmul_alt_mc = define_assert_from_elf
  "p256_montjscalarmul_alt_mc" "x86/p256/p256_montjscalarmul_alt.o"
[
  0xf3; 0x0f; 0x1e; 0xfa;  (* ENDBR64 *)
  0x41; 0x57;              (* PUSH (% r15) *)
  0x41; 0x56;              (* PUSH (% r14) *)
  0x41; 0x55;              (* PUSH (% r13) *)
  0x41; 0x54;              (* PUSH (% r12) *)
  0x55;                    (* PUSH (% rbp) *)
  0x53;                    (* PUSH (% rbx) *)
  0x48; 0x81; 0xec; 0x00; 0x04; 0x00; 0x00;
                           (* SUB (% rsp) (Imm32 (word 1024)) *)
  0x48; 0x89; 0xd3;        (* MOV (% rbx) (% rdx) *)
  0x48; 0x89; 0xbc; 0x24; 0xe0; 0x03; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,992))) (% rdi) *)
  0x49; 0xbc; 0x51; 0x25; 0x63; 0xfc; 0xc2; 0xca; 0xb9; 0xf3;
                           (* MOV (% r12) (Imm64 (word 17562291160714782033)) *)
  0x49; 0xbd; 0x84; 0x9e; 0x17; 0xa7; 0xad; 0xfa; 0xe6; 0xbc;
                           (* MOV (% r13) (Imm64 (word 13611842547513532036)) *)
  0x49; 0xc7; 0xc6; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r14) (Imm32 (word 4294967295)) *)
  0x49; 0xbf; 0x00; 0x00; 0x00; 0x00; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r15) (Imm64 (word 18446744069414584320)) *)
  0x4c; 0x8b; 0x06;        (* MOV (% r8) (Memop Quadword (%% (rsi,0))) *)
  0x4d; 0x29; 0xe0;        (* SUB (% r8) (% r12) *)
  0x4c; 0x8b; 0x4e; 0x08;  (* MOV (% r9) (Memop Quadword (%% (rsi,8))) *)
  0x4d; 0x19; 0xe9;        (* SBB (% r9) (% r13) *)
  0x4c; 0x8b; 0x56; 0x10;  (* MOV (% r10) (Memop Quadword (%% (rsi,16))) *)
  0x4d; 0x19; 0xf2;        (* SBB (% r10) (% r14) *)
  0x4c; 0x8b; 0x5e; 0x18;  (* MOV (% r11) (Memop Quadword (%% (rsi,24))) *)
  0x4d; 0x19; 0xfb;        (* SBB (% r11) (% r15) *)
  0x4c; 0x0f; 0x42; 0x06;  (* CMOVB (% r8) (Memop Quadword (%% (rsi,0))) *)
  0x4c; 0x0f; 0x42; 0x4e; 0x08;
                           (* CMOVB (% r9) (Memop Quadword (%% (rsi,8))) *)
  0x4c; 0x0f; 0x42; 0x56; 0x10;
                           (* CMOVB (% r10) (Memop Quadword (%% (rsi,16))) *)
  0x4c; 0x0f; 0x42; 0x5e; 0x18;
                           (* CMOVB (% r11) (Memop Quadword (%% (rsi,24))) *)
  0x4d; 0x29; 0xc4;        (* SUB (% r12) (% r8) *)
  0x4d; 0x19; 0xcd;        (* SBB (% r13) (% r9) *)
  0x4d; 0x19; 0xd6;        (* SBB (% r14) (% r10) *)
  0x4d; 0x19; 0xdf;        (* SBB (% r15) (% r11) *)
  0x4c; 0x89; 0xdd;        (* MOV (% rbp) (% r11) *)
  0x48; 0xc1; 0xed; 0x3f;  (* SHR (% rbp) (Imm8 (word 63)) *)
  0x4d; 0x0f; 0x45; 0xc4;  (* CMOVNE (% r8) (% r12) *)
  0x4d; 0x0f; 0x45; 0xcd;  (* CMOVNE (% r9) (% r13) *)
  0x4d; 0x0f; 0x45; 0xd6;  (* CMOVNE (% r10) (% r14) *)
  0x4d; 0x0f; 0x45; 0xdf;  (* CMOVNE (% r11) (% r15) *)
  0x48; 0xb8; 0x88; 0x88; 0x88; 0x88; 0x88; 0x88; 0x88; 0x88;
                           (* MOV (% rax) (Imm64 (word 9838263505978427528)) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xc1;        (* ADC (% r9) (% rax) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0x49; 0x11; 0xc3;        (* ADC (% r11) (% rax) *)
  0x49; 0x0f; 0xba; 0xfb; 0x3f;
                           (* BTC (% r11) (Imm8 (word 63)) *)
  0x4c; 0x89; 0x04; 0x24;  (* MOV (Memop Quadword (%% (rsp,0))) (% r8) *)
  0x4c; 0x89; 0x4c; 0x24; 0x08;
                           (* MOV (Memop Quadword (%% (rsp,8))) (% r9) *)
  0x4c; 0x89; 0x54; 0x24; 0x10;
                           (* MOV (Memop Quadword (%% (rsp,16))) (% r10) *)
  0x4c; 0x89; 0x5c; 0x24; 0x18;
                           (* MOV (Memop Quadword (%% (rsp,24))) (% r11) *)
  0x48; 0x8b; 0x03;        (* MOV (% rax) (Memop Quadword (%% (rbx,0))) *)
  0x48; 0x89; 0x84; 0x24; 0xe0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,224))) (% rax) *)
  0x48; 0x8b; 0x43; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rbx,8))) *)
  0x48; 0x89; 0x84; 0x24; 0xe8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,232))) (% rax) *)
  0x48; 0x8b; 0x43; 0x10;  (* MOV (% rax) (Memop Quadword (%% (rbx,16))) *)
  0x48; 0x89; 0x84; 0x24; 0xf0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,240))) (% rax) *)
  0x48; 0x8b; 0x43; 0x18;  (* MOV (% rax) (Memop Quadword (%% (rbx,24))) *)
  0x48; 0x89; 0x84; 0x24; 0xf8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,248))) (% rax) *)
  0x4c; 0x8b; 0x63; 0x20;  (* MOV (% r12) (Memop Quadword (%% (rbx,32))) *)
  0x4c; 0x89; 0xe0;        (* MOV (% rax) (% r12) *)
  0x4c; 0x8b; 0x6b; 0x28;  (* MOV (% r13) (Memop Quadword (%% (rbx,40))) *)
  0x4c; 0x09; 0xe8;        (* OR (% rax) (% r13) *)
  0x4c; 0x8b; 0x73; 0x30;  (* MOV (% r14) (Memop Quadword (%% (rbx,48))) *)
  0x4c; 0x89; 0xf1;        (* MOV (% rcx) (% r14) *)
  0x4c; 0x8b; 0x7b; 0x38;  (* MOV (% r15) (Memop Quadword (%% (rbx,56))) *)
  0x4c; 0x09; 0xf9;        (* OR (% rcx) (% r15) *)
  0x48; 0x09; 0xc8;        (* OR (% rax) (% rcx) *)
  0x48; 0x0f; 0x44; 0xe8;  (* CMOVE (% rbp) (% rax) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x4d; 0x8d; 0x42; 0xff;  (* LEA (% r8) (%% (r10,18446744073709551615)) *)
  0x49; 0xbb; 0xff; 0xff; 0xff; 0xff; 0x00; 0x00; 0x00; 0x00;
                           (* MOV (% r11) (Imm64 (word 4294967295)) *)
  0x4d; 0x89; 0xd9;        (* MOV (% r9) (% r11) *)
  0x49; 0xf7; 0xdb;        (* NEG (% r11) *)
  0x4d; 0x29; 0xe0;        (* SUB (% r8) (% r12) *)
  0x4d; 0x19; 0xe9;        (* SBB (% r9) (% r13) *)
  0x4d; 0x19; 0xf2;        (* SBB (% r10) (% r14) *)
  0x4d; 0x19; 0xfb;        (* SBB (% r11) (% r15) *)
  0x48; 0x85; 0xed;        (* TEST (% rbp) (% rbp) *)
  0x4d; 0x0f; 0x44; 0xc4;  (* CMOVE (% r8) (% r12) *)
  0x4d; 0x0f; 0x44; 0xcd;  (* CMOVE (% r9) (% r13) *)
  0x4d; 0x0f; 0x44; 0xd6;  (* CMOVE (% r10) (% r14) *)
  0x4d; 0x0f; 0x44; 0xdf;  (* CMOVE (% r11) (% r15) *)
  0x4c; 0x89; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,256))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,264))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,272))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,280))) (% r11) *)
  0x48; 0x8b; 0x43; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rbx,64))) *)
  0x48; 0x89; 0x84; 0x24; 0x20; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,288))) (% rax) *)
  0x48; 0x8b; 0x43; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rbx,72))) *)
  0x48; 0x89; 0x84; 0x24; 0x28; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,296))) (% rax) *)
  0x48; 0x8b; 0x43; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rbx,80))) *)
  0x48; 0x89; 0x84; 0x24; 0x30; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,304))) (% rax) *)
  0x48; 0x8b; 0x43; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rbx,88))) *)
  0x48; 0x89; 0x84; 0x24; 0x38; 0x01; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,312))) (% rax) *)
  0x48; 0x8d; 0xbc; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* LEA (% rdi) (%% (rsp,320)) *)
  0x48; 0x8d; 0xb4; 0x24; 0xe0; 0x00; 0x00; 0x00;
                           (* LEA (% rsi) (%% (rsp,224)) *)
  0xe8; 0x38; 0x31; 0x00; 0x00;
                           (* CALL (Imm32 (word 12600)) *)
  0x48; 0x8d; 0xbc; 0x24; 0xa0; 0x01; 0x00; 0x00;
                           (* LEA (% rdi) (%% (rsp,416)) *)
  0x48; 0x8d; 0xb4; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* LEA (% rsi) (%% (rsp,320)) *)
  0x48; 0x8d; 0x94; 0x24; 0xe0; 0x00; 0x00; 0x00;
                           (* LEA (% rdx) (%% (rsp,224)) *)
  0xe8; 0xb3; 0x09; 0x00; 0x00;
                           (* CALL (Imm32 (word 2483)) *)
  0x48; 0x8d; 0xbc; 0x24; 0x00; 0x02; 0x00; 0x00;
                           (* LEA (% rdi) (%% (rsp,512)) *)
  0x48; 0x8d; 0xb4; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* LEA (% rsi) (%% (rsp,320)) *)
  0xe8; 0x06; 0x31; 0x00; 0x00;
                           (* CALL (Imm32 (word 12550)) *)
  0x48; 0x8d; 0xbc; 0x24; 0x60; 0x02; 0x00; 0x00;
                           (* LEA (% rdi) (%% (rsp,608)) *)
  0x48; 0x8d; 0xb4; 0x24; 0x00; 0x02; 0x00; 0x00;
                           (* LEA (% rsi) (%% (rsp,512)) *)
  0x48; 0x8d; 0x94; 0x24; 0xe0; 0x00; 0x00; 0x00;
                           (* LEA (% rdx) (%% (rsp,224)) *)
  0xe8; 0x81; 0x09; 0x00; 0x00;
                           (* CALL (Imm32 (word 2433)) *)
  0x48; 0x8d; 0xbc; 0x24; 0xc0; 0x02; 0x00; 0x00;
                           (* LEA (% rdi) (%% (rsp,704)) *)
  0x48; 0x8d; 0xb4; 0x24; 0xa0; 0x01; 0x00; 0x00;
                           (* LEA (% rsi) (%% (rsp,416)) *)
  0xe8; 0xd4; 0x30; 0x00; 0x00;
                           (* CALL (Imm32 (word 12500)) *)
  0x48; 0x8d; 0xbc; 0x24; 0x20; 0x03; 0x00; 0x00;
                           (* LEA (% rdi) (%% (rsp,800)) *)
  0x48; 0x8d; 0xb4; 0x24; 0xc0; 0x02; 0x00; 0x00;
                           (* LEA (% rsi) (%% (rsp,704)) *)
  0x48; 0x8d; 0x94; 0x24; 0xe0; 0x00; 0x00; 0x00;
                           (* LEA (% rdx) (%% (rsp,224)) *)
  0xe8; 0x4f; 0x09; 0x00; 0x00;
                           (* CALL (Imm32 (word 2383)) *)
  0x48; 0x8d; 0xbc; 0x24; 0x80; 0x03; 0x00; 0x00;
                           (* LEA (% rdi) (%% (rsp,896)) *)
  0x48; 0x8d; 0xb4; 0x24; 0x00; 0x02; 0x00; 0x00;
                           (* LEA (% rsi) (%% (rsp,512)) *)
  0xe8; 0xa2; 0x30; 0x00; 0x00;
                           (* CALL (Imm32 (word 12450)) *)
  0x48; 0x8b; 0x7c; 0x24; 0x18;
                           (* MOV (% rdi) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xc1; 0xef; 0x3c;  (* SHR (% rdi) (Imm8 (word 60)) *)
  0x31; 0xc0;              (* XOR (% eax) (% eax) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x31; 0xd2;              (* XOR (% edx) (% edx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x83; 0xff; 0x01;  (* CMP (% rdi) (Imm8 (word 1)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0xe0; 0x00; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,224))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0xe8; 0x00; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,232))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0xf0; 0x00; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,240))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0xf8; 0x00; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,248))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,256))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,264))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,272))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,280))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0x20; 0x01; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,288))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0x28; 0x01; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,296))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0x30; 0x01; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,304))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0x38; 0x01; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,312))) *)
  0x48; 0x83; 0xff; 0x02;  (* CMP (% rdi) (Imm8 (word 2)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,320))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,328))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,336))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,344))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0x60; 0x01; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,352))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,360))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0x70; 0x01; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,368))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,376))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0x80; 0x01; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,384))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0x88; 0x01; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,392))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0x90; 0x01; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,400))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0x98; 0x01; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,408))) *)
  0x48; 0x83; 0xff; 0x03;  (* CMP (% rdi) (Imm8 (word 3)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0xa0; 0x01; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,416))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0xa8; 0x01; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,424))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0xb0; 0x01; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,432))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0xb8; 0x01; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,440))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0xc0; 0x01; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,448))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0xc8; 0x01; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,456))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0xd0; 0x01; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,464))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0xd8; 0x01; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,472))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0xe0; 0x01; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,480))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0xe8; 0x01; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,488))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0xf0; 0x01; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,496))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0xf8; 0x01; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,504))) *)
  0x48; 0x83; 0xff; 0x04;  (* CMP (% rdi) (Imm8 (word 4)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0x00; 0x02; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,512))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0x08; 0x02; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,520))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0x10; 0x02; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,528))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0x18; 0x02; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,536))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0x20; 0x02; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,544))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0x28; 0x02; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,552))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0x30; 0x02; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,560))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0x38; 0x02; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,568))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0x40; 0x02; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,576))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0x48; 0x02; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,584))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0x50; 0x02; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,592))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0x58; 0x02; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,600))) *)
  0x48; 0x83; 0xff; 0x05;  (* CMP (% rdi) (Imm8 (word 5)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0x60; 0x02; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,608))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0x68; 0x02; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,616))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0x70; 0x02; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,624))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0x78; 0x02; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,632))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0x80; 0x02; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,640))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0x88; 0x02; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,648))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0x90; 0x02; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,656))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0x98; 0x02; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,664))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0xa0; 0x02; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,672))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0xa8; 0x02; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,680))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0xb0; 0x02; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,688))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0xb8; 0x02; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,696))) *)
  0x48; 0x83; 0xff; 0x06;  (* CMP (% rdi) (Imm8 (word 6)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0xc0; 0x02; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,704))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0xc8; 0x02; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,712))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0xd0; 0x02; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,720))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0xd8; 0x02; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,728))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0xe0; 0x02; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,736))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0xe8; 0x02; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,744))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0xf0; 0x02; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,752))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0xf8; 0x02; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,760))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0x00; 0x03; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,768))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0x08; 0x03; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,776))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0x10; 0x03; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,784))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0x18; 0x03; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,792))) *)
  0x48; 0x83; 0xff; 0x07;  (* CMP (% rdi) (Imm8 (word 7)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0x20; 0x03; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,800))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0x28; 0x03; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,808))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0x30; 0x03; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,816))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0x38; 0x03; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,824))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0x40; 0x03; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,832))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0x48; 0x03; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,840))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0x50; 0x03; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,848))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0x58; 0x03; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,856))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0x60; 0x03; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,864))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0x68; 0x03; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,872))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0x70; 0x03; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,880))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0x78; 0x03; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,888))) *)
  0x48; 0x83; 0xff; 0x08;  (* CMP (% rdi) (Imm8 (word 8)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0x80; 0x03; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,896))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0x88; 0x03; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,904))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0x90; 0x03; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,912))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0x98; 0x03; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,920))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0xa0; 0x03; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,928))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0xa8; 0x03; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,936))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0xb0; 0x03; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,944))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0xb8; 0x03; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,952))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0xc0; 0x03; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,960))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0xc8; 0x03; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,968))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0xd0; 0x03; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,976))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0xd8; 0x03; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,984))) *)
  0x48; 0x89; 0x44; 0x24; 0x20;
                           (* MOV (Memop Quadword (%% (rsp,32))) (% rax) *)
  0x48; 0x89; 0x5c; 0x24; 0x28;
                           (* MOV (Memop Quadword (%% (rsp,40))) (% rbx) *)
  0x48; 0x89; 0x4c; 0x24; 0x30;
                           (* MOV (Memop Quadword (%% (rsp,48))) (% rcx) *)
  0x48; 0x89; 0x54; 0x24; 0x38;
                           (* MOV (Memop Quadword (%% (rsp,56))) (% rdx) *)
  0x4c; 0x89; 0x44; 0x24; 0x40;
                           (* MOV (Memop Quadword (%% (rsp,64))) (% r8) *)
  0x4c; 0x89; 0x4c; 0x24; 0x48;
                           (* MOV (Memop Quadword (%% (rsp,72))) (% r9) *)
  0x4c; 0x89; 0x54; 0x24; 0x50;
                           (* MOV (Memop Quadword (%% (rsp,80))) (% r10) *)
  0x4c; 0x89; 0x5c; 0x24; 0x58;
                           (* MOV (Memop Quadword (%% (rsp,88))) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% r15) *)
  0xbd; 0xfc; 0x00; 0x00; 0x00;
                           (* MOV (% ebp) (Imm32 (word 252)) *)
  0x48; 0x83; 0xed; 0x04;  (* SUB (% rbp) (Imm8 (word 4)) *)
  0x48; 0x8d; 0x74; 0x24; 0x20;
                           (* LEA (% rsi) (%% (rsp,32)) *)
  0x48; 0x8d; 0x7c; 0x24; 0x20;
                           (* LEA (% rdi) (%% (rsp,32)) *)
  0xe8; 0xa5; 0x2c; 0x00; 0x00;
                           (* CALL (Imm32 (word 11429)) *)
  0x48; 0x8d; 0x74; 0x24; 0x20;
                           (* LEA (% rsi) (%% (rsp,32)) *)
  0x48; 0x8d; 0x7c; 0x24; 0x20;
                           (* LEA (% rdi) (%% (rsp,32)) *)
  0xe8; 0x96; 0x2c; 0x00; 0x00;
                           (* CALL (Imm32 (word 11414)) *)
  0x48; 0x8d; 0x74; 0x24; 0x20;
                           (* LEA (% rsi) (%% (rsp,32)) *)
  0x48; 0x8d; 0x7c; 0x24; 0x20;
                           (* LEA (% rdi) (%% (rsp,32)) *)
  0xe8; 0x87; 0x2c; 0x00; 0x00;
                           (* CALL (Imm32 (word 11399)) *)
  0x48; 0x8d; 0x74; 0x24; 0x20;
                           (* LEA (% rsi) (%% (rsp,32)) *)
  0x48; 0x8d; 0x7c; 0x24; 0x20;
                           (* LEA (% rdi) (%% (rsp,32)) *)
  0xe8; 0x78; 0x2c; 0x00; 0x00;
                           (* CALL (Imm32 (word 11384)) *)
  0x48; 0x89; 0xe8;        (* MOV (% rax) (% rbp) *)
  0x48; 0xc1; 0xe8; 0x06;  (* SHR (% rax) (Imm8 (word 6)) *)
  0x48; 0x8b; 0x3c; 0xc4;  (* MOV (% rdi) (Memop Quadword (%%% (rsp,3,rax))) *)
  0x48; 0x89; 0xe9;        (* MOV (% rcx) (% rbp) *)
  0x48; 0xd3; 0xef;        (* SHR (% rdi) (% cl) *)
  0x48; 0x83; 0xe7; 0x0f;  (* AND (% rdi) (Imm8 (word 15)) *)
  0x48; 0x83; 0xef; 0x08;  (* SUB (% rdi) (Imm8 (word 8)) *)
  0x48; 0x19; 0xf6;        (* SBB (% rsi) (% rsi) *)
  0x48; 0x31; 0xf7;        (* XOR (% rdi) (% rsi) *)
  0x48; 0x29; 0xf7;        (* SUB (% rdi) (% rsi) *)
  0x31; 0xc0;              (* XOR (% eax) (% eax) *)
  0x31; 0xdb;              (* XOR (% ebx) (% ebx) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x31; 0xd2;              (* XOR (% edx) (% edx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x83; 0xff; 0x01;  (* CMP (% rdi) (Imm8 (word 1)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0xe0; 0x00; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,224))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0xe8; 0x00; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,232))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0xf0; 0x00; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,240))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0xf8; 0x00; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,248))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0x00; 0x01; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,256))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0x08; 0x01; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,264))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0x10; 0x01; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,272))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0x18; 0x01; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,280))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0x20; 0x01; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,288))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0x28; 0x01; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,296))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0x30; 0x01; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,304))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0x38; 0x01; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,312))) *)
  0x48; 0x83; 0xff; 0x02;  (* CMP (% rdi) (Imm8 (word 2)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0x40; 0x01; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,320))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0x48; 0x01; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,328))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0x50; 0x01; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,336))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0x58; 0x01; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,344))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0x60; 0x01; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,352))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0x68; 0x01; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,360))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0x70; 0x01; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,368))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0x78; 0x01; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,376))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0x80; 0x01; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,384))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0x88; 0x01; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,392))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0x90; 0x01; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,400))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0x98; 0x01; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,408))) *)
  0x48; 0x83; 0xff; 0x03;  (* CMP (% rdi) (Imm8 (word 3)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0xa0; 0x01; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,416))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0xa8; 0x01; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,424))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0xb0; 0x01; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,432))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0xb8; 0x01; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,440))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0xc0; 0x01; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,448))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0xc8; 0x01; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,456))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0xd0; 0x01; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,464))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0xd8; 0x01; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,472))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0xe0; 0x01; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,480))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0xe8; 0x01; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,488))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0xf0; 0x01; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,496))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0xf8; 0x01; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,504))) *)
  0x48; 0x83; 0xff; 0x04;  (* CMP (% rdi) (Imm8 (word 4)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0x00; 0x02; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,512))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0x08; 0x02; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,520))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0x10; 0x02; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,528))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0x18; 0x02; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,536))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0x20; 0x02; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,544))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0x28; 0x02; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,552))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0x30; 0x02; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,560))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0x38; 0x02; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,568))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0x40; 0x02; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,576))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0x48; 0x02; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,584))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0x50; 0x02; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,592))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0x58; 0x02; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,600))) *)
  0x48; 0x83; 0xff; 0x05;  (* CMP (% rdi) (Imm8 (word 5)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0x60; 0x02; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,608))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0x68; 0x02; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,616))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0x70; 0x02; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,624))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0x78; 0x02; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,632))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0x80; 0x02; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,640))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0x88; 0x02; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,648))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0x90; 0x02; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,656))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0x98; 0x02; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,664))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0xa0; 0x02; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,672))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0xa8; 0x02; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,680))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0xb0; 0x02; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,688))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0xb8; 0x02; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,696))) *)
  0x48; 0x83; 0xff; 0x06;  (* CMP (% rdi) (Imm8 (word 6)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0xc0; 0x02; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,704))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0xc8; 0x02; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,712))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0xd0; 0x02; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,720))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0xd8; 0x02; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,728))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0xe0; 0x02; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,736))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0xe8; 0x02; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,744))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0xf0; 0x02; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,752))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0xf8; 0x02; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,760))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0x00; 0x03; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,768))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0x08; 0x03; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,776))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0x10; 0x03; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,784))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0x18; 0x03; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,792))) *)
  0x48; 0x83; 0xff; 0x07;  (* CMP (% rdi) (Imm8 (word 7)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0x20; 0x03; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,800))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0x28; 0x03; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,808))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0x30; 0x03; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,816))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0x38; 0x03; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,824))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0x40; 0x03; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,832))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0x48; 0x03; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,840))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0x50; 0x03; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,848))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0x58; 0x03; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,856))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0x60; 0x03; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,864))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0x68; 0x03; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,872))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0x70; 0x03; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,880))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0x78; 0x03; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,888))) *)
  0x48; 0x83; 0xff; 0x08;  (* CMP (% rdi) (Imm8 (word 8)) *)
  0x48; 0x0f; 0x44; 0x84; 0x24; 0x80; 0x03; 0x00; 0x00;
                           (* CMOVE (% rax) (Memop Quadword (%% (rsp,896))) *)
  0x48; 0x0f; 0x44; 0x9c; 0x24; 0x88; 0x03; 0x00; 0x00;
                           (* CMOVE (% rbx) (Memop Quadword (%% (rsp,904))) *)
  0x48; 0x0f; 0x44; 0x8c; 0x24; 0x90; 0x03; 0x00; 0x00;
                           (* CMOVE (% rcx) (Memop Quadword (%% (rsp,912))) *)
  0x48; 0x0f; 0x44; 0x94; 0x24; 0x98; 0x03; 0x00; 0x00;
                           (* CMOVE (% rdx) (Memop Quadword (%% (rsp,920))) *)
  0x4c; 0x0f; 0x44; 0x84; 0x24; 0xa0; 0x03; 0x00; 0x00;
                           (* CMOVE (% r8) (Memop Quadword (%% (rsp,928))) *)
  0x4c; 0x0f; 0x44; 0x8c; 0x24; 0xa8; 0x03; 0x00; 0x00;
                           (* CMOVE (% r9) (Memop Quadword (%% (rsp,936))) *)
  0x4c; 0x0f; 0x44; 0x94; 0x24; 0xb0; 0x03; 0x00; 0x00;
                           (* CMOVE (% r10) (Memop Quadword (%% (rsp,944))) *)
  0x4c; 0x0f; 0x44; 0x9c; 0x24; 0xb8; 0x03; 0x00; 0x00;
                           (* CMOVE (% r11) (Memop Quadword (%% (rsp,952))) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0xc0; 0x03; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,960))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0xc8; 0x03; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,968))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0xd0; 0x03; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,976))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0xd8; 0x03; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,984))) *)
  0x48; 0x89; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,128))) (% rax) *)
  0x48; 0x89; 0x9c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,136))) (% rbx) *)
  0x48; 0x89; 0x8c; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,144))) (% rcx) *)
  0x48; 0x89; 0x94; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,152))) (% rdx) *)
  0x4c; 0x89; 0xa4; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,192))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,200))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,208))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,216))) (% r15) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x4c; 0x09; 0xc8;        (* OR (% rax) (% r9) *)
  0x4d; 0x8d; 0x66; 0xff;  (* LEA (% r12) (%% (r14,18446744073709551615)) *)
  0x4c; 0x89; 0xd1;        (* MOV (% rcx) (% r10) *)
  0x49; 0xbf; 0xff; 0xff; 0xff; 0xff; 0x00; 0x00; 0x00; 0x00;
                           (* MOV (% r15) (Imm64 (word 4294967295)) *)
  0x4c; 0x09; 0xd9;        (* OR (% rcx) (% r11) *)
  0x4d; 0x89; 0xfd;        (* MOV (% r13) (% r15) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x48; 0x09; 0xc8;        (* OR (% rax) (% rcx) *)
  0x48; 0x0f; 0x44; 0xf0;  (* CMOVE (% rsi) (% rax) *)
  0x4d; 0x29; 0xc4;        (* SUB (% r12) (% r8) *)
  0x4d; 0x19; 0xcd;        (* SBB (% r13) (% r9) *)
  0x4d; 0x19; 0xd6;        (* SBB (% r14) (% r10) *)
  0x4d; 0x19; 0xdf;        (* SBB (% r15) (% r11) *)
  0x48; 0x85; 0xf6;        (* TEST (% rsi) (% rsi) *)
  0x4d; 0x0f; 0x45; 0xc4;  (* CMOVNE (% r8) (% r12) *)
  0x4d; 0x0f; 0x45; 0xcd;  (* CMOVNE (% r9) (% r13) *)
  0x4d; 0x0f; 0x45; 0xd6;  (* CMOVNE (% r10) (% r14) *)
  0x4d; 0x0f; 0x45; 0xdf;  (* CMOVNE (% r11) (% r15) *)
  0x4c; 0x89; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% r8) *)
  0x4c; 0x89; 0x8c; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% r9) *)
  0x4c; 0x89; 0x94; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% r10) *)
  0x4c; 0x89; 0x9c; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% r11) *)
  0x48; 0x8d; 0x94; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* LEA (% rdx) (%% (rsp,128)) *)
  0x48; 0x8d; 0x74; 0x24; 0x20;
                           (* LEA (% rsi) (%% (rsp,32)) *)
  0x48; 0x8d; 0x7c; 0x24; 0x20;
                           (* LEA (% rdi) (%% (rsp,32)) *)
  0xe8; 0x8e; 0x00; 0x00; 0x00;
                           (* CALL (Imm32 (word 142)) *)
  0x48; 0x85; 0xed;        (* TEST (% rbp) (% rbp) *)
  0x0f; 0x85; 0x35; 0xfb; 0xff; 0xff;
                           (* JNE (Imm32 (word 4294966069)) *)
  0x48; 0x8b; 0xbc; 0x24; 0xe0; 0x03; 0x00; 0x00;
                           (* MOV (% rdi) (Memop Quadword (%% (rsp,992))) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0x89; 0x07;        (* MOV (Memop Quadword (%% (rdi,0))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0x89; 0x47; 0x08;  (* MOV (Memop Quadword (%% (rdi,8))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,48))) *)
  0x48; 0x89; 0x47; 0x10;  (* MOV (Memop Quadword (%% (rdi,16))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,56))) *)
  0x48; 0x89; 0x47; 0x18;  (* MOV (Memop Quadword (%% (rdi,24))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0x89; 0x47; 0x20;  (* MOV (Memop Quadword (%% (rdi,32))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x48;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0x89; 0x47; 0x28;  (* MOV (Memop Quadword (%% (rdi,40))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,80))) *)
  0x48; 0x89; 0x47; 0x30;  (* MOV (Memop Quadword (%% (rdi,48))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x58;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,88))) *)
  0x48; 0x89; 0x47; 0x38;  (* MOV (Memop Quadword (%% (rdi,56))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0x89; 0x47; 0x40;  (* MOV (Memop Quadword (%% (rdi,64))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0x89; 0x47; 0x48;  (* MOV (Memop Quadword (%% (rdi,72))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0x89; 0x47; 0x50;  (* MOV (Memop Quadword (%% (rdi,80))) (% rax) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0x89; 0x47; 0x58;  (* MOV (Memop Quadword (%% (rdi,88))) (% rax) *)
  0x48; 0x81; 0xc4; 0x00; 0x04; 0x00; 0x00;
                           (* ADD (% rsp) (Imm32 (word 1024)) *)
  0x5b;                    (* POP (% rbx) *)
  0x5d;                    (* POP (% rbp) *)
  0x41; 0x5c;              (* POP (% r12) *)
  0x41; 0x5d;              (* POP (% r13) *)
  0x41; 0x5e;              (* POP (% r14) *)
  0x41; 0x5f;              (* POP (% r15) *)
  0xc3;                    (* RET *)
  0x53;                    (* PUSH (% rbx) *)
  0x55;                    (* PUSH (% rbp) *)
  0x41; 0x54;              (* PUSH (% r12) *)
  0x41; 0x55;              (* PUSH (% r13) *)
  0x41; 0x56;              (* PUSH (% r14) *)
  0x41; 0x57;              (* PUSH (% r15) *)
  0x48; 0x81; 0xec; 0xe0; 0x00; 0x00; 0x00;
                           (* SUB (% rsp) (Imm32 (word 224)) *)
  0x48; 0x89; 0xd5;        (* MOV (% rbp) (% rdx) *)
  0x48; 0x8b; 0x46; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc1;        (* MOV (% r9) (% rax) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x48; 0x8b; 0x46; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rsi,88))) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc3;        (* MOV (% r11) (% rax) *)
  0x49; 0x89; 0xd4;        (* MOV (% r12) (% rdx) *)
  0x48; 0x8b; 0x46; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rsi,80))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x49; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% r13) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x49; 0x89; 0xd6;        (* MOV (% r14) (% rdx) *)
  0x48; 0x8b; 0x46; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x5e; 0x58;  (* MOV (% rbx) (Memop Quadword (%% (rsi,88))) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x49; 0x83; 0xd6; 0x00;  (* ADC (% r14) (Imm8 (word 0)) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x4d; 0x01; 0xc9;        (* ADD (% r9) (% r9) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xe4;        (* ADC (% r12) (% r12) *)
  0x4d; 0x11; 0xed;        (* ADC (% r13) (% r13) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x11; 0xc9;        (* ADC (% rcx) (% rcx) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x4d; 0x01; 0xf9;        (* ADD (% r9) (% r15) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x46; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rsi,80))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc4;        (* ADC (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x46; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rsi,88))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc6;        (* ADC (% r14) (% rax) *)
  0x48; 0x11; 0xca;        (* ADC (% rdx) (% rcx) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xc6;        (* ADC (% r14) (% r8) *)
  0x4d; 0x11; 0xc7;        (* ADC (% r15) (% r8) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0x8d; 0x5b; 0xff;  (* LEA (% rbx) (%% (rbx,18446744073709551615)) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x4d; 0x8d; 0x49; 0xff;  (* LEA (% r9) (%% (r9,18446744073709551615)) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x24; 0x24;  (* MOV (Memop Quadword (%% (rsp,0))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x08;
                           (* MOV (Memop Quadword (%% (rsp,8))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x10;
                           (* MOV (Memop Quadword (%% (rsp,16))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x18;
                           (* MOV (Memop Quadword (%% (rsp,24))) (% r15) *)
  0x48; 0x8b; 0x45; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rbp,64))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0x8b; 0x45; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rbp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc1;        (* MOV (% r9) (% rax) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x48; 0x8b; 0x45; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rbp,88))) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc3;        (* MOV (% r11) (% rax) *)
  0x49; 0x89; 0xd4;        (* MOV (% r12) (% rdx) *)
  0x48; 0x8b; 0x45; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rbp,80))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x49; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% r13) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x49; 0x89; 0xd6;        (* MOV (% r14) (% rdx) *)
  0x48; 0x8b; 0x45; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rbp,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x45; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rbp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x5d; 0x58;  (* MOV (% rbx) (Memop Quadword (%% (rbp,88))) *)
  0x48; 0x8b; 0x45; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rbp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x49; 0x83; 0xd6; 0x00;  (* ADC (% r14) (Imm8 (word 0)) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x4d; 0x01; 0xc9;        (* ADD (% r9) (% r9) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xe4;        (* ADC (% r12) (% r12) *)
  0x4d; 0x11; 0xed;        (* ADC (% r13) (% r13) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x11; 0xc9;        (* ADC (% rcx) (% rcx) *)
  0x48; 0x8b; 0x45; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rbp,72))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x4d; 0x01; 0xf9;        (* ADD (% r9) (% r15) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x45; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rbp,80))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc4;        (* ADC (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x45; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rbp,88))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc6;        (* ADC (% r14) (% rax) *)
  0x48; 0x11; 0xca;        (* ADC (% rdx) (% rcx) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xc6;        (* ADC (% r14) (% r8) *)
  0x4d; 0x11; 0xc7;        (* ADC (% r15) (% r8) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0x8d; 0x5b; 0xff;  (* LEA (% rbx) (%% (rbx,18446744073709551615)) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x4d; 0x8d; 0x49; 0xff;  (* LEA (% r9) (%% (r9,18446744073709551615)) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% r15) *)
  0x48; 0x8b; 0x5e; 0x20;  (* MOV (% rbx) (Memop Quadword (%% (rsi,32))) *)
  0x48; 0x8b; 0x45; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rbp,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x45; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rbp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x45; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rbp,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x45; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rbp,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5e; 0x28;  (* MOV (% rbx) (Memop Quadword (%% (rsi,40))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x45; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rbp,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x45; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rbp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x45; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rbp,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x45; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rbp,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5e; 0x30;  (* MOV (% rbx) (Memop Quadword (%% (rsi,48))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x45; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rbp,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x45; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rbp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x45; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rbp,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x45; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rbp,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5e; 0x38;  (* MOV (% rbx) (Memop Quadword (%% (rsi,56))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x45; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rbp,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x45; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rbp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x45; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rbp,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x45; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rbp,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,192))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,200))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,208))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,216))) (% r15) *)
  0x48; 0x8b; 0x5d; 0x20;  (* MOV (% rbx) (Memop Quadword (%% (rbp,32))) *)
  0x48; 0x8b; 0x46; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x46; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rsi,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x46; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rsi,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5d; 0x28;  (* MOV (% rbx) (Memop Quadword (%% (rbp,40))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x46; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x46; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rsi,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x46; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rsi,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5d; 0x30;  (* MOV (% rbx) (Memop Quadword (%% (rbp,48))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x46; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x46; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rsi,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x46; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rsi,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5d; 0x38;  (* MOV (% rbx) (Memop Quadword (%% (rbp,56))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x46; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x46; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rsi,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x46; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rsi,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x20;
                           (* MOV (Memop Quadword (%% (rsp,32))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x28;
                           (* MOV (Memop Quadword (%% (rsp,40))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x30;
                           (* MOV (Memop Quadword (%% (rsp,48))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x38;
                           (* MOV (Memop Quadword (%% (rsp,56))) (% r15) *)
  0x48; 0x8b; 0x5d; 0x00;  (* MOV (% rbx) (Memop Quadword (%% (rbp,0))) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x08;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x18;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5d; 0x08;  (* MOV (% rbx) (Memop Quadword (%% (rbp,8))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x08;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x18;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5d; 0x10;  (* MOV (% rbx) (Memop Quadword (%% (rbp,16))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x08;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x18;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5d; 0x18;  (* MOV (% rbx) (Memop Quadword (%% (rbp,24))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x08;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x18;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x40;
                           (* MOV (Memop Quadword (%% (rsp,64))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x48;
                           (* MOV (Memop Quadword (%% (rsp,72))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x50;
                           (* MOV (Memop Quadword (%% (rsp,80))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x58;
                           (* MOV (Memop Quadword (%% (rsp,88))) (% r15) *)
  0x48; 0x8b; 0x1e;        (* MOV (% rbx) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5e; 0x08;  (* MOV (% rbx) (Memop Quadword (%% (rsi,8))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5e; 0x10;  (* MOV (% rbx) (Memop Quadword (%% (rsi,16))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5e; 0x18;  (* MOV (% rbx) (Memop Quadword (%% (rsi,24))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,128))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,136))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,144))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,152))) (% r15) *)
  0x48; 0x8b; 0x5c; 0x24; 0x20;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x08;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x18;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5c; 0x24; 0x28;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,40))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x08;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x18;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5c; 0x24; 0x30;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,48))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x08;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x18;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5c; 0x24; 0x38;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,56))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x08;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x18;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x20;
                           (* MOV (Memop Quadword (%% (rsp,32))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x28;
                           (* MOV (Memop Quadword (%% (rsp,40))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x30;
                           (* MOV (Memop Quadword (%% (rsp,48))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x38;
                           (* MOV (Memop Quadword (%% (rsp,56))) (% r15) *)
  0x48; 0x8b; 0x9c; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,192))) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x9c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,200))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x9c; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,208))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x9c; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,216))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,192))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,200))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,208))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,216))) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0x2b; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* SUB (% rax) (Memop Quadword (%% (rsp,128))) *)
  0x48; 0x8b; 0x4c; 0x24; 0x48;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0x1b; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* SBB (% rcx) (Memop Quadword (%% (rsp,136))) *)
  0x4c; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,80))) *)
  0x4c; 0x1b; 0x84; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* SBB (% r8) (Memop Quadword (%% (rsp,144))) *)
  0x4c; 0x8b; 0x4c; 0x24; 0x58;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,88))) *)
  0x4c; 0x1b; 0x8c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,152))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x8c; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x8c; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0x2b; 0x84; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* SUB (% rax) (Memop Quadword (%% (rsp,192))) *)
  0x48; 0x8b; 0x4c; 0x24; 0x28;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0x1b; 0x8c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* SBB (% rcx) (Memop Quadword (%% (rsp,200))) *)
  0x4c; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,48))) *)
  0x4c; 0x1b; 0x84; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* SBB (% r8) (Memop Quadword (%% (rsp,208))) *)
  0x4c; 0x8b; 0x4c; 0x24; 0x38;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,56))) *)
  0x4c; 0x1b; 0x8c; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,216))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x44; 0x24; 0x20;
                           (* MOV (Memop Quadword (%% (rsp,32))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x4c; 0x24; 0x28;
                           (* MOV (Memop Quadword (%% (rsp,40))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x44; 0x24; 0x30;
                           (* MOV (Memop Quadword (%% (rsp,48))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x4c; 0x24; 0x38;
                           (* MOV (Memop Quadword (%% (rsp,56))) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc1;        (* MOV (% r9) (% rax) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc3;        (* MOV (% r11) (% rax) *)
  0x49; 0x89; 0xd4;        (* MOV (% r12) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x49; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% r13) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x49; 0x89; 0xd6;        (* MOV (% r14) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x9c; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x49; 0x83; 0xd6; 0x00;  (* ADC (% r14) (Imm8 (word 0)) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x4d; 0x01; 0xc9;        (* ADD (% r9) (% r9) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xe4;        (* ADC (% r12) (% r12) *)
  0x4d; 0x11; 0xed;        (* ADC (% r13) (% r13) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x11; 0xc9;        (* ADC (% rcx) (% rcx) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x4d; 0x01; 0xf9;        (* ADD (% r9) (% r15) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc4;        (* ADC (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc6;        (* ADC (% r14) (% rax) *)
  0x48; 0x11; 0xca;        (* ADC (% rdx) (% rcx) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xc6;        (* ADC (% r14) (% r8) *)
  0x4d; 0x11; 0xc7;        (* ADC (% r15) (% r8) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0x8d; 0x5b; 0xff;  (* LEA (% rbx) (%% (rbx,18446744073709551615)) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x4d; 0x8d; 0x49; 0xff;  (* LEA (% r9) (%% (r9,18446744073709551615)) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc1;        (* MOV (% r9) (% rax) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,56))) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc3;        (* MOV (% r11) (% rax) *)
  0x49; 0x89; 0xd4;        (* MOV (% r12) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,48))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x49; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% r13) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x49; 0x89; 0xd6;        (* MOV (% r14) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x5c; 0x24; 0x38;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,56))) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x49; 0x83; 0xd6; 0x00;  (* ADC (% r14) (Imm8 (word 0)) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x4d; 0x01; 0xc9;        (* ADD (% r9) (% r9) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xe4;        (* ADC (% r12) (% r12) *)
  0x4d; 0x11; 0xed;        (* ADC (% r13) (% r13) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x11; 0xc9;        (* ADC (% rcx) (% rcx) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x4d; 0x01; 0xf9;        (* ADD (% r9) (% r15) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,48))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc4;        (* ADC (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,56))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc6;        (* ADC (% r14) (% rax) *)
  0x48; 0x11; 0xca;        (* ADC (% rdx) (% rcx) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xc6;        (* ADC (% r14) (% r8) *)
  0x4d; 0x11; 0xc7;        (* ADC (% r15) (% r8) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0x8d; 0x5b; 0xff;  (* LEA (% rbx) (%% (rbx,18446744073709551615)) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x4d; 0x8d; 0x49; 0xff;  (* LEA (% r9) (%% (r9,18446744073709551615)) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x24; 0x24;  (* MOV (Memop Quadword (%% (rsp,0))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x08;
                           (* MOV (Memop Quadword (%% (rsp,8))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x10;
                           (* MOV (Memop Quadword (%% (rsp,16))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x18;
                           (* MOV (Memop Quadword (%% (rsp,24))) (% r15) *)
  0x48; 0x8b; 0x9c; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,128))) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x9c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,136))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x9c; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,144))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x9c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,152))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,128))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,136))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,144))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,152))) (% r15) *)
  0x48; 0x8b; 0x5c; 0x24; 0x40;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5c; 0x24; 0x48;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,72))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5c; 0x24; 0x50;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,80))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5c; 0x24; 0x58;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,88))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x40;
                           (* MOV (Memop Quadword (%% (rsp,64))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x48;
                           (* MOV (Memop Quadword (%% (rsp,72))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x50;
                           (* MOV (Memop Quadword (%% (rsp,80))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x58;
                           (* MOV (Memop Quadword (%% (rsp,88))) (% r15) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0x2b; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* SUB (% rax) (Memop Quadword (%% (rsp,128))) *)
  0x48; 0x8b; 0x4c; 0x24; 0x08;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0x1b; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* SBB (% rcx) (Memop Quadword (%% (rsp,136))) *)
  0x4c; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,16))) *)
  0x4c; 0x1b; 0x84; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* SBB (% r8) (Memop Quadword (%% (rsp,144))) *)
  0x4c; 0x8b; 0x4c; 0x24; 0x18;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,24))) *)
  0x4c; 0x1b; 0x8c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,152))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x04; 0x24;  (* MOV (Memop Quadword (%% (rsp,0))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x4c; 0x24; 0x08;
                           (* MOV (Memop Quadword (%% (rsp,8))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x44; 0x24; 0x10;
                           (* MOV (Memop Quadword (%% (rsp,16))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x4c; 0x24; 0x18;
                           (* MOV (Memop Quadword (%% (rsp,24))) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0x2b; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* SUB (% rax) (Memop Quadword (%% (rsp,128))) *)
  0x48; 0x8b; 0x4c; 0x24; 0x48;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0x1b; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* SBB (% rcx) (Memop Quadword (%% (rsp,136))) *)
  0x4c; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,80))) *)
  0x4c; 0x1b; 0x84; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* SBB (% r8) (Memop Quadword (%% (rsp,144))) *)
  0x4c; 0x8b; 0x4c; 0x24; 0x58;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,88))) *)
  0x4c; 0x1b; 0x8c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,152))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x44; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x4c; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x44; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x4c; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% r9) *)
  0x48; 0x8b; 0x5e; 0x40;  (* MOV (% rbx) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5e; 0x48;  (* MOV (% rbx) (Memop Quadword (%% (rsi,72))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5e; 0x50;  (* MOV (% rbx) (Memop Quadword (%% (rsi,80))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5e; 0x58;  (* MOV (% rbx) (Memop Quadword (%% (rsi,88))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% r15) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0x2b; 0x44; 0x24; 0x40;
                           (* SUB (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0x8b; 0x4c; 0x24; 0x08;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0x1b; 0x4c; 0x24; 0x48;
                           (* SBB (% rcx) (Memop Quadword (%% (rsp,72))) *)
  0x4c; 0x8b; 0x44; 0x24; 0x10;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,16))) *)
  0x4c; 0x1b; 0x44; 0x24; 0x50;
                           (* SBB (% r8) (Memop Quadword (%% (rsp,80))) *)
  0x4c; 0x8b; 0x4c; 0x24; 0x18;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,24))) *)
  0x4c; 0x1b; 0x4c; 0x24; 0x58;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,88))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x04; 0x24;  (* MOV (Memop Quadword (%% (rsp,0))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x4c; 0x24; 0x08;
                           (* MOV (Memop Quadword (%% (rsp,8))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x44; 0x24; 0x10;
                           (* MOV (Memop Quadword (%% (rsp,16))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x4c; 0x24; 0x18;
                           (* MOV (Memop Quadword (%% (rsp,24))) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,128))) *)
  0x48; 0x2b; 0x04; 0x24;  (* SUB (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0x8b; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,136))) *)
  0x48; 0x1b; 0x4c; 0x24; 0x08;
                           (* SBB (% rcx) (Memop Quadword (%% (rsp,8))) *)
  0x4c; 0x8b; 0x84; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,144))) *)
  0x4c; 0x1b; 0x44; 0x24; 0x10;
                           (* SBB (% r8) (Memop Quadword (%% (rsp,16))) *)
  0x4c; 0x8b; 0x8c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,152))) *)
  0x4c; 0x1b; 0x4c; 0x24; 0x18;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,24))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,128))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,136))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x84; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,144))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x8c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,152))) (% r9) *)
  0x48; 0x8b; 0x9c; 0x24; 0xc0; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,192))) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x9c; 0x24; 0xc8; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,200))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x9c; 0x24; 0xd0; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,208))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x9c; 0x24; 0xd8; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,216))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% r15) *)
  0x48; 0x8b; 0x5d; 0x40;  (* MOV (% rbx) (Memop Quadword (%% (rbp,64))) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5d; 0x48;  (* MOV (% rbx) (Memop Quadword (%% (rbp,72))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5d; 0x50;  (* MOV (% rbx) (Memop Quadword (%% (rbp,80))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5d; 0x58;  (* MOV (% rbx) (Memop Quadword (%% (rbp,88))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% r15) *)
  0x48; 0x8b; 0x9c; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,128))) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,48))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,56))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x9c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,136))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,48))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,56))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x9c; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,144))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,48))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,56))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x9c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,152))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,48))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,56))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,128))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,136))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,144))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,152))) (% r15) *)
  0x48; 0x8b; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,128))) *)
  0x48; 0x2b; 0x44; 0x24; 0x60;
                           (* SUB (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0x8b; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,136))) *)
  0x48; 0x1b; 0x4c; 0x24; 0x68;
                           (* SBB (% rcx) (Memop Quadword (%% (rsp,104))) *)
  0x4c; 0x8b; 0x84; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,144))) *)
  0x4c; 0x1b; 0x44; 0x24; 0x70;
                           (* SBB (% r8) (Memop Quadword (%% (rsp,112))) *)
  0x4c; 0x8b; 0x8c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,152))) *)
  0x4c; 0x1b; 0x4c; 0x24; 0x78;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,120))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,128))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,136))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x84; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,144))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x8c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,152))) (% r9) *)
  0x4c; 0x8b; 0x46; 0x40;  (* MOV (% r8) (Memop Quadword (%% (rsi,64))) *)
  0x4c; 0x8b; 0x4e; 0x48;  (* MOV (% r9) (Memop Quadword (%% (rsi,72))) *)
  0x4c; 0x8b; 0x56; 0x50;  (* MOV (% r10) (Memop Quadword (%% (rsi,80))) *)
  0x4c; 0x8b; 0x5e; 0x58;  (* MOV (% r11) (Memop Quadword (%% (rsi,88))) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x4c; 0x89; 0xca;        (* MOV (% rdx) (% r9) *)
  0x4c; 0x09; 0xd0;        (* OR (% rax) (% r10) *)
  0x4c; 0x09; 0xda;        (* OR (% rdx) (% r11) *)
  0x48; 0x09; 0xd0;        (* OR (% rax) (% rdx) *)
  0x48; 0xf7; 0xd8;        (* NEG (% rax) *)
  0x48; 0x19; 0xc0;        (* SBB (% rax) (% rax) *)
  0x4c; 0x8b; 0x65; 0x40;  (* MOV (% r12) (Memop Quadword (%% (rbp,64))) *)
  0x4c; 0x8b; 0x6d; 0x48;  (* MOV (% r13) (Memop Quadword (%% (rbp,72))) *)
  0x4c; 0x8b; 0x75; 0x50;  (* MOV (% r14) (Memop Quadword (%% (rbp,80))) *)
  0x4c; 0x8b; 0x7d; 0x58;  (* MOV (% r15) (Memop Quadword (%% (rbp,88))) *)
  0x4c; 0x89; 0xe3;        (* MOV (% rbx) (% r12) *)
  0x4c; 0x89; 0xea;        (* MOV (% rdx) (% r13) *)
  0x4c; 0x09; 0xf3;        (* OR (% rbx) (% r14) *)
  0x4c; 0x09; 0xfa;        (* OR (% rdx) (% r15) *)
  0x48; 0x09; 0xd3;        (* OR (% rbx) (% rdx) *)
  0x48; 0xf7; 0xdb;        (* NEG (% rbx) *)
  0x48; 0x19; 0xdb;        (* SBB (% rbx) (% rbx) *)
  0x48; 0x39; 0xc3;        (* CMP (% rbx) (% rax) *)
  0x4d; 0x0f; 0x42; 0xe0;  (* CMOVB (% r12) (% r8) *)
  0x4d; 0x0f; 0x42; 0xe9;  (* CMOVB (% r13) (% r9) *)
  0x4d; 0x0f; 0x42; 0xf2;  (* CMOVB (% r14) (% r10) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x0f; 0x44; 0xa4; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* CMOVE (% r12) (Memop Quadword (%% (rsp,160))) *)
  0x4c; 0x0f; 0x44; 0xac; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* CMOVE (% r13) (Memop Quadword (%% (rsp,168))) *)
  0x4c; 0x0f; 0x44; 0xb4; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* CMOVE (% r14) (Memop Quadword (%% (rsp,176))) *)
  0x4c; 0x0f; 0x44; 0xbc; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* CMOVE (% r15) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0x8b; 0x04; 0x24;  (* MOV (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0x0f; 0x42; 0x06;  (* CMOVB (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0x0f; 0x47; 0x45; 0x00;
                           (* CMOVA (% rax) (Memop Quadword (%% (rbp,0))) *)
  0x48; 0x8b; 0x5c; 0x24; 0x08;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,8))) *)
  0x48; 0x0f; 0x42; 0x5e; 0x08;
                           (* CMOVB (% rbx) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0x0f; 0x47; 0x5d; 0x08;
                           (* CMOVA (% rbx) (Memop Quadword (%% (rbp,8))) *)
  0x48; 0x8b; 0x4c; 0x24; 0x10;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,16))) *)
  0x48; 0x0f; 0x42; 0x4e; 0x10;
                           (* CMOVB (% rcx) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0x0f; 0x47; 0x4d; 0x10;
                           (* CMOVA (% rcx) (Memop Quadword (%% (rbp,16))) *)
  0x48; 0x8b; 0x54; 0x24; 0x18;
                           (* MOV (% rdx) (Memop Quadword (%% (rsp,24))) *)
  0x48; 0x0f; 0x42; 0x56; 0x18;
                           (* CMOVB (% rdx) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0x0f; 0x47; 0x55; 0x18;
                           (* CMOVA (% rdx) (Memop Quadword (%% (rbp,24))) *)
  0x4c; 0x8b; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,128))) *)
  0x4c; 0x0f; 0x42; 0x46; 0x20;
                           (* CMOVB (% r8) (Memop Quadword (%% (rsi,32))) *)
  0x4c; 0x0f; 0x47; 0x45; 0x20;
                           (* CMOVA (% r8) (Memop Quadword (%% (rbp,32))) *)
  0x4c; 0x8b; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,136))) *)
  0x4c; 0x0f; 0x42; 0x4e; 0x28;
                           (* CMOVB (% r9) (Memop Quadword (%% (rsi,40))) *)
  0x4c; 0x0f; 0x47; 0x4d; 0x28;
                           (* CMOVA (% r9) (Memop Quadword (%% (rbp,40))) *)
  0x4c; 0x8b; 0x94; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (% r10) (Memop Quadword (%% (rsp,144))) *)
  0x4c; 0x0f; 0x42; 0x56; 0x30;
                           (* CMOVB (% r10) (Memop Quadword (%% (rsi,48))) *)
  0x4c; 0x0f; 0x47; 0x55; 0x30;
                           (* CMOVA (% r10) (Memop Quadword (%% (rbp,48))) *)
  0x4c; 0x8b; 0x9c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (% r11) (Memop Quadword (%% (rsp,152))) *)
  0x4c; 0x0f; 0x42; 0x5e; 0x38;
                           (* CMOVB (% r11) (Memop Quadword (%% (rsi,56))) *)
  0x4c; 0x0f; 0x47; 0x5d; 0x38;
                           (* CMOVA (% r11) (Memop Quadword (%% (rbp,56))) *)
  0x48; 0x89; 0x07;        (* MOV (Memop Quadword (%% (rdi,0))) (% rax) *)
  0x48; 0x89; 0x5f; 0x08;  (* MOV (Memop Quadword (%% (rdi,8))) (% rbx) *)
  0x48; 0x89; 0x4f; 0x10;  (* MOV (Memop Quadword (%% (rdi,16))) (% rcx) *)
  0x48; 0x89; 0x57; 0x18;  (* MOV (Memop Quadword (%% (rdi,24))) (% rdx) *)
  0x4c; 0x89; 0x47; 0x20;  (* MOV (Memop Quadword (%% (rdi,32))) (% r8) *)
  0x4c; 0x89; 0x4f; 0x28;  (* MOV (Memop Quadword (%% (rdi,40))) (% r9) *)
  0x4c; 0x89; 0x57; 0x30;  (* MOV (Memop Quadword (%% (rdi,48))) (% r10) *)
  0x4c; 0x89; 0x5f; 0x38;  (* MOV (Memop Quadword (%% (rdi,56))) (% r11) *)
  0x4c; 0x89; 0x67; 0x40;  (* MOV (Memop Quadword (%% (rdi,64))) (% r12) *)
  0x4c; 0x89; 0x6f; 0x48;  (* MOV (Memop Quadword (%% (rdi,72))) (% r13) *)
  0x4c; 0x89; 0x77; 0x50;  (* MOV (Memop Quadword (%% (rdi,80))) (% r14) *)
  0x4c; 0x89; 0x7f; 0x58;  (* MOV (Memop Quadword (%% (rdi,88))) (% r15) *)
  0x48; 0x81; 0xc4; 0xe0; 0x00; 0x00; 0x00;
                           (* ADD (% rsp) (Imm32 (word 224)) *)
  0x41; 0x5f;              (* POP (% r15) *)
  0x41; 0x5e;              (* POP (% r14) *)
  0x41; 0x5d;              (* POP (% r13) *)
  0x41; 0x5c;              (* POP (% r12) *)
  0x5d;                    (* POP (% rbp) *)
  0x5b;                    (* POP (% rbx) *)
  0xc3;                    (* RET *)
  0x53;                    (* PUSH (% rbx) *)
  0x41; 0x54;              (* PUSH (% r12) *)
  0x41; 0x55;              (* PUSH (% r13) *)
  0x41; 0x56;              (* PUSH (% r14) *)
  0x41; 0x57;              (* PUSH (% r15) *)
  0x48; 0x81; 0xec; 0xc0; 0x00; 0x00; 0x00;
                           (* SUB (% rsp) (Imm32 (word 192)) *)
  0x48; 0x8b; 0x46; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc1;        (* MOV (% r9) (% rax) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x48; 0x8b; 0x46; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rsi,88))) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc3;        (* MOV (% r11) (% rax) *)
  0x49; 0x89; 0xd4;        (* MOV (% r12) (% rdx) *)
  0x48; 0x8b; 0x46; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rsi,80))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x49; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% r13) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x49; 0x89; 0xd6;        (* MOV (% r14) (% rdx) *)
  0x48; 0x8b; 0x46; 0x40;  (* MOV (% rax) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x5e; 0x58;  (* MOV (% rbx) (Memop Quadword (%% (rsi,88))) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x49; 0x83; 0xd6; 0x00;  (* ADC (% r14) (Imm8 (word 0)) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x4d; 0x01; 0xc9;        (* ADD (% r9) (% r9) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xe4;        (* ADC (% r12) (% r12) *)
  0x4d; 0x11; 0xed;        (* ADC (% r13) (% r13) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x11; 0xc9;        (* ADC (% rcx) (% rcx) *)
  0x48; 0x8b; 0x46; 0x48;  (* MOV (% rax) (Memop Quadword (%% (rsi,72))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x4d; 0x01; 0xf9;        (* ADD (% r9) (% r15) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x46; 0x50;  (* MOV (% rax) (Memop Quadword (%% (rsi,80))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc4;        (* ADC (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x46; 0x58;  (* MOV (% rax) (Memop Quadword (%% (rsi,88))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc6;        (* ADC (% r14) (% rax) *)
  0x48; 0x11; 0xca;        (* ADC (% rdx) (% rcx) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xc6;        (* ADC (% r14) (% r8) *)
  0x4d; 0x11; 0xc7;        (* ADC (% r15) (% r8) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0x8d; 0x5b; 0xff;  (* LEA (% rbx) (%% (rbx,18446744073709551615)) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x4d; 0x8d; 0x49; 0xff;  (* LEA (% r9) (%% (r9,18446744073709551615)) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x24; 0x24;  (* MOV (Memop Quadword (%% (rsp,0))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x08;
                           (* MOV (Memop Quadword (%% (rsp,8))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x10;
                           (* MOV (Memop Quadword (%% (rsp,16))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x18;
                           (* MOV (Memop Quadword (%% (rsp,24))) (% r15) *)
  0x48; 0x8b; 0x46; 0x20;  (* MOV (% rax) (Memop Quadword (%% (rsi,32))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0x8b; 0x46; 0x28;  (* MOV (% rax) (Memop Quadword (%% (rsi,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc1;        (* MOV (% r9) (% rax) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x48; 0x8b; 0x46; 0x38;  (* MOV (% rax) (Memop Quadword (%% (rsi,56))) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc3;        (* MOV (% r11) (% rax) *)
  0x49; 0x89; 0xd4;        (* MOV (% r12) (% rdx) *)
  0x48; 0x8b; 0x46; 0x30;  (* MOV (% rax) (Memop Quadword (%% (rsi,48))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x49; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% r13) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x49; 0x89; 0xd6;        (* MOV (% r14) (% rdx) *)
  0x48; 0x8b; 0x46; 0x20;  (* MOV (% rax) (Memop Quadword (%% (rsi,32))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x46; 0x28;  (* MOV (% rax) (Memop Quadword (%% (rsi,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x5e; 0x38;  (* MOV (% rbx) (Memop Quadword (%% (rsi,56))) *)
  0x48; 0x8b; 0x46; 0x28;  (* MOV (% rax) (Memop Quadword (%% (rsi,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x49; 0x83; 0xd6; 0x00;  (* ADC (% r14) (Imm8 (word 0)) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x4d; 0x01; 0xc9;        (* ADD (% r9) (% r9) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xe4;        (* ADC (% r12) (% r12) *)
  0x4d; 0x11; 0xed;        (* ADC (% r13) (% r13) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x11; 0xc9;        (* ADC (% rcx) (% rcx) *)
  0x48; 0x8b; 0x46; 0x28;  (* MOV (% rax) (Memop Quadword (%% (rsi,40))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x4d; 0x01; 0xf9;        (* ADD (% r9) (% r15) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x46; 0x30;  (* MOV (% rax) (Memop Quadword (%% (rsi,48))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc4;        (* ADC (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x46; 0x38;  (* MOV (% rax) (Memop Quadword (%% (rsi,56))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc6;        (* ADC (% r14) (% rax) *)
  0x48; 0x11; 0xca;        (* ADC (% rdx) (% rcx) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xc6;        (* ADC (% r14) (% r8) *)
  0x4d; 0x11; 0xc7;        (* ADC (% r15) (% r8) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0x8d; 0x5b; 0xff;  (* LEA (% rbx) (%% (rbx,18446744073709551615)) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x4d; 0x8d; 0x49; 0xff;  (* LEA (% r9) (%% (r9,18446744073709551615)) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x20;
                           (* MOV (Memop Quadword (%% (rsp,32))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x28;
                           (* MOV (Memop Quadword (%% (rsp,40))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x30;
                           (* MOV (Memop Quadword (%% (rsp,48))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x38;
                           (* MOV (Memop Quadword (%% (rsp,56))) (% r15) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0x2b; 0x04; 0x24;  (* SUB (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0x8b; 0x4e; 0x08;  (* MOV (% rcx) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0x1b; 0x4c; 0x24; 0x08;
                           (* SBB (% rcx) (Memop Quadword (%% (rsp,8))) *)
  0x4c; 0x8b; 0x46; 0x10;  (* MOV (% r8) (Memop Quadword (%% (rsi,16))) *)
  0x4c; 0x1b; 0x44; 0x24; 0x10;
                           (* SBB (% r8) (Memop Quadword (%% (rsp,16))) *)
  0x4c; 0x8b; 0x4e; 0x18;  (* MOV (% r9) (Memop Quadword (%% (rsi,24))) *)
  0x4c; 0x1b; 0x4c; 0x24; 0x18;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,24))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x44; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x4c; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x44; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x4c; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% r9) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0x03; 0x04; 0x24;  (* ADD (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0x8b; 0x4e; 0x08;  (* MOV (% rcx) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0x13; 0x4c; 0x24; 0x08;
                           (* ADC (% rcx) (Memop Quadword (%% (rsp,8))) *)
  0x4c; 0x8b; 0x46; 0x10;  (* MOV (% r8) (Memop Quadword (%% (rsi,16))) *)
  0x4c; 0x13; 0x44; 0x24; 0x10;
                           (* ADC (% r8) (Memop Quadword (%% (rsp,16))) *)
  0x4c; 0x8b; 0x4e; 0x18;  (* MOV (% r9) (Memop Quadword (%% (rsi,24))) *)
  0x4c; 0x13; 0x4c; 0x24; 0x18;
                           (* ADC (% r9) (Memop Quadword (%% (rsp,24))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x29; 0xd8;        (* SUB (% rax) (% r11) *)
  0x48; 0x89; 0x44; 0x24; 0x40;
                           (* MOV (Memop Quadword (%% (rsp,64))) (% rax) *)
  0x4c; 0x19; 0xd1;        (* SBB (% rcx) (% r10) *)
  0x48; 0x89; 0x4c; 0x24; 0x48;
                           (* MOV (Memop Quadword (%% (rsp,72))) (% rcx) *)
  0x49; 0x83; 0xd8; 0x00;  (* SBB (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x44; 0x24; 0x50;
                           (* MOV (Memop Quadword (%% (rsp,80))) (% r8) *)
  0x49; 0x19; 0xd1;        (* SBB (% r9) (% rdx) *)
  0x4c; 0x89; 0x4c; 0x24; 0x58;
                           (* MOV (Memop Quadword (%% (rsp,88))) (% r9) *)
  0x48; 0x8b; 0x5c; 0x24; 0x60;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x48;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x58;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5c; 0x24; 0x68;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,104))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x48;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x44; 0x24; 0x58;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5c; 0x24; 0x70;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,112))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x48;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x44; 0x24; 0x58;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5c; 0x24; 0x78;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,120))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x48;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,80))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x58;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,88))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% r15) *)
  0x4d; 0x31; 0xdb;        (* XOR (% r11) (% r11) *)
  0x48; 0x8b; 0x46; 0x20;  (* MOV (% rax) (Memop Quadword (%% (rsi,32))) *)
  0x48; 0x03; 0x46; 0x40;  (* ADD (% rax) (Memop Quadword (%% (rsi,64))) *)
  0x48; 0x8b; 0x4e; 0x28;  (* MOV (% rcx) (Memop Quadword (%% (rsi,40))) *)
  0x48; 0x13; 0x4e; 0x48;  (* ADC (% rcx) (Memop Quadword (%% (rsi,72))) *)
  0x4c; 0x8b; 0x46; 0x30;  (* MOV (% r8) (Memop Quadword (%% (rsi,48))) *)
  0x4c; 0x13; 0x46; 0x50;  (* ADC (% r8) (Memop Quadword (%% (rsi,80))) *)
  0x4c; 0x8b; 0x4e; 0x38;  (* MOV (% r9) (Memop Quadword (%% (rsi,56))) *)
  0x4c; 0x13; 0x4e; 0x58;  (* ADC (% r9) (Memop Quadword (%% (rsi,88))) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x48; 0x83; 0xe8; 0xff;  (* SUB (% rax) (Imm8 (word 255)) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4c; 0x19; 0xd1;        (* SBB (% rcx) (% r10) *)
  0x49; 0x83; 0xd8; 0x00;  (* SBB (% r8) (Imm8 (word 0)) *)
  0x48; 0xba; 0x01; 0x00; 0x00; 0x00; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% rdx) (Imm64 (word 18446744069414584321)) *)
  0x49; 0x19; 0xd1;        (* SBB (% r9) (% rdx) *)
  0x49; 0x83; 0xdb; 0x00;  (* SBB (% r11) (Imm8 (word 0)) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x21; 0xda;        (* AND (% rdx) (% r11) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x44; 0x24; 0x40;
                           (* MOV (Memop Quadword (%% (rsp,64))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x4c; 0x24; 0x48;
                           (* MOV (Memop Quadword (%% (rsp,72))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x44; 0x24; 0x50;
                           (* MOV (Memop Quadword (%% (rsp,80))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x4c; 0x24; 0x58;
                           (* MOV (Memop Quadword (%% (rsp,88))) (% r9) *)
  0x48; 0x8b; 0x5c; 0x24; 0x20;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x46; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x46; 0x10;  (* MOV (% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x46; 0x18;  (* MOV (% rax) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5c; 0x24; 0x28;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,40))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x46; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x46; 0x10;  (* MOV (% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x46; 0x18;  (* MOV (% rax) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5c; 0x24; 0x30;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,48))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x46; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x46; 0x10;  (* MOV (% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x46; 0x18;  (* MOV (% rax) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5c; 0x24; 0x38;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,56))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x06;        (* MOV (% rax) (Memop Quadword (%% (rsi,0))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x46; 0x08;  (* MOV (% rax) (Memop Quadword (%% (rsi,8))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x46; 0x10;  (* MOV (% rax) (Memop Quadword (%% (rsi,16))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x46; 0x18;  (* MOV (% rax) (Memop Quadword (%% (rsi,24))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,128))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,136))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,144))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,152))) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc1;        (* MOV (% r9) (% rax) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc3;        (* MOV (% r11) (% rax) *)
  0x49; 0x89; 0xd4;        (* MOV (% r12) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x49; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% r13) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x49; 0x89; 0xd6;        (* MOV (% r14) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x5c; 0x24; 0x78;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x49; 0x83; 0xd6; 0x00;  (* ADC (% r14) (Imm8 (word 0)) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x4d; 0x01; 0xc9;        (* ADD (% r9) (% r9) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xe4;        (* ADC (% r12) (% r12) *)
  0x4d; 0x11; 0xed;        (* ADC (% r13) (% r13) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x11; 0xc9;        (* ADC (% rcx) (% rcx) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x4d; 0x01; 0xf9;        (* ADD (% r9) (% r15) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc4;        (* ADC (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc6;        (* ADC (% r14) (% rax) *)
  0x48; 0x11; 0xca;        (* ADC (% rdx) (% rcx) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xc6;        (* ADC (% r14) (% r8) *)
  0x4d; 0x11; 0xc7;        (* ADC (% r15) (% r8) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0x8d; 0x5b; 0xff;  (* LEA (% rbx) (%% (rbx,18446744073709551615)) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x4d; 0x8d; 0x49; 0xff;  (* LEA (% r9) (%% (r9,18446744073709551615)) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0xa4; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% r12) *)
  0x4c; 0x89; 0xac; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% r13) *)
  0x4c; 0x89; 0xb4; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% r14) *)
  0x4c; 0x89; 0xbc; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x48;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc1;        (* MOV (% r9) (% rax) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x58;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,88))) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc3;        (* MOV (% r11) (% rax) *)
  0x49; 0x89; 0xd4;        (* MOV (% r12) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,80))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x49; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% r13) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x49; 0x89; 0xd6;        (* MOV (% r14) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x44; 0x24; 0x48;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x5c; 0x24; 0x58;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,88))) *)
  0x48; 0x8b; 0x44; 0x24; 0x48;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x49; 0x83; 0xd6; 0x00;  (* ADC (% r14) (Imm8 (word 0)) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x4d; 0x01; 0xc9;        (* ADD (% r9) (% r9) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xe4;        (* ADC (% r12) (% r12) *)
  0x4d; 0x11; 0xed;        (* ADC (% r13) (% r13) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x11; 0xc9;        (* ADC (% rcx) (% rcx) *)
  0x48; 0x8b; 0x44; 0x24; 0x48;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x4d; 0x01; 0xf9;        (* ADD (% r9) (% r15) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,80))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc4;        (* ADC (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x58;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,88))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc6;        (* ADC (% r14) (% rax) *)
  0x48; 0x11; 0xca;        (* ADC (% rdx) (% rcx) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xc6;        (* ADC (% r14) (% r8) *)
  0x4d; 0x11; 0xc7;        (* ADC (% r15) (% r8) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0x8d; 0x5b; 0xff;  (* LEA (% rbx) (%% (rbx,18446744073709551615)) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x4d; 0x8d; 0x49; 0xff;  (* LEA (% r9) (%% (r9,18446744073709551615)) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x40;
                           (* MOV (Memop Quadword (%% (rsp,64))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x48;
                           (* MOV (Memop Quadword (%% (rsp,72))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x50;
                           (* MOV (Memop Quadword (%% (rsp,80))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x58;
                           (* MOV (Memop Quadword (%% (rsp,88))) (% r15) *)
  0x49; 0xc7; 0xc1; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r9) (Imm32 (word 4294967295)) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x4c; 0x2b; 0x8c; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* SUB (% r9) (Memop Quadword (%% (rsp,160))) *)
  0x49; 0xba; 0xff; 0xff; 0xff; 0xff; 0x00; 0x00; 0x00; 0x00;
                           (* MOV (% r10) (Imm64 (word 4294967295)) *)
  0x4c; 0x1b; 0x94; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* SBB (% r10) (Memop Quadword (%% (rsp,168))) *)
  0x4c; 0x1b; 0x9c; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* SBB (% r11) (Memop Quadword (%% (rsp,176))) *)
  0x49; 0xbc; 0x01; 0x00; 0x00; 0x00; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r12) (Imm64 (word 18446744069414584321)) *)
  0x4c; 0x1b; 0xa4; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* SBB (% r12) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xc7; 0xc1; 0x09; 0x00; 0x00; 0x00;
                           (* MOV (% rcx) (Imm32 (word 9)) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4c; 0x89; 0xe0;        (* MOV (% rax) (% r12) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0xb9; 0x0c; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 12)) *)
  0x48; 0x8b; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,128))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x48; 0x19; 0xdb;        (* SBB (% rbx) (% rbx) *)
  0x48; 0x8b; 0x84; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,136))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x29; 0xda;        (* SUB (% rdx) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xdb;        (* SBB (% rbx) (% rbx) *)
  0x48; 0x8b; 0x84; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,144))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x29; 0xda;        (* SUB (% rdx) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xdb;        (* SBB (% rbx) (% rbx) *)
  0x48; 0x8b; 0x84; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,152))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x29; 0xda;        (* SUB (% rdx) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x49; 0x8d; 0x4c; 0x24; 0x01;
                           (* LEA (% rcx) (%% (r12,1)) *)
  0x48; 0xb8; 0x01; 0x00; 0x00; 0x00; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% rax) (Imm64 (word 18446744069414584321)) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x89; 0xcb;        (* MOV (% rbx) (% rcx) *)
  0x48; 0xc1; 0xe3; 0x20;  (* SHL (% rbx) (Imm8 (word 32)) *)
  0x49; 0x01; 0xc8;        (* ADD (% r8) (% rcx) *)
  0x48; 0x83; 0xdb; 0x00;  (* SBB (% rbx) (Imm8 (word 0)) *)
  0x49; 0x29; 0xd9;        (* SUB (% r9) (% rbx) *)
  0x49; 0x83; 0xda; 0x00;  (* SBB (% r10) (Imm8 (word 0)) *)
  0x49; 0x19; 0xc3;        (* SBB (% r11) (% rax) *)
  0x48; 0x19; 0xd1;        (* SBB (% rcx) (% rdx) *)
  0x48; 0xff; 0xc9;        (* DEC (% rcx) *)
  0xb8; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% eax) (Imm32 (word 4294967295)) *)
  0x48; 0x21; 0xc8;        (* AND (% rax) (% rcx) *)
  0x31; 0xd2;              (* XOR (% edx) (% edx) *)
  0x48; 0x29; 0xc2;        (* SUB (% rdx) (% rax) *)
  0x49; 0x01; 0xc8;        (* ADD (% r8) (% rcx) *)
  0x4c; 0x89; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,160))) (% r8) *)
  0x49; 0x11; 0xc1;        (* ADC (% r9) (% rax) *)
  0x4c; 0x89; 0x8c; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,168))) (% r9) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x94; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,176))) (% r10) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4c; 0x89; 0x9c; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (Memop Quadword (%% (rsp,184))) (% r11) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0x2b; 0x04; 0x24;  (* SUB (% rax) (Memop Quadword (%% (rsp,0))) *)
  0x48; 0x8b; 0x4c; 0x24; 0x48;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0x1b; 0x4c; 0x24; 0x08;
                           (* SBB (% rcx) (Memop Quadword (%% (rsp,8))) *)
  0x4c; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,80))) *)
  0x4c; 0x1b; 0x44; 0x24; 0x10;
                           (* SBB (% r8) (Memop Quadword (%% (rsp,16))) *)
  0x4c; 0x8b; 0x4c; 0x24; 0x58;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,88))) *)
  0x4c; 0x1b; 0x4c; 0x24; 0x18;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,24))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x44; 0x24; 0x40;
                           (* MOV (Memop Quadword (%% (rsp,64))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x4c; 0x24; 0x48;
                           (* MOV (Memop Quadword (%% (rsp,72))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x44; 0x24; 0x50;
                           (* MOV (Memop Quadword (%% (rsp,80))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x4c; 0x24; 0x58;
                           (* MOV (Memop Quadword (%% (rsp,88))) (% r9) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc1;        (* MOV (% r9) (% rax) *)
  0x49; 0x89; 0xd2;        (* MOV (% r10) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,56))) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc3;        (* MOV (% r11) (% rax) *)
  0x49; 0x89; 0xd4;        (* MOV (% r12) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,48))) *)
  0x48; 0x89; 0xc3;        (* MOV (% rbx) (% rax) *)
  0x49; 0xf7; 0xe5;        (* MUL2 (% rdx,% rax) (% r13) *)
  0x49; 0x89; 0xc5;        (* MOV (% r13) (% rax) *)
  0x49; 0x89; 0xd6;        (* MOV (% r14) (% rdx) *)
  0x48; 0x8b; 0x44; 0x24; 0x20;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0x8b; 0x5c; 0x24; 0x38;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,56))) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x49; 0x83; 0xd6; 0x00;  (* ADC (% r14) (Imm8 (word 0)) *)
  0x31; 0xc9;              (* XOR (% ecx) (% ecx) *)
  0x4d; 0x01; 0xc9;        (* ADD (% r9) (% r9) *)
  0x4d; 0x11; 0xd2;        (* ADC (% r10) (% r10) *)
  0x4d; 0x11; 0xdb;        (* ADC (% r11) (% r11) *)
  0x4d; 0x11; 0xe4;        (* ADC (% r12) (% r12) *)
  0x4d; 0x11; 0xed;        (* ADC (% r13) (% r13) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x11; 0xc9;        (* ADC (% rcx) (% rcx) *)
  0x48; 0x8b; 0x44; 0x24; 0x28;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,40))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x4d; 0x01; 0xf9;        (* ADD (% r9) (% r15) *)
  0x49; 0x11; 0xc2;        (* ADC (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x30;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,48))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc4;        (* ADC (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x38;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,56))) *)
  0x48; 0xf7; 0xe0;        (* MUL2 (% rdx,% rax) (% rax) *)
  0x49; 0xf7; 0xdf;        (* NEG (% r15) *)
  0x49; 0x11; 0xc6;        (* ADC (% r14) (% rax) *)
  0x48; 0x11; 0xca;        (* ADC (% rdx) (% rcx) *)
  0x49; 0x89; 0xd7;        (* MOV (% r15) (% rdx) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xc6;        (* ADC (% r14) (% r8) *)
  0x4d; 0x11; 0xc7;        (* ADC (% r15) (% r8) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0x8d; 0x5b; 0xff;  (* LEA (% rbx) (%% (rbx,18446744073709551615)) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x4d; 0x8d; 0x49; 0xff;  (* LEA (% r9) (%% (r9,18446744073709551615)) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x24; 0x24;  (* MOV (Memop Quadword (%% (rsp,0))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x08;
                           (* MOV (Memop Quadword (%% (rsp,8))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x10;
                           (* MOV (Memop Quadword (%% (rsp,16))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x18;
                           (* MOV (Memop Quadword (%% (rsp,24))) (% r15) *)
  0x48; 0x8b; 0x5c; 0x24; 0x60;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x89; 0xc0;        (* MOV (% r8) (% rax) *)
  0x49; 0x89; 0xd1;        (* MOV (% r9) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xdb;        (* XOR (% r11d) (% r11d) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x45; 0x31; 0xe4;        (* XOR (% r12d) (% r12d) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x8b; 0x5c; 0x24; 0x68;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,104))) *)
  0x45; 0x31; 0xed;        (* XOR (% r13d) (% r13d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xf6;        (* SBB (% r14) (% r14) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xf2;        (* SUB (% rdx) (% r14) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x45; 0x31; 0xf6;        (* XOR (% r14d) (% r14d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xc0;        (* MOV (% rax) (% r8) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xff;        (* SBB (% r15) (% r15) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xfa;        (* SUB (% rdx) (% r15) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x11; 0xf6;        (* ADC (% r14) (% r14) *)
  0x48; 0x8b; 0x5c; 0x24; 0x70;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,112))) *)
  0x45; 0x31; 0xff;        (* XOR (% r15d) (% r15d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc0;        (* SBB (% r8) (% r8) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xc2;        (* SUB (% rdx) (% r8) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x11; 0xff;        (* ADC (% r15) (% r15) *)
  0x48; 0x8b; 0x5c; 0x24; 0x78;
                           (* MOV (% rbx) (Memop Quadword (%% (rsp,120))) *)
  0x45; 0x31; 0xc0;        (* XOR (% r8d) (% r8d) *)
  0x48; 0x8b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,160))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,168))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,176))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x4d; 0x19; 0xc9;        (* SBB (% r9) (% r9) *)
  0x48; 0x8b; 0x84; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x4c; 0x29; 0xca;        (* SUB (% rdx) (% r9) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc0;        (* ADC (% r8) (% r8) *)
  0x45; 0x31; 0xc9;        (* XOR (% r9d) (% r9d) *)
  0x48; 0xbb; 0x00; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% rbx) (Imm64 (word 4294967296)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc4;        (* ADD (% r12) (% rax) *)
  0x49; 0x11; 0xd5;        (* ADC (% r13) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x48; 0xf7; 0xd3;        (* NOT (% rbx) *)
  0x48; 0x8d; 0x5b; 0x02;  (* LEA (% rbx) (%% (rbx,2)) *)
  0x4c; 0x89; 0xd0;        (* MOV (% rax) (% r10) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc5;        (* ADD (% r13) (% rax) *)
  0x49; 0x11; 0xd6;        (* ADC (% r14) (% rdx) *)
  0x48; 0x19; 0xc9;        (* SBB (% rcx) (% rcx) *)
  0x4c; 0x89; 0xd8;        (* MOV (% rax) (% r11) *)
  0x48; 0xf7; 0xe3;        (* MUL2 (% rdx,% rax) (% rbx) *)
  0x48; 0x29; 0xca;        (* SUB (% rdx) (% rcx) *)
  0x49; 0x01; 0xc6;        (* ADD (% r14) (% rax) *)
  0x49; 0x11; 0xd7;        (* ADC (% r15) (% rdx) *)
  0x4d; 0x11; 0xc8;        (* ADC (% r8) (% r9) *)
  0xb9; 0x01; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 1)) *)
  0x4c; 0x01; 0xe1;        (* ADD (% rcx) (% r12) *)
  0x48; 0xff; 0xcb;        (* DEC (% rbx) *)
  0x4c; 0x11; 0xeb;        (* ADC (% rbx) (% r13) *)
  0x49; 0xff; 0xc9;        (* DEC (% r9) *)
  0x4c; 0x89; 0xc8;        (* MOV (% rax) (% r9) *)
  0x4d; 0x11; 0xf1;        (* ADC (% r9) (% r14) *)
  0x41; 0xbb; 0xfe; 0xff; 0xff; 0xff;
                           (* MOV (% r11d) (Imm32 (word 4294967294)) *)
  0x4d; 0x11; 0xfb;        (* ADC (% r11) (% r15) *)
  0x4c; 0x11; 0xc0;        (* ADC (% rax) (% r8) *)
  0x4c; 0x0f; 0x42; 0xe1;  (* CMOVB (% r12) (% rcx) *)
  0x4c; 0x0f; 0x42; 0xeb;  (* CMOVB (% r13) (% rbx) *)
  0x4d; 0x0f; 0x42; 0xf1;  (* CMOVB (% r14) (% r9) *)
  0x4d; 0x0f; 0x42; 0xfb;  (* CMOVB (% r15) (% r11) *)
  0x4c; 0x89; 0x64; 0x24; 0x60;
                           (* MOV (Memop Quadword (%% (rsp,96))) (% r12) *)
  0x4c; 0x89; 0x6c; 0x24; 0x68;
                           (* MOV (Memop Quadword (%% (rsp,104))) (% r13) *)
  0x4c; 0x89; 0x74; 0x24; 0x70;
                           (* MOV (Memop Quadword (%% (rsp,112))) (% r14) *)
  0x4c; 0x89; 0x7c; 0x24; 0x78;
                           (* MOV (Memop Quadword (%% (rsp,120))) (% r15) *)
  0x48; 0x8b; 0x44; 0x24; 0x40;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,64))) *)
  0x48; 0x2b; 0x44; 0x24; 0x20;
                           (* SUB (% rax) (Memop Quadword (%% (rsp,32))) *)
  0x48; 0x8b; 0x4c; 0x24; 0x48;
                           (* MOV (% rcx) (Memop Quadword (%% (rsp,72))) *)
  0x48; 0x1b; 0x4c; 0x24; 0x28;
                           (* SBB (% rcx) (Memop Quadword (%% (rsp,40))) *)
  0x4c; 0x8b; 0x44; 0x24; 0x50;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,80))) *)
  0x4c; 0x1b; 0x44; 0x24; 0x30;
                           (* SBB (% r8) (Memop Quadword (%% (rsp,48))) *)
  0x4c; 0x8b; 0x4c; 0x24; 0x58;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,88))) *)
  0x4c; 0x1b; 0x4c; 0x24; 0x38;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,56))) *)
  0x41; 0xba; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r10d) (Imm32 (word 4294967295)) *)
  0x4d; 0x19; 0xdb;        (* SBB (% r11) (% r11) *)
  0x48; 0x31; 0xd2;        (* XOR (% rdx) (% rdx) *)
  0x4d; 0x21; 0xda;        (* AND (% r10) (% r11) *)
  0x4c; 0x29; 0xd2;        (* SUB (% rdx) (% r10) *)
  0x4c; 0x01; 0xd8;        (* ADD (% rax) (% r11) *)
  0x48; 0x89; 0x47; 0x40;  (* MOV (Memop Quadword (%% (rdi,64))) (% rax) *)
  0x4c; 0x11; 0xd1;        (* ADC (% rcx) (% r10) *)
  0x48; 0x89; 0x4f; 0x48;  (* MOV (Memop Quadword (%% (rdi,72))) (% rcx) *)
  0x49; 0x83; 0xd0; 0x00;  (* ADC (% r8) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x47; 0x50;  (* MOV (Memop Quadword (%% (rdi,80))) (% r8) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x4c; 0x89; 0x4f; 0x58;  (* MOV (Memop Quadword (%% (rdi,88))) (% r9) *)
  0x4c; 0x8b; 0x9c; 0x24; 0x98; 0x00; 0x00; 0x00;
                           (* MOV (% r11) (Memop Quadword (%% (rsp,152))) *)
  0x4c; 0x89; 0xd9;        (* MOV (% rcx) (% r11) *)
  0x4c; 0x8b; 0x94; 0x24; 0x90; 0x00; 0x00; 0x00;
                           (* MOV (% r10) (Memop Quadword (%% (rsp,144))) *)
  0x4d; 0x0f; 0xa4; 0xd3; 0x02;
                           (* SHLD (% r11) (% r10) (Imm8 (word 2)) *)
  0x4c; 0x8b; 0x8c; 0x24; 0x88; 0x00; 0x00; 0x00;
                           (* MOV (% r9) (Memop Quadword (%% (rsp,136))) *)
  0x4d; 0x0f; 0xa4; 0xca; 0x02;
                           (* SHLD (% r10) (% r9) (Imm8 (word 2)) *)
  0x4c; 0x8b; 0x84; 0x24; 0x80; 0x00; 0x00; 0x00;
                           (* MOV (% r8) (Memop Quadword (%% (rsp,128))) *)
  0x4d; 0x0f; 0xa4; 0xc1; 0x02;
                           (* SHLD (% r9) (% r8) (Imm8 (word 2)) *)
  0x49; 0xc1; 0xe0; 0x02;  (* SHL (% r8) (Imm8 (word 2)) *)
  0x48; 0xc1; 0xe9; 0x3e;  (* SHR (% rcx) (Imm8 (word 62)) *)
  0x48; 0x83; 0xc1; 0x01;  (* ADD (% rcx) (Imm8 (word 1)) *)
  0x4c; 0x2b; 0x84; 0x24; 0xa0; 0x00; 0x00; 0x00;
                           (* SUB (% r8) (Memop Quadword (%% (rsp,160))) *)
  0x4c; 0x1b; 0x8c; 0x24; 0xa8; 0x00; 0x00; 0x00;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,168))) *)
  0x4c; 0x1b; 0x94; 0x24; 0xb0; 0x00; 0x00; 0x00;
                           (* SBB (% r10) (Memop Quadword (%% (rsp,176))) *)
  0x4c; 0x1b; 0x9c; 0x24; 0xb8; 0x00; 0x00; 0x00;
                           (* SBB (% r11) (Memop Quadword (%% (rsp,184))) *)
  0x48; 0x83; 0xd9; 0x00;  (* SBB (% rcx) (Imm8 (word 0)) *)
  0x48; 0xb8; 0x01; 0x00; 0x00; 0x00; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% rax) (Imm64 (word 18446744069414584321)) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x89; 0xcb;        (* MOV (% rbx) (% rcx) *)
  0x48; 0xc1; 0xe3; 0x20;  (* SHL (% rbx) (Imm8 (word 32)) *)
  0x49; 0x01; 0xc8;        (* ADD (% r8) (% rcx) *)
  0x48; 0x83; 0xdb; 0x00;  (* SBB (% rbx) (Imm8 (word 0)) *)
  0x49; 0x29; 0xd9;        (* SUB (% r9) (% rbx) *)
  0x49; 0x83; 0xda; 0x00;  (* SBB (% r10) (Imm8 (word 0)) *)
  0x49; 0x19; 0xc3;        (* SBB (% r11) (% rax) *)
  0x48; 0x19; 0xd1;        (* SBB (% rcx) (% rdx) *)
  0x48; 0xff; 0xc9;        (* DEC (% rcx) *)
  0xb8; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% eax) (Imm32 (word 4294967295)) *)
  0x48; 0x21; 0xc8;        (* AND (% rax) (% rcx) *)
  0x31; 0xd2;              (* XOR (% edx) (% edx) *)
  0x48; 0x29; 0xc2;        (* SUB (% rdx) (% rax) *)
  0x49; 0x01; 0xc8;        (* ADD (% r8) (% rcx) *)
  0x4c; 0x89; 0x07;        (* MOV (Memop Quadword (%% (rdi,0))) (% r8) *)
  0x49; 0x11; 0xc1;        (* ADC (% r9) (% rax) *)
  0x4c; 0x89; 0x4f; 0x08;  (* MOV (Memop Quadword (%% (rdi,8))) (% r9) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x57; 0x10;  (* MOV (Memop Quadword (%% (rdi,16))) (% r10) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4c; 0x89; 0x5f; 0x18;  (* MOV (Memop Quadword (%% (rdi,24))) (% r11) *)
  0x49; 0xc7; 0xc0; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r8) (Imm32 (word 4294967295)) *)
  0x45; 0x31; 0xd2;        (* XOR (% r10d) (% r10d) *)
  0x4c; 0x2b; 0x04; 0x24;  (* SUB (% r8) (Memop Quadword (%% (rsp,0))) *)
  0x49; 0xb9; 0xff; 0xff; 0xff; 0xff; 0x00; 0x00; 0x00; 0x00;
                           (* MOV (% r9) (Imm64 (word 4294967295)) *)
  0x4c; 0x1b; 0x4c; 0x24; 0x08;
                           (* SBB (% r9) (Memop Quadword (%% (rsp,8))) *)
  0x4c; 0x1b; 0x54; 0x24; 0x10;
                           (* SBB (% r10) (Memop Quadword (%% (rsp,16))) *)
  0x49; 0xbb; 0x01; 0x00; 0x00; 0x00; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% r11) (Imm64 (word 18446744069414584321)) *)
  0x4c; 0x1b; 0x5c; 0x24; 0x18;
                           (* SBB (% r11) (Memop Quadword (%% (rsp,24))) *)
  0x4d; 0x89; 0xdc;        (* MOV (% r12) (% r11) *)
  0x4d; 0x0f; 0xa4; 0xd3; 0x03;
                           (* SHLD (% r11) (% r10) (Imm8 (word 3)) *)
  0x4d; 0x0f; 0xa4; 0xca; 0x03;
                           (* SHLD (% r10) (% r9) (Imm8 (word 3)) *)
  0x4d; 0x0f; 0xa4; 0xc1; 0x03;
                           (* SHLD (% r9) (% r8) (Imm8 (word 3)) *)
  0x49; 0xc1; 0xe0; 0x03;  (* SHL (% r8) (Imm8 (word 3)) *)
  0x49; 0xc1; 0xec; 0x3d;  (* SHR (% r12) (Imm8 (word 61)) *)
  0xb9; 0x03; 0x00; 0x00; 0x00;
                           (* MOV (% ecx) (Imm32 (word 3)) *)
  0x48; 0x8b; 0x44; 0x24; 0x60;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,96))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x49; 0x01; 0xc0;        (* ADD (% r8) (% rax) *)
  0x49; 0x11; 0xd1;        (* ADC (% r9) (% rdx) *)
  0x48; 0x19; 0xdb;        (* SBB (% rbx) (% rbx) *)
  0x48; 0x8b; 0x44; 0x24; 0x68;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,104))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x29; 0xda;        (* SUB (% rdx) (% rbx) *)
  0x49; 0x01; 0xc1;        (* ADD (% r9) (% rax) *)
  0x49; 0x11; 0xd2;        (* ADC (% r10) (% rdx) *)
  0x48; 0x19; 0xdb;        (* SBB (% rbx) (% rbx) *)
  0x48; 0x8b; 0x44; 0x24; 0x70;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,112))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x29; 0xda;        (* SUB (% rdx) (% rbx) *)
  0x49; 0x01; 0xc2;        (* ADD (% r10) (% rax) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x48; 0x19; 0xdb;        (* SBB (% rbx) (% rbx) *)
  0x48; 0x8b; 0x44; 0x24; 0x78;
                           (* MOV (% rax) (Memop Quadword (%% (rsp,120))) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x29; 0xda;        (* SUB (% rdx) (% rbx) *)
  0x49; 0x01; 0xc3;        (* ADD (% r11) (% rax) *)
  0x49; 0x11; 0xd4;        (* ADC (% r12) (% rdx) *)
  0x49; 0x8d; 0x4c; 0x24; 0x01;
                           (* LEA (% rcx) (%% (r12,1)) *)
  0x48; 0xb8; 0x01; 0x00; 0x00; 0x00; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% rax) (Imm64 (word 18446744069414584321)) *)
  0x48; 0xf7; 0xe1;        (* MUL2 (% rdx,% rax) (% rcx) *)
  0x48; 0x89; 0xcb;        (* MOV (% rbx) (% rcx) *)
  0x48; 0xc1; 0xe3; 0x20;  (* SHL (% rbx) (Imm8 (word 32)) *)
  0x49; 0x01; 0xc8;        (* ADD (% r8) (% rcx) *)
  0x48; 0x83; 0xdb; 0x00;  (* SBB (% rbx) (Imm8 (word 0)) *)
  0x49; 0x29; 0xd9;        (* SUB (% r9) (% rbx) *)
  0x49; 0x83; 0xda; 0x00;  (* SBB (% r10) (Imm8 (word 0)) *)
  0x49; 0x19; 0xc3;        (* SBB (% r11) (% rax) *)
  0x48; 0x19; 0xd1;        (* SBB (% rcx) (% rdx) *)
  0x48; 0xff; 0xc9;        (* DEC (% rcx) *)
  0xb8; 0xff; 0xff; 0xff; 0xff;
                           (* MOV (% eax) (Imm32 (word 4294967295)) *)
  0x48; 0x21; 0xc8;        (* AND (% rax) (% rcx) *)
  0x31; 0xd2;              (* XOR (% edx) (% edx) *)
  0x48; 0x29; 0xc2;        (* SUB (% rdx) (% rax) *)
  0x49; 0x01; 0xc8;        (* ADD (% r8) (% rcx) *)
  0x4c; 0x89; 0x47; 0x20;  (* MOV (Memop Quadword (%% (rdi,32))) (% r8) *)
  0x49; 0x11; 0xc1;        (* ADC (% r9) (% rax) *)
  0x4c; 0x89; 0x4f; 0x28;  (* MOV (Memop Quadword (%% (rdi,40))) (% r9) *)
  0x49; 0x83; 0xd2; 0x00;  (* ADC (% r10) (Imm8 (word 0)) *)
  0x4c; 0x89; 0x57; 0x30;  (* MOV (Memop Quadword (%% (rdi,48))) (% r10) *)
  0x49; 0x11; 0xd3;        (* ADC (% r11) (% rdx) *)
  0x4c; 0x89; 0x5f; 0x38;  (* MOV (Memop Quadword (%% (rdi,56))) (% r11) *)
  0x48; 0x81; 0xc4; 0xc0; 0x00; 0x00; 0x00;
                           (* ADD (% rsp) (Imm32 (word 192)) *)
  0x41; 0x5f;              (* POP (% r15) *)
  0x41; 0x5e;              (* POP (% r14) *)
  0x41; 0x5d;              (* POP (% r13) *)
  0x41; 0x5c;              (* POP (% r12) *)
  0x5b;                    (* POP (% rbx) *)
  0xc3                     (* RET *)
];;

let p256_montjscalarmul_alt_tmc = define_trimmed "p256_montjscalarmul_alt_tmc" p256_montjscalarmul_alt_mc;;

let P256_MONTJSCALARMUL_ALT_EXEC = X86_MK_EXEC_RULE p256_montjscalarmul_alt_tmc;;

(* ------------------------------------------------------------------------- *)
(* Local versions of the subroutines.                                        *)
(* ------------------------------------------------------------------------- *)

let LOCAL_JADD_TAC =
  let baseth = X86_SIMD_SHARPEN_RULE P256_MONTJADD_ALT_NOIBT_SUBROUTINE_CORRECT
  (X86_PROMOTE_RETURN_STACK_TAC p256_montjadd_alt_tmc P256_MONTJADD_ALT_CORRECT
    `[RBX; RBP; R12; R13; R14; R15]` 272) in
  let th =
    CONV_RULE(ONCE_DEPTH_CONV NUM_MULT_CONV)
      (REWRITE_RULE[bignum_triple_from_memory; bignum_pair_from_memory]
       baseth) in
  X86_SUBROUTINE_SIM_TAC
   (p256_montjscalarmul_alt_tmc,P256_MONTJSCALARMUL_ALT_EXEC,
    0xb7d,p256_montjadd_alt_tmc,th)
  [`read RDI s`; `read RSI s`;
   `read(memory :> bytes(read RSI s,8 * 4)) s,
    read(memory :> bytes(word_add (read RSI s) (word 32),8 * 4)) s,
    read(memory :> bytes(word_add (read RSI s) (word 64),8 * 4)) s`;
   `read RDX s`;
   `read(memory :> bytes(read RDX s,8 * 4)) s,
    read(memory :> bytes(word_add (read RDX s) (word 32),8 * 4)) s,
    read(memory :> bytes(word_add (read RDX s) (word 64),8 * 4)) s`;
   `pc + 0xb7d`; `read RSP s`; `read (memory :> bytes64(read RSP s)) s`];;

let LOCAL_JDOUBLE_TAC =
  let baseth = X86_SIMD_SHARPEN_RULE P256_MONTJDOUBLE_ALT_NOIBT_SUBROUTINE_CORRECT
  (X86_PROMOTE_RETURN_STACK_TAC p256_montjdouble_alt_tmc P256_MONTJDOUBLE_ALT_CORRECT
    `[RBX; R12; R13; R14; R15]` 232) in
  let th =
    CONV_RULE(ONCE_DEPTH_CONV NUM_MULT_CONV)
      (REWRITE_RULE[bignum_triple_from_memory; bignum_pair_from_memory]
       baseth) in
  X86_SUBROUTINE_SIM_TAC
   (p256_montjscalarmul_alt_tmc,P256_MONTJSCALARMUL_ALT_EXEC,
    0x32e5,p256_montjdouble_alt_tmc,th)
  [`read RDI s`; `read RSI s`;
   `read(memory :> bytes(read RSI s,8 * 4)) s,
    read(memory :> bytes(word_add (read RSI s) (word 32),8 * 4)) s,
    read(memory :> bytes(word_add (read RSI s) (word 64),8 * 4)) s`;
   `pc + 0x32e5`; `read RSP s`; `read (memory :> bytes64(read RSP s)) s`];;

(* ------------------------------------------------------------------------- *)
(* Overall point operation proof.                                            *)
(* ------------------------------------------------------------------------- *)

let represents_p256 = new_definition
 `represents_p256 P (x,y,z) <=>
        x < p_256 /\ y < p_256 /\ z < p_256 /\
        weierstrass_of_jacobian (integer_mod_ring p_256)
         (tripled (montgomery_decode (256,p_256)) (x,y,z)) = P`;;

let REPRESENTS_P256_NEGATION_ALT = prove
 (`!P x y z.
        represents_p256 P (x,y,z)
        ==> P IN group_carrier p256_group
            ==> represents_p256 (group_inv p256_group P)
                   (x,(if y = 0 then 0 else p_256 - y),z)`,
  REWRITE_TAC[represents_p256] THEN REPEAT GEN_TAC THEN
  STRIP_TAC THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  CONJ_TAC THENL [ASM_ARITH_TAC; ALL_TAC] THEN
  MP_TAC(ISPECL
   [`integer_mod_ring p_256`; `ring_neg (integer_mod_ring p_256) (&3)`;
    `&b_256:int`;
    `tripled (montgomery_decode (256,p_256)) (x,y,z)`]
   WEIERSTRASS_OF_JACOBIAN_NEG) THEN
  ASM_REWRITE_TAC[jacobian_point; GSYM nistp256; P256_GROUP; tripled] THEN
  ANTS_TAC THENL
   [REWRITE_TAC[FIELD_INTEGER_MOD_RING; PRIME_P256] THEN
    REWRITE_TAC[b_256; IN_INTEGER_MOD_RING_CARRIER; p_256;
                INTEGER_MOD_RING_CLAUSES] THEN
    CONV_TAC INT_REDUCE_CONV THEN REWRITE_TAC[GSYM p_256] THEN
    CONJ_TAC THENL [ALL_TAC; CONJ_TAC] THEN
    MATCH_MP_TAC MONTGOMERY_DECODE THEN
    REWRITE_TAC[p_256] THEN CONV_TAC NUM_REDUCE_CONV;
    MATCH_MP_TAC EQ_IMP THEN AP_THM_TAC THEN AP_TERM_TAC THEN AP_TERM_TAC THEN
    REWRITE_TAC[jacobian_neg; INTEGER_MOD_RING_CLAUSES; nistp256] THEN
    REWRITE_TAC[PAIR_EQ] THEN REWRITE_TAC[montgomery_decode] THEN
    CONV_TAC INT_REM_DOWN_CONV THEN
    REWRITE_TAC[INT_REM_EQ; GSYM INT_OF_NUM_CLAUSES] THEN
    MATCH_MP_TAC(INTEGER_RULE
     `(--x:int == y) (mod n) ==> (--(a * x) == a * y) (mod n)`) THEN
    REWRITE_TAC[GSYM INT_REM_EQ; INT_REM_LNEG] THEN
    REWRITE_TAC[INT_ABS_NUM; INT_OF_NUM_REM; INT_OF_NUM_CLAUSES] THEN
    ASM_SIMP_TAC[MOD_LT] THEN COND_CASES_TAC THEN ASM_REWRITE_TAC[MOD_0] THEN
    ASM_SIMP_TAC[INT_OF_NUM_CLAUSES; INT_OF_NUM_SUB; LT_IMP_LE] THEN
    CONV_TAC SYM_CONV THEN MATCH_MP_TAC MOD_LT THEN ASM_ARITH_TAC]);;

let P256_MONTJSCALARMUL_ALT_CORRECT = time prove
 (`!res scalar point n xyz pc stackpointer.
        ALL (nonoverlapping (stackpointer,1320))
            [(word pc,0x47ae); (res,96); (scalar,32); (point,96)] /\
        nonoverlapping (res,96) (word pc,0x47ae)
        ==> ensures x86
             (\s. bytes_loaded s (word pc) p256_montjscalarmul_alt_tmc /\
                  read RIP s = word(pc + 0x11) /\
                  read RSP s = word_add stackpointer (word 296) /\
                  C_ARGUMENTS [res;scalar;point] s /\
                  bignum_from_memory (scalar,4) s = n /\
                  bignum_triple_from_memory (point,4) s = xyz)
             (\s. read RIP s = word (pc + 0xb6b) /\
                  !P. P IN group_carrier p256_group /\
                      represents_p256 P xyz
                      ==> represents_p256
                            (group_pow p256_group P n)
                            (bignum_triple_from_memory(res,4) s))
          (MAYCHANGE [RIP] ,,
           MAYCHANGE [RAX; RCX; RDX; RSI; RDI; R8; R9; R10; R11] ,,
           MAYCHANGE [CF; PF; AF; ZF; SF; OF] ,,
           MAYCHANGE [RBX; RBP; R12; R13; R14; R15] ,,
           MAYCHANGE [memory :> bytes(res,96);
                      memory :> bytes(stackpointer,1320)])`,
  REWRITE_TAC[FORALL_PAIR_THM] THEN
  REWRITE_TAC[GSYM SEQ_ASSOC; MAYCHANGE_REGS_AND_FLAGS_PERMITTED_BY_ABI] THEN
  MAP_EVERY X_GEN_TAC
   [`res:int64`; `scalar:int64`; `point:int64`;
    `n_input:num`; `x:num`; `y:num`; `z:num`;
    `pc:num`; `stackpointer:int64`] THEN
  REWRITE_TAC[ALLPAIRS; ALL; NONOVERLAPPING_CLAUSES] THEN STRIP_TAC THEN
  REWRITE_TAC[C_ARGUMENTS; SOME_FLAGS; PAIR_EQ; bignum_triple_from_memory] THEN
  CONV_TAC(ONCE_DEPTH_CONV NUM_MULT_CONV) THEN
  CONV_TAC(ONCE_DEPTH_CONV NORMALIZE_RELATIVE_ADDRESS_CONV) THEN
  ENSURES_EXISTING_PRESERVED_TAC `RSP` THEN

  (*** Modified input arguments, mathematically first ***)

  ABBREV_TAC `n_red = n_input MOD n_256` THEN
  SUBGOAL_THEN `n_red < n_256` ASSUME_TAC THENL
   [EXPAND_TAC "n_red" THEN REWRITE_TAC[n_256] THEN ARITH_TAC; ALL_TAC] THEN

  ABBREV_TAC `sgn <=> 2 EXP 255 <= n_red` THEN
  ABBREV_TAC `n_neg = if sgn then n_256 - n_red else n_red` THEN
  SUBGOAL_THEN `n_neg < 2 EXP 255` ASSUME_TAC THENL
   [MAP_EVERY EXPAND_TAC ["n_neg"; "sgn"] THEN
    UNDISCH_TAC `n_red < n_256` THEN REWRITE_TAC[n_256] THEN ARITH_TAC;
    ALL_TAC] THEN

  ABBREV_TAC
   `recoder =
    0x0888888888888888888888888888888888888888888888888888888888888888` THEN
  ABBREV_TAC `n = n_neg + recoder` THEN
  SUBGOAL_THEN `n < 9 * 2 EXP 252` ASSUME_TAC THENL
   [MAP_EVERY EXPAND_TAC ["n"; "recoder"] THEN
    UNDISCH_TAC `n_neg < 2 EXP 255` THEN ARITH_TAC;
    ALL_TAC] THEN

  ABBREV_TAC `y' = if sgn /\ ~(y = 0) then p_256 - y else y` THEN

  (*** Main loop invariant setup. The bound on y is handy to have included ***)

  ENSURES_WHILE_DOWN_TAC `63` `pc + 0x62d` `pc + 0xaef`
   `\i s.
      read RSP s = word_add stackpointer (word 296) /\
      read (memory :> bytes64(word_add stackpointer (word 1288))) s = res /\
      read RBP s = word (4 * i) /\
      bignum_from_memory(word_add stackpointer (word 296),4) s = n /\
      !P. P IN group_carrier p256_group /\
          y < p_256 /\ represents_p256 P (x,y',z)
          ==> represents_p256
                (group_zpow p256_group P
                    (&(n DIV 2 EXP (4 * i)) - &(recoder DIV 2 EXP (4 * i))))
                (bignum_triple_from_memory
                     (word_add stackpointer (word 328),4) s) /\
              !i. i < 8
                  ==> represents_p256 (group_pow p256_group P (i + 1))
                       (bignum_triple_from_memory
                       (word_add stackpointer (word (96 * i + 520)),4) s)` THEN
  REPEAT CONJ_TAC THENL
   [ARITH_TAC;

    (*** Initial holding of invariant ***)
    (*** First, the input reduced modulo the group order ***)

    REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
    BIGNUM_LDIGITIZE_TAC "nin_" `read (memory :> bytes (scalar,8 * 4)) s0` THEN
    X86_ACCSTEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC [8;10;12;14] (1--18) THEN
    MAP_EVERY REABBREV_TAC
     [`nr_0 = read R8 s18`;
      `nr_1 = read R9 s18`;
      `nr_2 = read R10 s18`;
      `nr_3 = read R11 s18`] THEN
    SUBGOAL_THEN `bignum_of_wordlist[nr_0; nr_1; nr_2; nr_3] = n_red`
    ASSUME_TAC THENL
     [SUBGOAL_THEN `carry_s14 <=> n_input < n_256` SUBST_ALL_TAC THENL
       [MATCH_MP_TAC FLAG_FROM_CARRY_LT THEN EXISTS_TAC `256` THEN
        EXPAND_TAC "n_input" THEN
        REWRITE_TAC[n_256; GSYM REAL_OF_NUM_CLAUSES] THEN
        ACCUMULATOR_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
        DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN BOUNDER_TAC[];
        ALL_TAC] THEN
      EXPAND_TAC "n_red" THEN
      W(MP_TAC o PART_MATCH (lhand o rand) MOD_CASES o rand o snd) THEN
      ANTS_TAC THENL
       [REWRITE_TAC[n_256] THEN EXPAND_TAC "n_input" THEN BOUNDER_TAC[];
        DISCH_THEN SUBST1_TAC] THEN
      MAP_EVERY EXPAND_TAC ["nr_0"; "nr_1"; "nr_2"; "nr_3"] THEN
      COND_CASES_TAC THEN ASM_REWRITE_TAC[] THEN
      RULE_ASSUM_TAC(REWRITE_RULE[NOT_LT]) THEN
      ASM_SIMP_TAC[GSYM REAL_OF_NUM_EQ; GSYM REAL_OF_NUM_SUB] THEN
      EXPAND_TAC "n_input" THEN REWRITE_TAC[GSYM REAL_OF_NUM_ADD] THEN
      REWRITE_TAC[GSYM REAL_OF_NUM_POW; GSYM REAL_OF_NUM_MUL] THEN
      MATCH_MP_TAC EQUAL_FROM_CONGRUENT_REAL THEN
      MAP_EVERY EXISTS_TAC [`256`; `&0:real`] THEN ASM_REWRITE_TAC[] THEN
      CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN CONJ_TAC THENL
       [ASM_REWRITE_TAC[REAL_OF_NUM_ADD; REAL_OF_NUM_POW; REAL_OF_NUM_MUL] THEN
        ASM_REWRITE_TAC[REAL_SUB_LE; REAL_OF_NUM_LE] THEN
        MATCH_MP_TAC(REAL_ARITH `x:real < y ==> x - &n < y`) THEN
        REWRITE_TAC[REAL_OF_NUM_LT] THEN EXPAND_TAC "n_input" THEN
        BOUNDER_TAC[];
        ALL_TAC] THEN
      CONJ_TAC THENL [REAL_INTEGER_TAC; ALL_TAC] THEN
      EXPAND_TAC "n_input" THEN
      REWRITE_TAC[bignum_of_wordlist; n_256; GSYM REAL_OF_NUM_CLAUSES] THEN
      ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
      REWRITE_TAC[REAL_BITVAL_NOT; n_256] THEN
      DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN
      CONV_TAC(RAND_CONV REAL_POLY_CONV) THEN REAL_INTEGER_TAC;
      ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

    (*** Conditional negation of the scalar ***)

    X86_ACCSTEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (19--22) (19--28) THEN
    MAP_EVERY REABBREV_TAC
     [`nn_0 = read R8 s28`;
      `nn_1 = read R9 s28`;
      `nn_2 = read R10 s28`;
      `nn_3 = read R11 s28`] THEN

    SUBGOAL_THEN
     `word_ushr nr_3 63:int64 = word(bitval sgn)`
    SUBST_ALL_TAC THENL
     [MAP_EVERY EXPAND_TAC ["sgn"; "n_red"] THEN
      REWRITE_TAC[ARITH_RULE `2 EXP 255 <= b <=> ~(b DIV 2 EXP 255 = 0)`] THEN
      CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
      REWRITE_TAC[WORD_BLAST
       `val(x:int64) DIV 2 EXP 63 = bitval(bit 63 x)`] THEN
      REWRITE_TAC[BITVAL_EQ_0] THEN CONV_TAC WORD_BLAST;
      RULE_ASSUM_TAC(REWRITE_RULE[VAL_WORD_BITVAL; BITVAL_EQ_0])] THEN

    SUBGOAL_THEN `bignum_of_wordlist[nn_0; nn_1; nn_2; nn_3] = n_neg`
    ASSUME_TAC THENL
     [MAP_EVERY EXPAND_TAC ["n_neg"; "nn_0"; "nn_1"; "nn_2"; "nn_3"] THEN
      COND_CASES_TAC THEN ASM_REWRITE_TAC[] THEN
      REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES] THEN
      MATCH_MP_TAC EQUAL_FROM_CONGRUENT_REAL THEN
      MAP_EVERY EXISTS_TAC [`256`; `&0:real`] THEN ASM_REWRITE_TAC[] THEN
      CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN CONJ_TAC THENL
       [UNDISCH_TAC `n_red < n_256` THEN
        REWRITE_TAC[REAL_OF_NUM_CLAUSES; LE_0; n_256] THEN ARITH_TAC;
        ALL_TAC] THEN
      CONJ_TAC THENL [REAL_INTEGER_TAC; ALL_TAC] THEN
      ASM_SIMP_TAC[GSYM REAL_OF_NUM_SUB; LT_IMP_LE] THEN EXPAND_TAC "n_red" THEN
      REWRITE_TAC[bignum_of_wordlist; n_256; GSYM REAL_OF_NUM_CLAUSES] THEN
      ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
      REWRITE_TAC[REAL_BITVAL_NOT; n_256] THEN
      DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN
      CONV_TAC(RAND_CONV REAL_POLY_CONV) THEN REAL_INTEGER_TAC;
      ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

    (*** Add the recoding constant ***)

    X86_ACCSTEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (30--33) (29--38) THEN
    SUBGOAL_THEN
     `read (memory :> bytes(word_add stackpointer (word 296),8 * 4)) s38 = n`
    ASSUME_TAC THENL
     [CONV_TAC(LAND_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
      REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES] THEN
      MATCH_MP_TAC EQUAL_FROM_CONGRUENT_REAL THEN
      MAP_EVERY EXISTS_TAC [`256`; `&0:real`] THEN ASM_REWRITE_TAC[] THEN
      CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN CONJ_TAC THENL
       [REWRITE_TAC[REAL_OF_NUM_CLAUSES] THEN
        UNDISCH_TAC `n < 9 * 2 EXP 252` THEN ARITH_TAC;
        ALL_TAC] THEN
      CONJ_TAC THENL [REAL_INTEGER_TAC; ALL_TAC] THEN
      ASM_SIMP_TAC[GSYM REAL_OF_NUM_SUB; LT_IMP_LE] THEN
      MAP_EVERY EXPAND_TAC ["n"; "recoder"; "n_neg"] THEN
      REWRITE_TAC[bignum_of_wordlist; n_256; GSYM REAL_OF_NUM_CLAUSES;
                  VAL_WORD_ADD; DIMINDEX_64; REAL_OF_NUM_MOD; WORD_BLAST
       `word_xor sum_s33 (word 9223372036854775808):int64 =
        word_add sum_s33 (word 9223372036854775808)`] THEN
      CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV) THEN
      ASM_SIMP_TAC[GSYM REAL_OF_NUM_SUB; LT_IMP_LE] THEN
      MAP_EVERY EXPAND_TAC ["n"; "recoder"; "n_neg"] THEN
      REWRITE_TAC[bignum_of_wordlist; n_256; GSYM REAL_OF_NUM_CLAUSES] THEN
      ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
      REWRITE_TAC[REAL_BITVAL_NOT; n_256] THEN
      DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN
      CONV_TAC(RAND_CONV REAL_POLY_CONV) THEN REAL_INTEGER_TAC;
      ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

   (*** Copying and optional negation of the point as zeroth table entry ***)

    BIGNUM_LDIGITIZE_TAC "x_"
     `read (memory :> bytes(point,8 * 4)) s38` THEN
    BIGNUM_LDIGITIZE_TAC "y_"
     `read (memory :> bytes(word_add point (word 32),8 * 4)) s38` THEN
    BIGNUM_LDIGITIZE_TAC "z_"
     `read (memory :> bytes(word_add point (word 64),8 * 4)) s38` THEN

    X86_ACCSTEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (62--65) (39--82) THEN
    SUBGOAL_THEN
     `read(memory :> bytes(word_add stackpointer (word 520),8 * 4)) s82 = x /\
      read(memory :> bytes(word_add stackpointer (word 584),8 * 4)) s82 = z`
    STRIP_ASSUME_TAC THENL
     [CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[];
      ALL_TAC] THEN

    (*** Defer conditional negation until we reach ambient y < p_256 asm ***)
    (*** At that point we will prove that in fact y'' = y' ***)

    ABBREV_TAC
     `y'' = read (memory :> bytes(word_add stackpointer (word 552),8 * 4))
                 s82` THEN

    (*** Computation of 2 * P ***)

    X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (83--85) THEN
    LOCAL_JDOUBLE_TAC 86 THEN
    MAP_EVERY ABBREV_TAC
     [`x2 = read (memory :> bytes(word_add stackpointer (word 616),8 * 4)) s86`;
      `y2 = read (memory :> bytes(word_add stackpointer (word 648),8 * 4)) s86`;
      `z2 = read (memory :> bytes(word_add stackpointer (word 680),8 * 4)) s86`
     ] THEN

    (*** Computation of 3 * P ***)

    X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (87--90) THEN
    LOCAL_JADD_TAC 91 THEN
    MAP_EVERY ABBREV_TAC
     [`x3 = read (memory :> bytes(word_add stackpointer (word 712),8 * 4)) s91`;
      `y3 = read (memory :> bytes(word_add stackpointer (word 744),8 * 4)) s91`;
      `z3 = read (memory :> bytes(word_add stackpointer (word 776),8 * 4)) s91`
     ] THEN

    (*** Computation of 4 * P ***)

    X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (92--94) THEN
    LOCAL_JDOUBLE_TAC 95 THEN
    MAP_EVERY ABBREV_TAC
     [`x4 = read (memory :> bytes(word_add stackpointer (word 808),8 * 4)) s95`;
      `y4 = read (memory :> bytes(word_add stackpointer (word 840),8 * 4)) s95`;
      `z4 = read (memory :> bytes(word_add stackpointer (word 872),8 * 4)) s95`
     ] THEN

    (*** Computation of 5 * P ***)

    X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (96--99) THEN
    LOCAL_JADD_TAC 100 THEN
    MAP_EVERY ABBREV_TAC
     [`x5 = read (memory :> bytes(word_add stackpointer (word 904),8 * 4)) s100`;
      `y5 = read (memory :> bytes(word_add stackpointer (word 936),8 * 4)) s100`;
      `z5 = read (memory :> bytes(word_add stackpointer (word 968),8 * 4)) s100`
     ] THEN

    (*** Computation of 6 * P ***)

    X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (101--103) THEN
    LOCAL_JDOUBLE_TAC 104 THEN
    MAP_EVERY ABBREV_TAC
     [`x6 = read (memory :> bytes(word_add stackpointer (word 1000),8 * 4)) s104`;
      `y6 = read (memory :> bytes(word_add stackpointer (word 1032),8 * 4)) s104`;
      `z6 = read (memory :> bytes(word_add stackpointer (word 1064),8 * 4)) s104`
     ] THEN

    (*** Computation of 7 * P ***)

    X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (105--108) THEN
    LOCAL_JADD_TAC 109 THEN
    MAP_EVERY ABBREV_TAC
     [`x7 = read (memory :> bytes(word_add stackpointer (word 1096),8 * 4)) s109`;
      `y7 = read (memory :> bytes(word_add stackpointer (word 1128),8 * 4)) s109`;
      `z7 = read (memory :> bytes(word_add stackpointer (word 1160),8 * 4)) s109`
     ] THEN

    (*** Computation of 8 * P ***)

    X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (110--112) THEN
    LOCAL_JDOUBLE_TAC 113 THEN
    MAP_EVERY ABBREV_TAC
     [`x8 = read (memory :> bytes(word_add stackpointer (word 1192),8 * 4)) s113`;
      `y8 = read (memory :> bytes(word_add stackpointer (word 1224),8 * 4)) s113`;
      `z8 = read (memory :> bytes(word_add stackpointer (word 1256),8 * 4)) s113`
     ] THEN

    (*** Selection of the top bitfield ***)

    X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (114--115) THEN
    SUBGOAL_THEN
     `word_ushr (word_xor sum_s33 (word 9223372036854775808):int64) 60 =
      word(n DIV 2 EXP 252)`
    SUBST_ALL_TAC THENL
     [EXPAND_TAC "n" THEN CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN
      ASM_REWRITE_TAC[] THEN
      CONV_TAC(ONCE_DEPTH_CONV BIGNUM_OF_WORDLIST_DIV_CONV) THEN
      CONV_TAC WORD_BLAST;
      ALL_TAC] THEN

    (*** Constant-time table selection ***)

    BIGNUM_LDIGITIZE_TAC "fab_"
     `read(memory :> bytes(word_add stackpointer (word 520),8 * 96)) s115` THEN
    X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (116--244) THEN
    ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN

    REWRITE_TAC[bignum_triple_from_memory] THEN
    CONV_TAC(ONCE_DEPTH_CONV EXPAND_CASES_CONV) THEN
    CONV_TAC(DEPTH_CONV(NUM_ADD_CONV ORELSEC NUM_MULT_CONV)) THEN
    CONV_TAC(ONCE_DEPTH_CONV NORMALIZE_RELATIVE_ADDRESS_CONV) THEN
    ASM_REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN

    (*** Finally justify the negation of y before continuing ***)

    X_GEN_TAC `P:(int#int)option` THEN STRIP_TAC THEN
    SUBGOAL_THEN `y'':num = y'` SUBST_ALL_TAC THENL
     [MAP_EVERY EXPAND_TAC ["y''"; "y'"] THEN
      CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
      SIMP_TAC[WORD_SUB_0; VAL_EQ_0; COND_SWAP; WORD_BITVAL_EQ_0] THEN
      REWRITE_TAC[WORD_OR_EQ_0; GSYM CONJ_ASSOC] THEN
      MP_TAC(SPEC `[y_0;y_1;y_2;y_3]:int64 list` BIGNUM_OF_WORDLIST_EQ_0) THEN
      ASM_REWRITE_TAC[ALL] THEN DISCH_THEN(SUBST1_TAC o SYM) THEN
      REWRITE_TAC[WORD_BITVAL_EQ_0; MESON[]
       `(if p then a else b) = x <=> if p then a = x else b = x`] THEN
      REWRITE_TAC[MESON[] `(if p then T else ~q) <=> ~(q /\ ~p)`] THEN
      EXPAND_TAC "y'" THEN REWRITE_TAC[COND_SWAP] THEN
      COND_CASES_TAC THEN ASM_REWRITE_TAC[] THEN
      MATCH_MP_TAC CONG_IMP_EQ THEN EXISTS_TAC `2 EXP 256` THEN
      CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN
      CONJ_TAC THENL [REWRITE_TAC[p_256] THEN ARITH_TAC; ALL_TAC] THEN
      ASM_SIMP_TAC[num_congruent; GSYM INT_OF_NUM_SUB; LT_IMP_LE] THEN
      REWRITE_TAC[REAL_INT_CONGRUENCE] THEN
      REWRITE_TAC[GSYM REAL_OF_INT_CLAUSES] THEN
      REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; REAL_POW_EQ_0] THEN
      REWRITE_TAC[REAL_OF_NUM_EQ; ARITH_EQ] THEN EXPAND_TAC "y" THEN
      REWRITE_TAC[bignum_of_wordlist; p_256; GSYM REAL_OF_NUM_CLAUSES] THEN
      ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
      DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC;
      ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

    (*** Final fiddle of the representations ***)

  CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN
    ASM_REWRITE_TAC[] THEN REWRITE_TAC[SYM(NUM_EXP_CONV `2 EXP 252`)] THEN
    SUBGOAL_THEN `n DIV 2 EXP 252 < 9` MP_TAC THENL
     [UNDISCH_TAC `n < 9 * 2 EXP 252` THEN ARITH_TAC;
      SPEC_TAC(`n DIV 2 EXP 252`,`b:num`)] THEN
    REWRITE_TAC[MESON[ARITH_RULE `0 < 9`]
      `(!b. b < 9 ==> P b /\ Q) <=> (Q ==> !b. b < 9 ==> P b) /\ Q`] THEN
    CONJ_TAC THENL
     [EXPAND_TAC "recoder" THEN CONV_TAC NUM_REDUCE_CONV THEN
      REWRITE_TAC[INT_SUB_RZERO; GROUP_NPOW] THEN
      CONV_TAC(RAND_CONV EXPAND_CASES_CONV) THEN
      CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV) THEN
      ASM_REWRITE_TAC[WORD_SUB_0; VAL_WORD_BITVAL; BITVAL_EQ_0] THEN
      MATCH_MP_TAC(TAUT `q /\ (p ==> r) ==> p ==> q /\ r`) THEN
      CONJ_TAC THENL
       [REWRITE_TAC[group_pow; P256_GROUP; represents_p256; tripled;
                    weierstrass_of_jacobian; montgomery_decode; p_256;
                    bignum_of_wordlist; INTEGER_MOD_RING_CLAUSES] THEN
        CONV_TAC(DEPTH_CONV(WORD_NUM_RED_CONV ORELSEC INVERSE_MOD_CONV));
        REPEAT(MATCH_MP_TAC MONO_AND THEN CONJ_TAC) THEN
        MATCH_MP_TAC EQ_IMP THEN AP_TERM_TAC THEN REWRITE_TAC[PAIR_EQ] THEN
        W(MAP_EVERY EXPAND_TAC o map (name_of o lhs) o conjuncts o snd) THEN
        CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN
        ASM_REWRITE_TAC[WORD_SUB_0; VAL_WORD_BITVAL; BITVAL_EQ_0]];
      ALL_TAC] THEN

    REPEAT(FIRST_X_ASSUM(MP_TAC o check (is_forall o concl))) THEN
    DISCH_THEN(MP_TAC o SPEC `P:(int#int)option`) THEN ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC] THEN
    ASM_SIMP_TAC[GROUP_RULE `group_mul G x x = group_pow G x 2`] THEN
    GEN_REWRITE_TAC I [IMP_CONJ] THEN DISCH_TAC THEN
    GEN_REWRITE_TAC I [IMP_CONJ] THEN DISCH_THEN(MP_TAC o SPECL
     [`group_pow p256_group P 2`; `P:(int#int)option`]) THEN
    ASM_SIMP_TAC[GROUP_RULE `group_pow G x 2 = x <=> x = group_id G`] THEN
    ASM_SIMP_TAC[GROUP_RULE
     `group_mul G (group_pow G x 2) x = group_pow G x 3`] THEN
    ANTS_TAC THENL [REWRITE_TAC[P256_GROUP]; DISCH_TAC] THEN
    GEN_REWRITE_TAC I [IMP_CONJ] THEN DISCH_THEN(MP_TAC o SPEC
     `group_pow p256_group P 2`) THEN
    ASM_SIMP_TAC[GSYM GROUP_POW_ADD] THEN CONV_TAC NUM_REDUCE_CONV THEN
    DISCH_TAC THEN GEN_REWRITE_TAC I [IMP_CONJ] THEN DISCH_THEN(MP_TAC o SPECL
     [`group_pow p256_group P 4`; `P:(int#int)option`]) THEN
    ASM_SIMP_TAC[GROUP_RULE
     `group_mul G (group_pow G x 4) x = group_pow G x 5`] THEN
    ANTS_TAC THENL
     [ASM_SIMP_TAC[GROUP_POW_EQ_ID; P256_GROUP_ELEMENT_ORDER; GROUP_RULE
        `group_pow G x 4 = x <=> group_pow G x 3 = group_id G`] THEN
      REWRITE_TAC[P256_GROUP] THEN COND_CASES_TAC THEN REWRITE_TAC[] THEN
      REWRITE_TAC[n_256] THEN CONV_TAC(RAND_CONV DIVIDES_CONV) THEN
      REWRITE_TAC[];
      DISCH_TAC] THEN
    GEN_REWRITE_TAC I [IMP_CONJ] THEN DISCH_THEN(MP_TAC o SPEC
     `group_pow p256_group P 3`) THEN
    ASM_SIMP_TAC[GSYM GROUP_POW_ADD] THEN CONV_TAC NUM_REDUCE_CONV THEN
    DISCH_TAC THEN GEN_REWRITE_TAC I [IMP_CONJ] THEN DISCH_THEN(MP_TAC o SPECL
     [`group_pow p256_group P 6`; `P:(int#int)option`]) THEN
    ASM_SIMP_TAC[GROUP_RULE
     `group_mul G (group_pow G x 6) x = group_pow G x 7`] THEN
    ANTS_TAC THENL
     [ASM_SIMP_TAC[GROUP_POW_EQ_ID; P256_GROUP_ELEMENT_ORDER; GROUP_RULE
        `group_pow G x 6 = x <=> group_pow G x 5 = group_id G`] THEN
      REWRITE_TAC[P256_GROUP] THEN COND_CASES_TAC THEN REWRITE_TAC[] THEN
      REWRITE_TAC[n_256] THEN CONV_TAC(RAND_CONV DIVIDES_CONV) THEN
      REWRITE_TAC[];
      DISCH_TAC] THEN
    DISCH_THEN(MP_TAC o SPEC `group_pow p256_group P 4`) THEN
    ASM_SIMP_TAC[GSYM GROUP_POW_ADD] THEN CONV_TAC NUM_REDUCE_CONV THEN
    DISCH_TAC THEN ASM_SIMP_TAC[GROUP_POW_1];

    (*** Defer the main invariant preservation proof till below ***)

    ALL_TAC;

    (*** The trivial loop-back goal ***)

    REPEAT STRIP_TAC THEN CONV_TAC(ONCE_DEPTH_CONV EXPAND_CASES_CONV) THEN
    CONV_TAC NUM_REDUCE_CONV THEN
    X86_SIM_TAC P256_MONTJSCALARMUL_ALT_EXEC (1--2) THEN
    VAL_INT64_TAC `4 * i` THEN
    ASM_REWRITE_TAC[ARITH_RULE `4 * i = 0 <=> ~(0 < i)`];

    (*** Final copying to the output and specializing invariant ***)

    GEN_REWRITE_TAC (RATOR_CONV o LAND_CONV o ONCE_DEPTH_CONV)
     [bignum_triple_from_memory] THEN
    CONV_TAC NUM_REDUCE_CONV THEN REWRITE_TAC[DIV_1] THEN
    CONV_TAC(ONCE_DEPTH_CONV NORMALIZE_RELATIVE_ADDRESS_CONV) THEN
    REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
    BIGNUM_LDIGITIZE_TAC "x_"
     `read (memory :> bytes(word_add stackpointer (word 328),8 * 4)) s0` THEN
    BIGNUM_LDIGITIZE_TAC "y_"
     `read (memory :> bytes(word_add stackpointer (word 360),8 * 4)) s0` THEN
    BIGNUM_LDIGITIZE_TAC "z_"
     `read (memory :> bytes(word_add stackpointer (word 392),8 * 4)) s0` THEN
    FIRST_X_ASSUM(ASSUME_TAC o MATCH_MP (MESON[]
      `(!x. P x ==> Q x /\ R x) ==> (!x. P x ==> Q x)`)) THEN
    X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (1--27) THEN
    ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
    CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
    DISCARD_STATE_TAC "s27" THEN X_GEN_TAC `P:(int#int)option` THEN
    STRIP_TAC THEN
    ABBREV_TAC `Q = if sgn then group_inv p256_group P else P` THEN
    SUBGOAL_THEN `Q IN group_carrier p256_group` ASSUME_TAC THENL
     [EXPAND_TAC "Q" THEN COND_CASES_TAC THEN ASM_SIMP_TAC[GROUP_INV];
      ALL_TAC] THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `Q:(int#int)option`) THEN
    ASM_REWRITE_TAC[] THEN
    SUBGOAL_THEN
     `group_zpow p256_group Q (&n - &recoder) = group_pow p256_group P n_input`
    SUBST1_TAC THENL
     [MAP_EVERY EXPAND_TAC ["Q"; "n"; "n_neg"; "n_red"] THEN
      REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES] THEN
      REWRITE_TAC[INT_ARITH `(x + y) - y:int = x`] THEN
      COND_CASES_TAC THEN REWRITE_TAC[GSYM INT_OF_NUM_REM; GSYM GROUP_NPOW] THEN
      ASM_SIMP_TAC[GSYM GROUP_INV_ZPOW; GSYM GROUP_ZPOW_NEG; GROUP_ZPOW_EQ] THEN
      ASM_SIMP_TAC[P256_GROUP_ELEMENT_ORDER; INT_CONG_LREM; INT_CONG_REFL] THEN
      EXPAND_TAC "n_red" THEN COND_CASES_TAC THEN
      REWRITE_TAC[INT_CONG_MOD_1] THEN
      (SUBGOAL_THEN `n_input MOD n_256 <= n_256`
       (fun th -> SIMP_TAC[GSYM INT_OF_NUM_SUB; th])
       THENL [REWRITE_TAC[n_256] THEN ARITH_TAC; ALL_TAC]) THEN
      REWRITE_TAC[INTEGER_RULE
      `(--(n - x):int == y) (mod n) <=> (x == y) (mod n)`] THEN
      REWRITE_TAC[INT_CONG_LREM; INT_CONG_REFL; GSYM INT_OF_NUM_REM];
      DISCH_THEN MATCH_MP_TAC] THEN
    CONJ_TAC THENL
     [RULE_ASSUM_TAC(REWRITE_RULE[represents_p256]) THEN ASM_REWRITE_TAC[];
      MAP_EVERY EXPAND_TAC ["y'"; "Q"]] THEN
    BOOL_CASES_TAC `sgn:bool` THEN ASM_REWRITE_TAC[] THEN
    FIRST_ASSUM(MP_TAC o MATCH_MP REPRESENTS_P256_NEGATION_ALT) THEN
    ASM_SIMP_TAC[COND_SWAP]] THEN

  (**** Preservation of the loop invariant ***)

  X_GEN_TAC `i:num` THEN STRIP_TAC THEN
  CONV_TAC(RATOR_CONV(LAND_CONV(ONCE_DEPTH_CONV EXPAND_CASES_CONV))) THEN
  CONV_TAC NUM_REDUCE_CONV THEN
  GEN_REWRITE_TAC (RATOR_CONV o LAND_CONV o ONCE_DEPTH_CONV)
   [bignum_triple_from_memory] THEN
  CONV_TAC NUM_REDUCE_CONV THEN
  CONV_TAC(ONCE_DEPTH_CONV NORMALIZE_RELATIVE_ADDRESS_CONV) THEN

  GHOST_INTRO_TAC `Xa:num`
   `bignum_from_memory (word_add stackpointer (word 328),4)` THEN
  GHOST_INTRO_TAC `Ya:num`
   `bignum_from_memory (word_add stackpointer (word 360),4)` THEN
  GHOST_INTRO_TAC `Za:num`
   `bignum_from_memory (word_add stackpointer (word 392),4)` THEN

  (*** Computation of 2 * (Xa,Ya,Za) ***)

  REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN ENSURES_INIT_TAC "s0" THEN
  X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (1--4) THEN
  RULE_ASSUM_TAC(REWRITE_RULE[WORD_RULE
   `word_sub (word (4 * (i + 1))) (word 4) = word(4 * i)`]) THEN
  LOCAL_JDOUBLE_TAC 5 THEN
  MAP_EVERY ABBREV_TAC
   [`X2a = read (memory :> bytes(word_add stackpointer (word 328),8 * 4)) s5`;
    `Y2a = read (memory :> bytes(word_add stackpointer (word 360),8 * 4)) s5`;
    `Z2a = read (memory :> bytes(word_add stackpointer (word 392),8 * 4)) s5`
   ] THEN

  (*** Computation of 4 * (Xa,Ya,Za) ***)

  X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (6--8) THEN LOCAL_JDOUBLE_TAC 9 THEN
  MAP_EVERY ABBREV_TAC
   [`X4a = read (memory :> bytes(word_add stackpointer (word 328),8 * 4)) s9`;
    `Y4a = read (memory :> bytes(word_add stackpointer (word 360),8 * 4)) s9`;
    `Z4a = read (memory :> bytes(word_add stackpointer (word 392),8 * 4)) s9`
   ] THEN

  (*** Computation of 8 * (Xa,Ya,Za) ***)

  X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (10--12) THEN LOCAL_JDOUBLE_TAC 13 THEN
  MAP_EVERY ABBREV_TAC
   [`X8a = read (memory :> bytes(word_add stackpointer (word 328),8 * 4)) s13`;
    `Y8a = read (memory :> bytes(word_add stackpointer (word 360),8 * 4)) s13`;
    `Z8a = read (memory :> bytes(word_add stackpointer (word 392),8 * 4)) s13`
   ] THEN

  (*** Computation of 16 * (Xa,Ya,Za) ***)

  X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (14--16) THEN LOCAL_JDOUBLE_TAC 17 THEN
  MAP_EVERY ABBREV_TAC
   [`Xha = read (memory :> bytes(word_add stackpointer (word 328),8 * 4)) s17`;
    `Yha = read (memory :> bytes(word_add stackpointer (word 360),8 * 4)) s17`;
    `Zha = read (memory :> bytes(word_add stackpointer (word 392),8 * 4)) s17`
   ] THEN

  (*** Selection of btable nybble ***)

  SUBGOAL_THEN
   `read(memory :> bytes64 (word_add stackpointer
         (word(296 + 8 * val(word_ushr (word (4 * i)) 6:int64))))) s17 =
    word(n DIV 2 EXP (64 * (4 * i) DIV 64) MOD 2 EXP (64 * 1))`
  ASSUME_TAC THENL
   [EXPAND_TAC "n" THEN
    REWRITE_TAC[GSYM BIGNUM_FROM_MEMORY_BYTES] THEN
    REWRITE_TAC[BIGNUM_FROM_MEMORY_DIV; BIGNUM_FROM_MEMORY_MOD] THEN
    ASM_SIMP_TAC[ARITH_RULE
     `i < 63 ==> MIN (4 - (4 * i) DIV 64) 1 = 1`] THEN
    REWRITE_TAC[BIGNUM_FROM_MEMORY_SING; WORD_VAL] THEN
    REWRITE_TAC[GSYM WORD_ADD_ASSOC; GSYM WORD_ADD] THEN
    AP_THM_TAC THEN REPLICATE_TAC 7 AP_TERM_TAC THEN
    REWRITE_TAC[VAL_WORD_USHR] THEN CONV_TAC NUM_REDUCE_CONV THEN
    AP_THM_TAC THEN AP_TERM_TAC THEN MATCH_MP_TAC VAL_WORD_EQ THEN
    REWRITE_TAC[DIMINDEX_64] THEN CONV_TAC NUM_REDUCE_CONV THEN
    ASM BOUNDER_TAC[];
    ALL_TAC] THEN

  (*** Recoding offset to get indexing and negation flag ***)

  X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (18--27) THEN
  RULE_ASSUM_TAC(REWRITE_RULE[MOD_64_CLAUSES]) THEN
  ABBREV_TAC `bf = (n DIV (2 EXP (4 * i))) MOD 16` THEN
  SUBGOAL_THEN
   `word_and
     (word_ushr
        (word ((n DIV 2 EXP (64 * (4 * i) DIV 64)) MOD 2 EXP 64))
        ((4 * i) MOD 64))
     (word 15):int64 = word bf`
  SUBST_ALL_TAC THENL
   [REWRITE_TAC[GSYM VAL_EQ; VAL_WORD_AND_MASK_WORD;
                ARITH_RULE `15 = 2 EXP 4 - 1`] THEN
    REWRITE_TAC[word_jushr; VAL_WORD_USHR; DIMINDEX_64; MOD_64_CLAUSES] THEN
    EXPAND_TAC "bf" THEN REWRITE_TAC[VAL_WORD; DIMINDEX_64] THEN
    REWRITE_TAC[MOD_MOD_EXP_MIN; ARITH_RULE `16 = 2 EXP 4`] THEN
    CONV_TAC(ONCE_DEPTH_CONV NUM_MIN_CONV) THEN
    REWRITE_TAC[DIV_MOD; MOD_MOD_EXP_MIN; GSYM EXP_ADD; DIV_DIV] THEN
    REWRITE_TAC[ADD_ASSOC; ARITH_RULE `64 * i DIV 64 + i MOD 64 = i`] THEN
    AP_THM_TAC THEN REPLICATE_TAC 3 AP_TERM_TAC THEN
    REWRITE_TAC[ARITH_RULE `MIN a b = b <=> b <= a`] THEN
    REWRITE_TAC[ARITH_RULE
     `x <= 64 * y DIV 64 + z <=> x + y MOD 64 <= y + z`] THEN
    REWRITE_TAC[ARITH_RULE `64 = 4 * 16`; MOD_MULT2] THEN
    UNDISCH_TAC `i < 63` THEN ARITH_TAC;
    ALL_TAC] THEN
  SUBGOAL_THEN `val(word bf:int64) = bf` SUBST_ALL_TAC THENL
   [MATCH_MP_TAC VAL_WORD_EQ THEN REWRITE_TAC[DIMINDEX_64] THEN
    EXPAND_TAC "bf" THEN ARITH_TAC;
    ALL_TAC] THEN
  ABBREV_TAC `ix = if bf < 8 then 8 - bf else bf - 8` THEN
   FIRST_X_ASSUM(MP_TAC o SPEC `word ix:int64` o MATCH_MP (MESON[]
   `read c s = word_sub a b
    ==> !x'. word_sub a b = x' ==> read c s = x'`)) THEN
  ANTS_TAC THENL
   [EXPAND_TAC "ix" THEN REWRITE_TAC[WORD_XOR_MASK] THEN
    POP_ASSUM_LIST(K ALL_TAC) THEN COND_CASES_TAC THEN
    ASM_REWRITE_TAC[BITVAL_CLAUSES; WORD_NEG_SUB; WORD_NEG_0;
     WORD_SUB_0; WORD_RULE
     `word_sub (word_not x) (word_neg(word 1)) = word_neg x`] THEN
    ASM_REWRITE_TAC[WORD_SUB] THEN ASM_ARITH_TAC;
    DISCH_TAC] THEN

  (*** Constant-time selection from the table ***)

  BIGNUM_LDIGITIZE_TAC "tab_"
   `read(memory :> bytes(word_add stackpointer (word 520),8 * 96)) s27` THEN
  X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (28--143) THEN
  MAP_EVERY REABBREV_TAC
   [`tab0 = read RAX s143`;
    `tab1 = read RBX s143`;
    `tab2 = read RCX s143`;
    `tab3 = read RDX s143`;
    `tab4 = read R8 s143`;
    `tab5 = read R9 s143`;
    `tab6 = read R10 s143`;
    `tab7 = read R11 s143`;
    `tab8 = read R12 s143`;
    `tab9 = read R13 s143`;
    `tab10 = read R14 s143`;
    `tab11 = read R15 s143`] THEN

  SUBGOAL_THEN
   `!P. P IN group_carrier p256_group /\ y < p_256 /\ represents_p256 P (x,y',z)
        ==> represents_p256 (group_pow p256_group P ix)
               (bignum_of_wordlist[tab0; tab1; tab2; tab3],
                bignum_of_wordlist[tab4; tab5; tab6; tab7],
                bignum_of_wordlist[tab8; tab9; tab10; tab11])`
  ASSUME_TAC THENL
   [X_GEN_TAC `P:(int#int)option` THEN STRIP_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `P:(int#int)option`) THEN
    CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN
    ASM_REWRITE_TAC[] THEN DISCH_TAC THEN
    MAP_EVERY EXPAND_TAC
     (map (fun n -> "tab"^string_of_int n) (0--11)) THEN
    SUBGOAL_THEN `ix < 9` MP_TAC THENL
     [MAP_EVERY EXPAND_TAC ["ix"; "bf"] THEN ARITH_TAC;
      SPEC_TAC(`ix:num`,`ix:num`)] THEN
    CONV_TAC EXPAND_CASES_CONV THEN
    CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV) THEN
    ASM_REWRITE_TAC[CONJUNCT1 group_pow] THEN
    REWRITE_TAC[group_pow; P256_GROUP; represents_p256; tripled;
                weierstrass_of_jacobian; montgomery_decode; p_256;
                bignum_of_wordlist; INTEGER_MOD_RING_CLAUSES] THEN
    CONV_TAC(DEPTH_CONV(WORD_NUM_RED_CONV ORELSEC INVERSE_MOD_CONV));
    ALL_TAC] THEN

  (*** Optional negation of the table entry ***)

  X86_ACCSTEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (163--166) (144--175) THEN
  MAP_EVERY ABBREV_TAC
   [`Xt = read (memory :> bytes(word_add stackpointer (word 424),8 * 4)) s175`;
    `Yt = read (memory :> bytes(word_add stackpointer (word 456),8 * 4)) s175`;
    `Zt = read (memory :> bytes(word_add stackpointer (word 488),8 * 4)) s175`
   ] THEN
  SUBGOAL_THEN
   `!P. P IN group_carrier p256_group /\ y < p_256 /\ represents_p256 P (x,y',z)
        ==> represents_p256 (group_zpow p256_group P (&bf - &8)) (Xt,Yt,Zt)`
  ASSUME_TAC THENL
   [X_GEN_TAC `P:(int#int)option` THEN STRIP_TAC THEN
    FIRST_X_ASSUM(K ALL_TAC o SPEC `P:(int#int)option`) THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `P:(int#int)option`) THEN
    ASM_REWRITE_TAC[] THEN DISCH_TAC THEN
    MAP_EVERY EXPAND_TAC ["Xt"; "Yt"; "Zt"] THEN
    CONV_TAC(ONCE_DEPTH_CONV BIGNUM_LEXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
    SUBGOAL_THEN `&bf - &8:int = if bf < 8 then --(&ix) else &ix`
    SUBST1_TAC THENL
     [EXPAND_TAC "ix" THEN
      SUBGOAL_THEN `bf < 16` MP_TAC THENL
       [EXPAND_TAC "bf" THEN ARITH_TAC; POP_ASSUM_LIST(K ALL_TAC)] THEN
      COND_CASES_TAC THEN ASM_SIMP_TAC[GSYM INT_OF_NUM_SUB; GSYM NOT_LT] THEN
      ASM_SIMP_TAC[GSYM INT_OF_NUM_SUB; LT_IMP_LE] THEN INT_ARITH_TAC;
      ALL_TAC] THEN
    SIMP_TAC[WORD_SUB_0; VAL_EQ_0; COND_SWAP; WORD_BITVAL_EQ_0] THEN
    REWRITE_TAC[WORD_OR_EQ_0; GSYM CONJ_ASSOC] THEN
    MP_TAC(SPEC `[tab4;tab5;tab6;tab7]:int64 list` BIGNUM_OF_WORDLIST_EQ_0) THEN
    ASM_REWRITE_TAC[ALL] THEN DISCH_THEN(SUBST1_TAC o SYM) THEN
    REWRITE_TAC[WORD_BITVAL_EQ_0; MESON[]
     `(if p then a else b) = x <=> if p then a = x else b = x`] THEN
    REWRITE_TAC[WORD_NEG_EQ_0; WORD_BITVAL_EQ_0; MESON[]
     `(if p then T else ~q) <=> ~(q /\ ~p)`] THEN
    ASM_CASES_TAC `bf < 8` THEN ASM_REWRITE_TAC[GROUP_NPOW] THEN
    CONV_TAC(DEPTH_CONV WORD_NUM_RED_CONV) THEN REWRITE_TAC[COND_SWAP] THEN
    FIRST_ASSUM(MP_TAC o MATCH_MP REPRESENTS_P256_NEGATION_ALT) THEN
    ASM_SIMP_TAC[GROUP_POW; GROUP_ZPOW_NEG; GROUP_NPOW] THEN
    MATCH_MP_TAC EQ_IMP THEN AP_TERM_TAC THEN REWRITE_TAC[PAIR_EQ] THEN
    COND_CASES_TAC THEN ASM_REWRITE_TAC[] THEN CONV_TAC SYM_CONV THEN
    MATCH_MP_TAC CONG_IMP_EQ THEN EXISTS_TAC `2 EXP 256` THEN
    CONJ_TAC THENL [BOUNDER_TAC[]; ALL_TAC] THEN
    CONJ_TAC THENL [REWRITE_TAC[p_256] THEN ARITH_TAC; ALL_TAC] THEN
    RULE_ASSUM_TAC(REWRITE_RULE[represents_p256]) THEN
    ASM_SIMP_TAC[num_congruent; GSYM INT_OF_NUM_SUB; LT_IMP_LE] THEN
    REWRITE_TAC[REAL_INT_CONGRUENCE] THEN
    REWRITE_TAC[GSYM REAL_OF_INT_CLAUSES] THEN
    REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES; REAL_POW_EQ_0] THEN
    REWRITE_TAC[REAL_OF_NUM_EQ; ARITH_EQ] THEN
    REWRITE_TAC[bignum_of_wordlist; p_256; GSYM REAL_OF_NUM_CLAUSES] THEN
    ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DESUM_RULE) THEN
    DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_INTEGER_TAC;
    ACCUMULATOR_POP_ASSUM_LIST(K ALL_TAC)] THEN

  (*** Final addition of the table entry ***)

  X86_STEPS_TAC P256_MONTJSCALARMUL_ALT_EXEC (176--179) THEN LOCAL_JADD_TAC 180 THEN
  MAP_EVERY ABBREV_TAC
   [`X' = read (memory :> bytes(word_add stackpointer (word 328),8 * 4)) s180`;
    `Y' = read (memory :> bytes(word_add stackpointer (word 360),8 * 4)) s180`;
    `Z' = read (memory :> bytes(word_add stackpointer (word 392),8 * 4)) s180`
   ] THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN

  (*** The final mathematics ***)



  X_GEN_TAC `P:(int#int)option` THEN STRIP_TAC THEN
  CONV_TAC(RAND_CONV EXPAND_CASES_CONV) THEN
  REWRITE_TAC[bignum_triple_from_memory] THEN
  CONV_TAC NUM_REDUCE_CONV THEN
  CONV_TAC(ONCE_DEPTH_CONV NORMALIZE_RELATIVE_ADDRESS_CONV) THEN
  ASM_REWRITE_TAC[BIGNUM_FROM_MEMORY_BYTES] THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `P:(int#int)option`) THEN
  ASM_REWRITE_TAC[] THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC (fun th -> REWRITE_TAC[th])) THEN
  ABBREV_TAC
   `Q = group_zpow p256_group P
      (&(n DIV 2 EXP (4 * (i + 1))) -
       &(recoder DIV 2 EXP (4 * (i + 1))))` THEN
  SUBGOAL_THEN `Q IN group_carrier p256_group` ASSUME_TAC THENL
   [EXPAND_TAC "Q" THEN MATCH_MP_TAC GROUP_ZPOW THEN ASM_REWRITE_TAC[];
    ALL_TAC] THEN
  UNDISCH_THEN
   `!P. represents_p256 P (Xa,Ya,Za)
        ==> represents_p256 (group_mul p256_group P P) (X2a,Y2a,Z2a)`
   (MP_TAC o SPEC `Q:(int#int)option`) THEN
  ASM_SIMP_TAC[GROUP_RULE `group_mul G x x = group_pow G x 2`] THEN
  DISCH_TAC THEN UNDISCH_THEN
   `!P. represents_p256 P (X2a,Y2a,Z2a)
        ==> represents_p256 (group_mul p256_group P P) (X4a,Y4a,Z4a)`
   (MP_TAC o SPEC `group_pow p256_group Q 2`) THEN
  ASM_SIMP_TAC[GSYM GROUP_POW_ADD] THEN CONV_TAC NUM_REDUCE_CONV THEN
  DISCH_TAC THEN UNDISCH_THEN
   `!P. represents_p256 P (X4a,Y4a,Z4a)
        ==> represents_p256 (group_mul p256_group P P) (X8a,Y8a,Z8a)`
   (MP_TAC o SPEC `group_pow p256_group Q 4`) THEN
  ASM_SIMP_TAC[GSYM GROUP_POW_ADD] THEN CONV_TAC NUM_REDUCE_CONV THEN
  DISCH_TAC THEN UNDISCH_THEN
   `!P. represents_p256 P (X8a,Y8a,Z8a)
        ==> represents_p256 (group_mul p256_group P P) (Xha,Yha,Zha)`
   (MP_TAC o SPEC `group_pow p256_group Q 8`) THEN
  ASM_SIMP_TAC[GSYM GROUP_POW_ADD] THEN CONV_TAC NUM_REDUCE_CONV THEN
  DISCH_TAC THEN FIRST_X_ASSUM(MP_TAC o SPECL
   [`group_pow p256_group Q 16`;
    `group_zpow p256_group P (&bf - &8)`]) THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `P:(int#int)option`) THEN
  ASM_REWRITE_TAC[] THEN DISCH_TAC THEN ASM_REWRITE_TAC[] THEN
  ASM_SIMP_TAC[GSYM GROUP_NPOW] THEN EXPAND_TAC "Q" THEN
  ASM_SIMP_TAC[GSYM GROUP_ZPOW_MUL; GSYM GROUP_ZPOW_ADD] THEN
  ANTS_TAC THENL
   [SUBST1_TAC(SYM(el 1 (CONJUNCTS P256_GROUP))) THEN
    ASM_SIMP_TAC[GROUP_ZPOW_EQ; GROUP_ZPOW_EQ_ID;
                 P256_GROUP_ELEMENT_ORDER] THEN
    COND_CASES_TAC THEN ASM_REWRITE_TAC[INT_DIVIDES_1] THEN
    DISCH_THEN(MP_TAC o MATCH_MP (REWRITE_RULE[IMP_CONJ_ALT]
        INT_CONG_IMP_EQ)) THEN
    ANTS_TAC THENL
     [MATCH_MP_TAC(INT_ARITH
       `abs(&16 * x) + abs(&16 * y) + abs(bf) + &8:int < n
        ==> abs((x - y) * &16 - (bf - &8)) < n`) THEN
      REWRITE_TAC[INT_ABS_NUM; INT_OF_NUM_CLAUSES] THEN
      REWRITE_TAC[ARITH_RULE `4 * (i + 1) = 4 * i + 4`; EXP_ADD] THEN
      REWRITE_TAC[GSYM DIV_DIV] THEN MATCH_MP_TAC(ARITH_RULE
       `a + b + c + d < n
        ==> 16 * a DIV 2 EXP 4 + 16 * b DIV 2 EXP 4 + c + d < n`) THEN
      TRANS_TAC LET_TRANS `n + recoder + bf + 8` THEN
      SIMP_TAC[LE_ADD2; LE_REFL; DIV_LE] THEN
      UNDISCH_TAC `n < 9 * 2 EXP 252` THEN
      MAP_EVERY EXPAND_TAC ["recoder"; "bf"] THEN
      REWRITE_TAC[n_256] THEN ARITH_TAC;
      ALL_TAC] THEN
    ASM_CASES_TAC `&bf - &8:int = &0` THEN ASM_REWRITE_TAC[INT_DIVIDES_0] THEN
    UNDISCH_TAC `~(&bf - &8:int = &0)` THEN
    MATCH_MP_TAC(TAUT `(p ==> ~q) ==> p ==> q ==> r`) THEN
    MATCH_MP_TAC(INT_ARITH
     `abs(y:int) < &16 /\ (~(x = &0) ==> &1 <= abs(x))
      ==> ~(y = &0) ==> ~(x * &16 = y)`) THEN
    CONJ_TAC THENL [EXPAND_TAC "bf"; CONV_TAC INT_ARITH] THEN
    REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES; GSYM INT_OF_NUM_REM] THEN
    CONV_TAC INT_ARITH;
    MATCH_MP_TAC EQ_IMP] THEN
  AP_THM_TAC THEN AP_TERM_TAC THEN AP_TERM_TAC THEN
  SUBGOAL_THEN
   `!n. n DIV 2 EXP (4 * i) =
        16 * (n DIV 2 EXP (4 * (i + 1))) + (n DIV 2 EXP (4 * i)) MOD 16`
  MP_TAC THENL
   [REWRITE_TAC[ARITH_RULE `4 * (i + 1) = 4 * i + 4`; EXP_ADD] THEN
    REWRITE_TAC[GSYM DIV_DIV] THEN ARITH_TAC;
    DISCH_THEN(fun th -> ONCE_REWRITE_TAC[th]) THEN
    ASM_REWRITE_TAC[]] THEN
  SUBGOAL_THEN `(recoder DIV 2 EXP (4 * i)) MOD 16 = 8` SUBST1_TAC THENL
   [UNDISCH_TAC `i < 63` THEN SPEC_TAC(`i:num`,`i:num`) THEN
    EXPAND_TAC "recoder" THEN POP_ASSUM_LIST(K ALL_TAC) THEN
    CONV_TAC EXPAND_CASES_CONV THEN CONV_TAC NUM_REDUCE_CONV;
    ALL_TAC] THEN
  REWRITE_TAC[GSYM INT_OF_NUM_CLAUSES] THEN CONV_TAC INT_ARITH);;

let P256_MONTJSCALARMUL_ALT_NOIBT_SUBROUTINE_CORRECT = time prove
 (`!res scalar point n xyz pc stackpointer returnaddress.
        ALL (nonoverlapping (word_sub stackpointer (word 1368),1368))
            [(word pc,LENGTH p256_montjscalarmul_alt_tmc); (scalar,32); (point,96)] /\
        ALL (nonoverlapping (res,96))
            [(word pc,LENGTH p256_montjscalarmul_alt_tmc); (word_sub stackpointer (word 1368),1376)]
        ==> ensures x86
             (\s. bytes_loaded s (word pc) p256_montjscalarmul_alt_tmc /\
                  read RIP s = word pc /\
                  read RSP s = stackpointer /\
                  read (memory :> bytes64 stackpointer) s = returnaddress /\
                  C_ARGUMENTS [res;scalar;point] s /\
                  bignum_from_memory (scalar,4) s = n /\
                  bignum_triple_from_memory (point,4) s = xyz)
             (\s. read RIP s = returnaddress /\
                  read RSP s = word_add stackpointer (word 8) /\
                  !P. P IN group_carrier p256_group /\
                      represents_p256 P xyz
                      ==> represents_p256
                            (group_pow p256_group P n)
                            (bignum_triple_from_memory(res,4) s))
          (MAYCHANGE [RSP] ,, MAYCHANGE_REGS_AND_FLAGS_PERMITTED_BY_ABI ,,
           MAYCHANGE[memory :> bytes(res,96);
                     memory :> bytes(word_sub stackpointer (word 1368),1368)])`,
   X86_ADD_RETURN_STACK_TAC P256_MONTJSCALARMUL_ALT_EXEC
     P256_MONTJSCALARMUL_ALT_CORRECT `[RBX; RBP; R12; R13; R14; R15]` 1368);;

let P256_MONTJSCALARMUL_ALT_SUBROUTINE_CORRECT = time prove
 (`!res scalar point n xyz pc stackpointer returnaddress.
        ALL (nonoverlapping (word_sub stackpointer (word 1368),1368))
            [(word pc,LENGTH p256_montjscalarmul_alt_mc); (scalar,32); (point,96)] /\
        ALL (nonoverlapping (res,96))
            [(word pc,LENGTH p256_montjscalarmul_alt_mc); (word_sub stackpointer (word 1368),1376)]
        ==> ensures x86
             (\s. bytes_loaded s (word pc) p256_montjscalarmul_alt_mc /\
                  read RIP s = word pc /\
                  read RSP s = stackpointer /\
                  read (memory :> bytes64 stackpointer) s = returnaddress /\
                  C_ARGUMENTS [res;scalar;point] s /\
                  bignum_from_memory (scalar,4) s = n /\
                  bignum_triple_from_memory (point,4) s = xyz)
             (\s. read RIP s = returnaddress /\
                  read RSP s = word_add stackpointer (word 8) /\
                  !P. P IN group_carrier p256_group /\
                      represents_p256 P xyz
                      ==> represents_p256
                            (group_pow p256_group P n)
                            (bignum_triple_from_memory(res,4) s))
          (MAYCHANGE [RSP] ,, MAYCHANGE_REGS_AND_FLAGS_PERMITTED_BY_ABI ,,
           MAYCHANGE[memory :> bytes(res,96);
                     memory :> bytes(word_sub stackpointer (word 1368),1368)])`,
  MATCH_ACCEPT_TAC(ADD_IBT_RULE P256_MONTJSCALARMUL_ALT_NOIBT_SUBROUTINE_CORRECT));;

(* ------------------------------------------------------------------------- *)
(* Correctness of Windows ABI version.                                       *)
(* ------------------------------------------------------------------------- *)

let p256_montjscalarmul_alt_windows_mc = define_from_elf "p256_montjscalarmul_alt_windows_mc"
      "x86/p256/p256_montjscalarmul_alt.obj";;

let p256_montjscalarmul_alt_windows_tmc = define_trimmed "p256_montjscalarmul_alt_windows_tmc" p256_montjscalarmul_alt_windows_mc;;

let P256_MONTJSCALARMUL_ALT_NOIBT_WINDOWS_SUBROUTINE_CORRECT = time prove
 (`!res scalar point n xyz pc stackpointer returnaddress.
        ALL (nonoverlapping (word_sub stackpointer (word 1392),1392))
            [(word pc,LENGTH p256_montjscalarmul_alt_windows_tmc); (scalar,32); (point,96)] /\
        ALL (nonoverlapping (res,96))
            [(word pc,LENGTH p256_montjscalarmul_alt_windows_tmc); (word_sub stackpointer (word 1392),1400)]
        ==> ensures x86
             (\s. bytes_loaded s (word pc) p256_montjscalarmul_alt_windows_tmc /\
                  read RIP s = word pc /\
                  read RSP s = stackpointer /\
                  read (memory :> bytes64 stackpointer) s = returnaddress /\
                  WINDOWS_C_ARGUMENTS [res;scalar;point] s /\
                  bignum_from_memory (scalar,4) s = n /\
                  bignum_triple_from_memory (point,4) s = xyz)
             (\s. read RIP s = returnaddress /\
                  read RSP s = word_add stackpointer (word 8) /\
                  !P. P IN group_carrier p256_group /\
                      represents_p256 P xyz
                      ==> represents_p256
                            (group_pow p256_group P n)
                            (bignum_triple_from_memory(res,4) s))
          (MAYCHANGE [RSP] ,, WINDOWS_MAYCHANGE_REGS_AND_FLAGS_PERMITTED_BY_ABI ,,
           MAYCHANGE[memory :> bytes(res,96);
                     memory :> bytes(word_sub stackpointer (word 1392),1392)])`,
  let WINDOWS_P256_MONTJSCALARMUL_ALT_EXEC =
    X86_MK_EXEC_RULE p256_montjscalarmul_alt_windows_tmc
  and baseth =
    X86_SIMD_SHARPEN_RULE P256_MONTJSCALARMUL_ALT_NOIBT_SUBROUTINE_CORRECT
    (X86_ADD_RETURN_STACK_TAC P256_MONTJSCALARMUL_ALT_EXEC
     P256_MONTJSCALARMUL_ALT_CORRECT `[RBX; RBP; R12; R13; R14; R15]` 1368) in
  let subth =
    CONV_RULE(ONCE_DEPTH_CONV NUM_MULT_CONV)
     (REWRITE_RULE[bignum_triple_from_memory] baseth) in
  REWRITE_TAC[fst WINDOWS_P256_MONTJSCALARMUL_ALT_EXEC] THEN
  REPLICATE_TAC 6 GEN_TAC THEN WORD_FORALL_OFFSET_TAC 1392 THEN
  REWRITE_TAC[ALL; WINDOWS_C_ARGUMENTS; SOME_FLAGS;
              WINDOWS_MAYCHANGE_REGS_AND_FLAGS_PERMITTED_BY_ABI] THEN
  REWRITE_TAC[NONOVERLAPPING_CLAUSES] THEN REPEAT STRIP_TAC THEN
  ENSURES_PRESERVED_TAC "rsi_init" `RSI` THEN
  ENSURES_PRESERVED_TAC "rdi_init" `RDI` THEN
  REWRITE_TAC[bignum_triple_from_memory; WORD_RULE
    `word(8 * 4) = word 32 /\ word(16 * 4) = word 64`] THEN
  REWRITE_TAC(!simulation_precanon_thms) THEN ENSURES_INIT_TAC "s0" THEN
  UNDISCH_THEN `read RSP s0 = word_add stackpointer (word 1392)`
   (fun th -> SUBST_ALL_TAC th THEN ASSUME_TAC th) THEN
  RULE_ASSUM_TAC
   (CONV_RULE(ONCE_DEPTH_CONV NORMALIZE_RELATIVE_ADDRESS_CONV)) THEN
  X86_STEPS_TAC WINDOWS_P256_MONTJSCALARMUL_ALT_EXEC (1--6) THEN
  X86_SUBROUTINE_SIM_TAC
   (p256_montjscalarmul_alt_windows_tmc,
    WINDOWS_P256_MONTJSCALARMUL_ALT_EXEC,
    0x13,p256_montjscalarmul_alt_tmc,subth)
   [`read RDI s`; `read RSI s`; `read RDX s`;
    `read(memory :> bytes(read RSI s,8 * 4)) s`;
    `read(memory :> bytes(read RDX s,8 * 4)) s,
     read(memory :> bytes(word_add (read RDX s) (word 32),8 * 4)) s,
     read(memory :> bytes(word_add (read RDX s) (word 64),8 * 4)) s`;
    `pc + 0x13`; `read RSP s`;
    `read (memory :> bytes64 (read RSP s)) s`] 7 THEN
  X86_STEPS_TAC WINDOWS_P256_MONTJSCALARMUL_ALT_EXEC (8--10) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[]);;

let P256_MONTJSCALARMUL_ALT_WINDOWS_SUBROUTINE_CORRECT = time prove
 (`!res scalar point n xyz pc stackpointer returnaddress.
        ALL (nonoverlapping (word_sub stackpointer (word 1392),1392))
            [(word pc,LENGTH p256_montjscalarmul_alt_windows_mc); (scalar,32); (point,96)] /\
        ALL (nonoverlapping (res,96))
            [(word pc,LENGTH p256_montjscalarmul_alt_windows_mc); (word_sub stackpointer (word 1392),1400)]
        ==> ensures x86
             (\s. bytes_loaded s (word pc) p256_montjscalarmul_alt_windows_mc /\
                  read RIP s = word pc /\
                  read RSP s = stackpointer /\
                  read (memory :> bytes64 stackpointer) s = returnaddress /\
                  WINDOWS_C_ARGUMENTS [res;scalar;point] s /\
                  bignum_from_memory (scalar,4) s = n /\
                  bignum_triple_from_memory (point,4) s = xyz)
             (\s. read RIP s = returnaddress /\
                  read RSP s = word_add stackpointer (word 8) /\
                  !P. P IN group_carrier p256_group /\
                      represents_p256 P xyz
                      ==> represents_p256
                            (group_pow p256_group P n)
                            (bignum_triple_from_memory(res,4) s))
          (MAYCHANGE [RSP] ,, WINDOWS_MAYCHANGE_REGS_AND_FLAGS_PERMITTED_BY_ABI ,,
           MAYCHANGE[memory :> bytes(res,96);
                     memory :> bytes(word_sub stackpointer (word 1392),1392)])`,
  MATCH_ACCEPT_TAC(ADD_IBT_RULE P256_MONTJSCALARMUL_ALT_NOIBT_WINDOWS_SUBROUTINE_CORRECT));;

