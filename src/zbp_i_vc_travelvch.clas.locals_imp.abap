CLASS lsc_zi_vc_travel_vch DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zi_vc_travel_vch IMPLEMENTATION.

  METHOD adjust_numbers.
    DATA : travel_id_max TYPE /dmo/travel_id.

    IF mapped-zi_vc_travel_vch IS NOT INITIAL.
      TRY.
          cl_numberrange_runtime=>number_get(
                 EXPORTING
                    nr_range_nr = '01'
                    object = '/DMO/TRV_M'
                    quantity = CONV #( lines( mapped-zi_vc_travel_vch ) )
                 IMPORTING
                    number = DATA(number_range_key)
                    returncode = DATA(number_range_return_code)
                    returned_quantity = DATA(number_range_returned_quantity) ).
**
        CATCH cx_number_ranges INTO DATA(lx_number_ranges).
          RAISE SHORTDUMP TYPE cx_number_ranges
            EXPORTING
              previous = lx_number_ranges.
      ENDTRY.

      ASSERT number_range_returned_quantity = lines( mapped-zi_vc_travel_vch ).
      travel_id_max = number_range_key - number_range_returned_quantity.
      LOOP AT mapped-zi_vc_travel_vch ASSIGNING FIELD-SYMBOL(<travel>).
        travel_id_max += 1.
        <travel>-TravelId = travel_id_max.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_VC_TRAVEL_VCH DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    "METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
    " IMPORTING keys REQUEST requested_authorizations FOR zi_vc_travel_vch RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_vc_travel_vch RESULT result.

    METHODS newtotal FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_vc_travel_vch~newtotal.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_vc_travel_vch RESULT result.

    METHODS validateBookingFee FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_vc_travel_vch~validateBookingFee.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_vc_travel_vch~validateDates.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_vc_travel_vch~acceptTravel RESULT result.

    "METHODS earlynumbering_create FOR NUMBERING
    "  IMPORTING entities FOR CREATE zi_vc_travel_vch.

ENDCLASS.

CLASS lhc_ZI_VC_TRAVEL_VCH IMPLEMENTATION.

  "METHOD get_instance_authorizations.
  "ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD newtotal.
*  READ ENTITIES OF zi_vc_travel_vch IN LOCAL MODE reads the specified travel entity records f
*  from the RAP transactional buffer (local memory),
*  including any unsaved changes made in the current transaction.
    READ ENTITIES OF zi_vc_travel_vch IN LOCAL MODE
    ENTITY zi_vc_travel_vch
    FIELDS (  BookingFee CurrencyCode ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    " This statement reads the associated Booking entity records (_Booking) for the selected travel records
    " from the RAP transactional buffer,
    " retrieves the FlightPrice and CurrencyCode fields, and stores the results in the internal table bookings.

    READ ENTITIES OF zi_vc_travel_vch IN LOCAL MODE
     ENTITY zi_vc_travel_vch BY \_Booking
     FIELDS ( FlightPrice CurrencyCode ) WITH CORRESPONDING #( travels )
     RESULT DATA(bookings).

    "This statement reads the associated Booking Supplement (_Bookingsuppl) entity records for the selected booking
    "records from the RAP transactional buffer, retrieves the Price and CurrencyCode fields,
    "and stores the results in the internal table booksuppls.
    READ ENTITIES OF zi_vc_travel_vch IN LOCAL MODE
      ENTITY zi_booking_vch BY \_Bookingsuppl
      FIELDS ( Price CurrencyCode ) WITH CORRESPONDING #( bookings )
      RESULT DATA(booksuppls).

    " This loop iterates through each travel record and initializes the TotalPrice field with the value of the BookingFee.
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travels>).
      <travels>-TotalPrice = <travels>-BookingFee .

      " This loop processes each booking belonging to the travel, c
      " converts the FlightPrice into the travel currency when required, and adds the converted amount to the travel's TotalPrice.
      " /dmo/cl_flight_amdp=>convert_currency is an AMDP method used to convert an amount from one currency to another using the exchange rate valid on a specified date.
      "It takes the booking amount, source currency,
      "target currency, and exchange rate date as input parameters and returns the converted
      "amount in the target currency through ev_amount.
      "In this logic, it ensures that booking prices with different currencies are
      "converted into the travel currency before adding them to the TotalPrice.
      LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>) USING KEY entity
         WHERE TravelId = <travels>-TravelId AND CurrencyCode IS NOT INITIAL.
        DATA(lv_amount) = <booking>-FlightPrice.
        IF <booking>-CurrencyCode <> <travels>-CurrencyCode.
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = <booking>-FlightPrice
              iv_currency_code_source = <booking>-CurrencyCode
              iv_currency_code_target = <travels>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = lv_amount ).
        ENDIF.
        <travels>-TotalPrice += lv_amount.

        " This loop processes each booking supplement associated with the booking
        "and checks whether the supplement price is maintained in the same currency as the travel.
        "If the supplement currency differs, /dmo/cl_flight_amdp=>convert_currency
        "is called to convert the supplement Price into the travel currency using the current system date's exchange rate.
        "After conversion (if required), the supplement amount is added to the travel's TotalPrice to calculate the final accumulated travel cost.
        LOOP AT booksuppls ASSIGNING FIELD-SYMBOL(<booksuppl>) USING KEY entity
            WHERE TravelId = <booking>-TravelId
              AND BookingId = <booking>-BookingId
              AND CurrencyCode IS NOT INITIAL.
          lv_amount = <booksuppl>-Price.
          IF <booksuppl>-CurrencyCode <> <travels>-CurrencyCode.
            /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                iv_amount               = <booksuppl>-Price
                iv_currency_code_source = <booksuppl>-CurrencyCode
                iv_currency_code_target = <travels>-CurrencyCode
                iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
              IMPORTING
                ev_amount               = lv_amount ).
          ENDIF.
          <travels>-TotalPrice += lv_amount.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

* It updates the TotalPrice field of Travel entities in RAP
* using the internal table travels in local mode without immediate database commit.
    MODIFY ENTITIES OF zi_vc_travel_vch IN LOCAL MODE
      ENTITY zi_vc_travel_vch
      UPDATE FIELDS ( TotalPrice )
      WITH CORRESPONDING #( travels ).

  ENDMETHOD.

  METHOD get_instance_features.
*  Reads data from the Travel RAP business object
* Uses RAP buffer (not direct DB) because of LOCAL MODE
* Specifies which entity you are reading (Travel root entity)
* Only fetches these two fields from Travel:TravelId OverallStatus
* Maps input key structure (keys) automatically to Travel keys
* Used to select correct Travel records
* Stores retrieved Travel records into internal table lt_travel
* Captures any failed read operations (invalid keys, missing data, etc.)
    READ ENTITIES OF zi_vc_travel_vch IN LOCAL MODE
    ENTITY zi_vc_travel_vch
    FIELDS (  TravelId OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel)
    FAILED failed.

    result = VALUE #(  FOR travel IN lt_travel
                          ( %tky = travel-%tky
                           %assoc-_Booking = COND #( WHEN travel-OverallStatus = 'X'
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )
                           %action-acceptTravel = COND #( WHEN travel-OverallStatus = 'A'
                                                           THEN if_abap_behv=>fc-o-disabled
                                                           ELSE if_abap_behv=>fc-o-enabled ) ) )  .

  ENDMETHOD.

  METHOD validatebookingfee .
    READ ENTITIES OF zi_vc_travel_vch IN LOCAL MODE  " Read BookingFee from Travel entity passed into traveldates internal table.
    ENTITY zi_vc_travel_vch
    FIELDS ( BookingFee )
    WITH CORRESPONDING #( keys )
    RESULT DATA(traveldates).

    LOOP AT traveldates INTO DATA(traveldate). " Loop the internal table into workarea traveldate.

      IF traveldate-BookingFee < 2. " The booking fee if less than 2 for that specific record then error thrown on UI , Booking fee cannot be less than 2. and the record passed into table
        " reported-zi_vc_travel_vch.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(  severity = if_abap_behv_message=>severity-error
                        text = 'Booking Fee cannot be less than 2'
                        ) ) TO reported-zi_vc_travel_vch.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF zi_vc_travel_vch IN LOCAL MODE  " READ fields BeginDate and EndDate from entity travel and pass the data with their key values into internal table traveldates.
    ENTITY zi_vc_travel_vch
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(traveldates).

    LOOP AT traveldates INTO DATA(traveldate). " Loop data from internal table into workarea traveldate.

      IF ( traveldate-BeginDate IS INITIAL OR traveldate-EndDate IS INITIAL ) AND ( traveldate-BeginDate <= traveldate-EndDate ) . " Now if the Begindate for struc and Endate is empty

        APPEND VALUE #(   " The record will be passed into table reported-zi_vc_travel_vch.
          %tky = keys[ 1 ]-%tky
  ) TO failed-zi_vc_travel_vch.

        APPEND VALUE #(   " The record will be passed into table reported-zi_vc_travel_vch.
               %tky = keys[ 1 ]-%tky
               %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                         text     = 'Begin Date and End Date must not be empty'
                       )
             ) TO reported-zi_vc_travel_vch.


      ENDIF.

      IF  traveldate-BeginDate > traveldate-EndDate .
        APPEND VALUE #(   " The record will be passed into table reported-zi_vc_travel_vch.
      %tky = keys[ 1 ]-%tky
) TO failed-zi_vc_travel_vch.

        APPEND VALUE #(   " The record will be passed into table reported-zi_vc_travel_vch.
               %tky = keys[ 1 ]-%tky
               %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                         text     = 'Begin Date  must be less than End Date'
                       )
             ) TO reported-zi_vc_travel_vch.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.
    MODIFY ENTITIES OF zi_vc_travel_vch IN LOCAL MODE " The Overall Status for a travel record gets updated to 'A'.
    ENTITY zi_vc_travel_vch
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                     OverallStatus = 'A' ) ).

    READ ENTITIES OF zi_vc_travel_vch IN LOCAL MODE " The updated records are fetched and passed into the internal table lt_result.
    ENTITY zi_vc_travel_vch
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).
    .

    result  = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky " The result parameter returns the updated record back to the Fiori UI.
                                                 %param  =  ls_result ) ).

  ENDMETHOD.

*  METHOD earlynumbering_create.
*    DATA: entity TYPE STRUCTURE FOR CREATE zi_vc_travel_vch.
*
*    DATA(entites_wo_travelid) = entities.
*
*    DATA : travel_id_max TYPE /dmo/travel_id.
**
*    DATA: use_number_range TYPE abap_bool VALUE abap_true.
**
*    IF use_number_range = abap_true.
**
*      LOOP AT entites_wo_travelid INTO entity.
**
*        IF entity-TravelId IS INITIAL.
**
*          TRY.
**
*              cl_numberrange_runtime=>number_get(
*                 EXPORTING
*                    nr_range_nr = '01'
*                    object = '/DMO/TRV_M'
*                    quantity = CONV #( lines( entites_wo_travelid ) )
*                 IMPORTING
*                    number = DATA(number_range_key)
*                    returncode = DATA(number_range_return_code)
*                    returned_quantity = DATA(number_range_returned_quantity) ).
**
*            CATCH cx_number_ranges INTO DATA(lx_number_ranges).
***          LOOP AT entites_wo_travelid INTO entity.
***            APPEND VALUE #( %cid = entity-%cid
***                            %key = entity-%key
***                            %is_draft = entity-%is_draft
***                            %msg = lx_number_ranges ) TO reported-zi_vc_travel_vch.
***
***            APPEND VALUE #( %cid = entity-%cid
***                           %key = entity-%key
***                           %is_draft = entity-%is_draft
***                          ) TO failed-zi_vc_travel_vch.
***
***          ENDLOOP.
***
***          EXIT.
*          ENDTRY.
**
*          travel_id_max = number_range_key - number_range_returned_quantity.
**
***    SELECT SINGLE FROM zvc_travel_vch FIELDS MAX( travel_id ) AS travelID INTO @DATA(travel_id_max).
***
***    " SELECT SINGLE FROM zvc_dftb_travel FIELDS MAX( travelid ) INTO @DATA(max_travel_id_draft).
***
***    "IF max_travel_id_draft > travel_id_max.
***    " travel_id_max = max_travel_id_draft.
***    "ENDIF.
***
***    "  DELETE entites_wo_travelid WHERE TravelId IS NOT INITIAL.
*          "         LOOP AT entites_wo_travelid INTO entity.
**
*          entity-TravelId = travel_id_max.
*          "ENDIF.
***
***
*        ENDIF.
*        APPEND VALUE #( %cid = entity-%cid
*                       %key = entity-%key
*                       %is_draft = entity-%is_draft ) TO mapped-zi_vc_travel_vch.
*      ENDLOOP.
*    ENDIF.
*  ENDMETHOD.

ENDCLASS.
