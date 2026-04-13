CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  " 1. PUBLIC SECTION: Buffers must be public so the Saver class can read them.
  PUBLIC SECTION.
    TYPES: tt_booking TYPE STANDARD TABLE OF ztaxi_book WITH DEFAULT KEY.
    CLASS-DATA: mt_buffer_create TYPE tt_booking,
                mt_buffer_update TYPE tt_booking,
                mt_buffer_delete TYPE tt_booking.

  " 2. PRIVATE SECTION: Method definitions required by the RAP framework.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Booking RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Booking.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Booking.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Booking.

    " The lock method definition to prevent the CX_RAP_HANDLER_NOT_IMPLEMENTED dump
    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Booking.
ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.
  METHOD get_instance_authorizations.
    " Left empty because we commented out the authorization check in the BDEF
  ENDMETHOD.

  METHOD create.
    LOOP AT entities INTO DATA(ls_entity).
      " Move data to our temporary create buffer
      APPEND VALUE #(
        booking_id     = ls_entity-BookingId
        passenger_name = ls_entity-PassengerName
        pickup_loc     = ls_entity-PickupLoc
        drop_loc       = ls_entity-DropLoc
        fare           = ls_entity-Fare
        currency       = ls_entity-Currency
        status         = ls_entity-Status
      ) TO mt_buffer_create.

      " Tell the framework the record was mapped successfully
      INSERT VALUE #( %cid = ls_entity-%cid  BookingId = ls_entity-BookingId ) INTO TABLE mapped-booking.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(ls_entity).
      " Move data to our temporary update buffer
      APPEND VALUE #(
        booking_id     = ls_entity-BookingId
        passenger_name = ls_entity-PassengerName
        pickup_loc     = ls_entity-PickupLoc
        drop_loc       = ls_entity-DropLoc
        fare           = ls_entity-Fare
        currency       = ls_entity-Currency
        status         = ls_entity-Status
      ) TO mt_buffer_update.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      " Move the key to our temporary delete buffer
      APPEND VALUE #( booking_id = ls_key-BookingId ) TO mt_buffer_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    " Left empty to satisfy the 'lock master' requirement for testing.
    " In production, you would call an ENQUEUE function module here.
  ENDMETHOD.
ENDCLASS.

" --- THE SAVER CLASS ---

CLASS lsc_ZR_TAXI_BOOK DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
ENDCLASS.

CLASS lsc_ZR_TAXI_BOOK IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    " Commit the buffers to the physical database table
    IF lhc_Booking=>mt_buffer_create IS NOT INITIAL.
      INSERT ztaxi_book FROM TABLE @lhc_Booking=>mt_buffer_create.
    ENDIF.

    IF lhc_Booking=>mt_buffer_update IS NOT INITIAL.
      UPDATE ztaxi_book FROM TABLE @lhc_Booking=>mt_buffer_update.
    ENDIF.

    IF lhc_Booking=>mt_buffer_delete IS NOT INITIAL.
      DELETE ztaxi_book FROM TABLE @lhc_Booking=>mt_buffer_delete.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    " Clear the buffers so old data doesn't accidentally save twice
    CLEAR lhc_Booking=>mt_buffer_create.
    CLEAR lhc_Booking=>mt_buffer_update.
    CLEAR lhc_Booking=>mt_buffer_delete.
  ENDMETHOD.
ENDCLASS.
