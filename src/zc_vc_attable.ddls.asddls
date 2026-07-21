@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachement view projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zc_vc_attable
  as projection on zi_vc_attable
{
  key TravelId,
  key AttachId,
      Memo,
      Attachment,
      Mimetype,
      Filename,
      /* Associations */
      _Travel : redirected to parent ZC_VC_TRAVEL_VCH
}
