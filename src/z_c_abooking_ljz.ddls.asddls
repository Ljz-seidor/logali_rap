@EndUserText.label: 'Consumption - Booking Approval'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_ABOOKING_LJZ
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
      _Travel : redirected to parent Z_C_ATRAVEL_LJZ,     
      _Customer,
      _Carrier
}
