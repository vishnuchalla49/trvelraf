@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_VC_TRAVEL_VCH
  as projection on ZI_VC_TRAVEL_VCH
{
  key     TravelId,
          AgencyId,
          CustomerId,
          BeginDate,
          EndDate,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          BookingFee,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          TotalPrice,
          CurrencyCode,
          Description,
          OverallStatus,
          OverallStatusCriticality,
          CreatedBy,
          CreatedAt,
          LastChangedBy,
          LastChangedAt,
          /* Associations */
          _Agency,
          _Booking    : redirected to composition child ZC_BOOKING_VCH,
          _Currency,
          _Customer,
          _Status,
          _Attachment : redirected to composition child zc_vc_attable

}
