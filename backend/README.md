The starting point of the backend app is in the API directory, in the  [Program.cs](backend/CodeyBE.API/Program.cs) file. \
The app is designed by the Controller-Service-Repository pattern:
- The Controller part is located in the [CodeyBE.API](backend/CodeyBE.API) directory. It is concerned with creating an API for the frontend app to connect to. 📡
- The Service part is located in the [CodeyBE.Services](backend/CodeyBE.Services) directory. It contains all the business logic of the app and converts the data received from repositories to useful information demanded by controllers or other services. ⚙️
- The Repository part is located in the [CodeyBE.Data.DB](backend/CodeyBE.Data.DB) directory. It is concerned with fetching raw data from the database (MongoDB) and serving it to those who demand it (usually services). 📊

*In order to achieve inversion of control and dependency injection, all the services and repositories are first defined as interfaces in the [CodeyBE.Contracts](backend/CodeyBE.Contracts) directory.
