; #FUNCTION# ====================================================================================================================
; Author ........: SmOke_N
; ===============================================================================================================================
Func _ArrayRandomShuffle($av_array, $i_lbound = 0)
    Local $i_ubound = UBound($av_array) - 1
    Local $icc, $s_temp, $i_random
    
    For $icc = $i_lbound To $i_ubound
        $s_temp = $av_array[$icc]
        $i_random = Random($i_lbound, $i_ubound, 1)
        $av_array[$icc] = $av_array[$i_random]
        $av_array[$i_random] = $s_temp
    Next
    
    Return $av_array
EndFunc