(*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT-0
 *)

(* ========================================================================= *)
(* 8x8->16 multiply optimized for uarchs with higher multiplier throughput.  *)
(* ========================================================================= *)

needs "arm/proofs/base.ml";;

(**** print_literal_from_elf "arm/fastmul/bignum_mul_8_16_alt.o";;
 ****)

let bignum_mul_8_16_alt_mc =
  define_assert_from_elf "bignum_mul_8_16_alt_mc" "arm/fastmul/bignum_mul_8_16_alt.o"
[
  0xa9bf53f3;       (* arm_STP X19 X20 SP (Preimmediate_Offset (iword (-- &16))) *)
  0xa9bf5bf5;       (* arm_STP X21 X22 SP (Preimmediate_Offset (iword (-- &16))) *)
  0xa9bf63f7;       (* arm_STP X23 X24 SP (Preimmediate_Offset (iword (-- &16))) *)
  0xa9401023;       (* arm_LDP X3 X4 X1 (Immediate_Offset (iword (&0))) *)
  0xa9401845;       (* arm_LDP X5 X6 X2 (Immediate_Offset (iword (&0))) *)
  0x9b057c6e;       (* arm_MUL X14 X3 X5 *)
  0x9bc57c6f;       (* arm_UMULH X15 X3 X5 *)
  0x9b067c6d;       (* arm_MUL X13 X3 X6 *)
  0x9bc67c70;       (* arm_UMULH X16 X3 X6 *)
  0xab0d01ef;       (* arm_ADDS X15 X15 X13 *)
  0xa9412047;       (* arm_LDP X7 X8 X2 (Immediate_Offset (iword (&16))) *)
  0x9b077c6d;       (* arm_MUL X13 X3 X7 *)
  0x9bc77c71;       (* arm_UMULH X17 X3 X7 *)
  0xba0d0210;       (* arm_ADCS X16 X16 X13 *)
  0x9b087c6d;       (* arm_MUL X13 X3 X8 *)
  0x9bc87c73;       (* arm_UMULH X19 X3 X8 *)
  0xba0d0231;       (* arm_ADCS X17 X17 X13 *)
  0xa9422849;       (* arm_LDP X9 X10 X2 (Immediate_Offset (iword (&32))) *)
  0x9b097c6d;       (* arm_MUL X13 X3 X9 *)
  0x9bc97c74;       (* arm_UMULH X20 X3 X9 *)
  0xba0d0273;       (* arm_ADCS X19 X19 X13 *)
  0x9b0a7c6d;       (* arm_MUL X13 X3 X10 *)
  0x9bca7c75;       (* arm_UMULH X21 X3 X10 *)
  0xba0d0294;       (* arm_ADCS X20 X20 X13 *)
  0xa943304b;       (* arm_LDP X11 X12 X2 (Immediate_Offset (iword (&48))) *)
  0x9b0b7c6d;       (* arm_MUL X13 X3 X11 *)
  0x9bcb7c76;       (* arm_UMULH X22 X3 X11 *)
  0xba0d02b5;       (* arm_ADCS X21 X21 X13 *)
  0x9b0c7c6d;       (* arm_MUL X13 X3 X12 *)
  0x9bcc7c77;       (* arm_UMULH X23 X3 X12 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9a1f02f7;       (* arm_ADC X23 X23 XZR *)
  0x9b057c8d;       (* arm_MUL X13 X4 X5 *)
  0xab0d01ef;       (* arm_ADDS X15 X15 X13 *)
  0x9b067c8d;       (* arm_MUL X13 X4 X6 *)
  0xba0d0210;       (* arm_ADCS X16 X16 X13 *)
  0x9b077c8d;       (* arm_MUL X13 X4 X7 *)
  0xba0d0231;       (* arm_ADCS X17 X17 X13 *)
  0x9b087c8d;       (* arm_MUL X13 X4 X8 *)
  0xba0d0273;       (* arm_ADCS X19 X19 X13 *)
  0x9b097c8d;       (* arm_MUL X13 X4 X9 *)
  0xba0d0294;       (* arm_ADCS X20 X20 X13 *)
  0x9b0a7c8d;       (* arm_MUL X13 X4 X10 *)
  0xba0d02b5;       (* arm_ADCS X21 X21 X13 *)
  0x9b0b7c8d;       (* arm_MUL X13 X4 X11 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9b0c7c8d;       (* arm_MUL X13 X4 X12 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9a9f37f8;       (* arm_CSET X24 Condition_CS *)
  0x9bc57c8d;       (* arm_UMULH X13 X4 X5 *)
  0xab0d0210;       (* arm_ADDS X16 X16 X13 *)
  0x9bc67c8d;       (* arm_UMULH X13 X4 X6 *)
  0xba0d0231;       (* arm_ADCS X17 X17 X13 *)
  0x9bc77c8d;       (* arm_UMULH X13 X4 X7 *)
  0xba0d0273;       (* arm_ADCS X19 X19 X13 *)
  0x9bc87c8d;       (* arm_UMULH X13 X4 X8 *)
  0xba0d0294;       (* arm_ADCS X20 X20 X13 *)
  0x9bc97c8d;       (* arm_UMULH X13 X4 X9 *)
  0xba0d02b5;       (* arm_ADCS X21 X21 X13 *)
  0x9bca7c8d;       (* arm_UMULH X13 X4 X10 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9bcb7c8d;       (* arm_UMULH X13 X4 X11 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9bcc7c8d;       (* arm_UMULH X13 X4 X12 *)
  0x9a0d0318;       (* arm_ADC X24 X24 X13 *)
  0xa9003c0e;       (* arm_STP X14 X15 X0 (Immediate_Offset (iword (&0))) *)
  0xa9411023;       (* arm_LDP X3 X4 X1 (Immediate_Offset (iword (&16))) *)
  0x9b057c6d;       (* arm_MUL X13 X3 X5 *)
  0xab0d0210;       (* arm_ADDS X16 X16 X13 *)
  0x9b067c6d;       (* arm_MUL X13 X3 X6 *)
  0xba0d0231;       (* arm_ADCS X17 X17 X13 *)
  0x9b077c6d;       (* arm_MUL X13 X3 X7 *)
  0xba0d0273;       (* arm_ADCS X19 X19 X13 *)
  0x9b087c6d;       (* arm_MUL X13 X3 X8 *)
  0xba0d0294;       (* arm_ADCS X20 X20 X13 *)
  0x9b097c6d;       (* arm_MUL X13 X3 X9 *)
  0xba0d02b5;       (* arm_ADCS X21 X21 X13 *)
  0x9b0a7c6d;       (* arm_MUL X13 X3 X10 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9b0b7c6d;       (* arm_MUL X13 X3 X11 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9b0c7c6d;       (* arm_MUL X13 X3 X12 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9a9f37ee;       (* arm_CSET X14 Condition_CS *)
  0x9bc57c6d;       (* arm_UMULH X13 X3 X5 *)
  0xab0d0231;       (* arm_ADDS X17 X17 X13 *)
  0x9bc67c6d;       (* arm_UMULH X13 X3 X6 *)
  0xba0d0273;       (* arm_ADCS X19 X19 X13 *)
  0x9bc77c6d;       (* arm_UMULH X13 X3 X7 *)
  0xba0d0294;       (* arm_ADCS X20 X20 X13 *)
  0x9bc87c6d;       (* arm_UMULH X13 X3 X8 *)
  0xba0d02b5;       (* arm_ADCS X21 X21 X13 *)
  0x9bc97c6d;       (* arm_UMULH X13 X3 X9 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9bca7c6d;       (* arm_UMULH X13 X3 X10 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9bcb7c6d;       (* arm_UMULH X13 X3 X11 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9bcc7c6d;       (* arm_UMULH X13 X3 X12 *)
  0x9a0d01ce;       (* arm_ADC X14 X14 X13 *)
  0x9b057c8d;       (* arm_MUL X13 X4 X5 *)
  0xab0d0231;       (* arm_ADDS X17 X17 X13 *)
  0x9b067c8d;       (* arm_MUL X13 X4 X6 *)
  0xba0d0273;       (* arm_ADCS X19 X19 X13 *)
  0x9b077c8d;       (* arm_MUL X13 X4 X7 *)
  0xba0d0294;       (* arm_ADCS X20 X20 X13 *)
  0x9b087c8d;       (* arm_MUL X13 X4 X8 *)
  0xba0d02b5;       (* arm_ADCS X21 X21 X13 *)
  0x9b097c8d;       (* arm_MUL X13 X4 X9 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9b0a7c8d;       (* arm_MUL X13 X4 X10 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9b0b7c8d;       (* arm_MUL X13 X4 X11 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9b0c7c8d;       (* arm_MUL X13 X4 X12 *)
  0xba0d01ce;       (* arm_ADCS X14 X14 X13 *)
  0x9a9f37ef;       (* arm_CSET X15 Condition_CS *)
  0x9bc57c8d;       (* arm_UMULH X13 X4 X5 *)
  0xab0d0273;       (* arm_ADDS X19 X19 X13 *)
  0x9bc67c8d;       (* arm_UMULH X13 X4 X6 *)
  0xba0d0294;       (* arm_ADCS X20 X20 X13 *)
  0x9bc77c8d;       (* arm_UMULH X13 X4 X7 *)
  0xba0d02b5;       (* arm_ADCS X21 X21 X13 *)
  0x9bc87c8d;       (* arm_UMULH X13 X4 X8 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9bc97c8d;       (* arm_UMULH X13 X4 X9 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9bca7c8d;       (* arm_UMULH X13 X4 X10 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9bcb7c8d;       (* arm_UMULH X13 X4 X11 *)
  0xba0d01ce;       (* arm_ADCS X14 X14 X13 *)
  0x9bcc7c8d;       (* arm_UMULH X13 X4 X12 *)
  0x9a0d01ef;       (* arm_ADC X15 X15 X13 *)
  0xa9014410;       (* arm_STP X16 X17 X0 (Immediate_Offset (iword (&16))) *)
  0xa9421023;       (* arm_LDP X3 X4 X1 (Immediate_Offset (iword (&32))) *)
  0x9b057c6d;       (* arm_MUL X13 X3 X5 *)
  0xab0d0273;       (* arm_ADDS X19 X19 X13 *)
  0x9b067c6d;       (* arm_MUL X13 X3 X6 *)
  0xba0d0294;       (* arm_ADCS X20 X20 X13 *)
  0x9b077c6d;       (* arm_MUL X13 X3 X7 *)
  0xba0d02b5;       (* arm_ADCS X21 X21 X13 *)
  0x9b087c6d;       (* arm_MUL X13 X3 X8 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9b097c6d;       (* arm_MUL X13 X3 X9 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9b0a7c6d;       (* arm_MUL X13 X3 X10 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9b0b7c6d;       (* arm_MUL X13 X3 X11 *)
  0xba0d01ce;       (* arm_ADCS X14 X14 X13 *)
  0x9b0c7c6d;       (* arm_MUL X13 X3 X12 *)
  0xba0d01ef;       (* arm_ADCS X15 X15 X13 *)
  0x9a9f37f0;       (* arm_CSET X16 Condition_CS *)
  0x9bc57c6d;       (* arm_UMULH X13 X3 X5 *)
  0xab0d0294;       (* arm_ADDS X20 X20 X13 *)
  0x9bc67c6d;       (* arm_UMULH X13 X3 X6 *)
  0xba0d02b5;       (* arm_ADCS X21 X21 X13 *)
  0x9bc77c6d;       (* arm_UMULH X13 X3 X7 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9bc87c6d;       (* arm_UMULH X13 X3 X8 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9bc97c6d;       (* arm_UMULH X13 X3 X9 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9bca7c6d;       (* arm_UMULH X13 X3 X10 *)
  0xba0d01ce;       (* arm_ADCS X14 X14 X13 *)
  0x9bcb7c6d;       (* arm_UMULH X13 X3 X11 *)
  0xba0d01ef;       (* arm_ADCS X15 X15 X13 *)
  0x9bcc7c6d;       (* arm_UMULH X13 X3 X12 *)
  0x9a0d0210;       (* arm_ADC X16 X16 X13 *)
  0x9b057c8d;       (* arm_MUL X13 X4 X5 *)
  0xab0d0294;       (* arm_ADDS X20 X20 X13 *)
  0x9b067c8d;       (* arm_MUL X13 X4 X6 *)
  0xba0d02b5;       (* arm_ADCS X21 X21 X13 *)
  0x9b077c8d;       (* arm_MUL X13 X4 X7 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9b087c8d;       (* arm_MUL X13 X4 X8 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9b097c8d;       (* arm_MUL X13 X4 X9 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9b0a7c8d;       (* arm_MUL X13 X4 X10 *)
  0xba0d01ce;       (* arm_ADCS X14 X14 X13 *)
  0x9b0b7c8d;       (* arm_MUL X13 X4 X11 *)
  0xba0d01ef;       (* arm_ADCS X15 X15 X13 *)
  0x9b0c7c8d;       (* arm_MUL X13 X4 X12 *)
  0xba0d0210;       (* arm_ADCS X16 X16 X13 *)
  0x9a9f37f1;       (* arm_CSET X17 Condition_CS *)
  0x9bc57c8d;       (* arm_UMULH X13 X4 X5 *)
  0xab0d02b5;       (* arm_ADDS X21 X21 X13 *)
  0x9bc67c8d;       (* arm_UMULH X13 X4 X6 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9bc77c8d;       (* arm_UMULH X13 X4 X7 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9bc87c8d;       (* arm_UMULH X13 X4 X8 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9bc97c8d;       (* arm_UMULH X13 X4 X9 *)
  0xba0d01ce;       (* arm_ADCS X14 X14 X13 *)
  0x9bca7c8d;       (* arm_UMULH X13 X4 X10 *)
  0xba0d01ef;       (* arm_ADCS X15 X15 X13 *)
  0x9bcb7c8d;       (* arm_UMULH X13 X4 X11 *)
  0xba0d0210;       (* arm_ADCS X16 X16 X13 *)
  0x9bcc7c8d;       (* arm_UMULH X13 X4 X12 *)
  0x9a0d0231;       (* arm_ADC X17 X17 X13 *)
  0xa9025013;       (* arm_STP X19 X20 X0 (Immediate_Offset (iword (&32))) *)
  0xa9431023;       (* arm_LDP X3 X4 X1 (Immediate_Offset (iword (&48))) *)
  0x9b057c6d;       (* arm_MUL X13 X3 X5 *)
  0xab0d02b5;       (* arm_ADDS X21 X21 X13 *)
  0x9b067c6d;       (* arm_MUL X13 X3 X6 *)
  0xba0d02d6;       (* arm_ADCS X22 X22 X13 *)
  0x9b077c6d;       (* arm_MUL X13 X3 X7 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9b087c6d;       (* arm_MUL X13 X3 X8 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9b097c6d;       (* arm_MUL X13 X3 X9 *)
  0xba0d01ce;       (* arm_ADCS X14 X14 X13 *)
  0x9b0a7c6d;       (* arm_MUL X13 X3 X10 *)
  0xba0d01ef;       (* arm_ADCS X15 X15 X13 *)
  0x9b0b7c6d;       (* arm_MUL X13 X3 X11 *)
  0xba0d0210;       (* arm_ADCS X16 X16 X13 *)
  0x9b0c7c6d;       (* arm_MUL X13 X3 X12 *)
  0xba0d0231;       (* arm_ADCS X17 X17 X13 *)
  0x9a9f37f3;       (* arm_CSET X19 Condition_CS *)
  0x9bc57c6d;       (* arm_UMULH X13 X3 X5 *)
  0xab0d02d6;       (* arm_ADDS X22 X22 X13 *)
  0x9bc67c6d;       (* arm_UMULH X13 X3 X6 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9bc77c6d;       (* arm_UMULH X13 X3 X7 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9bc87c6d;       (* arm_UMULH X13 X3 X8 *)
  0xba0d01ce;       (* arm_ADCS X14 X14 X13 *)
  0x9bc97c6d;       (* arm_UMULH X13 X3 X9 *)
  0xba0d01ef;       (* arm_ADCS X15 X15 X13 *)
  0x9bca7c6d;       (* arm_UMULH X13 X3 X10 *)
  0xba0d0210;       (* arm_ADCS X16 X16 X13 *)
  0x9bcb7c6d;       (* arm_UMULH X13 X3 X11 *)
  0xba0d0231;       (* arm_ADCS X17 X17 X13 *)
  0x9bcc7c6d;       (* arm_UMULH X13 X3 X12 *)
  0x9a0d0273;       (* arm_ADC X19 X19 X13 *)
  0x9b057c8d;       (* arm_MUL X13 X4 X5 *)
  0xab0d02d6;       (* arm_ADDS X22 X22 X13 *)
  0x9b067c8d;       (* arm_MUL X13 X4 X6 *)
  0xba0d02f7;       (* arm_ADCS X23 X23 X13 *)
  0x9b077c8d;       (* arm_MUL X13 X4 X7 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9b087c8d;       (* arm_MUL X13 X4 X8 *)
  0xba0d01ce;       (* arm_ADCS X14 X14 X13 *)
  0x9b097c8d;       (* arm_MUL X13 X4 X9 *)
  0xba0d01ef;       (* arm_ADCS X15 X15 X13 *)
  0x9b0a7c8d;       (* arm_MUL X13 X4 X10 *)
  0xba0d0210;       (* arm_ADCS X16 X16 X13 *)
  0x9b0b7c8d;       (* arm_MUL X13 X4 X11 *)
  0xba0d0231;       (* arm_ADCS X17 X17 X13 *)
  0x9b0c7c8d;       (* arm_MUL X13 X4 X12 *)
  0xba0d0273;       (* arm_ADCS X19 X19 X13 *)
  0x9a9f37f4;       (* arm_CSET X20 Condition_CS *)
  0x9bc57c8d;       (* arm_UMULH X13 X4 X5 *)
  0xab0d02f7;       (* arm_ADDS X23 X23 X13 *)
  0x9bc67c8d;       (* arm_UMULH X13 X4 X6 *)
  0xba0d0318;       (* arm_ADCS X24 X24 X13 *)
  0x9bc77c8d;       (* arm_UMULH X13 X4 X7 *)
  0xba0d01ce;       (* arm_ADCS X14 X14 X13 *)
  0x9bc87c8d;       (* arm_UMULH X13 X4 X8 *)
  0xba0d01ef;       (* arm_ADCS X15 X15 X13 *)
  0x9bc97c8d;       (* arm_UMULH X13 X4 X9 *)
  0xba0d0210;       (* arm_ADCS X16 X16 X13 *)
  0x9bca7c8d;       (* arm_UMULH X13 X4 X10 *)
  0xba0d0231;       (* arm_ADCS X17 X17 X13 *)
  0x9bcb7c8d;       (* arm_UMULH X13 X4 X11 *)
  0xba0d0273;       (* arm_ADCS X19 X19 X13 *)
  0x9bcc7c8d;       (* arm_UMULH X13 X4 X12 *)
  0x9a0d0294;       (* arm_ADC X20 X20 X13 *)
  0xa9035815;       (* arm_STP X21 X22 X0 (Immediate_Offset (iword (&48))) *)
  0xa9046017;       (* arm_STP X23 X24 X0 (Immediate_Offset (iword (&64))) *)
  0xa9053c0e;       (* arm_STP X14 X15 X0 (Immediate_Offset (iword (&80))) *)
  0xa9064410;       (* arm_STP X16 X17 X0 (Immediate_Offset (iword (&96))) *)
  0xa9075013;       (* arm_STP X19 X20 X0 (Immediate_Offset (iword (&112))) *)
  0xa8c163f7;       (* arm_LDP X23 X24 SP (Postimmediate_Offset (iword (&16))) *)
  0xa8c15bf5;       (* arm_LDP X21 X22 SP (Postimmediate_Offset (iword (&16))) *)
  0xa8c153f3;       (* arm_LDP X19 X20 SP (Postimmediate_Offset (iword (&16))) *)
  0xd65f03c0        (* arm_RET X30 *)
];;

let BIGNUM_MUL_8_16_ALT_EXEC = ARM_MK_EXEC_RULE bignum_mul_8_16_alt_mc;;

(* ------------------------------------------------------------------------- *)
(* Proof.                                                                    *)
(* ------------------------------------------------------------------------- *)

let BIGNUM_MUL_8_16_ALT_CORRECT = time prove
 (`!z x y a b pc.
     nonoverlapping (word pc,0x458) (z,8 * 16) /\
     (x = z \/ nonoverlapping (x,8 * 8) (z,8 * 16))
     ==> ensures arm
          (\s. aligned_bytes_loaded s (word pc) bignum_mul_8_16_alt_mc /\
               read PC s = word(pc + 0xc) /\
               C_ARGUMENTS [z; x; y] s /\
               bignum_from_memory (x,8) s = a /\
               bignum_from_memory (y,8) s = b)
          (\s. read PC s = word (pc + 0x448) /\
               bignum_from_memory (z,16) s = a * b)
          (MAYCHANGE [PC; X3; X4; X5; X6; X7; X8; X9; X10; X11; X12; X13;
                      X14; X15; X16; X17; X19; X20; X21; X22; X23; X24] ,,
           MAYCHANGE [memory :> bytes(z,8 * 16)] ,,
           MAYCHANGE SOME_FLAGS ,, MAYCHANGE [events])`,
  MAP_EVERY X_GEN_TAC
   [`z:int64`; `x:int64`; `y:int64`; `a:num`; `b:num`; `pc:num`] THEN
  REWRITE_TAC[C_ARGUMENTS; SOME_FLAGS; NONOVERLAPPING_CLAUSES] THEN
  DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  ENSURES_INIT_TAC "s0" THEN
  BIGNUM_DIGITIZE_TAC "x_" `bignum_from_memory (x,8) s0` THEN
  BIGNUM_DIGITIZE_TAC "y_" `bignum_from_memory (y,8) s0` THEN
  ARM_ACCSTEPS_TAC BIGNUM_MUL_8_16_ALT_EXEC (1--271) (1--271) THEN
  RULE_ASSUM_TAC(REWRITE_RULE[COND_SWAP; GSYM WORD_BITVAL]) THEN
  ENSURES_FINAL_STATE_TAC THEN ASM_REWRITE_TAC[] THEN
  CONV_TAC(LAND_CONV BIGNUM_EXPAND_CONV) THEN ASM_REWRITE_TAC[] THEN
  MAP_EVERY EXPAND_TAC ["a"; "b"] THEN
  REWRITE_TAC[GSYM REAL_OF_NUM_CLAUSES] THEN
  ACCUMULATOR_POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o DECARRY_RULE) THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN REAL_ARITH_TAC);;

let BIGNUM_MUL_8_16_ALT_SUBROUTINE_CORRECT = time prove
 (`!z x y a b pc stackpointer returnaddress.
     aligned 16 stackpointer /\
     nonoverlapping (z,8 * 16) (word_sub stackpointer (word 48),48) /\
     (x = z \/ nonoverlapping (x,8 * 8) (z,8 * 16)) /\
     ALLPAIRS nonoverlapping
          [(z,8 * 16); (word_sub stackpointer (word 48),48)]
          [(word pc,0x458); (x,8 * 8); (y,8 * 8)]
     ==> ensures arm
          (\s. aligned_bytes_loaded s (word pc) bignum_mul_8_16_alt_mc /\
               read PC s = word pc /\
               read SP s = stackpointer /\
               read X30 s = returnaddress /\
               C_ARGUMENTS [z; x; y] s /\
               bignum_from_memory (x,8) s = a /\
               bignum_from_memory (y,8) s = b)
          (\s. read PC s = returnaddress /\
               bignum_from_memory (z,16) s = a * b)
          (MAYCHANGE_REGS_AND_FLAGS_PERMITTED_BY_ABI ,,
           MAYCHANGE [memory :> bytes(z,8 * 16);
                      memory :> bytes(word_sub stackpointer (word 48),48)])`,
  ARM_ADD_RETURN_STACK_TAC
    BIGNUM_MUL_8_16_ALT_EXEC BIGNUM_MUL_8_16_ALT_CORRECT
    `[X19;X20;X21;X22;X23;X24]` 48);;
