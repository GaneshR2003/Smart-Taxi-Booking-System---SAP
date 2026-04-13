@EndUserText.label: 'Projection View for Taxi Booking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TAXI_BOOK
  provider contract transactional_query
  as projection on ZR_TAXI_BOOK
{
  key BookingId,
  PassengerName,
  PickupLoc,
  DropLoc,
  Fare,
  Currency,
  Status,
  StatusCriticality
}
