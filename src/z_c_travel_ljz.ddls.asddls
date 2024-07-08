@EndUserText.label: 'Consumption - Travel'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity Z_C_TRAVEL_LJZ
  as projection on Z_I_TRAVEL_LJZ
{
  key     TravelId,
          @ObjectModel.text.element: [ 'AgencyName' ]
          AgencyId,
          _Agency.Name       as AgencyName,
          @ObjectModel.text.element: [ 'CustomerName' ]
          CustomerId,
          _Customer.LastName as CustomerName,
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
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEM_LJZ'
  virtual DiscountPrice : /dmo/total_price,

          /* Associations */
          _Agency,
          _Booking : redirected to composition child Z_C_BOOKING_LJZ,
          _Currency,
          _Customer
}
