
// C sources of the DCT functions:

inline __m128i _mm_mr_epi16(__m128i x, __m128i y, __m128i c){
	__m128i h = _mm_mulhi_epi16(x, y), l = _mm_mullo_epi16(x, y);
	return _mm_packs_epi32(_mm_srai_epi32(_mm_slli_epi32(_mm_srai_epi32(_mm_add_epi32(_mm_unpacklo_epi16(l, h), c), 15), 16), 16),
		                   _mm_srai_epi32(_mm_slli_epi32(_mm_srai_epi32(_mm_add_epi32(_mm_unpackhi_epi16(l, h), c), 15), 16), 16));
}

#define _mm_mradds_epi16(x, y, z) _mm_adds_epi16(_mm_mr_epi16(x, y, c), z)

__declspec(dllexport) void __stdcall DCT2DSlow(uint8_t *input, int16_t *output) {

	__m128i x0, x1, x2, x3, x4, x5, x6, x7, y0, y1, y2, y3, y4, y5, y6, y7;

	const __m128i k_ZERO = _mm_setzero_si128();

	{
		// Load unsigned bytes as signed words by subtracting by 128 as offset
		const __m128i k_128 = _mm_set1_epi16(128);
		y0 = _mm_sub_epi16(_mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(input + (0 * 8))), k_ZERO), k_128);
		y1 = _mm_sub_epi16(_mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(input + (1 * 8))), k_ZERO), k_128);
		y2 = _mm_sub_epi16(_mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(input + (2 * 8))), k_ZERO), k_128);
		y3 = _mm_sub_epi16(_mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(input + (3 * 8))), k_ZERO), k_128);
		y4 = _mm_sub_epi16(_mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(input + (4 * 8))), k_ZERO), k_128);
		y5 = _mm_sub_epi16(_mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(input + (5 * 8))), k_ZERO), k_128);
		y6 = _mm_sub_epi16(_mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(input + (6 * 8))), k_ZERO), k_128);
		y7 = _mm_sub_epi16(_mm_unpacklo_epi8(_mm_loadl_epi64((const __m128i *)(input + (7 * 8))), k_ZERO), k_128);
	}

	const __m128i c = _mm_set1_epi32(1 << 14);

	for(int32_t pass = 0; pass < 2; pass++){

		{
			// Transpose
			__m128i a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, b4, b5, b6, b7;

			b0 = _mm_unpacklo_epi16(y0, y4); // [ 00 40 01 41 02 42 03 43 ]
			b1 = _mm_unpackhi_epi16(y0, y4); // [ 04 44 05 45 06 46 07 47 ]
			b2 = _mm_unpacklo_epi16(y1, y5); // [ 10 50 11 51 12 52 13 53 ]
			b3 = _mm_unpackhi_epi16(y1, y5); // [ 14 54 15 55 16 56 17 57 ]
			b4 = _mm_unpacklo_epi16(y2, y6); // [ 20 60 21 61 22 62 23 63 ]
			b5 = _mm_unpackhi_epi16(y2, y6); // [ 24 64 25 65 26 66 27 67 ]
			b6 = _mm_unpacklo_epi16(y3, y7); // [ 30 70 31 71 32 72 33 73 ]
			b7 = _mm_unpackhi_epi16(y3, y7); // [ 34 74 35 75 36 76 37 77 ]

			a0 = _mm_unpacklo_epi16(b0, b4); // [ 00 20 40 60 01 21 41 61 ]
			a1 = _mm_unpackhi_epi16(b0, b4); // [ 02 22 42 62 03 23 43 63 ]
			a2 = _mm_unpacklo_epi16(b1, b5); // [ 04 24 44 64 05 25 45 65 ]
			a3 = _mm_unpackhi_epi16(b1, b5); // [ 06 26 46 66 07 27 47 67 ]
			a4 = _mm_unpacklo_epi16(b2, b6); // [ 10 30 50 70 11 31 51 71 ]
			a5 = _mm_unpackhi_epi16(b2, b6); // [ 12 32 52 72 13 33 53 73 ]
			a6 = _mm_unpacklo_epi16(b3, b7); // [ 14 34 54 74 15 35 55 75 ]
			a7 = _mm_unpackhi_epi16(b3, b7); // [ 16 36 56 76 17 37 57 77 ]

			x0 = _mm_unpacklo_epi16(a0, a4); // [ 00 10 20 30 40 50 60 70 ]
			x1 = _mm_unpackhi_epi16(a0, a4); // [ 01 11 21 31 41 51 61 71 ]
			x2 = _mm_unpacklo_epi16(a1, a5); // [ 02 12 22 32 42 52 62 72 ]
			x3 = _mm_unpackhi_epi16(a1, a5); // [ 03 13 23 33 43 53 63 73 ]
			x4 = _mm_unpacklo_epi16(a2, a6); // [ 04 14 24 34 44 54 64 74 ]
			x5 = _mm_unpackhi_epi16(a2, a6); // [ 05 15 25 35 45 55 65 75 ]
			x6 = _mm_unpacklo_epi16(a3, a7); // [ 06 16 26 36 46 56 66 76 ]
			x7 = _mm_unpackhi_epi16(a3, a7); // [ 07 17 27 37 47 57 67 77 ]

		}

		{
			// Transform
			__m128i t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;

			t8 = _mm_adds_epi16(x0, x7);
			t9 = _mm_subs_epi16(x0, x7);
			t0 = _mm_adds_epi16(x1, x6);
			t7 = _mm_subs_epi16(x1, x6);
			t1 = _mm_adds_epi16(x2, x5);
			t6 = _mm_subs_epi16(x2, x5);
			t2 = _mm_adds_epi16(x3, x4);
			t5 = _mm_subs_epi16(x3, x4);

			t3 = _mm_adds_epi16(t8, t2);
			t4 = _mm_subs_epi16(t8, t2);
			t2 = _mm_adds_epi16(t0, t1);
			t8 = _mm_subs_epi16(t0, t1);

			t1 = _mm_adds_epi16(t7, t6);
			t0 = _mm_subs_epi16(t7, t6);

			y0 = _mm_adds_epi16(t3, t2);
			y4 = _mm_subs_epi16(t3, t2);

			const __m128i c13573 = _mm_set1_epi16(13573);
			const __m128i c21895 = _mm_set1_epi16(21895);
			const __m128i cNeg21895 = _mm_set1_epi16(-21895);
			const __m128i c23170 = _mm_set1_epi16(23170);
			const __m128i cNeg23170 = _mm_set1_epi16(-23170);
			const __m128i c6518 = _mm_set1_epi16(6518);

			y2 = _mm_mradds_epi16(t8, c13573, t4);
			t10 = _mm_mr_epi16(t4, c13573, c);

			y6 = _mm_subs_epi16(t10, t8);

			t6 = _mm_mradds_epi16(t0, c23170, t5);
			t7 = _mm_mradds_epi16(t0, cNeg23170, t5);
			t2 = _mm_mradds_epi16(t1, cNeg23170, t9);
			t3 = _mm_mradds_epi16(t1, c23170, t9);

			y1 = _mm_mradds_epi16(t6, c6518, t3);
			t9 = _mm_mr_epi16(t3, c6518, c);

			y7 = _mm_subs_epi16(t9, t6);
			y5 = _mm_mradds_epi16(t2, c21895, t7);
			y3 = _mm_mradds_epi16(t7, cNeg21895, t2);

		}
	}

	{
		// Post scale and store
		const __m128i k_B = _mm_set_epi16(7880, 7422, 6680, 5681, 6680, 7422, 7880, 5681);
		const __m128i k_C = _mm_set_epi16(7422, 6992, 6292, 5351, 6292, 6992, 7422, 5351);
		const __m128i k_D = _mm_set_epi16(6680, 6292, 5663, 4816, 5663, 6292, 6680, 4816);
		_mm_storeu_si128((__m128i *)(&output[0 * 8]), _mm_mradds_epi16(_mm_set_epi16(5681, 5351, 4816, 4095, 4816, 5351, 5681, 4095), y0, k_ZERO));
		_mm_storeu_si128((__m128i *)(&output[1 * 8]), _mm_mradds_epi16(k_B, y1, k_ZERO));
		_mm_storeu_si128((__m128i *)(&output[2 * 8]), _mm_mradds_epi16(k_C, y2, k_ZERO));
		_mm_storeu_si128((__m128i *)(&output[3 * 8]), _mm_mradds_epi16(k_D, y3, k_ZERO));
		_mm_storeu_si128((__m128i *)(&output[4 * 8]), _mm_mradds_epi16(_mm_set_epi16(5681, 5351, 4816, 4095, 4816, 5351, 5681, 4095), y4, k_ZERO));
		_mm_storeu_si128((__m128i *)(&output[5 * 8]), _mm_mradds_epi16(k_D, y5, k_ZERO));
		_mm_storeu_si128((__m128i *)(&output[6 * 8]), _mm_mradds_epi16(k_C, y6, k_ZERO));
		_mm_storeu_si128((__m128i *)(&output[7 * 8]), _mm_mradds_epi16(k_B, y7, k_ZERO));
	}

}

__declspec(dllexport) void __stdcall DCT2DFast(uint8_t *input, int16_t *output){

	const int32_t CONST_BITS = 13;
	const int32_t ROW_BITS = 2;
	const int32_t SHIFT0 = CONST_BITS - ROW_BITS;
	const int32_t SHIFT0ADD = 1 << (SHIFT0 - 1);
	const int32_t SHIFT1 = ROW_BITS + 3;
	const int32_t SHIFT1ADD = 1 << (SHIFT1 - 1);
	const int32_t SHIFT2 = CONST_BITS + ROW_BITS + 3;
	const int32_t SHIFT2ADD = 1 << (SHIFT2 - 1);
	const __m128i rounder_11 = _mm_set1_epi32(SHIFT0ADD);
	const __m128i rounder_18 = _mm_set1_epi32(SHIFT2ADD + 16384);
	const __m128i rounder_5 = _mm_set1_epi16(SHIFT1ADD + 2);
	const __m128i FIX_1 = _mm_set_epi16(4433, 10703, 4433, 10703, 4433, 10703, 4433, 10703);
	const __m128i FIX_2 = _mm_set_epi16(-10704, 4433, -10704, 4433, -10704, 4433, -10704, 4433);
	const __m128i FIX_3a = _mm_set_epi16(2260, 6437, 2260, 6437, 2260, 6437, 2260, 6437);
	const __m128i FIX_3b = _mm_set_epi16(9633, 11363, 9633, 11363, 9633, 11363, 9633, 11363);
	const __m128i FIX_4a = _mm_set_epi16(-6436, -11362, -6436, -11362, -6436, -11362, -6436, -11362);
	const __m128i FIX_4b = _mm_set_epi16(-2259, 9633, -2259, 9633, -2259, 9633, -2259, 9633);
	const __m128i FIX_5a = _mm_set_epi16(9633, 2261, 9633, 2261, 9633, 2261, 9633, 2261);
	const __m128i FIX_5b = _mm_set_epi16(-11362, 6437, -11362, 6437, -11362, 6437, -11362, 6437);
	const __m128i FIX_6a = _mm_set_epi16(-11363, 9633, -11363, 9633, -11363, 9633, -11363, 9633);
	const __m128i FIX_6b = _mm_set_epi16(-6436, 2260, -6436, 2260, -6436, 2260, -6436, 2260);
	const __m128i k_128 = _mm_set1_epi16(128);

	__m128i data[8];
	__m128i buffer[8];

	__asm {

		push eax
		push edx

		lea eax,dword ptr [data]
		mov edx,dword ptr [input]

		// Load unsigned bytes as signed words by subtracting by 128 as offset
		pxor xmm7,xmm7
		movdqa xmm6,xmmword ptr [k_128]
		movq xmm0,qword ptr [edx+0]
		movq xmm1,qword ptr [edx+8]
		movq xmm2,qword ptr [edx+16]
		movq xmm3,qword ptr [edx+24]
		movq xmm4,qword ptr [edx+32]
		movq xmm5,qword ptr [edx+40]
		punpcklbw xmm0,xmm7
		punpcklbw xmm1,xmm7
		punpcklbw xmm2,xmm7
		punpcklbw xmm3,xmm7
		punpcklbw xmm4,xmm7
		punpcklbw xmm5,xmm7
		psubw xmm0,xmm6
		psubw xmm1,xmm6
		psubw xmm2,xmm6
		psubw xmm3,xmm6
		psubw xmm4,xmm6
		psubw xmm5,xmm6
		movdqa xmmword ptr [eax+0],xmm0
		movdqa xmmword ptr [eax+16],xmm1
		movq xmm0,qword ptr [edx+48]
		movq xmm1,qword ptr [edx+56]
		punpcklbw xmm0,xmm7
		punpcklbw xmm1,xmm7
		psubw xmm0,xmm6
		psubw xmm1,xmm6
		movdqa xmmword ptr [eax+32],xmm2
		movdqa xmmword ptr [eax+48],xmm3
		movdqa xmmword ptr [eax+64],xmm4
		movdqa xmmword ptr [eax+80],xmm5
		movdqa xmmword ptr [eax+96],xmm0
		movdqa xmmword ptr [eax+112],xmm1

		lea	edx,dword ptr [buffer]

		prefetchnta [FIX_1]
        prefetchnta [FIX_3a]
        prefetchnta [FIX_5a]

		// First we transpose last 4 rows
		movdqa xmm0,xmmword ptr [eax+0*16]  // 07 06 05 04 03 02 01 00
        movdqa xmm6,xmmword ptr [eax+2*16]  // 27 26 25 24 23 22 21 20
        movdqa xmm4,xmmword ptr [eax+4*16]  // 47 46 45 44 43 42 41 40
        movdqa xmm7,xmmword ptr [eax+6*16]  // 67 66 65 64 63 62 61 60
        punpckhwd xmm0,xmmword ptr [eax+1*16]
        movdqa xmm2,xmm0
        punpckhwd xmm6,xmmword ptr [eax+3*16]
        punpckhwd xmm4,xmmword ptr [eax+5*16]
        movdqa xmm5,xmm4
        punpckhwd xmm7,xmmword ptr [eax+7*16]
        punpckldq xmm0,xmm6 // 31 21 11 01 30 20 10 00
        movdqa xmm1,xmm0
        punpckldq xmm4,xmm7 // 71 61 51 41 70 60 50 40
        punpckhdq xmm2,xmm6 // 33 23 13 03 32 22 12 02
        movdqa xmm3,xmm2
        punpckhdq xmm5,xmm7 // 73 63 53 43 72 62 52 42
        punpcklqdq xmm0,xmm4 // 70 60 50 40 30 20 10 00
        punpcklqdq xmm2,xmm5 // 72 62 52 42 32 22 21 02
        punpckhqdq xmm1,xmm4 // 71 61 51 41 31 21 11 01
        punpckhqdq xmm3,xmm5 // 73 63 53 43 33 23 13 03
        movdqa xmmword ptr [edx+4*16],xmm0
        movdqa xmmword ptr [edx+5*16],xmm1
        movdqa xmmword ptr [edx+6*16],xmm2
        movdqa xmmword ptr [edx+7*16],xmm3

		// Then we transpose first 4 rows
		movdqa xmm0,xmmword ptr [eax+0*16] // 07 06 05 04 03 02 01 00
        movdqa xmm6,xmmword ptr [eax+2*16] // 27 26 25 24 23 22 21 20
        movdqa xmm4,xmmword ptr [eax+4*16] // 47 46 45 44 43 42 41 40
        movdqa xmm7,xmmword ptr [eax+6*16] // 67 66 65 64 63 62 61 60
        punpcklwd xmm0,xmmword ptr [eax+1*16] // 13 03 12 02 11 01 10 00
        movdqa xmm2,xmm0
        punpcklwd xmm6,xmmword ptr [eax+3*16] // 33 23 32 22 31 21 30 20
        punpcklwd xmm4,xmmword ptr [eax+5*16] // 53 43 52 42 51 41 50 40
        movdqa xmm5,xmm4
        punpcklwd xmm7,xmmword ptr [eax+7*16] // 73 63 72 62 71 61 70 60
        punpckldq xmm0,xmm6 // 31 21 11 01 30 20 10 00
        movdqa xmm1,xmm0
        punpckldq xmm4,xmm7 // 71 61 51 41 70 60 50 40
        punpckhdq xmm2,xmm6 // 33 23 13 03 32 22 12 02
        movdqa xmm3,xmm2
        punpckhdq xmm5,xmm7 // 73 63 53 43 72 62 52 42
        punpcklqdq xmm0,xmm4 // 70 60 50 40 30 20 10 00
        punpcklqdq xmm2,xmm5 // 72 62 52 42 32 22 21 02
        punpckhqdq xmm1,xmm4 // 71 61 51 41 31 21 11 01
        punpckhqdq xmm3,xmm5 // 73 63 53 43 33 23 13 03
        movdqa xmmword ptr [edx+0*16],xmm0
        movdqa xmmword ptr [edx+1*16],xmm1
        movdqa xmmword ptr [edx+2*16],xmm2
        movdqa xmmword ptr [edx+3*16],xmm3

		// DCT 1D
		paddsw	xmm0,xmmword ptr [edx+16*7]	// tmp0
        movdqa  xmm4,xmm0
		paddsw	xmm1,xmmword ptr [edx+16*6]	// tmp1
        movdqa  xmm5,xmm1
		paddsw	xmm2,xmmword ptr [edx+16*5]	// tmp2
		paddsw	xmm3,xmmword ptr [edx+16*4]	// tmp3

		paddsw xmm0,xmm3 // tmp10
        movdqa xmm6,xmm0 // tmp10
		paddsw xmm1,xmm2 // tmp11
		psubsw xmm4,xmm3 // tmp13
		psubsw xmm5,xmm2 // tmp12

		paddsw xmm0,xmm1
		psubsw xmm6,xmm1

		psllw xmm0,2
		psllw xmm6,2

		movdqa xmm1,xmm4
        movdqa xmm2,xmm4

		movdqa xmmword ptr [eax+16*0],xmm0
		movdqa xmmword ptr [eax+16*4],xmm6

        movdqa xmm7,xmmword ptr [FIX_1]

        punpckhwd xmm1,xmm5 // 12 13 12 13 12 13 12 13 high part
        movdqa xmm6,xmm1 // high
        punpcklwd xmm2,xmm5 // 12 13 12 13 12 13 12 13 low part
        movdqa xmm0,xmm2 // low

        movdqa xmm4,xmmword ptr [FIX_2]

        movdqa xmm5,xmmword ptr [rounder_11]

        pmaddwd xmm2,xmm7 // [FIX_1]
        pmaddwd xmm1,xmm7 // [FIX_1]
        pmaddwd xmm0,xmm4 // [FIX_2]
        pmaddwd xmm6,xmm4 // [FIX_2]

        paddd xmm2,xmm5 // rounder
        paddd xmm1,xmm5 // rounder
        psrad xmm2,11
        psrad xmm1,11

		packssdw xmm2,xmm1
		movdqa xmmword ptr [eax+16*2],xmm2

        paddd xmm0,xmm5 // rounder
        paddd xmm6,xmm5 // rounder
        psrad xmm0,11
        psrad xmm6,11

		packssdw xmm0,xmm6
		movdqa xmmword ptr [eax+16*6],xmm0

		movdqa xmm0,xmmword ptr [edx+16*0]
		movdqa xmm1,xmmword ptr [edx+16*1]
		movdqa xmm2,xmmword ptr [edx+16*2]
		movdqa xmm3,xmmword ptr [edx+16*3]

		psubsw xmm0,xmmword ptr [edx+16*7]	// tmp7
		movdqa xmm4,xmm0
		psubsw xmm1,xmmword ptr [edx+16*6]	// tmp6
		psubsw xmm2,xmmword ptr [edx+16*5]	// tmp5
		movdqa xmm6,xmm2
		psubsw xmm3,xmmword ptr [edx+16*4]	// tmp4

        punpckhwd xmm4,xmm1 // 6 7 6 7 6 7 6 7 high part
        punpcklwd xmm0,xmm1 // 6 7 6 7 6 7 6 7 low part
        punpckhwd xmm6,xmm3 // 4 5 4 5 4 5 4 5 high part
        punpcklwd xmm2,xmm3 // 4 5 4 5 4 5 4 5 low part

		movdqa xmm1,xmmword ptr [FIX_3a]
        movdqa xmm5,xmmword ptr [FIX_3b]
        movdqa xmm3,xmm1
        movdqa xmm7,xmm5
        pmaddwd xmm1,xmm2
        pmaddwd xmm5,xmm0
        paddd xmm1,xmm5
        movdqa xmm5,xmmword ptr [rounder_11]
        pmaddwd xmm3,xmm6
        pmaddwd xmm7,xmm4
		paddd xmm3,xmm7
        paddd xmm1,xmm5
        paddd xmm3,xmm5
        psrad xmm1,11
        psrad xmm3,11
		packssdw xmm1,xmm3
		movdqa xmmword ptr [eax+16*1],xmm1

		movdqa xmm1,xmmword ptr [FIX_4a]
        movdqa xmm5,xmmword ptr [FIX_4b]
        movdqa xmm3,xmm1
        movdqa xmm7,xmm5
        pmaddwd xmm1,xmm2
        pmaddwd xmm5,xmm0
        paddd xmm1,xmm5
        movdqa xmm5,xmmword ptr [rounder_11]
        pmaddwd xmm3,xmm6
        pmaddwd xmm7,xmm4
		paddd xmm3,xmm7
        paddd xmm1,xmm5
        paddd xmm3,xmm5
        psrad xmm1,11
        psrad xmm3,11
		packssdw xmm1,xmm3
		movdqa xmmword ptr [eax+16*3],xmm1

		movdqa xmm1,xmmword ptr [FIX_5a]
        movdqa xmm5,xmmword ptr [FIX_5b]
        movdqa xmm3,xmm1
        movdqa xmm7,xmm5
        pmaddwd xmm1,xmm2
        pmaddwd xmm5,xmm0
        paddd xmm1,xmm5
        movdqa xmm5,xmmword ptr [rounder_11]
        pmaddwd xmm3,xmm6
        pmaddwd xmm7,xmm4
		paddd xmm3,xmm7
        paddd xmm1,xmm5
        paddd xmm3,xmm5
        psrad xmm1,11
        psrad xmm3,11
		packssdw xmm1,xmm3
		movdqa xmmword ptr [eax+16*5],xmm1

        pmaddwd xmm2,xmmword ptr [FIX_6a]
        pmaddwd xmm0,xmmword ptr [FIX_6b]
        paddd xmm2,xmm0
        pmaddwd xmm6,xmmword ptr [FIX_6a]
        pmaddwd xmm4,xmmword ptr [FIX_6b]
        paddd xmm6,xmm4
        paddd xmm2,xmm5 // rounder
        paddd xmm6,xmm5 // rounder
        psrad xmm2,11
        psrad xmm6,11

        packssdw xmm2,xmm6
        movdqa xmmword ptr [eax+16*7],xmm2

		// First we transpose last 4 rows
		movdqa xmm0,xmmword ptr [eax+0*16]  // 07 06 05 04 03 02 01 00
        movdqa xmm6,xmmword ptr [eax+2*16]  // 27 26 25 24 23 22 21 20
        movdqa xmm4,xmmword ptr [eax+4*16]  // 47 46 45 44 43 42 41 40
        movdqa xmm7,xmmword ptr [eax+6*16]  // 67 66 65 64 63 62 61 60
        punpckhwd xmm0,xmmword ptr [eax+1*16]
        movdqa xmm2,xmm0
        punpckhwd xmm6,xmmword ptr [eax+3*16]
        punpckhwd xmm4,xmmword ptr [eax+5*16]
        movdqa xmm5,xmm4
        punpckhwd xmm7,xmmword ptr [eax+7*16]
        punpckldq xmm0,xmm6 // 31 21 11 01 30 20 10 00
        movdqa xmm1,xmm0
        punpckldq xmm4,xmm7 // 71 61 51 41 70 60 50 40
        punpckhdq xmm2,xmm6 // 33 23 13 03 32 22 12 02
        movdqa xmm3,xmm2
        punpckhdq xmm5,xmm7 // 73 63 53 43 72 62 52 42
        punpcklqdq xmm0,xmm4 // 70 60 50 40 30 20 10 00
        punpcklqdq xmm2,xmm5 // 72 62 52 42 32 22 21 02
        punpckhqdq xmm1,xmm4 // 71 61 51 41 31 21 11 01
        punpckhqdq xmm3,xmm5 // 73 63 53 43 33 23 13 03
        movdqa xmmword ptr [edx+4*16],xmm0
        movdqa xmmword ptr [edx+5*16],xmm1
        movdqa xmmword ptr [edx+6*16],xmm2
        movdqa xmmword ptr [edx+7*16],xmm3

		// Then we transpose first 4 rows
		movdqa xmm0,xmmword ptr [eax+0*16] // 07 06 05 04 03 02 01 00
        movdqa xmm6,xmmword ptr [eax+2*16] // 27 26 25 24 23 22 21 20
        movdqa xmm4,xmmword ptr [eax+4*16] // 47 46 45 44 43 42 41 40
        movdqa xmm7,xmmword ptr [eax+6*16] // 67 66 65 64 63 62 61 60
        punpcklwd xmm0,xmmword ptr [eax+1*16] // 13 03 12 02 11 01 10 00
        movdqa xmm2,xmm0
        punpcklwd xmm6,xmmword ptr [eax+3*16] // 33 23 32 22 31 21 30 20
        punpcklwd xmm4,xmmword ptr [eax+5*16] // 53 43 52 42 51 41 50 40
        movdqa xmm5,xmm4
        punpcklwd xmm7,xmmword ptr [eax+7*16] // 73 63 72 62 71 61 70 60
        punpckldq xmm0,xmm6 // 31 21 11 01 30 20 10 00
        movdqa xmm1,xmm0
        punpckldq xmm4,xmm7 // 71 61 51 41 70 60 50 40
        punpckhdq xmm2,xmm6 // 33 23 13 03 32 22 12 02
        movdqa xmm3,xmm2
        punpckhdq xmm5,xmm7 // 73 63 53 43 72 62 52 42
        punpcklqdq xmm0,xmm4 // 70 60 50 40 30 20 10 00
        punpcklqdq xmm2,xmm5 // 72 62 52 42 32 22 21 02
        punpckhqdq xmm1,xmm4 // 71 61 51 41 31 21 11 01
        punpckhqdq xmm3,xmm5 // 73 63 53 43 33 23 13 03
        movdqa xmmword ptr [edx+0*16],xmm0
        movdqa xmmword ptr [edx+1*16],xmm1
        movdqa xmmword ptr [edx+2*16],xmm2
        movdqa xmmword ptr [edx+3*16],xmm3

        movdqa xmm7,xmmword ptr [rounder_5]

		paddsw xmm0,xmmword ptr [edx+16*7] //tmp0
        movdqa xmm4,xmm0
		paddsw xmm1,xmmword ptr [edx+16*6] // tmp1
        movdqa xmm5,xmm1
		paddsw xmm2,xmmword ptr [edx+16*5] // tmp2
		paddsw xmm3,xmmword ptr [edx+16*4] // tmp3

		paddsw xmm0,xmm3 // tmp10
        // In the second pass we must round and shift before
        // the tmp10+tmp11 and tmp10-tmp11 calculation
        // or the overflow will happen.
        paddsw xmm0,xmm7 // [rounder_5]
        psraw xmm0,5
        movdqa xmm6,xmm0 // tmp10
		paddsw xmm1,xmm2 // tmp11
		psubsw xmm4,xmm3 // tmp13
		psubsw xmm5,xmm2 // tmp12

        paddsw xmm1,xmm7 // [rounder_5]
        psraw xmm1,5

		paddsw xmm0,xmm1
		psubsw xmm6,xmm1

        movdqa xmm1,xmm4
        movdqa xmm2,xmm4

		movdqa xmmword ptr [eax+16*0],xmm0
		movdqa xmmword ptr [eax+16*4],xmm6

        movdqa xmm7,xmmword ptr [FIX_1]

        punpckhwd xmm1,xmm5 // 12 13 12 13 12 13 12 13 high part
        movdqa xmm6,xmm1 // high
        punpcklwd xmm2,xmm5 // 12 13 12 13 12 13 12 13 low part
        movdqa xmm0,xmm2 // low

        movdqa xmm4,xmmword ptr [FIX_2]

        movdqa xmm5,xmmword ptr [rounder_18]

        pmaddwd xmm2,xmm7 // [FIX_1]
        pmaddwd xmm1,xmm7 // [FIX_1]
        pmaddwd xmm0,xmm4 // [FIX_2]
        pmaddwd xmm6,xmm4 // [FIX_2]

        paddd xmm2,xmm5 // rounder
        paddd xmm1,xmm5 // rounder
        psrad xmm2,18
        psrad xmm1,18

		packssdw xmm2,xmm1
		movdqa xmmword ptr [eax+16*2],xmm2

        paddd xmm0,xmm5 // rounder
        paddd xmm6,xmm5 // rounder
        psrad xmm0,18
        psrad xmm6,18

		packssdw xmm0,xmm6
		movdqa xmmword ptr [eax+16*6],xmm0

		movdqa xmm0,xmmword ptr [edx+16*0]
		movdqa xmm1,xmmword ptr [edx+16*1]
		movdqa xmm2,xmmword ptr [edx+16*2]
		movdqa xmm3,xmmword ptr [edx+16*3]

		psubsw xmm0,xmmword ptr [edx+16*7] // tmp7
		movdqa xmm4,xmm0
		psubsw xmm1,xmmword ptr [edx+16*6] // tmp6
		psubsw xmm2,xmmword ptr [edx+16*5] // tmp5
		movdqa xmm6,xmm2
		psubsw xmm3,xmmword ptr [edx+16*4] // tmp4

        punpckhwd xmm4,xmm1 // 6 7 6 7 6 7 6 7 high part
        punpcklwd xmm0,xmm1 // 6 7 6 7 6 7 6 7 low part
        punpckhwd xmm6,xmm3 // 4 5 4 5 4 5 4 5 high part
        punpcklwd xmm2,xmm3 // 4 5 4 5 4 5 4 5 low part

		movdqa xmm1,xmmword ptr [FIX_3a]
        movdqa xmm5,xmmword ptr [FIX_3b]
        movdqa xmm3,xmm1
        movdqa xmm7,xmm5
        pmaddwd xmm1,xmm2
        pmaddwd xmm5,xmm0
        paddd xmm1,xmm5
        movdqa xmm5,xmmword ptr [rounder_18]
        pmaddwd xmm3,xmm6
        pmaddwd xmm7,xmm4
		paddd xmm3,xmm7
        paddd xmm1,xmm5
        paddd xmm3,xmm5
        psrad xmm1,18
        psrad xmm3,18
		packssdw xmm1,xmm3
		movdqa xmmword ptr [eax+16],xmm1

		movdqa xmm1,xmmword ptr [FIX_4a]
        movdqa xmm5,xmmword ptr [FIX_4b]
        movdqa xmm3,xmm1
        movdqa xmm7,xmm5
        pmaddwd xmm1,xmm2
        pmaddwd xmm5,xmm0
        paddd xmm1,xmm5
        movdqa xmm5,xmmword ptr [rounder_18]
        pmaddwd xmm3,xmm6
        pmaddwd xmm7,xmm4
		paddd xmm3,xmm7
        paddd xmm1,xmm5
        paddd xmm3,xmm5
        psrad xmm1,18
        psrad xmm3,18
		packssdw xmm1,xmm3
		movdqa xmmword ptr [eax+48],xmm1

		movdqa xmm1,xmmword ptr [FIX_5a]
        movdqa xmm5,xmmword ptr [FIX_5b]
        movdqa xmm3,xmm1
        movdqa xmm7,xmm5
        pmaddwd xmm1,xmm2
        pmaddwd xmm5,xmm0
        paddd xmm1,xmm5
        movdqa xmm5,xmmword ptr [rounder_18]
        pmaddwd xmm3,xmm6
        pmaddwd xmm7,xmm4
		paddd xmm3,xmm7
        paddd xmm1,xmm5
        paddd xmm3,xmm5
        psrad xmm1,18
        psrad xmm3,18
		packssdw xmm1,xmm3
		movdqa xmmword ptr [eax+80],xmm1

        pmaddwd xmm2,xmmword ptr [FIX_6a]
        pmaddwd xmm0,xmmword ptr [FIX_6b]
        paddd xmm2,xmm0
        pmaddwd xmm6,xmmword ptr [FIX_6a]
        pmaddwd xmm4,xmmword ptr [FIX_6b]
        paddd xmm6,xmm4
        paddd xmm2,xmm5 // rounder
        paddd xmm6,xmm5 // rounder
        psrad xmm2,18
        psrad xmm6,18

        packssdw xmm2,xmm6
        movdqa xmmword ptr [eax+112],xmm2

		// Store result
		mov edx,dword ptr [output]
		movdqa xmm0,xmmword ptr [eax+0]
		movdqa xmm1,xmmword ptr [eax+16]
		movdqa xmm2,xmmword ptr [eax+32]
		movdqa xmm3,xmmword ptr [eax+48]
		movdqa xmm4,xmmword ptr [eax+64]
		movdqa xmm5,xmmword ptr [eax+80]
		movdqa xmm6,xmmword ptr [eax+96]
		movdqa xmm7,xmmword ptr [eax+112]
		movdqu xmmword ptr [edx+0],xmm0
		movdqu xmmword ptr [edx+16],xmm1
		movdqu xmmword ptr [edx+32],xmm2
		movdqu xmmword ptr [edx+48],xmm3
		movdqu xmmword ptr [edx+64],xmm4
		movdqu xmmword ptr [edx+80],xmm5
		movdqu xmmword ptr [edx+96],xmm6
		movdqu xmmword ptr [edx+112],xmm7

		pop edx
		pop eax

	}
}

// and for Delphi 7:

inline __m128i _mm_mr_epi16(__m128i x, __m128i y, __m128i c) {
	__m128i h = _mm_mulhi_epi16(x, y), l = _mm_mullo_epi16(x, y);
   return _mm_packs_epi32( _mm_srai_epi32( _mm_slli_epi32((_mm_srai_epi32(_mm_add_epi32(_mm_unpacklo_epi16(l, h), c), 15), 16), 16), _mm_srai_epi32( _mm_slli_epi32(_mm_srai_epi32(_mm_add_epi32(_mm_unpackhi_epi16(l, h), c), 15), 16), 16) )
}

#define _mm_mradds_epi16(x, y, z) _mm_adds_epi16(_mm_mr_epi16(x, y, *((__m128i*)(&c))), z)

__declspec(dllexport) void __stdcall dct_vector(uint8_t *input, int16_t *output) {

	static int16_t PostScaleArray[64] = {
		4095, 5681, 5351, 4816, 4095, 4816, 5351, 5681,
		5681, 7880, 7422, 6680, 5681, 6680, 7422, 7880,
		5351, 7422, 6992, 6292, 5351, 6292, 6992, 7422,
		4816, 6680, 6292, 5663, 4816, 5663, 6292, 6680,
		4095, 5681, 5351, 4816, 4095, 4816, 5351, 5681,
		4816, 6680, 6292, 5663, 4816, 5663, 6292, 6680,
		5351, 7422, 6992, 6292, 5351, 6292, 6992, 7422,
		5681, 7880, 7422, 6680, 5681, 6680, 7422, 7880
	};

	__m128i t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;
	__m128i a0, a1, a2, a3, a4, a5, a6, a7;
	__m128i b0, b1, b2, b3, b4, b5, b6, b7;

	volatile __m128i c13573 = _mm_set1_epi16(13573);
	volatile __m128i c21895 = _mm_set1_epi16(21895);
	volatile __m128i cNeg21895 = _mm_set1_epi16(-21895);
	volatile __m128i c23170 = _mm_set1_epi16(23170);
	volatile __m128i cNeg23170 = _mm_set1_epi16(-23170);
	volatile __m128i c6518 = _mm_set1_epi16(6518);
	volatile __m128i c = _mm_set1_epi32(1 << 14);

	__m128i vx[8], vy[8];

	const __m128i k__ZERO = _mm_setzero_si128();
	volatile __m128i k__128 = _mm_set1_epi16(128);

	__m128i in0 = _mm_loadl_epi64((const __m128i *)(input + (0 * 8)));
	__m128i in1 = _mm_loadl_epi64((const __m128i *)(input + (1 * 8)));
	__m128i in2 = _mm_loadl_epi64((const __m128i *)(input + (2 * 8)));
	__m128i in3 = _mm_loadl_epi64((const __m128i *)(input + (3 * 8)));
	__m128i in4 = _mm_loadl_epi64((const __m128i *)(input + (4 * 8)));
	__m128i in5 = _mm_loadl_epi64((const __m128i *)(input + (5 * 8)));
	__m128i in6 = _mm_loadl_epi64((const __m128i *)(input + (6 * 8)));
	__m128i in7 = _mm_loadl_epi64((const __m128i *)(input + (7 * 8)));
	// Convert bytes to words
	in0 = _mm_unpacklo_epi8(in0, k__ZERO);
	in1 = _mm_unpacklo_epi8(in1, k__ZERO);
	in2 = _mm_unpacklo_epi8(in2, k__ZERO);
	in3 = _mm_unpacklo_epi8(in3, k__ZERO);
	in4 = _mm_unpacklo_epi8(in4, k__ZERO);
	in5 = _mm_unpacklo_epi8(in5, k__ZERO);
	in6 = _mm_unpacklo_epi8(in6, k__ZERO);
	in7 = _mm_unpacklo_epi8(in7, k__ZERO);
	// Convert unsigned words to signed words (subtracting by 128)
	vy[0] = _mm_sub_epi16(in0, *((__m128i*)(&k__128)));
	vy[1] = _mm_sub_epi16(in1, *((__m128i*)(&k__128)));
	vy[2] = _mm_sub_epi16(in2, *((__m128i*)(&k__128)));
	vy[3] = _mm_sub_epi16(in3, *((__m128i*)(&k__128)));
	vy[4] = _mm_sub_epi16(in4, *((__m128i*)(&k__128)));
	vy[5] = _mm_sub_epi16(in5, *((__m128i*)(&k__128)));
	vy[6] = _mm_sub_epi16(in6, *((__m128i*)(&k__128)));
	vy[7] = _mm_sub_epi16(in7, *((__m128i*)(&k__128)));

	{
		// Transpose

		b0 = _mm_unpacklo_epi16(vy[0], vy[4]);     /* [ 00 40 01 41 02 42 03 43 ]*/
		b1 = _mm_unpackhi_epi16(vy[0], vy[4]);     /* [ 04 44 05 45 06 46 07 47 ]*/
		b2 = _mm_unpacklo_epi16(vy[1], vy[5]);     /* [ 10 50 11 51 12 52 13 53 ]*/
		b3 = _mm_unpackhi_epi16(vy[1], vy[5]);     /* [ 14 54 15 55 16 56 17 57 ]*/
		b4 = _mm_unpacklo_epi16(vy[2], vy[6]);     /* [ 20 60 21 61 22 62 23 63 ]*/
		b5 = _mm_unpackhi_epi16(vy[2], vy[6]);     /* [ 24 64 25 65 26 66 27 67 ]*/
		b6 = _mm_unpacklo_epi16(vy[3], vy[7]);     /* [ 30 70 31 71 32 72 33 73 ]*/
		b7 = _mm_unpackhi_epi16(vy[3], vy[7]);     /* [ 34 74 35 75 36 76 37 77 ]*/

		a0 = _mm_unpacklo_epi16(b0, b4);                 /* [ 00 20 40 60 01 21 41 61 ]*/
		a1 = _mm_unpackhi_epi16(b0, b4);                 /* [ 02 22 42 62 03 23 43 63 ]*/
		a2 = _mm_unpacklo_epi16(b1, b5);                 /* [ 04 24 44 64 05 25 45 65 ]*/
		a3 = _mm_unpackhi_epi16(b1, b5);                 /* [ 06 26 46 66 07 27 47 67 ]*/
		a4 = _mm_unpacklo_epi16(b2, b6);                 /* [ 10 30 50 70 11 31 51 71 ]*/
		a5 = _mm_unpackhi_epi16(b2, b6);                 /* [ 12 32 52 72 13 33 53 73 ]*/
		a6 = _mm_unpacklo_epi16(b3, b7);                 /* [ 14 34 54 74 15 35 55 75 ]*/
		a7 = _mm_unpackhi_epi16(b3, b7);                 /* [ 16 36 56 76 17 37 57 77 ]*/

		vx[0] = _mm_unpacklo_epi16(a0, a4);          /* [ 00 10 20 30 40 50 60 70 ]*/
		vx[1] = _mm_unpackhi_epi16(a0, a4);          /* [ 01 11 21 31 41 51 61 71 ]*/
		vx[2] = _mm_unpacklo_epi16(a1, a5);          /* [ 02 12 22 32 42 52 62 72 ]*/
		vx[3] = _mm_unpackhi_epi16(a1, a5);          /* [ 03 13 23 33 43 53 63 73 ]*/
		vx[4] = _mm_unpacklo_epi16(a2, a6);          /* [ 04 14 24 34 44 54 64 74 ]*/
		vx[5] = _mm_unpackhi_epi16(a2, a6);          /* [ 05 15 25 35 45 55 65 75 ]*/
		vx[6] = _mm_unpacklo_epi16(a3, a7);          /* [ 06 16 26 36 46 56 66 76 ]*/
		vx[7] = _mm_unpackhi_epi16(a3, a7);          /* [ 07 17 27 37 47 57 67 77 ]*/

	}

	{
		// Transform

		t8 = _mm_adds_epi16(vx[0], vx[7]);
		t9 = _mm_subs_epi16(vx[0], vx[7]);
		t0 = _mm_adds_epi16(vx[1], vx[6]);
		t7 = _mm_subs_epi16(vx[1], vx[6]);
		t1 = _mm_adds_epi16(vx[2], vx[5]);
		t6 = _mm_subs_epi16(vx[2], vx[5]);
		t2 = _mm_adds_epi16(vx[3], vx[4]);
		t5 = _mm_subs_epi16(vx[3], vx[4]);

		t3 = _mm_adds_epi16(t8, t2);
		t4 = _mm_subs_epi16(t8, t2);
		t2 = _mm_adds_epi16(t0, t1);
		t8 = _mm_subs_epi16(t0, t1);

		t1 = _mm_adds_epi16(t7, t6);
		t0 = _mm_subs_epi16(t7, t6);

		vy[0] = _mm_adds_epi16(t3, t2);
		vy[4] = _mm_subs_epi16(t3, t2);

		vy[2] = _mm_mradds_epi16(t8, *((__m128i*)(&c13573)), t4);
		t10 = _mm_mr_epi16(t4, *((__m128i*)(&c13573)), *((__m128i*)(&c)));

		vy[6] = _mm_subs_epi16(t10, t8);

		t6 = _mm_mradds_epi16(t0, *((__m128i*)(&c23170)), t5);
		t7 = _mm_mradds_epi16(t0, *((__m128i*)(&cNeg23170)), t5);
		t2 = _mm_mradds_epi16(t1, *((__m128i*)(&cNeg23170)), t9);
		t3 = _mm_mradds_epi16(t1, *((__m128i*)(&c23170)), t9);

		vy[1] = _mm_mradds_epi16(t6, *((__m128i*)(&c6518)), t3);
		t9 = _mm_mr_epi16(t3, *((__m128i*)(&c6518)), *((__m128i*)(&c)));

		vy[7] = _mm_subs_epi16(t9, t6);
		vy[5] = _mm_mradds_epi16(t2, *((__m128i*)(&c21895)), t7);
		vy[3] = _mm_mradds_epi16(t7, *((__m128i*)(&cNeg21895)), t2);

	}

	{
		// Transpose

		b0 = _mm_unpacklo_epi16(vy[0], vy[4]);     /* [ 00 40 01 41 02 42 03 43 ]*/
		b1 = _mm_unpackhi_epi16(vy[0], vy[4]);     /* [ 04 44 05 45 06 46 07 47 ]*/
		b2 = _mm_unpacklo_epi16(vy[1], vy[5]);     /* [ 10 50 11 51 12 52 13 53 ]*/
		b3 = _mm_unpackhi_epi16(vy[1], vy[5]);     /* [ 14 54 15 55 16 56 17 57 ]*/
		b4 = _mm_unpacklo_epi16(vy[2], vy[6]);     /* [ 20 60 21 61 22 62 23 63 ]*/
		b5 = _mm_unpackhi_epi16(vy[2], vy[6]);     /* [ 24 64 25 65 26 66 27 67 ]*/
		b6 = _mm_unpacklo_epi16(vy[3], vy[7]);     /* [ 30 70 31 71 32 72 33 73 ]*/
		b7 = _mm_unpackhi_epi16(vy[3], vy[7]);     /* [ 34 74 35 75 36 76 37 77 ]*/

		a0 = _mm_unpacklo_epi16(b0, b4);                 /* [ 00 20 40 60 01 21 41 61 ]*/
		a1 = _mm_unpackhi_epi16(b0, b4);                 /* [ 02 22 42 62 03 23 43 63 ]*/
		a2 = _mm_unpacklo_epi16(b1, b5);                 /* [ 04 24 44 64 05 25 45 65 ]*/
		a3 = _mm_unpackhi_epi16(b1, b5);                 /* [ 06 26 46 66 07 27 47 67 ]*/
		a4 = _mm_unpacklo_epi16(b2, b6);                 /* [ 10 30 50 70 11 31 51 71 ]*/
		a5 = _mm_unpackhi_epi16(b2, b6);                 /* [ 12 32 52 72 13 33 53 73 ]*/
		a6 = _mm_unpacklo_epi16(b3, b7);                 /* [ 14 34 54 74 15 35 55 75 ]*/
		a7 = _mm_unpackhi_epi16(b3, b7);                 /* [ 16 36 56 76 17 37 57 77 ]*/

		vx[0] = _mm_unpacklo_epi16(a0, a4);          /* [ 00 10 20 30 40 50 60 70 ]*/
		vx[1] = _mm_unpackhi_epi16(a0, a4);          /* [ 01 11 21 31 41 51 61 71 ]*/
		vx[2] = _mm_unpacklo_epi16(a1, a5);          /* [ 02 12 22 32 42 52 62 72 ]*/
		vx[3] = _mm_unpackhi_epi16(a1, a5);          /* [ 03 13 23 33 43 53 63 73 ]*/
		vx[4] = _mm_unpacklo_epi16(a2, a6);          /* [ 04 14 24 34 44 54 64 74 ]*/
		vx[5] = _mm_unpackhi_epi16(a2, a6);          /* [ 05 15 25 35 45 55 65 75 ]*/
		vx[6] = _mm_unpacklo_epi16(a3, a7);          /* [ 06 16 26 36 46 56 66 76 ]*/
		vx[7] = _mm_unpackhi_epi16(a3, a7);          /* [ 07 17 27 37 47 57 67 77 ]*/

	}

	{
		// Transform

		t8 = _mm_adds_epi16(vx[0], vx[7]);
		t9 = _mm_subs_epi16(vx[0], vx[7]);
		t0 = _mm_adds_epi16(vx[1], vx[6]);
		t7 = _mm_subs_epi16(vx[1], vx[6]);
		t1 = _mm_adds_epi16(vx[2], vx[5]);
		t6 = _mm_subs_epi16(vx[2], vx[5]);
		t2 = _mm_adds_epi16(vx[3], vx[4]);
		t5 = _mm_subs_epi16(vx[3], vx[4]);

		t3 = _mm_adds_epi16(t8, t2);
		t4 = _mm_subs_epi16(t8, t2);
		t2 = _mm_adds_epi16(t0, t1);
		t8 = _mm_subs_epi16(t0, t1);

		t1 = _mm_adds_epi16(t7, t6);
		t0 = _mm_subs_epi16(t7, t6);

		vy[0] = _mm_adds_epi16(t3, t2);
		vy[4] = _mm_subs_epi16(t3, t2);

		vy[2] = _mm_mradds_epi16(t8, *((__m128i*)(&c13573)), t4);
		t10 = _mm_mr_epi16(t4, *((__m128i*)(&c13573)), *((__m128i*)(&c)));

		vy[6] = _mm_subs_epi16(t10, t8);

		t6 = _mm_mradds_epi16(t0, *((__m128i*)(&c23170)), t5);
		t7 = _mm_mradds_epi16(t0, *((__m128i*)(&cNeg23170)), t5);
		t2 = _mm_mradds_epi16(t1, *((__m128i*)(&cNeg23170)), t9);
		t3 = _mm_mradds_epi16(t1, *((__m128i*)(&c23170)), t9);

		vy[1] = _mm_mradds_epi16(t6, *((__m128i*)(&c6518)), t3);
		t9 = _mm_mr_epi16(t3, *((__m128i*)(&c6518)), *((__m128i*)(&c)));

		vy[7] = _mm_subs_epi16(t9, t6);
		vy[5] = _mm_mradds_epi16(t2, *((__m128i*)(&c21895)), t7);
		vy[3] = _mm_mradds_epi16(t7, *((__m128i*)(&cNeg21895)), t2);

	}

	{
		volatile __m128i *PostScalev = (__m128i*)&PostScaleArray;
		__m128i *v = (__m128i*) output;
		{
			static const int32_t i = 0;
			__m128i t = _mm_loadu_si128((const __m128i *)(&PostScalev[i]));
			_mm_storeu_si128((__m128i *)(&v[i]), _mm_mradds_epi16(t, vy[i], _mm_set1_epi16(0)));
		}
		{
			static const int32_t i = 1;
			__m128i t = _mm_loadu_si128((const __m128i *)(&PostScalev[i]));
			_mm_storeu_si128((__m128i *)(&v[i]), _mm_mradds_epi16(t, vy[i], _mm_set1_epi16(0)));
		}
		{
			static const int32_t i = 2;
			__m128i t = _mm_loadu_si128((const __m128i *)(&PostScalev[i]));
			_mm_storeu_si128((__m128i *)(&v[i]), _mm_mradds_epi16(t, vy[i], _mm_set1_epi16(0)));
		}
		{
			static const int32_t i = 3;
			__m128i t = _mm_loadu_si128((const __m128i *)(&PostScalev[i]));
			_mm_storeu_si128((__m128i *)(&v[i]), _mm_mradds_epi16(t, vy[i], _mm_set1_epi16(0)));
		}
		{
			static const int32_t i = 4;
			__m128i t = _mm_loadu_si128((const __m128i *)(&PostScalev[i]));
			_mm_storeu_si128((__m128i *)(&v[i]), _mm_mradds_epi16(t, vy[i], _mm_set1_epi16(0)));
		}
		{
			static const int32_t i = 5;
			__m128i t = _mm_loadu_si128((const __m128i *)(&PostScalev[i]));
			_mm_storeu_si128((__m128i *)(&v[i]), _mm_mradds_epi16(t, vy[i], _mm_set1_epi16(0)));
		}
		{
			static const int32_t i = 6;
			__m128i t = _mm_loadu_si128((const __m128i *)(&PostScalev[i]));
			_mm_storeu_si128((__m128i *)(&v[i]), _mm_mradds_epi16(t, vy[i], _mm_set1_epi16(0)));
		}
		{
			static const int32_t i = 7;
			__m128i t = _mm_loadu_si128((const __m128i *)(&PostScalev[i]));
			_mm_storeu_si128((__m128i *)(&v[i]), _mm_mradds_epi16(t, vy[i], _mm_set1_epi16(0)));
		}
	}

}
