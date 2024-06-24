@EndUserText.label: 'Consumption - Booking Supplement'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_BOOKSUPPL_LJZ
  as projection on Z_I_BOOKSUPPL_LJZ
{
  key TravelId                    as TravelId,
  key BookingId                   as BookingId,
  key BookingSupplementId         as BookingSupplementId,
      SupplementId                as SupplementId,
      _SupplementText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price                       as Price,
      @Semantics.currencyCode: true
      CurrencyCode                as CurrencyCode,
      LastChangedAt               as LastChangedAt,

      /* Associations */
      _Travel  : redirected to Z_C_TRAVEL_LJZ,
      _Booking : redirected to parent Z_C_BOOKING_LJZ,
      _Product,
      _SupplementText
}
