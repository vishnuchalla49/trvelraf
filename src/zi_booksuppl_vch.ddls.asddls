@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suppl Views'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKSUPPL_VCH
  as select from zvc_booksupl_vch
  association        to parent ZI_BOOKING_VCH as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                 and $projection.BookingId = _Booking.BookingId
  association [1..1] to ZI_VC_TRAVEL_VCH      as _Travel         on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement     as _Supplement     on  $projection.SupplementId = _Supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on  $projection.SupplementId = _SupplementText.SupplementID

{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      //the persistent field last_changed_at plays a special role as a field ETag.
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Travel,
      _Booking,
      _Supplement,
      _SupplementText
}
