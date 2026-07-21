CLASS zcl_calc_book_ele DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_calc_book_ele IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_booking TYPE STANDARD TABLE OF zc_booking_vch. " Internal table lt_booking is of type the projection view having all it's fields as columns.

    lt_booking = CORRESPONDING #( it_original_data ). " Data then populated into the declared internal table above from it_original_data into lt_booking internal table.

    LOOP AT lt_booking ASSIGNING FIELD-SYMBOL(<fs_booking>). " Now evey loop data passed into workarea fs_booking from lt_booking internal table.

      <fs_booking>-RemainingDaysToFlight =
        <fs_booking>-FlightDate - cl_abap_context_info=>get_system_date( ). " Difference of flightdate and the current system date is stored in the virtual field of struc
      " field RemainigDaysToFlight.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_booking ). " Now the value updated into the virtual field RemainDaysToFlight and displayed in table ct_calculated_data.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity = 'ZC_BOOKING_VCH'. " Which entity to be considered .

      APPEND 'FLIGHTDATE' TO et_requested_orig_elements. " Field of that entity on which the calculation is done. This field is appended into the signature table .

    ENDIF.
  ENDMETHOD.
ENDCLASS.
