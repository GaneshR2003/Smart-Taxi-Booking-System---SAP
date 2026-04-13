@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View for Taxi Booking'
define root view entity ZR_TAXI_BOOK
  as select from ztaxi_book
{
  key booking_id as BookingId,
  passenger_name as PassengerName,
  pickup_loc as PickupLoc,
  drop_loc as DropLoc,
  @Semantics.amount.currencyCode: 'Currency'
  fare as Fare,
  currency as Currency,
  status as Status,
  
  // Criticality for UI Colors
 case status
    when 'R' then 2 // Yellow
    when 'r' then 2 
    when 'C' then 3 // Green
    when 'c' then 3 
    when 'D' then 3 // Green
    when 'd' then 3 
    when 'X' then 1 // Red
    when 'x' then 1 
    else 0          // Grey
  end as StatusCriticality
}
