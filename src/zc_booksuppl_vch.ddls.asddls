@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Book Suppl View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKSUPPL_VCH
  as projection on ZI_BOOKSUPPL_VCH
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZC_BOOKING_VCH,
      _Supplement,
      _SupplementText,
      _Travel  : redirected to ZC_VC_TRAVEL_VCH

}
