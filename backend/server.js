
const express = require('express');
const mongoose = require('mongoose');

const app = express();
const port = 3000;

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/test')
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('Error connecting to MongoDB', err));

// Define a schema for your data
// const mySchema = new mongoose.Schema({
//   ID: Number,
//   Type: String,
//   Question: String,
// });

// Define a model for your data
const ExercisesModel = mongoose.model('exercises',{});
// Define a route to get all data
app.get('/api/data/exercises', async (req, res) => {
  const data = await ExercisesModel.find();
  res.send(data);
});

// Define a model for your data
const LessonsModel = mongoose.model('lessons',{});
// Define a route to get all data
app.get('/api/data/lessons', async (req, res) => {
  const data = await LessonsModel.find();
  res.send(data);
});

// Define a model for your data
const LessonGroupsModel = mongoose.model('lesson_groups',{});
// Define a route to get all data
app.get('/api/data/lesson_groups', async (req, res) => {
  const data = await LessonGroupsModel.find();
  res.send(data);
});

// Start the server
app.listen(port, () => console.log(`Server listening on port ${port}`));
