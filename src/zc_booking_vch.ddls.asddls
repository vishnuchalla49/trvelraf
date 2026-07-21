@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_VCH
  as projection on ZI_BOOKING_VCH
{
  key     TravelId,
  key     BookingId,
          BookingDate,
          CustomerId,
          CarrierId,
          ConnectionId,
          FlightDate,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          FlightPrice,
          CurrencyCode,
          BookingStatus,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_CALC_BOOK_ELE'
          @EndUserText.label: 'Remaining Days to flight'
  virtual RemainingDaysToFlight : abap.int8,
          LastChangedAt,
          /* Associations */
          _Bookingsuppl : redirected to composition child ZC_BOOKSUPPL_VCH,
          _Booking_Status,
          _Carrier,
          _Connection,
          _Customer,
          _Travel       : redirected to parent ZC_VC_TRAVEL_VCH
}
