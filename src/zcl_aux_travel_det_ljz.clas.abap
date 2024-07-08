CLASS zcl_aux_travel_det_ljz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_travel_reported      TYPE TABLE FOR REPORTED z_i_travel_ljz,
           tt_booking_reported     TYPE TABLE FOR REPORTED z_i_booking_ljz,
           tt_supplements_reported TYPE TABLE FOR REPORTED z_i_booksuppl_ljz.


    TYPES: tt_travel_id TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS calculate_price IMPORTING it_travel_id TYPE tt_travel_id.
*                                  EXPORTING et_travel_reported TYPE tt_travel_reported.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_aux_travel_det_ljz IMPLEMENTATION.
  METHOD calculate_price.

    DATA: lv_total_booking_price TYPE /dmo/total_price,
          lv_total_suppl_price   TYPE /dmo/total_price.

    IF it_travel_id IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF z_i_travel_ljz
         ENTITY Travel
         FIELDS ( travelid currencycode )
         WITH VALUE #( FOR lv_travel_id IN it_travel_id (
                           travelid = lv_travel_id ) )
         RESULT DATA(lt_read_travel).

    READ ENTITIES OF z_i_travel_ljz
     ENTITY Travel BY \_Booking
     FROM VALUE #( FOR lv_travel_id IN it_travel_id (
                       travelid = lv_travel_id
                       %control-flightprice   = if_abap_behv=>mk-on
                       %control-currencycode  = if_abap_behv=>mk-on  )
                    ) RESULT DATA(lt_read_booking).

    LOOP AT lt_read_booking INTO DATA(ls_booking)
        GROUP BY ls_booking-travelid INTO DATA(lv_travel_key).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS travelid = lv_travel_key ] TO FIELD-SYMBOL(<ls_travel>).

      LOOP AT GROUP lv_travel_key INTO DATA(ls_booking_result)
        GROUP BY ls_booking_result-currencycode INTO DATA(lv_curr).

        lv_total_booking_price = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_booking_line).
          lv_total_booking_price += ls_booking_line-flightprice.
        ENDLOOP.

        IF lv_curr EQ <ls_travel>-currencycode.
          <ls_travel>-totalprice += lv_total_booking_price.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                  iv_amount               =  lv_total_booking_price
                  iv_currency_code_source = lv_curr
                  iv_currency_code_target = <ls_travel>-currencycode
                  iv_exchange_rate_date   = cl_abap_context_info=>get_system_date(  )
              IMPORTING
                  ev_amount               =  DATA(lv_amount_converted) ).

          <ls_travel>-totalprice +=  lv_amount_converted.

        ENDIF.
      ENDLOOP.
    ENDLOOP.

    READ ENTITIES OF z_i_travel_ljz
     ENTITY Booking BY \_BookingSupplement
     FROM VALUE #( FOR ls_travel IN lt_read_booking (
                       travelid         = ls_travel-travelid
                       bookingid        = ls_travel-bookingid
                       %control-price    = if_abap_behv=>mk-on         "Si hubo algun cambio en el precio
                       %control-CurrencyCode = if_abap_behv=>mk-on ) ) "Si hubo algun cambio en la moneda
                       RESULT DATA(lt_read_supplements).

    LOOP AT lt_read_supplements INTO DATA(ls_booking_suppl)
        GROUP BY ls_booking_suppl-travelid INTO lv_travel_key.

      ASSIGN lt_read_travel[ KEY entity COMPONENTS travelid = lv_travel_key ] TO <ls_travel>.

      LOOP AT GROUP lv_travel_key INTO DATA(ls_supplements_result)
          GROUP BY ls_supplements_result-CurrencyCode INTO lv_curr.

        lv_total_suppl_price = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_supplement_line).
          lv_total_suppl_price += ls_supplement_line-price.
        ENDLOOP.

        IF lv_curr EQ <ls_travel>-currencycode.
          <ls_travel>-totalprice += lv_total_suppl_price.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
          EXPORTING
              iv_amount               =  lv_total_suppl_price
              iv_currency_code_source = lv_curr
              iv_currency_code_target = <ls_travel>-currencycode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date(  )
          IMPORTING
              ev_amount               =  lv_amount_converted ).

          <ls_travel>-totalprice +=  lv_amount_converted.

        ENDIF.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF z_i_travel_ljz
       ENTITY Travel
           UPDATE FROM VALUE #( FOR ls_travel_bo IN lt_read_travel (
                                    travelid = ls_travel_bo-travelid
                                    totalprice = ls_travel_bo-totalprice
                                    %control-totalprice = if_abap_behv=>mk-on ) "indicamos que el valor ha sido modificado
                              ).

  ENDMETHOD.

ENDCLASS.
