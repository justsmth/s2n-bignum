(*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "LICENSE" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 *)

(* ========================================================================= *)
(* Load all x86 bignum proofs in alphabetical order.                         *)
(* ========================================================================= *)

loadt "update_database.ml";;
prioritize_num();;

(* ------------------------------------------------------------------------- *)
(* Some background theory from the standard libraries.                       *)
(* ------------------------------------------------------------------------- *)

needs "Library/iter.ml";;
needs "Library/rstc.ml";;
needs "Library/bitsize.ml";;
needs "Library/pocklington.ml";;
needs "Library/integer.ml";;
needs "Library/words.ml";;
needs "Library/bitmatch.ml";;

(* ------------------------------------------------------------------------- *)
(* Common ARM-X86 proof infrastructure.                                      *)
(* ------------------------------------------------------------------------- *)

loadt "Common/overlap.ml";;
loadt "Common/for_hollight.ml";;
loadt "Common/words2.ml";;
loadt "Common/misc.ml";;
loadt "Common/components.ml";;
loadt "Common/records.ml";;
loadt "Common/relational.ml";;
loadt "Common/interval.ml";;
loadt "Common/elf.ml";;

loadt "X86/instruction.ml";;
loadt "X86/decode.ml";;
loadt "X86/x86.ml";;

prioritize_int();;
prioritize_real();;
prioritize_num();;

loadt "Common/bignum.ml";;

(* ------------------------------------------------------------------------- *)
(* Load the individual proofs (in alphabetical order)                        *)
(* ------------------------------------------------------------------------- *)

loadt "X86/bignum_add.ml";;
loadt "X86/bignum_add_p256.ml";;
loadt "X86/bignum_add_p384.ml";;
loadt "X86/bignum_amontifier.ml";;
loadt "X86/bignum_amontmul.ml";;
loadt "X86/bignum_amontmul_p256.ml";;
loadt "X86/bignum_amontmul_p384.ml";;
loadt "X86/bignum_amontredc.ml";;
loadt "X86/bignum_amontsqr.ml";;
loadt "X86/bignum_amontsqr_p256.ml";;
loadt "X86/bignum_amontsqr_p384.ml";;
loadt "X86/bignum_bitfield.ml";;
loadt "X86/bignum_bitsize.ml";;
loadt "X86/bignum_cld.ml";;
loadt "X86/bignum_clz.ml";;
loadt "X86/bignum_cmadd.ml";;
loadt "X86/bignum_cmul.ml";;
loadt "X86/bignum_cmul_p256.ml";;
loadt "X86/bignum_cmul_p384.ml";;
loadt "X86/bignum_coprime.ml";;
loadt "X86/bignum_copy.ml";;
loadt "X86/bignum_ctd.ml";;
loadt "X86/bignum_ctz.ml";;
loadt "X86/bignum_deamont_p256.ml";;
loadt "X86/bignum_deamont_p384.ml";;
loadt "X86/bignum_demont.ml";;
loadt "X86/bignum_demont_p256.ml";;
loadt "X86/bignum_demont_p384.ml";;
loadt "X86/bignum_digit.ml";;
loadt "X86/bignum_digitsize.ml";;
loadt "X86/bignum_double_p256.ml";;
loadt "X86/bignum_double_p384.ml";;
loadt "X86/bignum_emontredc.ml";;
loadt "X86/bignum_emontredc_8n.ml";;
loadt "X86/bignum_eq.ml";;
loadt "X86/bignum_even.ml";;
loadt "X86/bignum_ge.ml";;
loadt "X86/bignum_gt.ml";;
loadt "X86/bignum_half_p256.ml";;
loadt "X86/bignum_half_p384.ml";;
loadt "X86/bignum_iszero.ml";;
loadt "X86/bignum_le.ml";;
loadt "X86/bignum_lt.ml";;
loadt "X86/bignum_madd.ml";;
loadt "X86/bignum_mod_n256.ml";;
loadt "X86/bignum_mod_n256_4.ml";;
loadt "X86/bignum_mod_n384.ml";;
loadt "X86/bignum_mod_n384_6.ml";;
loadt "X86/bignum_mod_p256.ml";;
loadt "X86/bignum_mod_p256_4.ml";;
loadt "X86/bignum_mod_p384.ml";;
loadt "X86/bignum_mod_p384_6.ml";;
loadt "X86/bignum_modadd.ml";;
loadt "X86/bignum_moddouble.ml";;
loadt "X86/bignum_modifier.ml";;
loadt "X86/bignum_modinv.ml";;
loadt "X86/bignum_modoptneg.ml";;
loadt "X86/bignum_modsub.ml";;
loadt "X86/bignum_montifier.ml";;
loadt "X86/bignum_montmul.ml";;
loadt "X86/bignum_montmul_p256.ml";;
loadt "X86/bignum_montmul_p384.ml";;
loadt "X86/bignum_montredc.ml";;
loadt "X86/bignum_montsqr.ml";;
loadt "X86/bignum_montsqr_p256.ml";;
loadt "X86/bignum_montsqr_p384.ml";;
loadt "X86/bignum_mul.ml";;
loadt "X86/bignum_mul_4_8.ml";;
loadt "X86/bignum_mul_6_12.ml";;
loadt "X86/bignum_mul_8_16.ml";;
loadt "X86/bignum_mux.ml";;
loadt "X86/bignum_mux16.ml";;
loadt "X86/bignum_neg_p256.ml";;
loadt "X86/bignum_neg_p384.ml";;
loadt "X86/bignum_negmodinv.ml";;
loadt "X86/bignum_nonzero.ml";;
loadt "X86/bignum_normalize.ml";;
loadt "X86/bignum_odd.ml";;
loadt "X86/bignum_of_word.ml";;
loadt "X86/bignum_optadd.ml";;
loadt "X86/bignum_optneg.ml";;
loadt "X86/bignum_optneg_p256.ml";;
loadt "X86/bignum_optneg_p384.ml";;
loadt "X86/bignum_optsub.ml";;
loadt "X86/bignum_optsubadd.ml";;
loadt "X86/bignum_pow2.ml";;
loadt "X86/bignum_shl_small.ml";;
loadt "X86/bignum_shr_small.ml";;
loadt "X86/bignum_sqr_4_8.ml";;
loadt "X86/bignum_sqr_6_12.ml";;
loadt "X86/bignum_sqr_8_16.ml";;
loadt "X86/bignum_sub.ml";;
loadt "X86/bignum_sub_p256.ml";;
loadt "X86/bignum_sub_p384.ml";;
loadt "X86/bignum_tomont_p256.ml";;
loadt "X86/bignum_tomont_p384.ml";;
loadt "X86/bignum_triple_p256.ml";;
loadt "X86/bignum_triple_p384.ml";;
loadt "X86/word_clz.ml";;
loadt "X86/word_ctz.ml";;
loadt "X86/word_negmodinv.ml";;