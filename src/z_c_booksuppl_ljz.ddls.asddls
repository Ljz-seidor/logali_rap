@EndUserText.label: 'Consumption - Booking Supplement'
@AccessControl.authorizationCheck: #NOT_REQUIRED
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

      /* Associations */
      _Travel  : redirected to z_c_travel_ljz,
      _Booking : redirected to parent z_c_booking_ljz,
      _Product,
      _SupplementText
}
