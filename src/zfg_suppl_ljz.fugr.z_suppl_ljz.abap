FUNCTION z_suppl_ljz.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPLEMENTS) TYPE  ZTT_SUPPL_LJZ
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG_LJZ
*"  EXPORTING
*"     REFERENCE(EV_UPDATED) TYPE  ZDE_FLAG_LJZ
*"----------------------------------------------------------------------
    CHECK it_supplements IS NOT INITIAL.

    CASE iv_op_type.

        WHEN 'C'.
            insert zbooksuppl_ljz FROM TABLE @it_supplements.
        WHEN 'U'.
            update zbooksuppl_ljz FROM TABLE @it_supplements.
        WHEN 'D'.
            delete zbooksuppl_ljz FROM TABLE @it_supplements.
    ENDCASE.

    IF sy-subrc EQ 0.
        ev_updated = abap_true.
    ENDIF.

ENDFUNCTION.
