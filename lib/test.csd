<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
; ==============================================
<CsInstruments>

sr	=	48000
ksmps	=	1
nchnls	=	2
0dbfs	=	1

instr 1	

    ao = oscili(0.3, 400)

    outs ao,ao
endin

</CsInstruments>
; ==============================================
<CsScore>

i 1 0 5



</CsScore>
</CsoundSynthesizer>

