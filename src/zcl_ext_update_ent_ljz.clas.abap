CLASS zcl_ext_update_ent_ljz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_update_ent_ljz IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF z_i_travel_ljz
    ENTITY Travel
    UPDATE FIELDS ( AgencyId Description )
    WITH VALUE #( ( TravelId = '00000005'
                    AgencyId = 000138
                    Description = 'De 225 a 138') )
    FAILED DATA(failed)
    REPORTED DATA(reported).

    READ ENTITIES OF z_i_travel_ljz
    ENTITY Travel
    FIELDS ( AgencyId Description )
        WITH VALUE #( ( TravelId = '00000005' ) )
        RESULT DATA(lt_travel_data)
        FAILED failed
        REPORTED reported.

    COMMIT ENTITIES. "Se maneja manualmente xq estamos fuera del behavor

    IF failed IS INITIAL.
      out->write( 'Commit Succesfull' ).
    ELSE.
      out->write( 'Commit Failed' ).

    ENDIF.
  ENDMETHOD.

ENDCLASS.
