@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'booking proj view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_VC_Booking_vch_proj
  as projection on ZI_BOOKING_VCH
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _Bookingsuppl : redirected to composition child ZC_VC_BOOKSUPPL_PROJ,
      _Booking_Status,
      _Carrier,
      _Connection,
      _Customer,
      _Travel       : redirected to parent ZC_VC_TRAVEL_VCH
}
