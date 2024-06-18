@EndUserText.label: 'Consumption - Booking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_BOOKING_LJZ
  as projection on Z_I_BOOKING_LJZ
{
  key TravelId      as TravelId,
  key BookingId     as BookingId,
      BookingDate   as BookingDate,
      CustomerId    as CustomerID,
      CarrierId     as CarrierID,
      _Carrier.Name as CarrierName,
      ConnectionId  as ConnectionID,
      FlightDate    as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice   as FlightPrice,
      @Semantics.currencyCode: true
      CurrencyCode  as CurrencyCode,
      BookingStatus as BookingStatus,
      LastChangedAt as LastChangedAt,

      /* Associations */
      _Travel : redirected to parent z_c_travel_ljz,
      _BookingSupplement : redirected to composition child z_c_booksuppl_ljz,
      _Carrier,
      _Connection,
      _Customer

}
