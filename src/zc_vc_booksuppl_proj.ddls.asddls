@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BookSuppl View Proj'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_VC_BOOKSUPPL_PROJ
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
      _Booking : redirected to parent ZC_VC_Booking_vch_proj,
      _Supplement,
      _SupplementText,
      _Travel  : redirected to ZC_VC_TRAVEL_VCH
}
