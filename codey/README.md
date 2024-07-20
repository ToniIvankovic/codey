# Frontend app - Codey
This is the fronted part of the Codey app. The source code is located in the [lib](lib) directory. \
The code is structurally divided by the Model-Service-Repository pattern, where: 
- models define classes and interfaces,
- services process raw data and give information or cause state changes,
- repositories are concerned with fetching data from the backend API.
  
In the [widgets](widgets) directory, all the widgets used in the app are located. \
The widgets are separated into 5 categories, each category building the respective interface:
- Student interface 👨‍🎓
- Teacher interface 🧑‍🏫
- Creator interface 🎨
- Admin interface 🎛️
- Authentication interface 🔐
  
Each interface is logically very independent of the others, but some of the widgets are reused, so the it is structurally still a single app.

The app is deployed on AWS and it is possible to test it on the following url: [https://d3l6qdq14kds7s.cloudfront.net/](https://d3l6qdq14kds7s.cloudfront.net/)
