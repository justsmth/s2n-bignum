 ; * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 ; *
 ; * Licensed under the Apache License, Version 2.0 (the "License").
 ; * You may not use this file except in compliance with the License.
 ; * A copy of the License is located at
 ; *
 ; *  http://aws.amazon.com/apache2.0
 ; *
 ; * or in the "LICENSE" file accompanying this file. This file is distributed
 ; * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 ; * express or implied. See the License for the specific language governing
 ; * permissions and limitations under the License.

; ----------------------------------------------------------------------------
; Multiplex/select z := x (if p nonzero) or z := y (if p zero)
; Inputs b, x[k], y[k]; output b, z[k]
;
;    extern void bignum_mux
;     (uint64_t b, uint64_t k, uint64_t *z, uint64_t *x, uint64_t *y);
;
; It is assumed that all numbers x, y and z have the same size k digits.
;
; Standard x86-64 ABI: RDI = b, RSI = k, RDX = z, RCX = x, R8 = y
; ----------------------------------------------------------------------------

%define b rdi
%define k rsi
%define z rdx
%define x rcx
%define y r8
%define m r9
%define n r10
%define i r11
%define a rax

                global  bignum_mux
                section .text

bignum_mux:
                test    k, k
                jz      end                     ; If length = 0 do nothing

                neg     b                       ; CF <=> (b != 0)
                sbb     m, m                    ; m = mask for (b != 0)
                mov     n, m
                not     n                       ; n = mask for (b == 0)
                xor     i, i

loop:
                mov     a, [x+8*i]
                mov     b, [y+8*i]
                and     a, m
                and     b, n
                or      a, b
                mov     [z+8*i],a
                inc     i
                cmp     i, k
                jc      loop
end:
                ret