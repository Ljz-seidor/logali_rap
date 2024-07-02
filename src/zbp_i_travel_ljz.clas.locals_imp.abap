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
                %action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
                %action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
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
    CREATE FIELDS ( AgencyId
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
    CREATE FIELDS ( OverallStatus )
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

  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF z_i_travel_ljz
    IN LOCAL MODE "BO - related updates there are not relevant for authorization objects
    ENTITY travel
    CREATE FIELDS ( OverallStatus )
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

  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateDates.
  ENDMETHOD.

  METHOD validateStatus.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_LJZ DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_LJZ IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
