CLASS zcl_virt_elem_ljz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_virt_elem_ljz IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  "Se ejecuta primero este metodo

    IF iv_entity = 'Z_C_TRAVEL_LJZ'.

        LOOP AT it_requested_calc_elements INTO data(ls_calc_elements).

           if  ls_calc_elements = 'DISCOUNTPRICE'.
            APPEND 'TOTALPRICE' to et_requested_orig_elements.  "Elementos que voy a usar en el metodo "calculate"
           ENDIF.

        ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.
  "Luego este

    DATA lt_original_data TYPE STANDARD TABLE OF z_c_travel_ljz WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<ls_original_data>).
        <ls_original_data>-DiscountPrice = <ls_original_data>-TotalPrice - ( <ls_original_data>-TotalPrice * ( 1 / 10 ) ).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.



ENDCLASS.
