@EndUserText.label: 'Consumption - Booking Supplement'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity Z_C_BOOKSUPPL_LJZ
  as projection on Z_I_BOOKSUPPL_LJZ
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      Price,
      CurrencyCode,
      /* Associations */
      _Booking,
      _Product,
      _SupplementText,
      _Travel
}
