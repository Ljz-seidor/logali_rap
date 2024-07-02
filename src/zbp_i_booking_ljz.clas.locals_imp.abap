CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateFlightPrice.
  ENDMETHOD.

  METHOD validateStatus.
  ENDMETHOD.

ENDCLASS.
