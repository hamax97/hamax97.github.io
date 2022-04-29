# P'UNK AVENUE Backend Challenge

1. Every hour collect information from the following APIs:

   - [Indego](https://www.rideindego.com), Philadelphia's bike-sharing program.
     [API URL](https://www.rideindego.com/stations/json/).

   - [Open Weather Map API](https://openweathermap.org/current#name), specifying a central
     location of Philadelphia.

2. Store the collected information.

3. Expose the stored information through the following endpoints:
   1. /api/v1/stations?at=\<dateTime>
   2. /api/v1/stations/\<kioskId>?at=\<dateTime>
   3. /api/v1/stations/\<kioskId>?from=\<fromDateTime>&to=\<toDateTime>&frequency=\<daily|hourly>

   The \<dateTime> should have the format: 2017-11-01T11:00:00.

4. Deploy to a cloud based infrastructure.

## Tech stack

- NestJS (NodeJS).
- Jest.
- TypeScript.
- Docker, hosted in [Linode](https://www.linode.com/).
- MongoDB, hosted in [MongoDB Cloud](https://www.mongodb.com/cloud).

## Links

- GitHub: https://github.com/hamax97/punkave-backend-challenge
- Detailed description of the challenge: https://github.com/punkave/backend-challenge.
- Implemented API URL: http://139.144.16.184. This URL works as of April 29th, 2022.
