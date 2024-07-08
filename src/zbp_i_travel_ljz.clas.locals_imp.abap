CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF z_i_travel_ljz
    IN LOCAL MODE
    ENTITY travel
    FIELDS ( TravelId OverallStatus )
    WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
    RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result (
                %key                 = ls_Travel-%key
                %field-TravelId      = if_abap_behv=>fc-f-read_only
                %field-OverallStatus = if_abap_behv=>fc-f-read_only
                %assoc-_Booking      = if_abap_behv=>fc-o-enabled
                %action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
                %action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.


    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name(  ) EQ 'CB9980000874'
                                THEN if_abap_behv=>auth-allowed
                                ELSE if_abap_behv=>auth-unauthorized ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result> = VALUE #(  %key = <ls_keys>-%key
                              %op-%update = lv_auth
                              %op-%delete = lv_auth
                              %action-acceptTravel = lv_auth
                              %action-rejectTravel = lv_auth
                              %action-createTravelByTemplate = lv_auth
                              %assoc-_Booking = lv_auth ).

    ENDLOOP.


  ENDMETHOD.


  METHOD createTravelByTemplate.

*    keys[ 1 ]
*    result[ 1 ]
*    mapped-
*    failed-
*    reported-

*    READ ENTITY z_i_Travel_ljz
*    FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
*    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
*    RESULT DATA(lt_read_entity_travel)
*    FAILED failed
*    REPORTED reported.


    READ ENTITIES OF z_i_Travel_ljz
    IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
    RESULT DATA(lt_entity_travel)
    FAILED failed
    REPORTED reported.

    DATA lt_create_travel TYPE TABLE FOR CREATE z_i_travel_ljz\\Travel.

    SELECT MAX( travel_id )
    FROM ztravel_ljz
    INTO @DATA(lv_travel_id).

    DATA(lv_today) = cl_abap_context_info=>get_system_date(  ).

    lt_create_travel = VALUE #(
                                FOR create_row IN lt_entity_travel INDEX INTO idx
                                    ( TravelId      = lv_travel_id + idx
                                      AgencyId      = create_row-AgencyId
                                      CustomerId    = create_row-CustomerId
                                      BeginDate     = lv_today
                                      EndDate       = lv_today + 30
                                      BookingFee    = create_row-BookingFee
                                      TotalPrice    = create_row-TotalPrice
                                      CurrencyCode  = create_row-CurrencyCode
                                      Description   = 'Add Comments'
                                      OverallStatus = 'O'
                                    )
                              ).

    MODIFY ENTITIES OF z_i_travel_ljz
    IN LOCAL MODE
    ENTITY Travel
    CREATE FIELDS (
                    TravelId
                    AgencyId
                    CustomerId
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
                    CurrencyCode
                    Description
                    OverallStatus )
    WITH lt_create_travel
    MAPPED mapped
    FAILED failed
    REPORTED reported.

    result = VALUE #( FOR result_row IN lt_create_Travel INDEX INTO idx
                        (
                            %cid_ref = keys[ idx ]-%cid_ref
                            %key     = keys[ idx ]-%key
                            %param   = CORRESPONDING #( result_row )
                        )
                    ).
  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF z_i_travel_ljz
    IN LOCAL MODE "BO - related updates there are not relevant for authorization objects
    ENTITY travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #(
                    FOR key_row IN keys
                    (
                        TravelId      = key_row-TravelId
                        OverallStatus = 'A' "Accepted
                    )
                )
    FAILED failed
    REPORTED reported. "en caso de algun error


    READ ENTITIES OF z_i_travel_ljz
    IN LOCAL MODE
    ENTITY travel
    FIELDS (
             AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             Description
             OverallStatus
             CreatedAt
             CreatedBy
             LastChangedAt
             LastChangedBy
            )
     WITH VALUE #(
        FOR key_row IN keys (
            TravelId = key_row-TravelId
        )
     )
     RESULT DATA(lt_travel).


    RESult = VALUE #(
                       FOR ls_travel IN lt_travel (
                           TravelId = ls_travel-TravelId
                           %param   = ls_travel

                       )
    ).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).


      DATA(lv_travel_msg) = <ls_travel>-TravelId.

      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( travelid = <ls_travel>-TravelId
                    %msg    = new_message( id = 'Z_MC_TRAVEL_LJZ'
                                            number = '005'
                                            v1 = lv_travel_msg
                                            severity = if_abap_behv_message=>severity-success )
*                   %element-customerid = if_abap_behv=>mk-on
                ) TO reported-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF z_i_travel_ljz
    IN LOCAL MODE "BO - related updates there are not relevant for authorization objects
    ENTITY travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #(
                    FOR key_row IN keys
                    (
                        TravelId      = key_row-TravelId
                        OverallStatus = 'X' "Rejected
                    )
                )
    FAILED failed
    REPORTED reported. "en caso de algun error


    READ ENTITIES OF z_i_travel_ljz
    IN LOCAL MODE
    ENTITY travel
    FIELDS (
             AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             Description
             OverallStatus
             CreatedAt
             CreatedBy
             LastChangedAt
             LastChangedBy
            )
     WITH VALUE #(
        FOR key_row IN keys (
            TravelId = key_row-TravelId
        )
     )
     RESULT DATA(lt_travel).


    RESult = VALUE #(
                       FOR ls_travel IN lt_travel (
                           TravelId = ls_travel-TravelId
                           %param   = ls_travel

                       )
    ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).


      DATA(lv_travel_msg) = <ls_travel>-TravelId.

      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( travelid = <ls_travel>-TravelId
                    %msg    = new_message( id = 'Z_MC_TRAVEL_LJZ'
                                            number = '006'
                                            v1 = lv_travel_msg
                                            severity = if_abap_behv_message=>severity-success )
*                   %element-customerid = if_abap_behv=>mk-on
                ) TO reported-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF z_i_travel_ljz
    IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).

    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer
    FIELDS customer_id
    FOR ALL ENTRIES IN @lt_customer
    WHERE customer_id EQ @lt_customer-customer_id
    INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF  <ls_travel>-CustomerId IS INITIAL OR NOT line_exists( lt_customer_db[ customer_id = <ls_travel>-CustomerId ] ).

        APPEND VALUE #( travelid = <ls_travel>-TravelId ) TO failed-travel.

        APPEND VALUE #( travelid = <ls_travel>-TravelId
                        %msg    = new_message( id = 'Z_MC_TRAVEL_LJZ'
                                                number = '001'
                                                v1 = <ls_travel>-TravelId
                                                severity = if_abap_behv_message=>severity-error )
                        %element-customerid = if_abap_behv=>mk-on
                    ) TO reported-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.


    READ ENTITY z_i_travel_ljz\\Travel
       FIELDS ( BeginDate EndDate )
       WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
       RESULT DATA(lt_travel_result).


    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      IF ls_travel_result-enddate LT ls_travel_result-begindate.  "end_date before begin_date

        APPEND VALUE #( %key = ls_travel_result-%key
                        travelid = ls_travel_result-travelid ) TO failed-travel.

        APPEND VALUE #( %key      = ls_travel_result-%key
                        %msg      = new_message( id       = 'Z_MC_TRAVEL_LJZ'
                                                 number   =  '002'
                                                 v1       = ls_travel_result-begindate
                                                 v2       = ls_travel_result-enddate
                                                 v3       = ls_travel_result-travelid
                                                 severity = if_abap_behv_message=>severity-error )

                       %element-begindate = if_abap_behv=>mk-on
                       %element-enddate = if_abap_behv=>mk-on )
            TO reported-travel.

      ELSEIF ls_travel_result-begindate < cl_abap_context_info=>get_system_date( ).  "begin_date must be in the future.

        APPEND VALUE #( %key = ls_travel_result-%key
                    travelid = ls_travel_result-travelid ) TO failed-travel.

        APPEND VALUE #( %key      = ls_travel_result-%key
                        %msg      = new_message( id       = 'Z_MC_TRAVEL_LJZ'
                                             number   =  '003'
                                             severity = if_abap_behv_message=>severity-error )

                   %element-begindate = if_abap_behv=>mk-on
                   %element-enddate = if_abap_behv=>mk-on )
        TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY z_i_travel_ljz\\Travel
         FIELDS ( OverallStatus )
         WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
         RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      CASE ls_travel_result-overallstatus.

        WHEN 'O'.  " Open
        WHEN 'X'.  " Cancelled
        WHEN 'A'.  " Accepted
        WHEN OTHERS.

          APPEND VALUE #( %key = ls_travel_result-%key )
             TO failed-travel.

          APPEND VALUE #( %key = ls_travel_result-%key
                          %msg = new_message( id       = 'Z_MC_TRAVEL_LJZ'
                                              number   =  '004'
                                              v1       = ls_travel_result-overallstatus
                                              severity = if_abap_behv_message=>severity-error )

                %element-overallstatus = if_abap_behv=>mk-on )
     TO reported-travel.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_LJZ DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.

    CONSTANTS: create TYPE string VALUE 'CREATE',
               update TYPE string VALUE 'UPDATE',
               delete TYPE string VALUE 'DELETE'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_LJZ IMPLEMENTATION.

  METHOD save_modified.

*    DATA: lt_travel_log   TYPE STANDARD TABLE OF zlog_ljz,
*          lt_travel_log_u TYPE STANDARD TABLE OF zlog_ljz.
*
*    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
*
*
*    IF NOT create-travel IS INITIAL.
*
*      lt_travel_log = CORRESPONDING #( create-travel ).
*
*      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).
*
*        GET TIME STAMP FIELD <ls_travel_log>-created_at.
*        <ls_travel_log>-changing_operation = lsc_Z_I_TRAVEL_LJZ=>create.
*
*        READ TABLE create-travel WITH TABLE KEY entity
*            COMPONENTS travelid = <ls_travel_log>-travel_id
*            INTO DATA(ls_travel).
*
*        IF sy-subrc EQ 0.
*          IF ls_travel-%control-bookingfee EQ cl_abap_behv=>flag_changed.
*            <ls_travel_log>-changed_field_name = 'booking_fee'.
*            <ls_travel_log>-changed_value = ls_travel-bookingfee.
*            <ls_travel_log>-user_mod = lv_user.
*            TRY.
*                <ls_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
*              CATCH cx_uuid_error.
*            ENDTRY.
*            APPEND <ls_travel_log> TO lt_travel_log_u.
*          ENDIF.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*
*    IF NOT update-travel IS INITIAL.
*
*     "CAMBIAR EL CORRESPONDING
*      lt_travel_log = CORRESPONDING #( update-travel ).
*      LOOP AT update-travel INTO DATA(ls_update_travel).
*        ASSIGN lt_travel_log[ travel_id = ls_update_travel-travelid ] TO FIELD-SYMBOL(<ls_travel_log_bd>).
*        GET TIME STAMP FIELD <ls_travel_log_bd>-created_at.
*        <ls_travel_log_bd>-changing_operation = lsc_Z_I_TRAVEL_LJZ=>update.
*
*        IF ls_update_travel-%control-customerid EQ cl_abap_behv=>flag_changed.
*          <ls_travel_log_bd>-changed_field_name = 'customer_id'.
*          <ls_travel_log_bd>-changed_value = ls_update_travel-customerid.
*          <ls_travel_log_bd>-user_mod = lv_user.
*          TRY.
*              <ls_travel_log_bd>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
*            CATCH cx_uuid_error.
*          ENDTRY.
*          APPEND <ls_travel_log_bd> TO lt_travel_log_u.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*
*    IF NOT delete-travel IS INITIAL.
*      lt_travel_log = CORRESPONDING #( delete-travel ).
*      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log_del>).
*        GET TIME STAMP FIELD <ls_travel_log_del>-created_at.
*        <ls_travel_log_del>-changing_operation = lsc_Z_I_TRAVEL_LJZ=>delete.
*        <ls_travel_log_del>-user_mod = lv_user.
*        TRY.
*            <ls_travel_log_del>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
*          CATCH cx_uuid_error.
*        ENDTRY.
*        APPEND <ls_travel_log_del> TO lt_travel_log_u.
*      ENDLOOP.
*    ENDIF.
*
*
*    IF NOT lt_travel_log_u IS INITIAL.
*      INSERT zlog_ljz FROM TABLE @lt_travel_log_u.
*    ENDIF.
*
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
