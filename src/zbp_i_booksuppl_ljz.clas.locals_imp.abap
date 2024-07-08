CLASS lhc_Supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalSupplPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~calculateTotalSupplPrice.

ENDCLASS.

CLASS lhc_Supplement IMPLEMENTATION.

  METHOD calculateTotalSupplPrice.

    IF NOT keys IS INITIAL.

      zcl_aux_travel_det_ljz=>calculate_price( it_travel_id = VALUE #( FOR GROUPS <suppl> OF booking_key IN keys
                                                                       GROUP BY booking_key-travelid WITHOUT MEMBERS ( <suppl> ) ) ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_supplement DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PUBLIC SECTION.

    CONSTANTS: create TYPE string VALUE 'C',
               update TYPE string VALUE 'U',
               delete TYPE string VALUE 'D'.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_supplement IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_supplements TYPE STANDARD TABLE OF zbooksuppl_ljz,
          lv_op_type     TYPE zde_flag,
          lv_updated     TYPE zde_flag.

    IF NOT create-supplement IS INITIAL.

      LOOP AT create-supplement INTO DATA(ls_create_suppl).

        APPEND INITIAL LINE TO lt_supplements ASSIGNING FIELD-SYMBOL(<fs_supplements>).
        <fs_supplements>-travel_id              = ls_create_suppl-TravelId.
        <fs_supplements>-booking_id             = ls_create_suppl-BookingId.
        <fs_supplements>-booking_supplement_id  = ls_create_suppl-BookingSupplementId.
        <fs_supplements>-supplement_id          = ls_create_suppl-SupplementId.
        <fs_supplements>-booking_supplement_id  = ls_create_suppl-BookingSupplementId.
        <fs_supplements>-price                  = ls_create_suppl-Price.
        <fs_supplements>-currency_code          = ls_create_suppl-CurrencyCode.
        <fs_supplements>-last_changed_at        = ls_create_suppl-LastChangedAt.

      ENDLOOP.

*      lt_supplements = CORRESPONDING #( create-supplement ).
      lv_op_type = lsc_supplement=>create.
    ENDIF.

    IF NOT update-supplement IS INITIAL.

      LOOP AT update-supplement INTO DATA(ls_update_suppl).

        APPEND INITIAL LINE TO lt_supplements ASSIGNING <fs_supplements>.
        <fs_supplements>-travel_id              = ls_update_suppl-TravelId.
        <fs_supplements>-booking_id             = ls_update_suppl-BookingId.
        <fs_supplements>-booking_supplement_id  = ls_update_suppl-BookingSupplementId.
        <fs_supplements>-supplement_id          = ls_update_suppl-SupplementId.
        <fs_supplements>-booking_supplement_id  = ls_update_suppl-BookingSupplementId.
        <fs_supplements>-price                  = ls_update_suppl-Price.
        <fs_supplements>-currency_code          = ls_update_suppl-CurrencyCode.
        <fs_supplements>-last_changed_at        = ls_update_suppl-LastChangedAt.

      ENDLOOP.

*      lt_supplements = CORRESPONDING #( update-supplement ).
      lv_op_type = lsc_supplement=>update.
    ENDIF.

    IF NOT delete-supplement IS INITIAL.


      LOOP AT delete-supplement INTO DATA(ls_delete_suppl).

        APPEND INITIAL LINE TO lt_supplements ASSIGNING <fs_supplements>.
        <fs_supplements>-travel_id              = ls_delete_suppl-TravelId.
        <fs_supplements>-booking_id             = ls_delete_suppl-BookingId.
        <fs_supplements>-booking_supplement_id  = ls_delete_suppl-BookingSupplementId.
        <fs_supplements>-booking_supplement_id  = ls_delete_suppl-BookingSupplementId.


      ENDLOOP.
*      lt_supplements = CORRESPONDING #( delete-supplement ).

      lv_op_type = lsc_supplement=>delete.
    ENDIF.

    IF NOT lt_supplements IS INITIAL.

      CALL FUNCTION 'Z_SUPPL_LJZ'
        EXPORTING
          it_supplements = lt_supplements
          iv_op_type     = lv_op_type
        IMPORTING
          ev_updated     = lv_updated.

    ENDIF.

    IF lv_updated EQ abap_true.
*reported-supplement
    ENDIF.


  ENDMETHOD.

ENDCLASS.
