@EndUserText.label: 'Consumption - Travel Approval'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity Z_C_ATRAVEL_LJZ
  as projection on Z_I_TRAVEL_LJZ
{
  key TravelId,
      AgencyId,
      CustomerId,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Semantics.currencyCode: true
      CurrencyCode,
      Description,
      OverallStatus,
      LastChangedAt,
      
      /* Associations */
      _Booking : redirected to composition child Z_C_ABOOKING_LJZ,
      _Customer
}
